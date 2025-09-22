#!/bin/sh
if [ -r "/usr/cadtool/GPDK45/gsclib045_svt_v4.4/gsclib045/db/slow_vdd1v2_basicCells_wl.db" ]
then
    echo "Check Synthesis library OK !"
    if [ -r "/usr/cadtool/GPDK45/gsclib045_svt_v4.4/gsclib045/lib/slow_vdd1v2_basicCells_wl.lib" ]
    then 
      echo "Check APR library OK !"
        if [ -x "/usr/cad/synopsys/synthesis/cur/amd64/syn/bin/dc_shell" ]
        then 
          echo "Check Tool OK !"
        else
          echo "Permission denied, ask TA for help!"
    fi  
    else
      echo "Permission denied, ask TA for help!"
    fi  
else
    echo "Permission denied, ask TA for help!"
fi