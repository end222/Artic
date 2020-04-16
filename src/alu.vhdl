-- Author: Pablo Orduna Lagarma
-- Risc V

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


-- Operations available
-- ADD: 000
-- SUB: 000
-- SLL: 001
-- SLT: 010
-- SLTU: 011
-- XOR: 100
-- SRL: 101
-- SRA: 101
-- OR: 110
-- AND: 111

entity ALU is
    Port ( in_clk : in std_logic;
	   in_A : in std_logic_vector (31 downto 0);
	   in_B : in std_logic_vector (31 downto 0);
	   in_imm : in std_logic_vector (31 downto 0);
	   in_func7 : in std_logic_vector (6 downto 0);
	   op_code : in std_logic_vector (6 downto 0);
	   op_ctrl : in std_logic_vector (2 downto 0);
	   out_value : out std_logic_vector (31 downto 0));
end ALU;

architecture Behavioral of ALU is
	signal out_value_internal : std_logic_vector (31 downto 0);
begin
	out_value_internal <= in_A + in_B when (op_ctrl="000" and in_func7="0000000" and op_code="0110011") -- ADD
			      else in_A + in_imm when (op_code="000" and in_func7="0000000" and op_code="0010011") -- ADDI
			      else in_A - in_B when (op_ctrl="000" and in_func7="0100000")  -- SUB
			      else X"00000000";
	out_value <= out_value_internal;
end Behavioral;
