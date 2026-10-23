library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alu_control is
    port (
        ALUOp_in  : in  std_logic_vector(1 downto 0);
        funct3_in : in  std_logic_vector(2 downto 0);
        funct7_in : in  std_logic_vector(6 downto 0);
        ALUControl_out : out std_logic_vector(3 downto 0)
    );
end entity alu_control;

architecture Behavioral of alu_control is
    -- Codigos de operacao da ALU (devem casar com alu.vhd)
    constant ALU_ADD  : std_logic_vector(3 downto 0) := "0010";
    constant ALU_SUB  : std_logic_vector(3 downto 0) := "0110";
    constant ALU_AND  : std_logic_vector(3 downto 0) := "0000";
    constant ALU_OR   : std_logic_vector(3 downto 0) := "0001";
    constant ALU_XOR  : std_logic_vector(3 downto 0) := "0100";
    constant ALU_SLL  : std_logic_vector(3 downto 0) := "0011"; -- shift left logico
    constant ALU_SRL  : std_logic_vector(3 downto 0) := "0101"; -- shift right logico
    constant ALU_SRA  : std_logic_vector(3 downto 0) := "0111"; -- shift right aritmetico
    constant ALU_SLT  : std_logic_vector(3 downto 0) := "1000"; -- set less than (com sinal)
    constant ALU_SLTU : std_logic_vector(3 downto 0) := "1001"; -- set less than (sem sinal)

    -- Decodifica funct3 (+ funct7 quando relevante) numa operacao da ALU.
    -- is_rtype = true permite distinguir ADD/SUB e SRL/SRA pelo funct7,
    -- que so existe em instrucoes tipo-R. No tipo-I, funct7 nao se aplica
    -- a soma (addi nunca subtrai), mas os shifts imediatos ainda usam
    -- funct7(5) para escolher SRLI vs SRAI.
    function decode(funct3 : std_logic_vector(2 downto 0);
                    funct7 : std_logic_vector(6 downto 0);
                    is_rtype : boolean) return std_logic_vector is
    begin
        case funct3 is
            when "000" =>
                if is_rtype and funct7(5) = '1' then
                    return ALU_SUB;      -- SUB (so tipo-R)
                else
                    return ALU_ADD;      -- ADD / ADDI
                end if;
            when "001" => return ALU_SLL;   -- SLL / SLLI
            when "010" => return ALU_SLT;   -- SLT / SLTI
            when "011" => return ALU_SLTU;  -- SLTU / SLTIU
            when "100" => return ALU_XOR;   -- XOR / XORI
            when "101" =>
                if funct7(5) = '1' then
                    return ALU_SRA;      -- SRA / SRAI
                else
                    return ALU_SRL;      -- SRL / SRLI
                end if;
            when "110" => return ALU_OR;    -- OR / ORI
            when "111" => return ALU_AND;   -- AND / ANDI
            when others => return (3 downto 0 => 'X');
        end case;
    end function;

begin
    process(ALUOp_in, funct3_in, funct7_in)
    begin
        case ALUOp_in is
            when "00" =>  -- Load / Store: soma para calcular endereco
                ALUControl_out <= ALU_ADD;
            when "01" =>  -- Branch: subtrai para comparar
                ALUControl_out <= ALU_SUB;
            when "10" =>  -- Tipo-R: funct3 + funct7 decidem
                ALUControl_out <= decode(funct3_in, funct7_in, true);
            when "11" =>  -- Tipo-I: funct3 decide (funct7 so vale para shift)
                ALUControl_out <= decode(funct3_in, funct7_in, false);
            when others =>
                ALUControl_out <= (others => 'X');
        end case;
    end process;
end architecture Behavioral;
