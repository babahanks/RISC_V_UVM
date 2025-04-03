`ifndef __risc_test_driver__
 `define __risc_test_driver__

`include "risc_inst_seq_item.sv"
`include "risc_r_inst_seq_item.sv"
`include "risc_b_inst_seq_item.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM

class risc_test_driver extends uvm_driver#(risc_inst_seq_item);
  `uvm_component_utils(risc_test_driver)
  
  virtual memory_if memory_if_i;
  uvm_analysis_port#(risc_inst_seq_item) port_to_scoreboard; // ✅ Sends seq_items to the scoreboard

  function new(string name = "risc_inst_driver", uvm_component parent);
    super.new(name, parent);
    port_to_scoreboard = new ("port_to_scoreboard", this);
  endfunction
  
    //uvm_config_db#(virtual risc_v_2_circuit)::set(null, "*", "risc_v_2_circuit", risc_v_2_circuit);

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);    
    if (!uvm_config_db#(virtual memory_if)::get(this, "", "memory_if", memory_if_i))
      begin
        `uvm_fatal("DRIVER", "Failed to get virtual interface memory_if")
      end
  endfunction
  
  
  
  
  task run_phase(uvm_phase phase);
    
    risc_inst_seq_item txn;
    int inst_clks;


    @(negedge memory_if_i.reset)
    `uvm_info("risc_test_driver",  $sformatf("memory_if_i.reset = %b", memory_if_i.reset), UVM_MEDIUM);

    
    forever begin
      seq_item_port.get_next_item(txn);
      `uvm_info("risc_test_driver",  $sformatf("txn.inst = %b", txn.instruction), UVM_MEDIUM);

      
      while (txn.getting_next_instruction() != 1) begin
        @(posedge memory_if_i.clk);        
      end
     
      txn.checkExecution();
      port_to_scoreboard.write(txn);
      seq_item_port.item_done(); // ✅ Ensure transaction completes
    end
  endtask
  
  
  function int get_next_instruction_signal();
    logic get_next_instruction = 0;
    string hdl = "risc_test_top.circuit.risc_chip.rih.get_next_instruction";
    
    uvm_hdl_read(hdl, get_next_instruction);
    `uvm_info("risc_test_driver",  $sformatf("get_next_instruction = %b", get_next_instruction), UVM_MEDIUM);
  endfunction


 

endclass
`endif     