`ifndef __risc_b_inst_seq_item__
  `define __risc_b_inst_seq_item__

`include "ALU.sv"

`include "risc_inst_seq_item.sv"
`include "risc_instruction_constants.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM



class risc_b_inst_seq_item extends risc_inst_seq_item; 
  `uvm_object_utils(risc_b_inst_seq_item)

  
  logic[4:0]   reg_addr_a;
  logic[4:0]   reg_addr_b;
  logic[31:0]  reg_addr_a_data;
  logic[31:0]  reg_addr_b_data;
  logic[2:0]   jump_code;
  logic signed [12:1]  expected_jump_offset;
  logic[31:0]  expected_next_inst_address;
  logic[31:0]  expected_next_inst;
  logic[31:0]  actual_PC;

  
  string register_hdl_path = "risc_test_top.circuit.risc_chip.regfile_.registers[%0d]";
  string memory_hdl_path = "risc_test_top.circuit.mem.memory[%0d]";
  string PC_hdl_path =  "risc_test_top.circuit.risc_chip.rih.PC";
  
  function new (string name = "risc_b_inst_seq_item"); 
    super.new(name);
  endfunction
  
  
  function void setItUp();
    set_input_values();
    setExpectedInstruction();
  endfunction
  
  
  
  
  function void set_input_values();
    int status;
    string formated_hdl_path;
    reg_addr_a = instruction[19:15];
    reg_addr_b = instruction[24:20];
    
    formated_hdl_path =  $sformatf(register_hdl_path, reg_addr_a);
    status = uvm_hdl_read(formated_hdl_path, reg_addr_a_data);
    if (status) begin
      `uvm_info("risc_b_inst_seq_item", $sformatf("reg_addr_a_data = %b", reg_addr_a_data), UVM_MEDIUM);            
    end
    else begin
      `uvm_error("risc_b_inst_seq_item", $sformatf("Failed to get reg_addr_a_data at reg_addr[%b]", reg_addr_a));
    end
    
    formated_hdl_path =  $sformatf(register_hdl_path, reg_addr_b);
    status = uvm_hdl_read(formated_hdl_path, reg_addr_b_data);
    if (status) begin
      `uvm_info("risc_b_inst_seq_item", $sformatf("reg_addr_b_data = %b", reg_addr_b_data), UVM_MEDIUM);            
    end
    else begin
      `uvm_error("risc_b_inst_seq_item", "Failed to get reg_addr_b_data");
    end    
  endfunction
  
  
  
  

  function void setExpectedInstruction();
    int status;   
    string formated_hdl_path;
    
    
    int jump = 0;    
    expected_jump_offset = 11'b1;

    
    case (instruction[14:12])
      `RISC_B_FUNCT_3_EQUAL:            jump = (reg_addr_a_data == reg_addr_b_data);
      `RISC_B_FUNCT_3_NOT_EQUAL:        jump = (reg_addr_a_data != reg_addr_b_data);		
      `RISC_B_FUNCT_3_LESS_THAN:        jump = ($signed(reg_addr_a_data) <  $signed(reg_addr_b_data));		
      `RISC_B_FUNCT_3_GREATER_OR_EQ:    jump = (reg_addr_a_data >= reg_addr_b_data);	
      `RISC_B_FUNCT_3_U_LESS_THAN:	    jump = (reg_addr_a_data <  reg_addr_b_data);	
      `RISC_B_FUNCT_3_U_GREATER_OR_EQ:	jump = (reg_addr_a_data <= reg_addr_b_data);
    endcase
    
    if (jump) begin
      expected_jump_offset[4:1]  = instruction[11:8];
      expected_jump_offset[10:5] = instruction[30:25];
      expected_jump_offset[11]   = instruction[7];
      expected_jump_offset[12]   = instruction[31]; 
    end
    
    
    `uvm_info("risc_b_inst_seq_item", $sformatf("current_PC = %0d", current_PC), UVM_MEDIUM);            
    `uvm_info("risc_b_inst_seq_item", $sformatf("expected_jump_offset = %0d", expected_jump_offset), UVM_MEDIUM);            

    
    expected_next_inst_address = $signed(current_PC)  + expected_jump_offset;
    `uvm_info("risc_b_inst_seq_item", $sformatf("expected_next_inst_address = %0d", expected_next_inst_address), UVM_MEDIUM);            

    
    formated_hdl_path =  $sformatf(memory_hdl_path, expected_next_inst_address);

    
    `uvm_info("risc_b_inst_seq_item", $sformatf("next instruction at = %s", formated_hdl_path), UVM_MEDIUM);            

    
    status = uvm_hdl_read(formated_hdl_path, expected_next_inst);
    if (status) begin
      `uvm_info("risc_b_inst_seq_item", $sformatf("expected_next_inst = %b", expected_next_inst), UVM_MEDIUM);            
    end
    else begin
      `uvm_error("risc_b_inst_seq_item", "Failed to get expected_next_inst");
    end      
  endfunction
  
  
  function int nextPC();
    return expected_next_inst_address;
  endfunction

  
  virtual function int getting_next_instruction();
    logic jump_pc_set = 0;
    string hdl = "risc_test_top.circuit.risc_chip.rih.jump_pc_set";
    
    uvm_hdl_read(hdl, jump_pc_set);
    `uvm_info("risc_b_inst_seq_item",  $sformatf("getting_next_instruction = %b", jump_pc_set), UVM_MEDIUM);

    return jump_pc_set;    
  endfunction
  
  
  
  function void checkExecution();
    int status;
    string formated_hdl_path;
    
    `uvm_info("risc_b_inst_seq_item", $sformatf("expected_next_inst_address = %0d", expected_next_inst_address), UVM_MEDIUM);            

    status = uvm_hdl_read(PC_hdl_path, actual_PC);
    if (status) begin
      `uvm_info("risc_b_inst_seq_item", $sformatf("actual_PC = %0d", actual_PC), UVM_MEDIUM);            
    end
    else begin
      `uvm_error("risc_b_inst_seq_item", "Failed to get actual_PC");
      executedCorrectly = 0;
      return;
    end      
    
    if (expected_next_inst_address != actual_PC) begin
      `uvm_error("risc_b_inst_seq_item", "expected_next_inst_address != actual_PC");
      executedCorrectly = 0;
      return;
    end
    `uvm_info("risc_b_inst_seq_item", $sformatf("instruction: %b at %0d Executed Correctly", instruction, current_PC), UVM_MEDIUM);            
    executedCorrectly = 1;
  endfunction
  
  
endclass

`endif