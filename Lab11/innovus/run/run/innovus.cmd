#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Wed Nov 19 22:42:00 2025                
#                                                     
#######################################################

#@(#)CDS: Innovus v20.10-p004_1 (64bit) 05/07/2020 20:02 (Linux 2.6.32-431.11.2.el6.x86_64)
#@(#)CDS: NanoRoute 20.10-p004_1 NR200413-0234/20_10-UB (database version 18.20.505) {superthreading v1.69}
#@(#)CDS: AAE 20.10-p005 (64bit) 05/07/2020 (Linux 2.6.32-431.11.2.el6.x86_64)
#@(#)CDS: CTE 20.10-p005_1 () Apr 14 2020 09:14:28 ( )
#@(#)CDS: SYNTECH 20.10-b004_1 () Mar 12 2020 22:18:21 ( )
#@(#)CDS: CPE v20.10-p006
#@(#)CDS: IQuantus/TQuantus 19.1.3-s155 (64bit) Sun Nov 3 18:26:52 PST 2019 (Linux 2.6.32-431.11.2.el6.x86_64)

set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
win
set init_gnd_net VSS
set init_lef_file {/usr/cadtool/GPDK45/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_tech.lef /usr/cadtool/GPDK45/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_macro.lef}
set init_verilog ../pre_layout/top_pipe_syn.v
set init_mmmc_file ../pre_layout/mmmc.view
set init_pwr_net VDD
init_design
saveIoFile -byOrder -temp top_pipe.save.io
setDesignMode -process 45
clearGlobalNets
globalNetConnect VDD -type pgpin -pin VDD -instanceBasename *
globalNetConnect VSS -type pgpin -pin VSS -instanceBasename *
clearGlobalNets
globalNetConnect VDD -type pgpin -pin VDD -instanceBasename *
globalNetConnect VSS -type pgpin -pin VSS -instanceBasename *
clearGlobalNets
globalNetConnect VDD -type pgpin -pin VDD -instanceBasename *
globalNetConnect VSS -type pgpin -pin VSS -instanceBasename *
saveDesign top_pipe
getIoFlowFlag
setIoFlowFlag 0
floorPlan -site CoreSite -r 1 0.5 35.5 35.5 35.5 35.5
uiSetTool select
getIoFlowFlag
fit
loadIoFile top_pipe.save.io
fit
fit
gui_select -rect {591.37100 631.10400 632.49900 589.97650}
deselectAll
zoomIn
zoomOut
gui_select -rect {668.78850 552.47850 563.54950 645.62100}
zoomIn
zoomOut
zoomIn
zoomOut
zoomSelected -margin 50
deselectAll
gui_select -rect {609.07600 615.49850 618.62300 608.63650}
zoomSelected -margin 50
viewLast
viewLast
deselectAll
getIoFlowFlag
setIoFlowFlag 0
floorPlan -site CoreSite -r 0.997342192691 0.499881 35.6 35.53 35.6 35.53
uiSetTool select
getIoFlowFlag
fit
fit
fit
setRouteMode -earlyGlobalHonorMsvRouteConstraint false -earlyGlobalRoutePartitionPinGuide true
setEndCapMode -reset
setEndCapMode -boundary_tap false
setNanoRouteMode -quiet -droutePostRouteSpreadWire 1
setNanoRouteMode -quiet -droutePostRouteWidenWireRule LEFSpecialRouteSpec
setNanoRouteMode -quiet -timingEngine {}
setUsefulSkewMode -maxSkew false -noBoundary false -useCells {DLY4X4 DLY4X1 DLY3X4 DLY3X1 DLY2X4 DLY2X1 DLY1X4 DLY1X1 CLKBUFX8 CLKBUFX6 CLKBUFX4 CLKBUFX3 CLKBUFX20 CLKBUFX2 CLKBUFX16 CLKBUFX12 BUFX8 BUFX6 BUFX4 BUFX3 BUFX20 BUFX2 BUFX16 BUFX12 INVXL INVX8 INVX6 INVX4 INVX3 INVX20 INVX2 INVX16 INVX12 INVX1 CLKINVX8 CLKINVX6 CLKINVX4 CLKINVX3 CLKINVX20 CLKINVX2 CLKINVX16 CLKINVX12 CLKINVX1} -maxAllowedDelay 1
setPlaceMode -reset
setPlaceMode -fp true -timingDriven 1 -clkGateAware 1 -powerDriven 0 -ignoreScan 1 -reorderScan 1 -ignoreSpare 0 -placeIOPins 0 -moduleAwareSpare 0 -preserveRouting 1 -rmAffectedRouting 0 -checkRoute 0 -swapEEQ 0
fit
place_design
refinePlace -checkRoute 1
setRouteMode -earlyGlobalHonorMsvRouteConstraint false -earlyGlobalRoutePartitionPinGuide true
earlyGlobalRoute
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -prePlace -pathReports -drvReports -slackReports -numPaths 50 -prefix top_pipe_prePlace -outDir timingReports
setLayerPreference routeCongest -isVisible 1
setLayerPreference congestH -color {#000066 #0000c9 #0053ff #00fcfa #00a953 #53a900 #f9fc00 #ff5300 #ff5858 #ffffff}
setLayerPreference congestV -color {#000066 #0000c9 #0053ff #00fcfa #00a953 #53a900 #f9fc00 #ff5300 #ff5858 #ffffff}
setLayerPreference node_route -isVisible 0
redraw
congRepair
fit
saveDesign top_pipe
