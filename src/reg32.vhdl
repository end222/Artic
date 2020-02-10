-- Author: Pablo Orduna Lagarma (end222)
-- Risc V

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Implementation of a 32b register

entity reg32 is
	generic(
		value : std_logic_vector(31 downto 0)
	);
	port(
		in_clk : in std_logic;
		in_D : in std_logic_vector(31 downto 0);
		in_W : in std_logic;
		in_reset : in std_logic;
		out_val : out std_logic_vector(31 downto 0)
	);
end entity reg32;

architecture RTL of reg32 is
	signal out_val_internal : std_logic_vector(31 downto 0) := value;
begin
	process(in_clk)
	begin
		if(rising_edge(in_clk)) then
			if (in_reset = '1') then
				out_val_internal <= "00000000000000000000000000000000";
			else
				if (in_W = '1') then
					out_val_internal <= in_D;
				end if;
			end if;
		end if;
	end process;
	out_val <= out_val_internal;
end architecture RTL;
