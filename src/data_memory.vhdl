-- Author: Pablo Orduna Lagarma
-- RISC V

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity data_memory is 
	Port ( in_clk : in std_logic;
	       in_addr : in std_logic_vector(31 downto 0);
	       in_D : in std_logic_vector(31 downto 0);
	       in_WE : in std_logic;
	       in_RE : in std_logic;
	       out_val : out std_logic_vector(31 downto 0));
end data_memory;

architecture Behavioral of data_memory is
	type memory is array(0 to 127) of std_logic_vector(31 downto 0);
	signal RAM : memory := ( X"deadbeef", X"ae86ae86", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000");
	signal addr7b : std_logic_vector(6 downto 0); 
begin
	addr7b <= in_addr(8 downto 2);
	process (in_clk)
	begin
		if (in_clk'event and in_clk = '1') then
			if (in_WE = '1') then
				RAM(conv_integer(addr7b)) <= in_D;
			end if;
		end if;
	end process;

	out_val <= RAM(conv_integer(addr7b)) when (in_RE = '1') else X"00000000";
end Behavioral;
