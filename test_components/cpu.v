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

////-------

wire [4:0]  xs1;
wire [4:0]  xs2;
wire [5:0]  op;
wire [4:0]  xd;
wire        xwe;       /// write enable for x 2darray - GPRs
wire [31:0] xv1;
wire [31:0] xv2;
wire [31:0] x_xv2;
wire [31:0] aluout;
reg [31:0] xwdata;
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

////-------

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
        end 

        else if ( (op>= 'd29) & (op<='d36) )
        begin
            case(op)

            'd29 : iaddr <= iaddr + xv2  ;
            
            'd30 : iaddr <= xv1 + xv2  ;

            'd31 : begin if(xv1 == xv2)   begin // should we check this condition before or after the clock cycle...???????
                                    iaddr <= iaddr + ({ {20{idata[31]}} , idata[7], idata[30:25], idata[11:8], {1'b0}}) ; 
                                    end
                         else begin iaddr <= iaddr + 4; end
                    end

            'd32 : begin if(xv1 != xv2)   begin // should we check this condition before or after the clock cycle...???????
                                    iaddr <= iaddr + ( { {20{idata[31]}} , idata[7], idata[30:25], idata[11:8], {1'b0}} ); 
                                    end
                         else begin iaddr <= iaddr + 4; end
                    end

            'd33 : begin if( $signed(xv1) < $signed(xv2) )  begin // should we check this condition before or after the clock cycle...???????
                    iaddr <= (iaddr + ( { {20{idata[31]}} , idata[7], idata[30:25], idata[11:8], {1'b0}} ) ); 
                    end
                        else begin iaddr <= iaddr + 4; end
                    end

            'd34 : begin if( $signed(xv1) >= $signed(xv2) ) begin // should we check this condition before or after the clock cycle...???????
                    iaddr <= (iaddr + ( { {20{idata[31]}} , idata[7], idata[30:25], idata[11:8], {1'b0}} ) ); 
                    end
                    else begin iaddr <= iaddr + 4; end
                    end

            'd35 : begin if( xv1 < xv2 )  begin // should we check this condition before or after the clock cycle...???????
                                    iaddr <= (iaddr + ( { {20{idata[31]}} , idata[7], idata[30:25], idata[11:8], {1'b0}} ) ); 
                                    end
                        else begin iaddr <= iaddr + 4; end
                    end

            'd36 : begin if( xv1 >= xv2 ) begin // should we check this condition before or after the clock cycle...???????
                                    iaddr <= (iaddr + ( { {20{idata[31]}} , idata[7], idata[30:25], idata[11:8], {1'b0}} ) ); 
                                    end
                        else begin iaddr <= iaddr + 4; end
                    end
            
            endcase
        end

        else 
        begin
                begin iaddr <= iaddr + 4; end
        end

    end



always@(*)
begin
    if (op<='d18)
    begin
        xwdata <= aluout;
        dwe <= 0;
    end
end



always@(*)
begin
    case(op)
    'd19 :  begin   dwe = 0;  daddr = xv1 + xv2; //end // $signed(xv2); does this make any difference...?
                    xwdata = drdata >> (8*daddr[1:0]);
                    xwdata = ( {{24{xwdata[7]}}, xwdata[7:0]} );
            end

    'd20 :  begin   dwe = 0; daddr = xv1 + xv2; //end // $signed(xv2)
                    xwdata = drdata;
                    xwdata = xwdata >> (16*daddr[1:0]);
                    xwdata = ({ {16{xwdata[15]}},xwdata[15:0] } );
            end
        
    'd21 :  begin   dwe = 0; daddr = xv1 + xv2; xwdata = drdata; end // $signed(xv2)

    'd22 :  begin   dwe = 0; daddr = xv1 + xv2;
                    xwdata = drdata >> (8*daddr[1:0]) ;
                    xwdata = ( {{24{1'b0}} ,xwdata[7:0]} );
            end

    'd23 :  begin   dwe = 0; daddr = xv1 + xv2; 
                    xwdata = drdata >> (16*daddr[1:0]);
                    xwdata = ( {{16{1'b0}},xwdata[15:0]} );
            end

    'd24 :  begin   daddr = xv1 + ( { {20{idata[31]}}, idata[31:25] ,idata[11:7] } ); // $signed
                    dwe = 4'b0001 << daddr[1:0];
                    dwdata = xv2 << (8*daddr[1:0]);
                    xwdata <= aluout;
            end

    'd25 :  begin   daddr = xv1 + ( { {20{idata[31]}}, idata[31:25] ,idata[11:7] } );
                    dwe = 4'b0011 << (2*daddr[1]);
                    dwdata = xv2 << (16*daddr[1]) ;
                    xwdata <= aluout;
            end

    'd26 :  begin   dwe = 4'b1111; daddr = xv1 + ( { {20{idata[31]}}, idata[31:25] ,idata[11:7] } ); 
                    dwdata = xv2;
                    xwdata <= aluout;
            end
////
    'd27 :  begin   dwe <= 0; xwdata <= ({idata[31:12], xv1[11:0]});
            end

    'd28 :  begin   dwe <= 0; xwdata <= iaddr + ({ idata[31:12], xv1[11:0] });
            end

    'd29 :  begin   dwe <= 0; xwdata <= iaddr + 4;
            end

    'd30 :  begin   dwe <= 0; xwdata <= iaddr + 4;
            end

    'd31 :  begin   dwe <= 0;
            end

    'd32 :  begin   dwe <= 0;
            end

    'd33 :  begin   dwe <= 0;
            end

    'd34 :  begin   dwe <= 0;
            end

    'd35 :  begin   dwe <= 0;
            end

    'd36 :  begin   dwe <= 0;
            end

    'd63 :  begin   dwe <= 0; //default case handling
            end

    endcase                        
end

endmodule
