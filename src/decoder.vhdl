-- Author: Pablo Orduna Lagarma
-- Risc V

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Other variables will be needed whenever FENCE is implemented
entity decoder is
	Port ( in_inst : in  std_logic_vector (31 downto 0);
	       out_rs1 : out  std_logic_vector (4 downto 0);
	       out_rs2 : out  std_logic_vector (4 downto 0);
	       out_rd : out  std_logic_vector (4 downto 0);
	       out_func3 : out  std_logic_vector (2 downto 0);
	       out_func7 : out  std_logic_vector (6 downto 0);
	       out_imm : out std_logic_vector(31 downto 0);
	       out_opcode : out  std_logic_vector (6 downto 0);
	       out_breg_WE : out std_logic);
end decoder;

architecture RTL of decoder is
	signal expanded_imm_internal : std_logic_vector (31 downto 0);
begin
	out_opcode <= in_inst(6 downto 0);
	out_rs1 <= in_inst(19 downto 15);
	out_rs2 <= in_inst(24 downto 20);
	out_rd <= in_inst(11 downto 7);
	out_func3 <= in_inst(14 downto 12);
	out_func7 <= in_inst(31 downto 25);

	-- TODO: Take into account more cases
	expanded_imm_internal(11 downto 0) <= in_inst(31 downto 20);
	expanded_imm_internal(31 downto 12) <= "00000000000000000000" when in_inst(31)='0' else "11111111111111111111";
	out_imm <= expanded_imm_internal;

	out_breg_WE <= '1' when in_inst(6 downto 0)="0010011" or in_inst(6 downto 0)="0110011" -- ALU operations (0110011) and ALU with imm (0010011)
		       else '0';
end RTL;
