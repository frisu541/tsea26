
module adder_ctrl
  (
   input wire [2:0]  function_i,
   input wire 	     opa_sign_i,
   output wire 	     mx_opa_inv_o,
   output wire [1:0] mx_ci_o
   );

   reg [2:0] 	     mx_ctrl;
   
   always @(*) begin
      case(function_i)
	3'b000: mx_ctrl = 3'b000; // ADD
	3'b001: mx_ctrl = 3'b010;// ADDC
	3'b010, 3'b101: mx_ctrl = 3'b101;// SUB, CMP
	3'b011: mx_ctrl = 3'b110; // SUBC
	3'b100: mx_ctrl = {opa_sign_i,1'b0, opa_sign_i}; // ABS
	default: mx_ctrl = 3'b000; // MAX, MIN (don't care)
      endcase
   end // always @(*)

   assign mx_opa_inv_o = mx_ctrl[2];
   assign mx_ci_o = mx_ctrl[1:0];
   
endmodule // adder_ctrl
