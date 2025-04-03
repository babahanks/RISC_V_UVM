# RISC_V_UVM


The design under test is "risc_v_circuit".  This constists of "risc_v" that is connected to "memory".  The top module in testbech is "risc_test_top"

The testbench starts with loading randomly generated RISC R and B instructions into the memory.  
This is done in "risc_test".  
This is done using:
  - risc_instruction
  - risc_r_instruction
  - risc_b_instruction
  - (risc_i_instruction is being worked on)

These instructions are read from the memory by "risc_inst_sequence" and expanded into class objects usingg the following:
  - risc_inst_seq_item
  - risc_r_inst_seq_item
  - risc_b_inst_seq_item
    
Each seq item has a test to see if the instruction was handled properly by risc_v.

The seq_items are sent to "risc_test_driver".  The driver synchronizes with the risc code by skipping CLK cycles till the risc code goes for the next instruction.  THis depends on the type of instruction and the seq_item has a "getting_next_instruction" method to get that signal.

When the raic_v has executed the instruction, seq_item checks if it has been executed correctly.  
The seq_item is then passed to "risc_scoreboard".  It keeps a score of how many were executed correctly.


