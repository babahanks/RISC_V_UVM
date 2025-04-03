`ifndef __reg_file_if__
    `define __reg_file_if__

interface reg_file_if(
  input logic clk,
  input logic reset);
  
  logic[4:0]  reg_rd_addr_a;
  logic 	  reg_rd_addr_a_valid;
  logic[31:0] reg_rd_data_a;
  logic		  reg_rd_data_a_ack;
  
  logic[4:0]  reg_rd_addr_b;
  logic 	  reg_rd_addr_b_valid;
  logic[31:0] reg_rd_data_b;
  logic		  reg_rd_data_b_ack;
  
  logic[4:0]  reg_wr_addr;
  logic[31:0] reg_wr_data;
  logic		  reg_wr_data_valid;
  logic 	  reg_wr_ack;
  
endinterface

`endif