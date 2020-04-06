-- Author: Pablo Orduna Lagar,a
-- Risc V

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity RV32I is
	Port ( clk : in std_logic;
	       in_reset : in std_logic);
end RV32I;

architecture Behavioral of RV32I is
	component ALU is
		Port ( in_clk : in std_logic;
		       in_A : in  std_logic_vector (31 downto 0);
		       in_B : in  std_logic_vector (31 downto 0);
		       op_ctrl : in  std_logic_vector (1 downto 0);
		       out_value : out  std_logic_vector (31 downto 0));
	end component;

	component mux_2_32 is
		Port ( in_0 : in std_logic_vector (31 downto 0);
		       in_1 : in std_logic_vector(31 downto 0);
		       ctrl : in std_logic;
		       out_val : out std_logic_vector(31 downto 0));
	end component;

	-- 32 bit adder used to increase PC by 4
	signal adder4_out : std_logic_vector(31 downto 0);
	component adder32 is
		Port ( in_0 : in std_logic_vector(31 downto 0);
		       in_1 : in std_logic_vector(31 downto 0);
		       out_val : out std_logic_vector(31 downto 0));
	end component;

	signal PC_in, PC_out : std_logic_vector(31 downto 0);
	component reg32 is
		port( in_clk : in std_logic;
		      in_D : in std_logic_vector(31 downto 0);
		      in_W : in std_logic;
		      in_reset : in std_logic;
		      out_val : out std_logic_vector(31 downto 0)
	      );
	end component;

	signal inst_out : std_logic_vector(31 downto 0);
	component inst_memory is
		Port ( in_clk : in std_logic;
		       in_addr : in std_logic_vector(31 downto 0);
		       in_D : in std_logic_vector(31 downto 0);
		       in_WE : in std_logic;
		       in_RE : in std_logic;
		       out_val : out std_logic_vector(31 downto 0));
	end component;

	-- TODO: if jmp is absolute it is not needed to store next_pc here
	signal decode_inst_fd, decode_next_pc_fd : std_logic_vector(31 downto 0);
	component fetch_decode is
		Port ( in_clk : in std_logic;
		       in_reset : in std_logic;
		       in_load : in std_logic;
		       fetch_inst : in std_logic_vector (31 downto 0);
		       fetch_next_pc : in std_logic_vector (31 downto 0);
		       decode_inst : out std_logic_vector (31 downto 0);
		       decode_next_pc : out std_logic_vector (31 downto 0));
	end component;

begin
	-- 32b register that contains the PC
	pc : reg32 port map ( in_D => PC_in,
			      in_clk => clk,
			      in_reset => in_reset,
			      in_W => '1', -- Always load
			      out_val => PC_out);

	-- TODO: implement jump and modify this mux to choose between the new calculated
	-- direction and the one from the PC adder
	pc_mux : mux_2_32 port map ( in_0 => adder4_out,
				     in_1 => "00000000000000000000000000000000",
				     ctrl => '0',
				     out_val => PC_in);

	adder4 : adder32 port map ( in_0 => PC_out,
				    in_1 => "00000000000000000000000000000100",
				    out_val => adder4_out);

	inst_mem : inst_memory port map ( in_clk => clk,
					  in_addr => PC_out,
					  in_D => X"00000000",
					  in_WE => '0',
					  in_RE => '1',
					  out_val => inst_out);

	fd_reg : fetch_decode port map ( in_clk => clk,
					 in_reset => '0',
					 in_load => '1',
					 fetch_inst => inst_out,
					 fetch_next_pc => adder4_out,
					 decode_inst => decode_inst_fd,
					 decode_next_pc => decode_next_pc_fd);

end Behavioral;
