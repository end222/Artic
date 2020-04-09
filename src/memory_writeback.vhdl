-- Author: Pablo Orduna Lagarma
-- Artic Risc V


library ieee;
use ieee.std_logic_1164.all;

entity memory_writeback is
	Port ( in_clk : in std_logic;
	       in_reset : in std_logic;
	       in_load : in std_logic;

	       memory_alu_out_value : in std_logic_vector(31 downto 0);
	       memory_mem_out_value : in std_logic_vector(31 downto 0);
	       memory_rd_id : in std_logic_vector(4 downto 0);
	       memory_rst_inuse : in std_logic; -- Use of RD for risk detection
	       memory_memwrite : in std_logic;
	       memory_memread : in std_logic;
		-- Determines whether to use ALU output or MEM output to write to the RD reg
	       memory_memtoreg : in std_logic;

	       writeback_alu_out_value : out std_logic_vector(31 downto 0);
	       writeback_mem_out_value : out std_logic_vector(31 downto 0);
	       writeback_rd_id : out std_logic_vector(4 downto 0);
	       writeback_rst_inuse : out std_logic;
	       writeback_memwrite : out std_logic;
	       writeback_memread : out std_logic;
	       writeback_memtoreg : out std_logic);
end memory_writeback;


architecture RTL of memory_writeback is
begin
	process(in_clk)
	begin
		if(rising_edge(in_clk)) then
			if (in_reset = '1') then
				writeback_alu_out_value <= "00000000000000000000000000000000";
				writeback_rd_id <= "00000";
				writeback_rst_inuse <= '0';
				writeback_memwrite <= '0';
				writeback_memread <= '0';
				writeback_memtoreg <= '0';

			else
				if (in_load = '1') then
					writeback_alu_out_value <= memory_alu_out_value;
					writeback_mem_out_value <= memory_mem_out_value;
					writeback_rd_id <= memory_rd_id;
					writeback_rst_inuse <= memory_rst_inuse;
					writeback_memwrite <= memory_memwrite;
					writeback_memread <= memory_memread;
					writeback_memtoreg <= memory_memtoreg;
				end if;
			end if;
		end if;
	end process;
end RTL;
