`ifndef __risc_inst_seq_test__
    `define __risc_inst_seq_test__

`include "risc_test_constants.sv"
`include "risc_instruction.sv"
`include "risc_r_instruction.sv"
`include "risc_i_instruction.sv"
`include "risc_b_instruction.sv"

`include "risc_inst_seq_item.sv"
`include "risc_inst_sequence.sv"
`include "risc_test_env.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM 


class risc_test extends uvm_test;
  `uvm_component_utils(risc_test)

  risc_test_env env;
  risc_inst_sequence seq;
  
  rand logic[31:0] reg_value;
  

  //uvm_sequencer#(risc_inst_seq_item) sequencer;
  

  function new(string name = "risc_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    `uvm_info("risc_inst_seq_test", "build_phase", UVM_MEDIUM);

    env = risc_test_env::type_id::create("env", this);
    setInstructionsInMemory();
    setRandomValuesInRegister();
  endfunction

  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this); // ✅ Prevent test from ending immediately
    
    `uvm_info("risc_test", "run_phase sequence", UVM_MEDIUM);
     
    seq = risc_inst_sequence::type_id::create("seq");
    if (seq == null) begin
      `uvm_fatal("risc_test", "Sequence creation failed")
    end
    
    if (env.agent.sequencer == null) begin
      `uvm_fatal("risc_test", "Sequencer is NULL in test!")
    end
    
    //seq.print();
    seq.start(env.agent.sequencer);// ✅ Start sequence on sequencer
    
    #100; // Some wait time
    phase.drop_objection(this); // ✅ Allow test to finish
  endtask
  
  
 
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    `uvm_info("risc_test", "Finalizing risc test...", UVM_MEDIUM);
    env.scoreboard.print_results(); // ✅ Print test report
  endfunction

  
  
  function void setInstructionsInMemory();
    risc_instruction inst;
    risc_r_instruction r_inst;
    risc_i_instruction i_inst;
    string hdl_path;
    int status;
    int random_instruction;
    
    //int start_address = `MEMORY_CODE_START_ADDR;
    //int end_address = `MEMORY_CODE_END_ADDR;
    
    int start_address = 0;
    int end_address = 10;

    risc_b_instruction::min_index = start_address;
    risc_b_instruction::max_index = end_address;
    
    
    for (int i=start_address; i<= end_address; i++) begin
      random_instruction = $urandom_range(0,1);
      `uvm_info("risc_test", $sformatf("random_instruction: %0d", random_instruction), UVM_MEDIUM);               
    
      //inst = risc_r_instruction::type_id::create("risc_r_instruction");
      //inst = risc_b_instruction::type_id::create("risc_b_instruction");
      
      case (random_instruction)
        0: inst = risc_r_instruction::type_id::create("risc_r_instruction");
        1: inst = risc_b_instruction::type_id::create("risc_b_instruction");   
      endcase
      
      
      inst.setParameters(i);      
      if (!inst.randomize())
        `uvm_error("risc_test", "Randomization failed!")
        
      inst.build_inst();
      inst.print();
      
      
      //`uvm_info("risc_test_driver",  $sformatf("instruction = %b", inst.), UVM_MEDIUM); 
      
      hdl_path = $sformatf("risc_test_top.circuit.mem.memory[%0d]", i);

      
      status = uvm_hdl_deposit(hdl_path, inst.inst);
      if (status) begin
        `uvm_info("risc_test", $sformatf("data written to risc_test_top.circuit.mem.memory[%0d] = %b", i, inst.inst), UVM_MEDIUM);            
      end 
      else begin
        `uvm_error("risc_test", $sformatf("Failed to write data to risc_test_top.circuit.mem.memory[%0d]", i));
      end          
    end
    
  endfunction
  
  
  
  
  function void setRandomValuesInRegister();
    
    int num_of_registers = 32;
	int status;
    string hdl_path;
    logic[31:0] read_value;
       
    for (int i=0; i< num_of_registers; i++) begin      
      reg_value = $urandom();
      `uvm_info("risc_test", $sformatf("reg_value=%b", reg_value), UVM_MEDIUM); 

      hdl_path = $sformatf("risc_test_top.circuit.risc_chip.regfile_.registers[%0d]", i);
      `uvm_info("risc_test", hdl_path, UVM_MEDIUM); 

      status = uvm_hdl_deposit(hdl_path, reg_value);
      
      if (status==0) begin
        `uvm_error("risc_test", "Failed to load register");
      end
      
      status = uvm_hdl_read(hdl_path, read_value);
      if (status==0) begin
        `uvm_error("risc_test", "Failed to read register");
      end
      else begin
        if (reg_value != read_value) begin
          `uvm_error("risc_test", "registers: read value does not match the loaded value");         
        end
      end      
    end    
  endfunction

  
endclass

`endif