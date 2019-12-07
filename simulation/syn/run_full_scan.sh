export WORKDIR=$PROJECT_HOME/atpg
irun \
+access+rwc \
+ncstatus \
+nc64bit \
+TESTFILE1=$WORKDIR/testresults/verilog/FULLSCAN_PARALLEL/VER.FULLSCAN.data.scan.ex1.ts1.verilog \
+TESTFILE2=$WORKDIR/testresults/verilog/FULLSCAN_PARALLEL/VER.FULLSCAN.data.logic.ex1.ts2.verilog \
+HEARTBEAT \
+FAILSET \
+nctimescale+1ns/1ps \
+ncoverride_timescale \
+ncseq_udp_delay+2ps \
+libext+.v+.V+.z+.Z+.gz \
+nclibdirname+$WORKDIR/Inca_libs_15_06_19 \
-l $WORKDIR/ncverilog_FULLSCAN.log \
-v /CMC/kits/GPDK045/gsclib045_svt_v4.4/gsclib045/verilog/fast_vdd1v0_basicCells.v \
$WORKDIR/mipsCPU.test_netlist.v \
$WORKDIR/testresults/verilog/FULLSCAN_PARALLEL/VER.FULLSCAN.mainsim.v

