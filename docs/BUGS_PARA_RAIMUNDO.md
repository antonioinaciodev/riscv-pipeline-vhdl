# Bugs do pipeline RV32I: divisão de trabalho

Base: commit `5867ec8` de `riscv-pipeline-vhdl`. Todos os bugs abaixo foram **confirmados por simulação** (GHDL, `--std=08 -fsynopsys`), exceto o item B7, que é spec e ainda não tem teste. Valores de instrução em binário. FENCE, ECALL e EBREAK virando NOP é **intencional**, não é bug.

## Como reproduzir
Pasta `testes/` (ao lado de `riscv-pipeline-vhdl/`). Precisa de Docker e Python. Não verifiquei se funciona em outra máquina além da do João.
```
powershell -ExecutionPolicy Bypass -File .\testes\rodar_testes.ps1            # todos
powershell -ExecutionPolicy Bypass -File .\testes\rodar_testes.ps1 -Teste E01 # um só
```
Saída: `testes/resultados/RESULTADOS.md` (programa em binário, esperado vs obtido) e ondas em `testes/ondas/<TESTE>.vcd|.ghw`. Quando o bug estiver corrigido, o teste correspondente deve passar a dar PASS (hoje dá CONFIRMADO).

## Especificação de bolhas (aula teórica)
Branch e JALR são resolvidos em ID. Penalidade esperada:

| Situação | Stalls | Flush | Total se salta | Total se não salta |
|---|---|---|---|---|
| Produtor 2+ instruções antes (ALU ou lw) | 0 | 1 | 1 | 0 |
| Produtor ALU 1 instrução antes | 1 | 1 | 2 | 1 |
| Produtor `lw` 1 instrução antes | 2 | 1 | 3 | 2 |
| Produtor `lw` 2 instruções antes | 1 | 1 | 2 | 1 |

O código atual **não segue isso** (ver A3). O `lw` no destino do salto não gera bolha extra; só gera se a instrução seguinte consumir o valor (stall de 1 ciclo de load-use, que já existe).

## Divisão proposta
- **Bloco A: forwarding, hazard e branch.** Arquivos: `forwarding_unit.vhd`, `hazard_detection_unit.vhd`, `branch_condition_unit.vhd`. Toca `pipeline_toplevel.vhd` só nas ligações do caminho de branch/JALR.
- **Bloco B: memória, link e imediatos longos.** Arquivos: `data_memory.vhd`, `mem_wb_register.vhd`, `main_control.vhd`, `id_ex_register.vhd`, `ex_mem_register.vhd`, `alu_control.vhd`. Toca `pipeline_toplevel.vhd` no estágio MEM/WB e no mux da ALU.

**Conflito provável: `pipeline_toplevel.vhd`.** Os dois mexem nele. Sugestão: cada um em uma branch, commits pequenos, e `git pull --rebase` antes de cada push.
**Ordem:** B1 (LW) antes de tudo, porque os testes E02, E09, E10 e E11 dependem dele para sair do vermelho.

---

## BLOCO A: forwarding, hazard e branch

### A1. Forwarding com prioridade invertida (teste E01)
- `rtl/forwarding_unit.vhd:51-61` e `:64-74`. O teste de MEM/WB vem depois do de EX/MEM e sobrescreve o `01` com `10`.
- Programa: `addi x1,x0,1; addi x1,x0,2; add x2,x1,x0` sem NOPs. Esperado `x2 = 00000000000000000000000000000010`; obtido `00000000000000000000000000000001`.
- Correção: só aceitar o forward de MEM/WB se o de EX/MEM não acertou o mesmo registrador.

### A2. Ramo de load descarta o forwarding de MEM/WB (teste E02)
- `rtl/forwarding_unit.vhd:38-75`. Se `ex_mem_memRead='1'`, o `else` com `01`/`10` não executa.
- Programa: `add x3,..; lw x5,..; sub x4,x3,..`. Quando o `lw` está em MEM, o `add` está em WB e x3 não é encaminhado. Obtido x4 = -3, esperado 5.
- Atenção: o E02 também depende do LW funcionar (B1).

### A3. Branch e JALR sem forwarding e sem stalls corretos (teste E03; falta teste para `lw`→branch)
- `rtl/pipeline_toplevel.vhd:187` (JALR) e `:362-363` (branch): leem o banco direto em ID.
- Confirmado: com 0 e 1 NOP entre o produtor e o `beq`, o resultado está errado; com 2 e 3 NOPs está certo. Os `.hex` do repositório têm 2 NOPs antes do `beq`, o que esconde isso.
- Implementar a tabela de bolhas acima: `hazard_detection_unit` precisa saber que a instrução em ID é branch/JALR e comparar `rd` de ID/EX (ALU: 1 stall) e de EX/MEM (`lw`: segundo stall). Ou, alternativa, forwarding de EX/MEM e MEM/WB para o comparador de branch.
- Hoje, `lw` seguido de `beq` dependente: a unidade dá 1 stall (compara qualquer instrução em ID) e depois o `beq` resolve lendo o valor antigo. Resultado: 2 bolhas com dado errado, quando deveriam ser 3 com dado certo (pela análise do código; falta teste, sugiro criar o E12).

### A4. BLT e BGE erram com overflow (teste E08)
- `rtl/branch_condition_unit.vhd:23,25,46-55`: usam o sinal de `a-b`.
- `a = 01111111111111111111111111111111`, `b = 11111111111111111111111111111111`. `blt a,b` NÃO deve saltar, mas salta; `bge a,b` deve saltar e não salta.
- Correção: comparar `signed(a) < signed(b)` direto.

---

## BLOCO B: memória, link e imediatos longos

### B1. LW devolve o dado errado (teste E09; também afeta E02, E10, E11)
- `rtl/data_memory.vhd:38-60` registra `readData` na borda de subida, e `rtl/mem_wb_register.vhd` registra de novo na mesma borda. O load recebe o dado do ciclo anterior.
- E09: SW grava certo, LW devolve `00000000000000000000000000000000`. Em loads seguidos, cada um recebe o dado do load anterior.
- A causa é inferência a partir do comportamento, não foi isolada em onda. Correção provável: leitura combinacional na data_memory, ou tirar um dos dois registros.

### B2. JAL e JALR não gravam PC+4 em rd (testes E04, E05, E05d)
- `rtl/main_control.vhd:58-67`. `id_pc_plus_4` (`pipeline_toplevel.vhd:85`) é declarado e nunca usado.
- E04 `jal x1,+8`: esperado `x1` = endereço do `jal` + 4; obtido `00000000000000000000000000000000`.
- E05 `jalr x1,0(x5)`: `x1` recebe o alvo, não PC+4. O salto e o bit 0 zerado estão **corretos**. `jalr x0,0(x1)` funciona.
- Precisa levar PC+4 até o WB (mux de write-back) ou até a ALU. Ver também B6 (ALUOp de JAL).

### B3. LUI soma o campo rs1 (teste E06)
- `rtl/main_control.vhd:54-57` usa ALUOp `00`, que soma rs1 + imm. O campo `[19:15]` da LUI é parte do imediato e é lido como registrador.
- Obtido `x1 = imm<<12 + x8`. Esperado: só `imm<<12`. A entrada A da ALU precisa ser zero para LUI.

### B4. AUIPC soma rs1 em vez do PC (teste E07)
- `rtl/main_control.vhd:61-62`. O ID/EX (`id_ex_register.vhd`) não carrega o PC.
- Esperado `PC + (imm<<12)`. Precisa levar o PC até EX e selecionar o PC na entrada A da ALU.
- B3 e B4 mexem no mesmo ponto (mux da entrada A da ALU), então convém fazer juntos.

### B5. Stores e loads de byte e halfword (testes E10, E11)
- `rtl/pipeline_toplevel.vhd:323`: `byte_enable <= "1111"` fixo. `data_memory.vhd` já trata `0001`, `0010`, `0100`, `1000`, `0011` e `1100` (`:43-52`), mas ninguém o alimenta. `funct3` chega a `ex_mem_funct3` e não é usado.
- E10: SB/SH gravam a palavra inteira (memória final `00000000000000000000011001111000`, esperado `10011001011110000101011001111000`).
- E11: LB, LH, LBU e LHU devolvem a palavra inteira, sem seleção de byte e sem extensão de sinal ou zero.
- Falta: gerar `byteEN` a partir de `funct3` e `address[1:0]` (store), e selecionar byte/half com extensão (load), usando `funct3`.
- Atenção: há uma linha suspeita em `data_memory.vhd` (caso `"1100"`, `writeData(15 downto 0)`) já avisada em `docs/MUDANCAS.md`.

### B6. ALUOp indefinido ("XX") em JAL e opcodes não reconhecidos
- `rtl/main_control.vhd:34` e `:58-60`. O JAL escreve valor indefinido na ALU (na simulação, deu 0 em rd). Atribuir ALUOp explícito no default e no JAL.

---

## Itens de infraestrutura (qualquer um, sem pressa)
- `tb/pipeline_tb.vhd` não tem `assert`; a checagem é um `grep -F` por substring em `run_tests.sh` ("x10 = 8" casa com "x10 = 80").
- `pipeline_types_pkg.vhd` não está no `quartus/pipeline.qsf`; o Quartus provavelmente falha. A leitura de `.hex` na `instruction_memory` provavelmente não sintetiza.
- `test_shift.hex`: o `srai` lê `x7=0`, então não testa SRAI. `test_branch.hex` só cobre um `beq` tomado.
- README lista `lw`, `sw` e `sll/srl/sra/slt/sltu` como suportadas sem teste.
- `docs/MUDANCAS.md` diz que `forwarding_unit` foi corrigido, mas o arquivo não mudou desde `13e772f`.

## Definição de pronto
`rodar_testes.ps1` dando PASS em T00 e em todos os E##, mais um novo teste (E12) para `lw` seguido de `beq` com a tabela de bolhas.
