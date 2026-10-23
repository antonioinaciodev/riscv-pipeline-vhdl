library ieee;
use ieee.std_logic_1164.all;

entity pipeline_tb is
end entity pipeline_tb;

architecture test of pipeline_tb is
    -- Componente que vamos testar
    component pipeline_toplevel is
        port (
            clk : in std_logic;
            rst : in std_logic
        );
    end component;

    -- Sinais para conectar no componente
    signal clk_tb : std_logic := '0';
    signal rst_tb : std_logic := '0';
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Instanciar o processador pipeline (DUT - Device Under Test)
    DUT: component pipeline_toplevel port map (clk => clk_tb, rst => rst_tb);

    -- Processo para gerar o clock
    clk_process: process
    begin
        clk_tb <= '0'; wait for CLK_PERIOD / 2;
        clk_tb <= '1'; wait for CLK_PERIOD / 2;
    end process;

    -- Processo para gerar o estimulo de reset
    stimulus_process: process
    begin
        rst_tb <= '1';      -- Ativa o reset
        wait for 10 ns;     -- Segura por 20ns
        rst_tb <= '0';      -- Libera o reset
        wait;               -- Fim do teste
    end process;


end architecture test;
