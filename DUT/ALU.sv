`ifndef __ALU__
    `define __ALU__


typedef enum logic [3:0] {
  
  ADD         = 4'b0000,
  SUBTRACT      = 4'b0001,
  XOR       = 4'b0010,
  OR        = 4'b0011,
  AND       = 4'b0100,
  SHIFT_LT_LOG    = 4'b0101,
  SHIFT_RT_LOG    = 4'b0110,
  SHIFT_RT_AR   = 4'b0111,
  BARREL_SHIFTER  = 4'b1000,
  IS_EQUAL      = 4'b1001,
  IS_GREATER    = 4'b1010
} 
ALU_OP_CODE;


module ALU(
  input  logic        clk,
  input  logic        reset,
  input  ALU_OP_CODE  op_code,
  input  logic[31:0]  input_A,
  input  logic[31:0]  input_B,
  input  logic		  reg_out,   // send answer to reg
  input  logic[4:0]   reg_addr,
  input  logic		  mem_out,   // send answer to mem
  input  logic[31:0]  mem_addr,

  input  logic        pc_jump,
  input  logic        inputs_valid,
  
  output logic[31:0]  reg_wr_data,
  output logic[4:0]   reg_wr_addr,
  output logic		  reg_wr_data_valid,
  input  logic        reg_wr_ack,
  
  output logic       mem_alu_sel,    // mem_bus_interface select alu, if 
  								  // mem_bus_interface.rih_sel is low
  output logic[31:0]  mem_rd_addr,
  output logic[31:0]  mem_wr_addr,
  output logic[31:0]  mem_wr_data,
  output logic        mem_rd_wr,   // 0 => rd
  output logic	      mem_req_valid,
  input  logic[31:0]  mem_rd_data,
  input  logic        mem_ack,
  
  
  output logic[31:0]  pc_branch_data,
  output logic        pc_branch_data_valid,
  input  logic        pc_branch_data_ack,
  output logic 		  alu_input_ack,
  output logic 		  alu_done
  );
  
  logic[31:0] result;
  
    always_ff @(posedge clk) begin
    if (reset) begin
      alu_input_ack <= 1'b0;
    end
    else begin 
      if (inputs_valid && ~alu_input_ack) begin
        $display("alu_input_ack <= 1'b1;");
      	alu_input_ack <= 1'b1;
      end
      else if (alu_input_ack) begin
        $display("alu_input_ack <= 1'b0;");
      	alu_input_ack <= 1'b0;  // bring it down next clk cycle.
      end
    end
  end
   
  
  always_ff @(posedge clk) begin
    if (reset) begin
      alu_done <= 1'b0;      
    end   
    else if ((reg_wr_ack || mem_ack) && ~ alu_done ) begin
      alu_done <= 1'b1;
    end 
    else if (alu_done) begin
      alu_done <= 1'b0;  // bring it down next clk cycle.
    end

  end
  
  
  always_ff @(posedge clk) begin
    if (reset || ~inputs_valid) begin
      reg_wr_data_valid <= 1'b0;      
    end
    else if (inputs_valid  && reg_out) begin
      reg_wr_addr  <= reg_addr;
      reg_wr_data_valid <= 1'b1;
      case (op_code)
        ADD:       reg_wr_data <= input_A + input_B;               
        SUBTRACT:  reg_wr_data <= input_A - input_B;
        XOR:       reg_wr_data <= input_A ^ input_B;
        OR:        reg_wr_data <= input_A | input_B;
        AND:       reg_wr_data <= input_A & input_B;
        SHIFT_LT_LOG:   reg_wr_data <= input_A << input_B;
        SHIFT_RT_LOG:   reg_wr_data <= input_A >> input_B;
        SHIFT_RT_AR:    reg_wr_data <= input_A >>> input_B;
        //BARREL_SHIFTER: 
        IS_EQUAL:     reg_wr_data <= input_A == input_B;
        IS_GREATER:   reg_wr_data <= input_A > input_B; 
      endcase
    end
    else if (reg_wr_ack) begin
      reg_wr_data_valid <= 1'b0;
    end    
  end
  
 
  always_ff @(posedge clk) begin
    if (reset || ~inputs_valid) begin
      mem_req_valid <= 1'b0;      
    end
    else if (inputs_valid  && mem_out) begin
      mem_wr_addr  <= mem_addr;
      mem_rd_wr    <= 1'b1;  // 1 => wr
      mem_req_valid <= 1'b1;
      mem_alu_sel <= 1'b1; 
      case (op_code)
        ADD:       mem_wr_data <= input_A + input_B;               
        SUBTRACT:  mem_wr_data <= input_A - input_B;
        XOR:       mem_wr_data <= input_A ^ input_B;
        OR:        mem_wr_data <= input_A | input_B;
        AND:       mem_wr_data <= input_A & input_B;
        SHIFT_LT_LOG:   mem_wr_data <= input_A << input_B;
        SHIFT_RT_LOG:   mem_wr_data <= input_A >> input_B;
        SHIFT_RT_AR:    mem_wr_data <= input_A >>> input_B;
        //BARREL_SHIFTER: 
        IS_EQUAL:     mem_wr_data <= input_A == input_B;
        IS_GREATER:   mem_wr_data <= input_A > input_B; 
      endcase
    end
    else if (mem_ack) begin
      mem_req_valid <= 1'b0;
      mem_alu_sel <= 1'b0; 
    end       
  end 
endmodule

`endif