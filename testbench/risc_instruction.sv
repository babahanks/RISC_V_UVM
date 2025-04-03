`ifndef __risc_instruction__
    `define __risc_instruction__

`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM 

class risc_instruction extends uvm_object;
  `uvm_object_utils(risc_instruction)
  
  rand logic[31:0]  inst;
  int current_index;

  function new(string name = "risc_instruction_generator");
    super.new(name);
  endfunction
  
  virtual function void setParameters(int index);
    this.current_index = index;
  endfunction
  
  virtual function void build_inst();
  endfunction
  
  virtual function void do_print(uvm_printer printer);
    super.do_print(printer); // Call parent do_print()
  endfunction
  
  
endclass

`endif
