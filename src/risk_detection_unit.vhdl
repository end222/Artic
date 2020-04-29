-- Author: Pablo Orduna Lagarma
-- RISC V

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity risk_detection_unit is
	Port ( decode_rs1_id : in std_logic_vector(4 downto 0);
	       decode_rs2_id : in std_logic_vector(4 downto 0);
	       exec_rd_id : in std_logic_vector(4 downto 0);
	       exec_memread	: in std_logic;
	       exec_breg_WE : in std_logic;
	       memory_rd_id : in std_logic_vector(4 downto 0);
	       memory_breg_WE : in std_logic;
	       decode_opcode : in std_logic_vector(6 downto 0);
	       stop_decode : out std_logic);
end risk_detection_unit;

Architecture Behavioral of risk_detection_unit is
begin
	-- Solve risk created by the LOAD instruction
	stop_decode <= '1' when ((exec_rd_id=decode_rs1_id or exec_rd_id=decode_rs2_id) and exec_memread='1')
		       or ( decode_opcode = "1100011" and ((exec_rd_id = decode_rs1_id and exec_breg_WE='1') or (exec_rd_id = decode_rs2_id and exec_breg_WE='1') or (memory_rd_id = decode_rs1_id and memory_breg_WE='1') or (memory_rd_id = decode_rs2_id and memory_breg_WE='1')))
		       else '0';
end Behavioral;
