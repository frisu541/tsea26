
module saturation
  (
    input wire [39:0]   value_i,
    input wire 		do_sat_i,
    output wire [39:0] 	value_o,
    output wire 	did_sat_o
   );

   reg [39:0]		value_int;
   reg 			do_sat_int;
   reg  		overflow;
         
   always@* begin

      // Check for overflow in guard bit and MSB
      case (value_i[39:31])
	9'b0: overflow = 0;
	9'b111111111: overflow = 0;
	default: overflow = 1;
      endcase

      // Perform saturation?
      do_sat_int = do_sat_i & overflow;

      // Set saturation_o to value_i or saturated value
      case (do_sat_int)
	0: value_int = value_i;
	1: begin
	   case (value_i[39])
	     // Didn't work when using hex values?!
	     0:	value_int = 40'b0000000001111111111111111111111111111111;
	     1: value_int = 40'b1111111110000000000000000000000000000000;
	   endcase // case (value_i[39])
	end
      endcase // case (do_sat_int)
      
   end

   // Set output values
   assign value_o = value_int;
   assign did_sat_o = do_sat_int;

endmodule // saturation
