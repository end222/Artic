-- Author: Pablo Orduna Lagarma
-- Risc V

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Other variables will be needed whenever FENCE is implemented
entity exception_detect is
	Port ( in_opcode : in std_logic_vector (6 downto 0);
	       in_rs1_value : in std_logic_vector(31 downto 0);
	       func3 : in std_logic_vector(2 downto 0);
	       imm : in std_logic_vector(31 downto 0);
	       exception : out  std_logic_vector (1 downto 0));
end exception_detect;

architecture Behavioral of exception_detect is
	signal address : std_logic_vector (31 downto 0);
begin
    address <= in_rs1_value + imm;
	exception <= "10" when in_opcode = "1110011" -- System trap
		     else "01" when (in_opcode = "1101111" or in_opcode = "1100011") and not (imm(1 downto 0) = "00") -- Misaligned address in JAL and Branches
		     else "01" when in_opcode = "1100111" and not (address(1 downto 0) = "00") -- Misaligned address in JALR
		     else "01" when (in_opcode = "0100011" or in_opcode = "0000011") and func3 = "010" and not (address(1 downto 0) = "00") -- Misaligned address in LW/SW
		     else "01" when (in_opcode = "0100011" or in_opcode = "0000011") and (func3 = "001" or func3 = "101") and not (address(0) = '0') -- Misaligned address in LH/LHU/SH
		     else "00";
end Behavioral;
