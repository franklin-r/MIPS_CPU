# LIBRARY SETUP
set init_oa_ref_lib [list gsclib045_tech gsclib045 gpdk045 giolib045]
set init_verilog $::env(SYN_NET_DIR)/mipsCPU.syn.v
set init_design_settop 1
set init_top_cell mipsCPU
set init_gnd_net VSS
set init_pwr_net VDD
set init_mmmc_file $::env(CONST_DIR)/mmmc.tcl
init_design

# FLOORPLAN
floorPlan -site CoreSite -r 1.0 0.6 1 1 1 1

# POWER
globalNetConnect VDD -type pgpin -pin VDD -inst * -override
globalNetConnect VSS -type pgpin -pin VSS -inst * -override
globalNetConnect VDD -type tiehi -inst * -override
globalNetConnect VSS -type tielo -inst * -override
addStripe -nets VDD -layer Metal1 -direction vertical -width 0.6 \
-number_of_sets 1 -start_from left -start_offset -0.8
addStripe -nets VSS -layer Metal1 -direction vertical -width 0.6 \
-number_of_sets 1 -start_from right -start_offset -0.8
sroute -nets { VDD VSS } -connect { corePin floatingStripe }

# INPUTS/OUTPUTS
setPinAssignMode -pinEditInBatch true
editPin -start 2 9 -end 10 9 -pin [list CLK RST scan_en test_mode tdi] \
-side Top -layer 2 -spreadType range -spreadDirection clockwise
editPin -start 1 0 -end 80 0 -pin [list DummyOut[0] DummyOut[1] DummyOut[2] DummyOut[3] DummyOut[3] DummyOut[5] DummyOut[6] DummyOut[7] DummyOut[8] DummyOut[9] DummyOut[10] DummyOut[11] DummyOut[12] DummyOut[13] DummyOut[14] DummyOut[15] DummyOut[16] DummyOut[17] DummyOut[18] DummyOut[19] DummyOut[20] DummyOut[21] DummyOut[22] DummyOut[23] DummyOut[24] DummyOut[25] DummyOut[26] DummyOut[27] DummyOut[28] DummyOut[29] DummyOut[30] DummyOut[31] tdo] \
-side Bottom -layer 2 -spreadType range -spreadDirection counterclockwise

# PLACE
specifyScanChain chain1 -start tdi -stop tdo
setPlaceMode -place_global_ignore_scan true
setScanReorderMode -skipMode skipNone
setDesignMode -process 45
place_opt_design

# CLOCK TREE SYNTHESIS
optDesign -preCTS
set_ccopt_property buffer_cells [list CLKBUFX20 CLKBUFX16 CLKBUFX12 \ CLKBUFX8 CLKBUFX6 CLKBUFX4 CLKBUFX3 CLKBUFX2]
set_ccopt_property inverter_cells [list CLKINVX20 CLKINVX6 CLKINVX8 \
CLKINVX16 CLKINVX12 CLKINVX4 CLKINVX3 CLKINVX2 CLKINVX1]
set_ccopt_property use_inverters true
ccopt_design
optDesign -postCTS

# ROUTING
setNanoRouteMode -quiet -routeWithTimingDriven true
routeDesign -globalDetail
addFiller -cell FILL32 FILL16 FILL8 FILL4 FILL2 FILL1 -prefix FILLER

# DRC CHECKING
set_verify_drc_mode -report $::env(PNR_REP_DIR)/mipsCPU.drc.rpt
verify_drc
puts "Check the DRC report."

# STA CHECKING
setAnalysisMode -analysisType onChipVariation
report_timing > $::env(PNR_REP_DIR)/mipsCPU.tim.rpt
puts "Check the STA report."

# AREA REPORTING
report_area > $::env(PNR_REP_DIR)/mipsCPU.area.rpt

puts "If any constraints is not met, restart at the needed step."

# SAVE
createLib liboa -attachTech gsclib045_tech
saveDesign -cellview {liboa mipsCPU layout}

# END
puts "End of PNR."
puts "Open a new terminal and go to implementation/pnr."
puts "Start Voltus and run power.tcl."









