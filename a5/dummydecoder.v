module dummydecoder(
    input [31:0] instr,  // Full 32-b instruction
    output [5:0] op,     // some operation encoding of your choice
    output [4:0] rs1,    // First operand reg address to reg file
    output [4:0] rs2,    // Second operand (reg address) to reg file
    output [4:0] rd,     // Output reg (address)
    input  [31:0] r_rv2, // From RegFile
    output [31:0] rv2,   // To ALU
    output we            // Write to reg (to reg file)
);
reg [31:0] rv2;
reg [4:0] rs1,rs2,rd;
reg [5:0] op;
reg we;


always@(*)
begin

        rs1 = instr[19:15];
        rd = instr[11:7];
        rs2 = instr[24:20];

        case({instr[14:12],instr[6:0]})
        10'b000_0010011: begin op <= 6'd0; we<=1; end//         ADDI
        10'b010_0010011: begin op <= 6'd1; we<=1; end//         SLTI
        10'b011_0010011: begin op <= 6'd2; we<=1; end//         SLTIU
        10'b100_0010011: begin op <= 6'd3; we<=1; end//         XORI
        10'b110_0010011: begin op <= 6'd4; we<=1; end//         ORI
        10'b111_0010011: begin op <= 6'd5; we<=1; end//         ANDI
        10'b001_0010011: begin op <= 6'd6; we<=1; end//         SLLI
        10'b101_0010011: begin if(instr[30]) begin op <= 6'd8; we<=1; end //        SRAI
                               else          begin op <= 6'd7; we<=1; end //        SRLI
                         end
        endcase

        case({instr[30],instr[14:12],instr[6:0]})
        11'b0_000_0110011: begin op <= 6'd9 ; we<=1; end//       ADD
        11'b1_000_0110011: begin op <= 6'd10; we<=1; end//       SUB
        11'b0_001_0110011: begin op <= 6'd11; we<=1; end//       SLL
        11'b0_010_0110011: begin op <= 6'd12; we<=1; end//       SLT
        11'b0_011_0110011: begin op <= 6'd13; we<=1; end//       SLTU
        11'b0_100_0110011: begin op <= 6'd14; we<=1; end//       XOR
        11'b0_101_0110011: begin op <= 6'd15; we<=1; end//       SRL
        11'b1_101_0110011: begin op <= 6'd16; we<=1; end//       SRA
        11'b0_110_0110011: begin op <= 6'd17; we<=1; end//       OR
        11'b0_111_0110011: begin op <= 6'd18; we<=1; end//       AND
        endcase

        case({instr[14:12],instr[6:0]})
        10'b000_0000011 : begin op <= 6'd19; we<=1;   end//        LB - Load Byte
        10'b001_0000011 : begin op <= 6'd20; we<=1;   end//        LH - Load HalfWord
        10'b010_0000011 : begin op <= 6'd21; we<=1;   end//        LW - Load Word
        10'b100_0000011 : begin op <= 6'd22; we<=1;   end//        LBU- Load Byte Unsigned
        10'b101_0000011 : begin op <= 6'd23; we<=1;   end//        LHU- Load HalfWord Unsigned
        10'b000_0100011 : begin op <= 6'd24; we<=0;   end//        SB - Store Byte
        10'b001_0100011 : begin op <= 6'd25; we<=0;   end//        SH - Store HalfWord
        10'b010_0100011 : begin op <= 6'd26; we<=0;   end//        SW - Store Word
        endcase

end

always@(*) // sending either immediate or reg contents to alu
    begin

        if( ~( (instr[6:0]==7'b1100011) || (instr[6:0]==7'b0100011) || (instr[6:0]==7'b0110011) ) )
        begin
            rv2 = ({ {20{instr[31]}} ,instr[31:20] }); // sign extension of the signed immediate /// considering SLLI,SRLI,SRAI under this categ.
            // op[4]= 1'b1;
        end

        else
        begin
            rv2 = r_rv2;  // from regfile to ALU
        end

    end

endmodule



// always@(*)
// case(instr[6:0])
// 7'b0110111 :  we <= 1'b1;
// 7'b0010111 :  we <= 1'b1;
// 7'b1101111 :  we <= 1'b1;
// 7'b1100111 :  we <= 1'b1;
// 7'b1100011 :  we <= 1'b0;
// 7'b0000011 :  we <= 1'b1;
// 7'b0100011 :  we <= 1'b0;
// 7'b0010011 :  we <= 1'b1;
// 7'b0110011 :  we <= 1'b1;
// 7'b0001111 :  we <= 1'b1;
// 7'b1110011 :  we <= 1'b1;
// endcase


 