`ifndef __risc_r_instruction__
    `define __risc_r_instruction__

`include "risc_instruction_constants.sv"
`include "risc_instruction.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM 

class risc_r_instruction extends risc_instruction;
  
    `uvm_object_utils(risc_r_instruction)

  
  
  constraint inst_type_R {inst[6:0] == 7'b0110011;}

  
  constraint inst_r_alu_codes {
  {inst[14:12], inst[31:25]} inside {
    {`RISC_R_FUNC_3_ADD,         `RISC_R_FUNC_7_ADD},
    {`RISC_R_FUNC_3_SUBTRACT,    `RISC_R_FUNC_7_SUBTRACT},
    {`RISC_R_FUNC_3_XOR,         `RISC_R_FUNC_7_XOR},
    {`RISC_R_FUNC_3_OR,          `RISC_R_FUNC_7_OR},
    {`RISC_R_FUNC_3_AND,         `RISC_R_FUNC_7_AND},  
    {`RISC_R_FUNC_3_SHIFT_RT_AR, `RISC_R_FUNC_7_SHIFT_RT_AR},  
    {`RISC_R_FUNC_3_SHIFT_LT_LOG, `RISC_R_FUNC_7_SHIFT_LT_LOG} };
  }
  
                 
  function new(string name = "risc_r_instruction_generator");
    super.new(name);
  endfunction
  
  

  
  virtual function void do_print(uvm_printer printer);     
    `uvm_info(
      "risc_r_instruction", 
      $sformatf("inst[6:0]=%b, rs1= %0d, 	rs2= %0d, 	 rsd = %0d,  func3 = %0d, funct7= %0d",
                inst[6:0],    inst[19:15],  inst[24:20], inst[11:7], inst[14:12], inst[31:25]), 
      UVM_MEDIUM);
  endfunction
  
  

endclass

`endif