----------------------------------------------------------------------------------
-- ALU do processador RISC-V (RV32I)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    generic (
        DATA_WIDTH : integer := 32
    );
    port (
        A_in        : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        B_in        : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        ALU_OP_in   : in  std_logic_vector(3 downto 0);
        Result_out  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        Z_out       : out std_logic;
        N_out       : out std_logic
    );
end entity alu;

architecture RTL of alu is
    -- Codigos de operacao (devem casar com alu_control.vhd)
    constant ALU_ADD  : std_logic_vector(3 downto 0) := "0010";
    constant ALU_SUB  : std_logic_vector(3 downto 0) := "0110";
    constant ALU_AND  : std_logic_vector(3 downto 0) := "0000";
    constant ALU_OR   : std_logic_vector(3 downto 0) := "0001";
    constant ALU_XOR  : std_logic_vector(3 downto 0) := "0100";
    constant ALU_SLL  : std_logic_vector(3 downto 0) := "0011";
    constant ALU_SRL  : std_logic_vector(3 downto 0) := "0101";
    constant ALU_SRA  : std_logic_vector(3 downto 0) := "0111";
    constant ALU_SLT  : std_logic_vector(3 downto 0) := "1000";
    constant ALU_SLTU : std_logic_vector(3 downto 0) := "1001";

    signal result_s : std_logic_vector(DATA_WIDTH - 1 downto 0);

    -- A quantidade de shift em RV32I usa so os 5 bits baixos do operando B
    function shamt(b : std_logic_vector) return integer is
    begin
        return to_integer(unsigned(b(4 downto 0)));
    end function;

begin
    process(A_in, B_in, ALU_OP_in)
    begin
        case ALU_OP_in is
            when ALU_ADD =>
                result_s <= std_logic_vector(signed(A_in) + signed(B_in));
            when ALU_SUB =>
                result_s <= std_logic_vector(signed(A_in) - signed(B_in));
            when ALU_AND =>
                result_s <= A_in and B_in;
            when ALU_OR =>
                result_s <= A_in or B_in;
            when ALU_XOR =>
                result_s <= A_in xor B_in;
            when ALU_SLL =>
                result_s <= std_logic_vector(shift_left(unsigned(A_in), shamt(B_in)));
            when ALU_SRL =>
                result_s <= std_logic_vector(shift_right(unsigned(A_in), shamt(B_in)));
            when ALU_SRA =>
                result_s <= std_logic_vector(shift_right(signed(A_in), shamt(B_in)));
            when ALU_SLT =>
                -- set less than com sinal: 1 se A < B, senao 0
                if signed(A_in) < signed(B_in) then
                    result_s <= (0 => '1', others => '0');
                else
                    result_s <= (others => '0');
                end if;
            when ALU_SLTU =>
                -- set less than sem sinal
                if unsigned(A_in) < unsigned(B_in) then
                    result_s <= (0 => '1', others => '0');
                else
                    result_s <= (others => '0');
                end if;
            when others =>
                result_s <= (others => '0');
        end case;
    end process;

    Result_out <= result_s;
    N_out <= result_s(DATA_WIDTH - 1);
    Z_out <= '1' when result_s = (result_s'range => '0') else '0';

end architecture RTL;
