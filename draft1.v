`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/17/2024 06:07:57 PM
// Design Name: 
// Module Name: draft1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
///////////////////////////////////////////////////////////////////////////////
module alu_8bit(
    input [7:0] a, b,  
    input cin,   
    input [1:0] sel,
    output [15:0] result,
    output reg carry
);
    wire enable_add, enable_sub, enable_mul;
    wire [15:0] sum, diff, product;
    wire cout_add, cout_sub, cout_mul;
 
    
     decoder dec (
        .sel(sel),
        .enable_add(enable_add),
        .enable_sub(enable_sub),
        .enable_mul(enable_mul)
    );
  carry_lookahead_adder_8bit cla (
        .a(a),
        .b(b),
        .cin(cin),
        .enable_add(enable_add),
        .SUM(sum),
        .COUT(cout_add));
    twos_complement_subtractor sub (
        .a(a),
        .b(b),
        .enable_sub(enable_sub),
        .diff(diff),
        .COUT(sub_cout)
    );
    
    array_multiplier_8bit mul (
        .a(a),
        .b(b),
        .enable_mul(enable_mul),
        .product(product),
        .cout(mul_cout)
    );
   assign result = (enable_add) ? sum :
                    (enable_sub) ? diff :
                    (enable_mul) ? product : 16'b0;

    always @(*) begin
        if (enable_add) carry = cout_add;
        else if (enable_sub) carry = sub_cout;
        else if (enable_mul) carry = cout_mul;
        else carry = 0;
    end
endmodule
