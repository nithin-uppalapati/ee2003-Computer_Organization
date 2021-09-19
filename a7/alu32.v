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
    'd0  : rvout <= rv1 + rv2;                                     // 1        ADDI
    'd1  : rvout <= {{31{1'b0}}, ($signed(rv1) < $signed(rv2))};   // 2        SLTI
    'd2  : rvout <= {{31{1'b0}}, (rv1 < rv2) };                    // 3        SLTIU
    'd3  : rvout <= rv1 ^ rv2;                                     // 4        XORI
    'd4  : rvout <= rv1 | rv2;                                     // 5        ORI
    'd5  : rvout <= rv1 & rv2;                                     // 6        ANDI
    'd6  : rvout <= rv1 << rv2[4:0];                               // 7        SLLI
    'd7  : rvout <= rv1 >> rv2[4:0];                               // 8        SRLI
    'd8  : rvout <= $signed(rv1) >>> rv2[4:0];                     // 9        SRAI ...
    'd9  : rvout <= rv1 + rv2;                                     // 10       ADD
    'd10 : rvout <= rv1 - rv2;                                     // 11       SUB
    'd11 : rvout <= rv1 << rv2[4:0];                               // 12       SLL
    'd12 : rvout <= { {31{1'b0}}, ($signed(rv1) < $signed(rv2))};  // 13       SLT
    'd13 : rvout <= { {31{1'b0}}, (rv1 < rv2) };                   // 14       SLTU
    'd14 : rvout <= rv1 ^ rv2;                                     // 15       XOR
    'd15 : rvout <= rv1 >> rv2[4:0];                               // 16       SRL
    'd16 : rvout <= $signed(rv1) >>> rv2[4:0];                     // 17       SRA          is signed necessary here ....?
    'd17 : rvout <= rv1 | rv2;                                     // 18       OR
    'd18 : rvout <= rv1 & rv2;                                     // 19       AND
    default : rvout <= 0;
    endcase                                 
end

endmodule