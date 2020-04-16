-- Author: Pablo Orduna Lagarma
-- Artic Risc V


library ieee;
use ieee.std_logic_1164.all;

entity decode_exec is
	Port ( in_clk : in std_logic;
	       in_reset : in std_logic;
	       in_load : in std_logic;

	       decode_rs1_value : in std_logic_vector(31 downto 0);
	       decode_rs2_value : in std_logic_vector(31 downto 0);
	       decode_rs1_id : in std_logic_vector(4 downto 0);
	       decode_rs2_id : in std_logic_vector(4 downto 0);
	       decode_rd_id : in std_logic_vector(4 downto 0);
	       decode_imm : in std_logic_vector(31 downto 0);
	       decode_rst_inuse : in std_logic; -- Use of RD for risk detection
	       decode_fp_add : in std_logic;
	       decode_alu_opctrl : in std_logic_vector(2 downto 0);
	       decode_memwrite : in std_logic;
	       decode_memread : in std_logic;
	       -- Determines whether to use ALU output or MEM output to write to the RD reg
	       decode_memtoreg : in std_logic;
	       -- Determines whether to use inm or RT value 
	       decode_alu_src : in std_logic;
	       decode_opcode : in std_logic_vector(6 downto 0);
	       decode_func7 : in std_logic_vector(6 downto 0);
	       decode_breg_WE : in std_logic;

	       exec_rs1_value : out std_logic_vector(31 downto 0);
	       exec_rs2_value : out std_logic_vector(31 downto 0);
	       exec_rs1_id : out std_logic_vector(4 downto 0);
	       exec_rs2_id : out std_logic_vector(4 downto 0);
	       exec_rd_id : out std_logic_vector(4 downto 0);
	       exec_imm : out std_logic_vector(31 downto 0);
	       exec_rst_inuse : out std_logic;
	       exec_fp_add : out std_logic;
	       exec_alu_opctrl : out std_logic_vector(2 downto 0);
	       exec_memwrite : out std_logic;
	       exec_memread : out std_logic;
	       exec_memtoreg : out std_logic;
	       exec_alu_src : out std_logic;
	       exec_opcode : out std_logic_vector(6 downto 0);
	       exec_func7 : out std_logic_vector(6 downto 0);
	       exec_breg_WE : out std_logic);
end decode_exec;


architecture RTL of decode_exec is
begin
	process(in_clk)
	begin
		if(rising_edge(in_clk)) then
			if (in_reset = '1') then
				exec_rs1_value <= "00000000000000000000000000000000";
				exec_rs2_value <= "00000000000000000000000000000000";
				exec_rs1_id <= "00000";
				exec_rs2_id <= "00000";
				exec_rd_id <= "00000";
				exec_imm <= "00000000000000000000000000000000";
				exec_rst_inuse <= '0';
				exec_fp_add <= '0';
				exec_alu_opctrl <= "000";
				exec_memwrite <= '0';
				exec_memread <= '0';
				exec_memtoreg <= '0';
				exec_alu_src <= '0';
				exec_opcode <= "0000000";
				exec_func7 <= "0000000";
				exec_breg_WE <= '0';

			else
				if (in_load = '1') then
					exec_rs1_value <= decode_rs1_value;
					exec_rs2_value <= decode_rs2_value;
					exec_rs1_id <= decode_rs1_id;
					exec_rs2_id <= decode_rs2_id;
					exec_rd_id <= decode_rd_id;
					exec_imm <= decode_imm;
					exec_rst_inuse <= decode_rst_inuse;
					exec_fp_add <= decode_fp_add;
					exec_alu_opctrl <= decode_alu_opctrl;
					exec_memwrite <= decode_memwrite;
					exec_memread <= decode_memread;
					exec_memtoreg <= decode_memtoreg;
					exec_alu_src <= decode_alu_src;
					exec_opcode <= decode_opcode;
					exec_func7 <= decode_func7;
					exec_breg_WE <= decode_breg_WE;
				end if;
			end if;
		end if;
	end process;
end RTL;
