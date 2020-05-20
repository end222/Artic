-- Author: Pablo Orduna Lagarma
-- Risc V

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
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
			      else in_imm when (op_code="0110111") -- LUI
			      else in_A + in_imm when (op_ctrl="000" and op_code="0010011") or (op_code="0000011") or (op_code="0100011") -- ADDI, LD & ST address
			      else in_A - in_B when (op_ctrl="000" and in_func7="0100000" and op_code="0110011")  -- SUB
			      else in_A and in_B when (op_ctrl="111" and op_code="0110011") -- AND
			      else in_A and in_imm when (op_ctrl="111" and op_code="0010011") -- ANDI
			      else in_A or in_B when (op_ctrl="110" and op_code="0110011") -- OR
			      else in_A or in_imm when (op_ctrl="110" and op_code="0010011") -- ORI
			      else in_A xor in_B when (op_ctrl="100" and op_code="0110011") --XOR
			      else in_A xor in_imm when (op_ctrl="100" and op_code="0010011") -- XORI
			      else X"00000001" when (op_ctrl="010"and op_code="0010011" and (to_integer(signed(in_A))<to_integer(signed(in_imm)))) -- SLTI
			      else X"00000001" when (op_ctrl="011"and op_code="0010011" and (unsigned(in_A) < unsigned(in_imm))) -- SLTIU
			      else X"00000001" when (op_ctrl="010"and op_code="0010011" and (to_integer(signed(in_A)) < to_integer(signed(in_B)))) -- SLT
			      else X"00000001" when (op_ctrl="011"and op_code="0010011" and (unsigned(in_A) < unsigned(in_B))) -- SLTU
			      else X"00000000";
	out_value <= out_value_internal;
end Behavioral;
