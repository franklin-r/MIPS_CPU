#-----------------------------------------------------------------------------
# Project    : SYS808 : Circuits intégrés à très grande échelle
# Ecole de Technologie Superieure 
#-----------------------------------------------------------------------------
# File       : mmmc.tcl
# Author     : Mickael Fiorentino <mickael.fiorentino@polymtl.ca>
# updated by : Hachem Bensalem <hachem.bensalem.1@ens.etsmtl.ca>
# Created    : 2018-06-22
# Last update: 2019-08-10
#-----------------------------------------------------------------------------
# Description: Fichier de configuration "Multi-Mode Multi-Corner"
#              pour le placement et routage du compteur BCD
#-----------------------------------------------------------------------------

set fastlib $::env(FE_TIM_LIB)/fast_vdd1v0_basicCells.lib 

# operating conditions
create_op_cond -name pvt_fast -P 1.0 -V 1.0 -T 25.0 -library_file $fastlib

# library sets
create_library_set -name libs_fast -timing $fastlib -si $::env(BE_CDB_LIB)/fast.cdb

# rc corner
create_rc_corner -name rc_basic -qx_tech_file $::env(BE_QRC_LIB)/gpdk045.tch

# delay corner
create_delay_corner -name fast_basic -library_set libs_fast -rc_corner rc_basic

# constraint mode
create_constraint_mode -name const_mode -sdc_files $::env(CONST_DIR)/mipsCPU.sdc

# analysis view
create_analysis_view -name av_fast -constraint_mode const_mode -delay_corner fast_basic
set_analysis_view -setup av_fast -hold av_fast
