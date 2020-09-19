module alu32(
    input [5:0] op,      // some input encoding of your choice
    input [31:0] rv1,    // First operand
    input [31:0] rv2,    // Second operand
    output [31:0] rvout  // Output value
);

// ALU is a combinational block, no clk inputs
// write case statements...
reg [31:0] rvout;

always @(*)
begin
    case(op)
    // format for opcode [0,I[30],code,I[5]]

    6'b010000 : rvout <= rv1 + rv2;                                     // 1        ADDI
    6'b010100 : rvout <= {{31{1'b0}}, ($signed(rv1) < $signed(rv2))};   // 2        SLTI
    6'b010110 : rvout <= {{31{1'b0}}, (rv1 < rv2) };                    // 3        SLTIU
    6'b011000 : rvout <= rv1 ^ rv2;                                     // 4        XORI
    6'b011100 : rvout <= rv1 | rv2;                                     // 5        ORI
    6'b011110 : rvout <= rv1 & rv2;                                     // 6        ANDI
    6'b000010 : rvout <= rv1 << rv2[4:0];                               // 7        SLLI
    6'b001010 : rvout <= rv1 >> rv2[4:0];                               // 8        SRLI
    6'b011010 : rvout <= $signed(rv1) >>> rv2[4:0];                              // 9        SRAI
    6'b000001 : rvout <= rv1 + rv2;                                     // 10       ADD
    6'b010001 : rvout <= rv1 - rv2;                                     // 11       SUB
    6'b000011 : rvout <= rv1 << rv2[4:0];                               // 12       SLL
    6'b000101 : rvout <= { {31{1'b0}}, ($signed(rv1) < $signed(rv2))};     // 13       SLT
    6'b000111 : rvout <= { {31{1'b0}}, (rv1 < rv2) };                    // 14       SLTU
    6'b001001 : rvout <= rv1 ^ rv2;                                     // 15       XOR
    6'b001011 : rvout <= rv1 >> rv2[4:0];                               // 16       SRL
    6'b011011 : rvout <= $signed(rv1) >>> rv2[4:0];                              // 17       SRA          is signed necessary here ....?
    6'b001101 : rvout <= rv1 | rv2;                                     // 18       OR
    6'b001111 : rvout <= rv1 & rv2;                                     // 19       AND
    endcase                                 
end


    // assign rvout = 'haabbccdd;  // What does this do exactly...?

endmodule
