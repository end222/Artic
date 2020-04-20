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
	signal reg_file : reg_array := (X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000");
begin 
	process(in_clk)
	begin 
		if (falling_edge(in_clk)) then
			if in_reset='1' then 	
				for i in 0 to 31 loop
					reg_file(i) <= "00000000000000000000000000000000";
				end loop;
			else
				-- Keeping in mind that R0 is always 0 in RISCV
				if in_WE = '1' and in_write_addr/="00000" then
					reg_file(conv_integer(in_write_addr)) <= in_write_value;
				end if;
			end if;
		end if;
	end process;
	out_rs1 <= reg_file(conv_integer(in_rs1_addr));
	out_rs2 <= reg_file(conv_integer(in_rs2_addr));
end Behavioral;
