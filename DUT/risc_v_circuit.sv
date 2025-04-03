`ifndef __RISC_V_CIRCUIT__
    `define __RISC_V_CIRCUIT__


`include "memory.sv"
`include "risc_v.sv"
`include "memory_if.sv"
`include "reg_file_if.sv"

module risc_v_circuit(
  input logic clk,
  input logic reset,
  reg_file_if reg_file_if_i,
  memory_if   memory_if_i);
  
  /*
  
  logic[31:0] mem_rd_addr;
  logic[31:0] mem_wr_addr;
  logic[31:0] mem_wr_data;
  logic       mem_rd_wr;  // 0 => rd
  logic	      mem_req_valid;
  
  logic[31:0] mem_rd_data;
  logic		  mem_ack;
  */
  
  memory mem(memory_if_i);
  
  risc_v risc_chip(
    .clk(clk),
    .reset(reset),
    .reg_file_if_i(reg_file_if_i),
    .memory_if_i(memory_if_i));


endmodule

`endif
