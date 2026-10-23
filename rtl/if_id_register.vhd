library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity if_id_registrador is
    port (
        clk            : in  std_logic;
        rst            : in  std_logic;
        write_enable   : in  std_logic;
        
		pc_in          : in  std_logic_vector(31 downto 0);
        pc_plus_4_in   : in  std_logic_vector(31 downto 0);
        instruction_in : in  std_logic_vector(31 downto 0);
        
        pc_out         : out  std_logic_vector(31 downto 0);
        pc_plus_4_out  : out std_logic_vector(31 downto 0);
        instruction_out: out std_logic_vector(31 downto 0)
    );
end entity if_id_registrador;

architecture behavioral of if_id_registrador is
begin
    
    pipeline_reg_process: process(clk, rst)
    begin
        if rst = '1' then
		      pc_out         <= (others => '0');
            pc_plus_4_out  <= (others => '0');
            instruction_out <= (others => '0');
        elsif rising_edge(clk) then
 
            if write_enable = '1' then
		          pc_out <= pc_in;		
                pc_plus_4_out  <= pc_plus_4_in;
                instruction_out <= instruction_in;
            end if;
            
        end if;
    end process;
    
end architecture behavioral;
