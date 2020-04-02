-- Author: Pablo Orduna Lagarma
-- RISC V

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- In order to use arithmetic functions
use ieee.numeric_std.all;

entity adder32 is
	Port ( in_0 : in std_logic_vector(31 downto 0);
	       in_1 : in std_logic_vector(31 downto 0);
	       out_val : out std_logic_vector(31 downto 0));
end adder32;

architecture Behavioral of adder32 is
begin
	out_val <= in_0 + in_1;
end Behavioral;
