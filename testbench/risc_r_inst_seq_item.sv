
`ifndef __risc_r_inst_seq_item__
  `define __risc_r_inst_seq_item__

`include "ALU.sv"

`include "risc_inst_seq_item.sv"
`include "risc_instruction_constants.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM



class risc_r_inst_seq_item extends risc_inst_seq_item; 
  `uvm_object_utils(risc_r_inst_seq_item)

  
  logic[4:0]   reg_addr_a;
  logic[4:0]   reg_addr_b;
  logic[31:0]  input_a;
  logic[31:0]  input_b;
  logic[4:0]   expected_reg_address;
  logic[31:0]  expected_value;  // alu_result
  logic[31:0]  read_value_at_expected_address;
  int          status;
  ALU_OP_CODE  alu_op_code; 
  
  //string hdl_path;
  
  
  string hdl_path = "risc_test_top.circuit.risc_chip.regfile_.registers[%0d]";
  
  function new (string name = "risc_r_inst_seq_item"); 
    super.new(name);
  endfunction
  
  function void setItUp();
    `uvm_info("risc_r_inst_seq_item", $sformatf("setItUp:: instruction = %b", instruction), UVM_MEDIUM); 

    set_input_values();
    setOpCode();
    set_expected_value();
    expected_reg_address = instruction[11:7];                  
  endfunction
  
  virtual function int getting_next_instruction();
    logic alu_done_posedge = 0;
    string hdl = "risc_test_top.circuit.risc_chip.rih.alu_done_posedge";
    
    uvm_hdl_read(hdl, alu_done_posedge);
    `uvm_info("risc_r_inst_seq_item",  $sformatf("getting_next_instruction = %b", alu_done_posedge), UVM_MEDIUM);

    return alu_done_posedge;    
  endfunction
  
  
  function void checkExecution();
    int status;
    string formated_hdl_path;
    //super.executedCorrectly();

    

    `uvm_info("risc_r_inst_seq_item", "in executedCorrectly", UVM_MEDIUM);
   
    
    formated_hdl_path = $sformatf(hdl_path, expected_reg_address);

    `uvm_info("risc_r_inst_seq_item", $sformatf("hdl_path for expected register = %s", formated_hdl_path), UVM_MEDIUM); 
    
    status = uvm_hdl_read(formated_hdl_path, read_value_at_expected_address);
    
    `uvm_info("risc_r_inst_seq_item", $sformatf("expected value = %b", expected_value), UVM_MEDIUM);            

    if (status) begin
      `uvm_info("risc_r_inst_seq_item", $sformatf("read_value_at_expected_address = %b", read_value_at_expected_address), UVM_MEDIUM);            
    end
    else begin
      `uvm_error("risc_r_inst_seq_item", $sformatf("Failed to read value at expected address = %b", expected_reg_address));
    end  
    
    if (expected_value == read_value_at_expected_address) begin
      `uvm_info("risc_r_inst_seq_item", "Instruction executed correctly", UVM_MEDIUM);   
      executedCorrectly = 1; 
      return;
    end    
    else begin
      `uvm_error("risc_r_inst_seq_item", "Instruction NOT executed correctly");
      executedCorrectly = 0;  
      return;
    end
    
  endfunction
  
  
  
  
  function void print();
        
    `uvm_info("risc_r_inst_seq_item",  $sformatf( "instruction = %b", 		  instruction), 		 UVM_MEDIUM);  
    `uvm_info("risc_r_inst_seq_item",  $sformatf( "reg_addr_a = %b", 		  reg_addr_a), 			 UVM_MEDIUM);  
    `uvm_info("risc_r_inst_seq_item",  $sformatf( "reg_addr_b = %b", 		  reg_addr_b), 			 UVM_MEDIUM);  
    `uvm_info("risc_r_inst_seq_item",  $sformatf( "input_a = %b", 			  input_a), 			 UVM_MEDIUM);  
    `uvm_info("risc_r_inst_seq_item",  $sformatf( "input_b = %b", 			  input_b), 			 UVM_MEDIUM);  
    `uvm_info("risc_r_inst_seq_item",  $sformatf( "alu_op_code = %b", 		  alu_op_code), 		 UVM_MEDIUM);  
    `uvm_info("risc_r_inst_seq_item",  $sformatf( "expected_reg_address = %b", expected_reg_address), UVM_MEDIUM);  
    `uvm_info("risc_r_inst_seq_item",  $sformatf( "expected_value = %b", 	  expected_value), 		 UVM_MEDIUM);  
    
   
  endfunction
                
                 
                 
                 
  
  
  function void set_input_values();
    
    string formated_hdl_path;
    reg_addr_a = instruction[19:15];
    reg_addr_b = instruction[24:20];
    
    formated_hdl_path =  $sformatf(hdl_path, reg_addr_a);
    status = uvm_hdl_read(formated_hdl_path, input_a);
    if (status) begin
       `uvm_info("risc_r_inst_seq_item", $sformatf("input_a = %b", input_a), UVM_MEDIUM);            
    end
    else begin
      `uvm_error("risc_r_inst_seq_item", "Failed to get input_a");
    end
    
    formated_hdl_path =  $sformatf(hdl_path, reg_addr_b);
    status = uvm_hdl_read(formated_hdl_path, input_b);
    if (status) begin
      `uvm_info("risc_r_inst_seq_item", $sformatf("input_b = %b", input_b), UVM_MEDIUM);            
    end
    else begin
      `uvm_error("risc_r_inst_seq_item", "Failed to get input_b");
    end     
  endfunction
  
  
  function void setOpCode();
    `uvm_info("risc_r_inst_seq_item", ">>>>>>Setting op_code", UVM_MEDIUM);            

    if (instruction[14:12] == `RISC_R_FUNC_3_ADD && 
        instruction[31:25] == `RISC_R_FUNC_7_ADD)
      begin
        $display("instruction: ADD");
        alu_op_code = ADD; 
        `uvm_info("risc_r_inst_seq_item", "op_code: ADD", UVM_MEDIUM);            

      end
    else if (instruction[14:12] == `RISC_R_FUNC_3_SUBTRACT && 
             instruction[31:25] == `RISC_R_FUNC_7_SUBTRACT)
      begin
        alu_op_code = SUBTRACT; 
        `uvm_info("risc_r_inst_seq_item", "op_code: SUBTRACT", UVM_MEDIUM);            

      end
    else if (instruction[14:12] == `RISC_R_FUNC_3_XOR && 
             instruction[31:25] == `RISC_R_FUNC_7_XOR)
      begin
        alu_op_code = XOR;                
        `uvm_info("risc_r_inst_seq_item", "op_code: XOR", UVM_MEDIUM);            
      end
    else if (instruction[14:12] == `RISC_R_FUNC_3_OR && 
             instruction[31:25] == `RISC_R_FUNC_7_OR)
      begin
        alu_op_code = OR;                
        `uvm_info("risc_r_inst_seq_item", "op_code: OR", UVM_MEDIUM);            
      end
    else if (instruction[14:12] == `RISC_R_FUNC_3_AND && 
             instruction[31:25] == `RISC_R_FUNC_7_AND)
      begin
        alu_op_code = AND;                
        `uvm_info("risc_r_inst_seq_item", "op_code: AND", UVM_MEDIUM);            
      end
    else if (instruction[14:12] == `RISC_R_FUNC_3_SHIFT_LT_LOG && 
             instruction[31:25] == `RISC_R_FUNC_7_SHIFT_LT_LOG)
      begin
        alu_op_code = SHIFT_LT_LOG;                
        `uvm_info("risc_r_inst_seq_item", "op_code: SHIFT_LT_LOG", UVM_MEDIUM);            
      end  
    else if (instruction[14:12] == `RISC_R_FUNC_3_SHIFT_RT_LOG && 
             instruction[31:25] == `RISC_R_FUNC_7_SHIFT_RT_LOG)
      begin
        alu_op_code = SHIFT_RT_LOG;                
        `uvm_info("risc_r_inst_seq_item", "op_code: SHIFT_RT_LOG", UVM_MEDIUM);            
      end            
    else if (instruction[14:12] == `RISC_R_FUNC_3_SHIFT_RT_AR && 
             instruction[31:25] == `RISC_R_FUNC_7_SHIFT_RT_AR)
      begin
        alu_op_code = SHIFT_RT_AR;                
        `uvm_info("risc_r_inst_seq_item", "op_code: SHIFT_RT_AR", UVM_MEDIUM);            
      end 
    else begin
      `uvm_fatal("risc_r_inst_seq_item", "Could not get op_code");
    end
  endfunction
  
  
  function void set_expected_value();
    case (alu_op_code)
        ADD:          expected_value = input_a + input_b;               
        SUBTRACT:     expected_value = input_a - input_b;
        XOR:          expected_value = input_a ^ input_b;
        OR:           expected_value = input_a | input_b;
        AND:          expected_value = input_a & input_b;
        SHIFT_LT_LOG: expected_value = input_a << input_b;
        SHIFT_RT_LOG: expected_value = input_a >> input_b;
        SHIFT_RT_AR:  expected_value = input_a >>> input_b;
        //BARREL_SHIFTER: 
        IS_EQUAL:     expected_value = input_a == input_b;
        IS_GREATER:   expected_value = input_a > input_b; 
    endcase
    `uvm_info("risc_r_instruction_data", $sformatf("expected_value = %b", expected_value), UVM_MEDIUM);            
  endfunction
  
  

endclass

`endif