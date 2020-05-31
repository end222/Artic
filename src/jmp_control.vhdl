-- Author: Pablo Orduna Lagarma
-- Risc V

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity jmp_control is
	Port ( in_opcode : in std_logic_vector (6 downto 0);
	       in_func3 : in std_logic_vector(2 downto 0);
	       eq : in std_logic;
	       lt : in std_logic;
	       ltu : in std_logic;
	       out_jmp_mux_ctrl : out std_logic_vector(1 downto 0));
end jmp_control;

architecture Behavioral of jmp_control is
begin
	out_jmp_mux_ctrl <= "01" when in_opcode="1101111" -- JAL instructions (0100011)
			    else "01" when in_opcode="1100011" and in_func3="000" and eq='1' -- BEQ instruction
			    else "01" when in_opcode="1100011" and in_func3="001" and eq='0' -- BNE instruction
			    else "01" when in_opcode="1100011" and in_func3="100" and lt='1' -- BLT instruction
			    else "01" when in_opcode="1100011" and in_func3="101" and lt='0' -- BGE instruction
			    else "01" when in_opcode="1100011" and in_func3="110" and ltu='1' -- BLTU instruction
			    else "01" when in_opcode="1100011" and in_func3="111" and ltu='0' -- BGEU instruction
			    else "10" when in_opcode="1100111" -- JALR instruction
			    else "11" when in_opcode="1110011" -- SYSTEM instruction
			    else "00";
end Behavioral;
