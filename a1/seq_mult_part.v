//                              -*- Mode: Verilog -*-
// Filename        : seq-mult.v
// Description     : Sequential multiplier
// Author          : Nitin Chandrachoodan

// This implementation corresponds to a sequential multiplier, but
// most of the functionality is missing.  Complete the code so that
// the resulting module implements multiplication of two numbers in
// twos complement format.

// All the comments marked with *** correspond to something you need
// to fill in.

// This style of modeling is 'behavioural', where the desired
// behaviour is described in terms of high level statements ('if'
// statements in verilog).  This is where the real power of the
// language is seen, since such modeling is closest to the way we
// think about the operation.  However, it is also the most difficult
// to translate into hardware, so a good understanding of the
// connection between the program and hardware is important.

`define width 8
`define ctrwidth 4

module seq_mult (
		 // Outputs
		 p, rdy, 
		 // Inputs
		 clk, reset, a, b
		 ) ;
   input 		 clk, reset;
   input signed [`width-1:0] 	 a, b;
   output reg signed [2*`width-1:0]  p;// *** Output declaration for 'p'
   reg flag;
   output		rdy;
   
   // *** Register declarations for p, multiplier, multiplicand
   reg signed [2*`width-1:0] multiplier;
   reg signed [2*`width-1:0] multiplicand ;
//    reg [`width-1:0] a,b;
   reg 			 rdy;
   reg  [`ctrwidth:0]ctr; //
   reg temp;


   always @(posedge clk or posedge reset)
     if (reset) begin
		rdy 		<= 0;
		p 			<= 0;
		ctr 		<= 0;
		flag		<=0;
		multiplier 	<= {{`width{a[`width-1]}}, a}; // sign-extend
//???---> have a doubt here, is it necessary to do sign extension...?
		multiplicand 	<= {{`width{b[`width-1]}}, b}; // sign-extend

     end else begin //  ### determines the number of clock cycles needed 
	if (ctr < 2*`width/* *** How many times should the loop run? */ ) 
	  begin
	     // *** Code for multiplication

		multiplicand <= (multiplicand)<<<1;
		multiplier   <= (multiplier)>>>1;

		if (multiplier[0]) begin // ressembles a mux
			p = p + multiplicand;
		end


		ctr = ctr+1;
	  end else begin
	    rdy <= 1; 		// Assert 'rdy' signal to indicate end of multiplication
		// p={{2*`width-1{p[2*`width-1]}}, p};


	  end
     end
	 
endmodule // seqmult
