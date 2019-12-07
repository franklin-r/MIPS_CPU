# SETUP
read_design -cellview [list liboa mipsCPU layout] -physical_data
set_pg_library_mode -extraction_tech_file $::env(BE_QRC_LIB)/gpdk045.tch \
-celltype techonly -default_area_cap 0.5 \
-decap_cells DECAP* -filler_cells FILL* \
-power_pins {VDD 1.1} -ground_pins VSS
generate_pg_library -output $::env(PNR_REP_DIR)/power

# STATIC METHOD
set_power_analysis_mode -reset
set_power_analysis_mode -method static -analysis_view av_fast -corner max
set_default_switching_activity -reset
set_default_switching_activity -input_activity 0.2 -period 4.0
report_power -output $::env(PNR_REP_DIR)/power \
-format detailed -report_prefix mipsCPU_stat

#DYNAMIC METHOD
set_power_analysis_mode -reset
set_power_analysis_mode -method dynamic_vectorbased \
-analysis_view av_fast -corner max \
-power_grid_library reports/power/techonly.cl \
-report_stat true \
-enable_rtl_vectorbased_dynamic_analysis true \
-create_binary_db true \
-disable_static false \
-write_static_currents true \
-report_missing_flop_outputs false
set_default_switching_activity -reset
read_activity_file -format VCD $::env(SIM_PNR_DIR)/mipsCPU.pnr.vcd \
-scope mipsCPU_tb/UUT -start 0 -end 240
report_power -output $::env(PNR_REP_DIR)/power \
-format detailed -report_prefix mipsCPU_dyn

# END
puts "End of PNR."
puts "End of design flow."
puts "Check everything went well."
