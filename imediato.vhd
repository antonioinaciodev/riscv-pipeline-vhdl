library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity immediate_generator is
    port (

        instruction   : in  std_logic_vector(31 downto 0);
  
        immediate_out : out std_logic_vector(31 downto 0)
    );
end entity immediate_generator;

architecture behavioral of immediate_generator is
 
    signal opcode : std_logic_vector(6 downto 0);
begin

    opcode <= instruction(6 downto 0);

   
    gen_imm_process: process(opcode, instruction)
        variable imm : std_logic_vector(31 downto 0); 
    begin
      
        imm := (others => '0');
        
        case opcode is
         
            when "0010011" | "0000011" => -- I-type (Op-imm) | I-type (Load)
 
                imm := std_logic_vector(resize(signed(instruction(31 downto 20)), 32));
            
         
            when "0100011" => -- S-type (Store)
           
                imm := std_logic_vector(resize(signed(instruction(31 downto 25) & instruction(11 downto 7)), 32));
                
    
            when "1100011" => -- B-type (Branch)
  
                imm := std_logic_vector(resize(signed(instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0'), 32));

  
            when others =>
                imm := (others => 'X'); 
                
        end case;
        
        immediate_out <= imm;
    end process gen_imm_process;

end architecture behavioral;