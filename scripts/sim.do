# ============================================================
# Script de simulacao do pipeline RISC-V no ModelSim/Questa
# ------------------------------------------------------------
# Uso (a partir da pasta quartus/ ou scripts/, no console do ModelSim):
#
#   do ../scripts/sim.do                      -> roda o teste padrao (rtype)
#   do ../scripts/sim.do test_itype.hex       -> roda outro programa
#   do ../scripts/sim.do test_branch.hex
#   do ../scripts/sim.do test_shift.hex
#
# O programa e lido de ../programs/<arquivo>.hex pela instruction_memory.
# ============================================================

# Programa de teste: usa o argumento, ou test_rtype.hex por padrao
if {$argc > 0} {
    set PROG "../programs/[lindex $argv 0]"
} else {
    set PROG "../programs/test_rtype.hex"
}
echo "Programa de teste: $PROG"

# Biblioteca de trabalho limpa
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

# ------------------------------------------------------------
# Compilacao. ORDEM IMPORTANTE:
#  1) o pacote de tipos vem primeiro (register_file e o testbench dependem dele)
#  2) depois os modulos RTL
#  3) por fim os testbenches
# VHDL-2008 e exigido pela referencia hierarquica (<< signal ... >>) do testbench.
# ------------------------------------------------------------
vcom -2008 ../rtl/pipeline_types_pkg.vhd

vcom -2008 ../rtl/alu.vhd
vcom -2008 ../rtl/alu_control.vhd
vcom -2008 ../rtl/branch_condition_unit.vhd
vcom -2008 ../rtl/data_memory.vhd
vcom -2008 ../rtl/ex_mem_register.vhd
vcom -2008 ../rtl/forwarding_unit.vhd
vcom -2008 ../rtl/hazard_detection_unit.vhd
vcom -2008 ../rtl/id_ex_register.vhd
vcom -2008 ../rtl/if_id_register.vhd
vcom -2008 ../rtl/immediate_generator.vhd
vcom -2008 ../rtl/instruction_memory.vhd
vcom -2008 ../rtl/main_control.vhd
vcom -2008 ../rtl/mem_wb_register.vhd
vcom -2008 ../rtl/program_counter.vhd
vcom -2008 ../rtl/register_file.vhd
vcom -2008 ../rtl/pipeline_toplevel.vhd

vcom -2008 ../tb/pipeline_tb.vhd

# ------------------------------------------------------------
# Simulacao. Passamos o programa escolhido via -gPROGRAM_FILE.
# A configuration pipeline_tb_cfg liga esse generic a instruction_memory.
# ------------------------------------------------------------
vsim -gPROGRAM_FILE=$PROG work.pipeline_tb_cfg

# Adiciona todos os sinais do processador as formas de onda
add wave -position insertpoint sim:/pipeline_tb/DUT/*

# Roda ate o fim (o testbench para sozinho e imprime os registradores)
run -all

echo "Simulacao concluida. Veja os valores dos registradores no transcript acima."
