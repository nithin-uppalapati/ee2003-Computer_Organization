module decoder(
    input [31:0] instr, //32 instruction
    output [6:0] op,    //7 bit opcode for finding the type of instruction 
    output [3:0] funct3, //for deciding the specific instruction
    output [4:0] rs1,   //First operand register number
    output [4:0] rs2,   //second operand register number
    output [4:0] rd,    //destination register
    output [31:0] imm_val_s, //immedediate value from the instruction for store instructions
    output [31:0] imm_val, //immedediate value from the instruction for ALU instructions
    output [31:0] imm_val_cb,  //immediate value from the instruction for the cond. branching instructions
    output [31:0] imm_val_ui,   //immediate value for the upper immediate instructions i.e, LUI and AUIPC 
    output [31:0] imm_val_jmp   //immediate value for the JAL instruction
);
    assign op = instr[6:0];
    assign funct3 = {instr[30],instr[14:12]};
    assign rs1 =  instr[19:15];
    assign rs2 =  instr[24:20];
    assign rd = instr[11:7];
    assign imm_val_s = {{20{instr[31]}},{instr[31:25]},{instr[11:7]}};              //imm value for store instr
    assign imm_val = {{20{instr[31]}},{instr[31:20]}};                            //imm value for alu instr
    assign imm_val_cb = {{19{instr[31]}},{instr[31]},{instr[7]},{instr[30:25]},{instr[11:8]},1'b0}; //imm value for conditional branching(signed-13)
    assign imm_val_ui = {{instr[31:12]},{12{1'b0}}};
    assign imm_val_jmp = {{12{instr[31]}},{instr[19:12]},{instr[20]},{instr[30:21]},{1'b0}};    
    // 
endmodule