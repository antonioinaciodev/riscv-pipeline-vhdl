library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.pipeline_types.all;

entity pipeline_tb is
    generic (
        PROGRAM_FILE : string := "../programs/test_rtype.hex"
    );
end entity pipeline_tb;

architecture test of pipeline_tb is

    component pipeline_toplevel is
        port ( clk : in std_logic; rst : in std_logic );
    end component;

    signal clk_tb   : std_logic := '0';
    signal rst_tb   : std_logic := '0';
    signal sim_done : boolean := false;
    constant CLK_PERIOD : time := 10 ns;

begin

    DUT: component pipeline_toplevel port map (clk => clk_tb, rst => rst_tb);

    clk_process: process
    begin
        while not sim_done loop
            clk_tb <= '0'; wait for CLK_PERIOD / 2;
            clk_tb <= '1'; wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    stimulus_process: process
    begin
        report "=== Programa: " & PROGRAM_FILE & " ===" severity note;
        rst_tb <= '1';
        wait for 2 * CLK_PERIOD;
        rst_tb <= '0';
        wait for 30 * CLK_PERIOD;
        sim_done <= true;
        report "=== Simulacao concluida ===" severity note;
        wait;
    end process;

    report_process: process
        variable l : line;
        alias regs is << signal .pipeline_tb.DUT.reg_file_unit.registers : reg_array >>;
        procedure p(idx : integer; v : std_logic_vector(31 downto 0)) is
            variable ll : line;
        begin
            write(ll, string'("  x"));
            write(ll, idx);
            write(ll, string'(" = "));
            write(ll, to_integer(signed(v)));
            write(ll, string'("   (0x"));
            hwrite(ll, v);
            write(ll, string'(")"));
            writeline(output, ll);
        end procedure;
    begin
        wait until sim_done = true;
        wait for 1 ns;
        writeline(output, l);
        write(l, string'("================ RESULTADO FINAL ================"));
        writeline(output, l);
        p(1,  regs(1));
        p(2,  regs(2));
        p(10, regs(10));
        p(11, regs(11));
        p(12, regs(12));
        p(13, regs(13));
        p(14, regs(14));
        write(l, string'("================================================"));
        writeline(output, l);
        wait;
    end process;

end architecture test;

configuration pipeline_tb_cfg of pipeline_tb is
    for test
        for DUT : pipeline_toplevel
            use entity work.pipeline_toplevel(structural);
            for structural
                for instr_mem_unit : instruction_memory
                    use entity work.instruction_memory(behavioral)
                        generic map (PROGRAM_FILE => PROGRAM_FILE);
                end for;
            end for;
        end for;
    end for;
end configuration pipeline_tb_cfg;
