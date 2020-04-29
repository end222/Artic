-- Author: Pablo Orduna Lagarma
-- RISC V

-- Instruction and data memory
-- 2 read ports and 1 write port
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity memory is 
	Port ( in_clk : in std_logic;
	       in_addr : in std_logic_vector(31 downto 0);
	       in_addr2 : in std_logic_vector(31 downto 0);
	       in_D : in std_logic_vector(31 downto 0);
	       in_WE : in std_logic;
	       in_RE : in std_logic;
	       in_RE2 : in std_logic;
	       out_val : out std_logic_vector(31 downto 0);
	       out_val2 : out std_logic_vector(31 downto 0));
end memory;

architecture Behavioral of memory is
	type memory is array(0 to 127) of std_logic_vector(31 downto 0);
	signal RAM : memory := (X"004000EF", X"FFDFF0EF", X"000005B7", X"00158593", X"000000B7", X"00008093", X"00000137", X"00010113", X"000001B7", X"00018193", X"00208233", X"FC419AE3", X"00B50533", X"000000B7", X"00108093", X"00000137", X"00110113", X"000001B7", X"00218193", X"00208233", X"FA4198E3", X"00B50533", X"FFFF80B7", X"00008093", X"00000137", X"00010113", X"FFFF81B7", X"00018193", X"00208233", X"F84196E3", X"00B50533", X"FFFF80B7", X"00008093", X"80000137", X"00010113", X"7FFF81B7", X"00018193", X"00208233", X"F64194E3", X"00B50533", X"FFDFF0EF", X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000");
	signal addr7b : std_logic_vector(6 downto 0); 
	signal addr7b2 : std_logic_vector(6 downto 0); 
begin
	-- addr7b is used to index instructions and addr7b2 is used by the memory stage.
	-- Then only addr7b2 can be used to write to memory
	addr7b <= in_addr(8 downto 2);
	addr7b2 <= in_addr2(8 downto 2);
	process (in_clk)
	begin
		if (in_clk'event and in_clk = '1') then
			if (in_WE = '1') then
				RAM(conv_integer(addr7b2)) <= in_D;
			end if;
		end if;
	end process;

	out_val <= RAM(conv_integer(addr7b)) when (in_RE = '1') else X"00000000";
	out_val2 <= RAM(conv_integer(addr7b2)) when (in_RE2 = '1') else X"00000000";
end Behavioral;
