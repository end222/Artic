-- Author: Pablo Orduna Lagarma
-- RISC V

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity system_handler is 
	Port ( in_clk : in std_logic;
	       in_WE : in std_logic;
	       in_D : in std_logic_vector(31 downto 0);
	       in_De : in std_logic_vector(31 downto 0);
	       exception : in std_logic_vector(1 downto 0);
	       out_val : out std_logic_vector(31 downto 0));
end system_handler;

architecture Behavioral of system_handler is
	signal trap_handler : std_logic_vector(31 downto 0) := X"00000000";
	signal exception_handler : std_logic_vector(31 downto 0) := X"00000000";
begin
	out_val <= trap_handler when exception = "10"
		   else exception_handler when exception = "01";
	process (in_clk)
	begin
		if (in_clk'event and in_clk = '0') then
			if (in_WE = '1') then
				trap_handler <= in_D;
				exception_handler <= in_De;
			end if;
		end if;
	end process;
end Behavioral;
