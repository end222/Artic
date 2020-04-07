-- Author: Pablo Orduna Lagarma
-- Risc V

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity r32b is
	Port ( in_clk : in std_logic;
	       in_reset : in std_logic;
	       in_rs1_addr : in std_logic_vector (4 downto 0);
	       in_rs2_addr : in std_logic_vector (4 downto 0);
	       in_write_addr : in std_logic_vector (4 downto 0);
	       in_write_value : in std_logic_vector (31 downto 0);
	       in_WE : in std_logic;						
	       out_rs1 : out std_logic_vector (31 downto 0);
	       out_rs2 : out std_logic_vector (31 downto 0));
end r32b;

architecture Behavioral of r32b is
	type reg_array is array (0 to 31) of std_logic_vector(31 downto 0);
	signal reg_file : reg_array;
begin 
	process(in_clk)
	begin 
		if (in_clk'event and in_clk='0') then
			if in_reset='1' then 	
				for i in 0 to 31 loop
					reg_file(i) <= "00000000000000000000000000000000";
				end loop;
			else
				if in_WE = '1' then
					reg_file(conv_integer(in_write_addr)) <= in_write_value;
				end if;
			end if;
		end if;
	end process;

	-- R0 is always 0 in RISCV
	if out_rs1 != 0 then
		out_rs1 <= reg_file(conv_integer(in_rs1_addr));
	else
		out_rs1 <= X"00000000";
	end if;
	if out_rs2 != 0 then
		out_rs2 <= reg_file(conv_integer(in_rs2_addr));
	else
		out_rs2 <= X"00000000";
	end if;
end Behavioral;
