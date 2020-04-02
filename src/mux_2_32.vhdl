-- Author: Pablo Orduna Lagarma
-- RISC V

library ieee;
use ieee.std_logic_1164.all;

entity mux_2_32 is
	Port ( in_0 : in std_logic_vector (31 downto 0);
	       in_1 : in std_logic_vector(31 downto 0);
	       ctrl : in std_logic;
	       out_val : out std_logic_vector(31 downto 0));
end mux_2_32;

architecture Behavioral of mux_2_32 is
begin
	out_val <= in_1 when (ctrl = '1') else in_0;
end Behavioral;
