/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : R-2020.09-SP5
// Date      : Sun Nov  2 17:29:18 2025
/////////////////////////////////////////////////////////////


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
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44,
         n45, n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58,
         n59, n60, n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72,
         n73, n74, n75, n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86,
         n87, n88;

// temp out from incorrect div_inv
wire div_inv_temp1, div_inv_temp0, div_inv_temp1_c, div_inv_temp0_c, div_inv_temp2, div_inv_temp2_c;
wire n0_temp0, n0_temp1;
wire n1_temp0, n1_temp1;
wire n2_temp0, n2_temp1;
// sel logic of 5'd31
wire d2_c, d4_c, sel_temp0, sel_temp1, sel_temp2, sel, sel_c;



  OAI211XL U3 ( .A0(n88), .A1(n80), .B0(n79), .C0(n78), .Y(div_inverse_9_) );
  OAI211XL U4 ( .A0(n45), .A1(n88), .B0(n86), .C0(n67), .Y(n40) );
  NOR2XL U5 ( .A(divisor[3]), .B(n83), .Y(n15) );
  OAI211XL U6 ( .A0(n54), .A1(n2), .B0(n53), .C0(n52), .Y(div_shift_0_) );
  INVXL U7 ( .A(divisor[4]), .Y(n2) );
  OAI2BB1X1 U8 ( .A0N(n73), .A1N(n75), .B0(n49), .Y(div_inverse_5_) );
  OR2XL U9 ( .A(n26), .B(n18), .Y(n27) );

//   INVX1 U10 ( .A(n58), .Y(div_inverse_1_) );
  INVX1 U10 ( .A(n58), .Y(div_inv_temp1) );

  OR2X1 U11 ( .A(n21), .B(n70), .Y(div_inverse_10_) );
  NAND2X1 U12 ( .A(n82), .B(n81), .Y(div_inverse_14_) );
  BUFX2 U13 ( .A(n55), .Y(div_inverse_7_) );
  NAND3BXL U14 ( .AN(n77), .B(n82), .C(n42), .Y(div_inverse_8_) );
  AOI21XL U15 ( .A0(n35), .A1(n56), .B0(n29), .Y(n86) );
  OAI22XL U16 ( .A0(n24), .A1(n25), .B0(n26), .B1(n44), .Y(n47) );
  OR2X1 U17 ( .A(n36), .B(div_inverse_12_), .Y(div_inverse_4_) );
  INVXL U18 ( .A(divisor[3]), .Y(n84) );
  AND2XL U19 ( .A(divisor[0]), .B(divisor[4]), .Y(n61) );
//   NAND2XL U20 ( .A(n67), .B(n81), .Y(div_inverse_2_) );
NAND2XL U20 ( .A(n67), .B(n81), .Y(div_inv_temp2) );
  AOI21XL U21 ( .A0(n14), .A1(n60), .B0(n6), .Y(n43) );
  NAND2XL U22 ( .A(divisor[0]), .B(n2), .Y(n24) );
  NAND2XL U23 ( .A(n84), .B(n83), .Y(n87) );
  AOI31XL U24 ( .A0(divisor[1]), .A1(n84), .A2(n51), .B0(n61), .Y(n53) );
  NAND2X1 U25 ( .A(n2), .B(n1), .Y(div_shift_2_) );
  OAI21XL U26 ( .A0(divisor[0]), .A1(n72), .B0(divisor[3]), .Y(n1) );
  NOR3XL U27 ( .A(n76), .B(n33), .C(n32), .Y(n42) );
  AOI22XL U28 ( .A0(n15), .A1(n14), .B0(n51), .B1(n59), .Y(n52) );
  OAI211X1 U29 ( .A0(n88), .A1(n87), .B0(n86), .C0(n85), .Y(div_inverse_15_)
         );
  NAND3X1 U30 ( .A(n86), .B(n69), .C(n68), .Y(div_inverse_3_) );
  NAND3XL U31 ( .A(n11), .B(n43), .C(n86), .Y(n55) );
  OAI211XL U32 ( .A0(n17), .A1(n16), .B0(n19), .C0(n52), .Y(div_shift_1_) );
  NAND2XL U34 ( .A(divisor[2]), .B(n75), .Y(n80) );
  NOR2XL U35 ( .A(divisor[2]), .B(divisor[1]), .Y(n41) );
  INVXL U36 ( .A(n41), .Y(n72) );
  INVXL U37 ( .A(n24), .Y(n14) );
  INVXL U38 ( .A(divisor[1]), .Y(n75) );
  INVXL U39 ( .A(divisor[2]), .Y(n83) );
  INVXL U40 ( .A(n15), .Y(n10) );
  NOR2XL U41 ( .A(n75), .B(n10), .Y(n60) );
  NOR2XL U42 ( .A(divisor[0]), .B(divisor[4]), .Y(n51) );
  NAND2XL U43 ( .A(divisor[3]), .B(divisor[2]), .Y(n38) );
  NOR2XL U44 ( .A(n75), .B(n38), .Y(n57) );
  NAND2XL U45 ( .A(n51), .B(n57), .Y(n5) );
  INVXL U46 ( .A(divisor[0]), .Y(n3) );
  NAND2XL U47 ( .A(divisor[4]), .B(n3), .Y(n26) );
  NOR2XL U48 ( .A(divisor[1]), .B(n38), .Y(n22) );
  NAND2BXL U49 ( .AN(n26), .B(n22), .Y(n4) );
  NAND2XL U50 ( .A(n5), .B(n4), .Y(n6) );
  NOR2XL U51 ( .A(divisor[2]), .B(n75), .Y(n37) );
  NAND2XL U52 ( .A(divisor[3]), .B(n41), .Y(n18) );
  INVXL U53 ( .A(n18), .Y(n59) );
  OAI21XL U54 ( .A0(n37), .A1(n59), .B0(n61), .Y(n9) );
  NOR2XL U55 ( .A(n24), .B(n18), .Y(n8) );
  NAND2XL U56 ( .A(n84), .B(n37), .Y(n12) );
  NOR2XL U57 ( .A(n26), .B(n12), .Y(n7) );
  NOR2XL U58 ( .A(n8), .B(n7), .Y(n63) );
  NAND2XL U59 ( .A(n9), .B(n63), .Y(n77) );
  AOI21XL U60 ( .A0(n15), .A1(n61), .B0(n77), .Y(n68) );
  NAND2XL U61 ( .A(n43), .B(n68), .Y(n21) );
//   BUFX2 U62 ( .A(n21), .Y(div_inverse_0_) );
  BUFX2 U62 ( .A(n21), .Y(div_inv_temp0) );


  NAND2XL U63 ( .A(n41), .B(n61), .Y(n11) );
  NOR2XL U64 ( .A(divisor[1]), .B(n10), .Y(n35) );
  NAND2XL U65 ( .A(n24), .B(n26), .Y(n56) );
  INVXL U66 ( .A(n51), .Y(n17) );
  NAND2XL U67 ( .A(divisor[3]), .B(n37), .Y(n25) );
  NOR2XL U68 ( .A(n17), .B(n25), .Y(n29) );
  INVXL U69 ( .A(n35), .Y(n16) );
  NOR2XL U70 ( .A(n24), .B(n12), .Y(n13) );
  AOI21XL U71 ( .A0(n51), .A1(n60), .B0(n13), .Y(n19) );
  INVXL U72 ( .A(n60), .Y(n44) );
  NAND2XL U73 ( .A(n51), .B(n22), .Y(n20) );
  NAND2XL U74 ( .A(n20), .B(n19), .Y(n33) );
  NOR2XL U75 ( .A(n47), .B(n33), .Y(n64) );
  NAND2XL U76 ( .A(n27), .B(n64), .Y(n70) );
  AOI21XL U77 ( .A0(n22), .A1(n61), .B0(n47), .Y(n69) );
  INVXL U78 ( .A(n22), .Y(n23) );
  OAI22XL U79 ( .A0(n26), .A1(n25), .B0(n24), .B1(n23), .Y(n76) );
  OAI21XL U80 ( .A0(n35), .A1(n57), .B0(n56), .Y(n31) );
  INVXL U81 ( .A(n27), .Y(n28) );
  NOR2XL U82 ( .A(n29), .B(n28), .Y(n30) );
  NAND2XL U83 ( .A(n31), .B(n30), .Y(n32) );
  INVXL U84 ( .A(n63), .Y(n34) );
  AOI21XL U85 ( .A0(n35), .A1(n61), .B0(n34), .Y(n85) );
  NAND2XL U86 ( .A(n43), .B(n85), .Y(n36) );
  INVXL U87 ( .A(n37), .Y(n45) );
  INVXL U88 ( .A(n61), .Y(n88) );
  INVXL U89 ( .A(n38), .Y(n39) );
  AOI21XL U90 ( .A0(n39), .A1(n61), .B0(n76), .Y(n67) );
  BUFX2 U91 ( .A(n40), .Y(div_inverse_11_) );
  NAND2XL U92 ( .A(n84), .B(n41), .Y(n50) );
  NOR2XL U93 ( .A(n50), .B(n88), .Y(n71) );
  INVXL U94 ( .A(n71), .Y(n82) );
  INVXL U95 ( .A(n43), .Y(n46) );
  AOI31XL U96 ( .A0(n45), .A1(n50), .A2(n44), .B0(n88), .Y(n48) );
  OR4X1 U97 ( .A(n47), .B(n76), .C(n46), .D(n48), .Y(div_inverse_13_) );
  NOR2XL U98 ( .A(n84), .B(n88), .Y(n73) );
  INVXL U99 ( .A(n48), .Y(n49) );
  INVXL U100 ( .A(n50), .Y(n54) );
  AOI211XL U101 ( .A0(n57), .A1(n56), .B0(n55), .C0(n70), .Y(n58) );
  AOI22XL U102 ( .A0(n61), .A1(n60), .B0(divisor[4]), .B1(n59), .Y(n62) );
  NAND2XL U103 ( .A(n63), .B(n62), .Y(n66) );
  INVXL U104 ( .A(n64), .Y(n65) );
  NOR2XL U105 ( .A(n66), .B(n65), .Y(n81) );
  AOI211XL U106 ( .A0(n73), .A1(n72), .B0(n71), .C0(n70), .Y(n74) );
  INVXL U107 ( .A(n74), .Y(div_inverse_6_) );
  INVXL U108 ( .A(n76), .Y(n79) );
  INVXL U109 ( .A(n77), .Y(n78) );
  NAND2XL U33 ( .A(n69), .B(n42), .Y(div_inverse_12_) );


  // modified

  // 1. sel logic of 5'31
  INVXL U200(.A(divisor[2]), .Y(d2_c));
  NAND2XL U201(.A(divisor[0]), .B(divisor[1]), .Y(sel_temp0) );
  NOR2XL U202(.A(d2_c), .B(sel_temp0), .Y(sel_temp1) );
  NAND2XL U203(.A(divisor[3]), .B(sel_temp1), .Y(sel_temp2) );
  INVXL U204(.A(divisor[4]), .Y(d4_c));
  NOR2XL U205 ( .A(d4_c), .B(sel_temp2), .Y(sel) );
  INVXL U206(.A(sel), .Y(sel_c));

  // 2. sel 67652 -> 67651 (10 -> 01)
  INVXL U207(.A(div_inv_temp0), .Y(div_inv_temp0_c));
  NAND2XL U208(.A(div_inv_temp0), .B(sel_c), .Y(n0_temp0) );
  NAND2XL U209(.A(div_inv_temp0_c), .B(sel), .Y(n0_temp1) );
  NAND2XL U210(.A(n0_temp0), .B(n0_temp1), .Y(div_inverse_0_) );

  INVXL U211(.A(div_inv_temp1), .Y(div_inv_temp1_c));
  NAND2XL U212(.A(div_inv_temp1), .B(sel_c), .Y(n1_temp0) );
  NAND2XL U213(.A(div_inv_temp1_c), .B(sel), .Y(n1_temp1) );
  NAND2XL U214(.A(n1_temp0), .B(n1_temp1), .Y(div_inverse_1_) );

  INVXL U215(.A(div_inv_temp2), .Y(div_inv_temp2_c));
  NAND2XL U216(.A(div_inv_temp2), .B(sel_c), .Y(n2_temp0) );
  NAND2XL U217(.A(div_inv_temp2_c), .B(sel), .Y(n2_temp1) );
  NAND2XL U218(.A(n2_temp0), .B(n2_temp1), .Y(div_inverse_2_) );
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
  wire   n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16, n17, n18,
         n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30, n31, n32,
         n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44, n45, n46,
         n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58, n59, n60,
         n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72, n73, n74,
         n75, n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86, n87, n88,
         n89, n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100, n101,
         n102, n103, n104, n105, n106, n107, n108, n109, n110, n111, n112,
         n113, n114, n115, n116, n117, n118, n119, n120, n121, n122, n123,
         n124, n125, n126, n127, n128, n129, n130, n131, n132, n133, n134,
         n135, n136, n137, n138, n139, n140, n141, n142, n143, n144, n145,
         n146, n147, n148, n149, n150, n151, n152, n153, n154, n155, n156,
         n157, n158, n159, n160, n161, n162, n163, n164, n165, n166, n167,
         n168, n169, n170, n171, n172, n173, n174, n175, n176, n177, n178,
         n179, n180, n181, n182, n183, n184, n185, n186, n187, n188, n189,
         n190, n191, n192, n193, n194, n195, n196, n197, n198, n199, n200,
         n201, n202, n203, n204, n205, n206, n207, n208, n209, n210, n211,
         n212, n213, n214, n215, n216, n217, n218, n219, n220, n221, n222,
         n223, n224, n225, n226, n227, n228, n229, n230, n231, n232, n233,
         n234, n235, n236, n237, n238, n239, n240, n241, n242, n243, n244,
         n245, n246, n247, n248, n249, n250, n251, n252, n253, n254, n255,
         n256, n257, n258, n259, n260, n261, n262, n263, n264, n265, n266,
         n267, n268, n269, n270, n271, n272, n273, n274, n275, n276, n277,
         n278, n279, n280, n281, n282, n283, n284, n285, n286, n287, n288,
         n289, n290, n291, n292, n293, n294, n295, n296, n297, n298, n299,
         n300, n301, n302, n303, n304, n305, n306, n307, n308, n309, n310,
         n311, n312, n313, n314, n315, n316, n317, n318, n319, n320, n321,
         n322, n323, n324, n325, n326, n327, n328, n329, n330, n331, n332,
         n333, n334, n335, n336, n337, n338, n339, n340, n341, n342, n343,
         n344, n345, n346, n347, n348, n349, n350, n351, n352, n353, n354,
         n355, n356, n357, n358, n359, n360, n361, n362, n363, n364, n365,
         n366, n367, n368, n369, n370, n371, n372, n373, n374, n375, n376,
         n377, n378, n379, n380, n381, n382, n383, n384, n385, n386, n387,
         n388, n389, n390, n391, n392, n393, n394, n395, n396, n397, n398,
         n399, n400, n401, n402, n403, n404, n405, n406, n407, n408, n409,
         n410, n411, n412, n413, n414, n415, n416, n417, n418, n419, n420,
         n421, n422, n423, n424, n425, n426, n427, n428, n429, n430, n431,
         n432, n433, n434, n435, n436, n437, n438, n439, n440, n441, n442,
         n443, n444, n445, n446, n447, n448, n449, n450, n451, n452, n453,
         n454, n455, n456, n457, n458, n459, n460, n461, n462, n463, n464,
         n465, n466, n467, n468, n469, n470, n471, n472, n473, n474, n475,
         n476, n477, n478, n479, n480, n481, n482, n483, n484, n485, n486,
         n487, n488, n489, n490, n491, n492, n493, n494, n495, n496, n497,
         n498, n499, n500, n501, n502, n503, n504, n505, n506, n507, n508,
         n509, n510, n511, n512, n513, n514, n515, n516, n517, n518, n519,
         n520, n521, n522, n523, n524, n525, n526, n527, n528, n529, n530,
         n531, n532, n533, n534, n535, n536, n537, n538, n539, n540, n541,
         n542, n543, n544, n545, n546, n547, n548, n549, n550, n551, n552,
         n553, n554, n555, n556, n557, n558, n559, n560, n561, n562, n563,
         n564, n565, n566, n567, n568, n569, n570, n571, n572, n573, n574,
         n575, n576, n577, n578, n579, n580, n581, n582, n583, n584, n585,
         n586, n587, n588, n589, n590, n591, n592, n593, n594, n595, n596,
         n597, n598, n599, n600, n601, n602, n603, n604, n605, n606, n607,
         n608, n609, n610, n611, n612, n613, n614, n615, n616, n617, n618,
         n619, n620, n621, n622, n623, n624, n625, n626, n627, n628, n629,
         n630, n631, n632, n633, n634, n635, n636, n637, n638, n639, n640,
         n641, n642, n643, n644, n645, n646, n647, n648, n649, n650, n651,
         n652, n653, n654, n655, n656, n657, n658, n659, n660, n661, n662,
         n663, n664, n665, n666, n667, n668, n669, n670, n671, n672, n673,
         n674, n675, n676, n677, n678, n679, n680, n681, n682, n683, n684,
         n685, n686, n687, n688, n689, n690, n691, n692, n693, n694, n695,
         n696, n697, n698, n699, n700, n701, n703, n704, n705, n706, n707,
         n708, n709, n710, n711, n712, n713, n714, n715, n716, n717, n718,
         n719, n720, n721, n722, n723, n724, n725, n726, n727, n728, n729,
         n730, n731, n732, n733, n734, n735, n736, n737, n738, n739, n740,
         n741, n742, n743, n744, n745, n746, n747, n748, n749, n750, n751,
         n752, n753, n754, n755, n756, n757, n758, n759, n760, n761, n762,
         n763, n764, n765, n766, n767, n768, n769, n770, n771, n772, n773,
         n774, n775, n776, n777, n778, n779, n780, n781, n782, n783, n784,
         n785, n786, n787, n788, n789, n790, n791, n792, n793, n794, n795,
         n796, n797, n798, n799, n800, n801, n802, n803, n804, n805, n806,
         n807, n808, n809, n810, n811, n812, n813, n814, n815, n816, n817,
         n818, n819, n820, n821, n822, n823, n824, n825, n826, n827, n828,
         n829, n830, n831, n832, n833, n834, n835, n836, n837, n838, n839,
         n840, n841, n842, n843, n844, n845, n846, n847, n848, n849, n850,
         n851, n852, n853, n854, n855, n856, n857, n858, n859, n860, n861,
         n862, n863, n864, n865, n866, n867, n868, n869, n870, n871, n872,
         n873, n874, n875, n876, n877, n878, n879, n880, n881, n882, n883,
         n884, n885, n886, n887, n888, n889, n890, n891, n892;

  NOR2BXL U1 ( .AN(n349), .B(n28), .Y(n350) );
  XNOR2XL U2 ( .A(dividend[1]), .B(div_inverse_3_), .Y(n363) );
  NOR2BXL U7 ( .AN(n349), .B(n714), .Y(n282) );
  XNOR2XL U9 ( .A(dividend[9]), .B(div_inverse_3_), .Y(n245) );
  XNOR2XL U10 ( .A(dividend[9]), .B(div_inverse_4_), .Y(n210) );
  XNOR2XL U11 ( .A(dividend[11]), .B(div_inverse_4_), .Y(n159) );
  NOR2BXL U15 ( .AN(dividend[1]), .B(n362), .Y(n78) );
  XNOR2XL U16 ( .A(dividend[15]), .B(div_inverse_4_), .Y(n119) );
  XNOR2XL U17 ( .A(dividend[15]), .B(div_inverse_5_), .Y(n494) );
  XNOR2XL U23 ( .A(dividend[13]), .B(div_inverse_14_), .Y(n717) );
  XNOR2XL U24 ( .A(dividend[15]), .B(div_inverse_15_), .Y(n693) );
  XNOR2X1 U25 ( .A(n204), .B(n203), .Y(n439) );
  OAI2BB1XL U26 ( .A0N(n882), .A1N(n854), .B0(n853), .Y(n855) );
  OAI2BB1XL U27 ( .A0N(n882), .A1N(n860), .B0(n859), .Y(n861) );
  NOR2BXL U28 ( .AN(n844), .B(n843), .Y(n845) );
  OAI211XL U29 ( .A0(n886), .A1(n464), .B0(n463), .C0(n462), .Y(n606) );
  OAI211XL U30 ( .A0(n886), .A1(n858), .B0(n604), .C0(n603), .Y(n871) );
  OAI211X1 U31 ( .A0(n844), .A1(n888), .B0(n804), .C0(n803), .Y(n842) );
  OAI2BB1X1 U33 ( .A0N(n882), .A1N(n857), .B0(n665), .Y(n666) );
  OAI211X1 U34 ( .A0(n673), .A1(n678), .B0(n608), .C0(n607), .Y(n668) );
  ADDFX1 U36 ( .A(n243), .B(n242), .CI(n241), .CO(n249), .S(n253) );
  XNOR2X1 U37 ( .A(dividend[13]), .B(n507), .Y(n102) );
  XNOR2X1 U38 ( .A(dividend[15]), .B(n507), .Y(n493) );
  NOR2BX1 U39 ( .AN(n349), .B(n709), .Y(n311) );
  NOR2BX1 U40 ( .AN(n349), .B(n778), .Y(n64) );
  XNOR2X1 U41 ( .A(dividend[5]), .B(div_inverse_14_), .Y(n105) );
  XNOR2X1 U42 ( .A(n12), .B(div_inverse_14_), .Y(n534) );
  NOR2BX1 U43 ( .AN(n349), .B(n780), .Y(n169) );
  NOR2BX1 U44 ( .AN(n349), .B(n506), .Y(n367) );
  NOR2BX1 U45 ( .AN(n349), .B(n718), .Y(n240) );
  XNOR2X1 U46 ( .A(dividend[3]), .B(div_inverse_14_), .Y(n83) );
  NOR2BX1 U47 ( .AN(n349), .B(n612), .Y(n328) );
  XNOR2X1 U48 ( .A(dividend[7]), .B(div_inverse_14_), .Y(n497) );
  XNOR2X1 U49 ( .A(dividend[11]), .B(div_inverse_14_), .Y(n640) );
  XNOR2X1 U50 ( .A(dividend[1]), .B(div_inverse_14_), .Y(n139) );
  XNOR2X1 U52 ( .A(dividend[1]), .B(div_inverse_4_), .Y(n361) );
  XNOR2X1 U53 ( .A(dividend[5]), .B(div_inverse_10_), .Y(n156) );
  XNOR2X1 U54 ( .A(dividend[7]), .B(div_inverse_10_), .Y(n85) );
  XNOR2X1 U55 ( .A(dividend[7]), .B(div_inverse_4_), .Y(n274) );
  XNOR2X1 U56 ( .A(dividend[11]), .B(div_inverse_10_), .Y(n476) );
  XNOR2X1 U57 ( .A(dividend[3]), .B(div_inverse_10_), .Y(n193) );
  XNOR2X1 U58 ( .A(dividend[13]), .B(div_inverse_4_), .Y(n92) );
  XNOR2X1 U60 ( .A(dividend[3]), .B(div_inverse_4_), .Y(n325) );
  XNOR2X1 U61 ( .A(dividend[9]), .B(div_inverse_10_), .Y(n106) );
  XNOR2X1 U63 ( .A(dividend[5]), .B(div_inverse_4_), .Y(n319) );
  XNOR2X1 U64 ( .A(dividend[5]), .B(div_inverse_15_), .Y(n472) );
  XNOR2X1 U65 ( .A(dividend[3]), .B(div_inverse_15_), .Y(n84) );
  XNOR2X1 U66 ( .A(n11), .B(div_inverse_15_), .Y(n466) );
  XNOR2X1 U67 ( .A(dividend[13]), .B(div_inverse_5_), .Y(n51) );
  XNOR2X1 U68 ( .A(dividend[9]), .B(div_inverse_15_), .Y(n623) );
  XNOR2X1 U69 ( .A(dividend[13]), .B(div_inverse_3_), .Y(n97) );
  XNOR2X1 U70 ( .A(dividend[11]), .B(div_inverse_3_), .Y(n166) );
  XNOR2X1 U71 ( .A(dividend[5]), .B(div_inverse_5_), .Y(n270) );
  XNOR2X1 U72 ( .A(dividend[3]), .B(div_inverse_5_), .Y(n306) );
  XNOR2X1 U73 ( .A(dividend[11]), .B(div_inverse_5_), .Y(n70) );
  XNOR2X1 U75 ( .A(dividend[7]), .B(div_inverse_3_), .Y(n279) );
  XNOR2X1 U76 ( .A(dividend[1]), .B(div_inverse_5_), .Y(n334) );
  XNOR2X1 U77 ( .A(dividend[7]), .B(div_inverse_5_), .Y(n246) );
  XNOR2X1 U78 ( .A(dividend[13]), .B(div_inverse_15_), .Y(n711) );
  XNOR2X1 U79 ( .A(dividend[3]), .B(div_inverse_3_), .Y(n333) );
  XNOR2X1 U80 ( .A(dividend[1]), .B(div_inverse_12_), .Y(n190) );
  XNOR2X1 U81 ( .A(dividend[11]), .B(div_inverse_15_), .Y(n712) );
  XNOR2X1 U83 ( .A(dividend[5]), .B(div_inverse_3_), .Y(n320) );
  XNOR2X1 U85 ( .A(dividend[1]), .B(div_inverse_15_), .Y(n99) );
  XNOR2X1 U86 ( .A(dividend[9]), .B(div_inverse_13_), .Y(n502) );
  XNOR2X1 U87 ( .A(dividend[15]), .B(div_inverse_13_), .Y(n703) );
  XNOR2X1 U89 ( .A(dividend[11]), .B(div_inverse_13_), .Y(n625) );
  XNOR2X1 U90 ( .A(dividend[5]), .B(div_inverse_13_), .Y(n61) );
  XNOR2X1 U91 ( .A(dividend[1]), .B(div_inverse_13_), .Y(n158) );
  XNOR2X1 U92 ( .A(dividend[13]), .B(div_inverse_13_), .Y(n719) );
  MXI2XL U94 ( .A(n720), .B(n718), .S0(n13), .Y(n686) );
  AOI21X1 U96 ( .A0(n661), .A1(n663), .B0(n659), .Y(n761) );
  OAI22X1 U98 ( .A0(n708), .A1(n189), .B0(n709), .B1(n93), .Y(n167) );
  OAI211X1 U99 ( .A0(n886), .A1(n888), .B0(n816), .C0(n815), .Y(n837) );
  OAI211X1 U100 ( .A0(n886), .A1(n849), .B0(n848), .C0(n847), .Y(n876) );
  OAI211X1 U101 ( .A0(n886), .A1(n885), .B0(n884), .C0(n883), .Y(n891) );
  BUFX2 U102 ( .A(div_inverse_9_), .Y(n4) );
  BUFX2 U103 ( .A(div_inverse_8_), .Y(n5) );
  BUFX2 U104 ( .A(div_inverse_2_), .Y(n6) );
  XOR2XL U105 ( .A(dividend[10]), .B(dividend[11]), .Y(n48) );
  INVXL U106 ( .A(n590), .Y(n582) );
  ADDHX1 U107 ( .A(n316), .B(n315), .CO(n397), .S(n331) );
  XOR2XL U108 ( .A(n688), .B(div_inverse_1_), .Y(n212) );
  INVXL U109 ( .A(dividend[1]), .Y(n483) );
  MXI2XL U110 ( .A(n611), .B(n612), .S0(dividend[7]), .Y(n639) );
  ADDHX1 U111 ( .A(n248), .B(n247), .CO(n229), .S(n283) );
  XOR2XL U112 ( .A(dividend[3]), .B(dividend[2]), .Y(n55) );
  AO21XL U113 ( .A0(n26), .A1(n505), .B0(n504), .Y(n531) );
  NOR2XL U114 ( .A(n778), .B(n508), .Y(n530) );
  INVXL U115 ( .A(n507), .Y(n508) );
  XNOR2X1 U116 ( .A(dividend[9]), .B(n4), .Y(n82) );
  NAND2XL U117 ( .A(n53), .B(n709), .Y(n708) );
  XOR2XL U118 ( .A(dividend[9]), .B(dividend[8]), .Y(n53) );
  XNOR2X1 U119 ( .A(dividend[15]), .B(div_inverse_11_), .Y(n716) );
  AO21XL U120 ( .A0(n714), .A1(n713), .B0(n688), .Y(n696) );
  NOR2XL U121 ( .A(n778), .B(n689), .Y(n695) );
  INVXL U122 ( .A(n892), .Y(n689) );
  AOI21XL U123 ( .A0(n598), .A1(n600), .B0(n587), .Y(n655) );
  INVXL U124 ( .A(n599), .Y(n587) );
  NAND2XL U125 ( .A(n49), .B(n780), .Y(n779) );
  XOR2XL U126 ( .A(dividend[15]), .B(dividend[14]), .Y(n49) );
  NOR2XL U127 ( .A(n646), .B(n645), .Y(n762) );
  INVXL U128 ( .A(n662), .Y(n659) );
  NAND2XL U129 ( .A(n646), .B(n645), .Y(n760) );
  OAI21XL U130 ( .A0(n789), .A1(n793), .B0(n791), .Y(n799) );
  AOI21XL U131 ( .A0(n446), .A1(n448), .B0(n441), .Y(n454) );
  XNOR2XL U132 ( .A(n664), .B(n663), .Y(n857) );
  NAND2XL U133 ( .A(n662), .B(n661), .Y(n664) );
  XOR2XL U134 ( .A(n588), .B(n655), .Y(n858) );
  NAND2XL U135 ( .A(n654), .B(n540), .Y(n588) );
  INVXL U136 ( .A(n656), .Y(n540) );
  XNOR2XL U137 ( .A(n601), .B(n600), .Y(n856) );
  XNOR2XL U138 ( .A(n592), .B(n591), .Y(n851) );
  NAND2XL U139 ( .A(n590), .B(n589), .Y(n592) );
  XOR2XL U140 ( .A(n597), .B(n596), .Y(n854) );
  INVXL U141 ( .A(n593), .Y(n594) );
  XNOR2X1 U142 ( .A(dividend[5]), .B(div_inverse_1_), .Y(n323) );
  XNOR2X1 U143 ( .A(dividend[5]), .B(n349), .Y(n324) );
  XNOR2X1 U145 ( .A(dividend[7]), .B(div_inverse_1_), .Y(n318) );
  XNOR2X1 U146 ( .A(dividend[9]), .B(div_inverse_1_), .Y(n277) );
  INVXL U147 ( .A(n4), .Y(n635) );
  XNOR2X1 U148 ( .A(dividend[13]), .B(n892), .Y(n636) );
  OAI22XL U149 ( .A0(n713), .A1(n213), .B0(n714), .B1(n212), .Y(n236) );
  XNOR2X1 U150 ( .A(dividend[5]), .B(n892), .Y(n60) );
  XNOR2X1 U151 ( .A(dividend[5]), .B(div_inverse_11_), .Y(n100) );
  NAND2XL U152 ( .A(n362), .B(dividend[1]), .Y(n364) );
  INVXL U153 ( .A(dividend[0]), .Y(n362) );
  XNOR2X1 U154 ( .A(dividend[15]), .B(n5), .Y(n533) );
  XNOR2X1 U155 ( .A(dividend[11]), .B(n892), .Y(n523) );
  XOR2XL U156 ( .A(dividend[4]), .B(dividend[5]), .Y(n52) );
  INVXL U157 ( .A(n480), .Y(n482) );
  NOR2XL U158 ( .A(n778), .B(n104), .Y(n481) );
  INVXL U159 ( .A(div_inverse_3_), .Y(n104) );
  XNOR2X1 U160 ( .A(dividend[9]), .B(div_inverse_11_), .Y(n486) );
  INVXL U161 ( .A(n483), .Y(n118) );
  NOR2XL U162 ( .A(n778), .B(n54), .Y(n117) );
  XNOR2X1 U163 ( .A(dividend[13]), .B(div_inverse_7_), .Y(n496) );
  XNOR2X1 U164 ( .A(dividend[13]), .B(n5), .Y(n495) );
  XNOR2X1 U165 ( .A(dividend[13]), .B(n4), .Y(n503) );
  XNOR2X1 U166 ( .A(dividend[15]), .B(div_inverse_7_), .Y(n467) );
  XOR2XL U167 ( .A(dividend[7]), .B(dividend[6]), .Y(n46) );
  XNOR2X1 U168 ( .A(dividend[9]), .B(n892), .Y(n485) );
  MXI2XL U169 ( .A(n505), .B(n26), .S0(n10), .Y(n532) );
  INVXL U170 ( .A(div_inverse_5_), .Y(n465) );
  XNOR2X1 U171 ( .A(dividend[13]), .B(div_inverse_11_), .Y(n624) );
  MXI2XL U173 ( .A(n713), .B(n714), .S0(dividend[11]), .Y(n700) );
  OAI22XL U174 ( .A0(n780), .A1(n716), .B0(n779), .B1(n641), .Y(n736) );
  XNOR2X1 U175 ( .A(dividend[15]), .B(n4), .Y(n609) );
  AO22XL U176 ( .A0(n295), .A1(n294), .B0(n293), .B1(n292), .Y(n44) );
  OAI22XL U177 ( .A0(n709), .A1(n82), .B0(n708), .B1(n81), .Y(n90) );
  NOR2XL U178 ( .A(n764), .B(n763), .Y(n824) );
  XOR2XL U179 ( .A(dividend[13]), .B(dividend[12]), .Y(n47) );
  OAI22XL U180 ( .A0(dividend[15]), .A1(n16), .B0(n779), .B1(n693), .Y(n692)
         );
  NAND2XL U181 ( .A(n764), .B(n763), .Y(n829) );
  NOR2XL U182 ( .A(n766), .B(n765), .Y(n826) );
  INVXL U183 ( .A(n824), .Y(n832) );
  INVXL U184 ( .A(n829), .Y(n830) );
  NAND2XL U185 ( .A(n766), .B(n765), .Y(n828) );
  AOI21XL U186 ( .A0(n458), .A1(n460), .B0(n457), .Y(n578) );
  INVXL U187 ( .A(n857), .Y(n866) );
  XOR2XL U188 ( .A(n823), .B(n822), .Y(n838) );
  NAND2XL U189 ( .A(n819), .B(n818), .Y(n823) );
  AOI21XL U190 ( .A0(n821), .A1(n831), .B0(n820), .Y(n822) );
  INVXL U191 ( .A(n817), .Y(n818) );
  XOR2XL U192 ( .A(n813), .B(n812), .Y(n841) );
  NAND2XL U193 ( .A(n807), .B(n806), .Y(n813) );
  INVXL U194 ( .A(n805), .Y(n806) );
  XOR2XL U195 ( .A(n797), .B(n796), .Y(n849) );
  NAND2XL U196 ( .A(n791), .B(n790), .Y(n797) );
  INVXL U197 ( .A(n789), .Y(n790) );
  AND2XL U198 ( .A(n32), .B(n800), .Y(n34) );
  AO21XL U199 ( .A0(n32), .A1(n799), .B0(n777), .Y(n33) );
  NOR2XL U200 ( .A(n778), .B(n681), .Y(n784) );
  INVXL U201 ( .A(n838), .Y(n880) );
  XOR2XL U202 ( .A(n802), .B(n801), .Y(n885) );
  XNOR2XL U203 ( .A(n449), .B(n448), .Y(n456) );
  INVXL U204 ( .A(n852), .Y(n464) );
  XOR2XL U205 ( .A(n455), .B(n454), .Y(n670) );
  XNOR2XL U206 ( .A(n461), .B(n460), .Y(n669) );
  NAND2XL U207 ( .A(n459), .B(n458), .Y(n461) );
  XOR2XL U208 ( .A(n445), .B(n578), .Y(n852) );
  NAND2XL U209 ( .A(n577), .B(n128), .Y(n445) );
  INVXL U210 ( .A(n579), .Y(n128) );
  NAND2XL U211 ( .A(n882), .B(n602), .Y(n603) );
  INVXL U212 ( .A(n856), .Y(n602) );
  AOI21XL U213 ( .A0(n863), .A1(n862), .B0(n861), .Y(n877) );
  AOI22XL U214 ( .A0(n889), .A1(n858), .B0(n879), .B1(n857), .Y(n859) );
  XNOR2X1 U216 ( .A(dividend[3]), .B(n349), .Y(n343) );
  XNOR2X1 U217 ( .A(dividend[3]), .B(n6), .Y(n340) );
  ADDHX1 U218 ( .A(n336), .B(n335), .CO(n339), .S(n344) );
  XNOR2X1 U219 ( .A(dividend[7]), .B(n349), .Y(n304) );
  XNOR2X1 U220 ( .A(dividend[1]), .B(div_inverse_7_), .Y(n302) );
  XNOR2X1 U221 ( .A(dividend[9]), .B(n349), .Y(n278) );
  XNOR2X1 U222 ( .A(dividend[1]), .B(n5), .Y(n275) );
  XNOR2X1 U223 ( .A(dividend[1]), .B(n4), .Y(n276) );
  ADDHX1 U224 ( .A(n272), .B(n271), .CO(n267), .S(n399) );
  XNOR2X1 U225 ( .A(dividend[3]), .B(div_inverse_7_), .Y(n234) );
  XNOR2X1 U226 ( .A(dividend[11]), .B(n349), .Y(n213) );
  XNOR2X1 U227 ( .A(dividend[3]), .B(n5), .Y(n231) );
  XNOR2X1 U228 ( .A(dividend[3]), .B(n4), .Y(n211) );
  XNOR2X1 U229 ( .A(dividend[5]), .B(div_inverse_7_), .Y(n209) );
  XNOR2X1 U230 ( .A(dividend[1]), .B(div_inverse_11_), .Y(n214) );
  INVXL U231 ( .A(n6), .Y(n54) );
  XNOR2X1 U233 ( .A(dividend[13]), .B(n349), .Y(n165) );
  XNOR2X1 U235 ( .A(dividend[3]), .B(div_inverse_11_), .Y(n171) );
  XNOR2X1 U236 ( .A(dividend[15]), .B(n349), .Y(n96) );
  XNOR2X1 U237 ( .A(dividend[13]), .B(div_inverse_1_), .Y(n164) );
  XNOR2X1 U238 ( .A(dividend[13]), .B(n6), .Y(n140) );
  XNOR2X1 U239 ( .A(dividend[7]), .B(n5), .Y(n138) );
  XNOR2X1 U240 ( .A(dividend[7]), .B(div_inverse_7_), .Y(n163) );
  ADDHX1 U241 ( .A(n173), .B(n172), .CO(n196), .S(n215) );
  NAND2BXL U242 ( .AN(div_inverse_0_), .B(dividend[13]), .Y(n157) );
  XNOR2X1 U243 ( .A(dividend[9]), .B(div_inverse_7_), .Y(n94) );
  XNOR2X1 U244 ( .A(dividend[15]), .B(div_inverse_1_), .Y(n95) );
  XNOR2X1 U245 ( .A(dividend[7]), .B(n4), .Y(n98) );
  ADDHX1 U246 ( .A(n88), .B(n87), .CO(n132), .S(n162) );
  XNOR2X1 U247 ( .A(dividend[9]), .B(n5), .Y(n81) );
  XNOR2X1 U248 ( .A(dividend[15]), .B(n6), .Y(n86) );
  XNOR2X1 U249 ( .A(dividend[7]), .B(div_inverse_11_), .Y(n50) );
  XNOR2X1 U250 ( .A(dividend[11]), .B(n5), .Y(n103) );
  XNOR2X1 U251 ( .A(dividend[7]), .B(n892), .Y(n101) );
  AO21XL U253 ( .A0(n28), .A1(n470), .B0(n469), .Y(n479) );
  AO21XL U254 ( .A0(n709), .A1(n708), .B0(n707), .Y(n731) );
  NOR2XL U255 ( .A(n778), .B(n710), .Y(n730) );
  INVXL U256 ( .A(n732), .Y(n735) );
  NOR2XL U257 ( .A(n778), .B(n635), .Y(n734) );
  OAI22XL U258 ( .A0(n12), .A1(n22), .B0(n708), .B1(n623), .Y(n634) );
  NOR2XL U259 ( .A(n778), .B(n522), .Y(n615) );
  INVXL U260 ( .A(n639), .Y(n616) );
  AO21XL U261 ( .A0(n612), .A1(n611), .B0(n610), .Y(n638) );
  NOR2XL U262 ( .A(n778), .B(n613), .Y(n637) );
  INVXL U263 ( .A(n5), .Y(n613) );
  OAI22XL U264 ( .A0(n22), .A1(n623), .B0(n708), .B1(n534), .Y(n620) );
  OAI22XL U265 ( .A0(n780), .A1(n609), .B0(n779), .B1(n533), .Y(n621) );
  AND2XL U266 ( .A(n384), .B(n383), .Y(n7) );
  OAI22XL U267 ( .A0(dividend[1]), .A1(n362), .B0(n364), .B1(n99), .Y(n63) );
  OAI22XL U268 ( .A0(n779), .A1(n467), .B0(n780), .B1(n533), .Y(n519) );
  OAI22XL U269 ( .A0(n708), .A1(n82), .B0(n709), .B1(n106), .Y(n108) );
  OAI22XL U270 ( .A0(n779), .A1(n75), .B0(n780), .B1(n119), .Y(n115) );
  OAI22XL U271 ( .A0(n709), .A1(n486), .B0(n708), .B1(n106), .Y(n487) );
  OAI22XL U272 ( .A0(n708), .A1(n486), .B0(n709), .B1(n485), .Y(n490) );
  INVXL U273 ( .A(div_inverse_4_), .Y(n484) );
  OAI22XL U274 ( .A0(n780), .A1(n494), .B0(n779), .B1(n119), .Y(n545) );
  OAI22XL U275 ( .A0(n779), .A1(n494), .B0(n780), .B1(n493), .Y(n511) );
  OAI22XL U276 ( .A0(n780), .A1(n467), .B0(n779), .B1(n493), .Y(n517) );
  NOR2XL U277 ( .A(n778), .B(n465), .Y(n513) );
  INVXL U278 ( .A(n532), .Y(n514) );
  OAI22XL U279 ( .A0(n709), .A1(n502), .B0(n708), .B1(n485), .Y(n512) );
  OAI22XL U280 ( .A0(n779), .A1(n716), .B0(n780), .B1(n715), .Y(n746) );
  NOR2XL U281 ( .A(n778), .B(n701), .Y(n728) );
  INVXL U282 ( .A(n700), .Y(n729) );
  OAI22XL U283 ( .A0(n16), .A1(n703), .B0(n779), .B1(n715), .Y(n727) );
  OAI22XL U284 ( .A0(n779), .A1(n703), .B0(n780), .B1(n694), .Y(n705) );
  NOR2XL U285 ( .A(n805), .B(n817), .Y(n772) );
  NOR2XL U286 ( .A(n778), .B(n687), .Y(n698) );
  INVXL U287 ( .A(n686), .Y(n699) );
  INVXL U288 ( .A(div_inverse_13_), .Y(n687) );
  AO22XL U289 ( .A0(n262), .A1(n261), .B0(n260), .B1(n259), .Y(n39) );
  AO22XL U290 ( .A0(n298), .A1(n297), .B0(n45), .B1(n296), .Y(n29) );
  NAND2XL U291 ( .A(n772), .B(n821), .Y(n792) );
  AOI21XL U292 ( .A0(n772), .A1(n820), .B0(n771), .Y(n793) );
  OAI21XL U293 ( .A0(n805), .A1(n819), .B0(n807), .Y(n771) );
  AOI2BB1XL U294 ( .A0N(n422), .A1N(n421), .B0(n420), .Y(n423) );
  AO22XL U296 ( .A0(n202), .A1(n201), .B0(n179), .B1(n203), .Y(n35) );
  INVXL U297 ( .A(n202), .Y(n175) );
  NAND2XL U298 ( .A(n658), .B(n657), .Y(n662) );
  OAI21XL U299 ( .A0(n656), .A1(n655), .B0(n654), .Y(n663) );
  OR2XL U300 ( .A(n658), .B(n657), .Y(n661) );
  NOR2XL U301 ( .A(n539), .B(n538), .Y(n656) );
  NAND2XL U302 ( .A(n539), .B(n538), .Y(n654) );
  NOR2XL U303 ( .A(n768), .B(n767), .Y(n817) );
  NOR2XL U304 ( .A(n826), .B(n824), .Y(n821) );
  OAI21XL U305 ( .A0(n826), .A1(n829), .B0(n828), .Y(n820) );
  NAND2XL U306 ( .A(n768), .B(n767), .Y(n819) );
  NOR2XL U307 ( .A(n770), .B(n769), .Y(n805) );
  NOR2XL U308 ( .A(n817), .B(n808), .Y(n811) );
  INVXL U309 ( .A(n821), .Y(n808) );
  OAI21XL U310 ( .A0(n817), .A1(n809), .B0(n819), .Y(n810) );
  INVXL U311 ( .A(n820), .Y(n809) );
  NAND2XL U312 ( .A(n770), .B(n769), .Y(n807) );
  NOR2XL U313 ( .A(n774), .B(n773), .Y(n789) );
  INVXL U314 ( .A(n792), .Y(n795) );
  INVXL U315 ( .A(n793), .Y(n794) );
  NAND2XL U316 ( .A(n774), .B(n773), .Y(n791) );
  AO21XL U317 ( .A0(n18), .A1(n720), .B0(n682), .Y(n685) );
  NAND2XL U318 ( .A(n776), .B(n775), .Y(n798) );
  OR2XL U319 ( .A(n776), .B(n775), .Y(n32) );
  OR2XL U320 ( .A(n440), .B(n439), .Y(n446) );
  OR2XL U321 ( .A(n444), .B(n443), .Y(n458) );
  NAND2XL U322 ( .A(n586), .B(n585), .Y(n599) );
  OR2XL U323 ( .A(n586), .B(n585), .Y(n598) );
  NAND2XL U324 ( .A(n581), .B(n580), .Y(n590) );
  OR2XL U325 ( .A(n581), .B(n580), .Y(n589) );
  NOR2XL U326 ( .A(n127), .B(n126), .Y(n579) );
  NAND2XL U327 ( .A(n127), .B(n126), .Y(n577) );
  NOR2XL U328 ( .A(n584), .B(n583), .Y(n593) );
  NAND2XL U329 ( .A(n584), .B(n583), .Y(n595) );
  XOR2XL U330 ( .A(n660), .B(n761), .Y(n860) );
  NAND2XL U331 ( .A(n760), .B(n647), .Y(n660) );
  INVXL U332 ( .A(n762), .Y(n647) );
  XOR2XL U333 ( .A(n834), .B(n833), .Y(n870) );
  NAND2XL U334 ( .A(n828), .B(n827), .Y(n834) );
  INVXL U335 ( .A(n860), .Y(n865) );
  INVXL U336 ( .A(n862), .Y(n867) );
  INVXL U337 ( .A(n870), .Y(n846) );
  INVXL U338 ( .A(n882), .Y(n678) );
  NAND2XL U339 ( .A(n863), .B(n854), .Y(n607) );
  INVXL U340 ( .A(n851), .Y(n673) );
  NOR2XL U341 ( .A(div_shift_0_), .B(n844), .Y(n882) );
  INVXL U342 ( .A(n886), .Y(n863) );
  NAND2XL U343 ( .A(n863), .B(n866), .Y(n676) );
  AOI21XL U344 ( .A0(n863), .A1(n860), .B0(n666), .Y(n875) );
  AOI22XL U345 ( .A0(n889), .A1(n856), .B0(n879), .B1(n858), .Y(n665) );
  OAI211XL U346 ( .A0(n886), .A1(n870), .B0(n869), .C0(n868), .Y(n887) );
  AOI22XL U347 ( .A0(n889), .A1(n866), .B0(n879), .B1(n865), .Y(n869) );
  NAND2XL U348 ( .A(n882), .B(n867), .Y(n868) );
  OAI211XL U349 ( .A0(n886), .A1(n838), .B0(n836), .C0(n835), .Y(n872) );
  AOI22XL U350 ( .A0(n889), .A1(n865), .B0(n879), .B1(n867), .Y(n836) );
  NAND2XL U351 ( .A(n882), .B(n846), .Y(n835) );
  OAI211XL U352 ( .A0(n886), .A1(n841), .B0(n840), .C0(n839), .Y(n874) );
  NAND2XL U353 ( .A(n882), .B(n880), .Y(n839) );
  AOI22XL U354 ( .A0(n889), .A1(n867), .B0(n879), .B1(n846), .Y(n840) );
  NAND2XL U355 ( .A(n882), .B(n878), .Y(n847) );
  AOI22XL U356 ( .A0(n889), .A1(n846), .B0(n879), .B1(n880), .Y(n848) );
  NOR2XL U357 ( .A(div_shift_0_), .B(div_shift_1_), .Y(n889) );
  XOR2XL U358 ( .A(n36), .B(n788), .Y(n888) );
  XOR2XL U359 ( .A(n787), .B(n786), .Y(n788) );
  AO21XL U360 ( .A0(n34), .A1(n831), .B0(n33), .Y(n36) );
  MX2XL U361 ( .A(n606), .B(n605), .S0(div_shift_2_), .Y(quotient[0]) );
  AOI22XL U362 ( .A0(n889), .A1(n456), .B0(n879), .B1(n670), .Y(n463) );
  MX2XL U363 ( .A(n680), .B(n679), .S0(div_shift_2_), .Y(quotient[1]) );
  INVXL U364 ( .A(n873), .Y(n679) );
  AOI22XL U365 ( .A0(n889), .A1(n670), .B0(n879), .B1(n669), .Y(n672) );
  MX2XL U366 ( .A(n668), .B(n667), .S0(div_shift_2_), .Y(quotient[2]) );
  INVXL U367 ( .A(n875), .Y(n667) );
  AOI22XL U368 ( .A0(n889), .A1(n669), .B0(n879), .B1(n852), .Y(n608) );
  AOI22XL U369 ( .A0(n889), .A1(n852), .B0(n879), .B1(n851), .Y(n853) );
  INVXL U370 ( .A(div_shift_0_), .Y(n450) );
  INVXL U371 ( .A(n688), .Y(n8) );
  INVXL U372 ( .A(n469), .Y(n9) );
  INVXL U373 ( .A(dividend[3]), .Y(n469) );
  INVXL U374 ( .A(n504), .Y(n10) );
  INVXL U375 ( .A(dividend[5]), .Y(n504) );
  INVXL U376 ( .A(n610), .Y(n11) );
  INVXL U377 ( .A(n707), .Y(n12) );
  INVXL U378 ( .A(n682), .Y(n13) );
  INVXL U379 ( .A(n778), .Y(n14) );
  INVXL U380 ( .A(dividend[15]), .Y(n778) );
  INVXL U381 ( .A(n780), .Y(n15) );
  INVXL U382 ( .A(n15), .Y(n16) );
  OAI22XL U383 ( .A0(n780), .A1(n75), .B0(n779), .B1(n86), .Y(n58) );
  XNOR2X1 U384 ( .A(dividend[13]), .B(dividend[14]), .Y(n780) );
  INVXL U385 ( .A(n718), .Y(n17) );
  INVXL U386 ( .A(n17), .Y(n18) );
  OAI22XL U387 ( .A0(n18), .A1(n711), .B0(n720), .B1(n717), .Y(n740) );
  OAI22XL U388 ( .A0(n13), .A1(n718), .B0(n720), .B1(n711), .Y(n706) );
  OAI22XL U389 ( .A0(n720), .A1(n503), .B0(n718), .B1(n518), .Y(n528) );
  OAI22XL U390 ( .A0(n720), .A1(n719), .B0(n718), .B1(n717), .Y(n745) );
  OAI22XL U391 ( .A0(n720), .A1(n624), .B0(n718), .B1(n636), .Y(n633) );
  OAI22XL U392 ( .A0(n718), .A1(n719), .B0(n720), .B1(n636), .Y(n733) );
  OAI22XL U393 ( .A0(n718), .A1(n503), .B0(n720), .B1(n495), .Y(n516) );
  OAI22XL U394 ( .A0(n720), .A1(n496), .B0(n718), .B1(n495), .Y(n510) );
  OAI22XL U395 ( .A0(n718), .A1(n496), .B0(n720), .B1(n102), .Y(n474) );
  OAI22XL U396 ( .A0(n720), .A1(n51), .B0(n718), .B1(n102), .Y(n121) );
  OAI22XL U397 ( .A0(n718), .A1(n51), .B0(n720), .B1(n92), .Y(n56) );
  NAND2XL U398 ( .A(n47), .B(n718), .Y(n720) );
  INVXL U399 ( .A(n714), .Y(n19) );
  INVXL U400 ( .A(n19), .Y(n20) );
  OAI22XL U401 ( .A0(n713), .A1(n625), .B0(n20), .B1(n640), .Y(n632) );
  OAI22XL U402 ( .A0(dividend[11]), .A1(n20), .B0(n713), .B1(n712), .Y(n747)
         );
  OAI22XL U403 ( .A0(n714), .A1(n712), .B0(n713), .B1(n640), .Y(n737) );
  OAI22XL U404 ( .A0(n713), .A1(n477), .B0(n714), .B1(n523), .Y(n520) );
  OAI22XL U405 ( .A0(n714), .A1(n477), .B0(n713), .B1(n476), .Y(n501) );
  OAI22XL U406 ( .A0(n714), .A1(n625), .B0(n713), .B1(n523), .Y(n614) );
  OAI22XL U407 ( .A0(n714), .A1(n468), .B0(n713), .B1(n103), .Y(n473) );
  OAI22XL U408 ( .A0(n713), .A1(n80), .B0(n714), .B1(n103), .Y(n120) );
  OAI22XL U409 ( .A0(n714), .A1(n80), .B0(n713), .B1(n79), .Y(n91) );
  NAND2XL U410 ( .A(n48), .B(n714), .Y(n713) );
  XNOR2X1 U411 ( .A(dividend[9]), .B(dividend[10]), .Y(n714) );
  INVXL U412 ( .A(n709), .Y(n21) );
  INVXL U413 ( .A(n21), .Y(n22) );
  INVXL U414 ( .A(n612), .Y(n23) );
  INVXL U415 ( .A(n23), .Y(n24) );
  OAI22XL U416 ( .A0(n24), .A1(n466), .B0(n611), .B1(n497), .Y(n515) );
  OAI22XL U417 ( .A0(n11), .A1(n24), .B0(n611), .B1(n466), .Y(n521) );
  OAI22XL U418 ( .A0(n611), .A1(n498), .B0(n612), .B1(n497), .Y(n509) );
  OAI22XL U419 ( .A0(n612), .A1(n498), .B0(n611), .B1(n101), .Y(n475) );
  OAI22XL U420 ( .A0(n611), .A1(n50), .B0(n612), .B1(n101), .Y(n122) );
  OAI22XL U421 ( .A0(n612), .A1(n50), .B0(n611), .B1(n85), .Y(n57) );
  NAND2XL U422 ( .A(n46), .B(n612), .Y(n611) );
  INVXL U423 ( .A(n506), .Y(n25) );
  INVXL U424 ( .A(n25), .Y(n26) );
  OAI22XL U425 ( .A0(n506), .A1(n472), .B0(n505), .B1(n105), .Y(n488) );
  OAI22XL U426 ( .A0(n505), .A1(n61), .B0(n506), .B1(n105), .Y(n109) );
  OAI22XL U427 ( .A0(n505), .A1(n100), .B0(n506), .B1(n60), .Y(n62) );
  NAND2XL U428 ( .A(n52), .B(n506), .Y(n505) );
  XNOR2X1 U429 ( .A(dividend[3]), .B(dividend[4]), .Y(n506) );
  INVXL U430 ( .A(n471), .Y(n27) );
  INVXL U431 ( .A(n27), .Y(n28) );
  NAND2XL U432 ( .A(n55), .B(n471), .Y(n470) );
  XNOR2X1 U433 ( .A(dividend[1]), .B(dividend[2]), .Y(n471) );
  NOR2XL U434 ( .A(div_shift_1_), .B(n450), .Y(n879) );
  INVXL U435 ( .A(div_shift_1_), .Y(n844) );
  NAND2XL U436 ( .A(div_shift_0_), .B(div_shift_1_), .Y(n886) );
  ADDHX1 U437 ( .A(n355), .B(n354), .CO(n365), .S(n356) );
  ADDFXL U438 ( .A(n265), .B(n264), .CI(n263), .CO(n435), .S(n427) );
  ADDFXL U440 ( .A(n162), .B(n161), .CI(n160), .CO(n153), .S(n199) );
  MXI2XL U441 ( .A(n887), .B(n891), .S0(div_shift_2_), .Y(quotient[8]) );
  MXI2XL U442 ( .A(n877), .B(n876), .S0(div_shift_2_), .Y(quotient[7]) );
  INVXL U443 ( .A(div_inverse_14_), .Y(n683) );
  ADDFXL U444 ( .A(n169), .B(n168), .CI(n167), .CO(n160), .S(n219) );
  OAI21X1 U445 ( .A0(n762), .A1(n761), .B0(n760), .Y(n831) );
  AOI21XL U446 ( .A0(n811), .A1(n831), .B0(n810), .Y(n812) );
  AOI21XL U447 ( .A0(n800), .A1(n831), .B0(n799), .Y(n801) );
  AOI21XL U448 ( .A0(n795), .A1(n831), .B0(n794), .Y(n796) );
  AO22XL U449 ( .A0(n405), .A1(n404), .B0(n42), .B1(n406), .Y(n30) );
  AND2XL U450 ( .A(n378), .B(n377), .Y(n31) );
  AND2XL U451 ( .A(n369), .B(n368), .Y(n37) );
  AND2XL U452 ( .A(n350), .B(n351), .Y(n38) );
  OR2XL U453 ( .A(n391), .B(n390), .Y(n40) );
  AO22XL U454 ( .A0(n391), .A1(n390), .B0(n40), .B1(n389), .Y(n41) );
  OR2XL U455 ( .A(n405), .B(n404), .Y(n42) );
  AND2XL U456 ( .A(n382), .B(n381), .Y(n43) );
  OR2XL U457 ( .A(n298), .B(n297), .Y(n45) );
  NAND2XL U458 ( .A(n331), .B(n330), .Y(n308) );
  NAND2BXL U459 ( .AN(div_inverse_0_), .B(dividend[15]), .Y(n68) );
  XNOR2X1 U460 ( .A(dividend[5]), .B(n4), .Y(n170) );
  INVXL U461 ( .A(n201), .Y(n174) );
  OAI22XL U462 ( .A0(n28), .A1(n84), .B0(n470), .B1(n83), .Y(n89) );
  OAI22XL U463 ( .A0(n9), .A1(n28), .B0(n470), .B1(n84), .Y(n116) );
  OAI22XL U464 ( .A0(n10), .A1(n506), .B0(n505), .B1(n472), .Y(n478) );
  INVXL U465 ( .A(div_inverse_7_), .Y(n522) );
  INVXL U466 ( .A(div_inverse_10_), .Y(n710) );
  NAND2XL U467 ( .A(n175), .B(n174), .Y(n179) );
  NOR2XL U468 ( .A(n778), .B(n484), .Y(n491) );
  OAI22XL U469 ( .A0(n713), .A1(n468), .B0(n714), .B1(n476), .Y(n549) );
  OAI22XL U470 ( .A0(n708), .A1(n502), .B0(n22), .B1(n534), .Y(n529) );
  INVXL U471 ( .A(div_inverse_11_), .Y(n701) );
  OAI22XL U472 ( .A0(n718), .A1(n624), .B0(n720), .B1(n518), .Y(n628) );
  OAI22XL U473 ( .A0(n779), .A1(n609), .B0(n16), .B1(n641), .Y(n631) );
  OAI22XL U474 ( .A0(n16), .A1(n693), .B0(n779), .B1(n694), .Y(n723) );
  NOR2XL U475 ( .A(n778), .B(n683), .Y(n684) );
  NAND2XL U476 ( .A(n440), .B(n439), .Y(n447) );
  NAND2XL U477 ( .A(n447), .B(n446), .Y(n449) );
  NAND2XL U478 ( .A(n595), .B(n594), .Y(n597) );
  INVXL U479 ( .A(n826), .Y(n827) );
  NOR2XL U480 ( .A(n789), .B(n792), .Y(n800) );
  NAND2XL U481 ( .A(n599), .B(n598), .Y(n601) );
  NAND2XL U482 ( .A(n829), .B(n832), .Y(n825) );
  NAND2XL U483 ( .A(n798), .B(n32), .Y(n802) );
  NAND2XL U484 ( .A(n882), .B(n669), .Y(n462) );
  NAND2XL U485 ( .A(n882), .B(n852), .Y(n671) );
  INVXL U486 ( .A(n871), .Y(n605) );
  AOI21XL U487 ( .A0(n863), .A1(n856), .B0(n855), .Y(n864) );
  BUFX2 U488 ( .A(div_inverse_6_), .Y(n507) );
  ADDFX1 U489 ( .A(n58), .B(n57), .CI(n56), .CO(n124), .S(n149) );
  BUFX2 U490 ( .A(div_inverse_0_), .Y(n349) );
  OAI22XL U491 ( .A0(n713), .A1(n70), .B0(n714), .B1(n79), .Y(n67) );
  OAI22XL U492 ( .A0(n708), .A1(n94), .B0(n709), .B1(n81), .Y(n66) );
  OAI22XL U493 ( .A0(n470), .A1(n69), .B0(n471), .B1(n83), .Y(n65) );
  INVXL U494 ( .A(div_inverse_1_), .Y(n59) );
  NOR2XL U495 ( .A(n778), .B(n59), .Y(n77) );
  OAI22XL U496 ( .A0(n506), .A1(n61), .B0(n505), .B1(n60), .Y(n76) );
  ADDFX1 U497 ( .A(n64), .B(n63), .CI(n62), .CO(n74), .S(n155) );
  ADDFX1 U498 ( .A(n67), .B(n66), .CI(n65), .CO(n73), .S(n154) );
  OAI22XL U499 ( .A0(n778), .A1(n779), .B0(n780), .B1(n68), .Y(n88) );
  OAI22XL U500 ( .A0(n471), .A1(n69), .B0(n470), .B1(n71), .Y(n87) );
  OAI22XL U501 ( .A0(n714), .A1(n70), .B0(n713), .B1(n159), .Y(n161) );
  OAI22XL U502 ( .A0(n470), .A1(n171), .B0(n471), .B1(n71), .Y(n168) );
  XNOR2X1 U503 ( .A(dividend[9]), .B(n507), .Y(n93) );
  ADDFX1 U504 ( .A(n74), .B(n73), .CI(n72), .CO(n112), .S(n148) );
  ADDFX1 U505 ( .A(n78), .B(n77), .CI(n76), .CO(n114), .S(n72) );
  OAI22XL U506 ( .A0(n611), .A1(n98), .B0(n612), .B1(n85), .Y(n134) );
  OAI22XL U507 ( .A0(n779), .A1(n95), .B0(n780), .B1(n86), .Y(n133) );
  ADDFX1 U508 ( .A(n91), .B(n90), .CI(n89), .CO(n113), .S(n130) );
  OAI22XL U509 ( .A0(n720), .A1(n97), .B0(n718), .B1(n92), .Y(n137) );
  OAI22XL U510 ( .A0(n709), .A1(n94), .B0(n708), .B1(n93), .Y(n143) );
  OAI22XL U511 ( .A0(n779), .A1(n96), .B0(n780), .B1(n95), .Y(n142) );
  OAI22XL U512 ( .A0(n718), .A1(n97), .B0(n720), .B1(n140), .Y(n141) );
  OAI22XL U513 ( .A0(n612), .A1(n98), .B0(n611), .B1(n138), .Y(n146) );
  OAI22XL U514 ( .A0(n362), .A1(n99), .B0(n364), .B1(n139), .Y(n145) );
  OAI22XL U515 ( .A0(n506), .A1(n100), .B0(n505), .B1(n156), .Y(n144) );
  MXI2XL U516 ( .A(n470), .B(n471), .S0(n9), .Y(n480) );
  ADDFX1 U517 ( .A(n109), .B(n108), .CI(n107), .CO(n550), .S(n123) );
  ADDFX1 U518 ( .A(n112), .B(n111), .CI(n110), .CO(n572), .S(n150) );
  ADDFX1 U519 ( .A(n115), .B(n114), .CI(n113), .CO(n564), .S(n111) );
  ADDFX1 U520 ( .A(n118), .B(n117), .CI(n116), .CO(n546), .S(n107) );
  ADDFX1 U521 ( .A(n122), .B(n121), .CI(n120), .CO(n544), .S(n125) );
  ADDFX1 U522 ( .A(n125), .B(n124), .CI(n123), .CO(n562), .S(n152) );
  ADDFX1 U523 ( .A(n131), .B(n130), .CI(n129), .CO(n110), .S(n182) );
  ADDFX1 U524 ( .A(n134), .B(n133), .CI(n132), .CO(n131), .S(n178) );
  ADDFX1 U525 ( .A(n137), .B(n136), .CI(n135), .CO(n129), .S(n177) );
  OAI22XL U526 ( .A0(n611), .A1(n163), .B0(n612), .B1(n138), .Y(n188) );
  OAI22XL U527 ( .A0(n364), .A1(n158), .B0(n362), .B1(n139), .Y(n187) );
  OAI22XL U528 ( .A0(n720), .A1(n164), .B0(n718), .B1(n140), .Y(n186) );
  ADDFX1 U529 ( .A(n143), .B(n142), .CI(n141), .CO(n136), .S(n184) );
  ADDFX1 U530 ( .A(n146), .B(n145), .CI(n144), .CO(n135), .S(n183) );
  ADDFX1 U531 ( .A(n149), .B(n148), .CI(n147), .CO(n151), .S(n180) );
  ADDFX1 U532 ( .A(n152), .B(n151), .CI(n150), .CO(n127), .S(n443) );
  ADDFX1 U533 ( .A(n155), .B(n154), .CI(n153), .CO(n147), .S(n202) );
  OAI22XL U534 ( .A0(n505), .A1(n170), .B0(n506), .B1(n156), .Y(n197) );
  INVXL U535 ( .A(dividend[13]), .Y(n682) );
  OAI22XL U536 ( .A0(n682), .A1(n720), .B0(n718), .B1(n157), .Y(n173) );
  OAI22XL U537 ( .A0(n362), .A1(n158), .B0(n364), .B1(n190), .Y(n172) );
  OAI22XL U538 ( .A0(n713), .A1(n166), .B0(n714), .B1(n159), .Y(n195) );
  XNOR2XL U539 ( .A(dividend[7]), .B(div_inverse_6_), .Y(n191) );
  OAI22XL U540 ( .A0(n612), .A1(n163), .B0(n611), .B1(n191), .Y(n207) );
  OAI22XL U541 ( .A0(n720), .A1(n165), .B0(n718), .B1(n164), .Y(n206) );
  OAI22XL U542 ( .A0(n714), .A1(n166), .B0(n713), .B1(n194), .Y(n205) );
  XNOR2X1 U543 ( .A(dividend[5]), .B(n5), .Y(n192) );
  OAI22XL U544 ( .A0(n506), .A1(n170), .B0(n505), .B1(n192), .Y(n217) );
  OAI22XL U545 ( .A0(n471), .A1(n171), .B0(n470), .B1(n193), .Y(n216) );
  ADDFX1 U546 ( .A(n178), .B(n177), .CI(n176), .CO(n181), .S(n203) );
  ADDFX1 U547 ( .A(n182), .B(n181), .CI(n180), .CO(n444), .S(n442) );
  NOR2XL U548 ( .A(n35), .B(n442), .Y(n451) );
  ADDFX1 U549 ( .A(n185), .B(n184), .CI(n183), .CO(n176), .S(n226) );
  ADDFX1 U550 ( .A(n188), .B(n187), .CI(n186), .CO(n185), .S(n223) );
  OAI22XL U551 ( .A0(n709), .A1(n189), .B0(n708), .B1(n210), .Y(n251) );
  OAI22XL U552 ( .A0(n364), .A1(n214), .B0(n362), .B1(n190), .Y(n239) );
  OAI22XL U553 ( .A0(n611), .A1(n246), .B0(n612), .B1(n191), .Y(n238) );
  OAI22XL U554 ( .A0(n505), .A1(n209), .B0(n506), .B1(n192), .Y(n243) );
  OAI22XL U555 ( .A0(n470), .A1(n211), .B0(n471), .B1(n193), .Y(n242) );
  INVXL U556 ( .A(dividend[11]), .Y(n688) );
  OAI22XL U557 ( .A0(n713), .A1(n212), .B0(n714), .B1(n194), .Y(n241) );
  ADDFX1 U558 ( .A(n197), .B(n196), .CI(n195), .CO(n200), .S(n221) );
  ADDFX1 U559 ( .A(n200), .B(n199), .CI(n198), .CO(n201), .S(n224) );
  ADDFX1 U560 ( .A(n207), .B(n206), .CI(n205), .CO(n220), .S(n257) );
  NAND2BXL U561 ( .AN(div_inverse_0_), .B(dividend[11]), .Y(n208) );
  OAI22XL U562 ( .A0(n688), .A1(n713), .B0(n714), .B1(n208), .Y(n248) );
  XNOR2XL U563 ( .A(dividend[5]), .B(div_inverse_6_), .Y(n230) );
  OAI22XL U564 ( .A0(n506), .A1(n209), .B0(n505), .B1(n230), .Y(n247) );
  OAI22XL U565 ( .A0(n708), .A1(n245), .B0(n709), .B1(n210), .Y(n228) );
  OAI22XL U566 ( .A0(n471), .A1(n211), .B0(n470), .B1(n231), .Y(n237) );
  OAI22XL U567 ( .A0(n362), .A1(n214), .B0(n364), .B1(n232), .Y(n235) );
  ADDFX1 U568 ( .A(n217), .B(n216), .CI(n215), .CO(n218), .S(n255) );
  ADDFX1 U569 ( .A(n220), .B(n219), .CI(n218), .CO(n198), .S(n264) );
  ADDFX1 U570 ( .A(n223), .B(n222), .CI(n221), .CO(n225), .S(n263) );
  ADDFX1 U571 ( .A(n226), .B(n225), .CI(n224), .CO(n440), .S(n434) );
  NOR2XL U572 ( .A(n435), .B(n434), .Y(n438) );
  ADDFX1 U573 ( .A(n229), .B(n228), .CI(n227), .CO(n256), .S(n298) );
  OAI22XL U574 ( .A0(n505), .A1(n270), .B0(n506), .B1(n230), .Y(n281) );
  OAI22XL U575 ( .A0(n470), .A1(n234), .B0(n471), .B1(n231), .Y(n280) );
  OAI22XL U576 ( .A0(n364), .A1(n276), .B0(n362), .B1(n232), .Y(n269) );
  OAI22XL U577 ( .A0(n708), .A1(n277), .B0(n709), .B1(n244), .Y(n268) );
  INVXL U578 ( .A(dividend[9]), .Y(n707) );
  NAND2BXL U579 ( .AN(div_inverse_0_), .B(dividend[9]), .Y(n233) );
  OAI22XL U580 ( .A0(n707), .A1(n708), .B0(n709), .B1(n233), .Y(n272) );
  XNOR2XL U581 ( .A(dividend[3]), .B(div_inverse_6_), .Y(n273) );
  OAI22XL U582 ( .A0(n471), .A1(n234), .B0(n470), .B1(n273), .Y(n271) );
  ADDFX1 U583 ( .A(n237), .B(n236), .CI(n235), .CO(n227), .S(n289) );
  ADDFX1 U584 ( .A(n240), .B(n239), .CI(n238), .CO(n250), .S(n254) );
  OAI22XL U585 ( .A0(n709), .A1(n245), .B0(n708), .B1(n244), .Y(n285) );
  OAI22XL U586 ( .A0(n612), .A1(n246), .B0(n611), .B1(n274), .Y(n284) );
  ADDFX1 U587 ( .A(n251), .B(n250), .CI(n249), .CO(n222), .S(n261) );
  ADDFX1 U588 ( .A(n254), .B(n253), .CI(n252), .CO(n262), .S(n296) );
  ADDFX1 U589 ( .A(n257), .B(n256), .CI(n255), .CO(n265), .S(n259) );
  NOR2XL U590 ( .A(n29), .B(n426), .Y(n266) );
  OR2XL U591 ( .A(n261), .B(n262), .Y(n260) );
  NOR2XL U592 ( .A(n39), .B(n427), .Y(n429) );
  NOR2XL U593 ( .A(n266), .B(n429), .Y(n433) );
  ADDFX1 U594 ( .A(n269), .B(n268), .CI(n267), .CO(n290), .S(n405) );
  OAI22XL U595 ( .A0(n506), .A1(n270), .B0(n505), .B1(n319), .Y(n400) );
  OAI22XL U596 ( .A0(n470), .A1(n306), .B0(n471), .B1(n273), .Y(n310) );
  OAI22XL U597 ( .A0(n364), .A1(n302), .B0(n362), .B1(n275), .Y(n309) );
  OAI22XL U598 ( .A0(n611), .A1(n279), .B0(n612), .B1(n274), .Y(n288) );
  OAI22XL U599 ( .A0(n362), .A1(n276), .B0(n364), .B1(n275), .Y(n394) );
  OAI22XL U600 ( .A0(n708), .A1(n278), .B0(n709), .B1(n277), .Y(n393) );
  OAI22XL U601 ( .A0(n612), .A1(n279), .B0(n611), .B1(n317), .Y(n392) );
  ADDFX1 U602 ( .A(n282), .B(n281), .CI(n280), .CO(n291), .S(n286) );
  ADDFX1 U603 ( .A(n285), .B(n284), .CI(n283), .CO(n252), .S(n294) );
  ADDFX1 U604 ( .A(n288), .B(n287), .CI(n286), .CO(n295), .S(n406) );
  ADDFX1 U605 ( .A(n291), .B(n290), .CI(n289), .CO(n297), .S(n292) );
  XOR3XL U606 ( .A(n294), .B(n295), .C(n292), .Y(n418) );
  OR2XL U607 ( .A(n30), .B(n418), .Y(n300) );
  OR2XL U608 ( .A(n294), .B(n295), .Y(n293) );
  XOR3XL U609 ( .A(n298), .B(n297), .C(n296), .Y(n419) );
  OR2XL U610 ( .A(n44), .B(n419), .Y(n299) );
  NAND2XL U611 ( .A(n300), .B(n299), .Y(n425) );
  INVXL U612 ( .A(dividend[7]), .Y(n610) );
  NAND2BXL U613 ( .AN(div_inverse_0_), .B(dividend[7]), .Y(n301) );
  OAI22XL U614 ( .A0(n610), .A1(n611), .B0(n612), .B1(n301), .Y(n316) );
  XNOR2XL U615 ( .A(dividend[1]), .B(div_inverse_6_), .Y(n303) );
  OAI22XL U616 ( .A0(n362), .A1(n302), .B0(n364), .B1(n303), .Y(n315) );
  OAI22XL U617 ( .A0(n364), .A1(n334), .B0(n362), .B1(n303), .Y(n327) );
  OAI22XL U618 ( .A0(n505), .A1(n323), .B0(n506), .B1(n305), .Y(n326) );
  OAI22XL U619 ( .A0(n611), .A1(n304), .B0(n612), .B1(n318), .Y(n314) );
  OAI22XL U620 ( .A0(n506), .A1(n320), .B0(n505), .B1(n305), .Y(n313) );
  OAI22XL U621 ( .A0(n471), .A1(n306), .B0(n470), .B1(n325), .Y(n312) );
  OAI21XL U622 ( .A0(n330), .A1(n331), .B0(n329), .Y(n307) );
  NAND2XL U623 ( .A(n308), .B(n307), .Y(n384) );
  ADDFX1 U624 ( .A(n311), .B(n310), .CI(n309), .CO(n398), .S(n391) );
  ADDFX1 U625 ( .A(n314), .B(n313), .CI(n312), .CO(n390), .S(n329) );
  XNOR2XL U626 ( .A(n391), .B(n390), .Y(n321) );
  OAI22XL U627 ( .A0(n611), .A1(n318), .B0(n612), .B1(n317), .Y(n396) );
  OAI22XL U628 ( .A0(n505), .A1(n320), .B0(n506), .B1(n319), .Y(n395) );
  OR2XL U629 ( .A(n384), .B(n383), .Y(n385) );
  NAND2BXL U630 ( .AN(div_inverse_0_), .B(dividend[5]), .Y(n322) );
  OAI22XL U631 ( .A0(n504), .A1(n505), .B0(n506), .B1(n322), .Y(n336) );
  OAI22XL U632 ( .A0(n505), .A1(n324), .B0(n506), .B1(n323), .Y(n335) );
  OAI22XL U633 ( .A0(n470), .A1(n333), .B0(n471), .B1(n325), .Y(n338) );
  ADDFX1 U634 ( .A(n328), .B(n327), .CI(n326), .CO(n330), .S(n337) );
  XOR3XL U635 ( .A(n331), .B(n330), .C(n329), .Y(n381) );
  OR2XL U636 ( .A(n382), .B(n381), .Y(n332) );
  NAND2XL U637 ( .A(n385), .B(n332), .Y(n388) );
  OAI22XL U638 ( .A0(n471), .A1(n333), .B0(n470), .B1(n340), .Y(n346) );
  OAI22XL U639 ( .A0(n362), .A1(n334), .B0(n364), .B1(n361), .Y(n345) );
  ADDFX1 U640 ( .A(n339), .B(n338), .CI(n337), .CO(n382), .S(n377) );
  OR2XL U641 ( .A(n378), .B(n377), .Y(n380) );
  OAI22XL U642 ( .A0(n470), .A1(n342), .B0(n471), .B1(n340), .Y(n366) );
  NAND2BXL U643 ( .AN(div_inverse_0_), .B(dividend[3]), .Y(n341) );
  OAI22XL U644 ( .A0(n469), .A1(n470), .B0(n471), .B1(n341), .Y(n355) );
  OAI22XL U645 ( .A0(n470), .A1(n343), .B0(n471), .B1(n342), .Y(n354) );
  ADDFX1 U646 ( .A(n346), .B(n345), .CI(n344), .CO(n378), .S(n372) );
  NOR2XL U647 ( .A(n373), .B(n372), .Y(n376) );
  NAND2BXL U648 ( .AN(div_inverse_0_), .B(dividend[1]), .Y(n347) );
  INVXL U649 ( .A(n347), .Y(n348) );
  AND2XL U650 ( .A(n348), .B(n59), .Y(n352) );
  OAI22XL U651 ( .A0(n364), .A1(div_inverse_1_), .B0(n362), .B1(n353), .Y(n351) );
  AOI21XL U652 ( .A0(n352), .A1(n351), .B0(n38), .Y(n360) );
  OAI22XL U653 ( .A0(n362), .A1(n363), .B0(n364), .B1(n353), .Y(n357) );
  NOR2XL U654 ( .A(n357), .B(n356), .Y(n359) );
  NAND2XL U655 ( .A(n357), .B(n356), .Y(n358) );
  OAI21XL U656 ( .A0(n360), .A1(n359), .B0(n358), .Y(n371) );
  OAI22XL U657 ( .A0(n364), .A1(n363), .B0(n362), .B1(n361), .Y(n369) );
  ADDFX1 U658 ( .A(n367), .B(n366), .CI(n365), .CO(n373), .S(n368) );
  OR2XL U659 ( .A(n369), .B(n368), .Y(n370) );
  AOI21XL U660 ( .A0(n371), .A1(n370), .B0(n37), .Y(n375) );
  NAND2XL U661 ( .A(n373), .B(n372), .Y(n374) );
  OAI21XL U662 ( .A0(n376), .A1(n375), .B0(n374), .Y(n379) );
  AOI21XL U663 ( .A0(n380), .A1(n379), .B0(n31), .Y(n387) );
  AOI21XL U664 ( .A0(n385), .A1(n43), .B0(n7), .Y(n386) );
  OAI21XL U665 ( .A0(n388), .A1(n387), .B0(n386), .Y(n417) );
  ADDFX1 U666 ( .A(n394), .B(n393), .CI(n392), .CO(n287), .S(n403) );
  ADDFX1 U667 ( .A(n397), .B(n396), .CI(n395), .CO(n402), .S(n389) );
  ADDFX1 U668 ( .A(n400), .B(n399), .CI(n398), .CO(n404), .S(n401) );
  NOR2XL U669 ( .A(n41), .B(n409), .Y(n408) );
  ADDFX1 U670 ( .A(n403), .B(n402), .CI(n401), .CO(n411), .S(n409) );
  NOR2XL U671 ( .A(n411), .B(n410), .Y(n413) );
  NOR2XL U672 ( .A(n408), .B(n413), .Y(n416) );
  NAND2XL U673 ( .A(n41), .B(n409), .Y(n414) );
  NAND2XL U674 ( .A(n411), .B(n410), .Y(n412) );
  OAI21XL U675 ( .A0(n414), .A1(n413), .B0(n412), .Y(n415) );
  AOI21XL U676 ( .A0(n417), .A1(n416), .B0(n415), .Y(n424) );
  NAND2XL U677 ( .A(n30), .B(n418), .Y(n422) );
  NOR2XL U678 ( .A(n44), .B(n419), .Y(n421) );
  AND2XL U679 ( .A(n44), .B(n419), .Y(n420) );
  OAI21XL U680 ( .A0(n425), .A1(n424), .B0(n423), .Y(n432) );
  NAND2XL U681 ( .A(n29), .B(n426), .Y(n430) );
  NAND2XL U682 ( .A(n39), .B(n427), .Y(n428) );
  OAI21XL U683 ( .A0(n430), .A1(n429), .B0(n428), .Y(n431) );
  AOI21XL U684 ( .A0(n433), .A1(n432), .B0(n431), .Y(n437) );
  NAND2XL U685 ( .A(n435), .B(n434), .Y(n436) );
  OAI21XL U686 ( .A0(n438), .A1(n437), .B0(n436), .Y(n448) );
  INVXL U687 ( .A(n447), .Y(n441) );
  NAND2XL U688 ( .A(n35), .B(n442), .Y(n453) );
  OAI21XL U689 ( .A0(n451), .A1(n454), .B0(n453), .Y(n460) );
  AND2XL U690 ( .A(n444), .B(n443), .Y(n457) );
  INVXL U691 ( .A(n451), .Y(n452) );
  NAND2XL U692 ( .A(n453), .B(n452), .Y(n455) );
  INVXL U693 ( .A(n457), .Y(n459) );
  ADDFX1 U694 ( .A(n475), .B(n474), .CI(n473), .CO(n547), .S(n552) );
  ADDFX1 U695 ( .A(n480), .B(n479), .CI(n478), .CO(n500), .S(n548) );
  ADDFX1 U696 ( .A(n483), .B(n482), .CI(n481), .CO(n492), .S(n489) );
  ADDFX1 U697 ( .A(n489), .B(n488), .CI(n487), .CO(n561), .S(n551) );
  ADDFX1 U698 ( .A(n492), .B(n491), .CI(n490), .CO(n499), .S(n560) );
  ADDFX1 U699 ( .A(n501), .B(n500), .CI(n499), .CO(n526), .S(n554) );
  ADDFX1 U700 ( .A(n511), .B(n510), .CI(n509), .CO(n543), .S(n559) );
  ADDFX1 U701 ( .A(n514), .B(n513), .CI(n512), .CO(n537), .S(n542) );
  ADDFX1 U702 ( .A(n517), .B(n516), .CI(n515), .CO(n536), .S(n541) );
  ADDFX1 U703 ( .A(n521), .B(n520), .CI(n519), .CO(n627), .S(n535) );
  ADDFX1 U704 ( .A(n526), .B(n525), .CI(n524), .CO(n649), .S(n556) );
  ADDFX1 U705 ( .A(n529), .B(n528), .CI(n527), .CO(n619), .S(n525) );
  ADDFX1 U706 ( .A(n532), .B(n531), .CI(n530), .CO(n622), .S(n527) );
  ADDFX1 U707 ( .A(n537), .B(n536), .CI(n535), .CO(n617), .S(n558) );
  ADDFX1 U708 ( .A(n543), .B(n542), .CI(n541), .CO(n524), .S(n570) );
  ADDFX1 U709 ( .A(n546), .B(n545), .CI(n544), .CO(n567), .S(n563) );
  ADDFX1 U710 ( .A(n549), .B(n548), .CI(n547), .CO(n555), .S(n566) );
  ADDFX1 U711 ( .A(n552), .B(n551), .CI(n550), .CO(n565), .S(n573) );
  ADDFX1 U712 ( .A(n555), .B(n554), .CI(n553), .CO(n557), .S(n568) );
  ADDFX1 U713 ( .A(n558), .B(n557), .CI(n556), .CO(n539), .S(n585) );
  ADDFX1 U714 ( .A(n561), .B(n560), .CI(n559), .CO(n553), .S(n576) );
  ADDFX1 U715 ( .A(n564), .B(n563), .CI(n562), .CO(n575), .S(n571) );
  ADDFX1 U716 ( .A(n567), .B(n566), .CI(n565), .CO(n569), .S(n574) );
  ADDFX1 U717 ( .A(n570), .B(n569), .CI(n568), .CO(n586), .S(n583) );
  ADDFX1 U718 ( .A(n573), .B(n572), .CI(n571), .CO(n581), .S(n126) );
  ADDFX1 U719 ( .A(n576), .B(n575), .CI(n574), .CO(n584), .S(n580) );
  OAI21XL U720 ( .A0(n579), .A1(n578), .B0(n577), .Y(n591) );
  AOI21XL U721 ( .A0(n589), .A1(n591), .B0(n582), .Y(n596) );
  OAI21XL U722 ( .A0(n593), .A1(n596), .B0(n595), .Y(n600) );
  INVXL U723 ( .A(n889), .Y(n675) );
  INVXL U724 ( .A(n879), .Y(n674) );
  OA22X1 U725 ( .A0(n851), .A1(n675), .B0(n674), .B1(n854), .Y(n604) );
  ADDFX1 U726 ( .A(n616), .B(n615), .CI(n614), .CO(n629), .S(n626) );
  ADDFX1 U727 ( .A(n619), .B(n618), .CI(n617), .CO(n652), .S(n648) );
  ADDFX1 U728 ( .A(n622), .B(n621), .CI(n620), .CO(n644), .S(n618) );
  ADDFX1 U729 ( .A(n628), .B(n627), .CI(n626), .CO(n642), .S(n650) );
  ADDFX1 U730 ( .A(n631), .B(n630), .CI(n629), .CO(n756), .S(n653) );
  ADDFX1 U731 ( .A(n634), .B(n633), .CI(n632), .CO(n750), .S(n643) );
  MXI2XL U732 ( .A(n708), .B(n709), .S0(dividend[9]), .Y(n732) );
  ADDFX1 U733 ( .A(n639), .B(n638), .CI(n637), .CO(n738), .S(n630) );
  ADDFX1 U734 ( .A(n644), .B(n643), .CI(n642), .CO(n754), .S(n651) );
  ADDFX1 U735 ( .A(n650), .B(n649), .CI(n648), .CO(n658), .S(n538) );
  ADDFX1 U736 ( .A(n653), .B(n652), .CI(n651), .CO(n646), .S(n657) );
  OA22X1 U737 ( .A0(n854), .A1(n675), .B0(n674), .B1(n856), .Y(n677) );
  MXI2XL U738 ( .A(n779), .B(n16), .S0(n14), .Y(n782) );
  INVXL U739 ( .A(n782), .Y(n785) );
  INVXL U740 ( .A(div_inverse_15_), .Y(n681) );
  ADDFX1 U741 ( .A(n686), .B(n685), .CI(n684), .CO(n783), .S(n691) );
  ADDFX1 U742 ( .A(n692), .B(n691), .CI(n690), .CO(n775), .S(n774) );
  ADDFX1 U743 ( .A(n700), .B(n696), .CI(n695), .CO(n697), .S(n704) );
  ADDFX1 U744 ( .A(n699), .B(n698), .CI(n697), .CO(n690), .S(n721) );
  ADDFX1 U745 ( .A(n706), .B(n705), .CI(n704), .CO(n722), .S(n725) );
  ADDFX1 U746 ( .A(n723), .B(n722), .CI(n721), .CO(n773), .S(n769) );
  ADDFX1 U747 ( .A(n726), .B(n725), .CI(n724), .CO(n770), .S(n768) );
  ADDFX1 U748 ( .A(n729), .B(n728), .CI(n727), .CO(n726), .S(n744) );
  ADDFX1 U749 ( .A(n732), .B(n731), .CI(n730), .CO(n741), .S(n753) );
  ADDFX1 U750 ( .A(n735), .B(n734), .CI(n733), .CO(n752), .S(n749) );
  ADDFX1 U751 ( .A(n738), .B(n737), .CI(n736), .CO(n751), .S(n748) );
  ADDFX1 U752 ( .A(n741), .B(n740), .CI(n739), .CO(n724), .S(n742) );
  ADDFX1 U753 ( .A(n744), .B(n743), .CI(n742), .CO(n767), .S(n766) );
  ADDFX1 U754 ( .A(n747), .B(n746), .CI(n745), .CO(n739), .S(n759) );
  ADDFX1 U755 ( .A(n750), .B(n749), .CI(n748), .CO(n758), .S(n755) );
  ADDFX1 U756 ( .A(n753), .B(n752), .CI(n751), .CO(n743), .S(n757) );
  ADDFX1 U757 ( .A(n756), .B(n755), .CI(n754), .CO(n764), .S(n645) );
  ADDFX1 U758 ( .A(n759), .B(n758), .CI(n757), .CO(n765), .S(n763) );
  INVXL U759 ( .A(n798), .Y(n777) );
  AO21XL U760 ( .A0(n16), .A1(n779), .B0(n778), .Y(n781) );
  XOR3XL U761 ( .A(n14), .B(n782), .C(n781), .Y(n787) );
  ADDFX1 U762 ( .A(n785), .B(n784), .CI(n783), .CO(n786), .S(n776) );
  INVXL U763 ( .A(n849), .Y(n881) );
  AOI21XL U764 ( .A0(n889), .A1(n881), .B0(n863), .Y(n804) );
  INVXL U765 ( .A(n885), .Y(n814) );
  NAND2XL U766 ( .A(div_shift_0_), .B(n814), .Y(n803) );
  NOR2XL U767 ( .A(div_shift_2_), .B(n842), .Y(quotient[14]) );
  INVXL U768 ( .A(n841), .Y(n878) );
  AOI22XL U769 ( .A0(n889), .A1(n878), .B0(n879), .B1(n881), .Y(n816) );
  NAND2XL U770 ( .A(n882), .B(n814), .Y(n815) );
  NOR2XL U771 ( .A(div_shift_2_), .B(n837), .Y(quotient[13]) );
  AOI21XL U772 ( .A0(n832), .A1(n831), .B0(n830), .Y(n833) );
  MXI2XL U773 ( .A(n872), .B(n837), .S0(div_shift_2_), .Y(quotient[9]) );
  MXI2XL U774 ( .A(n874), .B(n842), .S0(div_shift_2_), .Y(quotient[10]) );
  NOR2XL U775 ( .A(div_shift_0_), .B(n885), .Y(n843) );
  OAI21XL U776 ( .A0(n450), .A1(n888), .B0(n845), .Y(n850) );
  NOR2XL U777 ( .A(div_shift_2_), .B(n850), .Y(quotient[15]) );
  MXI2XL U778 ( .A(n876), .B(n850), .S0(div_shift_2_), .Y(quotient[11]) );
  MXI2XL U779 ( .A(n864), .B(n877), .S0(div_shift_2_), .Y(quotient[3]) );
  MXI2XL U780 ( .A(n871), .B(n887), .S0(div_shift_2_), .Y(quotient[4]) );
  MXI2XL U781 ( .A(n873), .B(n872), .S0(div_shift_2_), .Y(quotient[5]) );
  MXI2XL U782 ( .A(n875), .B(n874), .S0(div_shift_2_), .Y(quotient[6]) );
  AOI22XL U783 ( .A0(n889), .A1(n880), .B0(n879), .B1(n878), .Y(n884) );
  NAND2XL U784 ( .A(n882), .B(n881), .Y(n883) );
  NAND3XL U785 ( .A(div_shift_2_), .B(n889), .C(n888), .Y(n890) );
  OAI21XL U786 ( .A0(div_shift_2_), .A1(n891), .B0(n890), .Y(quotient[12]) );
  BUFX2 U3 ( .A(div_inverse_12_), .Y(n892) );
  XNOR2XL U4 ( .A(dividend[1]), .B(n6), .Y(n353) );
  XNOR2XL U5 ( .A(dividend[3]), .B(div_inverse_1_), .Y(n342) );
  XNOR2XL U6 ( .A(dividend[5]), .B(n6), .Y(n305) );
  XNOR2XL U8 ( .A(dividend[7]), .B(n6), .Y(n317) );
  XNOR2XL U12 ( .A(dividend[9]), .B(n6), .Y(n244) );
  XNOR2XL U13 ( .A(n405), .B(n404), .Y(n407) );
  XNOR2XL U14 ( .A(n321), .B(n389), .Y(n383) );
  XNOR2XL U18 ( .A(dividend[1]), .B(div_inverse_10_), .Y(n232) );
  XNOR2XL U19 ( .A(n407), .B(n406), .Y(n410) );
  XNOR2XL U20 ( .A(dividend[3]), .B(div_inverse_12_), .Y(n71) );
  XNOR2XL U21 ( .A(dividend[11]), .B(n6), .Y(n194) );
  XNOR2XL U22 ( .A(dividend[9]), .B(div_inverse_5_), .Y(n189) );
  XNOR2XL U32 ( .A(dividend[3]), .B(div_inverse_13_), .Y(n69) );
  XNOR2XL U35 ( .A(dividend[11]), .B(n507), .Y(n79) );
  XNOR2XL U51 ( .A(dividend[11]), .B(div_inverse_7_), .Y(n80) );
  XNOR2XL U59 ( .A(n261), .B(n262), .Y(n258) );
  XNOR2XL U62 ( .A(dividend[15]), .B(div_inverse_3_), .Y(n75) );
  XNOR2XL U74 ( .A(dividend[7]), .B(div_inverse_13_), .Y(n498) );
  XNOR2XL U82 ( .A(dividend[11]), .B(n4), .Y(n468) );
  XNOR2XL U84 ( .A(dividend[11]), .B(div_inverse_11_), .Y(n477) );
  XNOR2XL U88 ( .A(dividend[6]), .B(dividend[5]), .Y(n612) );
  XNOR2XL U93 ( .A(dividend[7]), .B(dividend[8]), .Y(n709) );
  XNOR2XL U95 ( .A(n258), .B(n259), .Y(n426) );
  XNOR2XL U97 ( .A(dividend[13]), .B(div_inverse_10_), .Y(n518) );
  XNOR2XL U144 ( .A(dividend[15]), .B(div_inverse_10_), .Y(n641) );
  XNOR2XL U172 ( .A(dividend[15]), .B(n892), .Y(n715) );
  XNOR2XL U215 ( .A(n202), .B(n201), .Y(n204) );
  XNOR2XL U232 ( .A(dividend[15]), .B(div_inverse_14_), .Y(n694) );
  XNOR2XL U234 ( .A(dividend[12]), .B(n8), .Y(n718) );
  XNOR2XL U252 ( .A(n825), .B(n831), .Y(n862) );
  OAI211XL U295 ( .A0(n886), .A1(n673), .B0(n672), .C0(n671), .Y(n680) );
  OAI211XL U439 ( .A0(n858), .A1(n678), .B0(n677), .C0(n676), .Y(n873) );
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

