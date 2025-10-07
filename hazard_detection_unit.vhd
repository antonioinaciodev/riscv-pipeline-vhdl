library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hazard_detection_unit is
    port (
        
        id_ex_memread_in  : in std_logic; 
        id_ex_rd_addr_in  : in std_logic_vector(4 downto 0); 
        if_id_rs1_addr_in : in std_logic_vector(4 downto 0); 
        if_id_rs2_addr_in : in std_logic_vector(4 downto 0); 

      
        pc_write_enable     : out std_logic; 
        if_id_write_enable  : out std_logic; 
        control_nop_select  : out std_logic 
    );
end entity hazard_detection_unit;

architecture behavioral of hazard_detection_unit is
    
    signal hazard_condition : std_logic;
begin
   
    hazard_condition <= '1' when (id_ex_memread_in = '1') and
                                 (id_ex_rd_addr_in /= "00000") and
                                 ((id_ex_rd_addr_in = if_id_rs1_addr_in) or
                                  (id_ex_rd_addr_in = if_id_rs2_addr_in))
                        else '0';
    pc_write_enable    <= '0' when hazard_condition = '1' else '1';
    if_id_write_enable <= '0' when hazard_condition = '1' else '1';
    control_nop_select <= '1' when hazard_condition = '1' else '0';

end architecture behavioral;