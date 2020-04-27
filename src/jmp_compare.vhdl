-- Author: Pablo Orduna Lagarma
-- Risc V

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity jmp_compare is
	Port ( in_A : in std_logic_vector(31 downto 0);
	       in_B : in std_logic_vector(31 downto 0);
	       eq : out std_logic;
	       lt : out std_logic;
	       ltu : out std_logic);
end jmp_compare;

architecture Behavioral of jmp_compare is
begin
	lt <= '1' when to_integer(signed(in_A)) < to_integer(signed(in_B))
	      else '0';
	ltu <= '1' when to_integer(unsigned(in_A)) < to_integer(unsigned(in_B))
	      else '0';
	eq <= '1' when to_integer(in_A) = to_integer(in_B)
	      else '0';
end Behavioral;
