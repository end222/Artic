-- Author: Pablo Orduna Lagarma
-- Artic Risc V


library ieee;
use ieee.std_logic_1164.all;

entity fetch_decode is
	Port (
		in_clk : in std_logic;
		in_reset : in std_logic;
		in_load : in std_logic;
		fetch_inst : in std_logic_vector (31 downto 0);
	        fetch_pc : in std_logic_vector (31 downto 0);
		fetch_next_pc : in std_logic_vector (31 downto 0);
		decode_inst : out std_logic_vector (31 downto 0);
	        decode_pc : out std_logic_vector(31 downto 0);
		decode_next_pc : out std_logic_vector (31 downto 0)
	);
end fetch_decode;


architecture RTL of fetch_decode is
begin
	process(in_clk)
	begin
		if(rising_edge(in_clk)) then
			if (in_reset = '1') then
				decode_inst <= "00000000000000000000000000000000";
				decode_pc <= "00000000000000000000000000000000";
				decode_next_pc <= "00000000000000000000000000000000";
			else
				if (in_load = '1') then
					decode_inst <= fetch_inst;
					decode_pc <= fetch_pc;
					decode_next_pc <= fetch_next_pc;
				end if;
			end if;
		end if;
	end process;
end RTL;
