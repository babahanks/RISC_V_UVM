`ifndef __RISC_INST_DRIVER__
    `define __RISC_INST_DRIVER__
`include "risc_instruction_constants.sv"
`include "risc_test_constants.sv"
`include "risc_inst_seq_item.sv"
`include "risc_r_inst_seq_item.sv"
`include "risc_b_inst_seq_item.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM 

class risc_inst_sequence extends uvm_sequence#(risc_inst_seq_item);
  `uvm_object_utils(risc_inst_sequence)
  
  function new(string name = "risc_inst_sequence");
    super.new(name);
  endfunction
  
  
  virtual task pre_start();
    if (m_sequencer == null) begin
      `uvm_fatal("risc_inst_sequence", "m_sequencer is NULL before start!")
    end
    super.pre_start();
  endtask


  task body();
    risc_inst_seq_item txn;
    logic[31:0] instruction;
    string hdl_path;
    int status;
        
    //int start_address = `MEMORY_CODE_START_ADDR;
    //int end_address = `MEMORY_CODE_END_ADDR;
    
    int start_address = 0;
    int end_address = 10;
    int index = 0;


    `uvm_info("risc_inst_sequence", "Starting sequence", UVM_MEDIUM);
    

    while(index <= end_address) begin
      
      hdl_path = $sformatf("risc_test_top.circuit.mem.memory[%0d]", index);
      
      status = uvm_hdl_read(hdl_path, instruction);
      
      if (status) begin
        `uvm_info("risc_inst_sequence", $sformatf("data read from risc_test_top.circuit.mem.memory[%0d] = %b", index, instruction), UVM_MEDIUM);
      end 
      else begin
        `uvm_error("risc_inst_sequence", $sformatf("Failed to read data from risc_test_top.circuit.mem.memory[%0d]", index));
      end 
    
      
      if (status) begin 
        
        case (instruction[6:0]) 
          `RISC_R_INSTRUCTION: txn = risc_r_inst_seq_item::type_id::create("risc_r_inst_seq_item");
          `RISC_B_INSTRUCTION: txn = risc_b_inst_seq_item::type_id::create("risc_b_inst_seq_item");
        endcase


        txn.setParameters(instruction, index);        
        txn.setItUp();
        index = txn.nextPC();
        start_item(txn);
        finish_item(txn);
      end      
    end
  endtask    
    
  
endclass

`endif