# Lab6-2
## FIR filter
### top-level block
![figure](image/top.png)

To simplify the design, the finite state machine is provided to decide whether the output is valid. 
You only need to finish the computational part.

### computation block
![figure](image/fir.png)

### fir1_v1
```verilog
integer j;
always @* begin
  y_n = 0;
  for (j = 0; j <= 15; j = j + 1) begin
    y_n = y_n + (DFF[j] * num[j]);
  end
end
```

### fir1_v2
```verilog

always @* begin
  pipe_wire[0] = (DFF[0] * num[0]) + (DFF[1] * num[1]);
  pipe_wire[1] = pipe_wire[0] + (DFF[2] * num[2]);
  pipe_wire[2] = pipe_wire[1] + (DFF[3] * num[3]);
  pipe_wire[3] = pipe_wire[2] + (DFF[4] * num[4]);
  pipe_wire[4] = pipe_wire[3] + (DFF[5] * num[5]);

  pipe_wire[5] = pipe_wire[4] + (DFF[6] * num[6]);
  pipe_wire[6] = pipe_wire[5] + (DFF[7] * num[7]);
  pipe_wire[7] = pipe_wire[6] + (DFF[8] * num[8]);
  pipe_wire[8] = pipe_wire[7] + (DFF[9] * num[9]);
  pipe_wire[9] = pipe_wire[8] + (DFF[10] * num[10]);

  pipe_wire[10] = pipe_wire[9] + (DFF[11] * num[11]);
  pipe_wire[11] = pipe_wire[10] + (DFF[12] * num[12]);
  pipe_wire[12] = pipe_wire[11] + (DFF[13] * num[13]);
  pipe_wire[13] = pipe_wire[12] + (DFF[14] * num[14]);
  pipe_wire[14] = pipe_wire[13] + (DFF[15] * num[15]);
  y_n = pipe_wire[14];
end
```
fir_v1 and fir_v2 have same performance.



## Performance Comparison

| Module | Area | Timing | Cycles(#) | Performance |
| ------ | ---- | ------ | --------- | ----------- |
| direct | 12912|3.3 | 1005 | $ 2.34\times 10^{-8}$ | 
| pipeline |15345 | 2.5| 1007| $2.58\times 10^{-8}$| 