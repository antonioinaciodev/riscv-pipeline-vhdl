library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity banco_reg is
    port (
        -- Entradas
        clk        : in  std_logic; 
        RegWrite   : in  std_logic; 
        rr1_addr   : in  std_logic_vector(4 downto 0); 
        rr2_addr   : in  std_logic_vector(4 downto 0);
        wr_addr    : in  std_logic_vector(4 downto 0); 
        wr_data    : in  std_logic_vector(31 downto 0); 

        -- Saidas
        rr1_data   : out std_logic_vector(31 downto 0);
        rr2_data   : out std_logic_vector(31 downto 0)  
    );
end entity banco_reg;

architecture behavioral of banco_reg is

    
    subtype reg_word is std_logic_vector(31 downto 0);
    type reg_array is array (0 to 31) of reg_word;

  
    signal registers : reg_array := (others => x"00000000");

begin

 
    rr1_data <= x"00000000" when rr1_addr = "00000" else registers(to_integer(unsigned(rr1_addr)));
    rr2_data <= x"00000000" when rr2_addr = "00000" else registers(to_integer(unsigned(rr2_addr)));

    write_process: process(clk)
    begin
        if rising_edge(clk) then
            
            if (RegWrite = '1' and wr_addr /= "00000") then
                registers(to_integer(unsigned(wr_addr))) <= wr_data;
            end if;
        end if;
    end process write_process;

end architecture behavioral;