library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity instruction_memory is
    generic (
        -- Caminho do arquivo .hex com o programa a ser executado.
        -- Pode ser trocado na simulacao sem recompilar (ver scripts/sim.do).
        PROGRAM_FILE : string := "../programs/test_rtype.hex"
    );
    port (
        address     : in  std_logic_vector(31 downto 0);
        instruction : out std_logic_vector(31 downto 0)
    );
end entity instruction_memory;

architecture behavioral of instruction_memory is

    subtype instruction_word is std_logic_vector(31 downto 0);
    type instruction_rom_type is array (0 to 255) of instruction_word;

    -- Funcao que le o arquivo .hex e preenche a ROM.
    -- Cada linha do arquivo deve conter 8 digitos hexadecimais (uma instrucao de 32 bits).
    -- Linhas em branco sao ignoradas. Posicoes nao preenchidas viram NOP (addi x0,x0,0).
    -- Converte um caractere hexadecimal em 4 bits (portavel, sem bibliotecas externas)
    function hex_char_to_slv(c : character) return std_logic_vector is
    begin
        case c is
            when '0' => return "0000";
            when '1' => return "0001";
            when '2' => return "0010";
            when '3' => return "0011";
            when '4' => return "0100";
            when '5' => return "0101";
            when '6' => return "0110";
            when '7' => return "0111";
            when '8' => return "1000";
            when '9' => return "1001";
            when 'A' | 'a' => return "1010";
            when 'B' | 'b' => return "1011";
            when 'C' | 'c' => return "1100";
            when 'D' | 'd' => return "1101";
            when 'E' | 'e' => return "1110";
            when 'F' | 'f' => return "1111";
            when others => return "XXXX";
        end case;
    end function;

    impure function load_program(file_name : string) return instruction_rom_type is
        file     prog_file : text;
        variable line_buf  : line;
        variable word_buf  : std_logic_vector(31 downto 0);
        variable rom       : instruction_rom_type := (others => x"00000013"); -- NOP
        variable index     : integer := 0;
        variable status    : file_open_status;
        variable c         : character;
        variable good      : boolean;
        variable nibble    : integer;
    begin
        file_open(status, prog_file, file_name, read_mode);

        if status /= open_ok then
            report "instruction_memory: NAO foi possivel abrir o arquivo '" & file_name &
                   "'. A ROM ficara so com NOPs." severity warning;
            return rom;
        end if;

        while not endfile(prog_file) and index < 256 loop
            readline(prog_file, line_buf);
            -- Le ate 8 caracteres hex da linha, montando a palavra de 32 bits
            word_buf := (others => '0');
            nibble := 0;
            loop
                read(line_buf, c, good);
                exit when not good;              -- fim da linha
                next when c = ' ' or c = HT;     -- ignora espacos/tabs
                word_buf := word_buf(27 downto 0) & hex_char_to_slv(c);
                nibble := nibble + 1;
            end loop;
            -- So grava se a linha tinha conteudo hex
            if nibble > 0 then
                rom(index) := word_buf;
                index := index + 1;
            end if;
        end loop;

        file_close(prog_file);

        report "instruction_memory: carregadas " & integer'image(index) &
               " instrucoes de '" & file_name & "'." severity note;
        return rom;
    end function;

    constant PROGRAM : instruction_rom_type := load_program(PROGRAM_FILE);

begin
    -- Endereco em bytes -> indice de palavra (divide por 4), usa 8 bits (256 posicoes)
    instruction <= PROGRAM(to_integer(unsigned(address(9 downto 2))));
end architecture behavioral;
