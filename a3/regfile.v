module regfile(
    input [4:0] rs1,     // address of first operand to read - 5 bits
    input [4:0] rs2,     // address of second operand
    input [4:0] rd,      // address of value to write
    input we,            // should write update occur
    input [31:0] wdata,  // value to be written
    output [31:0] rv1,   // First read value
    output [31:0] rv2,   // Second read value
    input clk            // Clock signal - all changes at clock posedge
);
    // Desired function
    // rv1, rv2 are combinational outputs - they will update whenever rs1, rs2 change
    // on clock edge, if we=1, regfile entry for rd will be updated
    
    reg [31:0] x[31:0]; // x is a 32x32 memory array with x[0] as 0x00000000 - hardwired

    integer i;

    initial
    begin
       for(i=0;i<32;i++)
       begin
         x[i] = 32'b0;
       end
    end


always@(posedge clk)
    begin
        if (we)
        begin
            x[rd] <= wdata; 
            x[0]  <= 32'b0;
        end
    end

// always @(rs1 or rs2)

    assign rv1  = x[rs1];
    assign rv2  = x[rs2];



endmodule