module cpu (
    input clk, 
    input reset,
    output [31:0] iaddr,
    input [31:0] idata,
    output [31:0] daddr,
    input [31:0] drdata,
    output [31:0] dwdata,
    output [3:0] dwe
);
//reg declarations
    reg[31:0] alu_buff_op;                  //buffer reg for alu ops result
    reg[31:0] alui_buff_op;                 //buffer reg for alui ops result
    reg[31:0] ld_buff_op;                   //buffer reg for load ops result
    reg[31:0] iaddr;        

//wire declarations

    wire [6:0] op;              // opcode
    wire [3:0] funct;           // funct3
    wire [4:0] rs1;             // rs1 - first operand register number
    wire [4:0] rs2;             // rs2 - second operand register number
    wire [4:0] rd;              // rd - destination register number
    wire [31:0] imm_val;        // immediate value for ALU ops
    wire [31:0] imm_val_s;      // immediate value for store operation
    wire [31:0] imm_val_cb;     // immediate value for cond. branching instructions
    wire [31:0] imm_val_ui;     // immediate value for UI instructions
    wire [31:0] imm_val_jmp;    // immediate value for JAL instruction
    wire [31:0] rv1;            // first operand value
    wire [31:0] rv2;            // second operand value
    wire [31:0] rvout;          // output of the instruction
    wire we;                    // write enable for reg file
    wire [31:0] drdata_buff;    // Buffer for assigning bytes
    wire [31:0] iaddr_buff;     // buffer reg for iaddr calc.
    wire [31:0] branch_addr;    // buffer reg for branch addr calc.
    
// module instantiations 
    decoder u1 (                       //instantiating the decoder module              
        .instr(idata),
        .op(op),
        .funct3(funct),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .imm_val(imm_val),
        .imm_val_s(imm_val_s),
        .imm_val_cb(imm_val_cb),
        .imm_val_ui(imm_val_ui),
        .imm_val_jmp(imm_val_jmp)
        );

    regfile u2 (                        //instantiating the regfile module                 
        .rv1(rv1),
        .rv2(rv2),
        .rd(rd),
        .rs2(rs2),
        .rs1(rs1),
        .we(we),
        .clk(clk),
        .wdata(rvout),
        .reset(reset)                               
        );


// Continuous assignment statements


    assign we =( ( op == 7'b0110011 | op == 7'b0010011 | op == 7'b0000011 | op == 7'b0110111 |
                  op == 7'b0010111 | op == 7'b1101111 | op == 7'b1100111 ) && (rd !== 5'b0)) ? 1'b1 : 1'b0;   // write enable for regfile ==> (ALU | ALUI | LD | LUI | AUIPC | JAL | JALR)
    

    assign dwe = (reset) ? 0 : (op != 7'b0100011) ? 0 : (funct[2:0] == 3'b010) ? 4'b1111 :
                   (funct[2:0] == 3'b001) ? {daddr[1], daddr[1], !daddr[0], !daddr[0]} :
                   (funct[2:0] == 3'b000) ? {(daddr[0]&daddr[1]), (daddr[1] & !daddr[0]), 
                    (!daddr[1] & daddr[0]), (!daddr[0] & !daddr[1]) } : 4'b0;                                 //setting dwe depending on the store condition.
    
    /*assign drdata_buff = (daddr[1:0] == 2'b00) ? drdata :
                     (daddr[1:0] == 2'b01) ? (drdata >> 8) :
                     (daddr[1:0] == 2'b10) ? (drdata >> 16) :
                     (daddr[1:0] == 2'b11) ? (drdata >>24) : 0;*/

    assign drdata_buff = (daddr[1:0] == 2'b0) ? drdata : (drdata << (daddr[1:0] * 8)) ;                       //loading the byte corresponding to the daddr


    assign dwdata = (daddr[1:0] == 2'b0) ? rv2 : (rv2 << (daddr[1:0] * 8)) ;


    assign daddr = (op == 7'b0000011) ? (rv1 + imm_val) : (op == 7'b0100011) ? (rv1 + imm_val_s) : 0 ;

    assign rvout = (op == 7'b0110011) ? alu_buff_op :                           //ALU
                    (op == 7'b0010011) ? alui_buff_op :                         //ALUI
                    (op == 7'b0000011) ? ld_buff_op :                           //LOAD
                    (op == 7'b0110111) ? imm_val_ui :                           //LUI
                    (op == 7'b0010111) ? iaddr + imm_val_ui :                   //AUIPC
                    (op == 7'b1101111 | op == 7'b1100111) ? (iaddr + 4) : 0;  //JAL,JALR and default case


    assign branch_addr = (funct[2:0] == 3'b000 & rv1 == rv2) ? imm_val_cb :                             //BEQ
                            (funct[2:0] == 3'b001 & rv1 != rv2) ? imm_val_cb :                          //BNE
                            (funct[2:0] == 3'b100 & rv1 < rv2) ? imm_val_cb :                           //BLT
                            (funct[2:0] == 3'b101 & rv1 >= rv2) ? imm_val_cb :                          //BGE
                            (funct[2:0] == 3'b110 & $unsigned(rv1) < $unsigned(rv2)) ? imm_val_cb :     //BLTU
                            (funct[2:0] == 3'b111 & $unsigned(rv1) >= $unsigned(rv2)) ? imm_val_cb : 4; //BGEU


    assign iaddr_buff = (op == 7'b1100011) ? (iaddr + branch_addr) :                //Branch
                        (op == 7'b1101111) ? (iaddr + imm_val_jmp) :                //JAL
                        (op == 7'b1100111) ? ((rv1+$signed(imm_val))&32'hffff_fffe) :   //JALR
                        (iaddr + 4);


// Procedural blocks
    //ALU
    always @(*) begin
        case(funct)
                4'b0000 : alu_buff_op = rv1 + rv2;                                          //ADD
                4'b1000 : alu_buff_op = rv1 + ((~rv2)+1);                                   //SUB
                4'b0001 : alu_buff_op = rv1 << rv2;                                         //SLL
                4'b0010 : alu_buff_op = ($signed(rv1) < $signed(rv2)) ? 1 : 0;              //SLT
                4'b0011 : alu_buff_op = ($unsigned(rv1) < $unsigned(rv2)) ? 1 : 0;         //SLTU
                4'b0100 : alu_buff_op = rv1 ^ rv2;                                          //XOR
                4'b0101 : alu_buff_op = rv1 >> rv2;                                         //SRL
                4'b1101 : alu_buff_op = rv1 >>> rv2;                                        //SRA
                4'b0110 : alu_buff_op = rv1 | rv2;                                          //OR
                4'b0111 : alu_buff_op = rv1 & rv2;                                          //AND
                default : alu_buff_op = 32'bx;                                              //EXCEPTION
            endcase
    end

    //ALUI
    always @(*) begin
        casez(funct)
                4'b?000 : alui_buff_op = rv1 + imm_val;                                          //ADDUI
                4'b0001 : alui_buff_op = rv1 << rs2;                                             //SLLI
                4'b?010 : alui_buff_op = ($signed(rv1) < $signed(imm_val)) ? 1 : 0;              //SLTI
                4'b?011 : alui_buff_op = ($unsigned(rv1) < $unsigned(imm_val)) ? 1 : 0;          //SLTUI              
                4'b?100 : alui_buff_op = rv1 ^ imm_val;                                          //XORI
                4'b0101 : alui_buff_op = rv1 >> rs2;                                             //SRLI
                4'b1101 : alui_buff_op = rv1 >>> rs2;                                            //SRAI
                4'b?110 : alui_buff_op = rv1 | imm_val;                                          //ORI
                4'b?111 : alui_buff_op = rv1 & imm_val;                                          //ANDI
                default : alui_buff_op = 32'bx;                                                  //Exception
            endcase
    end

    //Load
    always @(drdata_buff) begin
        case(funct[2:0]) 
                3'b000 : ld_buff_op = {{24{drdata_buff[7]}},drdata_buff[7:0]};                          //LB
                3'b001 : ld_buff_op = {{16{drdata_buff[15]}},drdata_buff[15:0]} ;                       //LH
                3'b010 : ld_buff_op = drdata_buff;                                                      //LW
                3'b100 : ld_buff_op = {24'b0,drdata_buff[7:0]} ;                                        //LBU
                3'b101 : ld_buff_op = {16'b0,drdata_buff[15:0]} ;                                       //LHU
                default : ld_buff_op = 32'b0;                                                           //Exception
            endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            iaddr = 0;
        end 
        else begin 
            iaddr = iaddr_buff;  
        end
    end

endmodule
