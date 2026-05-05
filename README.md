# 🖥️ Processador RISC-V Pipeline (VHDL)

## 📌 Sobre o Projeto
Este repositório contém a implementação em **VHDL** de um processador **RISC-V de 32 bits**, construído com uma arquitetura **Pipeline de 5 estágios**. 

O projeto foi desenvolvido em equipe como trabalho prático para a disciplina de Arquitetura de Computadores (Ciência da Computação - UFPI). O objetivo principal foi aplicar conceitos avançados de design de hardware em baixo nível, explorando o paralelismo em nível de instrução (ILP) e resolvendo conflitos (*hazards*) de dados e controle nativamente no hardware.

## 🧠 Arquitetura Implementada
O caminho de dados (*Datapath*) foi rigorosamente segmentado nos 5 estágios clássicos do RISC-V, com seus respectivos registradores de barreira:

1. **IF (Instruction Fetch):** Busca da instrução (`instruction_memory`, `program_counter`).
2. **ID (Instruction Decode):** Decodificação e leitura de registradores (`register_file`, `if_id_register`, `immediate_generator`).
3. **EX (Execute):** Execução lógica/aritmética (`alu`, `alu_control`, `id_ex_register`).
4. **MEM (Memory Access):** Acesso à memória de dados (`data_memory`, `ex_mem_register`).
5. **WB (Write Back):** Escrita do resultado nos registradores (`mem_wb_register`).

**Módulos de Resolução de Hazards:**
Para lidar com os estolamentos e problemas causados pela arquitetura paralela, foram implementadas as seguintes unidades de controle:
* **Forwarding Unit (`forwarding_unit`):** Resolve *Data Hazards* adiantando dados da saída da ALU (estágio EX/MEM) ou da Memória (estágio MEM/WB) diretamente para a entrada da ALU, evitando pausas desnecessárias.
* **Hazard Detection Unit (`hazard_detection_unit`):** Identifica dependências estritas de leitura/escrita (*Load-Use hazards*) e insere bolhas (*stall* / NOP) no fluxo do pipeline quando o adiantamento não é possível.
* **Branch Condition Unit (`branch_condition_unit`):** Avalia os saltos condicionais em paralelo, otimizando o recálculo do PC.

## ⚙️ Como Executar e Simular
O projeto foi estruturado para ser sintetizado no **Intel Quartus Prime** e simulado no **ModelSim** (ou Questa - Intel FPGA Edition).

### 1. Simulação no ModelSim (Recomendado)
Para visualizar as formas de onda (*Waveforms*) e verificar as instruções rodando ciclo a ciclo no processador:

1. Abra o ModelSim.
2. Crie uma biblioteca de trabalho digitando no console (*Transcript*):
   
```tcl
   vlib work
   ```
3. Compile todos os arquivos `.vhd` do projeto. 
   *(Nota: Compile primeiro os componentes base, depois os registradores, em seguida o Top-Level e por último o Testbench)*:
   ```tcl
   vcom -work work *.vhd
   ```
4. Inicie a simulação utilizando o arquivo de testbench principal (`pipeline_tb.vhd`):
   ```tcl
   vsim work.pipeline_tb
   ```
5. Adicione os sinais de interesse à tela de ondas:
   ```tcl
   add wave -position insertpoint sim:/pipeline_tb/DUT/*
   ```
6. Rode a simulação por um tempo determinado (exemplo: 1000 nanossegundos):
   ```tcl
   run 1000 ns
   ```

*(Importante: O arquivo `data.dat` deve estar no mesmo diretório da simulação para inicializar as memórias com o código de máquina).*

### 2. Síntese no Quartus
1. Abra o Intel Quartus Prime.
2. Vá em `File > Open Project...` e selecione o arquivo **`pipeline.qpf`**.
3. O arquivo `pipeline_toplevel.vhd` já atua como a entidade *Top-Level* do projeto.
4. Clique em **Compile Design** (Ctrl + L) para verificar a sintaxe, gerar a RTL e analisar o consumo de portas lógicas da FPGA.

## 🛠️ Tecnologias Utilizadas
* **Linguagem:** VHDL (*VHSIC Hardware Description Language*)
* **Síntese e Análise RTL:** Intel Quartus Prime
* **Simulação (Testbench & Waveforms):** ModelSim / QuestaSim
