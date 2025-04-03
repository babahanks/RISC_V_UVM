`ifndef __memory_if__
    `define __memory_if__


interface memory_if(
  input  logic clk,
  input  logic reset);

  logic[31:0] mem_rd_addr;
  logic[31:0] mem_wr_addr;
  logic[31:0] mem_wr_data;
  logic       mem_rd_wr;   // 0 => rd
  logic	      mem_req_valid;  
  logic[31:0] mem_rd_data;
  logic		  mem_ack;
  
endinterface

`endif