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
	       -- TODO: uncomment to implement imm. It should be kept
	       -- in mind that there are several imm codifications.
	       -- out_imm : out  std_logic_vector (31 downto 0);
	       out_opcode : out  std_logic_vector (6 downto 0));
end ALU;

architecture RTL of decoder is
begin
	out_opcode <= in_inst(6 downto 0);
	out_rs1 <= in_inst(19 downto 15);
	out_rs2 <= in_inst(24 downto 20);
	out_rd <= in_inst(11 downto 7);
	out_func3 <= in_inst(14 downto 12);
	out_func7 <= in_inst(31 downto 25);
end RTL;
