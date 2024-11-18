`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2024 05:56:00 PM
// Design Name: 
// Module Name: trialerror
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
module half_adder (
    input a, b,        
    output sum, carry  
);
    assign sum = a ^ b;     
    assign carry = a & b;   
endmodule

// Full Adder  Using Half Adders
module full_adder (
    input a, b, cin,   
    output sum, cout  
);
    wire sum_half, carry_half1, carry_half2;

    // First Half Adder
    half_adder ha1 (
        .a(a), 
        .b(b), 
        .sum(sum_half), 
        .carry(carry_half1)
    );

    // Second Half Adder
    half_adder ha2 (
        .a(sum_half), 
        .b(cin), 
        .sum(sum), 
        .carry(carry_half2)
    );

   
    assign cout = carry_half1 | carry_half2;  
endmodule


//CLA
module carry_lookahead_adder_4bit (
    input [3:0] a, b,
    input cin,
    output [3:0] sum,
    output cout
);
    wire [3:0] p, g;
    wire c1, c2, c3;

    assign p = a ^ b; 
    assign g = a & b; 

    assign c1 = g[0] | (p[0] & cin);
    assign c2 = g[1] | (p[1] & c1);
    assign c3 = g[2] | (p[2] & c2);
    assign cout = g[3] | (p[3] & c3);

    full_adder fa0 (
        .a(a[0]), 
        .b(b[0]), 
        .cin(cin), 
        .sum(sum[0]), 
        .cout(c1)
    );

    full_adder fa1 (
        .a(a[1]), 
        .b(b[1]), 
        .cin(c1), 
        .sum(sum[1]), 
        .cout(c2)
    );

    full_adder fa2 (
        .a(a[2]), 
        .b(b[2]), 
        .cin(c2), 
        .sum(sum[2]), 
        .cout(c3)
    );

    full_adder fa3 (
        .a(a[3]), 
        .b(b[3]), 
        .cin(c3), 
        .sum(sum[3]), 
        .cout(cout)
    );
endmodule
module carry_lookahead_adder_8bit (
    input [7:0] a, b,
    input cin,
    output [15:0] sum,
    output cout
);
    wire c4;

    carry_lookahead_adder_4bit cla0 (
        .a(a[3:0]), 
        .b(b[3:0]), 
        .cin(cin), 
        .sum(sum[3:0]), 
        .cout(c4)
    );

    carry_lookahead_adder_4bit cla1 (
        .a(a[7:4]), 
        .b(b[7:4]), 
        .cin(c4), 
        .sum(sum[7:4]), 
        .cout(cout)
    );
endmodule

//multipier
module array_multiplier_8bit (
    input [7:0] a, b,
    output [15:0] product,
    output cout
    
);
    wire [7:0] partial_products [7:0];
    wire [14:0] carry [6:0];           
    wire [14:0] sum [6:0];             

    
    genvar i, j;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_partial_products
            for (j = 0; j < 8; j = j + 1) begin : gen_bits
                assign partial_products[i][j] = a[j] & b[i];
            end
        end
    endgenerate

  
    assign product[0] = partial_products[0][0];
    generate
        for (j = 1; j < 8; j = j + 1) begin
            assign {carry[0][j-1], product[j]} = partial_products[0][j] + partial_products[1][j-1];
        end
    endgenerate

 
    generate
        for (i = 1; i < 7; i = i + 1) begin : gen_adder_rows
            for (j = 0; j < 15 - i; j = j + 1) begin : gen_adder_columns
                if (j == 0) begin
                    full_adder fa (
                        .a(partial_products[i+1][j]),
                        .b(product[i+j+1]),
                        .cin(1'b0),
                        .sum(sum[i][j]),
                        .cout(carry[i][j])
                    );
                end else begin
                    full_adder fa (
                        .a(partial_products[i+1][j]),
                        .b(sum[i-1][j-1]),
                        .cin(carry[i-1][j-1]),
                        .sum(sum[i][j]),
                        .cout(carry[i][j])
                    );
                end
            end
        end
    endgenerate

   
    generate
        for (j = 0; j < 7; j = j + 1) begin : gen_final_sum
            assign product[8+j] = sum[6][j];
        end
    endgenerate
    assign cout = carry[6][6]; 
endmodule

//subtractor
module twos_complement_subtractor (
    input [7:0] a, 
    input [7:0] b, 
    output [15:0] diff,
    output cout
);
    wire [7:0] b_inverted;    
    wire [7:0] sum;         
    wire [6:0] carry;       
    
  
    assign b_inverted = ~b+1;//inverting 

   
    half_adder ha0 (.a(a[0]), .b(b_inverted[0]), .sum(sum[0]), .carry(carry[0]));

  
    full_adder fa1 (.a(a[1]), .b(b_inverted[1]), .cin(carry[0]), .sum(sum[1]), .cout(carry[1]));
    full_adder fa2 (.a(a[2]), .b(b_inverted[2]), .cin(carry[1]), .sum(sum[2]), .cout(carry[2]));
    full_adder fa3 (.a(a[3]), .b(b_inverted[3]), .cin(carry[2]), .sum(sum[3]), .cout(carry[3]));
    full_adder fa4 (.a(a[4]), .b(b_inverted[4]), .cin(carry[3]), .sum(sum[4]), .cout(carry[4]));
    full_adder fa5 (.a(a[5]), .b(b_inverted[5]), .cin(carry[4]), .sum(sum[5]), .cout(carry[5]));
    full_adder fa6 (.a(a[6]), .b(b_inverted[6]), .cin(carry[5]), .sum(sum[6]), .cout(carry[6]));
    full_adder fa7 (.a(a[7]), .b(b_inverted[7]), .cin(carry[6]), .sum(sum[7]), .cout(cout));  // Carry-out of the MSB adder

    assign diff = sum;
endmodule

module alu_8bit(
    input [7:0] a, b,  
    input cin,   
    input [1:0] sel,
    output reg carry,        
    output reg [15:0] result 
);
    wire [15:0] sum, diff, product, quotient,cout;
    carry_lookahead_adder_8bit cla_add(.a(a), .b(b),.cin(cin), .sum(sum), .cout(cout)); 
    twos_complement_subtractor sub(.a(a), .b(b), .diff(diff), .cout(cout));
    array_multiplier_8bit mul(.a(a), .b(b), .product(product),.cout(cout));
    
    always @(*) begin
        case (sel)
            2'b00: begin
                result = sum;  
                carry = cout;
            end
            2'b01: begin
               result = diff;  
               carry = cout;
            end
            2'b10: begin 
            result = product; 
            carry = cout;
            end 
            
            default: begin
            result = 8'b00000000;
            carry =1'b0;
                 
            end
            endcase
    end

endmodule
