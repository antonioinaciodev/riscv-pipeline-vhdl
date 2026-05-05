-- Bibliotecas necessárias
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- Para conversões e aritmética no testbench

-- (Opcional, mas útil para imprimir std_logic_vectors no console)
library STD;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

----------------------------------------------------------------------------------
-- Entidade do Testbench (vazia, como padrão)
----------------------------------------------------------------------------------
entity tb_alu_system is
end entity tb_alu_system;

----------------------------------------------------------------------------------
-- Arquitetura de Teste
----------------------------------------------------------------------------------
architecture test of tb_alu_system is

    -- Constante para a largura dos dados, deve ser a mesma da ALU
    constant C_DATA_WIDTH : integer := 32; 

    -- Constante para o período de "clock" (intervalo entre testes)
    constant C_TEST_STEP : time := 10 ns;

    --------------------------------------------------------------------------
    -- Declaração do Componente 1: alu_control
    --------------------------------------------------------------------------
    component alu_control is
        port (
            ALUOp_in       : in  std_logic_vector(1 downto 0); 
            funct3_in      : in  std_logic_vector(2 downto 0); 
            funct7_in      : in  std_logic_vector(6 downto 0); 
            ALUControl_out : out std_logic_vector(3 downto 0)  
        );
    end component alu_control;

    --------------------------------------------------------------------------
    -- Declaração do Componente 2: alu
    --------------------------------------------------------------------------
    component alu is
        generic (
            DATA_WIDTH : integer := 32 
        );
        port (
            A_in       : in  std_logic_vector(DATA_WIDTH - 1 downto 0); 
            B_in       : in  std_logic_vector(DATA_WIDTH - 1 downto 0); 
            ALU_OP_in  : in  std_logic_vector(3 downto 0); 
            Result_out : out std_logic_vector(DATA_WIDTH - 1 downto 0); 
            Z_out      : out std_logic; 
            N_out      : out std_logic  
        );
    end component alu;

    --------------------------------------------------------------------------
    -- Sinais para conectar os componentes
    --------------------------------------------------------------------------
    -- Entradas para alu_control
    signal s_ALUOp_in  : std_logic_vector(1 downto 0);
    signal s_funct3_in : std_logic_vector(2 downto 0);
    signal s_funct7_in : std_logic_vector(6 downto 0);
    
    -- Entradas para alu
    signal s_A_in : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal s_B_in : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    
    -- Fio de conexão (Saída do Controle -> Entrada da ALU)
    signal s_ALUControl : std_logic_vector(3 downto 0);
    
    -- Saídas da alu
    signal s_Result_out : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal s_Z_out      : std_logic;
    signal s_N_out      : std_logic;

    -- Valores de teste
    constant VAL_A : std_logic_vector(C_DATA_WIDTH - 1 downto 0) := x"0000000A"; -- Valor: 10
    constant VAL_B : std_logic_vector(C_DATA_WIDTH - 1 downto 0) := x"00000005"; -- Valor: 5
    
begin

    --------------------------------------------------------------------------
    -- Instanciação (UUT - Units Under Test)
    --------------------------------------------------------------------------

    -- UUT 1: A unidade de controle
    uut_control : alu_control
        port map (
            ALUOp_in       => s_ALUOp_in,
            funct3_in      => s_funct3_in,
            funct7_in      => s_funct7_in,
            ALUControl_out => s_ALUControl -- Conectado ao sinal
        );

    -- UUT 2: A ALU principal
    uut_alu : alu
        generic map (
            DATA_WIDTH => C_DATA_WIDTH
        )
        port map (
            A_in       => s_A_in,
            B_in       => s_B_in,
            ALU_OP_in  => s_ALUControl, -- Recebe o sinal do controle
            Result_out => s_Result_out,
            Z_out      => s_Z_out,
            N_out      => s_N_out
        );

    --------------------------------------------------------------------------
    -- Processo de Estímulo (Testes)
    --------------------------------------------------------------------------
    stim_proc : process
    begin
        report "Iniciando simulação da ALU...";

        -- Valores padrão
        s_A_in <= VAL_A; -- 10
        s_B_in <= VAL_B; -- 5
        s_ALUOp_in  <= "00";
        s_funct3_in <= "000";
        s_funct7_in <= "0000000";
        
        wait for C_TEST_STEP;

        -- Teste 1: Instrução Load/Store (ADD) 
        -- ALUOp = "00"
        report "Teste 1: Load/Store (ADD). Esperado: 10 + 5 = 15";
        s_ALUOp_in <= "00";
        wait for C_TEST_STEP;
        -- (Esperado s_ALUControl = "0010", s_Result_out = x"0000000F")

        -- Teste 2: Instrução Tipo-B (SUB) 
        -- ALUOp = "01"
        report "Teste 2: Tipo-B (SUB). Esperado: 10 - 5 = 5";
        s_ALUOp_in <= "01";
        wait for C_TEST_STEP;
        -- (Esperado s_ALUControl = "0110", s_Result_out = x"00000005") 

        -- Teste 3: Instrução Tipo-R (ADD) 
        -- ALUOp = "10", funct3 = "000", funct7(5) = '0'
        report "Teste 3: Tipo-R (ADD). Esperado: 10 + 5 = 15";
        s_ALUOp_in  <= "10";
        s_funct3_in <= "000";
        s_funct7_in <= "0000000"; -- funct7(5) = '0'
        wait for C_TEST_STEP;
        -- (Esperado s_ALUControl = "0010", s_Result_out = x"0000000F") 

        -- Teste 4: Instrução Tipo-R (SUB) 
        -- ALUOp = "10", funct3 = "000", funct7(5) = '1'
        report "Teste 4: Tipo-R (SUB). Esperado: 10 - 5 = 5";
        s_ALUOp_in  <= "10";
        s_funct3_in <= "000";
        s_funct7_in <= "0100000"; -- funct7(5) = '1'
        wait for C_TEST_STEP;
        -- (Esperado s_ALUControl = "0110", s_Result_out = x"00000005") 

        -- Teste 5: Instrução Tipo-R (XOR) 
        -- ALUOp = "10", funct3 = "100"
        report "Teste 5: Tipo-R (XOR). Esperado: 10 XOR 5 = 15";
        s_ALUOp_in  <= "10";
        s_funct3_in <= "100";
        wait for C_TEST_STEP;
        -- (1010_2 XOR 0101_2 = 1111_2 = 15)
        -- (Esperado s_ALUControl = "0100", s_Result_out = x"0000000F") 

        -- Teste 6: Instrução Tipo-R (OR) 
        -- ALUOp = "10", funct3 = "110"
        report "Teste 6: Tipo-R (OR). Esperado: 10 OR 5 = 15";
        s_ALUOp_in  <= "10";
        s_funct3_in <= "110";
        wait for C_TEST_STEP;
        -- (1010_2 OR 0101_2 = 1111_2 = 15)
        -- (Esperado s_ALUControl = "0001", s_Result_out = x"0000000F") 

        -- Teste 7: Instrução Tipo-R (AND) 
        -- ALUOp = "10", funct3 = "111"
        report "Teste 7: Tipo-R (AND). Esperado: 10 AND 5 = 0";
        s_ALUOp_in  <= "10";
        s_funct3_in <= "111";
        wait for C_TEST_STEP;
        -- (1010_2 AND 0101_2 = 0000_2 = 0)
        -- (Esperado s_ALUControl = "0000", s_Result_out = x"00000000") 

        -- Teste 8: Flag Zero (Z_out) 
        -- Reutilizando o SUB (Teste 4), mas com A = B
        report "Teste 8: Flag Zero (Z_out). Esperado: 5 - 5 = 0, Z_out = '1'";
        s_A_in      <= VAL_B; -- 5
        s_B_in      <= VAL_B; -- 5
        s_ALUOp_in  <= "10";
        s_funct3_in <= "000";
        s_funct7_in <= "0100000"; -- SUB
        wait for C_TEST_STEP;
        -- (Esperado s_Result_out = x"00000000", s_Z_out = '1')

        -- Teste 9: Flag Negativo (N_out) 
        -- Reutilizando o SUB (Teste 4), mas com A < B
        report "Teste 9: Flag Negativo (N_out). Esperado: 5 - 10 = -5, N_out = '1'";
        s_A_in      <= VAL_B; -- 5
        s_B_in      <= VAL_A; -- 10
        s_ALUOp_in  <= "10";
        s_funct3_in <= "000";
        s_funct7_in <= "0100000"; -- SUB
        wait for C_TEST_STEP;
        -- (Esperado s_Result_out = x"FFFFFFF_B", s_N_out = '1')

        report "Simulação concluída.";
        wait; -- Fim da simulação

    end process stim_proc;

end architecture test;