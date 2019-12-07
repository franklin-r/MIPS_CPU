# Follow this instructions to realise the design flow of the simple MIPS CPU.

**This flow is made to work for my environment configuration.**
**To follow the flow for yours, just run the .tcl files.**


1.	Go to the root of the project
2. 	Enter 'csh'
3. 	Enter 'source setup.csh'
4. 	Go to implementation/syn
5. 	Enter 'genus'
6. 	Enter 'source dft.tcl'
7. 	Fix violations with the option corresponding to violations described in the report of report_dft_violations
	1.	Use 'fix_dft_violations' with the correct option
	2.	Enter 'check_dft_rules > reports/dft_rules_report_after_syn.rpt'
	3.	Enter 'report_dft_violations > reports/dft_violations_report_after_syn.rpt'
8. 	Enter 'source synthesis.tcl'
	1.	If slack < 0 : modify clock frequency in timing.sdc, dft.tcl,
		power.tcl and mipsCPU_tb.vhd. The current frequency is set to 250 MHz and procide a slack of 1 ps.
9. 	Open a new terminal and go the project's root
10.	Enter 'csh'
11.	Enter 'source setup.csh'
12.	Go to atpg
13. Enter 'modus'
14.	Enter 'source atpg.tcl'
15.	Open a new terminal and go to the project's root
16.	Enter 'csh'
17.	Enter 'source setup.csh'
18.	Go to simulation/syn
19.	Enter './run_full_scan.sh'
20.	Open a new terminal and go to the project's root
21.	Enter 'csh'
22.	Enter 'source setup.csh'
23.	Go to implementation/pnr
24.	Enter 'innovus'
25.	Enter 'source pnr.tcl'
26.	Open a new terminal and go to the simulation folder
27.	Enter 'csh'
28.	Enter 'source /CMC/scripts/mentor.modelsim.10.7a.csh'
29.	Enter 'vsim'
30.	Create a new project with the synthetised design mipsCPU.syn.v and its testbench
31.	Simulate the design
	1.	In Design, select work/mipsCPU_tb
	2.	In Libraries, select Add and library /CMC/kits/GPDK045/simlib/gsclib045
	3.	In SDF, select Add and mipsCPU.syn.sdf in implementation/syn/netlist/mipsCPU.syn.sdf. Apply to region, enter UUT. 
		Select typical delay and timeresolution ps.
32.	Start simulation, but do not run.
33.	Create the vcd file : Enter 'vcd file ../pnr/mipsCPU.pnr.vcd' in the Modelsim command line
34.	Add signals to save : Enter 'vcd add /mipsCPU_tb/UUT/*' in the Modelsim command line
35.	Run simulation : Enter 'run -all' in the Modelsim command line
36.	Save activity : Enter 'vcd flush' in the Modelsim command line
37.	Open a new terminal and go to the project's root 
38.	Enter 'csh'
39.	Enter 'source setup.csh'
40.	Go to implementation/pnr
41.	Enter 'voltus'
42.	Enter 'source power.tcl'

# Comments
Each module can be simulated individually with the .do scripts in the dource folder.
1. 	In Modelsim, go to File and Change directory... Select the project's directory.
2. 	Enter 'do ../simu/simu_script.do' where 'simu_script.do' is the name of the script to run.
	e.g. To run alu_tb.vhd, enter 'do ../simu/simu_alu.do'
