# Guia das issues: por onde começar

Repositório: https://github.com/antonioinaciodev/riscv-pipeline-vhdl
Detalhes técnicos de cada bug (arquivo, linha, esperado vs obtido): `BUGS_PARA_RAIMUNDO.md` e o texto de cada issue.
Como rodar os testes e ver as ondas: `testes/COMO_TESTAR.md` (precisa de Docker Desktop, Python e a extensão Surfer do VS Code).

## Blocos

Os blocos dividem o trabalho por área, para duas pessoas mexerem em arquivos diferentes.

| Bloco | Área | Issues | Arquivos principais |
|---|---|---|---|
| **A** | forwarding, hazard e branch | #8, #9, #10, #11, #12 | `forwarding_unit.vhd`, `hazard_detection_unit.vhd`, `branch_condition_unit.vhd` |
| **B** | memória, link e imediatos longos | #7, #13, #14, #15, #16, #17 | `data_memory.vhd`, `mem_wb_register.vhd`, `main_control.vhd`, `id_ex_register.vhd`, `ex_mem_register.vhd`, `alu_control.vhd` |
| infra | sem bloco | #18, #19, #20 | testbench, `.qsf`, testes e docs |

`pipeline_toplevel.vhd` é mexido pelos dois blocos e é onde os conflitos devem aparecer.

## Código antigo → número da issue

| Código em `BUGS_PARA_RAIMUNDO.md` | Issue | Teste |
|---|---|---|
| A1 | #8 | E01 |
| A2 | #9 | E02 |
| A3 | #10 | E03 |
| A4 | #11 | E08 |
| (teste novo) | #12 | E12 |
| B1 | #7 | E09 |
| B2 | #13 | E04, E05, E05d |
| B3 | #14 | E06 |
| B4 | #15 | E07 |
| B5 | #16 | E10, E11 |
| B6 | #17 | (sem teste) |

## Dependências

| Issue | Depende de | Motivo |
|---|---|---|
| **#7** (LW) | nenhuma | **Fazer primeiro.** |
| #9 | #7 | o teste E02 usa `lw` |
| #16 | #7 | os testes E10 e E11 usam `lw` |
| #12 | #7 e #10 | usa `lw` e só passa com os stalls corretos |
| #10 | #7, só no caso `lw` → branch | os casos com instrução de ALU não dependem |
| #14 e #15 | uma da outra (leve) | mexem no mesmo mux da ALU; convém fazer juntas |
| #13 e #17 | uma da outra (leve) | ambas mexem no JAL em `main_control.vhd` |

Podem começar já, sem esperar ninguém: #8, #11, #13, #14, #15 e as de infra.

## Ordem sugerida
1. **#7** (LW).
2. Em paralelo: Bloco A com #8 e #11; Bloco B com #13, #14 e #15.
3. Depois: #9, #10, #16 e #17.
4. Por último: #12.

## Como trabalhar
- Uma branch por issue (`fix/nome-curto`) e commits pequenos.
- `git pull --rebase` antes de cada push.
- No PR, escreva `Closes #n` no corpo para fechar a issue automaticamente.
- Antes de abrir o PR, rode **todos** os testes: o teste da issue deve dar `PASS` e nenhum outro pode piorar.
- Valores de instrução e de teste sempre em **binário**.
- FENCE, ECALL e EBREAK virarem NOP é intencional, não é bug.

## Pronto quando
`rodar_testes.ps1` der PASS em T00 e em todos os E##, incluindo o novo E12.
