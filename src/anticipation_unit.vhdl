-- Author: Pablo Orduna Lagarma
-- RISC V

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity anticipation_unit is
	Port( exec_rs1_id : in  std_logic_vector(4 downto 0);
	      exec_rs2_id : in  std_logic_vector(4 downto 0);
	      memory_breg_WE : in std_logic;
	      memory_rd_id : in  std_logic_vector(4 downto 0);
	      writeback_breg_WE : in std_logic;
	      writeback_rd_id : in  std_logic_vector(4 downto 0);
	      mux_ctrl_1 : out std_logic_vector(1 downto 0);
	      mux_ctrl_2 : out std_logic_vector(1 downto 0));
end anticipation_unit;

-- MUX ctrl codes:
-- 00: the desired data can be obtained from the bank register
-- 01: the desired data can be obtained from the memory stage
-- 10: the desired data can be obtained from the writeback stage

Architecture Behavioral of anticipation_unit is
begin

	mux_ctrl_1 <= "01" when ( memory_breg_WE='1' and exec_rs1_id = memory_rd_id ) else
				  "10" when ( writeback_breg_WE='1' and exec_rs1_id = writeback_rd_id) else
				  "00";
	mux_ctrl_2 <= "01" when ( memory_breg_WE='1' and exec_rs2_id = memory_rd_id ) else
				  "10" when ( writeback_breg_WE='1' and exec_rs2_id = writeback_rd_id) else
				  "00";
end Behavioral;
