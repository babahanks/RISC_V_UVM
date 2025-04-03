`ifndef __RISC_INST_CONSTANTS__
    `define __RISC_INST_CONSTANTS__


`define  RISC_R_INSTRUCTION      7'b0110011
`define  RISC_I_INSTRUCTION      7'b0010011
`define  RISC_B_INSTRUCTION      7'b1100011

`define  RISC_R_FUNC_3_ADD       3'b000
`define  RISC_R_FUNC_3_SUBTRACT  3'b000
`define  RISC_R_FUNC_3_XOR       3'b100
`define  RISC_R_FUNC_3_OR        3'b110
`define  RISC_R_FUNC_3_AND       3'b111
`define  RISC_R_FUNC_3_SHIFT_LT_LOG    3'b001
`define  RISC_R_FUNC_3_SHIFT_RT_LOG    3'b101
`define  RISC_R_FUNC_3_SHIFT_RT_AR     3'b101
`define  RISC_R_FUNC_3_SET_LESS_THAN   3'b010
`define  RISC_R_FUNC_3_SET_LESS_THAN_U 3'b011

`define  RISC_R_FUNC_7_ADD       7'b0000000
`define  RISC_R_FUNC_7_SUBTRACT  7'b0100000
`define  RISC_R_FUNC_7_XOR       7'b0000000
`define  RISC_R_FUNC_7_OR        7'b0000000
`define  RISC_R_FUNC_7_AND       7'b0000000
`define  RISC_R_FUNC_7_SHIFT_LT_LOG    7'b0000000
`define  RISC_R_FUNC_7_SHIFT_RT_LOG    7'b0000000
`define  RISC_R_FUNC_7_SHIFT_RT_AR     7'b0100000
`define  RISC_R_FUNC_7_SET_LESS_THAN   7'b0000000
`define  RISC_R_FUNC_7_SET_LESS_THAN_U 7'b0000000


`define  RISC_I_FUNC_3_ADD       3'b000
`define  RISC_I_FUNC_3_XOR       3'b100
`define  RISC_I_FUNC_3_OR        3'b110
`define  RISC_I_FUNC_3_AND       3'b111
`define  RISC_I_FUNC_3_SHIFT_LT_LOG    3'b001
`define  RISC_I_FUNC_3_SHIFT_RT_LOG    3'b101
`define  RISC_I_FUNC_3_SHIFT_RT_AR     3'b101
`define  RISC_I_FUNC_3_SET_LESS_THAN   3'b010
`define  RISC_I_FUNC_3_SET_LESS_THAN_U 3'b011


`define  RISC_B_FUNCT_3_EQUAL			3'b000
`define  RISC_B_FUNCT_3_NOT_EQUAL		3'b001
`define  RISC_B_FUNCT_3_LESS_THAN		3'b100
`define  RISC_B_FUNCT_3_GREATER_OR_EQ	3'b101
`define  RISC_B_FUNCT_3_U_LESS_THAN	    3'b110
`define  RISC_B_FUNCT_3_U_GREATER_OR_EQ	3'b111

  

`endif