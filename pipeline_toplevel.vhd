
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline_toplevel is
    port ( clk : in std_logic; rst : in std_logic );
end entity pipeline_toplevel;

architecture structural of pipeline_toplevel is

    
    component pc_contador is port (clk: in std_logic; rst: in std_logic; write_enable: in std_logic; pc_out: out std_logic_vector(31 downto 0)); end component;
    component instruction_memory is port (address: in std_logic_vector(31 downto 0); instruction: out std_logic_vector(31 downto 0)); end component;
    component if_id_registrador is port (clk: in std_logic; rst: in std_logic; write_enable: in std_logic; pc_plus_4_in: in std_logic_vector(31 downto 0); instruction_in: in std_logic_vector(31 downto 0); pc_plus_4_out: out std_logic_vector(31 downto 0); instruction_out: out std_logic_vector(31 downto 0)); end component;
    component banco_reg is port (clk: in std_logic; RegWrite: in std_logic; rr1_addr: in std_logic_vector(4 downto 0); rr2_addr: in std_logic_vector(4 downto 0); wr_addr: in std_logic_vector(4 downto 0); wr_data: in std_logic_vector(31 downto 0); rr1_data: out std_logic_vector(31 downto 0); rr2_data: out std_logic_vector(31 downto 0)); end component;
    component control is port (opcode: in std_logic_vector(6 downto 0); MemRead: out std_logic; MemtoReg: out std_logic; RegWrite: out std_logic; MemWrite: out std_logic; ALUSrc: out std_logic; ALUOp: out std_logic_vector(1 downto 0); Branch: out std_logic; Jump: out std_logic); end component;
    component gerador_imediato is port (instruction: in std_logic_vector(31 downto 0); immediate_out: out std_logic_vector(31 downto 0)); end component;
    component id_ex_registrador is port (clk : in std_logic; rst : in std_logic; memread_in : in std_logic; regwrite_in : in std_logic; memtoreg_in : in std_logic; alusrc_in : in std_logic; aluop_in : in std_logic_vector(1 downto 0); read_data_1_in : in std_logic_vector(31 downto 0); read_data_2_in : in std_logic_vector(31 downto 0); immediate_in : in std_logic_vector(31 downto 0); rd_addr_in : in std_logic_vector(4 downto 0); memread_out : out std_logic; regwrite_out : out std_logic; memtoreg_out : out std_logic; alusrc_out : out std_logic; aluop_out : out std_logic_vector(1 downto 0); read_data_1_out : out std_logic_vector(31 downto 0); read_data_2_out : out std_logic_vector(31 downto 0); immediate_out : out std_logic_vector(31 downto 0); rd_addr_out : out std_logic_vector(4 downto 0)); end component;
    component hazard_detection_unit is port (id_ex_memread_in: in std_logic; id_ex_rd_addr_in: in std_logic_vector(4 downto 0); if_id_rs1_addr_in: in std_logic_vector(4 downto 0); if_id_rs2_addr_in: in std_logic_vector(4 downto 0); pc_write_enable: out std_logic; if_id_write_enable: out std_logic; control_nop_select: out std_logic); end component;
    
  
    signal pc_write, if_id_write, nop_select: std_logic;
    signal if_pc_address, if_pc_plus_4, if_fetched_instruction: std_logic_vector(31 downto 0);
    signal id_pc_plus_4, id_instruction: std_logic_vector(31 downto 0);
    signal id_rs1, id_rs2, id_rd: std_logic_vector(4 downto 0);
    signal id_reg_read_data_1, id_reg_read_data_2, id_immediate: std_logic_vector(31 downto 0);
    signal id_memread, id_regwrite, id_memtoreg, id_alusrc, id_memwrite, id_branch, id_jump: std_logic;
    signal id_aluop: std_logic_vector(1 downto 0);
    signal final_id_regwrite, final_id_memtoreg, final_id_alusrc, final_id_memread, final_id_memwrite, final_id_branch: std_logic;
    signal final_id_aluop: std_logic_vector(1 downto 0);
    signal ex_memread, ex_regwrite, ex_memtoreg, ex_alusrc: std_logic;
    signal ex_aluop: std_logic_vector(1 downto 0);
    signal ex_read_data_1, ex_read_data_2, ex_immediate: std_logic_vector(31 downto 0);
    signal ex_rd_addr: std_logic_vector(4 downto 0);
    signal wb_regwrite_control: std_logic := '0';
    signal wb_rd_addr: std_logic_vector(4 downto 0) := (others => '0');
    signal wb_write_data: std_logic_vector(31 downto 0) := (others => '0');
	 signal id_opcode           : std_logic_vector(6 downto 0);
	 
	

begin
    
    pc_unit : component pc_contador port map (clk=>clk, rst=>rst, write_enable=>pc_write, pc_out=>if_pc_address);
    instr_mem_unit : component instruction_memory port map (address=>if_pc_address, instruction=>if_fetched_instruction);
    if_pc_plus_4 <= std_logic_vector(unsigned(if_pc_address) + 4);
    
   
    if_id_reg_unit : component if_id_registrador port map (clk=>clk, rst=>rst, write_enable=>if_id_write, pc_plus_4_in=>if_pc_plus_4, instruction_in=>if_fetched_instruction, pc_plus_4_out=>id_pc_plus_4, instruction_out=>id_instruction);

    
    id_rs1 <= id_instruction(19 downto 15);
    id_rs2 <= id_instruction(24 downto 20);
    id_rd  <= id_instruction(11 downto 7);
	 id_opcode <= id_instruction(6 downto 0);
    
    main_control_unit : component control port map (opcode => id_opcode, RegWrite=>id_regwrite, MemtoReg=>id_memtoreg, ALUSrc=>id_alusrc, ALUOp=>id_aluop, MemRead=>id_memread, MemWrite=>id_memwrite, Branch=>id_branch, Jump=>id_jump);
    imm_gen_unit : component gerador_imediato port map (instruction=>id_instruction, immediate_out=>id_immediate);
    reg_file_unit : component banco_reg port map (clk=>clk, RegWrite=>wb_regwrite_control, rr1_addr=>id_rs1, rr2_addr=>id_rs2, wr_addr=>wb_rd_addr, wr_data=>wb_write_data, rr1_data=>id_reg_read_data_1, rr2_data=>id_reg_read_data_2);

    
    hazard_unit : component hazard_detection_unit port map (id_ex_memread_in=>ex_memread, id_ex_rd_addr_in=>ex_rd_addr, if_id_rs1_addr_in=>id_rs1, if_id_rs2_addr_in=>id_rs2, pc_write_enable=>pc_write, if_id_write_enable=>if_id_write, control_nop_select=>nop_select);
    
    
    final_id_regwrite <= id_regwrite and (not nop_select);
    final_id_memtoreg <= id_memtoreg and (not nop_select);
    final_id_alusrc   <= id_alusrc   and (not nop_select);
    final_id_memread  <= id_memread  and (not nop_select);
    final_id_memwrite <= id_memwrite and (not nop_select);
    final_id_branch   <= id_branch   and (not nop_select);
    final_id_aluop    <= id_aluop    when nop_select = '0' else "00";
    
    
    id_ex_reg_unit : component id_ex_registrador port map (clk=>clk, rst=>rst, regwrite_in=>final_id_regwrite, memtoreg_in=>final_id_memtoreg, alusrc_in=>final_id_alusrc, aluop_in=>final_id_aluop, memread_in=>final_id_memread, read_data_1_in=>id_reg_read_data_1, read_data_2_in=>id_reg_read_data_2, immediate_in=>id_immediate, rd_addr_in=>id_rd, regwrite_out=>ex_regwrite, memtoreg_out=>ex_memtoreg, alusrc_out=>ex_alusrc, aluop_out=>ex_aluop, memread_out=>ex_memread, read_data_1_out=>open, read_data_2_out=>open, immediate_out=>open, rd_addr_out=>ex_rd_addr);
    
end architecture structural;