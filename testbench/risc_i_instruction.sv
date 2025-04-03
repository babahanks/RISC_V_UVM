`ifndef __risc_i_instruction__
    `define __risc_i_instruction__

`include "risc_instruction_constants.sv"
`include "risc_instruction.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM 

class risc_i_instruction extends risc_instruction;
  `uvm_object_utils(risc_i_instruction)


  
  constraint inst_type_I {inst[6:0] == 7'b0010011;}
  

  
  /*
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
 */
  
  function new(string name = "risc_i_instruction");
    super.new(name);
  endfunction
  
  
  virtual function void do_print(uvm_printer printer);
    //super.do_print(printer); 
    `uvm_info("RISC_I_INST_SEQ_ITEM", 
              $sformatf("inst[6:0]=%b, inst[14:12]=%b, inst[31:25]=%b",
                        inst[6:0],    inst[14:12],    inst[31:25]), 
              UVM_MEDIUM);

  endfunction
  
endclass

`endif
