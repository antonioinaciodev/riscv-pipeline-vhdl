library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity branch_condition_unit is
    port (
       
        read_data_1 : in  std_logic_vector(31 downto 0); 
        read_data_2 : in  std_logic_vector(31 downto 0); 
        funct3      : in  std_logic_vector(2 downto 0);  
        
        condition_met : out std_logic                      
    );
end entity branch_condition_unit;

architecture behavioral of branch_condition_unit is
    
    signal sub_result : signed(31 downto 0);
   
    signal is_zero     : std_logic;
    signal is_negative : std_logic;
begin
    sub_result <= signed(read_data_1) - signed(read_data_2);
    is_zero <= '1' when sub_result = 0 else '0';
    is_negative <= sub_result(31);
    process(funct3, is_zero, is_negative, read_data_1, read_data_2)
    begin
       
        condition_met <= '0';

       
        case funct3 is
           
            when "000" =>
                if is_zero = '1' then
                    condition_met <= '1';
                end if;

           
            when "001" =>
                if is_zero = '0' then
                    condition_met <= '1';
                end if;

           
            when "100" =>
                if is_negative = '1' then
                    condition_met <= '1';
                end if;

           
            when "101" =>
                if is_negative = '0' then
                    condition_met <= '1';
                end if;
            when "110" =>
                if unsigned(read_data_1) < unsigned(read_data_2) then
                    condition_met <= '1';
                end if;

            when "111" =>
                if unsigned(read_data_1) >= unsigned(read_data_2) then
                    condition_met <= '1';
                end if;
            when others =>
                condition_met <= '0'; 
        end case;
    end process;

end architecture behavioral;
