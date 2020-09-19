module dummydecoder(
    input [31:0] instr,  // Full 32-b instruction
    output [5:0] op,     // some operation encoding of your choice
    output [4:0] rs1,    // First operand reg address
    output [4:0] rs2,    // Second operand (reg address)
    output [4:0] rd,     // Output reg (address)
    input  [31:0] r_rv2, // From RegFile
    output [31:0] rv2,   // To ALU
    output we            // Write to reg
);
reg [31:0] rv2;
reg [4:0] rs1,rs2,rd;
reg [5:0] op;

always@(*)
    begin
        if ( ~instr[5] & (instr[13] | ~instr[12]) )
        begin
            rs1 = instr[19:15];
            rd = instr[11:7];
            // rs2 = instr[24:20]; No rs2 for immediate instructions
            op = {1'b0,1'b1,instr[14:12],instr[5]}; // assigning the values for opcode for ALU
            // format for opcode [0,1,code,I[5]]
        end

        if ( ~instr[5] & (~instr[13] & instr[12]) )
        begin
            rs1 = instr[19:15];
            rd = instr[11:7];
            // rs2 = instr[24:20]; No rs2 for immediate instructions
            op = {1'b0,instr[30],instr[14:12],instr[5]}; // assigning the values for opcode for ALU
            // format for opcode [0,I[30],code,I[5]]
        end

        if ( instr[5] )
        begin
            rs1 = instr[19:15];
            rd = instr[11:7];
            rs2 = instr[24:20];
            op = {1'b0,instr[30],instr[14:12],instr[5]}; // assigning the values for opcode for ALU
            // format for opcode [0,I[30],code,I[5]]
        end

    end


always@(*)
    begin

        if( ~instr[5] )
        begin
            rv2= { {20{instr[31]}} ,instr[31:20] }; // sign extension of the signed immediate
            // op[4]= 1'b1;
        end

        else
        begin
            rv2= r_rv2;  // from regfile to ALU
        end

    end



    assign we = 1;      // For only ALU ops, can always set to 1 (write enable)
    // assign rv2 = 'h0;   // Should send either the value from the RegFile or the Imm value from Instr

endmodule
