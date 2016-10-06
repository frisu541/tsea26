
module adder_ctrl
  (
    input wire [2:0] function_i,
    input wire 	     opa_sign_i,
    output reg 	     mx_opa_inv_o,
    output reg [1:0] mx_ci_o
   );

   always@* begin
      case(function_i)
	// ADD
	0: begin
	   assign mx_opa_inv_o = 0;
	   assign mx_ci_o = 0;
	end
	// ADDC
	1: begin
	   assign mx_opa_inv_o = 0;
	   assign mx_ci_o = 2;
	end
	// SUB
	2: begin
	   assign mx_opa_inv_o = 1;
	   assign mx_ci_o = 1; // Set carry = 1
	end
	// SUBC
	3: begin
	   assign mx_opa_inv_o = 1;
	   assign mx_ci_o = 2;
	end
	// ABS (NO SAT)
	4: begin
	   if(opa_sign_i == 0) begin   // Positive A
	      assign mx_opa_inv_o = 0;
	      assign mx_ci_o = 0;
	   end
	   else begin	               // Negative A
	      assign mx_opa_inv_o = 1;
	      assign mx_ci_o = 1;
	   end
	   
	end
	// CMP
	5: begin
	   assign mx_opa_inv_o = 1;
	   assign mx_ci_o = 1; // Set carry = 1
	end
	// MAX
	/*6: begin

	end
	// MIN
        7: begin

	end
	 */
	default: begin
	   assign mx_opa_inv_o = 0;
	   assign mx_ci_o = 0;
	end
      endcase
   end

endmodule // adder_ctrl
