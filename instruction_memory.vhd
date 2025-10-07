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
	0  => b"00000000101000000000001010010011",
	1  => b"00000000111000000000001010010011",  
   2  => b"00000001111000000000001010010011",  	
        others => x"00000000"
    );
	 --addi x5,x0,10
--testar o pc com 3 comandos addi, deu bom

begin

    instruction <= PROGRAM(to_integer(unsigned(address(9 downto 2))));

end architecture behavioral;