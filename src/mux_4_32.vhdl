-- Author: Pablo Orduna Lagarma
-- Artic Risc V

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Mux: 4 inputs, 1 output
entity mux_4_32 is
	Port ( in_0 : in  STD_LOGIC_VECTOR (31 downto 0);
		   in_1 : in  STD_LOGIC_VECTOR (31 downto 0);
		   in_2 : in  STD_LOGIC_VECTOR (31 downto 0);
		   in_3 : in  STD_LOGIC_VECTOR (31 downto 0);
		   in_ctrl : in  std_logic_vector(1 downto 0);
		   out_value : out  STD_LOGIC_VECTOR (31 downto 0));
end mux_4_32;
Architecture Behavioral of mux_4_32 is
begin
	out_value <= in_0 when in_ctrl = "00" else
			in_1 when in_ctrl = "01" else
			in_2 when in_ctrl = "10" else
			in_3;
end Behavioral;
