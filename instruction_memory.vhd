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
	     0 => x"06400093",  -- addi x1, x0, 100  (Apenas para ter um endereco base em x1)
    1 => x"0000A283",  -- lw   x5, 0(x1)     (Carrega Mem[100] para x5)
    2 => x"00528333",  -- add  x6, x5, x5    (DEPENDE do resultado de x5)
    others => x"00000000"
    );
	

begin

    instruction <= PROGRAM(to_integer(unsigned(address(9 downto 2))));

end architecture behavioral;