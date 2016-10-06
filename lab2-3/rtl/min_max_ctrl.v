
module min_max_ctrl
  (
    input wire [2:0] function_i,
    input wire 	     opa_sign_i,
    input wire 	     opb_sign_i,
    input wire 	     carry_i,
    output wire      mx_minmax_o
   );			

   reg 		      max_op;
 		     
   always @(*) begin
      case({opb_sign_i, opa_sign_i, carry_i})
	3'b000, 3'b100, 3'b101, 3'b110: max_op = 1'b0; // max: opa
	3'b001, 3'b010, 3'b011, 3'b111: max_op = 1'b1; // max: opb
      endcase
   end // always @(*)

   assign mx_minmax_o = max_op ^ function_i[0];
   
endmodule // min_max_ctrl
