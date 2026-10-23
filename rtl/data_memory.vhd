library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.TEXTIO.ALL;

ENTITY data_memory IS
    PORT (
        clk       : IN STD_LOGIC;
        reset     : IN STD_LOGIC;
        address   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        writeData : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        readData  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        memRead   : IN STD_LOGIC;
        memWrite  : IN STD_LOGIC;
        byteEN    : IN STD_LOGIC_VECTOR(3 DOWNTO 0) -- Controle de bytes
    );
END ENTITY data_memory;

ARCHITECTURE behavioral OF data_memory IS
    -- Tamanho da memória: 4KB (1024 palavras de 32 bits)
    CONSTANT size : INTEGER := 1024;
    TYPE MemType IS ARRAY (0 TO size-1) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    -- Inicialize a memória com zeros E VALOR ESPECÍFICO NO ENDEREÇO 64
    SIGNAL memoria : MemType := (
        16 => x"0000001E",  -- Endereço 64 = 30 (para teste imediato)
        others => (others => '0')
    );

BEGIN
    -- Processo principal de acesso à memória
    acess_process : PROCESS(clk, reset)
        VARIABLE palavra : INTEGER;
    BEGIN
        -- Reset assíncrono
        IF reset = '1' THEN
            readData <= (others => '0');
        ELSIF rising_edge(clk) THEN
            palavra := to_integer(unsigned(address(11 DOWNTO 2)));
            
            -- Escrita
            IF memWrite = '1' THEN
                CASE byteEN IS
                    WHEN "1111" => memoria(palavra) <= writeData;
                    WHEN "0011" => memoria(palavra)(15 DOWNTO 0) <= writeData(15 DOWNTO 0);
                    WHEN "1100" => memoria(palavra)(31 DOWNTO 16) <= writeData(15 DOWNTO 0);
                    WHEN "0001" => memoria(palavra)(7 DOWNTO 0) <= writeData(7 DOWNTO 0);
                    WHEN "0010" => memoria(palavra)(15 DOWNTO 8) <= writeData(7 DOWNTO 0);
                    WHEN "0100" => memoria(palavra)(23 DOWNTO 16) <= writeData(7 DOWNTO 0);
                    WHEN "1000" => memoria(palavra)(31 DOWNTO 24) <= writeData(7 DOWNTO 0);
                    WHEN OTHERS => NULL;
                END CASE;
            END IF;
            
            -- Leitura
            IF memRead = '1' THEN
                readData <= memoria(palavra);
            ELSE
                readData <= (others => '0');
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE behavioral;