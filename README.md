# Processador RISC-V Pipeline (VHDL)

![tests](https://github.com/antonioinaciodev/riscv-pipeline-vhdl/actions/workflows/ci.yml/badge.svg)

Implementação em **VHDL** de um processador **RISC-V de 32 bits (RV32I)** com
arquitetura **pipeline de 5 estágios**, com resolução de *hazards* de dados e de
controle em hardware.

Projeto desenvolvido em equipe para a disciplina de Tópicos em Arquitetura de Computadores
(Ciência da Computação – UFPI).

> **Começando agora no projeto?** Leia primeiro [`docs/MUDANCAS.md`](docs/MUDANCAS.md),
> que explica a estrutura de pastas, a ordem de compilação e as decisões de design.

---

## Arquitetura

O caminho de dados é segmentado nos 5 estágios clássicos, com registradores de barreira
entre eles:

| Estágio | Função | Módulos |
|---|---|---|
| **IF** | Busca da instrução | `program_counter`, `instruction_memory` |
| **ID** | Decodificação e leitura de registradores | `register_file`, `main_control`, `immediate_generator`, `if_id_register` |
| **EX** | Execução lógica/aritmética | `alu`, `alu_control`, `id_ex_register` |
| **MEM** | Acesso à memória de dados | `data_memory`, `ex_mem_register` |
| **WB** | Escrita no banco de registradores | `mem_wb_register` |

**Resolução de hazards:**
- `forwarding_unit` — adianta resultados da ALU/memória para evitar paradas em *data hazards*.
- `hazard_detection_unit` — insere bolhas (*stall*) em *load-use hazards* que o forwarding não cobre.
- `branch_condition_unit` — avalia saltos condicionais.

---

## Instruções suportadas (RV32I)

| Tipo | Instruções |
|---|---|
| **R** | `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`, `slt`, `sltu` |
| **I** | `addi`, `andi`, `ori`, `xori`, `slli`, `srli`, `srai`, `slti`, `sltiu` |
| **Load/Store** | `lw`, `sw` |
| **Branch** | `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu` |

Limitações conhecidas (em desenvolvimento): saltos (`jal`, `jalr`) e `lui`/`auipc`
parcialmente implementados; sem `fence`/`ecall`/`ebreak`. Veja `docs/MUDANCAS.md`.

---

## Estrutura do repositório

```
riscv-pipeline-vhdl/
├── rtl/          # módulos do processador (.vhd)
├── tb/           # testbenches
├── programs/     # programas de teste (.hex)
├── quartus/      # projeto do Quartus (pipeline.qpf, pipeline.qsf)
├── scripts/      # script de simulação do ModelSim (sim.do)
├── docs/         # documentação
└── run_tests.sh  # roda todos os testes (usado pelo CI)
```

---

## Como simular

### Opção 1 — ModelSim / Questa (visual, com formas de onda)

No console (*Transcript*) do ModelSim, a partir da pasta `quartus/`:

```tcl
do ../scripts/sim.do                  # teste padrão (tipo-R)
do ../scripts/sim.do test_itype.hex   # instruções tipo-I
do ../scripts/sim.do test_branch.hex  # branches
do ../scripts/sim.do test_shift.hex   # shifts e comparações
```

O script compila tudo na ordem certa, roda a simulação e imprime os valores finais dos
registradores no transcript. As formas de onda ficam disponíveis para inspeção.

> O testbench usa VHDL-2008 — o `sim.do` já compila com `vcom -2008`.

### Opção 2 — GHDL (linha de comando, sem interface)

Com o [GHDL](https://github.com/ghdl/ghdl) instalado, na raiz do repositório:

```bash
bash run_tests.sh
```

Compila, roda os quatro testes e confere automaticamente se os resultados batem com o
esperado. É o mesmo script que o CI executa.

---

## Síntese no Quartus

1. Abra o Intel Quartus Prime.
2. `File > Open Project...` e selecione **`quartus/pipeline.qpf`**.
3. A entidade top-level é `pipeline_toplevel`.
4. **Compile Design** (Ctrl + L).

---

## Testes

Os programas de teste ficam em `programs/`, um arquivo `.hex` por conjunto de instruções
(uma instrução de 32 bits em hexadecimal por linha). O `instruction_memory` carrega o
programa escolhido na hora da simulação, então criar um teste novo é criar um `.hex` —
sem recompilar o processador.

| Programa | Testa | Resultado esperado |
|---|---|---|
| `test_rtype.hex` | add, sub, and, or, xor | x10=8, x11=2, x12=1, x13=7, x14=6 |
| `test_itype.hex` | addi, ori, andi, slli | x10=11, x11=14, x12=40, x13=-1 |
| `test_branch.hex` | beq (tomado) | x10=42, x11=77 |
| `test_shift.hex` | slli, srli, slti, sltiu | x10=64, x11=8, x12=1, x13=1 |

A cada *push* ou *pull request*, o GitHub Actions roda todos esses testes automaticamente
(veja o selo no topo).

---

## Tecnologias

- **Linguagem:** VHDL
- **Síntese:** Intel Quartus Prime
- **Simulação:** ModelSim / Questa e GHDL
- **CI:** GitHub Actions
