/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : R-2020.09-SP5
// Date      : Sat Nov  8 22:04:06 2025
/////////////////////////////////////////////////////////////

// netlist of mission 1, 2
// we need to correct it by hand to mission 3 and 4
module inverse_table_DIVISOR_WIDTH5_WIDTH_INVERSE17_WIDTH_SHIFT5 ( divisor, 
        div_inverse_15_, div_inverse_14_, div_inverse_13_, div_inverse_12_, 
        div_inverse_11_, div_inverse_10_, div_inverse_9_, div_inverse_8_, 
        div_inverse_7_, div_inverse_6_, div_inverse_5_, div_inverse_4_, 
        div_inverse_3_, div_inverse_2_, div_inverse_1_, div_inverse_0_, 
        div_shift_2_, div_shift_1_, div_shift_0_ );
  input [4:0] divisor;
  output div_inverse_15_, div_inverse_14_, div_inverse_13_, div_inverse_12_,
         div_inverse_11_, div_inverse_10_, div_inverse_9_, div_inverse_8_,
         div_inverse_7_, div_inverse_6_, div_inverse_5_, div_inverse_4_,
         div_inverse_3_, div_inverse_2_, div_inverse_1_, div_inverse_0_,
         div_shift_2_, div_shift_1_, div_shift_0_;
  wire   n1, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44,
         n45, n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58,
         n59, n60, n61, n62, n63, n64, n65, n66, n67, n68, n69;

  NAND2XL U3 ( .A(divisor[1]), .B(n38), .Y(n28) );
  OAI211XL U4 ( .A0(n27), .A1(n14), .B0(n4), .C0(n15), .Y(div_shift_1_) );
  NAND2XL U5 ( .A(n26), .B(n55), .Y(div_inverse_10_) );
  NAND2XL U6 ( .A(n25), .B(n49), .Y(div_inverse_9_) );
  NAND2XL U7 ( .A(divisor[0]), .B(divisor[4]), .Y(n69) );
  OAI211X1 U8 ( .A0(n7), .A1(n34), .B0(n6), .C0(n69), .Y(div_shift_0_) );
  AOI32X1 U10 ( .A0(n18), .A1(n15), .A2(n22), .B0(n14), .B1(n15), .Y(n58) );
  AND4XL U11 ( .A(n67), .B(n47), .C(n40), .D(n39), .Y(n1) );
  INVXL U12 ( .A(divisor[1]), .Y(n11) );
  OR2XL U13 ( .A(n33), .B(n19), .Y(n63) );
  INVXL U14 ( .A(divisor[4]), .Y(n34) );
  NAND2XL U15 ( .A(divisor[3]), .B(n33), .Y(n56) );
  NAND3BX1 U16 ( .AN(n35), .B(n34), .C(n56), .Y(div_shift_2_) );
  INVXL U17 ( .A(n1), .Y(div_inverse_11_) );
  OR4X1 U18 ( .A(n65), .B(n54), .C(n64), .D(div_inverse_12_), .Y(
        div_inverse_4_) );
  NAND3BX1 U19 ( .AN(n57), .B(n55), .C(n50), .Y(div_inverse_12_) );
  NAND4X2 U20 ( .A(n47), .B(n51), .C(n46), .D(n45), .Y(div_inverse_13_) );
  NAND3BX1 U21 ( .AN(n44), .B(n48), .C(n50), .Y(div_inverse_5_) );
  NAND3BXL U22 ( .AN(divisor[3]), .B(divisor[2]), .C(n11), .Y(n27) );
  INVXL U23 ( .A(divisor[0]), .Y(n9) );
  NAND2XL U24 ( .A(n9), .B(n34), .Y(n14) );
  NAND2XL U25 ( .A(divisor[0]), .B(n34), .Y(n23) );
  INVXL U26 ( .A(n23), .Y(n10) );
  NAND2XL U27 ( .A(n10), .B(divisor[2]), .Y(n31) );
  NOR2XL U28 ( .A(divisor[3]), .B(n11), .Y(n30) );
  NAND2XL U29 ( .A(divisor[2]), .B(n30), .Y(n18) );
  INVXL U30 ( .A(divisor[2]), .Y(n8) );
  NAND2XL U31 ( .A(n8), .B(n11), .Y(n33) );
  INVXL U32 ( .A(divisor[3]), .Y(n19) );
  NAND2XL U33 ( .A(n18), .B(n63), .Y(n21) );
  INVXL U34 ( .A(n21), .Y(n3) );
  OAI22XL U35 ( .A0(divisor[3]), .A1(n31), .B0(n3), .B1(n14), .Y(n5) );
  INVXL U36 ( .A(n5), .Y(n4) );
  NAND2XL U37 ( .A(n8), .B(n19), .Y(n68) );
  NOR2XL U38 ( .A(n11), .B(n68), .Y(n16) );
  NAND2XL U39 ( .A(n10), .B(n16), .Y(n15) );
  INVXL U40 ( .A(n68), .Y(n7) );
  AOI21XL U41 ( .A0(n16), .A1(n9), .B0(n5), .Y(n6) );
  NOR2XL U42 ( .A(n8), .B(n19), .Y(n38) );
  NAND2XL U43 ( .A(n38), .B(n11), .Y(n22) );
  NAND2XL U44 ( .A(divisor[4]), .B(n9), .Y(n62) );
  OAI222XL U45 ( .A0(n22), .A1(n62), .B0(n18), .B1(n23), .C0(n14), .C1(n28), 
        .Y(n54) );
  INVXL U46 ( .A(n54), .Y(n13) );
  INVXL U47 ( .A(n62), .Y(n43) );
  NOR2XL U48 ( .A(n10), .B(n43), .Y(n12) );
  NOR2XL U49 ( .A(divisor[2]), .B(n11), .Y(n17) );
  NAND2XL U50 ( .A(divisor[3]), .B(n17), .Y(n32) );
  OA22X1 U51 ( .A0(n12), .A1(n27), .B0(n14), .B1(n32), .Y(n67) );
  OAI211X1 U52 ( .A0(n33), .A1(n69), .B0(n13), .C0(n67), .Y(div_inverse_7_) );
  NOR2XL U53 ( .A(n23), .B(n32), .Y(n41) );
  AOI211XL U54 ( .A0(n43), .A1(n21), .B0(n41), .C0(n58), .Y(n55) );
  NAND3BXL U55 ( .AN(div_inverse_7_), .B(n55), .C(n28), .Y(div_inverse_1_) );
  NOR2XL U56 ( .A(n69), .B(n27), .Y(n65) );
  NOR2XL U57 ( .A(n23), .B(n63), .Y(n35) );
  AOI21XL U58 ( .A0(n16), .A1(n43), .B0(n35), .Y(n53) );
  INVXL U59 ( .A(n69), .Y(n37) );
  NAND2XL U60 ( .A(n37), .B(n17), .Y(n40) );
  NOR2XL U61 ( .A(n65), .B(n59), .Y(n25) );
  INVXL U62 ( .A(n18), .Y(n42) );
  NAND2XL U63 ( .A(n42), .B(n37), .Y(n45) );
  NAND2XL U64 ( .A(n25), .B(n45), .Y(n52) );
  NOR2XL U65 ( .A(n54), .B(n52), .Y(n26) );
  OAI21XL U66 ( .A0(n28), .A1(n69), .B0(n26), .Y(div_inverse_0_) );
  NOR2XL U67 ( .A(n69), .B(n33), .Y(n20) );
  NAND2XL U68 ( .A(n20), .B(n19), .Y(n60) );
  NAND2XL U69 ( .A(n40), .B(n60), .Y(n44) );
  NAND2XL U70 ( .A(n37), .B(n21), .Y(n48) );
  NOR2XL U71 ( .A(n22), .B(n69), .Y(n24) );
  INVXL U72 ( .A(n24), .Y(n50) );
  OAI22XL U73 ( .A0(n23), .A1(n22), .B0(n62), .B1(n32), .Y(n36) );
  NOR2XL U74 ( .A(n24), .B(n36), .Y(n49) );
  AND2XL U75 ( .A(n28), .B(n27), .Y(n29) );
  OAI222XL U76 ( .A0(n32), .A1(divisor[0]), .B0(n31), .B1(n30), .C0(n62), .C1(
        n29), .Y(n57) );
  INVXL U77 ( .A(n36), .Y(n47) );
  NAND2XL U78 ( .A(n38), .B(n37), .Y(n39) );
  AOI21XL U79 ( .A0(n43), .A1(n42), .B0(n41), .Y(n51) );
  NOR2XL U80 ( .A(n54), .B(n44), .Y(n46) );
  NAND4XL U81 ( .A(n55), .B(n53), .C(n48), .D(n60), .Y(div_inverse_14_) );
  NAND4XL U82 ( .A(n55), .B(n53), .C(n49), .D(n48), .Y(div_inverse_2_) );
  NAND4BX1 U83 ( .AN(n52), .B(n67), .C(n51), .D(n50), .Y(div_inverse_3_) );
  INVXL U84 ( .A(n53), .Y(n64) );
  OAI211X1 U85 ( .A0(n69), .A1(n56), .B0(n55), .C0(n60), .Y(div_inverse_6_) );
  NOR3XL U86 ( .A(n59), .B(n58), .C(n57), .Y(n61) );
  OAI211X1 U87 ( .A0(n63), .A1(n62), .B0(n61), .C0(n60), .Y(div_inverse_8_) );
  NOR2XL U88 ( .A(n65), .B(n64), .Y(n66) );
  OAI211X1 U89 ( .A0(n69), .A1(n68), .B0(n67), .C0(n66), .Y(div_inverse_15_)
         );
  OAI211XL U9 ( .A0(n63), .A1(n69), .B0(n53), .C0(n40), .Y(n59) );
endmodule


module mul_and_shift_DIVIDEND_WIDTH16_WIDTH_INVERSE17_WIDTH_SHIFT5 ( dividend, 
        quotient, div_inverse_15_, div_inverse_14_, div_inverse_13_, 
        div_inverse_12_, div_inverse_11_, div_inverse_10_, div_inverse_9_, 
        div_inverse_8_, div_inverse_7_, div_inverse_6_, div_inverse_5_, 
        div_inverse_4_, div_inverse_3_, div_inverse_2_, div_inverse_1_, 
        div_inverse_0_, div_shift_2_, div_shift_1_, div_shift_0_ );
  input [15:0] dividend;
  output [15:0] quotient;
  input div_inverse_15_, div_inverse_14_, div_inverse_13_, div_inverse_12_,
         div_inverse_11_, div_inverse_10_, div_inverse_9_, div_inverse_8_,
         div_inverse_7_, div_inverse_6_, div_inverse_5_, div_inverse_4_,
         div_inverse_3_, div_inverse_2_, div_inverse_1_, div_inverse_0_,
         div_shift_2_, div_shift_1_, div_shift_0_;
  wire   intadd_0_A_24_, intadd_0_A_23_, intadd_0_A_22_, intadd_0_A_21_,
         intadd_0_A_20_, intadd_0_A_19_, intadd_0_A_18_, intadd_0_A_17_,
         intadd_0_A_16_, intadd_0_A_15_, intadd_0_A_14_, intadd_0_A_13_,
         intadd_0_A_12_, intadd_0_A_11_, intadd_0_A_10_, intadd_0_A_9_,
         intadd_0_A_8_, intadd_0_A_7_, intadd_0_A_6_, intadd_0_A_5_,
         intadd_0_A_4_, intadd_0_A_3_, intadd_0_A_2_, intadd_0_A_1_,
         intadd_0_A_0_, intadd_0_B_24_, intadd_0_B_23_, intadd_0_B_22_,
         intadd_0_B_19_, intadd_0_B_16_, intadd_0_B_14_, intadd_0_B_12_,
         intadd_0_B_11_, intadd_0_B_10_, intadd_0_B_9_, intadd_0_B_8_,
         intadd_0_B_7_, intadd_0_B_6_, intadd_0_B_5_, intadd_0_B_4_,
         intadd_0_B_3_, intadd_0_B_2_, intadd_0_B_1_, intadd_0_B_0_,
         intadd_0_CI, intadd_0_SUM_24_, intadd_0_SUM_23_, intadd_0_SUM_22_,
         intadd_0_SUM_21_, intadd_0_SUM_20_, intadd_0_SUM_19_,
         intadd_0_SUM_18_, intadd_0_SUM_17_, intadd_0_SUM_16_,
         intadd_0_SUM_15_, intadd_0_SUM_14_, intadd_0_SUM_13_,
         intadd_0_SUM_12_, intadd_0_SUM_11_, intadd_0_SUM_10_, intadd_0_SUM_9_,
         intadd_0_SUM_8_, intadd_0_SUM_7_, intadd_0_SUM_6_, intadd_0_SUM_5_,
         intadd_0_SUM_4_, intadd_0_SUM_3_, intadd_0_SUM_2_, intadd_0_SUM_1_,
         intadd_0_SUM_0_, intadd_0_n25, intadd_0_n24, intadd_0_n23,
         intadd_0_n22, intadd_0_n21, intadd_0_n20, intadd_0_n19, intadd_0_n18,
         intadd_0_n17, intadd_0_n16, intadd_0_n15, intadd_0_n14, intadd_0_n13,
         intadd_0_n12, intadd_0_n11, intadd_0_n10, intadd_0_n9, intadd_0_n8,
         intadd_0_n7, intadd_0_n6, intadd_0_n5, intadd_0_n4, intadd_0_n3,
         intadd_0_n2, intadd_0_n1, intadd_1_CI, intadd_1_SUM_12_,
         intadd_1_SUM_11_, intadd_1_SUM_10_, intadd_1_SUM_9_, intadd_1_SUM_8_,
         intadd_1_SUM_7_, intadd_1_SUM_6_, intadd_1_SUM_5_, intadd_1_SUM_4_,
         intadd_1_SUM_3_, intadd_1_SUM_2_, intadd_1_SUM_1_, intadd_1_SUM_0_,
         intadd_1_n13, intadd_1_n12, intadd_1_n11, intadd_1_n10, intadd_1_n9,
         intadd_1_n8, intadd_1_n7, intadd_1_n6, intadd_1_n5, intadd_1_n4,
         intadd_1_n3, intadd_1_n2, intadd_1_n1, intadd_2_A_9_, intadd_2_A_8_,
         intadd_2_A_7_, intadd_2_A_6_, intadd_2_A_5_, intadd_2_A_4_,
         intadd_2_A_3_, intadd_2_A_2_, intadd_2_A_1_, intadd_2_A_0_,
         intadd_2_B_9_, intadd_2_B_8_, intadd_2_B_7_, intadd_2_B_6_,
         intadd_2_B_5_, intadd_2_B_4_, intadd_2_B_3_, intadd_2_B_2_,
         intadd_2_B_1_, intadd_2_B_0_, intadd_2_CI, intadd_2_SUM_8_,
         intadd_2_n10, intadd_2_n9, intadd_2_n8, intadd_2_n7, intadd_2_n6,
         intadd_2_n5, intadd_2_n4, intadd_2_n3, intadd_2_n2, intadd_2_n1,
         intadd_3_A_8_, intadd_3_A_7_, intadd_3_A_6_, intadd_3_A_5_,
         intadd_3_A_4_, intadd_3_A_3_, intadd_3_A_2_, intadd_3_A_1_,
         intadd_3_A_0_, intadd_3_B_8_, intadd_3_B_6_, intadd_3_B_5_,
         intadd_3_B_4_, intadd_3_B_3_, intadd_3_B_2_, intadd_3_B_1_,
         intadd_3_B_0_, intadd_3_CI, intadd_3_SUM_7_, intadd_3_n9, intadd_3_n8,
         intadd_3_n7, intadd_3_n6, intadd_3_n5, intadd_3_n4, intadd_3_n3,
         intadd_3_n2, intadd_3_n1, intadd_4_A_5_, intadd_4_A_4_, intadd_4_A_3_,
         intadd_4_A_0_, intadd_4_B_5_, intadd_4_B_4_, intadd_4_B_3_,
         intadd_4_B_2_, intadd_4_B_1_, intadd_4_B_0_, intadd_4_CI,
         intadd_4_SUM_4_, intadd_4_SUM_3_, intadd_4_SUM_2_, intadd_4_SUM_1_,
         intadd_4_SUM_0_, intadd_4_n6, intadd_4_n5, intadd_4_n4, intadd_4_n3,
         intadd_4_n2, intadd_4_n1, intadd_5_A_4_, intadd_5_A_3_, intadd_5_A_1_,
         intadd_5_B_4_, intadd_5_B_3_, intadd_5_B_2_, intadd_5_B_1_,
         intadd_5_B_0_, intadd_5_CI, intadd_5_SUM_3_, intadd_5_SUM_2_,
         intadd_5_n5, intadd_5_n4, intadd_5_n3, intadd_5_n2, intadd_5_n1,
         intadd_6_A_3_, intadd_6_A_2_, intadd_6_A_1_, intadd_6_A_0_,
         intadd_6_B_2_, intadd_6_B_1_, intadd_6_B_0_, intadd_6_CI, intadd_6_n4,
         intadd_6_n3, intadd_6_n2, intadd_6_n1, intadd_7_A_3_, intadd_7_A_2_,
         intadd_7_A_1_, intadd_7_A_0_, intadd_7_B_0_, intadd_7_SUM_2_,
         intadd_7_SUM_1_, intadd_7_n4, intadd_7_n3, intadd_7_n2, intadd_7_n1,
         intadd_8_A_2_, intadd_8_A_1_, intadd_8_B_2_, intadd_8_B_1_,
         intadd_8_B_0_, intadd_8_CI, intadd_8_n3, intadd_8_n2, intadd_8_n1, n4,
         n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19,
         n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33,
         n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44, n45, n46, n47,
         n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58, n59, n60, n61,
         n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72, n73, n74, n75,
         n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86, n87, n88, n89,
         n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100, n101, n102,
         n103, n104, n105, n106, n107, n108, n109, n110, n111, n112, n113,
         n114, n115, n116, n117, n118, n119, n120, n121, n122, n123, n124,
         n125, n126, n127, n128, n129, n130, n131, n132, n133, n134, n135,
         n136, n137, n138, n139, n140, n141, n142, n143, n144, n145, n146,
         n147, n148, n149, n150, n151, n152, n153, n154, n155, n156, n157,
         n158, n159, n160, n161, n162, n163, n164, n165, n166, n167, n168,
         n169, n170, n171, n172, n173, n174, n175, n176, n177, n178, n179,
         n180, n181, n182, n183, n184, n185, n186, n187, n188, n189, n190,
         n191, n192, n193, n194, n195, n196, n197, n198, n199, n200, n201,
         n202, n203, n204, n205, n206, n207, n208, n209, n210, n211, n212,
         n213, n214, n215, n216, n217, n218, n219, n220, n221, n222, n223,
         n224, n225, n226, n227, n228, n229, n230, n231, n232, n233, n234,
         n235, n236, n237, n238, n239, n240, n241, n242, n243, n244, n245,
         n246, n247, n248, n249, n250, n251, n252, n253, n254, n255, n256,
         n257, n258, n259, n260, n261, n262, n263, n264, n265, n266, n267,
         n268, n269, n270, n271, n272, n273, n274, n275, n276, n277, n278,
         n279, n280, n281, n282, n283, n284, n285, n286, n287, n288, n289,
         n290, n291, n292, n293, n294, n295, n296, n297, n298, n299, n300,
         n301, n302, n303, n304, n305, n306, n307, n308, n309, n310, n311,
         n312, n313, n314, n315, n316, n317, n318, n319, n320, n321, n322,
         n323, n324, n325, n326, n327, n328, n329, n330, n331, n332, n333,
         n334, n335, n336, n337, n338, n339, n340, n341, n342, n343, n344,
         n345, n346, n347, n348, n349, n350, n351, n352, n353, n354, n355,
         n356, n357, n358, n359, n360, n361, n362, n363, n364, n365, n366,
         n367, n368, n369, n370, n371, n372, n373, n374, n375, n376, n377,
         n378, n379, n380, n381, n382, n383, n384, n385, n386, n387, n388,
         n389, n390, n391, n392, n393, n394, n395, n396, n397, n398, n399,
         n400, n401, n402, n403, n404, n405, n406, n407, n408, n409, n410,
         n411, n412, n413, n414, n415, n416, n417, n418, n419, n420, n421,
         n422, n423, n424, n425, n426, n427, n428, n429, n430, n431, n432,
         n433, n434, n435, n436, n437, n438, n439, n440, n441, n442, n443,
         n444, n445, n446, n447, n448, n449, n450, n451, n452, n453, n454,
         n455, n456, n457, n458, n459, n460, n461, n462, n463, n464, n465,
         n466, n467, n468, n469, n470, n471, n472, n473, n474, n475, n476,
         n477, n478, n479, n480, n481, n482, n483, n484, n485, n486, n487,
         n488, n489, n490, n491, n492, n493, n494, n495, n496, n497;

  ADDFX1 intadd_0_U26 ( .A(intadd_0_B_0_), .B(intadd_0_A_0_), .CI(intadd_0_CI), 
        .CO(intadd_0_n25), .S(intadd_0_SUM_0_) );
  ADDFX1 intadd_0_U25 ( .A(intadd_0_B_1_), .B(intadd_0_A_1_), .CI(intadd_0_n25), .CO(intadd_0_n24), .S(intadd_0_SUM_1_) );
  ADDFX1 intadd_0_U24 ( .A(intadd_0_B_2_), .B(intadd_0_A_2_), .CI(intadd_0_n24), .CO(intadd_0_n23), .S(intadd_0_SUM_2_) );
  ADDFX1 intadd_0_U23 ( .A(intadd_0_B_3_), .B(intadd_0_A_3_), .CI(intadd_0_n23), .CO(intadd_0_n22), .S(intadd_0_SUM_3_) );
  ADDFX1 intadd_0_U22 ( .A(intadd_0_B_4_), .B(intadd_0_A_4_), .CI(intadd_0_n22), .CO(intadd_0_n21), .S(intadd_0_SUM_4_) );
  ADDFX1 intadd_0_U21 ( .A(intadd_0_B_5_), .B(intadd_0_A_5_), .CI(intadd_0_n21), .CO(intadd_0_n20), .S(intadd_0_SUM_5_) );
  ADDFX1 intadd_0_U20 ( .A(intadd_0_B_6_), .B(intadd_0_A_6_), .CI(intadd_0_n20), .CO(intadd_0_n19), .S(intadd_0_SUM_6_) );
  ADDFX1 intadd_0_U19 ( .A(intadd_0_B_7_), .B(intadd_0_A_7_), .CI(intadd_0_n19), .CO(intadd_0_n18), .S(intadd_0_SUM_7_) );
  ADDFX1 intadd_0_U18 ( .A(intadd_0_B_8_), .B(intadd_0_A_8_), .CI(intadd_0_n18), .CO(intadd_0_n17), .S(intadd_0_SUM_8_) );
  ADDFX1 intadd_0_U17 ( .A(intadd_0_B_9_), .B(intadd_0_A_9_), .CI(intadd_0_n17), .CO(intadd_0_n16), .S(intadd_0_SUM_9_) );
  ADDFX1 intadd_0_U16 ( .A(intadd_0_B_10_), .B(intadd_0_A_10_), .CI(
        intadd_0_n16), .CO(intadd_0_n15), .S(intadd_0_SUM_10_) );
  ADDFX1 intadd_0_U15 ( .A(intadd_0_B_11_), .B(intadd_0_A_11_), .CI(
        intadd_0_n15), .CO(intadd_0_n14), .S(intadd_0_SUM_11_) );
  ADDFX1 intadd_0_U14 ( .A(intadd_0_B_12_), .B(intadd_0_A_12_), .CI(
        intadd_0_n14), .CO(intadd_0_n13), .S(intadd_0_SUM_12_) );
  ADDFX1 intadd_0_U13 ( .A(intadd_2_n1), .B(intadd_0_A_13_), .CI(intadd_0_n13), 
        .CO(intadd_0_n12), .S(intadd_0_SUM_13_) );
  ADDFX1 intadd_0_U12 ( .A(intadd_0_B_14_), .B(intadd_0_A_14_), .CI(
        intadd_0_n12), .CO(intadd_0_n11), .S(intadd_0_SUM_14_) );
  ADDFX1 intadd_0_U11 ( .A(intadd_3_n1), .B(intadd_0_A_15_), .CI(intadd_0_n11), 
        .CO(intadd_0_n10), .S(intadd_0_SUM_15_) );
  ADDFX1 intadd_0_U10 ( .A(intadd_0_B_16_), .B(intadd_0_A_16_), .CI(
        intadd_0_n10), .CO(intadd_0_n9), .S(intadd_0_SUM_16_) );
  ADDFX1 intadd_0_U9 ( .A(intadd_7_n1), .B(intadd_0_A_17_), .CI(intadd_0_n9), 
        .CO(intadd_0_n8), .S(intadd_0_SUM_17_) );
  ADDFX1 intadd_0_U8 ( .A(intadd_4_n1), .B(intadd_0_A_18_), .CI(intadd_0_n8), 
        .CO(intadd_0_n7), .S(intadd_0_SUM_18_) );
  ADDFX1 intadd_0_U7 ( .A(intadd_0_B_19_), .B(intadd_0_A_19_), .CI(intadd_0_n7), .CO(intadd_0_n6), .S(intadd_0_SUM_19_) );
  ADDFX1 intadd_0_U6 ( .A(intadd_5_n1), .B(intadd_0_A_20_), .CI(intadd_0_n6), 
        .CO(intadd_0_n5), .S(intadd_0_SUM_20_) );
  ADDFX1 intadd_0_U5 ( .A(intadd_8_n1), .B(intadd_0_A_21_), .CI(intadd_0_n5), 
        .CO(intadd_0_n4), .S(intadd_0_SUM_21_) );
  ADDFX1 intadd_0_U4 ( .A(intadd_0_B_22_), .B(intadd_0_A_22_), .CI(intadd_0_n4), .CO(intadd_0_n3), .S(intadd_0_SUM_22_) );
  ADDFX1 intadd_0_U3 ( .A(intadd_0_B_23_), .B(intadd_0_A_23_), .CI(intadd_0_n3), .CO(intadd_0_n2), .S(intadd_0_SUM_23_) );
  ADDFX1 intadd_0_U2 ( .A(intadd_0_B_24_), .B(intadd_0_A_24_), .CI(intadd_0_n2), .CO(intadd_0_n1), .S(intadd_0_SUM_24_) );
  ADDFX1 intadd_1_U14 ( .A(div_inverse_3_), .B(n496), .CI(intadd_1_CI), .CO(
        intadd_1_n13), .S(intadd_1_SUM_0_) );
  ADDFX1 intadd_1_U13 ( .A(div_inverse_4_), .B(div_inverse_3_), .CI(
        intadd_1_n13), .CO(intadd_1_n12), .S(intadd_1_SUM_1_) );
  ADDFX1 intadd_1_U10 ( .A(div_inverse_7_), .B(div_inverse_6_), .CI(
        intadd_1_n10), .CO(intadd_1_n9), .S(intadd_1_SUM_4_) );
  ADDFX1 intadd_1_U9 ( .A(div_inverse_8_), .B(div_inverse_7_), .CI(intadd_1_n9), .CO(intadd_1_n8), .S(intadd_1_SUM_5_) );
  ADDFX1 intadd_1_U8 ( .A(div_inverse_9_), .B(div_inverse_8_), .CI(intadd_1_n8), .CO(intadd_1_n7), .S(intadd_1_SUM_6_) );
  ADDFX1 intadd_1_U7 ( .A(div_inverse_10_), .B(div_inverse_9_), .CI(
        intadd_1_n7), .CO(intadd_1_n6), .S(intadd_1_SUM_7_) );
  ADDFX1 intadd_1_U6 ( .A(div_inverse_11_), .B(div_inverse_10_), .CI(
        intadd_1_n6), .CO(intadd_1_n5), .S(intadd_1_SUM_8_) );
  ADDFX1 intadd_1_U2 ( .A(div_inverse_15_), .B(n497), .CI(intadd_1_n2), .CO(
        intadd_1_n1), .S(intadd_1_SUM_12_) );
  ADDFX1 intadd_2_U11 ( .A(intadd_2_B_0_), .B(intadd_2_A_0_), .CI(intadd_2_CI), 
        .CO(intadd_2_n10), .S(intadd_0_A_3_) );
  ADDFX1 intadd_2_U10 ( .A(intadd_2_B_1_), .B(intadd_2_A_1_), .CI(intadd_2_n10), .CO(intadd_2_n9), .S(intadd_0_A_4_) );
  ADDFX1 intadd_2_U9 ( .A(intadd_2_B_2_), .B(intadd_2_A_2_), .CI(intadd_2_n9), 
        .CO(intadd_2_n8), .S(intadd_0_A_5_) );
  ADDFX1 intadd_2_U8 ( .A(intadd_2_B_3_), .B(intadd_2_A_3_), .CI(intadd_2_n8), 
        .CO(intadd_2_n7), .S(intadd_0_A_6_) );
  ADDFX1 intadd_2_U7 ( .A(intadd_2_B_4_), .B(intadd_2_A_4_), .CI(intadd_2_n7), 
        .CO(intadd_2_n6), .S(intadd_0_A_7_) );
  ADDFX1 intadd_2_U6 ( .A(intadd_2_B_5_), .B(intadd_2_A_5_), .CI(intadd_2_n6), 
        .CO(intadd_2_n5), .S(intadd_0_A_8_) );
  ADDFX1 intadd_2_U5 ( .A(intadd_2_B_6_), .B(intadd_2_A_6_), .CI(intadd_2_n5), 
        .CO(intadd_2_n4), .S(intadd_0_A_9_) );
  ADDFX1 intadd_2_U4 ( .A(intadd_2_B_7_), .B(intadd_2_A_7_), .CI(intadd_2_n4), 
        .CO(intadd_2_n3), .S(intadd_0_A_10_) );
  ADDFX1 intadd_2_U3 ( .A(intadd_2_B_8_), .B(intadd_2_A_8_), .CI(intadd_2_n3), 
        .CO(intadd_2_n2), .S(intadd_2_SUM_8_) );
  ADDFX1 intadd_2_U2 ( .A(intadd_2_B_9_), .B(intadd_2_A_9_), .CI(intadd_2_n2), 
        .CO(intadd_2_n1), .S(intadd_0_A_12_) );
  ADDFX1 intadd_3_U10 ( .A(intadd_3_B_0_), .B(intadd_3_A_0_), .CI(intadd_3_CI), 
        .CO(intadd_3_n9), .S(intadd_2_A_3_) );
  ADDFX1 intadd_3_U9 ( .A(intadd_3_B_1_), .B(intadd_3_A_1_), .CI(intadd_3_n9), 
        .CO(intadd_3_n8), .S(intadd_2_A_4_) );
  ADDFX1 intadd_3_U8 ( .A(intadd_3_B_2_), .B(intadd_3_A_2_), .CI(intadd_3_n8), 
        .CO(intadd_3_n7), .S(intadd_2_A_5_) );
  ADDFX1 intadd_3_U7 ( .A(intadd_3_B_3_), .B(intadd_3_A_3_), .CI(intadd_3_n7), 
        .CO(intadd_3_n6), .S(intadd_2_A_6_) );
  ADDFX1 intadd_3_U6 ( .A(intadd_3_B_4_), .B(intadd_3_A_4_), .CI(intadd_3_n6), 
        .CO(intadd_3_n5), .S(intadd_2_A_7_) );
  ADDFX1 intadd_3_U5 ( .A(intadd_3_B_5_), .B(intadd_3_A_5_), .CI(intadd_3_n5), 
        .CO(intadd_3_n4), .S(intadd_2_B_8_) );
  ADDFX1 intadd_3_U4 ( .A(intadd_3_B_6_), .B(intadd_3_A_6_), .CI(intadd_3_n4), 
        .CO(intadd_3_n3), .S(intadd_2_B_9_) );
  ADDFX1 intadd_3_U3 ( .A(intadd_6_n1), .B(intadd_3_A_7_), .CI(intadd_3_n3), 
        .CO(intadd_3_n2), .S(intadd_3_SUM_7_) );
  ADDFX1 intadd_3_U2 ( .A(intadd_3_B_8_), .B(intadd_3_A_8_), .CI(intadd_3_n2), 
        .CO(intadd_3_n1), .S(intadd_0_A_14_) );
  ADDFX1 intadd_4_U7 ( .A(intadd_4_B_0_), .B(intadd_4_A_0_), .CI(intadd_4_CI), 
        .CO(intadd_4_n6), .S(intadd_4_SUM_0_) );
  ADDFX1 intadd_4_U6 ( .A(intadd_4_B_1_), .B(intadd_4_A_0_), .CI(intadd_4_n6), 
        .CO(intadd_4_n5), .S(intadd_4_SUM_1_) );
  ADDFX1 intadd_4_U5 ( .A(intadd_4_B_2_), .B(intadd_4_A_0_), .CI(intadd_4_n5), 
        .CO(intadd_4_n4), .S(intadd_4_SUM_2_) );
  ADDFX1 intadd_4_U4 ( .A(intadd_4_B_3_), .B(intadd_4_A_3_), .CI(intadd_4_n4), 
        .CO(intadd_4_n3), .S(intadd_4_SUM_3_) );
  ADDFX1 intadd_4_U3 ( .A(intadd_4_B_4_), .B(intadd_4_A_4_), .CI(intadd_4_n3), 
        .CO(intadd_4_n2), .S(intadd_4_SUM_4_) );
  ADDFX1 intadd_4_U2 ( .A(intadd_4_B_5_), .B(intadd_4_A_5_), .CI(intadd_4_n2), 
        .CO(intadd_4_n1), .S(intadd_0_A_17_) );
  ADDFX1 intadd_5_U6 ( .A(intadd_5_B_0_), .B(dividend[5]), .CI(intadd_5_CI), 
        .CO(intadd_5_n5), .S(intadd_4_B_3_) );
  ADDFX1 intadd_5_U5 ( .A(intadd_5_B_1_), .B(intadd_5_A_1_), .CI(intadd_5_n5), 
        .CO(intadd_5_n4), .S(intadd_4_B_4_) );
  ADDFX1 intadd_5_U4 ( .A(intadd_5_B_2_), .B(intadd_5_B_1_), .CI(intadd_5_n4), 
        .CO(intadd_5_n3), .S(intadd_5_SUM_2_) );
  ADDFX1 intadd_5_U3 ( .A(intadd_5_B_3_), .B(intadd_5_A_3_), .CI(intadd_5_n3), 
        .CO(intadd_5_n2), .S(intadd_5_SUM_3_) );
  ADDFX1 intadd_5_U2 ( .A(intadd_5_B_4_), .B(intadd_5_A_4_), .CI(intadd_5_n2), 
        .CO(intadd_5_n1), .S(intadd_0_A_19_) );
  ADDFX1 intadd_6_U5 ( .A(intadd_6_B_0_), .B(intadd_6_A_0_), .CI(intadd_6_CI), 
        .CO(intadd_6_n4), .S(intadd_3_A_3_) );
  ADDFX1 intadd_6_U4 ( .A(intadd_6_B_1_), .B(intadd_6_A_1_), .CI(intadd_6_n4), 
        .CO(intadd_6_n3), .S(intadd_3_B_4_) );
  ADDFX1 intadd_6_U3 ( .A(intadd_6_B_2_), .B(intadd_6_A_2_), .CI(intadd_6_n3), 
        .CO(intadd_6_n2), .S(intadd_3_B_5_) );
  ADDFX1 intadd_6_U2 ( .A(intadd_4_SUM_0_), .B(intadd_6_A_3_), .CI(intadd_6_n2), .CO(intadd_6_n1), .S(intadd_3_B_6_) );
  ADDFX1 intadd_7_U5 ( .A(intadd_7_B_0_), .B(intadd_7_A_0_), .CI(
        intadd_4_SUM_1_), .CO(intadd_7_n4), .S(intadd_3_A_7_) );
  ADDFX1 intadd_7_U4 ( .A(intadd_4_SUM_2_), .B(intadd_7_A_1_), .CI(intadd_7_n4), .CO(intadd_7_n3), .S(intadd_7_SUM_1_) );
  ADDFX1 intadd_7_U3 ( .A(intadd_4_SUM_3_), .B(intadd_7_A_2_), .CI(intadd_7_n3), .CO(intadd_7_n2), .S(intadd_7_SUM_2_) );
  ADDFX1 intadd_7_U2 ( .A(intadd_4_SUM_4_), .B(intadd_7_A_3_), .CI(intadd_7_n2), .CO(intadd_7_n1), .S(intadd_0_A_16_) );
  ADDFX1 intadd_8_U4 ( .A(intadd_8_B_0_), .B(dividend[8]), .CI(intadd_8_CI), 
        .CO(intadd_8_n3), .S(intadd_5_A_3_) );
  ADDFX1 intadd_8_U3 ( .A(intadd_8_B_1_), .B(intadd_8_A_1_), .CI(intadd_8_n3), 
        .CO(intadd_8_n2), .S(intadd_5_A_4_) );
  ADDFX1 intadd_8_U2 ( .A(intadd_8_B_2_), .B(intadd_8_A_2_), .CI(intadd_8_n2), 
        .CO(intadd_8_n1), .S(intadd_0_A_20_) );
  ADDFX1 intadd_1_U12 ( .A(div_inverse_5_), .B(div_inverse_4_), .CI(
        intadd_1_n12), .CO(intadd_1_n11), .S(intadd_1_SUM_2_) );
  ADDFX1 intadd_1_U11 ( .A(div_inverse_6_), .B(div_inverse_5_), .CI(
        intadd_1_n11), .CO(intadd_1_n10), .S(intadd_1_SUM_3_) );
  ADDFX1 intadd_1_U5 ( .A(div_inverse_12_), .B(div_inverse_11_), .CI(
        intadd_1_n5), .CO(intadd_1_n4), .S(intadd_1_SUM_9_) );
  ADDFX1 intadd_1_U4 ( .A(div_inverse_13_), .B(div_inverse_12_), .CI(
        intadd_1_n4), .CO(intadd_1_n3), .S(intadd_1_SUM_10_) );
  ADDFX1 intadd_1_U3 ( .A(n497), .B(div_inverse_13_), .CI(intadd_1_n3), .CO(
        intadd_1_n2), .S(intadd_1_SUM_11_) );
  OAI211XL U1 ( .A0(n381), .A1(n109), .B0(n37), .C0(n36), .Y(n38) );
  OAI211XL U3 ( .A0(n439), .A1(n109), .B0(n48), .C0(n47), .Y(n49) );
  OAI221XL U7 ( .A0(intadd_0_SUM_0_), .A1(n58), .B0(n56), .B1(dividend[2]), 
        .C0(n55), .Y(n57) );
  OAI221XL U9 ( .A0(n64), .A1(intadd_0_SUM_1_), .B0(n62), .B1(intadd_5_B_0_), 
        .C0(n61), .Y(n63) );
  OAI211XL U10 ( .A0(dividend[11]), .A1(n375), .B0(n374), .C0(n373), .Y(
        intadd_2_A_0_) );
  OAI221XL U11 ( .A0(intadd_0_SUM_2_), .A1(n70), .B0(n68), .B1(intadd_5_B_0_), 
        .C0(n67), .Y(n69) );
  OAI221XL U13 ( .A0(n76), .A1(intadd_0_SUM_3_), .B0(n74), .B1(intadd_5_B_0_), 
        .C0(n73), .Y(n75) );
  OAI221XL U15 ( .A0(intadd_0_SUM_4_), .A1(n82), .B0(n80), .B1(intadd_5_B_0_), 
        .C0(n79), .Y(n81) );
  OAI211XL U16 ( .A0(n455), .A1(n474), .B0(n454), .C0(n453), .Y(n456) );
  OAI221XL U17 ( .A0(n88), .A1(intadd_0_SUM_5_), .B0(n86), .B1(intadd_5_B_0_), 
        .C0(n85), .Y(n87) );
  OAI2BB1XL U18 ( .A0N(n82), .A1N(intadd_0_SUM_4_), .B0(n81), .Y(n88) );
  OAI221XL U21 ( .A0(intadd_0_SUM_6_), .A1(n94), .B0(n92), .B1(intadd_5_B_0_), 
        .C0(n91), .Y(n93) );
  OAI211XL U23 ( .A0(n404), .A1(n463), .B0(n316), .C0(n315), .Y(n317) );
  OAI2BB1XL U24 ( .A0N(n469), .A1N(n482), .B0(n435), .Y(n294) );
  NAND2XL U27 ( .A(n22), .B(dividend[0]), .Y(n109) );
  OAI211XL U29 ( .A0(n362), .A1(n361), .B0(n360), .C0(n474), .Y(n363) );
  OAI211XL U30 ( .A0(n362), .A1(n407), .B0(n110), .C0(n109), .Y(n111) );
  OAI2BB1XL U31 ( .A0N(intadd_0_SUM_7_), .A1N(n100), .B0(n99), .Y(n106) );
  OAI221XL U36 ( .A0(div_shift_1_), .A1(n122), .B0(n166), .B1(n131), .C0(n495), 
        .Y(n123) );
  AOI222XL U37 ( .A0(n136), .A1(n156), .B0(n125), .B1(n157), .C0(n166), .C1(
        n124), .Y(n144) );
  OAI32XL U38 ( .A0(n495), .A1(n494), .A2(n493), .B0(div_shift_2_), .B1(n492), 
        .Y(quotient[12]) );
  NOR2XL U39 ( .A(div_inverse_15_), .B(intadd_1_n1), .Y(n406) );
  NOR2XL U40 ( .A(dividend[1]), .B(intadd_4_A_0_), .Y(n21) );
  NAND2XL U41 ( .A(dividend[15]), .B(dividend[14]), .Y(n150) );
  NOR2XL U42 ( .A(div_shift_1_), .B(div_shift_0_), .Y(n155) );
  OAI211X1 U43 ( .A0(n493), .A1(n169), .B0(n162), .C0(n161), .Y(n164) );
  OAI211X1 U44 ( .A0(n165), .A1(n168), .B0(n159), .C0(n158), .Y(n492) );
  OAI211X1 U45 ( .A0(n161), .A1(n169), .B0(n147), .C0(n146), .Y(n153) );
  OAI211X1 U46 ( .A0(n161), .A1(n165), .B0(n143), .C0(n142), .Y(n163) );
  OAI211X1 U47 ( .A0(n161), .A1(n140), .B0(n139), .C0(n138), .Y(n170) );
  OAI211X1 U48 ( .A0(n136), .A1(n168), .B0(n135), .C0(n134), .Y(n160) );
  AOI32XL U50 ( .A0(n126), .A1(n495), .A2(div_shift_1_), .B0(n119), .B1(n495), 
        .Y(n120) );
  OAI2BB1X1 U51 ( .A0N(n106), .A1N(intadd_0_SUM_8_), .B0(n105), .Y(n117) );
  OAI2BB1X1 U54 ( .A0N(n94), .A1N(intadd_0_SUM_6_), .B0(n93), .Y(n100) );
  AOI32X1 U56 ( .A0(intadd_5_B_0_), .A1(n410), .A2(n409), .B0(intadd_4_A_0_), 
        .B1(n408), .Y(n416) );
  OAI211X1 U57 ( .A0(n409), .A1(n413), .B0(n114), .C0(n113), .Y(n115) );
  OAI2BB1X1 U58 ( .A0N(n399), .A1N(n482), .B0(n272), .Y(n247) );
  OAI211XL U59 ( .A0(n362), .A1(n253), .B0(n252), .C0(n251), .Y(n254) );
  OAI211X1 U61 ( .A0(n435), .A1(n413), .B0(n429), .C0(n353), .Y(n354) );
  OAI211XL U62 ( .A0(n413), .A1(n272), .B0(n404), .C0(n271), .Y(n273) );
  OAI211XL U63 ( .A0(n362), .A1(n223), .B0(n222), .C0(n221), .Y(n224) );
  OAI211XL U64 ( .A0(n362), .A1(n289), .B0(n288), .C0(n287), .Y(n290) );
  OAI211X1 U65 ( .A0(n413), .A1(n474), .B0(n412), .C0(n411), .Y(n414) );
  OAI211X1 U66 ( .A0(n404), .A1(n475), .B0(n351), .C0(n350), .Y(n352) );
  OAI211X1 U67 ( .A0(n475), .A1(n474), .B0(n473), .C0(n472), .Y(n476) );
  OAI211XL U68 ( .A0(n404), .A1(n467), .B0(n356), .C0(n355), .Y(n357) );
  OAI211XL U69 ( .A0(n348), .A1(n463), .B0(n260), .C0(n259), .Y(n261) );
  OAI211XL U70 ( .A0(n481), .A1(n463), .B0(n234), .C0(n233), .Y(n235) );
  OAI211XL U72 ( .A0(n481), .A1(n459), .B0(n243), .C0(n242), .Y(n244) );
  OAI211XL U73 ( .A0(n348), .A1(n459), .B0(n275), .C0(n274), .Y(n276) );
  OAI211X1 U74 ( .A0(n467), .A1(n474), .B0(n466), .C0(n465), .Y(n468) );
  OAI211XL U75 ( .A0(n481), .A1(n455), .B0(n249), .C0(n248), .Y(n250) );
  OAI211XL U76 ( .A0(n348), .A1(n455), .B0(n292), .C0(n291), .Y(n293) );
  OAI211X1 U77 ( .A0(n404), .A1(n459), .B0(n365), .C0(n364), .Y(n366) );
  OAI211X1 U78 ( .A0(n463), .A1(n474), .B0(n462), .C0(n461), .Y(n464) );
  OAI211X1 U80 ( .A0(n404), .A1(n455), .B0(n403), .C0(n402), .Y(n405) );
  OAI211X1 U81 ( .A0(n348), .A1(n451), .B0(n284), .C0(n283), .Y(n285) );
  OAI211X1 U82 ( .A0(n459), .A1(n474), .B0(n458), .C0(n457), .Y(n460) );
  OAI211XL U83 ( .A0(n481), .A1(n451), .B0(n240), .C0(n239), .Y(n241) );
  OAI211XL U84 ( .A0(n481), .A1(n447), .B0(n263), .C0(n262), .Y(n264) );
  OAI211X1 U86 ( .A0(n348), .A1(n447), .B0(n300), .C0(n299), .Y(n301) );
  OAI211X1 U87 ( .A0(n404), .A1(n451), .B0(n397), .C0(n396), .Y(n398) );
  OAI211XL U88 ( .A0(n481), .A1(n443), .B0(n278), .C0(n277), .Y(n279) );
  OAI211X1 U89 ( .A0(n404), .A1(n447), .B0(n394), .C0(n393), .Y(n395) );
  OAI211XL U90 ( .A0(n348), .A1(n443), .B0(n319), .C0(n318), .Y(n320) );
  OAI211X1 U91 ( .A0(n451), .A1(n474), .B0(n450), .C0(n449), .Y(n452) );
  OAI211XL U92 ( .A0(n481), .A1(n439), .B0(n281), .C0(n280), .Y(n282) );
  OAI211XL U93 ( .A0(n348), .A1(n439), .B0(n322), .C0(n321), .Y(n323) );
  OAI211X1 U94 ( .A0(n404), .A1(n443), .B0(n391), .C0(n390), .Y(n392) );
  OAI211X1 U95 ( .A0(n447), .A1(n474), .B0(n446), .C0(n445), .Y(n448) );
  OAI211X1 U96 ( .A0(n443), .A1(n474), .B0(n442), .C0(n441), .Y(n444) );
  OAI211XL U97 ( .A0(n348), .A1(n385), .B0(n347), .C0(n346), .Y(n349) );
  OAI211X1 U98 ( .A0(n404), .A1(n439), .B0(n388), .C0(n387), .Y(n389) );
  OAI211X1 U99 ( .A0(n481), .A1(n385), .B0(n266), .C0(n265), .Y(n267) );
  OAI211X1 U100 ( .A0(n404), .A1(n385), .B0(n384), .C0(n383), .Y(n386) );
  OAI211XL U101 ( .A0(n348), .A1(n381), .B0(n341), .C0(n340), .Y(n342) );
  OAI211X1 U102 ( .A0(n439), .A1(n474), .B0(n438), .C0(n437), .Y(n440) );
  OAI211XL U103 ( .A0(n481), .A1(n381), .B0(n303), .C0(n302), .Y(n304) );
  OAI211X1 U105 ( .A0(n385), .A1(n109), .B0(n25), .C0(n24), .Y(n26) );
  OAI211X1 U106 ( .A0(n435), .A1(n434), .B0(n433), .C0(n432), .Y(n436) );
  AOI221X1 U107 ( .A0(intadd_5_B_0_), .A1(n35), .B0(n34), .B1(n33), .C0(n32), 
        .Y(n40) );
  OAI211XL U108 ( .A0(n481), .A1(n434), .B0(n307), .C0(n306), .Y(n308) );
  OAI211XL U109 ( .A0(n348), .A1(n434), .B0(n338), .C0(n337), .Y(n339) );
  OAI211XL U110 ( .A0(n4), .A1(n331), .B0(n330), .C0(n329), .Y(intadd_3_A_0_)
         );
  OAI211X1 U111 ( .A0(n404), .A1(n434), .B0(n377), .C0(n376), .Y(n378) );
  OAI211X1 U112 ( .A0(n429), .A1(n434), .B0(n428), .C0(n427), .Y(n430) );
  OAI211XL U113 ( .A0(n313), .A1(n434), .B0(n312), .C0(n311), .Y(n314) );
  OAI211XL U114 ( .A0(n335), .A1(n434), .B0(n334), .C0(n333), .Y(n336) );
  OAI211XL U115 ( .A0(n214), .A1(n481), .B0(n212), .C0(n211), .Y(n213) );
  OAI211X1 U117 ( .A0(n287), .A1(n434), .B0(n185), .C0(n184), .Y(n186) );
  OAI211XL U118 ( .A0(n214), .A1(n348), .B0(n197), .C0(n196), .Y(n198) );
  OAI211X1 U119 ( .A0(n214), .A1(n435), .B0(n9), .C0(n8), .Y(n10) );
  OAI211XL U120 ( .A0(n253), .A1(n206), .B0(n192), .C0(n191), .Y(n193) );
  OAI211X1 U121 ( .A0(n289), .A1(n206), .B0(n179), .C0(n178), .Y(n180) );
  OAI211XL U122 ( .A0(n223), .A1(n206), .B0(n205), .C0(n204), .Y(n207) );
  OAI211X1 U123 ( .A0(n361), .A1(n206), .B0(n13), .C0(n12), .Y(n14) );
  AOI32XL U124 ( .A0(dividend[15]), .A1(n478), .A2(n497), .B0(n477), .B1(
        dividend[14]), .Y(n480) );
  OAI2BB1X1 U125 ( .A0N(dividend[15]), .A1N(div_inverse_15_), .B0(n199), .Y(
        n479) );
  XNOR2X1 U127 ( .A(n151), .B(intadd_0_n1), .Y(n494) );
  XNOR2X1 U128 ( .A(n29), .B(n28), .Y(n41) );
  XNOR2X1 U129 ( .A(dividend[5]), .B(n14), .Y(n43) );
  XNOR2X1 U130 ( .A(n18), .B(n10), .Y(n172) );
  XNOR2X1 U131 ( .A(n173), .B(n423), .Y(n20) );
  XNOR2X1 U132 ( .A(n426), .B(n425), .Y(intadd_0_A_0_) );
  XNOR2X1 U133 ( .A(dividend[8]), .B(n180), .Y(n422) );
  AO21XL U134 ( .A0(n422), .A1(n421), .B0(n420), .Y(intadd_0_A_1_) );
  XNOR2X1 U136 ( .A(n420), .B(n419), .Y(intadd_0_A_2_) );
  XNOR2X1 U137 ( .A(dividend[5]), .B(n440), .Y(intadd_0_B_2_) );
  XNOR2X1 U138 ( .A(dividend[8]), .B(n378), .Y(intadd_2_CI) );
  XNOR2X1 U139 ( .A(dividend[11]), .B(n193), .Y(n371) );
  XNOR2X1 U141 ( .A(dividend[8]), .B(n382), .Y(intadd_2_B_1_) );
  XNOR2X1 U142 ( .A(n496), .B(n11), .Y(n206) );
  XNOR2X1 U143 ( .A(dividend[5]), .B(n448), .Y(intadd_0_B_4_) );
  XNOR2X1 U144 ( .A(n367), .B(n370), .Y(n368) );
  XNOR2X1 U145 ( .A(dividend[11]), .B(n336), .Y(intadd_3_CI) );
  XNOR2X1 U146 ( .A(dividend[14]), .B(n207), .Y(n328) );
  XNOR2X1 U147 ( .A(dividend[5]), .B(n452), .Y(intadd_0_B_5_) );
  XNOR2X1 U149 ( .A(n478), .B(n213), .Y(n326) );
  XNOR2X1 U150 ( .A(dividend[11]), .B(n339), .Y(intadd_3_B_1_) );
  XNOR2X1 U151 ( .A(dividend[14]), .B(n314), .Y(intadd_6_A_0_) );
  XNOR2X1 U153 ( .A(dividend[14]), .B(n304), .Y(intadd_6_A_2_) );
  XNOR2X1 U154 ( .A(n18), .B(dividend[4]), .Y(n7) );
  XNOR2X1 U155 ( .A(dividend[11]), .B(n301), .Y(intadd_6_A_3_) );
  XNOR2X1 U157 ( .A(dividend[11]), .B(n285), .Y(intadd_7_B_0_) );
  XNOR2X1 U158 ( .A(dividend[6]), .B(dividend[5]), .Y(n175) );
  XNOR2X1 U159 ( .A(dividend[6]), .B(dividend[7]), .Y(n174) );
  XNOR2X1 U160 ( .A(dividend[8]), .B(dividend[7]), .Y(n176) );
  XNOR2X1 U162 ( .A(dividend[14]), .B(n264), .Y(intadd_4_A_3_) );
  XNOR2X1 U163 ( .A(n372), .B(dividend[10]), .Y(n190) );
  XNOR2X1 U164 ( .A(n478), .B(dividend[13]), .Y(n203) );
  XNOR2X1 U166 ( .A(dividend[8]), .B(n392), .Y(intadd_2_B_4_) );
  XNOR2X1 U167 ( .A(dividend[11]), .B(n342), .Y(intadd_3_B_2_) );
  XNOR2X1 U168 ( .A(n324), .B(n327), .Y(n325) );
  XNOR2X1 U169 ( .A(dividend[11]), .B(n349), .Y(intadd_3_B_3_) );
  XNOR2X1 U171 ( .A(intadd_4_A_0_), .B(dividend[3]), .Y(n15) );
  XNOR2X1 U172 ( .A(dividend[11]), .B(n320), .Y(intadd_3_A_5_) );
  XNOR2X1 U174 ( .A(dividend[11]), .B(n293), .Y(n298) );
  XNOR2X1 U175 ( .A(dividend[5]), .B(n294), .Y(n297) );
  XNOR2X1 U176 ( .A(dividend[11]), .B(n276), .Y(intadd_7_A_2_) );
  XNOR2X1 U178 ( .A(dividend[14]), .B(n250), .Y(n257) );
  XNOR2X1 U179 ( .A(dividend[8]), .B(n247), .Y(n258) );
  XNOR2X1 U180 ( .A(dividend[14]), .B(n244), .Y(intadd_5_B_3_) );
  XNOR2X1 U181 ( .A(dividend[11]), .B(n225), .Y(n231) );
  XNOR2X1 U182 ( .A(dividend[14]), .B(n235), .Y(intadd_8_B_1_) );
  XNOR2X1 U183 ( .A(dividend[5]), .B(n460), .Y(intadd_0_B_7_) );
  XNOR2X1 U184 ( .A(dividend[8]), .B(n395), .Y(intadd_2_B_5_) );
  XNOR2X1 U185 ( .A(dividend[8]), .B(n405), .Y(intadd_2_B_7_) );
  XNOR2X1 U186 ( .A(dividend[8]), .B(n366), .Y(intadd_2_A_8_) );
  XNOR2X1 U187 ( .A(dividend[5]), .B(n363), .Y(intadd_2_A_9_) );
  XNOR2X1 U188 ( .A(dividend[8]), .B(n357), .Y(n358) );
  XNOR2X1 U189 ( .A(dividend[5]), .B(n354), .Y(n359) );
  XNOR2X1 U191 ( .A(dividend[8]), .B(n290), .Y(n296) );
  XNOR2X1 U192 ( .A(dividend[8]), .B(n273), .Y(intadd_7_A_3_) );
  XNOR2X1 U193 ( .A(dividend[11]), .B(n270), .Y(intadd_4_B_5_) );
  XNOR2X1 U194 ( .A(dividend[11]), .B(n254), .Y(n255) );
  XNOR2X1 U195 ( .A(dividend[11]), .B(n246), .Y(intadd_5_B_4_) );
  XNOR2X1 U196 ( .A(dividend[14]), .B(n218), .Y(n220) );
  XNOR2X1 U197 ( .A(dividend[14]), .B(n224), .Y(n230) );
  XNOR2X1 U198 ( .A(dividend[5]), .B(n464), .Y(intadd_0_B_8_) );
  XNOR2X1 U200 ( .A(dividend[5]), .B(n476), .Y(intadd_0_B_10_) );
  XNOR2X1 U201 ( .A(dividend[5]), .B(n414), .Y(n415) );
  XNOR2X1 U202 ( .A(dividend[2]), .B(n115), .Y(n490) );
  INVXL U203 ( .A(div_shift_0_), .Y(n152) );
  INVXL U204 ( .A(div_shift_1_), .Y(n166) );
  INVXL U205 ( .A(n478), .Y(n4) );
  NAND3BX1 U206 ( .AN(n201), .B(n203), .C(n200), .Y(n481) );
  XNOR2X1 U207 ( .A(n372), .B(dividend[12]), .Y(n201) );
  NAND3BX1 U208 ( .AN(n188), .B(n190), .C(n187), .Y(n348) );
  XNOR2X1 U209 ( .A(n424), .B(dividend[9]), .Y(n188) );
  BUFX2 U211 ( .A(div_inverse_2_), .Y(n496) );
  INVXL U212 ( .A(dividend[2]), .Y(intadd_4_A_0_) );
  INVXL U213 ( .A(intadd_4_A_0_), .Y(intadd_5_B_0_) );
  BUFX2 U214 ( .A(div_inverse_14_), .Y(n497) );
  INVXL U215 ( .A(div_shift_2_), .Y(n495) );
  AOI22XL U216 ( .A0(div_shift_0_), .A1(intadd_0_SUM_16_), .B0(
        intadd_0_SUM_15_), .B1(n152), .Y(n124) );
  AOI22XL U217 ( .A0(div_shift_0_), .A1(intadd_0_SUM_14_), .B0(
        intadd_0_SUM_13_), .B1(n152), .Y(n127) );
  AOI22XL U218 ( .A0(div_shift_1_), .A1(n124), .B0(n127), .B1(n166), .Y(n137)
         );
  AOI22XL U219 ( .A0(div_shift_0_), .A1(intadd_0_SUM_12_), .B0(
        intadd_0_SUM_11_), .B1(n152), .Y(n126) );
  INVXL U220 ( .A(dividend[5]), .Y(n18) );
  INVXL U221 ( .A(div_inverse_1_), .Y(n214) );
  NAND3BXL U222 ( .AN(n15), .B(n7), .C(n5), .Y(n435) );
  NOR2XL U223 ( .A(n15), .B(n5), .Y(n471) );
  NAND2XL U224 ( .A(n7), .B(n15), .Y(n361) );
  INVXL U225 ( .A(n361), .Y(n469) );
  AOI22XL U226 ( .A0(n496), .A1(n471), .B0(n469), .B1(intadd_1_SUM_0_), .Y(n9)
         );
  INVXL U227 ( .A(n15), .Y(n6) );
  NOR2XL U228 ( .A(n7), .B(n6), .Y(n431) );
  NAND2XL U229 ( .A(div_inverse_3_), .B(n431), .Y(n8) );
  NOR2XL U230 ( .A(div_inverse_0_), .B(n214), .Y(n11) );
  INVXL U231 ( .A(n435), .Y(n470) );
  AOI22XL U232 ( .A0(n471), .A1(div_inverse_1_), .B0(n470), .B1(div_inverse_0_), .Y(n13) );
  NAND2XL U233 ( .A(n431), .B(n496), .Y(n12) );
  NAND2XL U234 ( .A(n15), .B(div_inverse_0_), .Y(n34) );
  INVXL U235 ( .A(n34), .Y(n27) );
  INVXL U236 ( .A(div_inverse_0_), .Y(n215) );
  INVXL U237 ( .A(n471), .Y(n429) );
  INVXL U238 ( .A(n431), .Y(n474) );
  NAND2XL U239 ( .A(div_inverse_1_), .B(div_inverse_0_), .Y(n17) );
  NAND2XL U240 ( .A(n214), .B(n215), .Y(n16) );
  NAND2XL U241 ( .A(n17), .B(n16), .Y(n208) );
  OAI222XL U242 ( .A0(n215), .A1(n429), .B0(n214), .B1(n474), .C0(n361), .C1(
        n208), .Y(n29) );
  NOR2XL U243 ( .A(n18), .B(n29), .Y(n19) );
  NAND2XL U244 ( .A(n34), .B(n19), .Y(n42) );
  NOR2XL U245 ( .A(n43), .B(n42), .Y(n173) );
  NOR2XL U246 ( .A(n215), .B(n175), .Y(n181) );
  INVXL U247 ( .A(n181), .Y(n423) );
  XOR2XL U248 ( .A(n172), .B(n20), .Y(n52) );
  INVXL U249 ( .A(div_inverse_5_), .Y(n385) );
  AOI21XL U250 ( .A0(dividend[1]), .A1(intadd_4_A_0_), .B0(n21), .Y(n22) );
  INVXL U251 ( .A(dividend[0]), .Y(n23) );
  NAND2XL U252 ( .A(n21), .B(n23), .Y(n409) );
  INVXL U253 ( .A(n409), .Y(n107) );
  NOR2XL U254 ( .A(n22), .B(n23), .Y(n112) );
  AOI22XL U255 ( .A0(div_inverse_3_), .A1(n107), .B0(n112), .B1(
        intadd_1_SUM_2_), .Y(n25) );
  NAND2XL U256 ( .A(dividend[1]), .B(n23), .Y(n114) );
  INVXL U257 ( .A(n114), .Y(n108) );
  NAND2XL U258 ( .A(n108), .B(div_inverse_4_), .Y(n24) );
  NAND2XL U259 ( .A(dividend[5]), .B(n27), .Y(n28) );
  INVXL U260 ( .A(div_inverse_3_), .Y(n434) );
  AOI22XL U261 ( .A0(div_inverse_1_), .A1(n107), .B0(intadd_1_SUM_0_), .B1(
        n112), .Y(n31) );
  NAND2XL U262 ( .A(n496), .B(n108), .Y(n30) );
  INVXL U263 ( .A(n496), .Y(n216) );
  NAND4XL U264 ( .A(dividend[2]), .B(n214), .C(n216), .D(n215), .Y(n33) );
  NOR2XL U265 ( .A(n35), .B(dividend[2]), .Y(n32) );
  INVXL U266 ( .A(div_inverse_4_), .Y(n381) );
  AOI22XL U267 ( .A0(n496), .A1(n107), .B0(n112), .B1(intadd_1_SUM_1_), .Y(n37) );
  NAND2XL U268 ( .A(div_inverse_3_), .B(n108), .Y(n36) );
  OAI222XL U269 ( .A0(n41), .A1(n40), .B0(n41), .B1(n39), .C0(n39), .C1(n40), 
        .Y(n45) );
  OAI222XL U270 ( .A0(n46), .A1(n45), .B0(n46), .B1(n44), .C0(n44), .C1(n45), 
        .Y(n51) );
  INVXL U271 ( .A(div_inverse_6_), .Y(n439) );
  AOI22XL U272 ( .A0(n107), .A1(div_inverse_4_), .B0(n112), .B1(
        intadd_1_SUM_3_), .Y(n48) );
  NAND2XL U273 ( .A(n108), .B(div_inverse_5_), .Y(n47) );
  OAI222XL U274 ( .A0(n52), .A1(n51), .B0(n52), .B1(n50), .C0(n50), .C1(n51), 
        .Y(n58) );
  INVXL U275 ( .A(div_inverse_7_), .Y(n443) );
  NOR2XL U276 ( .A(n109), .B(n443), .Y(n54) );
  OAI22XL U277 ( .A0(n114), .A1(n439), .B0(n409), .B1(n385), .Y(n53) );
  AOI211XL U278 ( .A0(n112), .A1(intadd_1_SUM_4_), .B0(n54), .C0(n53), .Y(n56)
         );
  NAND2XL U279 ( .A(n56), .B(intadd_5_B_0_), .Y(n55) );
  INVXL U280 ( .A(div_inverse_8_), .Y(n447) );
  NOR2XL U281 ( .A(n109), .B(n447), .Y(n60) );
  OAI22XL U282 ( .A0(n114), .A1(n443), .B0(n409), .B1(n439), .Y(n59) );
  AOI211XL U283 ( .A0(n112), .A1(intadd_1_SUM_5_), .B0(n60), .C0(n59), .Y(n62)
         );
  NAND2XL U284 ( .A(n62), .B(intadd_5_B_0_), .Y(n61) );
  INVXL U285 ( .A(div_inverse_9_), .Y(n451) );
  NOR2XL U286 ( .A(n109), .B(n451), .Y(n66) );
  OAI22XL U287 ( .A0(n114), .A1(n447), .B0(n409), .B1(n443), .Y(n65) );
  AOI211XL U288 ( .A0(n112), .A1(intadd_1_SUM_6_), .B0(n66), .C0(n65), .Y(n68)
         );
  NAND2XL U289 ( .A(n68), .B(intadd_5_B_0_), .Y(n67) );
  INVXL U290 ( .A(div_inverse_10_), .Y(n455) );
  NOR2XL U291 ( .A(n109), .B(n455), .Y(n72) );
  OAI22XL U292 ( .A0(n114), .A1(n451), .B0(n409), .B1(n447), .Y(n71) );
  AOI211XL U293 ( .A0(n112), .A1(intadd_1_SUM_7_), .B0(n72), .C0(n71), .Y(n74)
         );
  NAND2XL U294 ( .A(n74), .B(intadd_5_B_0_), .Y(n73) );
  INVXL U295 ( .A(div_inverse_11_), .Y(n459) );
  NOR2XL U296 ( .A(n109), .B(n459), .Y(n78) );
  OAI22XL U297 ( .A0(n114), .A1(n455), .B0(n409), .B1(n451), .Y(n77) );
  AOI211XL U298 ( .A0(n112), .A1(intadd_1_SUM_8_), .B0(n78), .C0(n77), .Y(n80)
         );
  NAND2XL U299 ( .A(n80), .B(intadd_5_B_0_), .Y(n79) );
  INVXL U300 ( .A(div_inverse_12_), .Y(n463) );
  NOR2XL U301 ( .A(n109), .B(n463), .Y(n84) );
  OAI22XL U302 ( .A0(n114), .A1(n459), .B0(n409), .B1(n455), .Y(n83) );
  AOI211XL U303 ( .A0(n112), .A1(intadd_1_SUM_9_), .B0(n84), .C0(n83), .Y(n86)
         );
  NAND2XL U304 ( .A(n86), .B(intadd_5_B_0_), .Y(n85) );
  INVXL U305 ( .A(div_inverse_13_), .Y(n467) );
  NOR2XL U306 ( .A(n109), .B(n467), .Y(n90) );
  OAI22XL U307 ( .A0(n114), .A1(n463), .B0(n409), .B1(n459), .Y(n89) );
  AOI211XL U308 ( .A0(n112), .A1(intadd_1_SUM_10_), .B0(n90), .C0(n89), .Y(n92) );
  NAND2XL U309 ( .A(n92), .B(intadd_5_B_0_), .Y(n91) );
  INVXL U310 ( .A(n497), .Y(n475) );
  NOR2XL U311 ( .A(n109), .B(n475), .Y(n96) );
  OAI22XL U312 ( .A0(n114), .A1(n467), .B0(n409), .B1(n463), .Y(n95) );
  AOI211XL U313 ( .A0(n112), .A1(intadd_1_SUM_11_), .B0(n96), .C0(n95), .Y(n98) );
  NAND2XL U314 ( .A(n98), .B(intadd_5_B_0_), .Y(n97) );
  INVXL U315 ( .A(div_inverse_15_), .Y(n413) );
  NOR2XL U316 ( .A(n109), .B(n413), .Y(n102) );
  OAI22XL U317 ( .A0(n114), .A1(n475), .B0(n409), .B1(n467), .Y(n101) );
  AOI211XL U318 ( .A0(n112), .A1(intadd_1_SUM_12_), .B0(n102), .C0(n101), .Y(
        n104) );
  NAND2XL U319 ( .A(n104), .B(intadd_5_B_0_), .Y(n103) );
  AOI21XL U320 ( .A0(intadd_1_n1), .A1(div_inverse_15_), .B0(n406), .Y(n362)
         );
  INVXL U321 ( .A(n112), .Y(n407) );
  AOI22XL U322 ( .A0(n108), .A1(div_inverse_15_), .B0(n107), .B1(n497), .Y(
        n110) );
  NAND2XL U323 ( .A(n112), .B(n406), .Y(n113) );
  NOR2XL U324 ( .A(n152), .B(div_shift_1_), .Y(n145) );
  INVXL U325 ( .A(n145), .Y(n168) );
  ADDFX1 U326 ( .A(intadd_0_SUM_9_), .B(n117), .CI(n116), .CO(n491), .S(n118)
         );
  INVXL U327 ( .A(n155), .Y(n493) );
  OAI22XL U328 ( .A0(n121), .A1(n168), .B0(n118), .B1(n493), .Y(n119) );
  OAI21XL U329 ( .A0(n495), .A1(n137), .B0(n120), .Y(quotient[0]) );
  AOI22XL U330 ( .A0(div_shift_0_), .A1(intadd_0_SUM_17_), .B0(
        intadd_0_SUM_16_), .B1(n152), .Y(n129) );
  AOI22XL U331 ( .A0(div_shift_0_), .A1(intadd_0_SUM_15_), .B0(
        intadd_0_SUM_14_), .B1(n152), .Y(n132) );
  AOI22XL U332 ( .A0(div_shift_1_), .A1(n129), .B0(n132), .B1(n166), .Y(n141)
         );
  AOI22XL U333 ( .A0(div_shift_0_), .A1(intadd_0_SUM_11_), .B0(n121), .B1(n152), .Y(n122) );
  AOI22XL U334 ( .A0(div_shift_0_), .A1(intadd_0_SUM_13_), .B0(
        intadd_0_SUM_12_), .B1(n152), .Y(n131) );
  OAI21XL U335 ( .A0(n495), .A1(n141), .B0(n123), .Y(quotient[1]) );
  INVXL U336 ( .A(intadd_0_SUM_18_), .Y(n136) );
  NOR2XL U337 ( .A(n166), .B(n152), .Y(n156) );
  INVXL U338 ( .A(intadd_0_SUM_17_), .Y(n125) );
  NOR2XL U339 ( .A(div_shift_0_), .B(n166), .Y(n157) );
  AOI22XL U340 ( .A0(div_shift_1_), .A1(n127), .B0(n126), .B1(n166), .Y(n128)
         );
  AOI22XL U341 ( .A0(div_shift_2_), .A1(n144), .B0(n128), .B1(n495), .Y(
        quotient[2]) );
  INVXL U342 ( .A(intadd_0_SUM_19_), .Y(n130) );
  AOI22XL U343 ( .A0(div_shift_1_), .A1(n132), .B0(n131), .B1(n166), .Y(n133)
         );
  AOI22XL U344 ( .A0(div_shift_2_), .A1(n148), .B0(n133), .B1(n495), .Y(
        quotient[3]) );
  AOI22XL U345 ( .A0(n155), .A1(intadd_0_SUM_17_), .B0(intadd_0_SUM_20_), .B1(
        n156), .Y(n135) );
  NAND2XL U346 ( .A(n157), .B(intadd_0_SUM_19_), .Y(n134) );
  AOI22XL U347 ( .A0(div_shift_2_), .A1(n160), .B0(n137), .B1(n495), .Y(
        quotient[4]) );
  INVXL U348 ( .A(n156), .Y(n161) );
  INVXL U349 ( .A(intadd_0_SUM_21_), .Y(n140) );
  AOI22XL U350 ( .A0(n145), .A1(intadd_0_SUM_19_), .B0(n155), .B1(
        intadd_0_SUM_18_), .Y(n139) );
  NAND2XL U351 ( .A(n157), .B(intadd_0_SUM_20_), .Y(n138) );
  AOI22XL U352 ( .A0(div_shift_2_), .A1(n170), .B0(n141), .B1(n495), .Y(
        quotient[5]) );
  INVXL U353 ( .A(intadd_0_SUM_22_), .Y(n165) );
  AOI22XL U354 ( .A0(n145), .A1(intadd_0_SUM_20_), .B0(n155), .B1(
        intadd_0_SUM_19_), .Y(n143) );
  NAND2XL U355 ( .A(n157), .B(intadd_0_SUM_21_), .Y(n142) );
  AOI22XL U356 ( .A0(div_shift_2_), .A1(n163), .B0(n144), .B1(n495), .Y(
        quotient[6]) );
  INVXL U357 ( .A(intadd_0_SUM_23_), .Y(n169) );
  AOI22XL U358 ( .A0(n155), .A1(intadd_0_SUM_20_), .B0(intadd_0_SUM_22_), .B1(
        n157), .Y(n147) );
  NAND2XL U359 ( .A(n145), .B(intadd_0_SUM_21_), .Y(n146) );
  AOI22XL U360 ( .A0(div_shift_2_), .A1(n153), .B0(n148), .B1(n495), .Y(
        quotient[7]) );
  INVXL U361 ( .A(n150), .Y(n486) );
  OAI21XL U362 ( .A0(dividend[15]), .A1(dividend[14]), .B0(n150), .Y(n199) );
  INVXL U363 ( .A(n199), .Y(n485) );
  AOI22XL U364 ( .A0(div_inverse_13_), .A1(n486), .B0(n497), .B1(n485), .Y(
        n477) );
  INVXL U365 ( .A(n477), .Y(n489) );
  NAND2XL U366 ( .A(n489), .B(n479), .Y(n149) );
  MX2XL U367 ( .A(n150), .B(dividend[15]), .S0(n149), .Y(n151) );
  AOI22XL U368 ( .A0(div_shift_0_), .A1(n494), .B0(intadd_0_SUM_24_), .B1(n152), .Y(n167) );
  NAND2XL U369 ( .A(n166), .B(n167), .Y(n154) );
  NOR2XL U370 ( .A(div_shift_2_), .B(n154), .Y(quotient[15]) );
  AOI22XL U371 ( .A0(div_shift_2_), .A1(n154), .B0(n153), .B1(n495), .Y(
        quotient[11]) );
  AOI22XL U372 ( .A0(intadd_0_SUM_24_), .A1(n156), .B0(n155), .B1(
        intadd_0_SUM_21_), .Y(n159) );
  NAND2XL U373 ( .A(intadd_0_SUM_23_), .B(n157), .Y(n158) );
  AOI22XL U374 ( .A0(div_shift_2_), .A1(n492), .B0(n160), .B1(n495), .Y(
        quotient[8]) );
  AOI22XL U375 ( .A0(div_shift_1_), .A1(n494), .B0(div_shift_0_), .B1(
        intadd_0_SUM_24_), .Y(n162) );
  NOR2XL U376 ( .A(div_shift_2_), .B(n164), .Y(quotient[14]) );
  AOI22XL U377 ( .A0(div_shift_2_), .A1(n164), .B0(n163), .B1(n495), .Y(
        quotient[10]) );
  OAI222XL U378 ( .A0(n169), .A1(n168), .B0(n167), .B1(n166), .C0(n493), .C1(
        n165), .Y(n171) );
  NOR2XL U379 ( .A(div_shift_2_), .B(n171), .Y(quotient[13]) );
  AOI22XL U380 ( .A0(div_shift_2_), .A1(n171), .B0(n170), .B1(n495), .Y(
        quotient[9]) );
  OAI21XL U381 ( .A0(n181), .A1(n173), .B0(n172), .Y(intadd_0_B_0_) );
  INVXL U382 ( .A(dividend[8]), .Y(n424) );
  INVXL U383 ( .A(n188), .Y(n189) );
  NOR2XL U384 ( .A(n215), .B(n189), .Y(n417) );
  NOR2XL U385 ( .A(n175), .B(n176), .Y(n399) );
  INVXL U386 ( .A(n399), .Y(n289) );
  INVXL U387 ( .A(n175), .Y(n177) );
  NOR2XL U388 ( .A(n177), .B(n174), .Y(n286) );
  NAND3BXL U389 ( .AN(n176), .B(n175), .C(n174), .Y(n272) );
  INVXL U390 ( .A(n272), .Y(n400) );
  AOI22XL U391 ( .A0(div_inverse_1_), .A1(n286), .B0(div_inverse_0_), .B1(n400), .Y(n179) );
  NAND2XL U392 ( .A(n177), .B(n176), .Y(n287) );
  INVXL U393 ( .A(n287), .Y(n401) );
  NAND2XL U394 ( .A(n496), .B(n401), .Y(n178) );
  NOR2XL U395 ( .A(n181), .B(n424), .Y(n183) );
  INVXL U396 ( .A(n286), .Y(n404) );
  OAI222XL U397 ( .A0(n289), .A1(n208), .B0(n287), .B1(n214), .C0(n404), .C1(
        n215), .Y(n426) );
  INVXL U398 ( .A(n426), .Y(n182) );
  NAND2XL U399 ( .A(n183), .B(n182), .Y(n421) );
  NOR2XL U400 ( .A(n422), .B(n421), .Y(n420) );
  AOI22XL U401 ( .A0(div_inverse_1_), .A1(n400), .B0(intadd_1_SUM_0_), .B1(
        n399), .Y(n185) );
  NAND2XL U402 ( .A(n496), .B(n286), .Y(n184) );
  OAI21XL U403 ( .A0(n417), .A1(n420), .B0(n418), .Y(intadd_2_B_0_) );
  INVXL U404 ( .A(dividend[11]), .Y(n372) );
  INVXL U405 ( .A(n201), .Y(n202) );
  NOR2XL U406 ( .A(n215), .B(n202), .Y(n367) );
  NAND2XL U407 ( .A(n188), .B(n190), .Y(n253) );
  NOR2XL U408 ( .A(n188), .B(n187), .Y(n344) );
  INVXL U409 ( .A(n348), .Y(n332) );
  AOI22XL U410 ( .A0(div_inverse_1_), .A1(n344), .B0(div_inverse_0_), .B1(n332), .Y(n192) );
  NOR2XL U411 ( .A(n190), .B(n189), .Y(n345) );
  NAND2XL U412 ( .A(n496), .B(n345), .Y(n191) );
  NOR2XL U413 ( .A(n417), .B(n372), .Y(n195) );
  INVXL U414 ( .A(n345), .Y(n251) );
  INVXL U415 ( .A(n344), .Y(n335) );
  OAI222XL U416 ( .A0(n253), .A1(n208), .B0(n251), .B1(n214), .C0(n335), .C1(
        n215), .Y(n375) );
  INVXL U417 ( .A(n375), .Y(n194) );
  NAND2XL U418 ( .A(n195), .B(n194), .Y(n374) );
  NOR2XL U419 ( .A(n371), .B(n374), .Y(n370) );
  INVXL U420 ( .A(n253), .Y(n343) );
  AOI22XL U421 ( .A0(n496), .A1(n344), .B0(intadd_1_SUM_0_), .B1(n343), .Y(
        n197) );
  NAND2XL U422 ( .A(div_inverse_3_), .B(n345), .Y(n196) );
  OAI21XL U423 ( .A0(n367), .A1(n370), .B0(n369), .Y(intadd_3_B_0_) );
  NOR2XL U424 ( .A(n215), .B(n199), .Y(n324) );
  INVXL U425 ( .A(dividend[14]), .Y(n478) );
  NAND2XL U426 ( .A(n201), .B(n203), .Y(n223) );
  NOR2XL U427 ( .A(n201), .B(n200), .Y(n305) );
  INVXL U428 ( .A(n481), .Y(n309) );
  AOI22XL U429 ( .A0(div_inverse_1_), .A1(n305), .B0(div_inverse_0_), .B1(n309), .Y(n205) );
  NOR2XL U430 ( .A(n203), .B(n202), .Y(n310) );
  NAND2XL U431 ( .A(n496), .B(n310), .Y(n204) );
  INVXL U432 ( .A(n367), .Y(n210) );
  INVXL U433 ( .A(n310), .Y(n221) );
  INVXL U434 ( .A(n305), .Y(n313) );
  OAI222XL U435 ( .A0(n223), .A1(n208), .B0(n221), .B1(n214), .C0(n313), .C1(
        n215), .Y(n331) );
  NOR2XL U436 ( .A(n478), .B(n331), .Y(n209) );
  NAND2XL U437 ( .A(n210), .B(n209), .Y(n330) );
  NOR2XL U438 ( .A(n328), .B(n330), .Y(n327) );
  INVXL U439 ( .A(n223), .Y(n483) );
  AOI22XL U440 ( .A0(n496), .A1(n305), .B0(intadd_1_SUM_0_), .B1(n483), .Y(
        n212) );
  NAND2XL U441 ( .A(div_inverse_3_), .B(n310), .Y(n211) );
  OAI21XL U442 ( .A0(n324), .A1(n327), .B0(n326), .Y(intadd_6_CI) );
  AOI22XL U443 ( .A0(div_inverse_1_), .A1(n485), .B0(div_inverse_0_), .B1(n486), .Y(intadd_6_B_0_) );
  AOI22XL U444 ( .A0(n496), .A1(n485), .B0(div_inverse_1_), .B1(n486), .Y(
        intadd_6_B_1_) );
  AOI22XL U445 ( .A0(div_inverse_3_), .A1(n485), .B0(n496), .B1(n486), .Y(
        intadd_6_B_2_) );
  AOI22XL U446 ( .A0(div_inverse_3_), .A1(n486), .B0(div_inverse_4_), .B1(n485), .Y(intadd_4_CI) );
  AOI22XL U447 ( .A0(div_inverse_4_), .A1(n486), .B0(div_inverse_5_), .B1(n485), .Y(intadd_4_B_1_) );
  AOI22XL U448 ( .A0(div_inverse_5_), .A1(n486), .B0(div_inverse_6_), .B1(n485), .Y(intadd_4_B_2_) );
  AOI22XL U449 ( .A0(div_inverse_6_), .A1(n486), .B0(div_inverse_7_), .B1(n485), .Y(intadd_5_CI) );
  AOI22XL U450 ( .A0(div_inverse_7_), .A1(n486), .B0(div_inverse_8_), .B1(n485), .Y(intadd_8_B_0_) );
  INVXL U451 ( .A(intadd_8_B_0_), .Y(intadd_5_B_1_) );
  AOI22XL U452 ( .A0(div_inverse_8_), .A1(n486), .B0(div_inverse_9_), .B1(n485), .Y(intadd_5_B_2_) );
  AOI22XL U453 ( .A0(div_inverse_9_), .A1(n486), .B0(div_inverse_10_), .B1(
        n485), .Y(intadd_8_CI) );
  AOI22XL U454 ( .A0(div_inverse_10_), .A1(n486), .B0(div_inverse_11_), .B1(
        n485), .Y(n227) );
  INVXL U455 ( .A(n227), .Y(intadd_8_A_1_) );
  AOI21XL U456 ( .A0(n216), .A1(n215), .B0(n214), .Y(intadd_1_CI) );
  NAND2XL U457 ( .A(n483), .B(n406), .Y(n217) );
  OAI211XL U458 ( .A0(n413), .A1(n481), .B0(n313), .C0(n217), .Y(n218) );
  AOI22XL U459 ( .A0(div_inverse_12_), .A1(n486), .B0(div_inverse_13_), .B1(
        n485), .Y(n226) );
  ADDFX1 U460 ( .A(n220), .B(n489), .CI(n219), .CO(intadd_0_B_23_), .S(
        intadd_0_A_22_) );
  AOI22XL U461 ( .A0(n497), .A1(n309), .B0(div_inverse_15_), .B1(n305), .Y(
        n222) );
  AOI22XL U462 ( .A0(div_inverse_11_), .A1(n486), .B0(div_inverse_12_), .B1(
        n485), .Y(n232) );
  INVXL U463 ( .A(n406), .Y(n482) );
  ADDFX1 U464 ( .A(dividend[11]), .B(n227), .CI(n226), .CO(n219), .S(n228) );
  ADDFX1 U465 ( .A(n230), .B(n229), .CI(n228), .CO(intadd_0_B_22_), .S(
        intadd_0_A_21_) );
  ADDFX1 U466 ( .A(intadd_8_A_1_), .B(n232), .CI(n231), .CO(n229), .S(
        intadd_8_A_2_) );
  AOI22XL U467 ( .A0(div_inverse_13_), .A1(n305), .B0(intadd_1_SUM_11_), .B1(
        n483), .Y(n234) );
  NAND2XL U468 ( .A(n497), .B(n310), .Y(n233) );
  AOI22XL U469 ( .A0(n497), .A1(n305), .B0(intadd_1_SUM_12_), .B1(n483), .Y(
        n237) );
  NAND2XL U470 ( .A(div_inverse_15_), .B(n310), .Y(n236) );
  OAI211XL U471 ( .A0(n481), .A1(n467), .B0(n237), .C0(n236), .Y(n238) );
  AOI22XL U472 ( .A0(div_inverse_10_), .A1(n305), .B0(intadd_1_SUM_8_), .B1(
        n483), .Y(n240) );
  NAND2XL U473 ( .A(div_inverse_11_), .B(n310), .Y(n239) );
  AOI22XL U474 ( .A0(div_inverse_12_), .A1(n305), .B0(intadd_1_SUM_10_), .B1(
        n483), .Y(n243) );
  NAND2XL U475 ( .A(div_inverse_13_), .B(n310), .Y(n242) );
  NAND2XL U476 ( .A(n343), .B(n406), .Y(n245) );
  OAI211XL U477 ( .A0(n413), .A1(n348), .B0(n335), .C0(n245), .Y(n246) );
  AOI22XL U478 ( .A0(div_inverse_11_), .A1(n305), .B0(intadd_1_SUM_9_), .B1(
        n483), .Y(n249) );
  NAND2XL U479 ( .A(div_inverse_12_), .B(n310), .Y(n248) );
  AOI22XL U480 ( .A0(n497), .A1(n332), .B0(div_inverse_15_), .B1(n344), .Y(
        n252) );
  ADDFX1 U481 ( .A(intadd_5_SUM_3_), .B(n256), .CI(n255), .CO(intadd_0_B_19_), 
        .S(intadd_0_A_18_) );
  ADDFX1 U482 ( .A(n258), .B(n257), .CI(intadd_5_SUM_2_), .CO(n256), .S(
        intadd_4_A_5_) );
  AOI22XL U483 ( .A0(div_inverse_13_), .A1(n344), .B0(intadd_1_SUM_11_), .B1(
        n343), .Y(n260) );
  NAND2XL U484 ( .A(n497), .B(n345), .Y(n259) );
  AOI22XL U485 ( .A0(div_inverse_9_), .A1(n305), .B0(intadd_1_SUM_7_), .B1(
        n483), .Y(n263) );
  NAND2XL U486 ( .A(div_inverse_10_), .B(n310), .Y(n262) );
  AOI22XL U487 ( .A0(div_inverse_6_), .A1(n305), .B0(intadd_1_SUM_4_), .B1(
        n483), .Y(n266) );
  NAND2XL U488 ( .A(div_inverse_7_), .B(n310), .Y(n265) );
  AOI22XL U489 ( .A0(n497), .A1(n344), .B0(intadd_1_SUM_12_), .B1(n343), .Y(
        n269) );
  NAND2XL U490 ( .A(div_inverse_15_), .B(n345), .Y(n268) );
  OAI211XL U491 ( .A0(n348), .A1(n467), .B0(n269), .C0(n268), .Y(n270) );
  NAND2XL U492 ( .A(n399), .B(n406), .Y(n271) );
  AOI22XL U493 ( .A0(div_inverse_12_), .A1(n344), .B0(intadd_1_SUM_10_), .B1(
        n343), .Y(n275) );
  NAND2XL U494 ( .A(div_inverse_13_), .B(n345), .Y(n274) );
  AOI22XL U495 ( .A0(div_inverse_8_), .A1(n305), .B0(intadd_1_SUM_6_), .B1(
        n483), .Y(n278) );
  NAND2XL U496 ( .A(div_inverse_9_), .B(n310), .Y(n277) );
  AOI22XL U497 ( .A0(div_inverse_7_), .A1(n305), .B0(intadd_1_SUM_5_), .B1(
        n483), .Y(n281) );
  NAND2XL U498 ( .A(div_inverse_8_), .B(n310), .Y(n280) );
  AOI22XL U499 ( .A0(div_inverse_10_), .A1(n344), .B0(intadd_1_SUM_8_), .B1(
        n343), .Y(n284) );
  NAND2XL U500 ( .A(div_inverse_11_), .B(n345), .Y(n283) );
  AOI22XL U501 ( .A0(n497), .A1(n400), .B0(div_inverse_15_), .B1(n286), .Y(
        n288) );
  AOI22XL U502 ( .A0(div_inverse_11_), .A1(n344), .B0(intadd_1_SUM_9_), .B1(
        n343), .Y(n292) );
  NAND2XL U503 ( .A(div_inverse_12_), .B(n345), .Y(n291) );
  ADDFX1 U504 ( .A(n296), .B(n295), .CI(intadd_7_SUM_2_), .CO(intadd_0_B_16_), 
        .S(intadd_0_A_15_) );
  ADDFX1 U505 ( .A(intadd_7_SUM_1_), .B(n298), .CI(n297), .CO(n295), .S(
        intadd_3_A_8_) );
  AOI22XL U506 ( .A0(div_inverse_9_), .A1(n344), .B0(intadd_1_SUM_7_), .B1(
        n343), .Y(n300) );
  NAND2XL U507 ( .A(div_inverse_10_), .B(n345), .Y(n299) );
  AOI22XL U508 ( .A0(div_inverse_5_), .A1(n305), .B0(intadd_1_SUM_3_), .B1(
        n483), .Y(n303) );
  NAND2XL U509 ( .A(div_inverse_6_), .B(n310), .Y(n302) );
  AOI22XL U510 ( .A0(div_inverse_4_), .A1(n305), .B0(intadd_1_SUM_2_), .B1(
        n483), .Y(n307) );
  NAND2XL U511 ( .A(div_inverse_5_), .B(n310), .Y(n306) );
  AOI22XL U512 ( .A0(n496), .A1(n309), .B0(intadd_1_SUM_1_), .B1(n483), .Y(
        n312) );
  NAND2XL U513 ( .A(div_inverse_4_), .B(n310), .Y(n311) );
  AOI22XL U514 ( .A0(div_inverse_11_), .A1(n400), .B0(intadd_1_SUM_10_), .B1(
        n399), .Y(n316) );
  NAND2XL U515 ( .A(div_inverse_13_), .B(n401), .Y(n315) );
  AOI22XL U516 ( .A0(div_inverse_8_), .A1(n344), .B0(intadd_1_SUM_6_), .B1(
        n343), .Y(n319) );
  NAND2XL U517 ( .A(div_inverse_9_), .B(n345), .Y(n318) );
  AOI22XL U518 ( .A0(div_inverse_7_), .A1(n344), .B0(intadd_1_SUM_5_), .B1(
        n343), .Y(n322) );
  NAND2XL U519 ( .A(div_inverse_8_), .B(n345), .Y(n321) );
  XOR2XL U520 ( .A(n326), .B(n325), .Y(intadd_3_A_2_) );
  AO21XL U521 ( .A0(n328), .A1(n330), .B0(n327), .Y(intadd_3_A_1_) );
  NAND3BXL U522 ( .AN(n478), .B(n367), .C(n331), .Y(n329) );
  AOI22XL U523 ( .A0(n496), .A1(n332), .B0(intadd_1_SUM_1_), .B1(n343), .Y(
        n334) );
  NAND2XL U524 ( .A(div_inverse_4_), .B(n345), .Y(n333) );
  AOI22XL U525 ( .A0(div_inverse_4_), .A1(n344), .B0(intadd_1_SUM_2_), .B1(
        n343), .Y(n338) );
  NAND2XL U526 ( .A(div_inverse_5_), .B(n345), .Y(n337) );
  AOI22XL U527 ( .A0(div_inverse_5_), .A1(n344), .B0(intadd_1_SUM_3_), .B1(
        n343), .Y(n341) );
  NAND2XL U528 ( .A(div_inverse_6_), .B(n345), .Y(n340) );
  AOI22XL U529 ( .A0(div_inverse_6_), .A1(n344), .B0(intadd_1_SUM_4_), .B1(
        n343), .Y(n347) );
  NAND2XL U530 ( .A(div_inverse_7_), .B(n345), .Y(n346) );
  AOI22XL U531 ( .A0(div_inverse_13_), .A1(n400), .B0(intadd_1_SUM_12_), .B1(
        n399), .Y(n351) );
  NAND2XL U532 ( .A(div_inverse_15_), .B(n401), .Y(n350) );
  NAND2XL U533 ( .A(n469), .B(n406), .Y(n353) );
  AOI22XL U534 ( .A0(div_inverse_12_), .A1(n400), .B0(intadd_1_SUM_11_), .B1(
        n399), .Y(n356) );
  NAND2XL U535 ( .A(n497), .B(n401), .Y(n355) );
  ADDFX1 U536 ( .A(intadd_3_SUM_7_), .B(n359), .CI(n358), .CO(intadd_0_B_14_), 
        .S(intadd_0_A_13_) );
  AOI22XL U537 ( .A0(n471), .A1(div_inverse_15_), .B0(n470), .B1(n497), .Y(
        n360) );
  AOI22XL U538 ( .A0(div_inverse_10_), .A1(n400), .B0(intadd_1_SUM_9_), .B1(
        n399), .Y(n365) );
  NAND2XL U539 ( .A(div_inverse_12_), .B(n401), .Y(n364) );
  XOR2XL U540 ( .A(n369), .B(n368), .Y(intadd_2_A_2_) );
  AO21XL U541 ( .A0(n371), .A1(n374), .B0(n370), .Y(intadd_2_A_1_) );
  NAND3BXL U542 ( .AN(n372), .B(n417), .C(n375), .Y(n373) );
  AOI22XL U543 ( .A0(n496), .A1(n400), .B0(intadd_1_SUM_1_), .B1(n399), .Y(
        n377) );
  NAND2XL U544 ( .A(div_inverse_4_), .B(n401), .Y(n376) );
  AOI22XL U545 ( .A0(div_inverse_3_), .A1(n400), .B0(intadd_1_SUM_2_), .B1(
        n399), .Y(n380) );
  NAND2XL U546 ( .A(div_inverse_5_), .B(n401), .Y(n379) );
  AOI22XL U547 ( .A0(div_inverse_4_), .A1(n400), .B0(intadd_1_SUM_3_), .B1(
        n399), .Y(n384) );
  NAND2XL U548 ( .A(div_inverse_6_), .B(n401), .Y(n383) );
  AOI22XL U549 ( .A0(div_inverse_5_), .A1(n400), .B0(intadd_1_SUM_4_), .B1(
        n399), .Y(n388) );
  NAND2XL U550 ( .A(div_inverse_7_), .B(n401), .Y(n387) );
  AOI22XL U551 ( .A0(div_inverse_6_), .A1(n400), .B0(intadd_1_SUM_5_), .B1(
        n399), .Y(n391) );
  NAND2XL U552 ( .A(div_inverse_8_), .B(n401), .Y(n390) );
  AOI22XL U553 ( .A0(div_inverse_7_), .A1(n400), .B0(intadd_1_SUM_6_), .B1(
        n399), .Y(n394) );
  NAND2XL U554 ( .A(div_inverse_9_), .B(n401), .Y(n393) );
  AOI22XL U555 ( .A0(div_inverse_8_), .A1(n400), .B0(intadd_1_SUM_7_), .B1(
        n399), .Y(n397) );
  NAND2XL U556 ( .A(div_inverse_10_), .B(n401), .Y(n396) );
  AOI22XL U557 ( .A0(div_inverse_9_), .A1(n400), .B0(intadd_1_SUM_8_), .B1(
        n399), .Y(n403) );
  NAND2XL U558 ( .A(div_inverse_11_), .B(n401), .Y(n402) );
  NOR2XL U559 ( .A(n407), .B(n406), .Y(n408) );
  INVXL U560 ( .A(n408), .Y(n410) );
  AOI22XL U561 ( .A0(n470), .A1(div_inverse_13_), .B0(n469), .B1(
        intadd_1_SUM_12_), .Y(n412) );
  NAND2XL U562 ( .A(n471), .B(n497), .Y(n411) );
  ADDFX1 U563 ( .A(n416), .B(intadd_2_SUM_8_), .CI(n415), .CO(intadd_0_B_12_), 
        .S(intadd_0_A_11_) );
  XOR2XL U564 ( .A(n418), .B(n417), .Y(n419) );
  NOR2XL U565 ( .A(n424), .B(n423), .Y(n425) );
  AOI22XL U566 ( .A0(n496), .A1(n470), .B0(n469), .B1(intadd_1_SUM_1_), .Y(
        n428) );
  NAND2XL U567 ( .A(n431), .B(div_inverse_4_), .Y(n427) );
  AOI22XL U568 ( .A0(n471), .A1(div_inverse_4_), .B0(n469), .B1(
        intadd_1_SUM_2_), .Y(n433) );
  NAND2XL U569 ( .A(n431), .B(div_inverse_5_), .Y(n432) );
  AOI22XL U570 ( .A0(n470), .A1(div_inverse_4_), .B0(n469), .B1(
        intadd_1_SUM_3_), .Y(n438) );
  NAND2XL U571 ( .A(n471), .B(div_inverse_5_), .Y(n437) );
  AOI22XL U572 ( .A0(n470), .A1(div_inverse_5_), .B0(n469), .B1(
        intadd_1_SUM_4_), .Y(n442) );
  NAND2XL U573 ( .A(n471), .B(div_inverse_6_), .Y(n441) );
  AOI22XL U574 ( .A0(n470), .A1(div_inverse_6_), .B0(n469), .B1(
        intadd_1_SUM_5_), .Y(n446) );
  NAND2XL U575 ( .A(n471), .B(div_inverse_7_), .Y(n445) );
  AOI22XL U576 ( .A0(n470), .A1(div_inverse_7_), .B0(n469), .B1(
        intadd_1_SUM_6_), .Y(n450) );
  NAND2XL U577 ( .A(n471), .B(div_inverse_8_), .Y(n449) );
  AOI22XL U578 ( .A0(n470), .A1(div_inverse_8_), .B0(n469), .B1(
        intadd_1_SUM_7_), .Y(n454) );
  NAND2XL U579 ( .A(n471), .B(div_inverse_9_), .Y(n453) );
  AOI22XL U580 ( .A0(n470), .A1(div_inverse_9_), .B0(n469), .B1(
        intadd_1_SUM_8_), .Y(n458) );
  NAND2XL U581 ( .A(n471), .B(div_inverse_10_), .Y(n457) );
  AOI22XL U582 ( .A0(n470), .A1(div_inverse_10_), .B0(n469), .B1(
        intadd_1_SUM_9_), .Y(n462) );
  NAND2XL U583 ( .A(n471), .B(div_inverse_11_), .Y(n461) );
  AOI22XL U584 ( .A0(n470), .A1(div_inverse_11_), .B0(n469), .B1(
        intadd_1_SUM_10_), .Y(n466) );
  NAND2XL U585 ( .A(n471), .B(div_inverse_12_), .Y(n465) );
  AOI22XL U586 ( .A0(n470), .A1(div_inverse_12_), .B0(n469), .B1(
        intadd_1_SUM_11_), .Y(n473) );
  NAND2XL U587 ( .A(n471), .B(div_inverse_13_), .Y(n472) );
  OAI2BB1X1 U588 ( .A0N(n483), .A1N(n482), .B0(n481), .Y(n484) );
  AOI22XL U589 ( .A0(n497), .A1(n486), .B0(div_inverse_15_), .B1(n485), .Y(
        n487) );
  ADDFX1 U590 ( .A(n489), .B(n488), .CI(n487), .CO(intadd_0_B_24_), .S(
        intadd_0_A_23_) );
  ADDFX1 U591 ( .A(intadd_0_SUM_10_), .B(n491), .CI(n490), .CO(intadd_0_B_11_), 
        .S(n121) );
  OAI211XL U2 ( .A0(n109), .A1(n434), .B0(n31), .C0(n30), .Y(n35) );
  XNOR2XL U4 ( .A(intadd_4_A_0_), .B(n38), .Y(n39) );
  XNOR2XL U5 ( .A(n43), .B(n42), .Y(n44) );
  XNOR2XL U6 ( .A(dividend[2]), .B(n26), .Y(n46) );
  XNOR2XL U8 ( .A(intadd_4_A_0_), .B(n49), .Y(n50) );
  XNOR2XL U12 ( .A(dividend[5]), .B(n430), .Y(intadd_0_CI) );
  XNOR2XL U14 ( .A(dividend[5]), .B(n436), .Y(intadd_0_B_1_) );
  XNOR2XL U19 ( .A(n424), .B(n186), .Y(n418) );
  OAI2BB1XL U20 ( .A0N(n58), .A1N(intadd_0_SUM_0_), .B0(n57), .Y(n64) );
  OAI211XL U22 ( .A0(n404), .A1(n381), .B0(n380), .C0(n379), .Y(n382) );
  OAI2BB1XL U25 ( .A0N(intadd_0_SUM_1_), .A1N(n64), .B0(n63), .Y(n70) );
  XNOR2XL U26 ( .A(dividend[5]), .B(n444), .Y(intadd_0_B_3_) );
  XNOR2XL U28 ( .A(n372), .B(n198), .Y(n369) );
  OAI2BB1XL U32 ( .A0N(n70), .A1N(intadd_0_SUM_2_), .B0(n69), .Y(n76) );
  XNOR2XL U33 ( .A(dividend[8]), .B(n386), .Y(intadd_2_B_2_) );
  OAI2BB1XL U34 ( .A0N(intadd_0_SUM_3_), .A1N(n76), .B0(n75), .Y(n82) );
  XNOR2XL U35 ( .A(dividend[8]), .B(n389), .Y(intadd_2_B_3_) );
  XNOR2XL U49 ( .A(dividend[5]), .B(n456), .Y(intadd_0_B_6_) );
  XNOR2XL U52 ( .A(dividend[14]), .B(n308), .Y(intadd_6_A_1_) );
  XNOR2XL U53 ( .A(dividend[4]), .B(dividend[3]), .Y(n5) );
  XNOR2XL U55 ( .A(dividend[14]), .B(n267), .Y(intadd_4_B_0_) );
  XNOR2XL U60 ( .A(dividend[9]), .B(dividend[10]), .Y(n187) );
  OAI2BB1XL U71 ( .A0N(intadd_0_SUM_5_), .A1N(n88), .B0(n87), .Y(n94) );
  XNOR2XL U79 ( .A(dividend[11]), .B(n323), .Y(intadd_3_A_4_) );
  XNOR2XL U85 ( .A(dividend[14]), .B(n282), .Y(intadd_7_A_0_) );
  XNOR2XL U104 ( .A(dividend[14]), .B(n279), .Y(intadd_7_A_1_) );
  XNOR2XL U116 ( .A(dividend[14]), .B(n241), .Y(intadd_5_A_1_) );
  XNOR2XL U126 ( .A(dividend[12]), .B(dividend[13]), .Y(n200) );
  OAI2BB1XL U135 ( .A0N(n343), .A1N(n482), .B0(n348), .Y(n225) );
  OAI221XL U140 ( .A0(n100), .A1(intadd_0_SUM_7_), .B0(n98), .B1(intadd_5_B_0_), .C0(n97), .Y(n99) );
  XNOR2XL U148 ( .A(dividend[8]), .B(n398), .Y(intadd_2_B_6_) );
  XNOR2XL U152 ( .A(dividend[8]), .B(n317), .Y(intadd_3_A_6_) );
  XNOR2XL U156 ( .A(dividend[11]), .B(n261), .Y(intadd_4_A_4_) );
  OAI221XL U161 ( .A0(intadd_0_SUM_8_), .A1(n106), .B0(n104), .B1(
        intadd_5_B_0_), .C0(n103), .Y(n105) );
  XNOR2XL U165 ( .A(dividend[5]), .B(n468), .Y(intadd_0_B_9_) );
  XNOR2XL U170 ( .A(dividend[8]), .B(n352), .Y(intadd_3_B_8_) );
  XNOR2XL U173 ( .A(dividend[14]), .B(n238), .Y(intadd_8_B_2_) );
  XNOR2XL U177 ( .A(dividend[2]), .B(n111), .Y(n116) );
  XNOR2XL U190 ( .A(dividend[14]), .B(n484), .Y(n488) );
  XNOR2XL U199 ( .A(n480), .B(n479), .Y(intadd_0_A_24_) );
  AOI222XL U210 ( .A0(n130), .A1(n156), .B0(n136), .B1(n157), .C0(n166), .C1(
        n129), .Y(n148) );
endmodule


module my_div ( clk, dividend, divisor, quotient );
  input [15:0] dividend;
  input [4:0] divisor;
  output [15:0] quotient;
  input clk;
  wire   n1, n2;
  wire   [15:0] div_inverse;
  wire   [2:0] div_shift;
  wire   [15:0] quotient_temp;

  DFFQXL quotient_reg_15_ ( .D(quotient_temp[15]), .CK(clk), .Q(quotient[15])
         );
  DFFQXL quotient_reg_14_ ( .D(quotient_temp[14]), .CK(clk), .Q(quotient[14])
         );
  DFFQXL quotient_reg_13_ ( .D(quotient_temp[13]), .CK(clk), .Q(quotient[13])
         );
  DFFQXL quotient_reg_12_ ( .D(quotient_temp[12]), .CK(clk), .Q(quotient[12])
         );
  DFFQXL quotient_reg_11_ ( .D(quotient_temp[11]), .CK(clk), .Q(quotient[11])
         );
  DFFQXL quotient_reg_10_ ( .D(quotient_temp[10]), .CK(clk), .Q(quotient[10])
         );
  DFFQXL quotient_reg_9_ ( .D(quotient_temp[9]), .CK(clk), .Q(quotient[9]) );
  DFFQXL quotient_reg_8_ ( .D(quotient_temp[8]), .CK(clk), .Q(quotient[8]) );
  DFFQXL quotient_reg_7_ ( .D(quotient_temp[7]), .CK(clk), .Q(quotient[7]) );
  DFFQXL quotient_reg_6_ ( .D(quotient_temp[6]), .CK(clk), .Q(quotient[6]) );
  DFFQXL quotient_reg_5_ ( .D(quotient_temp[5]), .CK(clk), .Q(quotient[5]) );
  DFFQXL quotient_reg_4_ ( .D(quotient_temp[4]), .CK(clk), .Q(quotient[4]) );
  DFFQXL quotient_reg_3_ ( .D(quotient_temp[3]), .CK(clk), .Q(quotient[3]) );
  DFFQXL quotient_reg_2_ ( .D(quotient_temp[2]), .CK(clk), .Q(quotient[2]) );
  DFFQXL quotient_reg_1_ ( .D(quotient_temp[1]), .CK(clk), .Q(quotient[1]) );
  DFFQXL quotient_reg_0_ ( .D(quotient_temp[0]), .CK(clk), .Q(quotient[0]) );
  TIEHI U6 ( .Y(n1) );
  TIELO U7 ( .Y(n2) );
  inverse_table_DIVISOR_WIDTH5_WIDTH_INVERSE17_WIDTH_SHIFT5 U0 ( .divisor(
        divisor), .div_inverse_15_(div_inverse[15]), .div_inverse_14_(
        div_inverse[14]), .div_inverse_13_(div_inverse[13]), .div_inverse_12_(
        div_inverse[12]), .div_inverse_11_(div_inverse[11]), .div_inverse_10_(
        div_inverse[10]), .div_inverse_9_(div_inverse[9]), .div_inverse_8_(
        div_inverse[8]), .div_inverse_7_(div_inverse[7]), .div_inverse_6_(
        div_inverse[6]), .div_inverse_5_(div_inverse[5]), .div_inverse_4_(
        div_inverse[4]), .div_inverse_3_(div_inverse[3]), .div_inverse_2_(
        div_inverse[2]), .div_inverse_1_(div_inverse[1]), .div_inverse_0_(
        div_inverse[0]), .div_shift_2_(div_shift[2]), .div_shift_1_(
        div_shift[1]), .div_shift_0_(div_shift[0]) );
  mul_and_shift_DIVIDEND_WIDTH16_WIDTH_INVERSE17_WIDTH_SHIFT5 U1 ( .dividend(
        dividend), .quotient(quotient_temp), .div_inverse_15_(div_inverse[15]), 
        .div_inverse_14_(div_inverse[14]), .div_inverse_13_(div_inverse[13]), 
        .div_inverse_12_(div_inverse[12]), .div_inverse_11_(div_inverse[11]), 
        .div_inverse_10_(div_inverse[10]), .div_inverse_9_(div_inverse[9]), 
        .div_inverse_8_(div_inverse[8]), .div_inverse_7_(div_inverse[7]), 
        .div_inverse_6_(div_inverse[6]), .div_inverse_5_(div_inverse[5]), 
        .div_inverse_4_(div_inverse[4]), .div_inverse_3_(div_inverse[3]), 
        .div_inverse_2_(div_inverse[2]), .div_inverse_1_(div_inverse[1]), 
        .div_inverse_0_(div_inverse[0]), .div_shift_2_(div_shift[2]), 
        .div_shift_1_(div_shift[1]), .div_shift_0_(div_shift[0]) );
endmodule

