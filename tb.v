`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2024 03:36:06 PM
// Design Name: 
// Module Name: tb
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


`timescale 1ns / 1ps

module alu_8bit_tb;
    // Inputs
    reg [7:0] a, b;
    reg cin;
    reg [2:0] sel;

    // Outputs
    wire [15:0] result;
    wire carry;

    // Instantiate the Unit Under Test (UUT)
    alu_8bit uut (
        .a(a),
        .b(b),
        .cin(cin),
        .sel(sel),
        .result(result),
        .carry(carry)
    );

    initial begin
       
       
        a = 8'b00000001; // 15
        b = 8'b00000000; // 3
        cin = 1'b0;

      
        sel = 3'b000; // Select addition
        #10; // Wait for result
        

         a = 8'b00000001; // 15
        b = 8'b00000000; // 3
        cin = 1'b0;
        sel = 3'b001; // Select subtraction
        #10;
              
 a = 8'b00000011; 
        b = 8'b00000011; 
        cin = 1'b0;
        // Test multiplication (sel = 2'b10)
        sel = 3'b010; 
        #10;
       
 a = 8'b00000001; 
        b = 8'b00000001; 
        cin = 1'b0;
       
        sel = 3'b011; 
        #10;
       
       a = 8'b00000001; 
        b = 8'b00000000; 
        cin = 1'b0;
       
        sel = 3'b100; 
        #10;
         a = 8'b00000001; 
        b = 8'b00000001; 
        cin = 1'b0;
       
        sel = 3'b101; 
        #10;
       
         a = 8'b00000001; 
      
        sel = 3'b110; 
        #10;
       

        // End simulation
        $stop;
    end
endmodule
