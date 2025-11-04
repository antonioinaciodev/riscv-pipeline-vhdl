library ieee;
use ieee.std_logic_1164.all;

entity control is
    port (
        -- Entrada
        opcode : in  std_logic_vector(6 downto 0);

        -- Saidas de Controle
        ALUOp    : out std_logic_vector(1 downto 0);
        ALUSrc   : out std_logic;
        RegWrite : out std_logic;
        MemRead  : out std_logic;
        MemWrite : out std_logic;
        MemtoReg : out std_logic;
        Branch   : out std_logic;
        Jump     : out std_logic 
    );
end entity control;

architecture behavioral of control is
begin

    process(opcode)
    begin
     
        RegWrite <= '0';
        MemRead  <= '0';
        MemWrite <= '0';
        MemtoReg <= '0';
        Branch   <= '0';
        ALUSrc   <= '0';
        Jump     <= '0';
        ALUOp    <= "11";

        case opcode is
            
            when "0110011" => --Tipo R
                RegWrite <= '1'; ALUOp <= "10";
          
            when "0010011" => --Tipo I
                RegWrite <= '1'; ALUSrc <= '1'; ALUOp <= "10";
        
            when "0000011" => --Tipo I load's
                RegWrite <= '1'; MemRead <= '1'; MemtoReg <= '1'; ALUSrc <= '1'; ALUOp <= "00";
           
            when "0100011" => --Tipo S 
                MemWrite <= '1'; ALUSrc <= '1'; ALUOp <= "00";
           
            when "1100011" => -- Tipo B (beq)
                Branch <= '1'; ALUOp <= "01";
                
           
            when "0110111" =>
                RegWrite <= '1';
                ALUSrc   <= '1';
                ALUOp    <= "00"; 
            when "1101111" =>
                RegWrite <= '1';
                Jump     <= '1';
               
            
            when others =>
                null;

        end case;
    end process;

end architecture behavioral;