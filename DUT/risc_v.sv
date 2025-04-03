

`ifndef __RISC_V__
    `define __RISC_V__


//`include "ALU.sv"
//`include "memory.sv"
`include "regfile.sv"
`include "reg_file_if.sv"
`include "mem_bus_interface.sv"
`include "risc_instructions_handler.sv"

module risc_v(
  input logic  clk,
  input logic  reset,
  
  reg_file_if  reg_file_if_i,
  memory_if    memory_if_i);


  /*
  output logic[31:0] mem_rd_addr,
  output logic[31:0] mem_wr_addr,
  output logic[31:0] mem_wr_data,
  output logic       mem_rd_wr,   // 0 => rd
  output logic	     mem_req_valid,
  
  input  logic[31:0] mem_rd_data,
  input  logic		 mem_ack
  
); */
  
  logic 	  mem_rih_sel;      // mem_bus_interface selects rih
  logic       mem_alu_sel;		// mem_bus_interface selects alu if mem_rih_sel is low
  logic[31:0] rih_mem_rd_addr;  // rih => risc instruction handler
  logic[31:0] rih_mem_wr_addr;
  logic[31:0] rih_mem_wr_data;
  logic       rih_mem_rd_wr;    // 0 => rd
  logic		  rih_mem_req_valid;  
  logic[31:0] rih_mem_rd_data;  
  logic       rih_mem_ack;
  
  logic[31:0] alu_mem_rd_addr;
  logic[31:0] alu_mem_wr_addr;
  logic[31:0] alu_mem_wr_data;
  logic       alu_mem_rd_wr;    // 0 => rd
  logic		  alu_mem_req_valid;  
  logic[31:0] alu_mem_rd_data;  
  logic       alu_mem_ack;
  

  logic[4:0]  reg_rd_addr_a;
  logic       reg_rd_addr_a_valid;
  logic[31:0] reg_rd_data_a;
  logic	      reg_rd_data_a_ack;

  logic[4:0]  reg_rd_addr_b;
  logic       reg_rd_addr_b_valid;
  logic[31:0] reg_rd_data_b;
  logic	      reg_rd_data_b_ack;

  logic[4:0]  reg_wr_addr;
  logic[31:0] reg_wr_data;
  logic	      reg_wr_data_valid;
  logic 	  reg_wr_ack;  
  
  
  ALU_OP_CODE  alu_op_code;
  logic[31:0]  alu_input_A;
  logic[31:0]  alu_input_B;
  logic        alu_reg_out;
  logic[4:0]   alu_reg_addr;
  logic        alu_mem_out;
  logic[31:0]  alu_mem_addr;

  logic        alu_pc_jump;
  logic        alu_inputs_valid;

  logic[31:0]  alu_pc_branch_data;
  logic        alu_pc_branch_data_valid;
  logic        alu_pc_branch_data_ack;
  logic 	   alu_input_ack;
  logic        alu_done;

  
  /*
  memory memory_(
      .clk(clk),
      .reset(reset),
	  .rd_addr(mem_rd_addr),
      .wr_addr(mem_wr_addr),
      .wr_data(mem_wr_data),
      .rd_wr(mem_rd_wr),
      .req_valid(),
      .rd_data(),
      .ack());
  */
  
  
  mem_bus_interface mbi(  
    .clk(clk),
    .reset(reset),
    .mem_rih_sel(mem_rih_sel),
    .mem_alu_sel(mem_alu_sel),   
    .rih_mem_rd_addr(rih_mem_rd_addr),
    .rih_mem_wr_addr(rih_mem_wr_addr),
    .rih_mem_wr_data(rih_mem_wr_data),
    .rih_mem_rd_wr(rih_mem_rd_wr),  // 0 => rd
    .rih_mem_req_valid(rih_mem_req_valid),  
    .rih_mem_rd_data(rih_mem_rd_data),
    .rih_mem_ack(rih_mem_ack),
  
    .alu_mem_rd_addr(alu_mem_rd_addr),
    .alu_mem_wr_addr(alu_mem_wr_addr),
    .alu_mem_wr_data(alu_mem_wr_data),
    .alu_mem_rd_wr(alu_mem_rd_wr),  // 0 => rd  
    .alu_mem_req_valid(alu_mem_req_valid),  
    .alu_mem_rd_data(alu_mem_rd_data),
    .alu_mem_ack(alu_mem_ack),
  
    .mem_rd_addr(memory_if_i.mem_rd_addr),
    .mem_wr_addr(memory_if_i.mem_wr_addr),
    .mem_wr_data(memory_if_i.mem_wr_data),
    .mem_rd_wr(memory_if_i.mem_rd_wr),  // 0 => rd
    .mem_req_valid(memory_if_i.mem_req_valid),
  
    .mem_rd_data(memory_if_i.mem_rd_data),
    .mem_ack(memory_if_i.mem_ack));
  

  
  regfile regfile_(
  	.clk(clk),
    .reset(reset),
    .rd_addr_a(reg_file_if_i.reg_rd_addr_a),
    .rd_addr_a_valid(reg_file_if_i.reg_rd_addr_a_valid),
    .rd_data_a(reg_file_if_i.reg_rd_data_a),
    .rd_data_a_ack(reg_file_if_i.reg_rd_data_a_ack),

    .rd_addr_b(reg_file_if_i.reg_rd_addr_b),
    .rd_addr_b_valid(reg_file_if_i.reg_rd_addr_b_valid),
    .rd_data_b(reg_file_if_i.reg_rd_data_b),
    .rd_data_b_ack(reg_file_if_i.reg_rd_data_b_ack),

    .wr_addr(reg_file_if_i.reg_wr_addr),
    .wr_data(reg_file_if_i.reg_wr_data),
    .wr_data_valid(reg_file_if_i.reg_wr_data_valid),
    .wr_ack(reg_file_if_i.reg_wr_ack) 
  );
  
  
  ALU alu (
    .clk(clk),
    .reset(reset),
    .op_code(alu_op_code),
    .input_A(alu_input_A),
    .input_B(alu_input_B),
    .reg_out(alu_reg_out),
    .reg_addr(alu_reg_addr),
    .mem_out(alu_mem_out),
    .mem_addr(alu_mem_addr),

    .pc_jump(alu_pc_jump),
    .inputs_valid(alu_inputs_valid),

    .reg_wr_data(reg_file_if_i.reg_wr_data),
    .reg_wr_addr(reg_file_if_i.reg_wr_addr),
    .reg_wr_data_valid(reg_file_if_i.reg_wr_data_valid),
    .reg_wr_ack(reg_file_if_i.reg_wr_ack),
    
    .mem_alu_sel(mem_alu_sel),
    .mem_rd_addr(alu_mem_rd_addr),
    .mem_wr_addr(alu_mem_wr_addr),
    .mem_wr_data(alu_mem_wr_data),
    .mem_rd_wr(alu_mem_rd_wr),   // 0 => rd
    .mem_req_valid(alu_mem_req_valid),
    .mem_rd_data(alu_mem_rd_data),
    .mem_ack(alu_mem_ack),


    .pc_branch_data(alu_pc_branch_data),
    .pc_branch_data_valid(alu_pc_branch_data_valid),
    .pc_branch_data_ack(alu_pc_branch_data_ack),
    
    .alu_input_ack(alu_input_ack),
    .alu_done(alu_done)
  );

risc_instructions_handler
rih
(
  .clk(clk),
  .reset(reset),
  
  
  // to mem_bus_interface
  .mem_rih_sel(mem_rih_sel),
  .mem_rd_addr(rih_mem_rd_addr),
  .mem_wr_addr(rih_mem_wr_addr),
  .mem_wr_data(rih_mem_wr_data),
  .mem_rd_wr(rih_mem_rd_wr), // 0 => rd
  .mem_req_valid(rih_mem_req_valid),
  .mem_rd_data(rih_mem_rd_data),
  .mem_ack(rih_mem_ack),

  
  // registers signals
  .reg_rd_addr_a(reg_file_if_i.reg_rd_addr_a),
  .reg_rd_addr_a_valid(reg_file_if_i.reg_rd_addr_a_valid),
  .reg_rd_data_a(reg_file_if_i.reg_rd_data_a),
  .reg_rd_data_a_ack(reg_file_if_i.reg_rd_data_a_ack),
  
  .reg_rd_addr_b(reg_file_if_i.reg_rd_addr_b),
  .reg_rd_addr_b_valid(reg_file_if_i.reg_rd_addr_b_valid),  
  .reg_rd_data_b(reg_file_if_i.reg_rd_data_b),
  .reg_rd_data_b_ack(reg_file_if_i.reg_rd_data_b_ack),

  
  
  // ALU signals
  .alu_op_code(alu_op_code),
  .alu_input_A(alu_input_A),
  .alu_input_B(alu_input_B),
  .alu_reg_out(alu_reg_out),
  .alu_reg_addr(alu_reg_addr),
  .alu_mem_out(alu_mem_out),
  .alu_mem_addr(alu_mem_addr),

  .alu_pc_jump(alu_pc_jump),
  .alu_inputs_valid(alu_inputs_valid),

  .alu_pc_branch_data(alu_pc_branch_data),
 
  .alu_pc_branch_data_valid(alu_done),
  .alu_pc_branch_data_ack(alu_pc_branch_data_ack),
  .alu_input_ack(alu_input_ack),
  .alu_done(alu_done));
  
endmodule

`endif








