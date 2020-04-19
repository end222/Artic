-- Author: Pablo Orduna Lagarma
-- RISC V

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity risk_detection_unit is
	Port ( decode_rs1_id : in std_logic_vector(4 downto 0);
	       decode_rs2_id : in std_logic_vector(4 downto 0);
	       exec_rd_id : in std_logic_vector(4 downto 0);
	       exec_memread	: in std_logic;
	       stop_decode : out std_logic;
end risk_detection_unit;

Architecture Behavioral of risk_detection_unit is
begin
	-- Solve risk created by the LOAD instruction
	stop_decode <= '1' when (((exec_rd_id=decode_rs1_id or exec_rd_id=decode_rs2_id) and exec_memread='1') else '0';
end Behavioral;
