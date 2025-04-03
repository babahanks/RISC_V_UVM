`ifndef __REGFILE__
    `define __REGFILE__


module regfile(
  input  logic		 clk,
  input  logic		 reset,
  
  input  logic[4:0]  rd_addr_a,
  input  logic 		 rd_addr_a_valid,
  output logic[31:0] rd_data_a,
  output logic		 rd_data_a_ack,
  
  input  logic[4:0]  rd_addr_b,
  input  logic 		 rd_addr_b_valid,
  output logic[31:0] rd_data_b,
  output logic		 rd_data_b_ack,
  
  input  logic[4:0]  wr_addr,
  input  logic[31:0] wr_data,
  input  logic		 wr_data_valid,
  output logic 		 wr_ack);
  
  logic [31:0] registers[0:31];
  
  always_ff @(posedge clk) begin
    if (reset) begin
      wr_ack <= 1'b0;
      /*
      registers[0] <= 32'b101011;
      registers[1] <= 32'b101010;
      registers[3] <= 32'b101111;
      registers[4] <= 32'b101011;

      for (int i=5; i<32; i++) begin
        registers[i] <= 32'b0;
      end    */  
    end
    else if (wr_data_valid) begin
      $display("regfile::wr_data[%b]: %b", wr_addr, wr_data);
      registers[wr_addr] <= wr_data;
      wr_ack <= 1'b1;
    end
    else if (~wr_data_valid) begin
      wr_ack <= 1'b0;
    end

  end
  
  always_ff @(posedge clk) begin
    if (reset) begin
      rd_data_a_ack <= 1'b0;
    end
    else if (~rd_addr_a_valid) begin
      rd_data_a_ack <= 1'b0;
    end
    else if (rd_addr_a_valid) begin
      rd_data_a_ack <= 1'b1;
      rd_data_a <= registers[rd_addr_a];
      $display("regfile::rd_data_a: %b", registers[rd_addr_a]);
    end
  end
  
  
  always_ff @(posedge clk) begin
    if (reset) begin
      rd_data_b_ack <= 1'b0;
    end
    else if (~rd_addr_b_valid) begin
      rd_data_b_ack <= 1'b0;
    end
    else if (rd_addr_b_valid) begin
      rd_data_b_ack <= 1'b1;
      rd_data_b <= registers[rd_addr_b];
      $display("regfile::rd_data_b: %b", registers[rd_addr_b]);
    end
  end
  
endmodule
`endif
  
  
  
  
  