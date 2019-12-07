# BUILD MODEL
build_model \
-cell mipsCPU \
-techlib /CMC/kits/GPDK045/gsclib045_svt_v4.4/gsclib045/verilog/*.v \
-designsource $::env(SYN_NET_DIR)/mipsCPU.syn.v \
-blackboxoutputs z \
-allowmissingmodules no \
check_log log_build_model

# BUILD AND VERIFY TEST MODE
build_testmode \
-testmode FULLSCAN \
-assignfile mipsCPU.FULLSCAN.pinassign \
-modedef FULLSCAN \
-delaymode zero \
check_log log_build_testmode_FULLSCAN
report_test_structures \
-testmode FULLSCAN \
-reportscanchain all
verify_test_structures \
-testmode FULLSCAN \
-xclockanalysis yes \
-testxsource yes

# BUILD FAULT MODEL
build_faultmodel \
-includedynamic no \
check_log log_build_faultmodel
analyze_testability \
-testmode FULLSCAN \
check_log log_analyze_testability_FULLSCAN

# CREATE AND COMMIT LOGIC TEST
create_logic_tests \
-testmode FULLSCAN \
-experiment logic
create_sequential_tests \
-testmode FULLSCAN \
-experiment logic \
-append yes
commit_tests \
-testmode FULLSCAN \
-inexperiment logic

puts "Check the fault coverage file."
puts "Location : /atpg/testresults/logs"
puts "Name starts with \"log_create_sequential_tests_FULLSCAN_logic\""

# WRITE VECTOR
write_vectors \
-testmode FULLSCAN \
-language verilog \
-scanformat parallel \
-exportdir testresults/verilog/FULLSCAN_PARALLEL \
-logfile testresults/logs/log_write_vectors_verilog_parallel_FULLSCAN

# END
puts "End of ATPG."
puts "Open a new terminal and go to simulation/syn."
puts "Do ./run_full_scan.sh to test the vectors."
