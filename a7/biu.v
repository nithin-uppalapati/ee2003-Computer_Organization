`timescale 1ns/1ps
// Bus interface unit: assumes two branches of the bus -
// 1. connect to dmem
// 2. connect to a single peripheral
// The BIU needs to know the addresses at which DMEM and peripheral are
// connected, so it can do the required multiplexing. 
// These need to be added as part of your code. 
module biu (
    input clk,
    input reset,
    input [31:0] daddr,
    input [31:0] dwdata,
    input [3:0] dwe,
    output [31:0] drdata,

    // Signals going to/from dmem
    output [31:0] daddr1,
    output [31:0] dwdata1,
    output [3:0]  dwe1,
    input  [31:0] drdata1,

    // Signals going to/from peripheral
    output [31:0] daddr2,
    output [31:0] dwdata2,
    output [3:0]  dwe2,
    input  [31:0] drdata2
);

    // Modify below so that depending on the actual daddr range the BIU decides whether 
    // the response was from DMEM or peripheral - maybe a MUX?
    // assign drdata = drdata1;

    reg [31:0] drdata;
    reg [31:0] daddr1;
    reg [31:0] daddr2;
    reg [31:0] dwdata1;
    reg [31:0] dwdata2;
    reg [3:0] dwe1;
    reg [3:0] dwe2;

    always@(*) // reading data from peripheral/dmem
    begin
        daddr1 = daddr;
        daddr2 = daddr;
        if(daddr1<'d214368) begin
            drdata =drdata1; end

        if(daddr2>'d214368) begin  //////////////FIX THIS ADDRESS of PERIPHERAL
            drdata =drdata2; end
    end

    always@(*) // writing data into peripheral/dmem
    begin
        if(daddr1<'d214368) begin
            dwdata1 = dwdata; 
            dwe1 = dwe; dwe2 = 3'b000; end

        if(daddr2>'d214368) begin  //////////////FIX THIS ADDRESS of PERIPHERAL
            dwdata2 = dwdata; 
            dwe2 = dwe; dwe1 = 3'b000; end
    end


    // Send values to DMEM or peripheral (or both if it does not matter)
    // as required
    // assign daddr1 = daddr;
    // assign dwdata1 = dwdata;
    // assign dwe1 = dwe;

    // assign daddr2 = daddr;
    // assign dwdata2 = dwdata;
    // assign dwe2 = dwe;

endmodule