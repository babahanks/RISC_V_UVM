`include "risc_v_circuit.sv"
`include "memory_if.sv"
`include "reg_file_if.sv"

module risc_v_circuit_tb();
  
  logic clk;
  logic reset;
  logic [31:0] mem_read_value;
  int   global_clk;
  int   instruction_number;
  int   instruction_clk;
  
  
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
    
  end
  
  
  initial begin
    clk = 0;
    instruction_clk = 0;
    instruction_number = 0;
    forever begin
      #5 clk = ~clk;
      if (clk) begin
        $display("_______________________________");
        $display("global_clk: %d", global_clk);
        $display("instruction_number: %d", instruction_number);
        $display("instruction_clk: %d", instruction_clk);
        global_clk = global_clk + 1;
        instruction_clk = instruction_clk +1;
      end
    end
    
  end
  
  initial begin
    circuit.mem.front_door_read_write();    
  end
      
  initial begin
    //$readmemb("memory_boot_load.txt", circuit.mem.memory);
    
    $dumpfile("waveform.vcd");
    $dumpvars(0);

    reset = 1'b1;    
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
        
    assert(circuit.risc_chip.rih.mem_req_valid == 1'b0) 
      else $error("circuit.risc_chip.mem_req_valid should be %b. it is %b", 
                   1'b0, 
                   circuit.risc_chip.rih.mem_req_valid); 
    
    circuit.mem.back_door_write(32'b0, 32'b0000000000100000000000100110011);
    @(posedge clk);
    circuit.mem.back_door_read(32'b0, mem_read_value);
    $display("circuit.mem.back_door_read for address 0: %b", mem_read_value);

    
    reset = 1'b0; 
    
    
    $display("fetch_and_run_R_inst: b0000000000100000000000100110011");
    instruction_clk = 0;
    instruction_number = 1;

    fetch_and_run_R_inst(
      32'b0, // exp_PC,
      32'b0000000000100000000000100110011, // exp_instruction,
      5'b0,  // exp_reg_rd_addr_a,
      5'b1,  // exp_reg_rd_addr_b,
      32'b101011, // exp_reg_rd_data_a,
      32'b101010, // exp_reg_rd_data_b,
      ADD,    // exp_alu_code,
      5'b10,  //exp_reg_wr_addr,
      32'b1010101 //exp_reg_wr_data
    );
	
    circuit.mem.back_door_write(32'b1, 32'b00000000010000011000001010110011);
    //circuit.mem.back_door_write(32'b10, 32'b01000000010000011000001100110011);
    //circuit.mem.back_door_write(32'b11, 32'b00000000101000001000001110010011);

    instruction_clk = 0;
    instruction_number = 2;

    $display("fetch_and_run_R_inst: b00000000010000011000001010110011");
    fetch_and_run_R_inst(
      32'b1, // exp_PC,
      32'b00000000010000011000001010110011, // exp_instruction,
      5'b11,  // exp_reg_rd_addr_a,
      5'b100,  // exp_reg_rd_addr_b,
      32'b101111, // exp_reg_rd_data_a,
      32'b101011, // exp_reg_rd_data_b,
      ADD,    // exp_alu_code,
      5'b101,  //exp_reg_wr_addr,
      32'b1011010 //exp_reg_wr_data
    );

    circuit.mem.back_door_write(32'b10, 32'b01000000010000011000001100110011);

    
    $display("fetch_and_run_R_inst: b01000000010000011000001100110011");
    instruction_clk = 0;
    instruction_number = 3;

    fetch_and_run_R_inst(
      32'b10, // exp_PC,
      32'b01000000010000011000001100110011, // exp_instruction,
      5'b11,  // exp_reg_rd_addr_a,
      5'b100,  // exp_reg_rd_addr_b,
      32'b101111, // exp_reg_rd_data_a,
      32'b101011, // exp_reg_rd_data_b,
      SUBTRACT,    // exp_alu_code,
      5'b110,  //exp_reg_wr_addr,
      32'b000100 //exp_reg_wr_data
    );
    
    circuit.mem.back_door_write(32'b11, 32'b00000000101000001000001110010011);

    $display("fetch_and_run_I_inst: b00000000101000001000001110010011"); 
    instruction_clk = 0;
    instruction_number = 4;

    fetch_and_run_I_inst(
      32'b11, //exp_PC,
      32'b00000000101000001000001110010011,  // exp_instruction,
      5'b1, // exp_reg_rd_addr_a,
      32'b101010, // exp_reg_rd_data_a,
      12'b1010, // exp_immediate_value,
      ADD, //exp_alu_code,
      5'b111, // exp_reg_wr_addr,
      32'b110100 //exp_reg_wr_data
    );
    
    $finish();    
  end
  
  task automatic fetch_and_run_R_inst(
    input logic[31:0] exp_PC,
    input logic[31:0] exp_instruction,
    input logic[4:0]  exp_reg_rd_addr_a,
    input logic[4:0]  exp_reg_rd_addr_b,
    input logic[31:0] exp_reg_rd_data_a,
    input logic[31:0] exp_reg_rd_data_b,
    input ALU_OP_CODE exp_alu_code,
    input logic[31:0] exp_reg_wr_addr,
    input logic[31:0] exp_reg_wr_data);
    
	int i=1;
    @(posedge clk);
    setupToGetInstruction(exp_PC);
    
    @(posedge clk); // setting up mem_bus_interface
    
    @(posedge clk);  // spent in memory
    
    @(posedge clk); // mem to mem_bus_interface

    @(posedge clk);  // instruction received
    setUpRegDataFromInstruction_R(
      exp_instruction,
      exp_reg_rd_addr_a,
      exp_reg_rd_addr_b);
    
    @(posedge clk);
    getRegData_R(
      exp_reg_rd_data_a,
      exp_reg_rd_data_b);
    
    @(posedge clk);
    setUpALUCall(
      exp_reg_rd_data_a,
      exp_reg_rd_data_b,
      exp_alu_code);
    
    @(posedge clk);
    aluWriteResultToReg(
      exp_reg_wr_addr,
      exp_reg_wr_data);
    
    @(posedge clk)
	checkDataWrittenInReg(
    	exp_reg_wr_addr,
      	exp_reg_wr_data);  
    
    @(posedge clk);
    $display("DONE");
    //rihReceivesAluDone();

    //@(posedge clk);
    //$display("clk: 9");
    //rihReceivesAluDoneDown();
    
    //@(posedge clk);
    //$display("clk: 10");

    //@(posedge clk);
    //$display("clk: 11");
    
    
  endtask
  
  
  task automatic fetch_and_run_I_inst(
    input logic[31:0] exp_PC,
    input logic[31:0] exp_instruction,
    input logic[4:0]  exp_reg_rd_addr_a,
    input logic[31:0] exp_reg_rd_data_a,
    input logic[31:0] exp_immediate_value,
    input ALU_OP_CODE exp_alu_code,
    input logic[31:0] exp_reg_wr_addr,
    input logic[31:0] exp_reg_wr_data);
    
	int i = 1;
    @(posedge clk);
    setupToGetInstruction(exp_PC);
    
    @(posedge clk); // setting up mem_bus_interface
    
    @(posedge clk);  // spent in memory
    
    @(posedge clk); // mem to mem_bus_interface

    @(posedge clk);  // instruction received
    setUpRegDataFromInstruction_I(
      exp_instruction,
      exp_reg_rd_addr_a);
    
    @(posedge clk);
    getRegData_I(
      exp_reg_rd_data_a);
    
    @(posedge clk);
    setUpALUCall(
      exp_reg_rd_data_a,
      exp_immediate_value,
      exp_alu_code);
    
    @(posedge clk);
    aluWriteResultToReg(
      exp_reg_wr_addr,
      exp_reg_wr_data);
    
    @(posedge clk)
	checkDataWrittenInReg(
    	exp_reg_wr_addr,
      	exp_reg_wr_data);  
    
    @(posedge clk);
    $display("DONE");

    //rihReceivesAluDone();

    //@(posedge clk);
    //$display("clk: 9");
    //rihReceivesAluDoneDown();
    
    //@(posedge clk);
    //$display("clk: 10");

    //@(posedge clk);
    //$display("clk: 11");
    
    
  endtask
  
  task setupToGetInstruction(
    input logic[31:0] exp_PC);
    
   
    $display();
    $display("Setting up to get instruction");
    
    assert(circuit.risc_chip.rih.PC == exp_PC)
      else $error("exp_PC: %b. it is %b", 
                   exp_PC, 
                   circuit.risc_chip.rih.PC); 
    
    assert(circuit.risc_chip.rih_mem_req_valid == 1'b1) 
      else $error("circuit.risc_chip.mem_req_valid: %b. it is %b", 
                   1'b1, 
                   circuit.risc_chip.rih_mem_req_valid); 
    
    assert(circuit.risc_chip.rih.reg_rd_addr_a_valid == 1'b0) 
      else $error("circuit.risc_chip.reg_rd_addr_a_valid should be %b. it is %b", 
                   1'b0, 
                   circuit.risc_chip.reg_rd_addr_a_valid);
    
    assert(circuit.risc_chip.rih.reg_rd_addr_b_valid == 1'b0) 
      else $error("circuit.risc_chip.reg_rd_addr_b_valid should be %b. it is %b", 
                   1'b0, 
                   circuit.risc_chip.reg_rd_addr_b_valid);    

  endtask
  
  
  task setUpRegDataFromInstruction_R(
    input logic[31:0] exp_instruction,
    input logic[4:0]  exp_reg_rd_addr_a,
    input logic[4:0]  exp_reg_rd_addr_b);
    
    
    //@(posedge clk);
    $display();    
    $display("Instruction received");
    assert(circuit.risc_chip.rih.mem_rd_data == exp_instruction) 
      else $error("expected_instruction: should be %b. it is %b", 
                   exp_instruction, 
                   circuit.risc_chip.rih.mem_rd_data); 
    
    assert(circuit.risc_chip.rih.reg_rd_addr_a == exp_reg_rd_addr_a) 
      else $error("circuit.risc_chip.rih.reg_rd_addr_a should be %b. it is %b", 
                   exp_reg_rd_addr_a, 
                   circuit.risc_chip.rih.reg_rd_addr_a); 
    
    assert(circuit.risc_chip.rih.reg_rd_addr_b == exp_reg_rd_addr_b) 
      else $error("circuit.risc_chip.rih.reg_rd_addr_b should be %b. it is %b", 
                   exp_reg_rd_addr_b, 
                   circuit.risc_chip.rih.reg_rd_addr_b); 
    
        
    assert(circuit.risc_chip.rih.reg_rd_addr_a_valid == 1'b1) 
      else $error("circuit.risc_chip.rih.reg_rd_addr_a_valid should be %b. it is %b", 
                   1'b1, 
                   circuit.risc_chip.rih.reg_rd_addr_a_valid); 
    
    assert(circuit.risc_chip.rih.reg_rd_addr_b_valid == 1'b1) 
      else $error("circuit.risc_chip.rih.reg_rd_addr_b_valid should be %b. it is %b", 
                   1'b1, 
                   circuit.risc_chip.rih.reg_rd_addr_b_valid);    

  endtask
    
  task setUpRegDataFromInstruction_I(
      input logic[31:0] exp_instruction,
      input logic[4:0]  exp_reg_rd_addr_a);
    
    
    //@(posedge clk);
    $display();    
    $display("Instruction received");
    assert(circuit.risc_chip.rih_mem_rd_data == exp_instruction) 
      else $error("expected_instruction: should be %b. it is %b", 
                   exp_instruction, 
                   circuit.risc_chip.rih_mem_rd_data); 
    
    assert(circuit.risc_chip.rih.reg_rd_addr_a == exp_reg_rd_addr_a) 
      else $error("ircuit.risc_chip.rih.reg_rd_addr_a should be %b. it is %b", 
                   exp_reg_rd_addr_a, 
                   circuit.risc_chip.rih.reg_rd_addr_a); 
            
    assert(circuit.risc_chip.rih.reg_rd_addr_a_valid == 1'b1) 
      else $error("circuit.risc_chip.rih.reg_rd_addr_a_valid should be %b. it is %b", 
                   1'b1, 
                   circuit.risc_chip.rih.reg_rd_addr_a_valid); 
    
  endtask
  
  
  
  task getRegData_R(
    input logic[31:0] exp_reg_rd_data_a,
    input logic[31:0] exp_reg_rd_data_b);

    $display();
    $display("Received Reg Data");
    

    assert(reg_file_if_i.reg_rd_data_a == exp_reg_rd_data_a) 
      else $error("reg_file_if_i.reg_rd_data_a should be %b. it is %b", 
                   exp_reg_rd_data_a, 
                   reg_file_if_i.reg_rd_data_a); 

    /*
    assert(circuit.risc_chip.reg_rd_data_a == exp_reg_rd_data_a) 
      else $error("circuit.risc_chip.reg_rd_data_a should be %b. it is %b", 
                   exp_reg_rd_data_a, 
                   circuit.risc_chip.reg_rd_data_a); 
    */
    assert(circuit.risc_chip.rih.reg_rd_data_b == exp_reg_rd_data_b) 
      else $error("circuit.risc_chip.rih.reg_rd_data_b should be %b. it is %b", 
                   exp_reg_rd_data_b, 
                   circuit.risc_chip.rih.reg_rd_data_b); 
       
  endtask
  
  task getRegData_I(
    input logic[31:0] exp_reg_rd_data_a);

    $display();
    $display("Received Reg Data");

    assert(circuit.risc_chip.rih.reg_rd_data_a == exp_reg_rd_data_a) 
      else $error("circuit.risc_chip.rih.reg_rd_data_a should be %b. it is %b", 
                   exp_reg_rd_data_a, 
                   circuit.risc_chip.rih.reg_rd_data_a); 
           
  endtask
  
  
  
  
  
  task setUpALUCall(
    input logic[31:0] exp_alu_input_A,
    input logic[31:0] exp_alu_input_B,
    input ALU_OP_CODE exp_alu_code);
    
    $display();
    $display("Setup ALU call");

    assert(circuit.risc_chip.rih.alu_input_A == exp_alu_input_A) 
      else $error("circuit.risc_chip.rih.alu_input_A should be %b. it is %b", 
                   exp_alu_input_A, 
                   circuit.risc_chip.rih.alu_input_A); 
    
    assert(circuit.risc_chip.rih.alu_input_B == exp_alu_input_B) 
      else $error("circuit.risc_chip.rih.alu_input_B should be %b. it is %b", 
                   exp_alu_input_B, 
                   circuit.risc_chip.rih.alu_input_B); 
    
    assert(circuit.risc_chip.rih.alu_op_code == exp_alu_code) 
      else $error("circuit.risc_chip.rih.alu_op_code should be %b. it is %b", 
                   exp_alu_code, 
                   circuit.risc_chip.rih.alu_op_code); 
   
  endtask
  
  
  task aluWriteResultToReg(
    input logic[31:0] exp_reg_wr_addr,
    input logic[31:0] exp_reg_wr_data);
    
    $display();
    $display("aluWriteResultToReg");
    
    
    assert(circuit.risc_chip.alu.reg_wr_data == exp_reg_wr_data) 
      else $error("circuit.risc_chip.alu.reg_wr_data should be %b. it is %b", 
                   exp_reg_wr_data, 
                   circuit.risc_chip.alu.reg_wr_data); 
    
    assert(circuit.risc_chip.alu.reg_wr_addr == exp_reg_wr_addr) 
      else $error("circuit.risc_chip.alu.reg_wr_addr should be %b. it is %b", 
                   exp_reg_wr_addr, 
                   circuit.risc_chip.alu.reg_wr_addr); 

    assert(circuit.risc_chip.alu.reg_wr_data_valid == 1'b1) 
      else $error("circuit.risc_chip.alu.reg_wr_data_valid should be %b. it is %b", 
                   1'b1, 
                   circuit.risc_chip.alu.reg_wr_data_valid); 
    
  endtask
  
  task checkDataWrittenInReg(
    input logic[31:0] exp_reg_wr_addr,
    input logic[31:0] exp_reg_wr_data);
    
    $display();
    $display("checkDataWrittenInReg");

    
    assert(circuit.risc_chip.regfile_.registers[exp_reg_wr_addr] == exp_reg_wr_data) 
      else $error("circuit.risc_chip.regfile_.registers[exp_reg_wr_addr] should be %b. it is %b", 
                   exp_reg_wr_data, 
                   circuit.risc_chip.regfile_.registers[exp_reg_wr_addr]); 

    
  endtask
  
  
  task rihReceivesAluDone();
    $display("RIH receives ALU done signal");
    
    assert(circuit.risc_chip.rih.alu_done == 1'b1) 
      else $error("circuit.risc_chip.rih.alu_done should be %b. it is %b", 
                   1'b1, 
                   circuit.risc_chip.rih.alu_done);    
  endtask

  task rihReceivesAluDoneDown();
    $display("RIH receives ALU done down signal");
    
    assert(circuit.risc_chip.rih.alu_done == 1'b0) 
      else $error("circuit.risc_chip.rih.alu_done should be %b. it is %b", 
                   1'b0, 
                   circuit.risc_chip.rih.alu_done);    
  endtask
  

  
  
  /*
  
  initial begin
    
    reset = 1'b1;
    
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    
    
    
    assert(r.mem_rd_addr_valid == 1'b0) 
      else $error("r.mem_rd_addr_valid should be %b. it is %b", 
                   1'b0, 
                   r.mem_rd_addr_valid); 

    reset = 1'b0;
    
    @(posedge clk);
    $display("1");
    $display("clk");
    
    assert(r.mem_rd_addr_valid == 1'b1) 
      else $error("r.mem_rd_addr_valid should be %b. it is %b", 
                   1'b1, 
                   r.mem_rd_addr_valid); 
    
    assert(r.reg_rd_addr_a_valid == 1'b0) 
      else $error("r.reg_rd_addr_a_valid should be %b. it is %b", 
                   1'b0, 
                   r.reg_rd_addr_a_valid); 


    @(posedge clk);
    $display("2");
    $display("clk");    
    assert(r.mem_rd_data == 32'b0000000000100000000000100110011) 
      else $error("r.mem_rd_data should be %b. it is %b", 
                   32'b0000000000100000000000100110011, 
                   r.mem_rd_data); 
    assert(r.reg_rd_addr_a_valid == 1'b0) 
      else $error("r.reg_rd_addr_a_valid should be %b. it is %b", 
                   1'b0, 
                   r.reg_rd_addr_a_valid); 
  
    @(posedge clk);
    $display("3");
    $display("clk");
    
    $display("r.reg_rd_addr_a: %b", r.reg_rd_addr_a);
    $display("r.reg_rd_addr_b: %b", r.reg_rd_addr_b);

    $display("r.regfile_.rd_data_a_ack: %b", r.regfile_.rd_data_a_ack);
    $display("r.regfile_.rd_data_b_ack: %b", r.regfile_.rd_data_a_ack);

    $display("r.regfile_.rd_data_a: %b", r.regfile_.rd_data_a);
    $display("r.regfile_.rd_data_b: %b", r.regfile_.rd_data_b);
    
    @(posedge clk);
    $display("4");
    $display("clk");
    $display("r.reg_rd_data_a_ack: %b", r.reg_rd_data_a_ack);
    $display("r.reg_rd_data_b_ack: %b", r.reg_rd_data_b_ack);

    $display("r.reg_rd_addr_a: %b", r.reg_rd_addr_a);
    $display("r.reg_rd_addr_b: %b", r.reg_rd_addr_b);
    
    assert(r.reg_rd_addr_a == 1'b0) 
      else $error("r.reg_rd_addr_a should be %b. it is %b", 
                   5'b00000, 
                   r.reg_rd_addr_a); 
    assert(r.reg_rd_addr_b == 1'b0) 
      else $error("r.reg_rd_addr_b should be %b. it is %b", 
                   5'b00001, 
                   r.reg_rd_addr_b); 
    
    
    
    @(posedge clk);
    $display("5");
    $display("clk");
    $display("r.alu_input_A: %b", r.alu_input_A);
    $display("r.alu_input_B: %b", r.alu_input_B);

    $display("r.alu_reg_addr: %b", r.alu_reg_addr);
    $display("r.alu_reg_out: %b", r.alu_reg_out);
    $display("r.alu_op_code: %b", r.alu_op_code);
    
    $display("r.alu.inputs_valid: %b", r.alu.inputs_valid);    
    $display("r.alu.alu_input_ack: %b", r.alu.alu_input_ack);
    
    
    @(posedge clk);
    $display("6");
    $display("clk");
    $display("r.alu_input_A: %b", r.alu_input_A);
    $display("r.alu_input_B: %b", r.alu_input_B);

    $display("r.alu_reg_addr: %b", r.alu_reg_addr);
    $display("r.alu_reg_out: %b", r.alu_reg_out);
    $display("r.alu_op_code: %b", r.alu_op_code);
    $display("r.alu.alu_done: %b", r.alu.alu_done);
    $display("r.alu.inputs_valid: %b", r.alu.inputs_valid);    
    $display("r.alu.alu_input_ack: %b", r.alu.alu_input_ack);

    
    @(posedge clk);
    $display("7");
    $display("clk");
    $display("r.alu_input_A: %b", r.alu_input_A);
    $display("r.alu_input_B: %b", r.alu_input_B);

    $display("r.alu_reg_addr: %b", r.alu_reg_addr);
    $display("r.alu_reg_out: %b", r.alu_reg_out);
    $display("r.alu_op_code: %b", r.alu_op_code);
    $display("r.alu.reg_wr_ack %b", r.alu.reg_wr_ack);
    $display("r.alu.alu_done: %b", r.alu.alu_done);
    $display("r.alu.inputs_valid: %b", r.alu.inputs_valid);    
    $display("r.alu.alu_input_ack: %b", r.alu.alu_input_ack);

    
    @(posedge clk);
    $display("8");
    $display("clk");
    $display("r.alu.input_A: %b", r.alu.input_A);
    $display("r.alu.input_B: %b", r.alu.input_B);
    $display("r.alu.op_code: %b", r.alu.op_code);

    $display("r.alu.reg_wr_addr: %b", r.alu.reg_wr_addr);
    $display("r.alu.reg_wr_data_valid: %b", r.alu.reg_wr_data_valid);
    $display("r.alu.reg_wr_data: %b", r.alu.reg_wr_data);
    $display("r.alu.reg_wr_ack %b", r.alu.reg_wr_ack);
    $display("r.alu.alu_done: %b", r.alu.alu_done);
    $display("r.alu.inputs_valid: %b", r.alu.inputs_valid);    
    $display("r.alu.alu_input_ack: %b", r.alu.alu_input_ack);


    @(posedge clk);
    $display("9");
    $display("clk");
    $display("r.regfile_.wr_data_valid: %b", r.regfile_.wr_data_valid);
    $display("r.regfile_.wr_addr: %b", r.regfile_.wr_addr);
    $display("r.regfile_.registers[wr_addr]: %b", r.regfile_.registers[r.regfile_.wr_addr]);       		
    $display("r.alu.reg_wr_ack %b", r.alu.reg_wr_ack);
	$display("r.alu.alu_done: %b", r.alu.alu_done);
    $display("r.alu.inputs_valid: %b", r.alu.inputs_valid);    
    $display("r.alu.alu_input_ack: %b", r.alu.alu_input_ack);


    @(posedge clk);
    $display("10");
    $display("clk");
    
    assert(r.mem_rd_addr_valid == 1'b1) 
      else $error("r.mem_rd_addr_valid should be %b. it is %b", 
                   1'b1, 
                   r.mem_rd_addr_valid); 
    
    assert(r.reg_rd_addr_a_valid == 1'b0) 
      else $error("r.reg_rd_addr_a_valid should be %b. it is %b", 
                   1'b0, 
                   r.reg_rd_addr_a_valid); 
        $display("r.alu_input_ack: %b", r.alu_input_ack);

    @(posedge clk);
	

    @(posedge clk);
    $display("11");
    $display("clk");    
    assert(r.mem_rd_data == 32'b0000000000100000000000100111111) 
      else $error("r.mem_rd_data should be %b. it is %b", 
                   32'b0000000000100000000000100111111, 
                   r.mem_rd_data); 
    
    assert(r.reg_rd_addr_a_valid == 1'b0) 
      else $error("r.reg_rd_addr_a_valid should be %b. it is %b", 
                   1'b0, 
                   r.reg_rd_addr_a_valid); 

  
    @(posedge clk);
    $display("12");
    $display("clk");
    $display("r.regfile_.rd_data_a_ack: %b", r.regfile_.rd_data_a_ack);
    $display("r.regfile_.rd_data_b_ack: %b", r.regfile_.rd_data_a_ack);

    $display("r.regfile_.rd_data_a: %b", r.regfile_.rd_data_a);
    $display("r.regfile_.rd_data_b: %b", r.regfile_.rd_data_b);
    
    @(posedge clk);
    $display("13");
    $display("clk");
    $display("r.reg_rd_data_a_ack: %b", r.reg_rd_data_a_ack);
    $display("r.reg_rd_data_b_ack: %b", r.reg_rd_data_b_ack);

    $display("r.reg_rd_data_a: %b", r.reg_rd_data_a);
    $display("r.reg_rd_data_b: %b", r.reg_rd_data_b);
    
    
    @(posedge clk);
    $display("14");
    $display("clk");
    $display("r.alu_input_A: %b", r.alu_input_A);
    $display("r.alu_input_B: %b", r.alu_input_B);

    $display("r.alu_reg_addr: %b", r.alu_reg_addr);
    $display("r.alu_reg_out: %b", r.alu_reg_out);
    $display("r.alu_op_code: %b", r.alu_op_code);
    
    $display("r.alu.inputs_valid: %b", r.alu.inputs_valid);    
    $display("r.alu.alu_input_ack: %b", r.alu.alu_input_ack);
    
    
    @(posedge clk);
    $display("15");
    $display("clk");
    $display("r.alu_input_A: %b", r.alu_input_A);
    $display("r.alu_input_B: %b", r.alu_input_B);

    $display("r.alu_reg_addr: %b", r.alu_reg_addr);
    $display("r.alu_reg_out: %b", r.alu_reg_out);
    $display("r.alu_op_code: %b", r.alu_op_code);
    $display("r.alu.alu_done: %b", r.alu.alu_done);
    $display("r.alu.inputs_valid: %b", r.alu.inputs_valid);    
    $display("r.alu.alu_input_ack: %b", r.alu.alu_input_ack);

    
    @(posedge clk);
    $display("16");
    $display("clk");
    $display("r.alu_input_A: %b", r.alu_input_A);
    $display("r.alu_input_B: %b", r.alu_input_B);

    $display("r.alu_reg_addr: %b", r.alu_reg_addr);
    $display("r.alu_reg_out: %b", r.alu_reg_out);
    $display("r.alu_op_code: %b", r.alu_op_code);
    $display("r.alu.reg_wr_ack %b", r.alu.reg_wr_ack);
    $display("r.alu.alu_done: %b", r.alu.alu_done);
    $display("r.alu.inputs_valid: %b", r.alu.inputs_valid);    
    $display("r.alu.alu_input_ack: %b", r.alu.alu_input_ack);

    
    @(posedge clk);
    $display("17");
    $display("clk");
    $display("r.alu.input_A: %b", r.alu.input_A);
    $display("r.alu.input_B: %b", r.alu.input_B);
    $display("r.alu.op_code: %b", r.alu.op_code);

    $display("r.alu.reg_wr_addr: %b", r.alu.reg_wr_addr);
    $display("r.alu.reg_wr_data_valid: %b", r.alu.reg_wr_data_valid);
    $display("r.alu.reg_wr_data: %b", r.alu.reg_wr_data);
    $display("r.alu.reg_wr_ack %b", r.alu.reg_wr_ack);
    $display("r.alu.alu_done: %b", r.alu.alu_done);
    $display("r.alu.inputs_valid: %b", r.alu.inputs_valid);    
    $display("r.alu.alu_input_ack: %b", r.alu.alu_input_ack);


    @(posedge clk);
    $display("18");
    $display("clk");
    $display("r.regfile_.wr_data_valid: %b", r.regfile_.wr_data_valid);
    $display("r.regfile_.wr_addr: %b", r.regfile_.wr_addr);
    $display("r.regfile_.registers[wr_addr]: %b", r.regfile_.registers[r.regfile_.wr_addr]);       		$display("r.alu.reg_wr_ack %b", r.alu.reg_wr_ack);
	$display("r.alu.alu_done: %b", r.alu.alu_done);
    $display("r.alu.inputs_valid: %b", r.alu.inputs_valid);    
    $display("r.alu.alu_input_ack: %b", r.alu.alu_input_ack);


    @(posedge clk);
    $display("19");
    $display("clk");
    
    assert(r.mem_rd_addr_valid == 1'b1) 
      else $error("r.mem_rd_addr_valid should be %b. it is %b", 
                   1'b1, 
                   r.mem_rd_addr_valid); 
    
    assert(r.reg_rd_addr_a_valid == 1'b0) 
      else $error("r.reg_rd_addr_a_valid should be %b. it is %b", 
                   1'b0, 
                   r.reg_rd_addr_a_valid); 
        $display("r.alu_input_ack: %b", r.alu_input_ack);

    @(posedge clk);
	

    @(posedge clk);
    $display("20");
    $display("clk");    
    assert(r.mem_rd_data == 32'b0000000000100000000000100111111) 
      else $error("r.mem_rd_data should be %b. it is %b", 
                   32'b0000000000100000000000100111111, 
                   r.mem_rd_data); 
    
    assert(r.reg_rd_addr_a_valid == 1'b1) 
      else $error("r.reg_rd_addr_a_valid should be %b. it is %b", 
                   1'b1, 
                   r.reg_rd_addr_a_valid); 

    
    //reset = 1'b0;
    
    $finish();
    
  end
  
  */
endmodule