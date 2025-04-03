
`ifndef __RISC_INST_HANDLER__
    `define __RISC_INST_HANDLER__



`include "ALU.sv"
`include "risc_instruction_constants.sv"


typedef enum logic [2:0] {
  None = 3'b000,
  R = 3'b001,
  I = 3'b010,
  S = 3'b011,
  B	= 3'b100
} 
RISC_INSTR_TYPE;


module risc_instructions_handler(
  input  logic 			  clk,
  input  logic 			  reset,
  
  // memory signals
  output logic        mem_rih_sel,    // mem_bus_interface selects this.
  output logic[31:0]  mem_rd_addr,
  output logic[31:0]  mem_wr_addr,
  output logic[31:0]  mem_wr_data,
  output logic        mem_rd_wr, // 0 => rd
  output logic		  mem_req_valid,
  input  logic[31:0]  mem_rd_data,
  input  logic        mem_ack,
  
  // registers signals
  output logic[4:0]   reg_rd_addr_a,
  output logic 		  reg_rd_addr_a_valid,
  input  logic[31:0]  reg_rd_data_a,
  input  logic		  reg_rd_data_a_ack,
  
  output logic[4:0]   reg_rd_addr_b,
  output logic 		  reg_rd_addr_b_valid,  
  input  logic[31:0]  reg_rd_data_b,
  input  logic		  reg_rd_data_b_ack,

  
  
  // ALU signals
  output  ALU_OP_CODE alu_op_code,
  output  logic[31:0] alu_input_A,
  output  logic[31:0] alu_input_B,
  output  logic		  alu_reg_out,
  output  logic[4:0]  alu_reg_addr,
  output  logic		  alu_mem_out,
  output  logic[31:0] alu_mem_addr,

  output  logic       alu_pc_jump,
  output  logic       alu_inputs_valid,

  input   logic[31:0] alu_pc_branch_data, 
  input   logic       alu_pc_branch_data_valid,
  output  logic       alu_pc_branch_data_ack,
  input   logic 	  alu_input_ack,
  input   logic		  alu_done);

  
  logic[31:0] PC;
  logic[31:0] instruction;
  logic		  last_reset;
  logic	      last_alu_done;
  logic       jump;
  logic signed[12:1] jump_offset; 
  logic       inst_b_calculated; // to set PC after B inst.
  logic	      jump_pc_set;       // to get the next instruction after a B inst
  logic       last_inst_b_calculated;
  
  
  
  RISC_INSTR_TYPE risc_instruction;
  
  assign reset_negedge = ~reset && last_reset;
  assign alu_done_posedge = ~last_alu_done && alu_done;
  assign inst_b_calculated_posedge = ~last_inst_b_calculated && inst_b_calculated;  
  assign get_next_instruction = reset_negedge || alu_done_posedge  || jump_pc_set;
  
  
  always_ff @(posedge clk) begin
    if (reset) begin
      last_inst_b_calculated <= 1'b0;
    end
    else begin
    	last_inst_b_calculated <= inst_b_calculated;      
    end    
  end

  
  always_ff @(posedge clk) begin
    $display("risc_instructions_handler:: PC setter: reset = %b", reset);
    $display("risc_instructions_handler:: PC setter: alu_input_ack = %b", alu_input_ack);
    $display("risc_instructions_handler:: PC setter: inst_b_calculated_posedge = %b", inst_b_calculated_posedge);

    if (reset) begin
      PC <= 1'b0; 
      jump_pc_set <= 1'b0;
    end
    // for r and i instruction. inc PC after the alu ack receiving instructions
    else if (alu_input_ack) begin
      $display("inc PC");
      PC <= PC + 1;
    end
    // for b instruction. inc PC after the the next address is calculated   
    else if (inst_b_calculated_posedge) begin
      if (jump) begin
        $display("inc PC");
        PC <= $signed(PC) + jump_offset;        
      end
      else begin
        PC <= PC + 1;
      end
      jump_pc_set <= 1'b1;   // signal to gethe next instruction
    end    
    if (jump_pc_set) begin
      jump_pc_set <= 1'b0;
    end
    $display("risc_instructions_handler:: PC: %d", PC);
  end
  
  
  
  // instruction fetch start and completion
  always_ff @(posedge clk) begin 
    
    //$display("risc_instructions_handler:: get new instruction reset_negedge: %b", reset_negedge);
    //$display("risc_instructions_handler:: get new instruction alu_done_posedge: %b", alu_done_posedge);
    //$display("risc_instructions_handler:: get new instruction jump_pc_set: %b", jump_pc_set);

    if (reset) begin
      last_reset <= 1'b1;
      mem_req_valid <= 1'b0;
    end
    else begin
      last_alu_done <= alu_done;
      //if (reset_negedge || alu_done_posedge  || jump_pc_set) begin
      if (get_next_instruction) begin
        $display("risc_instructions_handler:: getting next instruction<<<<<<<<>>>>>>>>>>>>>>>>>>>>");
        last_reset  <= 1'b0;
        mem_rd_addr <= PC;
        mem_rd_wr   <= 1'b0;
        mem_req_valid <= 1'b1;
        mem_rih_sel  <= 1'b1;
      end 
      else begin
        mem_req_valid <= 1'b0;
      end
      if (mem_ack) begin
        //$display("rih:: mem_ack received"); 
        //mem_req_valid <= 1'b0;
        mem_rih_sel  <= 1'b0;
      end
  	end
  end
  
  
    
    
  // got instruction from memory. Execute it
  always_ff @(posedge clk) begin
    if (reset) begin
        reg_rd_addr_a_valid <= 1'b0;
        reg_rd_addr_b_valid <= 1'b0;      
    end
    else begin 
      if (mem_ack && mem_rd_data[6:0] == `RISC_R_INSTRUCTION) begin
        $display("risc_instruction_handler  instruction: %b", mem_rd_data);
          instruction <= mem_rd_data;
          risc_instruction = R;
          reg_rd_addr_a <= mem_rd_data[19:15];
          reg_rd_addr_b <= mem_rd_data[24:20];
          reg_rd_addr_a_valid <= 1'b1;
          reg_rd_addr_b_valid <= 1'b1;
      end
      else if (mem_ack && mem_rd_data[6:0] == `RISC_I_INSTRUCTION) begin
          instruction <= mem_rd_data;
          risc_instruction = I;
          reg_rd_addr_a <= mem_rd_data[19:15];
          //reg_rd_addr_b <= mem_rd_data[24:20];
          reg_rd_addr_a_valid <= 1'b1;
          //reg_rd_addr_b_valid <= 1'b1;
      end
      else if (mem_ack && mem_rd_data[6:0] == `RISC_B_INSTRUCTION) begin
          instruction <= mem_rd_data;
          risc_instruction = B;
          reg_rd_addr_a <= mem_rd_data[19:15];
          reg_rd_addr_b <= mem_rd_data[24:20];
          reg_rd_addr_a_valid <= 1'b1;
          reg_rd_addr_b_valid <= 1'b1;
      end


      else begin 
        if (reg_rd_data_a_ack) begin
        	reg_rd_addr_a_valid <= 1'b0;
      	end
      	if (reg_rd_data_b_ack) begin
        	reg_rd_addr_b_valid <= 1'b0;      
      	end
      end
    end
  end
  
   

  
  // from reg to ALU
  always_ff @(posedge clk) begin
    if (reset) begin
      alu_inputs_valid <= 1'b0;
      inst_b_calculated <= 1'b0;
    end
    if (inst_b_calculated) begin
      inst_b_calculated <= 1'b0;
    end
    else begin 
      
      if (alu_input_ack) begin
      	alu_inputs_valid <= 1'b0;
      end
      

      if (risc_instruction == R && reg_rd_data_a_ack && reg_rd_data_b_ack) begin
        $display("risc_instruction_handler:: address: %b;   instruction: %b", mem_rd_addr, instruction);
        $display("RISC_R");
      
        if (instruction[14:12] == `RISC_R_FUNC_3_ADD && 
            instruction[31:25] == `RISC_R_FUNC_7_ADD)
          begin
            $display("instruction: ADD");
            alu_op_code <= ADD;                
          end
        else if (instruction[14:12] == `RISC_R_FUNC_3_SUBTRACT && 
                 instruction[31:25] == `RISC_R_FUNC_7_SUBTRACT)
          begin
            alu_op_code <= SUBTRACT;                
          end
        else if (instruction[14:12] == `RISC_R_FUNC_3_XOR && 
                 instruction[31:25] == `RISC_R_FUNC_7_XOR)
          begin
            alu_op_code <= XOR;                
          end
        else if (instruction[14:12] == `RISC_R_FUNC_3_OR && 
                 instruction[31:25] == `RISC_R_FUNC_7_OR)
          begin
            alu_op_code <= OR;                
          end
        else if (instruction[14:12] == `RISC_R_FUNC_3_AND && 
                 instruction[31:25] == `RISC_R_FUNC_7_AND)
          begin
            alu_op_code <= AND;                
          end
        else if (instruction[14:12] == `RISC_R_FUNC_3_SHIFT_LT_LOG && 
                 instruction[31:25] == `RISC_R_FUNC_7_SHIFT_LT_LOG)
          begin
            alu_op_code <= SHIFT_LT_LOG;                
          end  
        else if (instruction[14:12] == `RISC_R_FUNC_3_SHIFT_RT_LOG && 
                 instruction[31:25] == `RISC_R_FUNC_7_SHIFT_RT_LOG)
          begin
            alu_op_code <= SHIFT_RT_LOG;                
          end            
        else if (instruction[14:12] == `RISC_R_FUNC_3_SHIFT_RT_AR && 
                 instruction[31:25] == `RISC_R_FUNC_7_SHIFT_RT_AR)
          begin
            alu_op_code <= SHIFT_RT_AR;                
          end 

        alu_input_A  <= reg_rd_data_a;
        alu_input_B  <= reg_rd_data_b;
        alu_reg_addr <= instruction[11:7];
        alu_inputs_valid <= 1'b1;
        alu_reg_out  <= 1'b1; 
      end
      
      else if (risc_instruction == I && reg_rd_data_a_ack) begin
        $display("risc_instruction_handler:: address: %b;   instruction: %b", mem_rd_addr, instruction);
        $display("RISC_I");
        if (instruction[14:12] == `RISC_I_FUNC_3_ADD)
          begin
            alu_op_code <= ADD; 
            alu_input_B <= instruction[31:20];
          end
        else if (instruction[14:12] == `RISC_I_FUNC_3_XOR )
          begin
            alu_op_code <= XOR;
            alu_input_B <= instruction[31:20];
          end
        else if (instruction[14:12] == `RISC_R_FUNC_3_OR )
          begin
            alu_op_code <= OR;                
            alu_input_B <= instruction[31:20];
          end
        else if (instruction[14:12] == `RISC_R_FUNC_3_AND )
          begin
            alu_op_code <= AND;                
            alu_input_B <= instruction[31:20];
          end
        else if (instruction[14:12] == `RISC_R_FUNC_3_SHIFT_LT_LOG)
          begin
            alu_op_code <= SHIFT_LT_LOG; 
            alu_input_B <= instruction[24:20];
          end  
        else if (instruction[14:12] == `RISC_R_FUNC_3_SHIFT_RT_LOG)
          begin
            alu_op_code <= SHIFT_RT_LOG;                
            alu_input_B <= instruction[24:20];
          end            
        else if (instruction[14:12] == `RISC_R_FUNC_3_SHIFT_RT_AR)
          begin
            alu_op_code <= SHIFT_RT_AR;                
            alu_input_B <= instruction[24:20];
          end 
        
        alu_input_A  <= reg_rd_data_a;
        //alu_input_B  <= reg_rd_data_b;
        alu_reg_addr <= instruction[11:7];
        alu_inputs_valid <= 1'b1;
        alu_reg_out  <= 1'b1; 
      end
      else if (risc_instruction == B && reg_rd_data_a_ack && reg_rd_data_b_ack) begin
        $display("risc_instruction_handler:: address: %b;   instruction: %b", mem_rd_addr, instruction);
        $display("RISC_B");
        jump_offset[4:1]  <= instruction[11:8];
        jump_offset[10:5] <= instruction[30:25];
        jump_offset[11]   <= instruction[7];
        jump_offset[12]   <= instruction[31];
        
        
        $display("risc_instruction_handler:: jump code: %b", instruction[14:12]);
        $display("risc_instruction_handler:: reg_rd_data_a: %b", reg_rd_data_a);
        $display("risc_instruction_handler:: reg_rd_data_b: %b", reg_rd_data_b);
        
        
        $display("risc_instruction_handler:: jump_offset: %b", jump_offset);
        //jump = 1'b0;
        case (instruction[14:12])
          `RISC_B_FUNCT_3_EQUAL:            jump <= (reg_rd_data_a == reg_rd_data_b);
          `RISC_B_FUNCT_3_NOT_EQUAL:        jump <= (reg_rd_data_a != reg_rd_data_b);		
          `RISC_B_FUNCT_3_LESS_THAN:        jump <= ($signed(reg_rd_data_a) <  $signed(reg_rd_data_b));		
          `RISC_B_FUNCT_3_GREATER_OR_EQ:    jump <= (reg_rd_data_a >= reg_rd_data_b);	
          `RISC_B_FUNCT_3_U_LESS_THAN:	    jump <= (reg_rd_data_a <  reg_rd_data_b);	
          `RISC_B_FUNCT_3_U_GREATER_OR_EQ:	jump <= (reg_rd_data_a <= reg_rd_data_b);
          default                           jump <= 1'b0;
        endcase
        
        inst_b_calculated <= 1'b1;
        $display("risc_instruction_handler:: jump: %0b", jump);
      end
    end     
  end
      
endmodule

`endif