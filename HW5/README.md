# HW5: Vision Transformer

## Introduction
Vision Transformers (ViTs) have emerged as a powerful alternative to traditional 
convolutional approaches for computer vision tasks. The pioneering work on ViT 
demonstrated that, with sufficient data and computational resources, transformer-based 
models can achieve state-of-the-art performance on image classification tasks, opening the 
door to a new era of vision architecture beyond CNNs. 
In this assignment, we will implement a multi-head attention of a transformer block. 
The implementation will also include linear projection, softmax and normalization 
operations. 

## Dataflow
1. Read the patch embedded data from SRAM A. 
2. Implement normalization. 
3. Quantize the result to 10-bit and write the result to SRAM B. 
4. Read normalized data from SRAM B. 
5. Implement head 0 of K projection, Q projection and V projection. 
6. Quantize the result to 10-bit and write the result to SRAM C. 
7. Read K projection and Q projection from SRAM C. 
8. Implement multiplication of attention head 0 first 16 rows results. 
9. Multiply each result with 1/$\sqrt{chead}$

10. Quantize the result to 10-bits and write the result to SRAM D. 
16 
Homework#5 EE429200 IC Design Laboratory 
11. Read the attention data form SRAM D. 
12. Implement Softmax. 
13. Quantize the result to 10-bits and write the result to SRAM B. 
14. Read V projection from SRAM C and softmax result from SRAM B. 
15. Implement multiplication of attention head 0 first 16 rows results. 
16. Quantize the result to 10-bits and write the result to SRAM D. 
17. Repeat step 7~15 to finish remaining rows. 
18. Repeat step 1~16 to finish head1. 
19. Read V softmax multiplication result from SRAM D. 
20. Implement O projection. 
21. Quantize the result to 10-bit and write the result to SRAM C. 
22. Read O projection from SRAM C and patch embedded data from SRAM A. 
23. Implement residual add 
24. Quantize the result to 10-bit and store the result to SRAM B. 

