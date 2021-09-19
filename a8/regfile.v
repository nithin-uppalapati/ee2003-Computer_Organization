module regfile(
    input [4:0] rs1,     // address of first operand to read 
    input [4:0] rs2,     // address of second operand
    input [4:0] rd,      // address of register to write
    input [31:0] wdata,  // value to be written
    output [31:0] rv1,   // First read value
    output [31:0] rv2,   // Second read value
    input clk,
    input we,
    input reset
);
    // 
    reg[31:0] reg_mem[31:0];  //declaring a memory(array of regs) for the registers
    
    
    initial $readmemh("reg_init.mem", reg_mem,31,0);
    
    assign rv1 = reg_mem[rs1];   
    assign rv2 = reg_mem[rs2];
    
    always @(posedge clk) begin    
        if(we & !reset ) begin			//added reset for overcoming the 10times execution of first instruction
                reg_mem[rd] = wdata;
        end
    end
              



endmodule
