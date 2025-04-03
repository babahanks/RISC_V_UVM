`ifndef __risc_inst_env__
 `define __risc_inst_env__

`include "risc_test_driver.sv"
`include "risc_test_agent.sv"
`include "risc_scoreboard.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM 


class risc_test_env extends uvm_agent;
  `uvm_component_utils(risc_test_env)

  risc_test_agent agent;
  risc_scoreboard scoreboard;
  
  function new(string name, uvm_component parent);
	super.new (name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    agent = risc_test_agent::type_id::create("agent", this);
    scoreboard = risc_scoreboard::type_id::create("scoreboard", this);  
  endfunction 
  
  
  function void connect_phase(uvm_phase phase);

    //  Connect port_to_scoreboard in risc_test_driver to seq_imp in scoreboard
    agent.driver.port_to_scoreboard.connect(scoreboard.seq_imp); 
    
      //agent.driver.scoreboard_item_rsp_port.connect(scoreboard.item_rsp_imp);  //  Connect rsp Results
    
      //agent.monitor.scoreboard_item_rsp_port.connect(scoreboard.item_rsp_imp);  //  Connect rsp Results
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #50;
    phase.drop_objection(this);
    //scoreboard.print_results();
  endtask
  
  
endclass
`endif