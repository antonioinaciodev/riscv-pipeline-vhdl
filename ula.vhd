----------------------------------------------------------------------------------
-- Biblioteca e Pacotes
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- Essencial para operações aritméticas

----------------------------------------------------------------------------------
-- Entidade da ULA
----------------------------------------------------------------------------------
entity ULA_simplificada is
    generic (
        DATA_WIDTH : integer := 32 -- Largura de dados de 32 bits, padrão para RISC-V
    );
    port (
        -- Entradas vindas dos muxs
        A_in        : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        B_in        : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        --Sinal de controle
        ALU_OP_in   : in  std_logic_vector(3 downto 0); -- Vai receber da ula_control.vhd - ALUControl_out

        -- Saídas
        Result_out  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        Z_out       : out std_logic; -- Flag Zero: '1' se o resultado for 0
        N_out       : out std_logic  -- Flag Negativo: '1' se o resultado for negativo (MSB = '1')
    );
end entity ULA_simplificada;

----------------------------------------------------------------------------------
-- Arquitetura da ULA
----------------------------------------------------------------------------------
architecture RTL of ULA_simplificada is

    -- Definição dos códigos de operação para 3 bits
    constant ALU_ADD  : std_logic_vector(3 downto 0) := "0010";
    constant ALU_SUB  : std_logic_vector(3 downto 0) := "0110";
    constant ALU_AND  : std_logic_vector(3 downto 0) := "0000";
    constant ALU_OR   : std_logic_vector(3 downto 0) := "0001";
    constant ALU_XOR  : std_logic_vector(3 downto 0) := "0100";
    -- Sinal interno para o resultado
    signal result_s : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin

    -- Processo principal da ULA (lógica puramente combinacional)
    process(A_in, B_in, ALU_OP_in)
    begin
        case ALU_OP_in is
            -- Operações Aritméticas
            when ALU_ADD =>
                result_s <= std_logic_vector(signed(A_in) + signed(B_in));

            when ALU_SUB =>
                result_s <= std_logic_vector(signed(A_in) - signed(B_in));

            -- Operações Lógicas
            when ALU_AND =>
                result_s <= A_in and B_in;

            when ALU_OR =>
                result_s <= A_in or B_in;

            when ALU_XOR =>
                result_s <= A_in xor B_in;

            -- Caso padrão: saída é zero se a operação for desconhecida
            when others =>
                result_s <= (others => '0');

        end case;
    end process;

    -- Atribuição concorrente da saída principal
    Result_out <= result_s;

    -- Lógica de Geração dos Flags (permanece inalterada)
    -- Flag N (Negativo): é simplesmente o bit mais significativo (MSB) do resultado.
    N_out <= result_s(DATA_WIDTH - 1);

    -- Flag Z (Zero): é '1' se TODOS os bits do resultado forem '0'.
    Z_out <= '1' when result_s = (result_s'range => '0') else '0';

end architecture RTL;