`ifndef __risc_inst_seq_test_top__
    `define __risc_inst_seq_test_top__

`include "memory_if.sv"
`include "reg_file_if.sv"
`include "risc_v_circuit.sv"

//`include "memory.sv"
//`include "risc_v.sv"
`include "risc_test.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM 


module risc_test_top();
  
  logic clk;
  logic reset;
  int  number_of_registers;
  int  global_clk;
  int  instruction_clk;

  

  
  memory_if memory_if_i(
    .clk(clk),
    .reset(reset));
    
  reg_file_if reg_file_if_i(
    .clk(clk),
    .reset(reset));
  
  risc_v_circuit circuit(	
    .clk(clk),
    .reset(reset),
    .reg_file_if_i(reg_file_if_i),
    .memory_if_i(memory_if_i));
  

  initial begin
    circuit.mem.front_door_read_write();    
  end

  
  //always #5 clk = ~clk;
  
   initial begin
    clk = 0;
    global_clk = 0;
    instruction_clk = 0;
    forever begin
      #5 clk = ~clk;
      if (clk) begin
        $display("_______________________________");
        $display("global_clk: %d", global_clk);
        global_clk = global_clk + 1;
      end
      if (global_clk >= 160) begin
        //$finish();
      end
    end
  end
 


  initial begin
    clk = 0;
    reset = 1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    reset = 0;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
  end



  
  initial begin
    uvm_config_db#(virtual memory_if)::set(null, "*", "memory_if", memory_if_i);
    run_test("risc_test");
  end
  
endmodule
`endif