library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity banco_reg is
    port (
        clk        : in  std_logic; 
        rst        : in  std_logic;  -- Sinal de reset adicionado
        RegWrite   : in  std_logic; 
        rr1_addr   : in  std_logic_vector(4 downto 0); 
        rr2_addr   : in  std_logic_vector(4 downto 0);
        wr_addr    : in  std_logic_vector(4 downto 0); 
        wr_data    : in  std_logic_vector(31 downto 0); 
        rr1_data   : out std_logic_vector(31 downto 0);
        rr2_data   : out std_logic_vector(31 downto 0)
    );
end entity banco_reg;

architecture behavioral of banco_reg is
    subtype reg_word is std_logic_vector(31 downto 0);
    type reg_array is array (0 to 31) of reg_word;
    signal registers : reg_array;

begin
    -- Processo de escrita síncrono com proteção para registros constantes
    write_process: process(clk, rst)
    begin
        if rst = '1' then
            -- Inicialização durante o reset
            registers(0)  <= x"00000000"; -- PC Register
            registers(1)  <= x"00000000"; -- AC Register  
            registers(2)  <= x"0000FFFF"; -- SP Register
            registers(3)  <= x"00000000"; -- IR Register
            registers(4)  <= x"00000000"; -- TIR Register
            registers(5)  <= x"00000000"; -- Constant ZERO Register
            registers(6)  <= x"00000001"; -- Constant +1 Register
            registers(7)  <= x"FFFFFFFF"; -- Constant -1 Register
            registers(8)  <= x"0000FFFF"; -- AMASK Register
            registers(9)  <= x"000000FF"; -- SMASK Register
            registers(10) <= x"00000000"; -- A Register
            registers(11) <= x"00000000"; -- B Register
            registers(12) <= x"00000000"; -- C Register
            registers(13) <= x"00000000"; -- D Register
            registers(14) <= x"00000000"; -- E Register
            registers(15) <= x"00000000"; -- F Register
            for i in 16 to 31 loop
                registers(i) <= x"00000000";
            end loop;
            
        elsif rising_edge(clk) then
            if RegWrite = '1' then
                -- Registro 0 é sempre zero e não pode ser escrito
                if wr_addr /= "00000" then
                    -- Proteção para registros constantes (5-9)
                    case wr_addr is
                        when "00101" => -- Registro 5 (constant zero)
                            registers(5) <= x"00000000"; -- Sempre mantém zero
                        when "00110" => -- Registro 6 (constant +1)
                            registers(6) <= x"00000001"; -- Sempre mantém +1
                        when "00111" => -- Registro 7 (constant -1)
                            registers(7) <= x"FFFFFFFF"; -- Sempre mantém -1
                        when "01000" => -- Registro 8 (AMASK)
                            registers(8) <= x"0000FFFF"; -- Sempre mantém AMASK
                        when "01001" => -- Registro 9 (SMASK)
                            registers(9) <= x"000000FF"; -- Sempre mantém SMASK
                        when others =>
                            -- Registros normais podem ser escritos
                            registers(to_integer(unsigned(wr_addr))) <= wr_data;
                    end case;
                end if;
            end if;
        end if;
    end process write_process;

    -- Processo de leitura assíncrono
    read_process: process(rr1_addr, rr2_addr, registers, RegWrite, wr_addr, wr_data)
    begin
        -- Leitura do primeiro registrador
        if rr1_addr = "00000" then
            rr1_data <= x"00000000"; -- Registro 0 sempre retorna 0
        elsif (RegWrite = '1' and wr_addr = rr1_addr and wr_addr /= "00000") then
            -- Forwarding: se estamos escrevendo no mesmo registro que estamos lendo
            rr1_data <= wr_data;
        else
            rr1_data <= registers(to_integer(unsigned(rr1_addr)));
        end if;

        -- Leitura do segundo registrador
        if rr2_addr = "00000" then
            rr2_data <= x"00000000"; -- Registro 0 sempre retorna 0
        elsif (RegWrite = '1' and wr_addr = rr2_addr and wr_addr /= "00000") then
            -- Forwarding: se estamos escrevendo no mesmo registro que estamos lendo
            rr2_data <= wr_data;
        else
            rr2_data <= registers(to_integer(unsigned(rr2_addr)));
        end if;
    end process read_process;

end architecture behavioral;
