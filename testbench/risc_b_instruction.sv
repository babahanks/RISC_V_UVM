`ifndef __risc_b_inst__
    `define __risc_b_instruction__

`include "risc_instruction_constants.sv"
`include "risc_instruction.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM 


typedef enum logic [2:0] {  
  Equal         = `RISC_B_FUNCT_3_EQUAL,
  NotEqual      = `RISC_B_FUNCT_3_NOT_EQUAL,
  LessThan      = `RISC_B_FUNCT_3_LESS_THAN,
  GreaterOrEq   = `RISC_B_FUNCT_3_GREATER_OR_EQ,
  U_LessThan    = `RISC_B_FUNCT_3_U_LESS_THAN,
  U_GreaterOrEq	= `RISC_B_FUNCT_3_U_GREATER_OR_EQ
} 
B_INST_JUMP_TEST;



class risc_b_instruction extends risc_instruction;
  `uvm_object_utils(risc_b_instruction)
  
  rand logic signed [12:1]  jump_offset; // => immediate
  logic[4:0]  rs1;
  logic[4:0]  rs2;
  logic[2:0]  func3;
  
  
  static int min_index;
  static int max_index;
  int max_forward_jump;
  int max_backward_jump;
  B_INST_JUMP_TEST jump_test;
  
    
  constraint inst_type_B {inst[6:0] == 7'b1100011;}
  
  constraint jump_constraint 
  {
    jump_offset >= min_index - current_index ; 
    jump_offset <= max_index - current_index; 
    
    //jump_offset % 2 == 0; // B-type immediate is always even (word aligned) ??
  }
  
  
  constraint jump_code 
  {inst[14:12] inside 
   {  `RISC_B_FUNCT_3_EQUAL,
      `RISC_B_FUNCT_3_NOT_EQUAL,
      `RISC_B_FUNCT_3_LESS_THAN,
      `RISC_B_FUNCT_3_GREATER_OR_EQ,
      `RISC_B_FUNCT_3_U_LESS_THAN,
      `RISC_B_FUNCT_3_U_GREATER_OR_EQ
   };	                        
  }
  
  function new(string name = "risc_b_instruction_generator");
    super.new(name);
  endfunction
  

  
  function void set_parameters(int current_index);
    max_forward_jump = max_index - current_index;
    max_backward_jump = current_index - min_index;    
  endfunction
  
  function void build_inst(); 
    
    `uvm_info("risc_b_instruction",$sformatf("inst: %b", inst), UVM_MEDIUM);
    `uvm_info("risc_b_instruction",$sformatf("jump_offset: %b", jump_offset), UVM_MEDIUM);


    rs1 = inst[19:15];
    rs2 = inst[24:20];
    func3 = inst[14:12];
    
    inst = {
      jump_offset[12],       // 1 bit - inst[31]
      jump_offset[10:5],     // 6 bits - inst[30:25]
      rs2,                   // 5 bits - inst[24:20]
      rs1,                   // 5 bits - inst[19:15]
      func3,                 // 3 bits - inst[14:12]
      jump_offset[4:1],      // 4 bits - inst[11:8]
      jump_offset[11],       // 1 bit - inst[7]
      7'b1100011             // opcode - inst[6:0]
    };  
    
    
    `uvm_info("risc_b_instruction",$sformatf("%b,  %b,  %b, %b,  %b, %b, %b, %b, %b", 
                                             jump_offset[12], jump_offset[10:5], rs2, rs1, func3, jump_offset[4:1], jump_offset[11], func3, inst[6:0]), 
              UVM_MEDIUM);
    
  endfunction
  
  
  function void do_print(uvm_printer printer);
    `uvm_info("risc_b_instruction", 
              $sformatf("inst[6:0]=%b, rs1= %b, rs2= %b, jump_code= %b, min_index = %0d, max_index = %0d, current_index = %0d,  jump_offset= %0d, jump_offset= %b", 
                        inst[6:0],    rs1,      rs2,      func3, min_index, max_index,  current_index,        jump_offset, jump_offset), 
              UVM_MEDIUM);

  endfunction
  
endclass

`endif