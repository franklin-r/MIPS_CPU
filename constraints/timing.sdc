#-----------------------------------------------------------------------------
# Project    : SYS808 : Circuits intégrés à très grande échelle
# Ecole de Technologie Superieure  
#-----------------------------------------------------------------------------
# File       : timing.sdc
# Author     : Mickael Fiorentino <mickael.fiorentino@polymtl.ca>
# updated by : Hachem Bensalem <hachem.bensalem.1@ens.etsmtl.ca>
# Created    : 2018-06-22
# Last update: 2019-08-07
#-----------------------------------------------------------------------------
# Description: Fichier de contraintes
#-----------------------------------------------------------------------------

# Unités par défaut
set_time_unit -picoseconds
set_load_unit -femtofarads

# Point de fonctionnement
set_db / .operating_conditions PVT_1P1V_0C

# Horloge principale: 250MHz
set clk "clk"
create_clock -period 4000 -name $clk [get_ports CLK]

# Incertitudes sur l'horloge: setup = 100ps, hold = 30ps 
set_db [get_clocks $clk] .clock_setup_uncertainty 100
set_db [get_clocks $clk] .clock_hold_uncertainty  30

# Entrées
set_input_delay 300 -clock [get_clocks $clk] [all_inputs]
set_db [all_inputs] .external_driver [vfind [vfind / -libcell BUFX20] -libpin Y]

# Sorties
set_output_delay 300 -clock [get_clocks $clk] [all_outputs]
set_db [all_outputs] .external_pin_cap 1000
