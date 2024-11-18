`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2024 11:14:54 PM
// Design Name: 
// Module Name: decoder
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
//////////////////////////////////////////////////////////////////////////////////


module decoder (
    input [1:0] sel,       // 2-bit input selector (00 - Add, 01 - Sub, 10 - Mul)
    output reg enable_add, // Enable for Adder
    output reg enable_sub, // Enable for Subtractor
    output reg enable_mul  // Enable for Multiplier
);
    always @(*) begin
        // Default to disable all operations
        enable_add = 1'b0;
        enable_sub = 1'b0;
        enable_mul = 1'b0;

        case(sel)
            2'b00: enable_add = 1'b1;  // Enable Adder
            2'b01: enable_sub = 1'b1;  // Enable Subtractor
            2'b10: enable_mul = 1'b1;  // Enable Multiplier
            default: begin
                enable_add = 1'b0;     // Disable all
                enable_sub = 1'b0;
                enable_mul = 1'b0;
            end
        endcase
    end
endmodule
