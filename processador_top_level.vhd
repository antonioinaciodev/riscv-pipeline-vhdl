processador_top_level

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity processador_toplevel is
    port (
        clk : in std_logic; -- Entrada de clock
        rst : in std_logic  -- Entrada de reset
    );
end entity processador_toplevel;

    component instruction_memory is
        port (
            address     : in  std_logic_vector(31 downto 0);
            instruction : out std_logic_vector(31 downto 0)
        );
    end component;
	component immediate_generator is
    port (
        instruction   : in  std_logic_vector(31 downto 0);
        immediate_out : out std_logic_vector(31 downto 0)
    );
end component;

component pc_contador is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        pc_out  : out std_logic_vector(31 downto 0)
    );
end component;
    
    signal pc_address : std_logic_vector(31 downto 0);
    signal generated_immediate : std_logic_vector(31 downto 0);
 
    signal fetched_instruction : std_logic_vector(31 downto 0);
    

    signal opcode : std_logic_vector(6 downto 0);
    signal rd     : std_logic_vector(4 downto 0);
    signal rs1    : std_logic_vector(4 downto 0);
    signal rs2    : std_logic_vector(4 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);
    
  


begin

 
	pc_unit : component pc_contador
    port map (
        clk    => clk,       -- Conecta o clock principal
        rst    => rst,       -- Conecta o reset principal
        pc_out => pc_address -- A saida do PC agora controla o fio pc_address
    );
	 
  
    instr_mem_unit : component instruction_memory
        port map (
            address     => pc_address,          -- Conecta o fio do PC na entrada de endereco
            instruction => fetched_instruction  -- Conecta o fio da instrucao na saida
        );

 
    opcode <= fetched_instruction(6 downto 0);
    rd     <= fetched_instruction(11 downto 7);
    funct3 <= fetched_instruction(14 downto 12);
    rs1    <= fetched_instruction(19 downto 15);
    rs2    <= fetched_instruction(24 downto 20);
    funct7 <= fetched_instruction(31 downto 25);
    
      imm_gen_unit : component immediate_generator
        port map (
            instruction   => fetched_instruction,   
            immediate_out => generated_immediate    
        );
 

end architecture structural;