-- Author: Pablo Orduna Lagarma
-- Risc V

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


-- Operations available
-- 	00: ADD
-- 	01: SUB
-- 	10: AND
-- 	11: OR

entity ALU is
    Port ( in_clk : in std_logic;
	   in_A : in  std_logic_vector (31 downto 0);
           in_B : in  std_logic_vector (31 downto 0);
           op_ctrl : in  std_logic_vector (1 downto 0);
	   out_value : out  std_logic_vector (31 downto 0));
end ALU;

architecture Behavioral of ALU is
	signal out_value_internal : std_logic_vector (31 downto 0);
begin
	out_value_internal <= 	in_A + in_B when (op_ctrl="000") 
			else in_A - in_B when (op_ctrl="001") 
			else in_A AND in_B when (op_ctrl="010")
			else in_A OR in_B when (op_ctrl="011")
			else X"00000000";
	out_value <= out_value_internal;
end Behavioral;
