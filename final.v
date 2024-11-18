`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2024 03:22:05 PM
// Design Name: 
// Module Name: final
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

module half_adder (
    input a, b,        // Inputs
    output sum, carry  // Outputs
);
    assign sum = a ^ b;     // XOR for sum
    assign carry = a & b;   // AND for carry
endmodule

// Full Adder Using Half Adders
module full_adder (
    input a, b, cin,   // Inputs
    output sum, cout   // Outputs
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

    assign cout = carry_half1 | carry_half2;  // OR gate for carry-out
endmodule

// 4-bit Carry Lookahead Adder
module carry_lookahead_adder_4bit (
    input [3:0] a, b,     // 4-bit inputs
    input cin,            // Carry-in
    output [3:0] sum,     // 4-bit sum
    output cout           // Carry-out
);
    wire [3:0] p, g;      // Propagate and Generate signals
    wire c1, c2, c3;      // Intermediate carry signals

    assign p = a ^ b;     // Propagate signals
    assign g = a & b;     // Generate signals

    assign c1 = g[0] | (p[0] & cin);
    assign c2 = g[1] | (p[1] & c1);
    assign c3 = g[2] | (p[2] & c2);
    assign cout = g[3] | (p[3] & c3);

    // Full adders for individual bits
    full_adder fa0 (
        .a(a[0]), 
        .b(b[0]), 
        .cin(cin), 
        .sum(sum[0]), 
        .cout()  // Intermediate carry not used here
    );
    full_adder fa1 (
        .a(a[1]), 
        .b(b[1]), 
        .cin(c1), 
        .sum(sum[1]), 
        .cout()  // Intermediate carry not used here
    );
    full_adder fa2 (
        .a(a[2]), 
        .b(b[2]), 
        .cin(c2), 
        .sum(sum[2]), 
        .cout()  // Intermediate carry not used here
    );
    full_adder fa3 (
        .a(a[3]), 
        .b(b[3]), 
        .cin(c3), 
        .sum(sum[3]), 
        .cout()  // Intermediate carry not used here
    );
endmodule

// 8-bit Carry Lookahead Adder
module carry_lookahead_adder_8bit (
    input [7:0] a, b,      // 8-bit inputs
    input cin,             // Carry-in
    input enable_add,      // Enable for adder
    output reg [15:0] SUM, // 16-bit sum
    output reg COUT        // Carry-out
);
    wire c4;
    wire [7:0] sum;        // Intermediate sum
    wire cout;             // Intermediate carry-out

    // Lower 4 bits
    carry_lookahead_adder_4bit cla0 (
        .a(a[3:0]), 
        .b(b[3:0]), 
        .cin(cin), 
        .sum(sum[3:0]), 
        .cout(c4)
    );

    // Upper 4 bits
    carry_lookahead_adder_4bit cla1 (
        .a(a[7:4]), 
        .b(b[7:4]), 
        .cin(c4), 
        .sum(sum[7:4]), 
        .cout(cout)
    );

    // Enable logic
    always @(*) begin
        if (enable_add)
         begin
            SUM = {8'b00000000, sum}; // Zero-extend lower 8 bits
            COUT = cout;             // Pass carry-out
        end 
        else begin
            SUM = 16'b0000000000000000; // Default to 0 when disabled
            COUT = 1'b0;               // Default carry-out
        end
    end
endmodule



    


//subtractor
module twos_complement_subtractor (
    input [7:0] a, 
    input [7:0] b, 
    input enable_sub,
    output reg [15:0] diff, // 16-bit output to match ALU requirements
    output reg COUT         // Carry-out (borrow indicator)
);
    wire [7:0] b_inverted;   // Inverted `b` for subtraction
    wire [7:0] sum;          // Result of addition
    wire [6:0] carry;        // Intermediate carries
    wire cout;               // Final carry-out
    
    // Two's complement of b (invert and add 1)
    assign b_inverted = ~b + 8'b00000001; // Two's complement operation
    
    // Perform addition (a + b_inverted)
    half_adder ha0 (
        .a(a[0]), 
        .b(b_inverted[0]), 
        .sum(sum[0]), 
        .carry(carry[0])
    );
    
    full_adder fa1 (.a(a[1]), .b(b_inverted[1]), .cin(carry[0]), .sum(sum[1]), .cout(carry[1]));
    full_adder fa2 (.a(a[2]), .b(b_inverted[2]), .cin(carry[1]), .sum(sum[2]), .cout(carry[2]));
    full_adder fa3 (.a(a[3]), .b(b_inverted[3]), .cin(carry[2]), .sum(sum[3]), .cout(carry[3]));
    full_adder fa4 (.a(a[4]), .b(b_inverted[4]), .cin(carry[3]), .sum(sum[4]), .cout(carry[4]));
    full_adder fa5 (.a(a[5]), .b(b_inverted[5]), .cin(carry[4]), .sum(sum[5]), .cout(carry[5]));
    full_adder fa6 (.a(a[6]), .b(b_inverted[6]), .cin(carry[5]), .sum(sum[6]), .cout(carry[6]));
    full_adder fa7 (.a(a[7]), .b(b_inverted[7]), .cin(carry[6]), .sum(sum[7]), .cout(cout));

    // Control logic for subtraction enable
    always @(*) begin
        if (enable_sub) begin
            diff = {8'b00000000, sum}; // Zero-extend to 16 bits
            COUT = cout;              // Final carry-out
        end else begin
            diff = 16'b0000000000000000; // Default to zero when disabled
            COUT = 1'b0;                // Default carry-out
        end
    end
endmodule


module array_multiplier_8bit (
    input [7:0] a, b,
    input enable_mul, // Enable signal for multiplication
    output reg [15:0] product,
    output reg cout
);
    wire [7:0] partial_products [7:0];
    wire [14:0] carry [6:0];
    wire [14:0] sum [6:0];
    wire [15:0] temp_product;
    wire temp_cout;

    genvar i, j;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_partial_products
            for (j = 0; j < 8; j = j + 1) begin : gen_bits
                assign partial_products[i][j] = a[j] & b[i];
            end
        end
    endgenerate

    assign temp_product[0] = partial_products[0][0];
    generate
        for (j = 1; j < 8; j = j + 1) begin
            assign {carry[0][j-1], temp_product[j]} = partial_products[0][j] + partial_products[1][j-1];
        end
    endgenerate

    generate
        for (i = 1; i < 7; i = i + 1) begin : gen_adder_rows
            for (j = 0; j < 15 - i; j = j + 1) begin : gen_adder_columns
                if (j == 0) begin
                    full_adder fa (
                        .a(partial_products[i+1][j]),
                        .b(temp_product[i+j+1]),
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
            assign temp_product[8+j] = sum[6][j];
        end
    endgenerate
    assign temp_cout = carry[6][6];

    // Controlled output based on enable signal
    always @(*) begin
        if (enable_mul) begin
            product = temp_product;
            cout = temp_cout;
        end else begin
            product = 16'b0;
            cout = 1'b0;
        end
    end
endmodule


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
