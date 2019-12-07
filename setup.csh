#!/usr/bin/env tcsh
#-----------------------------------------------------------------------------
# Project    : SYS808 : Circuits intégrés à très grande échelle
# Ecole de Technologie Superieure 
#-----------------------------------------------------------------------------
# File       : setup.csh
# Author     : Mickael Fiorentino <mickael.fiorentino@polymtl.ca>
# updated by : Hachem Bensalem <hachem.bensalem.1@ens.etsmtl.ca>
# Created    : 2018-06-19
# Last update: 2019-08-01
#-----------------------------------------------------------------------------
# Description: Script de configuration de l'environnement
#              + Environnement CMC
#              + Hiérarchie du projet
#              + kit GPDK045
#              + Outils Cadence & Mentor 
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# CONFIGURATION                                                         
#-----------------------------------------------------------------------------

setenv CMC_CONFIG   "/CMC/scripts/cmc.2017.12.csh"
setenv PROJECT_HOME `pwd` 

# setup.csh doit être lancé depuis la racine du projet
if ( ! -f ${PROJECT_HOME}/setup.csh ) then
    echo "ERROR: setup.csh doit être lancé depuis la racine du projet"
    exit 1
endif

# Vérification de l'environnment CMC
if ( ! -f ${CMC_CONFIG} ) then
    echo "ERROR: L'environnement n'est pas configuré pour les outils de CMC"
    exit 1
endif

source ${CMC_CONFIG}

#-----------------------------------------------------------------------------
# HIERARCHIE DU PROJET                                                    
#-----------------------------------------------------------------------------

# Global
setenv SRC_DIR      ${PROJECT_HOME}/sources
setenv CONST_DIR    ${PROJECT_HOME}/constraints
setenv SIM_DIR      ${PROJECT_HOME}/simulation
setenv IMP_DIR      ${PROJECT_HOME}/implementation
setenv DOC_DIR      ${PROJECT_HOME}/../doc
setenv SCRIPTS_DIR  ${PROJECT_HOME}/scripts

# Simulations
setenv SIM_BEH_DIR  ${SIM_DIR}/beh
setenv SIM_SYN_DIR  ${SIM_DIR}/syn
setenv SIM_PNR_DIR  ${SIM_DIR}/pnr

# Synthesis
setenv SYN_DIR      ${IMP_DIR}/syn
setenv SYN_NET_DIR  ${SYN_DIR}/netlist
setenv SYN_REP_DIR  ${SYN_DIR}/reports
setenv SYN_LOG_DIR  ${SYN_DIR}/logs

# Place and Route
setenv PNR_DIR      ${IMP_DIR}/pnr
setenv PNR_NET_DIR  ${PNR_DIR}/netlist
setenv PNR_REP_DIR  ${PNR_DIR}/reports
setenv PNR_OA_LIB   liboa

#-----------------------------------------------------------------------------
# CONFIGURATION DU KIT GPDK045
#-----------------------------------------------------------------------------

setenv KIT_HOME ${CMC_HOME}/kits/GPDK045
    
# Librairies Modelsim 
setenv SIMLIB     ${KIT_HOME}/simlib
setenv SIMLIB_VHD fast_vdd1v0_basicCells
setenv SIMLIB_VER gpdk45
    
# Front-End
setenv FE_DIR      ${KIT_HOME}/gsclib045_svt_v4.4/gsclib045
setenv FE_VER_LIB  ${FE_DIR}/verilog
setenv FE_VHD_LIB  ${FE_DIR}/vhdl
setenv FE_TIM_LIB  ${FE_DIR}/timing

# Back-End
setenv BE_DIR       ${KIT_HOME}/gsclib045_svt_v4.4/gsclib045
setenv BE_LEF_LIB   ${BE_DIR}/lef
setenv BE_CDB_LIB   ${BE_DIR}/celtic
setenv BE_OA_LIB    ${BE_DIR}/oa22/gsclib045
setenv BE_QRC_LIB   ${BE_DIR}/qrc/qx
setenv BE_GDS_LIB   ${BE_DIR}/gds
setenv BE_SPICE_LIB ${BE_DIR}/spectre/gsclib045

# I/O
setenv IO_DIR      ${KIT_HOME}/giolib045_v3.2/giolib045
setenv IO_VHDL_LIB ${IO_DIR}/vhdl
setenv IO_VER_LIB  ${IO_DIR}/vlog
setenv IO_LEF_LIB  ${IO_DIR}/lef
setenv IO_OA_LIB   ${IO_DIR}/oa22/giolib045

#-----------------------------------------------------------------------------
# CONFIGURATION DES OUTILS
#-----------------------------------------------------------------------------

# MENTOR
source ${CMC_HOME}/scripts/mentor.2017.12.csh

# CADENCE
source ${CMC_HOME}/scripts/cadence.2014.12.csh  
setenv DRCTEMPDIR /export/tmp/$user

# MODELSIM
source ${CMC_HOME}/scripts/mentor.modelsim.10.7a.csh
alias vsim "vsim -64 -modelsimini ${SIMLIB}/modelsim.ini"
alias vsim_help "${MGC_HTML_BROWSER} ${CMC_MNT_HOME}/modelsim.10.7a/modeltech/docs/index.html"

# GENUS
source ${CMC_HOME}/scripts/cadence.genus17.10.000.csh
alias genus "genus -overwrite"
alias genus_help "${CDS_TOP_DIR}/GENUS17.10.000_lnx86/tools.lnx86/bin/cdnshelp"
# Modus
source ${CMC_HOME}/scripts/cadence.modus17.10.000.csh
#Incisive
source ${CMC_HOME}/scripts/cadence.incisive15.20.054.csh
# INNOVUS
source ${CMC_HOME}/scripts/cadence.innovus17.11.000.csh
alias innovus "innovus -overwrite -no_logv"
alias innovus_help "${CDS_TOP_DIR}/INNOVUS17.11.000_lnx86/tools/bin/cdnshelp"

# VOLTUS & TEMPUS
source ${CMC_HOME}/scripts/cadence.ssv16.16.000.csh
alias voltus "voltus -overwrite -no_logv"
alias tempus "tempus -overwrite -no_logv"
alias ssv_help "${CDS_TOP_DIR}/SSV-ISR6.16.16.000_lnx86/bin/cdnshelp"

# QUANTUS QRC
source ${CMC_HOME}/scripts/cadence.ext17.21.000.csh

# CONFORMAL
source ${CMC_HOME}/scripts/cadence.conformal17.20.300.csh

# PVS
source ${CMC_HOME}/scripts/cadence.pvs16.12.000.csh
