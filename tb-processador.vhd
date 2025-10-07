tb-processador testbench do gpt mesmo 
-- ARQUIVO: tb_processador.vhd
-- DESCRICAO: Testbench para o processador_toplevel.

library ieee;
use ieee.std_logic_1164.all;

-- A entidade do testbench e sempre vazia.
entity tb_processador is
end entity tb_processador;

architecture test of tb_processador is

    -- 1. Declarar o componente que vamos testar
    component processador_toplevel is
        port (
            clk : in std_logic;
            rst : in std_logic
        );
    end component;

    -- 2. Criar os sinais para conectar nas entradas do componente
    signal clk_tb : std_logic := '0';
    signal rst_tb : std_logic := '0';

    -- Constante para o periodo do clock (10 ns = 100 MHz)
    constant CLK_PERIOD : time := 100 ns;

begin

    -- 3. Instanciar o componente a ser testado (DUT - Device Under Test)
    DUT : component processador_toplevel
        port map (
            clk => clk_tb,
            rst => rst_tb
        );

    -- 4. Gerar o clock
    -- Este processo faz o sinal de clock ficar alternando entre 0 e 1
    clk_process : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process clk_process;

    -- 5. Gerar os estimulos (reset)
    -- Este processo controla os sinais de entrada para o teste
    stimulus_process : process
    begin
        -- Aplica um pulso de reset no comeco
        rst_tb <= '1';
        wait for 20 ns; -- Mantem o reset ativo por 20 ns
        rst_tb <= '0';  -- Libera o reset

        -- O 'wait' final faz o processo parar aqui, deixando a simulacao continuar
        wait;
    end process stimulus_process;

end architecture test;