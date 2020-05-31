-- Author: Pablo Orduna Lagarma
-- RISC V

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity system_trap_handler is 
	Port ( in_clk : in std_logic;
	       in_WE : in std_logic;
	       in_D : in std_logic_vector(31 downto 0);
	       out_val : out std_logic_vector(31 downto 0));
end system_trap_handler;

architecture Behavioral of system_trap_handler is
	signal handler : std_logic_vector(31 downto 0) := X"00000000";
begin
	out_val <= handler; 
	process (in_clk)
	begin
		if (in_clk'event and in_clk = '0') then
			if (in_WE = '1') then
				handler <= in_D;
			end if;
		end if;
	end process;
end Behavioral;
