-- teste dos jals e branchs 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_memory is
    port (
        address     : in  std_logic_vector(31 downto 0);
        instruction : out std_logic_vector(31 downto 0)
    );
end entity instruction_memory;

architecture behavioral of instruction_memory is
    subtype instruction_word is std_logic_vector(31 downto 0);
    type instruction_rom_type is array (0 to 255) of instruction_word;

    constant PROGRAM : instruction_rom_type := (
        0 => x"0100006F",  -- jal x0, +16  -- beq  x0, x0, +16 (Alvo = 16. Condição VERDADEIRA)
        1 => x"00100093",  -- addi x1, x0, 1   (Endereço 4 - Será FLUSHED)
        2 => x"00200113",  -- addi x2, x0, 2   (Endereço 8 - Não será buscada)
        3 => x"00300193",  -- addi x3, x0, 3   (Endereço 12 - Não será buscada)
        4 => x"00000533",  -- add  x10, x0, x0 (Endereço 16 - ALVO DO SALTO)
        5 => x"00000663",  -- beq x0, x0, 12 (Sexta instrução - salta 12 bytes = +3 instruções)
        6 => x"00400533",  -- add x10, x0, x4 (Sétima instrução - add)
        7 => x"005005B3",  -- add x11, x0, x5 (Oitava instrução - add)
        8 => x"00002603",  -- lw x12, 0(x0)   (Nona instrução - lw sem dependência)
        9 => x"FF9FF06F",  -- jal x0, -8      (Volta para a oitava instrução - add x11)
        others => x"00000000"
    );

begin
    instruction <= PROGRAM(to_integer(unsigned(address(9 downto 2))));
end architecture behavioral;
