library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_contador is
    port (
        clk     : in  std_logic; -- Entrada de clock
        rst     : in  std_logic; -- Entrada de reset
        pc_out  : out std_logic_vector(31 downto 0) -- Saida com o endereco atual
    );
end entity pc_contador;

architecture behavioral of pc_contador is
    signal pc_reg : std_logic_vector(31 downto 0);
begin

    pc_process: process(clk, rst)
    begin
 
        if rst = '1' then
            pc_reg <= (others => '0');

        elsif rising_edge(clk) then
            pc_reg <= std_logic_vector(unsigned(pc_reg) + 4);

        end if;
   
    end process pc_process;

    pc_out <= pc_reg;

end architecture behavioral;