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
	       in_func3 : in std_logic_vector(2 downto 0);
	       out_val : out std_logic_vector(31 downto 0);
	       out_val2 : out std_logic_vector(31 downto 0));
end memory;

architecture Behavioral of memory is
	type memory is array(0 to 127) of std_logic_vector(31 downto 0);
	signal RAM : memory := (X"004000EF", X"FFDFF0EF", X"000005B7", X"00158593", X"000000B7", X"0E408093", X"00AA0137", X"0AA10113", X"0020A023", X"0000A183", X"FC311CE3", X"00B50533", X"AA00B137", X"A0010113", X"0020A223", X"0040A183", X"FC3110E3", X"00B50533", X"0AA01137", X"AA010113", X"0020A423", X"0080A183", X"FA3114E3", X"00B50533", X"A00AA137", X"00A10113", X"0020A623", X"00C0A183", X"F83118E3", X"00B50533", X"000000B7", X"10008093", X"00AA0137", X"0AA10113", X"FE20AA23", X"FF40A183", X"F63118E3", X"00B50533", X"AA00B137", X"A0010113", X"FE20AC23", X"FF80A183", X"F4311CE3", X"00B50533", X"0AA01137", X"AA010113", X"FE20AE23", X"FFC0A183", X"F43110E3", X"00B50533", X"A00AA137", X"00A10113", X"0020A023", X"0000A183", X"F23114E3", X"00B50533", X"FFDFF0EF", X"DEADBEEF", X"DEADBEEF", X"DEADBEEF", X"DEADBEEF", X"DEADBEEF", X"DEADBEEF", X"DEADBEEF", X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000");
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
				-- SW
				if (in_func3 = "010") then
					RAM(conv_integer(addr7b2)) <= in_D;

				-- SH
				elsif (in_func3 = "001") then
					RAM(conv_integer(addr7b2)) <= in_D;

				-- SB
				else
					RAM(conv_integer(addr7b2)) <= in_D;
				end if;
			end if;
		end if;
	end process;

	process(addr7b, addr7b2, in_RE, in_RE2, in_func3)
	begin
		if (in_RE = '1') then
			out_val <= RAM(conv_integer(addr7b));
		else
			out_val <= X"00000000";	
		end if;
		if (in_RE2 = '1') then 
			-- LW
			if (in_func3 = "010") then
				out_val2 <= RAM(conv_integer(addr7b2));

			-- LH
			elsif (in_func3 = "001") then
				out_val2 <= RAM(conv_integer(addr7b2));

			-- LB
			elsif ( in_func3 = "000" ) then
				out_val2 <= RAM(conv_integer(addr7b2));

			-- LBU
			elsif ( in_func3 = "100" ) then
				out_val2 <= RAM(conv_integer(addr7b2));

			-- LHU
			else
				out_val2 <= RAM(conv_integer(addr7b2));
			end if;

		else
			out_val2 <= X"00000000";
		end if;
	end process;
end Behavioral;
