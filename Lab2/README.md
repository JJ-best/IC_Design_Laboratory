# Lab2: Verilog Simulator (VCS)
## Check syntax error
```shell
vcs -full64 lab2_alu.v 
```
## To run simulation
```shell
vcs lab2_alu_test.v lab2_alu.v -R -full64 -debug_access+all +v2k 
```
or
```shell
vcs -f lab2_run.f -R -full64 -debug_access+all +v2k 
```