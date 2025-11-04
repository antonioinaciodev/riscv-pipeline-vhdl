library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity ULA_control is
    port (
        -- Entradas
        ALUOp_in  : in  std_logic_vector(1 downto 0); -- Vem do id_ex_register.vhd - aluop_out
        funct3_in : in  std_logic_vector(2 downto 0); -- Campo 'funct3' da instrução 
        funct7_in : in  std_logic_vector(6 downto 0); -- Campo 'funct7' da instrução

        -- Saída (1)
        ALUControl_out : out std_logic_vector(3 downto 0) -- Sinal de controle para a ULA
    );
end entity ULA_control;

architecture Behavioral of ULA_control is

    -- Códigos de operação da ULA (devem ser os mesmos definidos em ula.vhd)
    constant ALU_ADD  : std_logic_vector(3 downto 0) := "0010";
    constant ALU_SUB  : std_logic_vector(3 downto 0) := "0110";
    constant ALU_AND  : std_logic_vector(3 downto 0) := "0000";
    constant ALU_OR   : std_logic_vector(3 downto 0) := "0001";
    constant ALU_XOR  : std_logic_vector(3 downto 0) := "0100";

begin

    -- Processo para decodificar as entradas e gerar o sinal de controle da ULA
    process(ALUOp_in , funct3_in , funct7_in) -- Usar 'all' é a prática recomendada para lógica combinacional
    begin
        case ALUOp_in is
            -- Caso para instruções do tipo Load/Store (LW/SW): ULA faz uma soma
            when "00" =>
                ALUControl_out <= ALU_ADD;

            when "01" => --Tipo B
                ALUControl_out <= ALU_SUB;

            when "10" => --Tipo R
                case funct3_in is
                    when "000" => 
                        if funct7_in(5) = '0' then
                            ALUControl_out <= ALU_ADD; -- ADD
                        else
                            ALUControl_out <= ALU_SUB; -- SUB
                        end if;
                    when "100" => ALUControl_out <= ALU_XOR; -- XOR
                    when "110" => ALUControl_out <= ALU_OR;  -- OR
                    when "111" => ALUControl_out <= ALU_AND; -- AND
                    when others => ALUControl_out <= (others => 'X'); -- Operação não suportada
                end case;

            -- Outros casos: operação desconhecida
            when others =>
                ALUControl_out <= (others => 'X'); -- 'X' indica um estado desconhecido/inválido
        end case;
    end process;

end architecture Behavioral;