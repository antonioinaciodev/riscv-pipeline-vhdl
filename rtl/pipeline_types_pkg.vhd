library ieee;
use ieee.std_logic_1164.all;

package pipeline_types is
    subtype reg_word is std_logic_vector(31 downto 0);
    type reg_array is array (0 to 31) of reg_word;
end package pipeline_types;
