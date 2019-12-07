# BEGIN SETUP
set_db / .information_level 9
set_db / .hdl_vhdl_read_version 2008
set_db / .max_cpus_per_server 4
set_db / .init_hdl_search_path "$::env(SRC_DIR)"

# READ TARGET LIBRARIES
set_db / .init_lib_search_path "$::env(FE_TIM_LIB) \
$::env(BE_QRC_LIB) \
$::env(BE_LEF_LIB)"
read_libs fast_vdd1v0_basicCells.lib
read_physical -lef gsclib045_tech.lef
read_qrc gpdk045.tch
set_db / .interconnect_mode ple
set_db / .hdl_error_on_blackbox true
set_db / .hdl_error_on_latch true

# READ VHDL FILES
read_hdl -vhdl alu.vhd
read_hdl -vhdl registers.vhd
read_hdl -vhdl mux21.vhd
read_hdl -vhdl extender.vhd
read_hdl -vhdl dataMemory.vhd
read_hdl -vhdl processingUnit.vhd
read_hdl -vhdl pc.vhd
read_hdl -vhdl instrMemory.vhd
read_hdl -vhdl instrManagUnit.vhd
read_hdl -vhdl psr.vhd
read_hdl -vhdl instrDecod.vhd
read_hdl -vhdl controlUnit.vhd
read_hdl -vhdl mipsCPU.vhd
elaborate mipsCPU
check_design -unresolved

# SET TIMING CONSTRAINTS
read_sdc $::env(CONST_DIR)/timing.sdc
report_timing -lint > $::env(SYN_REP_DIR)/dft/mipsCPU.timing_lint.rpt

# DEFINE ET PREPARE ENVIRONMENT FOR DFT CHECK RULES
set_db dft_scan_style muxed_scan
define_shift_enable -active high -create_port scan_en
define_test_mode -active high -create_port test_mode
define_test_clock -name clk_scan -domain dom_1 -period 4000 CLK

# RUN DFT RULE CHECKER
set_db design:mipsCPU .dft_min_number_of_scan_chains 1
set_db design:mipsCPU .dft_mix_clock_edges_in_scan_chains true
set_db dft_prefix DFT_
set_db design:mipsCPU .dft_scan_output_preference auto
set_db design:mipsCPU .dft_scan_map_mode tdrc_pass
set_db design:mipsCPU .dft_connect_scan_data_pins_during_mapping high
set_db dft_auto_identify_shift_register true
set_db dft_shift_register_max_length 150
check_dft_rules > reports/dft/dft_rules_report_before_syn.rpt
report_dft_violations > reports/dft/dft_violations_report_before_syn.rpt

# END
puts "Fix violations if any."
puts "See page 7 of tutorials 5 for indications."
puts "Run synthesis.tcl when do"
