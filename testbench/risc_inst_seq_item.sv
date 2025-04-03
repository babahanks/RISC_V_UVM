`ifndef __RISC_INST_SEQ_ITEM__
    `define __RISC_INST_SEQ_ITEM__

`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM 

class risc_inst_seq_item extends uvm_sequence_item;
  `uvm_object_utils(risc_inst_seq_item)
  
  logic[31:0]  instruction;
  logic[31:0]  current_PC;
  int 		   executedCorrectly;

  function new(string name = "risc_inst_seq_item");
    super.new(name);
  endfunction
  
  virtual function void setParameters(
    logic[31:0]  inst,
    logic[31:0]  current_PC);
    
    this.instruction = inst;
    this.current_PC = current_PC;    
  endfunction
  
  virtual function void setItUp();
  endfunction
  
  virtual function int nextPC();
    return current_PC + 1;
  endfunction
  
  virtual function int getting_next_instruction();
  endfunction
  
  virtual function void checkExecution();
  endfunction

  function int isExecutedCorrectly();
    return executedCorrectly;
  endfunction
  
  virtual function void do_print(uvm_printer printer);
    super.do_print(printer); // Call parent do_print()
  endfunction
  
endclass

`endif
