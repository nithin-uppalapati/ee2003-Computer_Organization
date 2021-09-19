`timescale 1ns/1ps

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
    reg [31:0] iaddr;
    reg [31:0] daddr;
    reg [31:0] dwdata;
    reg [3:0]  dwe;

    always @(posedge clk) begin
        if (reset) begin
            iaddr <= 0;
            daddr <= 0;
            dwdata <= 0;
            dwe <= 0;
        end else begin 
            iaddr <= iaddr + 4;
        end
    end

////-------

wire [4:0]  xs1;       /// address of xv1
wire [4:0]  xs2;       /// address of xv2
wire [5:0]  op;        /// opcode of instruction // opcode is unique for each instruction (see dummydecoder.v)
wire [4:0]  xd;        /// data to be written to registers
wire        xwe;       /// write enable for x 2darray - GPRs
wire [31:0] xv1;       /// operand1 data to be read from registers
wire [31:0] xv2;       /// either a reg_value or immediate to alu
wire [31:0] x_xv2;     /// operand2 data to be read from registers
wire [31:0] aluout;    // Output of ALU
reg [31:0] xwdata;     // Data written in GPRs
// reg [31:0] xdata;
// wire [31:0] xdata;

// dummydecoder decocoder(idata,op,xs1,xs2,xd,x_xv2,xv2,xwe);
// alu32 alu(op,xv1,xv2,aluout);
// regfile gprs(reset,xs1,xs2,xd,xwe,xwdata,xv1,x_xv2,clk);

dummydecoder decoder(
    .instr(idata),  // Full 32-b instruction
    .op(op),        // some operation encoding of your choice
    .rs1(xs1),      // First operand reg address to reg file
    .rs2(xs2),      // Second operand (reg address) to reg file
    .rd(xd),        // Output reg (address)
    .r_rv2(x_xv2),  // From RegFile
    .rv2(xv2),      // To ALU
    .we(xwe)        // Write to reg (to reg file)
);

alu32 alu(
    .op(op),        
    .rv1(xv1),      // First operand
    .rv2(xv2),      // Second operand
    .rvout(aluout)  // Output value
);

regfile gprs(
    .reset(reset),
    .rs1(xs1),          // address of first operand to read - 5 bits
    .rs2(xs2),          // address of second operand
    .rd(xd),            // address of value to write
    .we(xwe),           // should write update occur
    .wdata(xwdata),     // value to be written
    .rv1(xv1),          // First read value
    .rv2(x_xv2),        // Second read value
    .clk(clk)           // Clock signal - all changes at clock posedge
);

always@(*)
begin
    if (op<='d18 | op>='d24)
    begin
        xwdata <= aluout;
    end
end



always@(*)
begin
    case(op)
//        LB - Load Byte
    'd19 :  begin   dwe = 0;  daddr = xv1 + xv2; //end // $signed(xv2); does this make any difference...?
                    xwdata = drdata >> (8*daddr[1:0]);
                    xwdata = ( {{24{xwdata[7]}}, xwdata[7:0]} );
            end

//        LH - Load HalfWord
    'd20 :  begin   dwe = 0; daddr = xv1 + xv2; //end // $signed(xv2)
                    xwdata = drdata;
                    xwdata = xwdata >> (8*daddr[1:0]);
                    xwdata = ({ {16{xwdata[15]}},xwdata[15:0] } );
            end

//        LW - Load Word    
    'd21 :  begin   dwe = 0; daddr = xv1 + xv2; xwdata = drdata; end // $signed(xv2)

//        LBU- Load Byte Unsigned
    'd22 :  begin   dwe = 0; daddr = xv1 + xv2;
                    xwdata = drdata >> (8*daddr[1:0]) ;
                    xwdata = ( {{24{1'b0}} ,xwdata[7:0]} );
            end

//        LHU- Load HalfWord Unsigned
    'd23 :  begin   dwe = 0; daddr = xv1 + xv2; 
                    xwdata = drdata >> (8*daddr[1:0]);
                    xwdata = ( {{16{1'b0}},xwdata[15:0]} );
            end

//        SB - Store Byte
    'd24 :  begin   daddr = xv1 + ( { {20{idata[31]}}, idata[31:25] ,idata[11:7] } ); // $signed
                    dwe = 4'b0001 << daddr[1:0];
                    dwdata = xv2 << (8*daddr[1:0]) ;
            end

//        SH - Store HalfWord
    'd25 :  begin   daddr = xv1 + ( { {20{idata[31]}}, idata[31:25] ,idata[11:7] } );
                    dwe = 4'b0011 << (2*daddr[1]);
                    dwdata = xv2 << (16*daddr[1]) ;
            end

//        SW - Store Word
    'd26 :  begin   dwe = 4'b1111; daddr = xv1 + ( { {20{idata[31]}}, idata[31:25] ,idata[11:7] } ); 
                    dwdata = xv2;
            end
    endcase                        
end

endmodule
