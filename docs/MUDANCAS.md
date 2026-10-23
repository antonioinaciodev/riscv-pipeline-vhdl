# Mudanças importantes no projeto — leia antes de compilar

Este documento resume as mudanças feitas na reorganização e correção do projeto.
**Se você trabalhava no projeto antes, a forma de compilar e simular mudou.** Leia as
seções 1 e 2 com atenção.

---

## 1. Nova estrutura de pastas

Os arquivos não ficam mais soltos na raiz. Agora estão organizados assim:

```
riscv-pipeline-vhdl/
├── rtl/          # todos os módulos do processador (.vhd)
├── tb/           # testbenches
├── programs/     # programas de teste (.hex) — um por conjunto de instruções
├── quartus/      # projeto do Quartus (pipeline.qpf, pipeline.qsf)
├── scripts/      # scripts de simulação (sim.do)
├── docs/         # documentação (este arquivo)
├── .gitignore
└── README.md
```

Ao abrir o projeto no Quartus, use **`quartus/pipeline.qpf`**.

---

## 2. Ordem de compilação (MUDOU — importante)

Foi adicionado um **pacote de tipos compartilhado**, `rtl/pipeline_types_pkg.vhd`, que
precisa ser compilado **antes** de todos os outros arquivos. Ele define o tipo do banco
de registradores, usado pelo `register_file.vhd` e pelo testbench.

No Quartus isso é automático (ele resolve a ordem sozinho). **No ModelSim, a ordem importa**:

1. `rtl/pipeline_types_pkg.vhd`  ← primeiro, sempre
2. os demais arquivos de `rtl/`
3. os testbenches de `tb/`

O script `scripts/sim.do` já faz isso na ordem certa — use-o em vez de compilar na mão.

---

## 3. Como simular agora (ModelSim)

No console (Transcript) do ModelSim, a partir da pasta `quartus/`:

```tcl
do ../scripts/sim.do                  # roda o teste padrão (tipo-R)
do ../scripts/sim.do test_itype.hex   # roda o teste de instruções tipo-I
do ../scripts/sim.do test_branch.hex  # roda o teste de branches
do ../scripts/sim.do test_shift.hex   # roda o teste de shifts e comparações
```

O script compila tudo na ordem certa, roda a simulação e **imprime os valores dos
registradores no final**, então você não precisa mais ficar lendo as formas de onda na
mão para conferir o resultado (embora as ondas continuem disponíveis).

### Importante: VHDL-2008

O testbench usa referência hierárquica (`<< signal ... >>`) para ler os registradores
sem precisar de portas extras. Isso exige compilar em **VHDL-2008** (`vcom -2008`), o que
o `sim.do` já faz. Se compilar manualmente em `-93`, vai dar erro no testbench.

---

## 4. Programas de teste em arquivo (.hex)

As instruções de teste **não ficam mais fixas dentro do `instruction_memory.vhd`**.
Agora o `instruction_memory` lê o programa de um arquivo `.hex` em `programs/`, escolhido
na hora da simulação. Cada arquivo tem uma instrução de 32 bits em hexadecimal por linha.

Para criar um teste novo, basta criar um arquivo `.hex` em `programs/` — não precisa mexer
em VHDL nem recompilar o processador. Os testes atuais:

| Arquivo | O que testa | Resultado esperado |
|---|---|---|
| `test_rtype.hex` | add, sub, and, or, xor | x10=8, x11=2, x12=1, x13=7, x14=6 |
| `test_itype.hex` | addi, ori, andi, slli | x10=11, x11=14, x12=40, x13=-1 |
| `test_branch.hex` | beq (branch tomado) | x10=42 (não 99), x11=77 |
| `test_shift.hex` | slli, srli, slti, sltiu | x10=64, x11=8, x12=1, x13=1 |

---

## 5. Correções de design (MUDANÇA DE COMPORTAMENTO)

### 5.1. Banco de registradores agora é RISC-V puro

Antes, o `register_file.vhd` inicializava vários registradores com valores fixos
(herança do modelo Mic-1 do Tanenbaum, de quando estávamos aprendendo) e travava
`x5`–`x9` como constantes. **Isso não é RISC-V.**

Agora segue o padrão RISC-V: **apenas `x0` é especial** (sempre zero). Todos os outros
(`x1`–`x31`) começam em zero e são livres para escrita.

> **Atenção:** se algum teste antigo dependia de `x6=1`, `x7=-1`, `x2=0xFFFF` etc. no
> reset, ele vai se comportar diferente agora. Esses valores não existem mais.

### 5.2. Instruções tipo-I lógicas e de shift agora funcionam

Antes, o controle mandava a ALU **somar** para toda instrução tipo-I. Isso fazia
`addi` funcionar, mas `andi`, `ori`, `xori`, `slli`, etc. davam resultado errado
(somavam em vez de fazer a operação correta). `ori` "parecia" certo por coincidência
em alguns casos.

Foi corrigido em três arquivos, de forma coordenada:
- `main_control.vhd`: tipo-I agora usa `ALUOp = "11"` (antes `"00"`).
- `alu_control.vhd`: decodifica o conjunto tipo-I completo e os shifts/comparações.
- `alu.vhd`: implementa SLL, SRL, SRA, SLT e SLTU (antes só tinha ADD/SUB/AND/OR/XOR).

Agora o processador suporta o conjunto **tipo-I do RV32I** de verdade: addi, andi, ori,
xori, slli, srli, srai, slti, sltiu.

### 5.3. Correções menores

- `branch_condition_unit.vhd`: faltavam `read_data_1`/`read_data_2` na lista de
  sensibilidade do processo, o que causava resultado errado em `BLTU`/`BGEU` na simulação.
- Vários arquivos tinham o nome do arquivo atualizado mas o nome da **entidade** dentro
  ainda antigo (`banco_reg`, `if_id_registrador`, `control`, `forwardingUnit`), e o
  `mem_wb_register` tinha portas com `WEB` em vez de `WB`. Tudo padronizado.

---

## 6. O que ainda falta (limitações conhecidas)

- Instruções de salto (`jal`, `jalr`) e a lógica de `lui`/`auipc` estão parcialmente
  implementadas — conferir antes de usar.
- Não há tratamento de `fence`, `ecall`, `ebreak`.
- O `data_memory.vhd` tem uma linha suspeita no tratamento de escrita de 16 bits na
  parte alta da palavra (`WHEN "1100"`, usa `writeData(15 downto 0)` onde provavelmente
  deveria ser `writeData(31 downto 16)`). Não foi alterado — decidir em grupo.
