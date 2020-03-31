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
	signal PC_in, PC_out : std_logic_vector(31 downto 0);
	signal load_PC : std_logic;
	component reg32 is
		port( in_clk : in std_logic;
		      in_D : in std_logic_vector(31 downto 0);
		      in_W : in std_logic;
		      in_reset : in std_logic;
		      out_val : out std_logic_vector(31 downto 0)
	      );
	end component;

begin
	pc: reg32 port map ( in_D => PC_in,
			     in_clk => clk,
			     in_reset => in_reset,
			     in_W => load_PC,
			     out_val => PC_out);
end Behavioral;
