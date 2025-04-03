`ifndef __risc_scoreboard__
 `define __risc_scoreboard__

`include "risc_inst_seq_item.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM 

class risc_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(risc_scoreboard)
  
  uvm_analysis_imp#(risc_inst_seq_item, risc_scoreboard) seq_imp;
  
  int pass_count = 0; // Track passed tests
  int fail_count = 0; // Track failed tests
  int total_tests = 0;

  risc_inst_seq_item queue[$]; // Queue for Expected Results

  function new(string name = "risc_scoreboard", uvm_component parent);
    super.new(name, parent);
    seq_imp = new("seq_imp", this);
  endfunction

  function void write_seq(risc_inst_seq_item txn);
    `uvm_info("risc_scoreboard", "in write_seq", UVM_MEDIUM);
    queue.push_back(txn);
  endfunction

  
  // Implement `write()` method required by `uvm_analysis_imp`
  function void write(risc_inst_seq_item txn);
    `uvm_info("risc_scoreboard", "in write..", UVM_MEDIUM);
    queue.push_back(txn);
  endfunction
  
  
  virtual task run_phase(uvm_phase phase);
    risc_inst_seq_item seq_item;
 
    
    forever begin
	   #10;
      if (queue.size() > 0 ) begin
        `uvm_info("risc_scoreboard", "in forever queue.size() > 0", UVM_MEDIUM)

        seq_item = queue.pop_front();
        total_tests++;
        
        if (seq_item.isExecutedCorrectly()) begin
          pass_count++;
        end
        else begin
          fail_count++;
        end
        `uvm_info("risc_scoreboard", $sformatf("Total Tests Run: %0d", total_tests), UVM_MEDIUM)
        `uvm_info("risc_scoreboard", $sformatf("Tests Passed: %0d", pass_count), UVM_MEDIUM)
        `uvm_info("risc_scoreboard", $sformatf("Tests Failed: %0d", fail_count), UVM_MEDIUM)

      end 
    end
    
  endtask
  
  function void print_results();
    `uvm_info("risc_scoreboard", $sformatf("Total Tests Run: %0d", total_tests), UVM_MEDIUM)
    `uvm_info("risc_scoreboard", $sformatf("Tests Passed: %0d", pass_count), UVM_MEDIUM)
    `uvm_info("risc_scoreboard", $sformatf("Tests Failed: %0d", fail_count), UVM_MEDIUM)

    if (fail_count == 0)
      `uvm_info("risc_scoreboard", " ALL TESTS PASSED ", UVM_NONE)
    else
      `uvm_info("risc_scoreboard", " SOME TESTS FAILED ", UVM_NONE)
  endfunction

endclass

`endif