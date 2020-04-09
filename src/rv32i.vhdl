-- Author: Pablo Orduna Lagarma
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

	signal decode_rs1_id, decode_rs2_id, decode_rd_id : std_logic_vector(4 downto 0);
	signal func3 : std_logic_vector(2 downto 0);
	signal func7, opcode : std_logic_vector(6 downto 0);
	component decoder is
		Port ( in_inst : in  std_logic_vector (31 downto 0);
		       out_rs1 : out  std_logic_vector (4 downto 0);
		       out_rs2 : out  std_logic_vector (4 downto 0);
		       out_rd : out  std_logic_vector (4 downto 0);
		       out_func3 : out  std_logic_vector (2 downto 0);
		       out_func7 : out  std_logic_vector (6 downto 0);
		       out_opcode : out  std_logic_vector (6 downto 0));
	end component;

	signal decode_rs1_value, decode_rs2_value : std_logic_vector(31 downto 0);
	component r32b is
		Port ( in_clk : in std_logic;
		       in_reset : in std_logic;
		       in_rs1_addr : in std_logic_vector (4 downto 0);
		       in_rs2_addr : in std_logic_vector (4 downto 0);
		       in_write_addr : in std_logic_vector (4 downto 0);
		       in_write_value : in std_logic_vector (31 downto 0);
		       in_WE : in std_logic;						
		       out_rs1 : out std_logic_vector (31 downto 0);
		       out_rs2 : out std_logic_vector (31 downto 0));
	end component;

	signal exec_rs1_value, exec_rs2_value, exec_rd_value, exec_inm : std_logic_vector(31 downto 0);
	signal exec_rs1_id, exec_rs2_id, exec_rd_id : std_logic_vector(4 downto 0);
	signal exec_rst_inuse, exec_fp_add, exec_memwrite, exec_memread, exec_memtoreg, exec_alu_src : std_logic;
	signal exec_alu_opctrl : std_logic_vector(1 downto 0);
	
	component decode_exec is
		Port ( in_clk : in std_logic;
		       in_reset : in std_logic;
		       in_load : in std_logic;

		       decode_rs1_value : in std_logic_vector(31 downto 0);
		       decode_rs2_value : in std_logic_vector(31 downto 0);
		       decode_rs1_id : in std_logic_vector(4 downto 0);
		       decode_rs2_id : in std_logic_vector(4 downto 0);
		       decode_rd_id : in std_logic_vector(4 downto 0);
		       decode_inm : in std_logic_vector(31 downto 0);
		       decode_rst_inuse : in std_logic;
		       decode_fp_add : in std_logic;
		       decode_alu_opctrl : in std_logic_vector(1 downto 0);
		       decode_memwrite : in std_logic;
		       decode_memread : in std_logic;
		       decode_memtoreg : in std_logic;
		       decode_alu_src : in std_logic;

		       exec_rs1_value : out std_logic_vector(31 downto 0);
		       exec_rs2_value : out std_logic_vector(31 downto 0);
		       exec_rs1_id : out std_logic_vector(4 downto 0);
		       exec_rs2_id : out std_logic_vector(4 downto 0);
		       exec_rd_id : out std_logic_vector(4 downto 0);
		       exec_inm : out std_logic_vector(31 downto 0);
		       exec_rst_inuse : out std_logic;
		       exec_fp_add : out std_logic;
		       exec_alu_opctrl : out std_logic_vector(1 downto 0);
		       exec_memwrite : out std_logic;
		       exec_memread : out std_logic;
		       exec_memtoreg : out std_logic;
		       exec_alu_src : out std_logic);
	end component;

	signal exec_alu_out_value : std_logic_vector(31 downto 0);
	component ALU is 
		Port ( in_clk : in std_logic;
		       in_A : in std_logic_vector(31 downto 0);
		       in_B : in std_logic_vector(31 downto 0);
		       op_ctrl : in std_logic_vector (1 downto 0);
		       out_value : out std_logic_vector(31 downto 0));
	end component;

	signal memory_rs1_value, memory_rs2_value : std_logic_vector(31 downto 0);
	signal memory_rd_id : std_logic_vector(4 downto 0);
	signal memory_rst_inuse, memory_rst_inuse, memory_memwrite, memory_memread, memory_memtoreg : std_logic;
	component exec_memory is
		Port ( in_clk : in std_logic;
		       in_reset : in std_logic;
		       in_load : in std_logic;
		       exec_rs1_value : in std_logic_vector(31 downto 0);
		       exec_rs2_value : in std_logic_vector(31 downto 0);
		       exec_rd_id : in std_logic_vector(4 downto 0);
		       exec_rst_inuse : in std_logic;
		       exec_memwrite : in std_logic;
		       exec_memread : in std_logic;
		       exec_memtoreg : in std_logic;
		       memory_rs1_value : out std_logic_vector(31 downto 0);
		       memory_rs2_value : out std_logic_vector(31 downto 0);
		       memory_rd_id : out std_logic_vector(4 downto 0);
		       memory_rst_inuse : out std_logic;
		       memory_memwrite : out std_logic;
		       memory_memread : out std_logic;
		       memory_memtoreg : out std_logic);
	end component;

	signal memory_mem_out_value : std_logic_vector(31 downto 0);
	component data_memory is
		Port ( in_clk : in std_logic;
		       in_addr : in std_logic_vector(31 downto 0);
		       in_D : in std_logic_vector(31 downto 0);
		       in_WE : in std_logic;
		       in_RE : in std_logic;
		       out_val : out std_logic_vector(31 downto 0));
	end component;

	signal writeback_alu_out_value, writeback_mem_out_value : std_logic_vector(31 downto 0);
	signal writeback_rd_id : std_logic_vector(4 downto 0);
	signal writeback_rst_inuse, writeback_memwrite, writeback_memread, writeback_memtoreg : std_logic;
	component memory_writeback is
		Port ( in_clk : in std_logic;
		       in_reset : in std_logic;
		       in_load : in std_logic;
		       memory_alu_out_value : in std_logic_vector(31 downto 0);
		       memory_mem_out_value : in std_logic_vector(31 downto 0);
		       memory_rd_id : in std_logic_vector(4 downto 0);
		       memory_rst_inuse : in std_logic; 
		       memory_memwrite : in std_logic;
		       memory_memread : in std_logic;
		       memory_memtoreg : in std_logic;
		       writeback_alu_out_value : out std_logic_vector(31 downto 0);
		       writeback_mem_out_value : out std_logic_vector(31 downto 0);
		       writeback_rd_id : out std_logic_vector(4 downto 0);
		       writeback_rst_inuse : out std_logic;
		       writeback_memwrite : out std_logic;
		       writeback_memread : out std_logic;
		       writeback_memtoreg : out std_logic);
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

	deco : decoder port map ( in_inst => inst_out,
				  out_rs1 => decode_rs1_id,
				  out_rs2 => decode_rs2_id,
				  out_rd => decode_rd_id,
				  out_func3 => func3,
				  out_func7 => func7,
				  out_opcode => opcode);

	registerb : r32b port map ( in_clk => clk,
				in_reset => in_reset,
				in_rs1_addr => decode_rs1_id,
				in_rs2_addr => decode_rs2_id,
				in_write_addr => "00000", -- Needed for writeback
				in_write_value => X"00000000",
				in_WE => '0',
				out_rs1 => decode_rs1_value,
				out_rs2 => decode_rs2_value);
	de_reg : decode_exec port map ( in_clk => clk,
		       in_reset => in_reset,
		       in_load => '1',

		       decode_rs1_value => decode_rs1_value,
		       decode_rs2_value => decode_rs2_value,
		       decode_rs1_id => decode_rs1_id,
		       decode_rs2_id => decode_rs2_id,
		       decode_rd_id => decode_rd_id,
		       decode_inm => X"00000000",
		       decode_rst_inuse => '0',
		       decode_fp_add => '0',
		       decode_alu_opctrl => "00",
		       decode_memwrite => '0',
		       decode_memread => '0',
		       decode_memtoreg => '0',
		       decode_alu_src => '0',

		       exec_rs1_value => exec_rs1_value,
		       exec_rs2_value => exec_rs2_value,
		       exec_rs1_id => exec_rs1_id,
		       exec_rs2_id => exec_rs2_id,
		       exec_rd_id => exec_rd_id,
		       exec_inm => exec_inm,
		       exec_rst_inuse => exec_rst_inuse,
		       exec_fp_add => exec_fp_add,
		       exec_alu_opctrl => exec_alu_opctrl,
		       exec_memwrite => exec_memwrite,
		       exec_memread => exec_memread,
		       exec_memtoreg => exec_memtoreg,
		       exec_alu_src => exec_alu_src);

	alu_int : ALU port map ( in_clk => clk,
				 in_A => exec_rs1_value,
				 in_B => exec_rs2_value,
				 op_ctrl => exec_alu_opctrl,
				 out_value => exec_alu_out_value);

	em_reg : exec_memory port map (in_clk => clk,
				       in_reset => in_reset,
				       in_load => '1',
				       exec_rs1_value => exec_rs1_value,
				       exec_rs2_value => exec_rs2_value,
				       exec_rd_id => exec_rd_id,
				       exec_rst_inuse => exec_rst_inuse,
				       exec_memwrite => exec_memwrite,
				       exec_memread => exec_memread,
				       exec_memtoreg => exec_memtoreg,
				       memory_rs1_value => memory_rs1_value,
				       memory_rs2_value => memory_rs2_value,
				       memory_rd_id => memory_rd_id,
				       memory_rst_inuse => memory_rst_inuse,
				       memory_memwrite => memory_memwrite,
				       memory_memread => memory_memread,
				       memory_memtoreg => memory_memtoreg);

	data_mem : data_memory port map ( in_clk => clk,
					in_addr => X"00000000",
					in_D => X"00000000",
					in_WE => memory_memwrite,
					in_RE => memory_memread,
					out_val => memory_mem_out_value);

end Behavioral;
