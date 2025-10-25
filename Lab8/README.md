# Lab8: Coding for Synthesis

This lab implement a fir filter with two different architecture from lab6.
![figure](image/lab6.png)

## 1. One multiplier and one adder architecture
![figure](image/lab8_p1.png)
![figure](image/part1.jpg)
![figure](image/part1_fsm.jpg)

## 2. Parallel architecture
![figure](image/lab8_p2.png)

## 3. Performance Comparison

| Module | Area | Timing | Cycles(#) | Performance |
| ------ | ---- | ------ | --------- | ----------- |
| one_add_mul | 7566|2.27 |167480 | $ 3.47\times 10^{-10}$ | 
| parallel |23539 | 3.2| 5040| $2.63\times 10^{-9}$| 
| direct | 12912|3.3 | 10050 | $ 2.34\times 10^{-9}$ | 
| pipeline |15345 | 2.5| 10070| $2.58\times 10^{-9}$| 
$ \text{Performance} = \frac{1}{A\times T \times C} $

The performance of parallel architecture is better.

### Part1 waveform
![figure](image/lab8_1_wave.png)

### PArt2 waveform
![figure](image/lab8_2_wave.png)
