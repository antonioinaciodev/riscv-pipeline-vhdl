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

    -- PROGRAMA SEM SALTOS - apenas instruções aritméticas e de memória
    constant PROGRAM : instruction_rom_type := (
        -- Instruções ADD (R-type)
        0  => x"00100093",  -- addi x1, x0, 1    (x1 = 1)
        1  => x"00200113",  -- addi x2, x0, 2    (x2 = 2)  
        2  => x"00300193",  -- addi x3, x0, 3    (x3 = 3)
        3  => x"00400213",  -- addi x4, x0, 4    (x4 = 4)
        
        -- Operações aritméticas
        4  => x"002081B3",  -- add  x3, x1, x2   (x3 = 1 + 2 = 3)
        5  => x"40208233",  -- sub  x4, x1, x2   (x4 = 1 - 2 = -1)
        6  => x"0020F2B3",  -- and  x5, x1, x2   (x5 = 1 & 2 = 0)
        7  => x"0020E333",  -- or   x6, x1, x2   (x6 = 1 | 2 = 3)
        
        -- Mais operações para testar forwarding
        8  => x"003084B3",  -- add  x9, x1, x3   (x9 = 1 + 3 = 4)
        9  => x"00410533",  -- add  x10, x2, x4  (x10 = 2 + 4 = 6)
        10 => x"005185B3",  -- add  x11, x3, x5  (x11 = 3 + 0 = 3)
        
        -- Instruções com imediato
        11 => x"00A00613",  -- addi x12, x0, 10  (x12 = 10)
        12 => x"01400693",  -- addi x13, x0, 20  (x13 = 20)
        13 => x"00D60733",  -- add  x14, x12, x13 (x14 = 10 + 20 = 30)
        
        -- Preenche o resto com NOPs (addi x0, x0, 0)
        others => x"00000013"
    );

begin
    instruction <= PROGRAM(to_integer(unsigned(address(9 downto 2))));
end architecture behavioral;
