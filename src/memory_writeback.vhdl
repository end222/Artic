-- Author: Pablo Orduna Lagarma
-- Risc V


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity memory_writeback is
	Port ( in_clk : in std_logic;
	       in_reset : in std_logic;
	       in_load : in std_logic;

	       memory_alu_out_value : in std_logic_vector(31 downto 0);
	       memory_mem_out_value : in std_logic_vector(31 downto 0);
	       memory_rd_id : in std_logic_vector(4 downto 0);
	       memory_rst_inuse : in std_logic; -- Use of RD for risk detection
	       -- Determines whether to use ALU output or MEM output to write to the RD reg
	       memory_memtoreg : in std_logic;
	       memory_breg_WE : in std_logic;
	       memory_next_pc : in std_logic_vector(31 downto 0);
	       memory_opcode : in std_logic_vector(6 downto 0);

	       writeback_out_value : out std_logic_vector(31 downto 0);
	       writeback_rd_id : out std_logic_vector(4 downto 0);
	       writeback_rst_inuse : out std_logic;
	       writeback_memtoreg : out std_logic;
	       writeback_breg_WE : out std_logic);
end memory_writeback;


architecture RTL of memory_writeback is
begin
	process(in_clk)
	begin
		if(rising_edge(in_clk)) then
			if (in_reset = '1') then
				writeback_out_value <= "00000000000000000000000000000000";
				writeback_rd_id <= "00000";
				writeback_rst_inuse <= '0';
				writeback_memtoreg <= '0';
				writeback_breg_WE <= '0';
			else
				if (in_load = '1') then
					if (memory_memtoreg='1') then
						writeback_out_value <= memory_mem_out_value;
					elsif (memory_opcode="1101111") then -- JAL instruction
						writeback_out_value <= memory_next_pc;
					else
						writeback_out_value <= memory_alu_out_value;
					end if;
					writeback_rd_id <= memory_rd_id;
					writeback_rst_inuse <= memory_rst_inuse;
					writeback_memtoreg <= memory_memtoreg;
					writeback_breg_WE <= memory_breg_WE;
				end if;
			end if;
		end if;
	end process;
end RTL;
