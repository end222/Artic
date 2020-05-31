-- Author: Pablo Orduna Lagarma
-- Risc V

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity RV32I is
	Port ( clk : in std_logic;
	       in_reset : in std_logic);
end RV32I;

architecture Behavioral of RV32I is
	-- 32 bit adder used to increase PC by 4
	signal adder4_out : std_logic_vector(31 downto 0);
	component adder32 is
		Port ( in_0 : in std_logic_vector(31 downto 0);
		       in_1 : in std_logic_vector(31 downto 0);
		       out_val : out std_logic_vector(31 downto 0));
	end component;

	signal PC_in, PC_out : std_logic_vector(31 downto 0);
	component reg32 is
		port( in_clk : in std_logic;
		      in_D : in std_logic_vector(31 downto 0);
		      in_W : in std_logic;
		      in_reset : in std_logic;
		      out_val : out std_logic_vector(31 downto 0)
	      );
	end component;

	signal inst_out, system_trap_value : std_logic_vector(31 downto 0);
	signal system_trap_WE : std_logic;
	component memory is
		Port ( in_clk : in std_logic;
		       in_addr : in std_logic_vector(31 downto 0);
		       in_addr2 : in std_logic_vector(31 downto 0);
		       in_D : in std_logic_vector(31 downto 0);
		       in_WE : in std_logic;
		       in_RE : in std_logic;
		       in_RE2 : in std_logic;
		       in_func3 : in std_logic_vector(2 downto 0);
		       out_system_trap_WE : out std_logic;
		       out_system_trap_value : out std_logic_vector(31 downto 0);
		       out_val : out std_logic_vector(31 downto 0);
		       out_val2 : out std_logic_vector(31 downto 0));
	end component;

	signal system_trap_out : std_logic_vector(31 downto 0);
	component system_trap_handler is
		Port ( in_clk : in std_logic;
		       in_WE : in std_logic;
		       in_D : in std_logic_vector(31 downto 0);
		       out_val : out std_logic_vector(31 downto 0));
	end component;

	signal decode_inst_fd, decode_next_pc, decode_pc : std_logic_vector(31 downto 0);
	component fetch_decode is
		Port ( in_clk : in std_logic;
		       in_reset : in std_logic;
		       in_load : in std_logic;
		       fetch_inst : in std_logic_vector (31 downto 0);
		       fetch_pc : in std_logic_vector (31 downto 0);
		       fetch_next_pc : in std_logic_vector (31 downto 0);
		       decode_inst : out std_logic_vector (31 downto 0);
		       decode_pc : out std_logic_vector (31 downto 0);
		       decode_next_pc : out std_logic_vector (31 downto 0));
	end component;

	signal decode_rs1_id, decode_rs2_id, decode_rd_id : std_logic_vector(4 downto 0);
	signal func3 : std_logic_vector(2 downto 0);
	signal func7, opcode : std_logic_vector(6 downto 0);
	signal imm, jmp_address, jalr_address : std_logic_vector(31 downto 0);
	signal breg_WE, memread, memwrite, memtoreg : std_logic; -- Write enable for bank register

	-- Splits the instruction and tells which components will need to be activated
	component decoder is
		Port ( in_inst : in  std_logic_vector (31 downto 0);
		       out_rs1 : out  std_logic_vector (4 downto 0);
		       out_rs2 : out  std_logic_vector (4 downto 0);
		       out_rd : out  std_logic_vector (4 downto 0);
		       out_func3 : out  std_logic_vector (2 downto 0);
		       out_func7 : out  std_logic_vector (6 downto 0);
		       out_imm : out std_logic_vector(31 downto 0);
		       out_opcode : out  std_logic_vector (6 downto 0);
		       out_memread : out std_logic;
		       out_memtoreg : out std_logic;
		       out_memwrite : out std_logic;
		       out_breg_WE : out std_logic);
	end component;

	signal decode_rs1_value, decode_rs2_value : std_logic_vector(31 downto 0);
	component r32b is
		Port ( in_clk : in std_logic;
		       in_reset : in std_logic;
		       in_rs1_addr : in std_logic_vector (4 downto 0);
		       in_rs2_addr : in std_logic_vector (4 downto 0);
		       in_write_addr : in std_logic_vector (4 downto 0);
		       in_write_value : in std_logic_vector (31 downto 0);
		       in_WE : in std_logic;						
		       out_rs1 : out std_logic_vector (31 downto 0);
		       out_rs2 : out std_logic_vector (31 downto 0));
	end component;

	signal exec_rs1_value, exec_rs2_value, exec_rd_value, exec_inm : std_logic_vector(31 downto 0);
	signal exec_rs1_id, exec_rs2_id, exec_rd_id : std_logic_vector(4 downto 0);
	signal exec_rst_inuse, exec_fp_add, exec_memwrite, exec_memread, exec_memtoreg, exec_alu_src, exec_breg_WE : std_logic;
	signal exec_alu_opctrl : std_logic_vector(2 downto 0);
	signal exec_opcode, exec_func7 : std_logic_vector(6 downto 0);
	signal exec_imm, exec_next_pc, exec_pc : std_logic_vector(31 downto 0);
	
	component decode_exec is
		Port ( in_clk : in std_logic;
		       in_reset : in std_logic;
		       in_load : in std_logic;

		       decode_rs1_value : in std_logic_vector(31 downto 0);
		       decode_rs2_value : in std_logic_vector(31 downto 0);
		       decode_rs1_id : in std_logic_vector(4 downto 0);
		       decode_rs2_id : in std_logic_vector(4 downto 0);
		       decode_rd_id : in std_logic_vector(4 downto 0);
		       decode_imm : in std_logic_vector(31 downto 0);
		       decode_rst_inuse : in std_logic;
		       decode_fp_add : in std_logic;
		       decode_alu_opctrl : in std_logic_vector(2 downto 0);
		       decode_memwrite : in std_logic;
		       decode_memread : in std_logic;
		       decode_memtoreg : in std_logic;
		       decode_alu_src : in std_logic;
		       decode_opcode : in std_logic_vector(6 downto 0);
		       decode_func7 : in std_logic_vector(6 downto 0);
		       decode_breg_WE : in std_logic;
		       decode_next_pc : in std_logic_vector(31 downto 0);
		       decode_pc : in std_logic_vector(31 downto 0);

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
		       exec_breg_WE : out std_logic;
		       exec_next_pc : out std_logic_vector(31 downto 0);
		       exec_pc : out std_logic_vector(31 downto 0));
	end component;

	signal exec_alu_out_value : std_logic_vector(31 downto 0);
	component ALU is 
		Port ( in_clk : in std_logic;
		       in_A : in std_logic_vector(31 downto 0);
		       in_B : in std_logic_vector(31 downto 0);
		       in_imm : in std_logic_vector (31 downto 0);
		       in_func7 : in std_logic_vector (6 downto 0);
		       in_pc : in std_logic_vector(31 downto 0);
		       op_code : in std_logic_vector (6 downto 0);
		       op_ctrl : in std_logic_vector (2 downto 0);
		       out_value : out std_logic_vector(31 downto 0));
	end component;

	signal memory_rs1_value, memory_rs2_value, memory_alu_out_value, memory_next_pc, memory_imm : std_logic_vector(31 downto 0);
	signal memory_rd_id : std_logic_vector(4 downto 0);
	signal memory_rst_inuse, memory_memwrite, memory_memread, memory_memtoreg, memory_breg_WE : std_logic;
	signal memory_opcode : std_logic_vector(6 downto 0);
	signal memory_func3 : std_logic_vector(2 downto 0);
	component exec_memory is
		Port ( in_clk : in std_logic;
		       in_reset : in std_logic;
		       in_load : in std_logic;
		       exec_rs1_value : in std_logic_vector(31 downto 0);
		       exec_rs2_value : in std_logic_vector(31 downto 0);
		       exec_alu_out_value : in std_logic_vector(31 downto 0);
		       exec_imm : in std_logic_vector(31 downto 0);
		       exec_rd_id : in std_logic_vector(4 downto 0);
		       exec_rst_inuse : in std_logic;
		       exec_memwrite : in std_logic;
		       exec_memread : in std_logic;
		       exec_memtoreg : in std_logic;
		       exec_breg_WE : in std_logic;
		       exec_next_pc : in std_logic_vector(31 downto 0);
		       exec_opcode : in std_logic_vector(6 downto 0);
		       exec_func3 : in std_logic_vector(2 downto 0);

		       memory_rs1_value : out std_logic_vector(31 downto 0);
		       memory_rs2_value : out std_logic_vector(31 downto 0);
		       memory_alu_out_value : out std_logic_vector(31 downto 0);
		       memory_rd_id : out std_logic_vector(4 downto 0);
		       memory_imm : out std_logic_vector(31 downto 0);
		       memory_rst_inuse : out std_logic;
		       memory_memwrite : out std_logic;
		       memory_memread : out std_logic;
		       memory_memtoreg : out std_logic;
		       memory_next_pc : out std_logic_vector(31 downto 0);
		       memory_opcode : out std_logic_vector(6 downto 0);
		       memory_breg_WE : out std_logic;
		       memory_func3 : out std_logic_vector(2 downto 0));
	end component;

	signal memory_mem_out_value : std_logic_vector(31 downto 0);

	signal writeback_out_value : std_logic_vector(31 downto 0);
	signal writeback_rd_id : std_logic_vector(4 downto 0);
	signal writeback_rst_inuse, writeback_memtoreg, writeback_breg_WE : std_logic;
	component memory_writeback is
		Port ( in_clk : in std_logic;
		       in_reset : in std_logic;
		       in_load : in std_logic;
		       memory_alu_out_value : in std_logic_vector(31 downto 0);
		       memory_mem_out_value : in std_logic_vector(31 downto 0);
		       memory_rd_id : in std_logic_vector(4 downto 0);
		       memory_imm : in std_logic_vector(31 downto 0);
		       memory_rst_inuse : in std_logic; 
		       memory_memtoreg : in std_logic;
		       memory_breg_WE : in std_logic;
		       memory_next_pc : in std_logic_vector(31 downto 0);
		       memory_opcode : in std_logic_vector(6 downto 0);

		       writeback_out_value : out std_logic_vector(31 downto 0);
		       writeback_rd_id : out std_logic_vector(4 downto 0);
		       writeback_rst_inuse : out std_logic;
		       writeback_memtoreg : out std_logic;
		       writeback_breg_WE : out std_logic);
	end component;

	signal mux4_out_1, mux4_out_2 : std_logic_vector(31 downto 0);
	signal mux_ctrl_1, mux_ctrl_2 : std_logic_vector(1 downto 0);
	component mux_4_32 is
		Port ( in_0 : in  STD_LOGIC_VECTOR (31 downto 0);
		       in_1 : in  STD_LOGIC_VECTOR (31 downto 0);
		       in_2 : in  STD_LOGIC_VECTOR (31 downto 0);
		       in_3 : in  STD_LOGIC_VECTOR (31 downto 0);
		       in_ctrl : in  std_logic_vector(1 downto 0);
		       out_value : out  STD_LOGIC_VECTOR (31 downto 0));
	end component;

	component anticipation_unit is
		Port( exec_rs1_id : in  std_logic_vector(4 downto 0);
		      exec_rs2_id : in  std_logic_vector(4 downto 0);
		      memory_breg_WE : in std_logic;
		      memory_rd_id : in  std_logic_vector(4 downto 0);
		      writeback_breg_WE : in std_logic;
		      writeback_rd_id : in  std_logic_vector(4 downto 0);
		      mux_ctrl_1: out std_logic_vector(1 downto 0);
		      mux_ctrl_2: out std_logic_vector(1 downto 0));
	end component;

	signal stop_decode : std_logic;
	component risk_detection_unit is
		Port ( decode_rs1_id : in std_logic_vector(4 downto 0);
		       decode_rs2_id : in std_logic_vector(4 downto 0);
		       exec_rd_id : in std_logic_vector(4 downto 0);
		       exec_memread : in std_logic;
		       exec_breg_WE : in std_logic;
		       memory_rd_id : in std_logic_vector(4 downto 0);
		       memory_breg_WE : in std_logic;
		       decode_opcode : in std_logic_vector(6 downto 0);
		       stop_decode : out std_logic);
	end component;

	signal load_PC, load_fd, load_de, reset_de : std_logic;

	signal jmp_mux_ctrl : std_logic_vector(1 downto 0);
	component jmp_control is
		Port ( in_opcode : in std_logic_vector (6 downto 0);
		       in_func3 : in std_logic_vector(2 downto 0);
		       eq : in std_logic;
		       lt : in std_logic;
		       ltu : in std_logic;
		       out_jmp_mux_ctrl : out std_logic_vector(1 downto 0));
	end component;

	signal eq, lt, ltu : std_logic;
	component jmp_compare is
		Port ( in_A : in std_logic_vector(31 downto 0);
		       in_B : in std_logic_vector(31 downto 0);
		       eq : out std_logic;
		       lt : out std_logic;
		       ltu : out std_logic);
	end component;


begin
	-- Load when there is no risk detected
	load_PC <= not stop_decode;
	load_fd <= not stop_decode;
	load_de <= not stop_decode;
	reset_de <= in_reset or stop_decode;

	-- 32b register that contains the PC
	pc : reg32 port map ( in_D => PC_in,
			      in_clk => clk,
			      in_reset => in_reset,
			      in_W => load_PC,
			      out_val => PC_out);

	pc_mux : mux_4_32 port map ( in_0 => adder4_out,
				     in_1 => jmp_address,
				     in_2 => jalr_address,
				     in_3 => system_trap_out,
				     in_ctrl => jmp_mux_ctrl,
				     out_value => PC_in);

	adder4 : adder32 port map ( in_0 => PC_out,
				    in_1 => "00000000000000000000000000000100",
				    out_val => adder4_out);

	adder_pc : adder32 port map ( in_0 => decode_next_pc,
				      in_1 => imm,
				      out_val => jmp_address);

	adder_jalr : adder32 port map ( in_0 => decode_rs1_value,
				      in_1 => imm,
				      out_val => jalr_address);

	mem : memory port map ( in_clk => clk,
					  in_addr => PC_out,
					  in_addr2 => memory_alu_out_value,
					  in_D => memory_rs2_value,
					  in_WE => memory_memwrite,
					  in_RE => '1',
					  in_RE2 => memory_memread,
					  in_func3 => memory_func3,
					  out_system_trap_WE => system_trap_WE,
					  out_system_trap_value => system_trap_value,
					  out_val => inst_out,
					  out_val2 => memory_mem_out_value);

	fd_reg : fetch_decode port map ( in_clk => clk,
					 -- Reset when a jump occurs so as to avoid executing PC+4
					 in_reset => (jmp_mux_ctrl(1) or jmp_mux_ctrl(0)) and load_fd,
					 in_load => load_fd and not jmp_mux_ctrl(1) and not jmp_mux_ctrl(0),
					 fetch_inst => inst_out,
					 fetch_pc => PC_out,
					 fetch_next_pc => adder4_out,
					 decode_inst => decode_inst_fd,
					 decode_pc => decode_pc,
					 decode_next_pc => decode_next_pc);

	deco : decoder port map ( in_inst => decode_inst_fd,
				  out_rs1 => decode_rs1_id,
				  out_rs2 => decode_rs2_id,
				  out_rd => decode_rd_id,
				  out_func3 => func3,
				  out_func7 => func7,
				  out_imm => imm,
				  out_breg_WE => breg_WE,
				  out_memread => memread,
				  out_memwrite => memwrite,
				  out_memtoreg => memtoreg,
				  out_opcode => opcode);

	registerb : r32b port map ( in_clk => clk,
				in_reset => in_reset,
				in_rs1_addr => decode_rs1_id,
				in_rs2_addr => decode_rs2_id,
				in_write_addr => writeback_rd_id,
				in_write_value => writeback_out_value,
				in_WE => writeback_breg_WE,
				out_rs1 => decode_rs1_value,
				out_rs2 => decode_rs2_value);

	de_reg : decode_exec port map ( in_clk => clk,
		       in_reset => reset_de,
		       in_load => load_de,

		       decode_rs1_value => decode_rs1_value,
		       decode_rs2_value => decode_rs2_value,
		       decode_rs1_id => decode_rs1_id,
		       decode_rs2_id => decode_rs2_id,
		       decode_rd_id => decode_rd_id,
		       decode_imm => imm,
		       decode_rst_inuse => '0',
		       decode_fp_add => '0',
		       decode_alu_opctrl => func3,
		       decode_memwrite => memwrite,
		       decode_memread => memread,
		       decode_memtoreg => memtoreg,
		       decode_alu_src => '0',
		       decode_opcode => opcode,
		       decode_func7 => func7,
		       -- Take into account that when a branch is taken
		       -- PC+4 has to be stored in rd.
		       decode_breg_WE => breg_WE,
		       decode_next_pc => decode_next_pc,
		       decode_pc => decode_pc,

		       exec_rs1_value => exec_rs1_value,
		       exec_rs2_value => exec_rs2_value,
		       exec_rs1_id => exec_rs1_id,
		       exec_rs2_id => exec_rs2_id,
		       exec_rd_id => exec_rd_id,
		       exec_imm => exec_imm,
		       exec_rst_inuse => exec_rst_inuse,
		       exec_fp_add => exec_fp_add,
		       exec_alu_opctrl => exec_alu_opctrl,
		       exec_memwrite => exec_memwrite,
		       exec_memread => exec_memread,
		       exec_memtoreg => exec_memtoreg,
		       exec_alu_src => exec_alu_src,
		       exec_opcode => exec_opcode,
		       exec_func7 => exec_func7,
		       exec_breg_WE => exec_breg_WE,
		       exec_pc => exec_pc,
		       exec_next_pc => exec_next_pc);

	alu_int : ALU port map ( in_clk => clk,
				 in_A => mux4_out_1,
				 in_B => mux4_out_2,
				 in_imm => exec_imm,
				 in_func7 => exec_func7,
				 in_pc => exec_pc,
				 op_ctrl => exec_alu_opctrl,
				 op_code => exec_opcode,
				 out_value => exec_alu_out_value);

	em_reg : exec_memory port map (in_clk => clk,
				       in_reset => in_reset,
				       in_load => '1',
				       exec_rs1_value => mux4_out_1,
				       exec_rs2_value => mux4_out_2,
				       exec_alu_out_value => exec_alu_out_value,
				       exec_rd_id => exec_rd_id,
				       exec_rst_inuse => exec_rst_inuse,
				       exec_memwrite => exec_memwrite,
				       exec_memread => exec_memread,
				       exec_memtoreg => exec_memtoreg,
				       exec_breg_WE => exec_breg_WE,
				       exec_next_pc => exec_next_pc,
				       exec_opcode => exec_opcode,
				       exec_imm => exec_imm,
				       exec_func3 => exec_alu_opctrl,
				       memory_rs1_value => memory_rs1_value,
				       memory_rs2_value => memory_rs2_value,
				       memory_alu_out_value => memory_alu_out_value,
				       memory_rd_id => memory_rd_id,
				       memory_rst_inuse => memory_rst_inuse,
				       memory_memwrite => memory_memwrite,
				       memory_memread => memory_memread,
				       memory_memtoreg => memory_memtoreg,
				       memory_next_pc => memory_next_pc,
				       memory_opcode => memory_opcode,
				       memory_imm => memory_imm,
				       memory_breg_WE => memory_breg_WE,
				       memory_func3 => memory_func3);

	mw_reg : memory_writeback port map ( in_clk => clk,
		       in_reset => in_reset,
		       in_load => '1',
		       memory_alu_out_value => memory_alu_out_value,
		       memory_mem_out_value => memory_mem_out_value,
		       memory_rd_id => memory_rd_id,
		       memory_rst_inuse => memory_rst_inuse,
		       memory_memtoreg => memory_memtoreg,
		       memory_breg_WE => memory_breg_WE,
		       memory_next_pc => memory_next_pc,
		       memory_opcode => memory_opcode,
		       memory_imm => memory_imm,
		       writeback_out_value => writeback_out_value,
		       writeback_rd_id => writeback_rd_id,
		       writeback_rst_inuse => writeback_rst_inuse,
		       writeback_memtoreg => writeback_memtoreg,
		       writeback_breg_WE => writeback_breg_WE);

	mux4_1 : mux_4_32 port map ( in_0 => exec_rs1_value,
		       in_1 => memory_alu_out_value,
		       in_2 => writeback_out_value,
		       in_3 => X"00000000",
		       in_ctrl => mux_ctrl_1,
		       out_value => mux4_out_1);

	mux4_2 : mux_4_32 port map ( in_0 => exec_rs2_value,
		       in_1 => memory_alu_out_value,
		       in_2 => writeback_out_value,
		       in_3 => X"00000000",
		       in_ctrl => mux_ctrl_2,
		       out_value => mux4_out_2);

	ant_unit : anticipation_unit port map ( exec_rs1_id => exec_rs1_id,
		      exec_rs2_id => exec_rs2_id,
		      memory_breg_WE => memory_breg_WE,
		      memory_rd_id => memory_rd_id,
		      writeback_breg_WE => writeback_breg_WE,
		      writeback_rd_id => writeback_rd_id,
		      mux_ctrl_1 => mux_ctrl_1,
		      mux_ctrl_2 => mux_ctrl_2);

	rd_unit : risk_detection_unit port map ( decode_rs1_id => decode_rs1_id,
		       decode_rs2_id => decode_rs2_id,
		       exec_memread => exec_memread,
		       exec_rd_id => exec_rd_id,
		       exec_breg_WE => exec_breg_WE,
		       memory_rd_id => memory_rd_id,
		       memory_breg_WE => memory_breg_WE,
	       	       decode_opcode => opcode,
		       stop_decode => stop_decode);

	jmp_con : jmp_control port map ( in_opcode => opcode,
					 in_func3 => func3,
					 eq => eq,
					 lt => lt,
					 ltu => ltu,
					 out_jmp_mux_ctrl => jmp_mux_ctrl);

	jmp_comp : jmp_compare port map ( in_A => decode_rs1_value,
					  in_B => decode_rs2_value,
					  eq => eq,
					  lt => lt,
					  ltu => ltu);
	thandler : system_trap_handler port map ( in_clk => clk,
		       in_WE => system_trap_WE,
		       in_D => system_trap_value,
		       out_val => system_trap_out);
end Behavioral;
