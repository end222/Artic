-- Author: Pablo Orduna Lagarma
-- Artic Risc V


library ieee;
use ieee.std_logic_1164.all;

entity exec_memory is
	Port ( in_clk : in std_logic;
	       in_reset : in std_logic;
	       in_load : in std_logic;

	       exec_rs1_value : in std_logic_vector(31 downto 0);
	       exec_rs2_value : in std_logic_vector(31 downto 0);
	       exec_imm : in std_logic_vector(31 downto 0);
	       exec_alu_out_value : in std_logic_vector(31 downto 0);
	       exec_rd_id : in std_logic_vector(4 downto 0);
	       exec_rst_inuse : in std_logic; -- Use of RD for risk detection
	       exec_memwrite : in std_logic;
	       exec_memread : in std_logic;
	       -- Determines whether to use ALU output or MEM output to write to the RD reg
	       exec_memtoreg : in std_logic;
	       exec_breg_WE : in std_logic;
	       exec_next_pc : in std_logic_vector(31 downto 0);
	       exec_opcode : in std_logic_vector(6 downto 0);
	       exec_func3 : in std_logic_vector(2 downto 0);

	       memory_rs1_value : out std_logic_vector(31 downto 0);
	       memory_rs2_value : out std_logic_vector(31 downto 0);
	       memory_alu_out_value : out std_logic_vector(31 downto 0);
	       memory_imm : out std_logic_vector(31 downto 0);
	       memory_rd_id : out std_logic_vector(4 downto 0);
	       memory_rst_inuse : out std_logic;
	       memory_memwrite : out std_logic;
	       memory_memread : out std_logic;
	       memory_memtoreg : out std_logic;
	       memory_next_pc : out std_logic_vector(31 downto 0);
	       memory_opcode : out std_logic_vector(6 downto 0);
	       memory_breg_WE : out std_logic;
	       memory_func3 : out std_logic_vector(2 downto 0));
end exec_memory;


architecture RTL of exec_memory is
begin
	process(in_clk)
	begin
		if(rising_edge(in_clk)) then
			if (in_reset = '1') then
				memory_rs1_value <= "00000000000000000000000000000000";
				memory_rs2_value <= "00000000000000000000000000000000";
				memory_alu_out_value <= "00000000000000000000000000000000";
				memory_rd_id <= "00000";
				memory_rst_inuse <= '0';
				memory_memwrite <= '0';
				memory_memread <= '0';
				memory_memtoreg <= '0';
				memory_breg_WE <= '0';
				memory_next_pc <= X"00000000";
				memory_imm <= X"00000000";
				memory_opcode <= "0000000";
				memory_func3 <= "000";
			else
				if (in_load = '1') then
					memory_rs1_value <= exec_rs1_value;
					memory_rs2_value <= exec_rs2_value;
					memory_alu_out_value <= exec_alu_out_value;
					memory_rd_id <= exec_rd_id;
					memory_rst_inuse <= exec_rst_inuse;
					memory_memwrite <= exec_memwrite;
					memory_memread <= exec_memread;
					memory_memtoreg <= exec_memtoreg;
					memory_breg_WE <= exec_breg_WE;
					memory_next_pc <= exec_next_pc;
					memory_imm <= exec_imm;
					memory_opcode <= exec_opcode;
					memory_func3 <= exec_func3;
				end if;
			end if;
		end if;
	end process;
end RTL;
