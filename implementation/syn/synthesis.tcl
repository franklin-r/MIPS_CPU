# DESIGN SYNTHESIS
report_scan_setup > reports/synthesis/scan_setup.rpt
set_db / .syn_generic_effort high
ungroup -all -simple
syn_generic mipsCPU
check_dft_rules > reports/synthesis/dft_rules.rpt
set_db / .syn_map_effort high
syn_map mipsCPU

# DEFINE SCAN CHAINS
define_scan_chain -name chain1 -create_ports -sdi tdi -sdo tdo
set_db design:mipsCPU .dft_min_number_of_scan_chains 1
set_db design:mipsCPU .dft_mix_clock_edges_in_scan_chains true

# CONNECT SCAN CHAINS
# connect_scan_chains -auto_create_chains -preview
connect_scan_chains -auto_create_chains
set_db / .syn_opt_effort high
syn_opt mipsCPU

# GENERATE REPORTS AND FILES TO EXPORT
write_hdl > $::env(SYN_NET_DIR)/mipsCPU.syn.v
write_sdc > $::env(CONST_DIR)/mipsCPU.sdc
write_scandef > $::env(SYN_NET_DIR)/mipsCPU.sdf
report_area > $::env(SYN_REP_DIR)/synthesis/mipsCPU.syn.opt.area.rpt
report_gates > $::env(SYN_REP_DIR)/synthesis/mipsCPU.syn.opt.gates.rpt
report_power > $::env(SYN_REP_DIR)/synthesis/mipsCPU.syn.opt.power.rpt
report_timing > $::env(SYN_REP_DIR)/synthesis/mipsCPU.syn.opt.timing.rpt
report_scan_setup > $::env(SYN_REP_DIR)/synthesis/mipsCPU.syn.opt.scan_setup.rpt
report_scan_chains > $::env(SYN_REP_DIR)/synthesis/mipsCPU.syn.opt.scan_chains.rpt
report_scan_registers > $::env(SYN_REP_DIR)/synthesis/mipsCPU.syn.opt.scan_registers.rpt
report_memory > $::env(SYN_REP_DIR)/synthesis/mipsCPU.syn.opt.memory.rpt
report_clocks > $::env(SYN_REP_DIR)/synthesis/mipsCPU.syn.opt.clocks.rpt
write_dft_atpg mipsCPU -library /CMC/kits/GPDK045/gsclib045_svt_v4.4/gsclib045/verilog/*.v \
-build_testmode_options FULLSCAN \
-directory $::env(PROJECT_HOME)/atpg
write_dft_abstract_model -ctl > dft_abstract_model
write_dft_atpg_other_vendor_files -stil > atpg

# END
puts "End of synthesis."
puts "Open a new terminal and go to the atpg folder."
puts "Start Modus and run atpg.tcl for ATPG."
