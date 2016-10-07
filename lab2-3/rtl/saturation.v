
module saturation
  (
    input wire [39:0] value_i,
    input wire 	      do_sat_i,
    output reg [39:0] value_o,
    output reg 	      did_sat_o
   );

   always @(*) begin
      case(value_i[39:31])
	9'b000000000, 9'b111111111 : did_sat_o = 1'b0;
	default : did_sat_o = do_sat_i & 1'b1;
      endcase // case (value_i[39:31])
   end // always @ begin
   
   always @(*) begin
      case({did_sat_o,value_i[39]})
	2'b10 : value_o = 40'h007fffffff;
	2'b11 : value_o = 40'hff80000000;
        default : value_o = value_i;
      endcase // case (did_sat_o)
   end // always @ begin

endmodule // saturation
