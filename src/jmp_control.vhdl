-- Author: Pablo Orduna Lagarma
-- Risc V

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Other variables will be needed whenever FENCE is implemented
entity jmp_control is
	Port ( in_opcode : in std_logic_vector (6 downto 0);
	       out_jmp_mux_ctrl : out std_logic);
end jmp_control;

architecture Behavioral of jmp_control is
begin
    out_jmp_mux_ctrl <= '1' when in_opcode="1101111" -- JAL instructions (0100011)
            else '0';
end Behavioral;
