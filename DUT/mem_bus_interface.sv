`ifndef __MEMORY_BUS_INTERFACE__
    `define __MEMORY_BUS_INTERFACE__


module mem_bus_interface(
  
  input  logic       clk,
  input  logic       reset,
  input  logic       mem_rih_sel, 
  input  logic       mem_alu_sel,
  input  logic[31:0] rih_mem_rd_addr,
  input  logic[31:0] rih_mem_wr_addr,
  input  logic[31:0] rih_mem_wr_data,
  input  logic       rih_mem_rd_wr,  // 0 => rd
  input  logic	     rih_mem_req_valid,  
  output logic[31:0] rih_mem_rd_data,
  output logic		 rih_mem_ack,
  
  input  logic[31:0] alu_mem_rd_addr,
  input  logic[31:0] alu_mem_wr_addr,
  input  logic[31:0] alu_mem_wr_data,
  input  logic       alu_mem_rd_wr,  // 0 => rd  
  input  logic	     alu_mem_req_valid,  
  output logic[31:0] alu_mem_rd_data,
  output logic		 alu_mem_ack,
  
  output logic[31:0] mem_rd_addr,
  output logic[31:0] mem_wr_addr,
  output logic[31:0] mem_wr_data,
  output logic       mem_rd_wr,  // 0 => rd
  output logic	     mem_req_valid,
  
  input  logic[31:0] mem_rd_data,
  input  logic		 mem_ack);
   
/*  
  logic last_rih_mem_req_valid;  
  assign rih_mem_req_valid_posedge = ~last_rih_mem_req_valid  && rih_mem_req_valid;
  
  logic last_alu_mem_req_valid;  
  assign alu_mem_req_valid_posedge = ~last_alu_mem_req_valid  && alu_mem_req_valid;
*/
  
  always_ff @(posedge clk) begin
    if (reset) begin
      mem_req_valid <= 1'b0;
      rih_mem_ack <= 1'b0;
      alu_mem_ack <= 1'b0;
    end
    else begin
      if (mem_rih_sel) begin  // mem_rih_sel has priority
        $display("in mem_bus_interface for mem_rih_sel, rih_mem_rd_addr: %b", rih_mem_rd_addr);
        mem_rd_addr     <= rih_mem_rd_addr;
        mem_wr_addr     <= rih_mem_wr_addr;
        mem_wr_data     <= rih_mem_wr_data;
        mem_rd_wr       <= rih_mem_rd_wr;
        mem_req_valid   <= rih_mem_req_valid; 
        rih_mem_rd_data <= mem_rd_data;
        rih_mem_ack     <= mem_ack;
      end
      else if (mem_alu_sel) begin
        $display("in mem_bus_interface for mem_alu_sel, alu_mem_rd_addr: %b", alu_mem_rd_addr);
        mem_rd_addr     <= alu_mem_rd_addr;
        mem_wr_addr     <= alu_mem_wr_addr;
        mem_wr_data     <= alu_mem_wr_data;
        mem_rd_wr       <= alu_mem_rd_wr;
        mem_req_valid   <= alu_mem_req_valid; 
        alu_mem_rd_data <= mem_rd_data;
        alu_mem_ack     <= mem_ack;
      end
    end
  end

endmodule

`endif