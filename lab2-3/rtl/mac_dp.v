`include "senior_defines.vh"

// A real project would probably parameterize the width of the various
// input and output signals, but for TSEA26 it is probably easier if
// we hard code the RF bus as 16 bits and the accumulators as 40 bits.
module mac_dp
   (input wire 			     clk_i, reset_i,

    input wire [2:0] 	     c_scalefactor,
    input wire [3:0] 	     c_macop,
    input wire 		     c_dosat,

    input wire [39:0] 	     mac_operanda,mac_operandb, // From ACR/RF
    input wire signed [16:0] mul_opa_reg,mul_opb_reg, // From multiplier

    output wire 	     scale_overflow, // 1 if overflow during scaling
    output wire 	     sat_flag, // 1 if data was saturated
    output wire [39:0] 	     mac_result, // macunit output data
    
    output wire 	     add_pos_overflow, // positive overflow
    output wire 	     add_neg_overflow   // negative overflow
    );


   reg signed [33:0] 	     mul_sig;

   reg [39:0] adr_opbrnd_sig, adder_opb, adder_opa, to_scaling,
              adder_result, mul_guarded_reg, round_result;
   reg 				     adder_cin;
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [39:0]		from_scaling;		// From scaling of mac_scale.v
   // End of automatics


   // Control table and control signals for the MAC unit
   reg 				     c_dornd;
   reg [1:0] 			     c_invopb, c_opbsel;
   reg [2:0] 			     c_opasel;
   always @* begin
      case(c_macop)
	// -------------------------------------------------------------------------------------------
	`MAC_CLR:	  begin c_dornd = 0; c_invopb = 2'b00; c_opasel = 3'b000; c_opbsel = 2'b00; end
	`MAC_ADD:	  begin c_dornd = 0; c_invopb = 2'b00; c_opasel = 3'b001; c_opbsel = 2'b01; end
	`MAC_SUB:	  begin c_dornd = 0; c_invopb = 2'b01; c_opasel = 3'b001; c_opbsel = 2'b01; end
	`MAC_CMP:	  begin c_dornd = 0; c_invopb = 2'b01; c_opasel = 3'b001; c_opbsel = 2'b01; end
	`MAC_NEG:	  begin c_dornd = 0; c_invopb = 2'b01; c_opasel = 3'b000; c_opbsel = 2'b01; end
	// --------------------------------------------------------------------------------------------------------
	`MAC_ABS:	  begin c_dornd = 0; c_invopb = 2'b10; c_opasel = 3'b000; c_opbsel = 2'b01; end
	// --------------------------------------------------------------------------------------------------------
	`MAC_MUL:	  begin c_dornd = 0; c_invopb = 2'b00; c_opasel = 3'b000; c_opbsel = 2'b10; end
	`MAC_MAC:	  begin c_dornd = 0; c_invopb = 2'b00; c_opasel = 3'b001; c_opbsel = 2'b10; end
	`MAC_MDM:	  begin c_dornd = 0; c_invopb = 2'b01; c_opasel = 3'b001; c_opbsel = 2'b10; end
	// --------------------------------------------------------------------------------------------------------
	`MAC_MOVE:	  begin c_dornd = 0; c_invopb = 2'b00; c_opasel = 3'b000; c_opbsel = 2'b01; end
	`MAC_MOVE_ROUND:  begin c_dornd = 1; c_invopb = 2'b00; c_opasel = 3'b010; c_opbsel = 2'b01; end
	// --------------------------------------------------------------------------------------------------------
	default:	  begin c_dornd = 0; c_invopb = 2'b00; c_opasel = 3'b000; c_opbsel = 2'b00; end /* MAC_NOP */
	// -------------------------------------------------------------------------------------------
      endcase
   end

   /* Operation description:
    CLR:  mac_result = 0
    ADD:  mac_result = mac_operanda + mac_operandb
    SUB:  mac_result = mac_operanda - mac_operandb
    CMP:  mac_result = mac_operanda - mac_operandb
    NEG:  mac_result = 0 - mac_operandb
    ABS:  mac_result = abs(mac_operandb)
    MUL:  mac_result = mul_opa * mul_opb
    MAC:  mac_result = mac_operanda + mul_opa * mul_opb
    MDM:  mac_result = mac_operanda - mul_opa * mul_opb
    MOVE: mac_result = mac_operandb
    MOVE_ROUND: mac_result = round(mac_operandb)
    NOP:  mac_result = 0
        */

   //compute multiplication and sign extent to 40 bits - execution stage 1 (1)
   always @* begin
      mul_sig= mul_opa_reg * mul_opb_reg;
   end

   // And add a pipeline stage for the multiplier result... (2)
   always @(posedge clk_i) begin
      if (!reset_i) begin
	 mul_guarded_reg<=0;
      end
      else begin 
	 mul_guarded_reg<={{6{mul_sig[33]}}, mul_sig[33:0]};
      end  
   end

   // Multiplexer before scaler. (3)
   always @* begin
      case (c_opbsel)
	2'b00: to_scaling = 40'h0;
	2'b01: to_scaling = mac_operandb;
	default: to_scaling = mul_guarded_reg;
      endcase
   end
   
   // Scaling module (4)
   mac_scale scaling(/*AUTOINST*/
		     // Outputs
		     .scale_overflow	(scale_overflow),
		     .from_scaling	(from_scaling[39:0]),
		     // Inputs
		     .to_scaling	(to_scaling),
		     .c_scalefactor	(c_scalefactor));
   
   
   // Mux for selecting whether opb should be inverted or not (5)
   always@* begin
      case (c_invopb) 
	2'b00: adder_cin=1'b0;
	2'b10: adder_cin=from_scaling[39]; // instead of c_doabs c_invopb = 2
	default: adder_cin=1'b1;
      endcase
   end
   
   // Mux for selecting whether to invert adder operand b or not... (6)
   always@* begin
      case (adder_cin)
	1'b1: adder_opb=~from_scaling;
	1'b0: adder_opb=from_scaling;
      endcase
   end

   
   // Mux for selecting adder opa (7)
   always@* begin
      casex (c_opasel)
	3'b000: adder_opa=40'b0;
	3'b010: adder_opa={25'h1,15'h0}; // c_opasel = 2 when c_dornd = 1
	default: adder_opa=mac_operanda;
      endcase
   end
   
   // Computing Addition with carry (8) <adder 1>
   always @* begin
      adder_result=adder_opa+adder_opb+adder_cin;
   end

   // (9)

   always @* begin // (10)
      case(c_dornd)
	1'b0: round_result=adder_result;
	1'b1: round_result={adder_result[39:16], 16'b0};
      endcase
   end

   // Create some overflow flags. The special checks for overflows
   // when rounding or taking the absolute value can probably be done
   // in a better way when you refactor the code for lab 2 

   assign add_pos_overflow = (!adder_opa[39] && !adder_opb[39] && adder_result[39]);
   assign add_neg_overflow = (adder_opa[39] && adder_opb[39] && !adder_result[39]); 

   // Saturation logic (11)
   saturation sat_box(.value_i(round_result[39:0]),
		      .do_sat_i(c_dosat),
		      .value_o(mac_result),
		      .did_sat_o(sat_flag));

   
endmodule // macu

