-- Author: Pablo Orduna Lagarma
-- Artic Risc V


library ieee;
use ieee.std_logic_1164.all;

entity exec_memory is
	Port (
		in_clk : in std_logic;
		in_reset : in std_logic;
		in_load : in std_logic;

		exec_rt_value : in std_logic_vector(31 downto 0);
		exec_rd_id : in std_logic_vector(4 downto 0);
		exec_rst_inuse : in std_logic; -- Use of RD for risk detection
		exec_memwrite : in std_logic;
		exec_memread : in std_logic;
		-- Determines whether to use ALU output or MEM output to write to the RD reg
		exec_memtoreg : in std_logic;

		memory_rt_value : out std_logic_vector(31 downto 0);
		memory_rd_id : out std_logic_vector(4 downto 0);
		memory_rst_inuse : out std_logic;
		memory_memwrite : out std_logic;
		memory_memread : out std_logic;
		memory_memtoreg : out std_logic
	);
end exec_memory;


architecture RTL of exec_memory is
begin
	process(in_clk)
	begin
		if(rising_edge(in_clk)) then
			if (in_reset = '1') then
				memory_rt_value <= "00000000000000000000000000000000";
				memory_rd_id <= "00000";
				memory_rst_inuse <= '0';
				memory_memwrite <= '0';
				memory_memread <= '0';
				memory_memtoreg <= '0';

			else
				if (in_load = '1') then
					memory_rt_value <= exec_rt_value;
					memory_rd_id <= exec_rd_id;
					memory_rst_inuse <= exec_rst_inuse;
					memory_memwrite <= exec_memwrite;
					memory_memread <= exec_memread;
					memory_memtoreg <= exec_memtoreg;
				end if;
			end if;
		end if;
	end process;
end RTL;
