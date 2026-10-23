#!/usr/bin/env bash
# Script de testes automatizado - roda todos os programas e confere os resultados.
# Usado tanto localmente quanto no CI (GitHub Actions).
set -e

STD="--std=08 -fsynopsys -C"
WORK=work_ci
rm -rf $WORK && mkdir -p $WORK

echo "==> Compilando..."
ghdl -a $STD --workdir=$WORK rtl/pipeline_types_pkg.vhd
ghdl -a $STD --workdir=$WORK rtl/alu.vhd rtl/alu_control.vhd rtl/branch_condition_unit.vhd \
    rtl/data_memory.vhd rtl/ex_mem_register.vhd rtl/forwarding_unit.vhd \
    rtl/hazard_detection_unit.vhd rtl/id_ex_register.vhd rtl/if_id_register.vhd \
    rtl/immediate_generator.vhd rtl/instruction_memory.vhd rtl/main_control.vhd \
    rtl/mem_wb_register.vhd rtl/program_counter.vhd rtl/register_file.vhd \
    rtl/pipeline_toplevel.vhd
ghdl -a $STD --workdir=$WORK tb/pipeline_tb.vhd
ghdl -e $STD --workdir=$WORK pipeline_tb_cfg

# Funcao que roda um teste e confere se a saida contem os valores esperados
check() {
    local prog=$1; shift
    echo "==> Teste: $prog"
    out=$(ghdl -r $STD --workdir=$WORK pipeline_tb_cfg \
          -gPROGRAM_FILE=programs/$prog --stop-time=400ns 2>/dev/null)
    echo "$out" | grep -E 'x[0-9]+ ='
    for expected in "$@"; do
        if ! echo "$out" | grep -qF "$expected"; then
            echo "    FALHOU: esperava '$expected' e nao encontrei"
            exit 1
        fi
    done
    echo "    OK"
}

check test_rtype.hex  "x10 = 8" "x11 = 2" "x12 = 1" "x13 = 7" "x14 = 6"
check test_itype.hex  "x10 = 11" "x11 = 14" "x12 = 40" "x13 = -1"
check test_branch.hex "x10 = 42" "x11 = 77"
check test_shift.hex  "x10 = 64" "x11 = 8" "x12 = 1" "x13 = 1"

echo ""
echo "======================================"
echo "  TODOS OS TESTES PASSARAM"
echo "======================================"
