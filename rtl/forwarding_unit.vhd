library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity forwarding_unit is 
port (
    id_ex_registerR1: in std_logic_vector(4 downto 0);
    id_ex_registerR2: in std_logic_vector(4 downto 0);
    
    ex_mem_registerRD: in std_logic_vector(4 downto 0);
    mem_wb_registerRD: in std_logic_vector(4 downto 0);
    
    ex_mem_registerWrite: in std_logic;
    mem_wb_registerWrite: in std_logic;
    
    ex_mem_memRead: in std_logic;  -- NOVO: sinal para detectar loads no estágio MEM
    

    forward_A: out std_logic_vector(1 downto 0);
    forward_B: out std_logic_vector(1 downto 0)
    

);

end entity forwarding_unit;


architecture behavioral of forwarding_unit is
begin
    process(id_ex_registerR1, id_ex_registerR2, ex_mem_registerRD, mem_wb_registerRD,
            ex_mem_registerWrite, mem_wb_registerWrite, ex_mem_memRead)
    begin
        -- Inicializar com valores padrão
        forward_A <= "00";
        forward_B <= "00";
        
        -- PRIORIDADE 1: Forwarding do estágio MEM para load instructions
        if (ex_mem_memRead = '1') then
            if (ex_mem_registerRD /= "00000") then
                if (ex_mem_registerRD = id_ex_registerR1) then
                    forward_A <= "11";  -- Forward do estágio MEM para A
                end if;
                if (ex_mem_registerRD = id_ex_registerR2) then
                    forward_B <= "11";  -- Forward do estágio MEM para B
                end if;
            end if;
        
        -- PRIORIDADE 2: Forwarding normal do EX/MEM e MEM/WB
        else
            -- Forward A
            if (ex_mem_registerWrite = '1' and ex_mem_registerRD /= "00000") then
                if (ex_mem_registerRD = id_ex_registerR1) then
                    forward_A <= "01";  -- Forward do EX/MEM
                end if;
            end if;
            
            if (mem_wb_registerWrite = '1' and mem_wb_registerRD /= "00000") then
                if (mem_wb_registerRD = id_ex_registerR1) then
                    forward_A <= "10";  -- Forward do MEM/WB
                end if;
            end if;
            
            -- Forward B
            if (ex_mem_registerWrite = '1' and ex_mem_registerRD /= "00000") then
                if (ex_mem_registerRD = id_ex_registerR2) then
                    forward_B <= "01";  -- Forward do EX/MEM
                end if;
            end if;
            
            if (mem_wb_registerWrite = '1' and mem_wb_registerRD /= "00000") then
                if (mem_wb_registerRD = id_ex_registerR2) then
                    forward_B <= "10";  -- Forward do MEM/WB
                end if;
            end if;
        end if;
    end process;
end architecture behavioral;
