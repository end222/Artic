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
	signal RAM : memory := (X"004000EF", X"FFDFF0EF", X"000005B7", X"00158593", X"FF0100B7", X"F0008093", X"FF0101B7", X"F0018193", X"F0F0F213", X"FC419EE3", X"00B50533", X"0FF010B7", X"FF008093", X"000001B7", X"0F018193", X"0F00F213", X"FC4190E3", X"00B50533", X"00FF00B7", X"0FF08093", X"000001B7", X"00F18193", X"70F0F213", X"FA4192E3", X"00B50533", X"F00FF0B7", X"00F08093", X"000001B7", X"00018193", X"0F00F213", X"F84194E3", X"00B50533", X"0FF010B7", X"FF008093", X"000001B7", X"70018193", X"70F0F213", X"F64196E3", X"00B50533", X"00FF00B7", X"0FF08093", X"000001B7", X"0F018193", X"0F00F213", X"F44198E3", X"00B50533", X"F00FF0B7", X"00F08093", X"F00FF1B7", X"00F18193", X"F0F0F213", X"F2419AE3", X"00B50533", X"0FF010B7", X"FF008093", X"000001B7", X"70018193", X"70F0F213", X"F0419CE3", X"00B50533", X"FFDFF0EF", X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000");
	signal addr7b : std_logic_vector(6 downto 0); 
	signal addr7b2 : std_logic_vector(6 downto 0); 
begin
	-- addr7b is used to index instructions and addr7b2 is used by the memory stage.
	-- Then only addr7b2 can be used to write to memory
	-- TODO: this is not taking into account misaligned addresses
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
					if (in_addr2(1) = '1') then
						RAM(conv_integer(addr7b2))(31 downto 16) <= in_D(15 downto 0);
					else
						RAM(conv_integer(addr7b2))(15 downto 0) <= in_D(15 downto 0);
					end if;
				-- SB
				else
					if(in_addr2(1 downto 0) = "00") then
						RAM(conv_integer(addr7b2))(7 downto 0) <= in_D(7 downto 0);
					elsif(in_addr2(1 downto 0) = "01") then
						RAM(conv_integer(addr7b2))(15 downto 8) <= in_D(7 downto 0);
					elsif(in_addr2(1 downto 0) = "10") then
						RAM(conv_integer(addr7b2))(23 downto 16) <= in_D(7 downto 0);
					else
						RAM(conv_integer(addr7b2))(31 downto 24) <= in_D(7 downto 0);
					end if;
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
				if (in_addr2(1) = '1') then
					out_val2(15 downto 0) <= RAM(conv_integer(addr7b2))(31 downto 16);
						-- Expand taking sign into account
					if (RAM(conv_integer(addr7b2))(31) = '1') then
						out_val2(31 downto 16) <= X"FFFF";
					else
						out_val2(31 downto 16) <= X"0000";
					end if;
				else
					out_val2(15 downto 0) <= RAM(conv_integer(addr7b2))(15 downto 0);
						-- Expand taking sign into account
					if (RAM(conv_integer(addr7b2))(15) = '1') then
						out_val2(31 downto 16) <= X"FFFF";
					else
						out_val2(31 downto 16) <= X"0000";
					end if;
				end if;

				-- LB
			elsif ( in_func3 = "000" ) then
				if(in_addr2(1 downto 0) = "00") then
					out_val2(7 downto 0) <= RAM(conv_integer(addr7b2))(7 downto 0);
						-- Expand taking sign into account
					if (RAM(conv_integer(addr7b2))(7) = '1') then
						out_val2(31 downto 8) <= X"FFFFFF";
					else
						out_val2(31 downto 8) <= X"000000";
					end if;
				elsif(in_addr2(1 downto 0) = "01") then
					out_val2(7 downto 0) <= RAM(conv_integer(addr7b2))(15 downto 8);
						-- Expand taking sign into account
					if (RAM(conv_integer(addr7b2))(15) = '1') then
						out_val2(31 downto 8) <= X"FFFFFF";
					else
						out_val2(31 downto 8) <= X"000000";
					end if;
				elsif(in_addr2(1 downto 0) = "10") then
					out_val2(7 downto 0) <= RAM(conv_integer(addr7b2))(23 downto 16);
						-- Expand taking sign into account
					if (RAM(conv_integer(addr7b2))(23) = '1') then
						out_val2(31 downto 8) <= X"FFFFFF";
					else
						out_val2(31 downto 8) <= X"000000";
					end if;
				else
					out_val2(7 downto 0) <= RAM(conv_integer(addr7b2))(31 downto 24);
						-- Expand taking sign into account
					if (RAM(conv_integer(addr7b2))(31) = '1') then
						out_val2(31 downto 8) <= X"FFFFFF";
					else
						out_val2(31 downto 8) <= X"000000";
					end if;
				end if;

				-- LBU and LHU do not sign-extend, unlike the previous ones
				-- LBU
			elsif ( in_func3 = "100" ) then
				if(in_addr2(1 downto 0) = "00") then
					out_val2(7 downto 0) <= RAM(conv_integer(addr7b2))(7 downto 0);
					out_val2(31 downto 8) <= X"000000";
				elsif(in_addr2(1 downto 0) = "01") then
					out_val2(7 downto 0) <= RAM(conv_integer(addr7b2))(15 downto 8);
					out_val2(31 downto 8) <= X"000000";
				elsif(in_addr2(1 downto 0) = "10") then
					out_val2(7 downto 0) <= RAM(conv_integer(addr7b2))(23 downto 16);
					out_val2(31 downto 8) <= X"000000";
				else
					out_val2(7 downto 0) <= RAM(conv_integer(addr7b2))(31 downto 24);
					out_val2(31 downto 8) <= X"000000";
				end if;

				-- LHU
			else
				if (in_addr2(1) = '1') then
					out_val2(15 downto 0) <= RAM(conv_integer(addr7b2))(31 downto 16);
					out_val2(31 downto 16) <= X"0000";
				else
					out_val2(15 downto 0) <= RAM(conv_integer(addr7b2))(15 downto 0);
					out_val2(31 downto 16) <= X"0000";
				end if;

			end if;

		else
			out_val2 <= X"00000000";
		end if;
	end process;
end Behavioral;
