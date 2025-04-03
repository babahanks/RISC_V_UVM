`ifndef __MEMORY__
    `define __MEMORY__

`include "memory_if.sv"

module memory(memory_if memory_if_i);
  
  localparam int MEM_SIZE = 64000; // Compile-time constant
  logic [31:0] memory [0:MEM_SIZE - 1]; // Array with 64000 elements  
  
  logic last_req_valid;  // keeping track of the req_valid signal in the previous clk
  
  assign req_valid_posedge = ~last_req_valid  && memory_if_i.mem_req_valid;
  
  
  
  task front_door_read_write();    
      forever begin
        $display("memory front_door_read_write before @(posedge memory_if_i.clk) ");

        @(posedge memory_if_i.clk)
 
        $display("memory. req_valid: %b", memory_if_i.mem_req_valid);
        $display("memory. last_req_valid: %b", last_req_valid);
        $display("memory. req_valid_posedge: %b", req_valid_posedge);

        if (memory_if_i.reset) begin
          last_req_valid <=1'b0;
          memory_if_i.mem_ack <= 1'b0;
          // boot load for testing
          //$readmemb("memory_boot_load.txt", memory);  
        end
        else begin 
          if (req_valid_posedge) begin
            if (~memory_if_i.mem_rd_wr) begin
              $display("memory reading address: %b", memory_if_i.mem_rd_addr);
              memory_if_i.mem_rd_data <= memory[memory_if_i.mem_rd_addr];
            end
            else if (memory_if_i.mem_rd_wr) begin
              memory[memory_if_i.mem_wr_addr] <= memory_if_i.mem_wr_data;
            end
            memory_if_i.mem_ack <= 1'b1;        
          end
        end
        if (memory_if_i.mem_ack) begin
          memory_if_i.mem_ack <= 1'b0;
        end  
      end   
  endtask

  
  task back_door_write(
    logic[31:0] address,
    logic[31:0] data);
    
    //@(posedge memory_if_i.clk)
    memory[address] <= data;
    $display("memory_2:: memory[%b] = %b", address, data);
    
  endtask
  
  
  task back_door_read(
    input logic[31:0] address,
    output logic[31:0] data);

    // Directly read memory content at the given address
    data = memory[address];
  endtask  
  
endmodule

`endif
  