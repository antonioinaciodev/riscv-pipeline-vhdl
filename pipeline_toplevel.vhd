
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline_toplevel is
    port ( clk : in std_logic; rst : in std_logic );
end entity pipeline_toplevel;

architecture structural of pipeline_toplevel is

    
   component pc_contador is port (clk: in std_logic; rst: in std_logic;pc_in: in std_logic_vector(31 downto 0); write_enable: in std_logic; pc_out: out std_logic_vector(31 downto 0)); end component;
   component instruction_memory is port (address: in std_logic_vector(31 downto 0); instruction: out std_logic_vector(31 downto 0)); end component;
   component if_id_registrador is port (clk: in std_logic;pc_in: in std_logic_vector(31 downto 0); rst: in std_logic; write_enable: in std_logic; pc_plus_4_in: in std_logic_vector(31 downto 0); instruction_in: in std_logic_vector(31 downto 0); pc_plus_4_out: out std_logic_vector(31 downto 0);pc_out: out std_logic_vector(31 downto 0); instruction_out: out std_logic_vector(31 downto 0)); end component;
   
	component banco_reg is port (clk: in std_logic;rst        : in  std_logic;
	RegWrite: in std_logic; rr1_addr: in std_logic_vector(4 downto 0); 
	rr2_addr: in std_logic_vector(4 downto 0); wr_addr: in std_logic_vector(4 downto 0); 
	wr_data: in std_logic_vector(31 downto 0); rr1_data: out std_logic_vector(31 downto 0); 
	rr2_data: out std_logic_vector(31 downto 0)); end component;
   
	component control is port (opcode: in std_logic_vector(6 downto 0); MemRead: out std_logic; MemtoReg: out std_logic; RegWrite: out std_logic; MemWrite: out std_logic; ALUSrc: out std_logic; ALUOp: out std_logic_vector(1 downto 0); Branch: out std_logic; Jump: out std_logic); end component;
   component gerador_imediato is port (instruction: in std_logic_vector(31 downto 0); immediate_out: out std_logic_vector(31 downto 0)); end component;
   component hazard_detection_unit is port (id_ex_memread_in: in std_logic; id_ex_rd_addr_in: in std_logic_vector(4 downto 0); if_id_rs1_addr_in: in std_logic_vector(4 downto 0); if_id_rs2_addr_in: in std_logic_vector(4 downto 0); pc_write_enable: out std_logic; if_id_write_enable: out std_logic; control_nop_select: out std_logic); end component;
   component branch_condition_unit is port (read_data_1 : in  std_logic_vector(31 downto 0);read_data_2 : in  std_logic_vector(31 downto 0);funct3: in  std_logic_vector(2 downto 0); condition_met : out std_logic ); end component;
	 
	component id_ex_registrador is port (clk : in std_logic; rst : in std_logic; memwrite_in : in std_logic; memread_in : in std_logic; memtoreg_in : in std_logic; regwrite_in : in std_logic; alusrc_in : std_logic; aluop_in : std_logic_vector(1 downto 0); branch_in : in std_logic;
													  read_data_1_in : in std_logic_vector(31 downto 0); read_data_2_in : in std_logic_vector(31 downto 0); immediate_in   : in std_logic_vector(31 downto 0); rd_addr_in : in std_logic_vector(4 downto 0); rs1_addr_in : in std_logic_vector(4 downto 0); rs2_addr_in : in std_logic_vector(4 downto 0); funct7_in : in std_logic_vector(6 downto 0); funct3_in : in std_logic_vector(2 downto 0);
													  memread_out  : out std_logic;  memtoreg_out : out std_logic; memwrite_out : out std_logic; branch_out : out std_logic; regwrite_out : out std_logic; alusrc_out : out std_logic; aluop_out : out std_logic_vector(1 downto 0);
													  read_data_1_out : out std_logic_vector(31 downto 0); read_data_2_out : out std_logic_vector(31 downto 0); immediate_out : out std_logic_vector(31 downto 0); rs1_addr_out : out std_logic_vector(4 downto 0); rs2_addr_out : out std_logic_vector(4 downto 0); rd_addr_out : out std_logic_vector(4 downto 0); funct7_out : out std_logic_vector(6 downto 0);funct3_out : out std_logic_vector(2 downto 0)
													  ); end component;
													  
	component ex_mem_register is port (clk : in std_logic; reset: in std_logic; memWriteEX : in std_logic; memReadEX : in std_logic; branchEX : in std_logic; memToRegEX : in std_logic; regWriteEX: in std_logic;
													aluResultEX : in std_logic_vector(31 downto 0); writeDataEX: in std_logic_vector(31 downto 0); rdRegisterEX : in std_logic_vector(4 downto 0); pcRegisterEX: in std_logic_vector(31 downto 0);funct3EX: in std_logic_vector(2 downto 0); 
													memWriteMEM : out std_logic; memReadMEM: out std_logic; branchMEM: out std_logic; memToRegMEM: out std_logic; regWriteMEM: out std_logic;
													aluResultMEM : out std_logic_vector(31 downto 0); writeDataMEM: out std_logic_vector(31 downto 0); rdRegisterMEM : out std_logic_vector(4 downto 0); funct3MEM: out std_logic_vector(2 downto 0); pcRegisterMEM: out std_logic_vector(31 downto 0)
													);end component;
	
	component mem_web_register is port(clk : in std_logic; reset: in std_logic; memToRegMEM : in std_logic; regWriteMEM: in std_logic;
													aluResultMEM : in std_logic_vector(31 downto 0); readDataMEM: in std_logic_vector(31 downto 0); rdRegisterMEM : in std_logic_vector(4 downto 0);
													memToRegWEB: out std_logic; regWriteWEB: out std_logic; 
													aluResultWEB : out std_logic_vector(31 downto 0); readDataWEB: out std_logic_vector(31 downto 0); rdRegisterWEB : out std_logic_vector(4 downto 0)
													);end component;
	component ULA_simplificada is generic ( DATA_WIDTH : integer := 32);
											 port (A_in : in std_logic_vector(DATA_WIDTH - 1 downto 0); B_in : in  std_logic_vector(DATA_WIDTH - 1 downto 0); ALU_OP_in : in  std_logic_vector(3 downto 0);
													 Result_out : out std_logic_vector(DATA_WIDTH - 1 downto 0); Z_out : out std_logic; N_out : out std_logic
													);end component;
	component forwardingUnit is port 
	(id_ex_registerR1: in std_logic_vector(4 downto 0);
	id_ex_registerR2: in std_logic_vector(4 downto 0);
	ex_mem_registerRD: in std_logic_vector(4 downto 0); mem_wb_registerRD: in std_logic_vector(4 downto 0); 
	                                   ex_mem_registerWrite: in std_logic; mem_wb_registerWrite: in std_logic;
												  ex_mem_memRead: in std_logic; 
												  forward_A: out std_logic_vector(1 downto 0);
												  forward_B: out std_logic_vector(1 downto 0)
													);end component;
	component ULA_control is port (ALUOp_in : in std_logic_vector(1 downto 0); funct7_in : in std_logic_vector(6 downto 0); funct3_in : in std_logic_vector(2 downto 0);
											 ALUControl_out: out std_logic_vector(3 downto 0)
											);end component;
	component data_memory is port (
        clk         : IN STD_LOGIC; reset       : IN STD_LOGIC;
        address     : IN STD_LOGIC_VECTOR(31 DOWNTO 0); writeData  : IN STD_LOGIC_VECTOR(31 DOWNTO 0); memRead    : IN STD_LOGIC; memWrite   : IN STD_LOGIC;  byteEN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		  readData   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        
    ); end component;
		
														
  
    signal pc_write, if_id_write, nop_select: std_logic;
	 signal if_instruction_to_id : std_logic_vector(31 downto 0);
	 signal id_take_branch        : std_logic;
	 signal id_opcode           : std_logic_vector(6 downto 0);
	 signal id_branch_target_addr: std_logic_vector(31 downto 0);
    signal id_jump_target_addr     : std_logic_vector(31 downto 0); 
    signal id_jalr_target_addr   : std_logic_vector(31 downto 0); 
	 signal id_jalr_base_addr     : signed(31 downto 0);
	 signal pc_mux_select         : std_logic_vector(1 downto 0); 
    signal if_flush_signal       : std_logic; 
     
	 signal if_pc_address, if_pc_plus_4, if_fetched_instruction: std_logic_vector(31 downto 0);
    signal next_pc_address : std_logic_vector(31 downto 0);
	 signal id_pc_plus_4, id_instruction: std_logic_vector(31 downto 0);
    signal id_rs1, id_rs2, id_rd: std_logic_vector(4 downto 0);
    
	 signal id_reg_read_data_1, id_reg_read_data_2, id_immediate: std_logic_vector(31 downto 0);
	 
    signal id_memread, id_regwrite, id_memtoreg, id_alusrc, id_memwrite, id_branch, id_jump: std_logic;
    signal id_aluop: std_logic_vector(1 downto 0);
    signal final_id_regwrite, final_id_memtoreg, final_id_alusrc, final_id_memread, final_id_memwrite, final_id_branch: std_logic;
    signal final_id_aluop: std_logic_vector(1 downto 0);
	 
    
    signal wb_regwrite_control: std_logic := '0';
	 signal id_pc_address     : std_logic_vector(31 downto 0);
    signal wb_rd_addr: std_logic_vector(4 downto 0) := (others => '0');
    signal wb_write_data: std_logic_vector(31 downto 0) := (others => '0');
	 signal id_funct3             : std_logic_vector(2 downto 0); 
    signal id_branch_condition_met : std_logic;
	 constant NOP_INSTRUCTION : std_logic_vector(31 downto 0) := x"00000013";
	 
	 -- novos sinais do ix/ex
	 signal id_ex_memread, id_ex_memtoreg, id_ex_memwrite, id_ex_regwrite, id_ex_alusrc, id_ex_branch : std_logic;
	 signal id_ex_aluop : std_logic_vector(1 downto 0);
	 signal id_ex_read_data_1, id_ex_read_data_2, id_ex_immediate : std_logic_vector(31 downto 0);
	 signal id_ex_rs1_addr, id_ex_rs2_addr, id_ex_rd_addr : std_logic_vector(4 downto 0);
	 signal id_ex_funct7 : std_logic_vector(6 downto 0); -- novo
	 signal id_ex_funct3 : std_logic_vector(2 downto 0);
	 
	 -- sinais ex/mem
	 signal ex_mem_memWrite, ex_mem_memRead, ex_mem_branch, ex_mem_memToReg, ex_mem_regWrite : std_logic;
	 signal ex_mem_aluResult, ex_mem_writeData, ex_mem_pcRegister : std_logic_vector(31 downto 0);
	 signal ex_mem_funct3 : std_logic_vector(2 downto 0);
	 signal ex_mem_rdRegister : std_logic_vector(4 downto 0);
	 
	 signal alu_a_input, alu_b_input, alu_result : std_logic_vector(31 downto 0);
	 signal alu_control_signal : std_logic_vector(3 downto 0);
	 signal alu_zero, alu_negative : std_logic;
	 
	 --sinais foewarding unit
	 signal forwardA, forwardB : std_logic_vector(1 downto 0);
	 signal mux_forwardA_out, mux_forwardB_out, mux_alusrc_out : std_logic_vector(31 downto 0);
	 
	 -- Sinais do estágio MEM/WB
	 signal mem_wb_memToReg, mem_wb_regWrite: std_logic;
	 signal mem_wb_aluResult, mem_wb_readData: std_logic_vector(31 downto 0);
	 signal mem_wb_rdRegister: std_logic_vector(4 downto 0);
	 
	 -- simulacao do data memory
	 signal data_memory_read_data : std_logic_vector(31 downto 0) := (others => '0');
	 signal byte_enable : std_logic_vector(3 downto 0);
	 
	 -- sinal final do mux
	 signal write_back_data : std_logic_vector(31 downto 0);
	 
	signal debug_reg_6_out : std_logic_vector(31 downto 0);
   signal debug_reg_7_out : std_logic_vector(31 downto 0);
   signal debug_reg_8_out : std_logic_vector(31 downto 0);
   signal debug_write_enable_out : std_logic;
   signal debug_write_addr_out : std_logic_vector(4 downto 0);
   signal debug_write_data_out : std_logic_vector(31 downto 0);
	 
	 
	

begin


	 pc_mux_select <= "11" when (id_jump = '1' and id_opcode = "1100111") else
	                  "10" when id_jump = '1' else         
                     "01" when id_take_branch = '1' else 
                     "00";                               

    with pc_mux_select select
        next_pc_address <= if_pc_plus_4          when "00",
                           id_branch_target_addr when "01",
                           id_jump_target_addr   when "10",
									id_jalr_target_addr   when "11",
                           (others => 'X')       when others; 
    
    pc_unit : component pc_contador port map (clk=>clk, rst=>rst, write_enable=>pc_write,pc_in=> next_pc_address, pc_out=>if_pc_address);
    instr_mem_unit : component instruction_memory port map (address=>if_pc_address, instruction=>if_fetched_instruction);
    if_pc_plus_4 <= std_logic_vector(unsigned(if_pc_address) + 4);
	 if_flush_signal <= id_jump or id_take_branch;
    if_instruction_to_id <= NOP_INSTRUCTION when if_flush_signal = '1' else
                              if_fetched_instruction;
   
    if_id_reg_unit : component if_id_registrador port map (clk=>clk, rst=>rst,pc_in=> if_pc_address,pc_out=> id_pc_address, write_enable=>if_id_write, pc_plus_4_in=>if_pc_plus_4, instruction_in=>if_instruction_to_id, pc_plus_4_out=>id_pc_plus_4, instruction_out=>id_instruction);

    
    id_rs1 <= id_instruction(19 downto 15); -- ????
    id_rs2 <= id_instruction(24 downto 20); --- ???
    id_rd  <= id_instruction(11 downto 7); --- ??
	 id_opcode <= id_instruction(6 downto 0); ---???
	 id_funct3 <= id_instruction(14 downto 12); --- ????
    
    main_control_unit : component control port map (opcode => id_opcode, RegWrite=>id_regwrite, MemtoReg=>id_memtoreg, ALUSrc=>id_alusrc, ALUOp=>id_aluop, MemRead=>id_memread, MemWrite=>id_memwrite, Branch=>id_branch, Jump=>id_jump);
    imm_gen_unit : component gerador_imediato port map (instruction=>id_instruction, immediate_out=>id_immediate);
    
	 reg_file_unit : component banco_reg port map 
	 (clk=>clk,rst=>rst, RegWrite=>wb_regwrite_control, rr1_addr=>id_rs1, rr2_addr=>id_rs2, wr_addr=>wb_rd_addr, 
	 wr_data=>wb_write_data, rr1_data=>id_reg_read_data_1, rr2_data=>id_reg_read_data_2);
	 
	 
	 id_jalr_base_addr <= signed(id_reg_read_data_1) + signed(id_immediate);
    
    id_jalr_target_addr <= std_logic_vector(id_jalr_base_addr(31 downto 1) & '0');
	 
	 
	 id_jump_target_addr <= std_logic_vector(signed(id_pc_address) + signed(id_immediate));
    
	 
	 
	 
    hazard_unit : component hazard_detection_unit port map (id_ex_memread_in=>id_ex_memread, id_ex_rd_addr_in=>id_ex_rd_addr, if_id_rs1_addr_in=>id_rs1, if_id_rs2_addr_in=>id_rs2, pc_write_enable=>pc_write, if_id_write_enable=>if_id_write, control_nop_select=>nop_select);
    
    
    final_id_regwrite <= id_regwrite and (not nop_select);
    final_id_memtoreg <= id_memtoreg and (not nop_select);
    final_id_alusrc   <= id_alusrc   and (not nop_select);
    final_id_memread  <= id_memread  and (not nop_select);
    final_id_memwrite <= id_memwrite and (not nop_select);
    final_id_branch   <= id_branch   and (not nop_select);
    final_id_aluop    <= id_aluop    when nop_select = '0' else "00";
    
    -- novo id/ex
    ID_EX_REG: id_ex_registrador port map(clk => clk, rst => rst,
					-- Entradas do estágio ID
					memread_in => final_id_memread,
					memtoreg_in => final_id_memtoreg,
					memwrite_in => final_id_memwrite,
					regwrite_in => final_id_regwrite,
					alusrc_in => final_id_alusrc,
					aluop_in => final_id_aluop,
					branch_in => final_id_branch, 
					read_data_1_in => id_reg_read_data_1,
					read_data_2_in => id_reg_read_data_2,
					immediate_in => id_immediate,
					rd_addr_in => id_rd,
					rs1_addr_in => id_rs1,
					rs2_addr_in => id_rs2,
					funct7_in => id_instruction(31 downto 25),funct3_in => id_instruction(14 downto 12),
					-- Saídas para o estágio EX
					memread_out => id_ex_memread,
					memtoreg_out => id_ex_memtoreg,
					memwrite_out => id_ex_memwrite,
					branch_out => id_ex_branch,
					regwrite_out => id_ex_regwrite,
					alusrc_out => id_ex_alusrc, aluop_out => id_ex_aluop,
					read_data_1_out => id_ex_read_data_1,
					read_data_2_out => id_ex_read_data_2,
					immediate_out => id_ex_immediate,
					rs1_addr_out => id_ex_rs1_addr,
					rs2_addr_out => id_ex_rs2_addr,
					rd_addr_out => id_ex_rd_addr, funct7_out => id_ex_funct7,funct3_out => id_ex_funct3
					);
	-- forwarding unit
		FORWARDING_UNIT: forwardingUnit port map(
		 id_ex_registerR1 => id_ex_rs1_addr,
		 id_ex_registerR2 => id_ex_rs2_addr,
		 ex_mem_registerRD => ex_mem_rdRegister,
		 mem_wb_registerRD => mem_wb_rdRegister,
		 ex_mem_registerWrite => ex_mem_regWrite,
		 mem_wb_registerWrite => mem_wb_regWrite,
		 ex_mem_memRead => ex_mem_memRead,  -- NOVO: conectar este sinal
		 forward_A => forwardA,
		 forward_B => forwardB
	);
		-- MUX para forward A (entrada A da ULA)
		MUX_FORWARD_A: process(forwardA, id_ex_read_data_1, ex_mem_aluResult, write_back_data, data_memory_read_data)
		begin
			 case forwardA is
				  when "00" => mux_forwardA_out <= id_ex_read_data_1;
				  when "01" => mux_forwardA_out <= ex_mem_aluResult;
				  when "10" => mux_forwardA_out <= write_back_data;
				  when "11" => mux_forwardA_out <= data_memory_read_data;  -- NOVO: forwarding do MEM
				  when others => mux_forwardA_out <= id_ex_read_data_1;
			 end case;
		end process;

		-- MUX para forward B (entrada B da ULA)
		MUX_FORWARD_B: process(forwardB, id_ex_read_data_2, ex_mem_aluResult, write_back_data, data_memory_read_data)
		begin
			 case forwardB is
				  when "00" => mux_forwardB_out <= id_ex_read_data_2;
				  when "01" => mux_forwardB_out <= ex_mem_aluResult;
				  when "10" => mux_forwardB_out <= write_back_data;
				  when "11" => mux_forwardB_out <= data_memory_read_data;  -- NOVO: forwarding do MEM
				  when others => mux_forwardB_out <= id_ex_read_data_2;
			 end case;
		end process;
	 -- MUX ALUSrc (seleciona entre o registrador e o imediato)
    MUX_ALUSRC: process(id_ex_alusrc, mux_forwardB_out, id_ex_immediate)
    begin
        if id_ex_alusrc = '0' then
            mux_alusrc_out <= mux_forwardB_out;
        else
            mux_alusrc_out <= id_ex_immediate;
        end if;
    end process;
	 
	alu_a_input <= mux_forwardA_out;
	alu_b_input <= mux_alusrc_out;
	  -- Instância do controle da ULA
    ULA_CTRL: ULA_control port map(ALUOp_in  => id_ex_aluop,
        funct7_in => id_ex_funct7,  -- bit 30 do imediato (funct7)
        funct3_in => id_ex_funct3,  -- bits 14-12 (funct3)
        ALUControl_out => alu_control_signal
    );
	  -- Instância da ULA
    ALU: ULA_simplificada
    generic map(DATA_WIDTH => 32)
    port map(A_in => mux_forwardA_out,
	 B_in => mux_alusrc_out,
	 ALU_OP_in => alu_control_signal, Result_out => alu_result, Z_out => alu_zero, N_out => alu_negative
				);
	 -- Instância do registrador EX/MEM
    EX_MEM_REG: ex_mem_register port map(clk => clk, reset => rst,       
						-- Entradas do estágio EX
						memWriteEX => id_ex_memwrite,
						memReadEX => id_ex_memread,
						branchEX => id_ex_branch,
						memToRegEX => id_ex_memtoreg, regWriteEX => id_ex_regwrite, aluResultEX => alu_result,
						writeDataEX => mux_forwardB_out,  -- Dado a ser escrito na memória (com forwarding)
						rdRegisterEX => id_ex_rd_addr,
						funct3EX => id_ex_funct3,
						pcRegisterEX => id_pc_address,  -- conversar com joao sobre onde sera feito o jal e se necessario passar o pc para o estagio ex
        
						-- Saídas para o estágio MEM
						memWriteMEM => ex_mem_memWrite,
						funct3MEM => ex_mem_funct3,
						memReadMEM => ex_mem_memRead,
						branchMEM => ex_mem_branch,
						memToRegMEM => ex_mem_memToReg, regWriteMEM => ex_mem_regWrite,        
						aluResultMEM => ex_mem_aluResult,
						writeDataMEM => ex_mem_writeData,
						rdRegisterMEM => ex_mem_rdRegister, pcRegisterMEM => ex_mem_pcRegister
						);
	

	 byte_enable <= "1111"; 
	data_mem: data_memory port map(
				 clk => clk,
				 reset => rst,
				 address => ex_mem_aluResult,
				 writeData => ex_mem_writeData,
				 readData => data_memory_read_data,  -- Saída da memória (palavra inteira)
				 memRead => ex_mem_memRead,
				 memWrite => ex_mem_memWrite,
				 byteEN => byte_enable   -- Sinal que vamos gerar
	);
	 -- Instância do registrador MEM/WB
    MEM_WB_REG: mem_web_register port map(clk => clk, reset => rst,        
						-- Entradas do estágio MEM
						memToRegMEM => ex_mem_memToReg, regWriteMEM => ex_mem_regWrite, aluResultMEM => ex_mem_aluResult,
						readDataMEM => data_memory_read_data,  -- Dado lido da memória ,ainda nao tenho, esperando codigo do benjas
						rdRegisterMEM => ex_mem_rdRegister,
        
					   -- Saídas para o estágio WB
					   memToRegWEB => mem_wb_memToReg, regWriteWEB => mem_wb_regWrite, aluResultWEB => mem_wb_aluResult, readDataWEB => mem_wb_readData, rdRegisterWEB => mem_wb_rdRegister
						);
	-- MUX para Write Back (memToReg)
    MUX_WB: process(mem_wb_memToReg, mem_wb_aluResult, mem_wb_readData)
    begin
        if mem_wb_memToReg = '0' then
            write_back_data <= mem_wb_aluResult;
        else
            write_back_data <= mem_wb_readData;
        end if;
    end process;
	 
	 wb_regwrite_control <= mem_wb_regWrite;
    wb_rd_addr <= mem_wb_rdRegister;
    wb_write_data <= write_back_data;
		
	
					
	 branch_cond_unit : component branch_condition_unit
    port map (
        read_data_1   => id_reg_read_data_1,
        read_data_2   => id_reg_read_data_2,
        funct3        => id_funct3, 
        condition_met => id_branch_condition_met
    );
	 id_take_branch <= id_branch and id_branch_condition_met;
    id_branch_target_addr <= std_logic_vector(signed(id_pc_address) + signed(id_immediate));
	 
end architecture structural;
