
module decoder (
    input [2:0] sel,       // 2-bit input selector (00 - Add, 01 - Sub, 10 - Mul)
    output reg enable_add, // Enable for Adder
    output reg enable_sub, // Enable for Subtractor
    output reg enable_mul,
     output reg enable_logic  // Enable for Multiplier
);
    always @(*) begin
        // Default to disable all operations
        enable_add = 1'b0;
        enable_sub = 1'b0;
        enable_mul = 1'b0;
         enable_logic = 1'b0;

        case(sel)
            3'b00: enable_add = 1'b1;  // Enable Adder
            3'b01: enable_sub = 1'b1;  // Enable Subtractor
            3'b10: enable_mul = 1'b1;  // Enable Multiplier
             3'b011, 3'b100, 3'b101, 3'b110: enable_logic = 1'b1;
            default: begin
                enable_add = 1'b0;     // Disable all
                enable_sub = 1'b0;
                enable_mul = 1'b0;
                 enable_logic = 1'b0;
            end
        endcase
    end
endmodule

module logic_operations (
    input [7:0] a, b,
    input [2:0] sel,
    output reg [15:0] result
);
    always @(*) begin
        case (sel)
            3'b011: result = {8'b00000000, a & b}; // AND
            3'b100: result = {8'b00000000, a | b}; // OR
            3'b101: result = {8'b00000000, a ^ b}; // XOR
            3'b110: result = {8'b00000000, ~a};    // NOT (only on `a`)
            default: result = 16'b0;
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


module array_multiplier_8bit(
input [7:0] a, b,
input enable_mul,
 output reg[15:0] product
 );

 
  wire [15:0]z;     
  wire temp_product;
  
  wire [7:0] p[7:0];  // Partial products (p[7:0] for each row)
  wire [54:0] c;      // Carry signals (used in adders)
  wire [47:0] s;      // Sum signals (used in adders)
  
  // Generate partial products
  genvar g, h;
  generate
    for (g = 0; g < 8; g = g + 1) begin
      for (h = 0; h < 8; h = h + 1) begin
        and and_gate(p[g][h], a[g], b[h]);
      end
    end
  endgenerate

  // Assign LSB of the product
  assign z[0] = p[0][0];

  // Row 0: Half Adders
  half_adder h0(p[0][1], p[1][0], z[1], c[0]);
  half_adder h1(p[1][1], p[2][0], s[0], c[1]);
  half_adder h2(p[2][1], p[3][0], s[1], c[2]);
  half_adder h3(p[3][1], p[4][0], s[2], c[3]);
  half_adder h4(p[4][1], p[5][0], s[3], c[4]);
  half_adder h5(p[5][1], p[6][0], s[4], c[5]);
  half_adder h6(p[6][1], p[7][0], s[5], c[6]);

  // Row 1: Full Adders
  full_adder f0(p[0][2], c[0], s[0], z[2], c[7]);
  full_adder f1(p[1][2], c[1], s[1], s[6], c[8]);
  full_adder f2(p[2][2], c[2], s[2], s[7], c[9]);
  full_adder f3(p[3][2], c[3], s[3], s[8], c[10]);
  full_adder f4(p[4][2], c[4], s[4], s[9], c[11]);
  full_adder f5(p[5][2], c[5], s[5], s[10], c[12]);
  full_adder f6(p[6][2], c[6], p[7][1], s[11], c[13]);

  // Row 2: Full Adders
  full_adder f7(p[0][3], c[7], s[6], z[3], c[14]);
  full_adder f8(p[1][3], c[8], s[7], s[12], c[15]);
  full_adder f9(p[2][3], c[9], s[8], s[13], c[16]);
  full_adder f10(p[3][3], c[10], s[9], s[14], c[17]);
  full_adder f11(p[4][3], c[11], s[10], s[15], c[18]);
  full_adder f12(p[5][3], c[12], s[11], s[16], c[19]);
  full_adder f13(p[6][3], c[13], p[7][2], s[17], c[20]);

  // Row 3: Full Adders
  full_adder f14(p[0][4], c[14], s[12], z[4], c[21]);
  full_adder f15(p[1][4], c[15], s[13], s[18], c[22]);
  full_adder f16(p[2][4], c[16], s[14], s[19], c[23]);
  full_adder f17(p[3][4], c[17], s[15], s[20], c[24]);
  full_adder f18(p[4][4], c[18], s[16], s[21], c[25]);
  full_adder f19(p[5][4], c[19], s[17], s[22], c[26]);
  full_adder f20(p[6][4], c[20], p[7][3], s[23], c[27]);

  // Row 4: Full Adders
  full_adder f21(p[0][5], c[21], s[18], z[5], c[28]);
  full_adder f22(p[1][5], c[22], s[19], s[24], c[29]);
  full_adder f23(p[2][5], c[23], s[20], s[25], c[30]);
  full_adder f24(p[3][5], c[24], s[21], s[26], c[31]);
  full_adder f25(p[4][5], c[25], s[22], s[27], c[32]);
  full_adder f26(p[5][5], c[26], s[23], s[28], c[33]);
  full_adder f27(p[6][5], c[27], p[7][4], s[29], c[34]);

  // Row 5: Full Adders
  full_adder f28(p[0][6], c[28], s[24], z[6], c[35]);
  full_adder f29(p[1][6], c[29], s[25], s[30], c[36]);
  full_adder f30(p[2][6], c[30], s[26], s[31], c[37]);
  full_adder f31(p[3][6], c[31], s[27], s[32], c[38]);
  full_adder f32(p[4][6], c[32], s[28], s[33], c[39]);
  full_adder f33(p[5][6], c[33], s[29], s[34], c[40]);
  full_adder f34(p[6][6], c[34], p[7][5], s[35], c[41]);

  // Row 6: Full Adders
  full_adder f35(p[0][7], c[35], s[30], z[7], c[42]);
  full_adder f36(p[1][7], c[36], s[31], s[36], c[43]);
  full_adder f37(p[2][7], c[37], s[32], s[37], c[44]);
  full_adder f38(p[3][7], c[38], s[33], s[38], c[45]);
  full_adder f39(p[4][7], c[39], s[34], s[39], c[46]);
  full_adder f40(p[5][7], c[40], s[35], s[40], c[47]);
  full_adder f41(p[6][7], c[41], p[7][6], s[41], c[48]);

  // Final Row: Carry Propagation
  full_adder f42(c[42], s[36], s[41], z[8], c[49]);
  full_adder f43(c[43], s[37], s[42], z[9], c[50]);
  full_adder f44(c[44], s[38], s[43], z[10], c[51]);
  full_adder f45(c[45], s[39], s[44], z[11], c[52]);
  full_adder f46(c[46], s[40], s[45], z[12], c[53]);
  full_adder f47(c[47], p[7][7], s[46], z[13], c[54]);
  


    // Controlled output based on enable signal
    always @(*) begin
        if (enable_mul) 
            product = {8'b00000000, z};
           
         else 
            product = 16'b0;
            
        end
   
endmodule


module alu_8bit(
    input [7:0] a, b,  
    input cin,   
    input [2:0] sel,    // 3-bit selector for operation
    output reg [15:0] result, // Final result
    output reg carry           // Final carry
);
    wire enable_add, enable_sub, enable_mul, enable_logic;
    wire [15:0] sum, diff, product, logic_result;
    wire cout_add, cout_sub;

    // Decoder for operation selection
    decoder dec (
        .sel(sel),
        .enable_add(enable_add),
        .enable_sub(enable_sub),
        .enable_mul(enable_mul),
        .enable_logic(enable_logic)
    );

    // Add/Subtract/Multiply/Logic operation modules
    carry_lookahead_adder_8bit cla (
        .a(a),
        .b(b),
        .cin(cin),
        .enable_add(enable_add),
        .SUM(sum),
        .COUT(cout_add)
    );

    twos_complement_subtractor sub (
        .a(a),
        .b(b),
        .enable_sub(enable_sub),
        .diff(diff),
        .COUT(cout_sub)
    );

    array_multiplier_8bit mul (
        .a(a),
        .b(b),
        .enable_mul(enable_mul),
        .product(product)
    );

    logic_operations log_ops (
        .a(a),
        .b(b),
        .sel(sel),
        .result(logic_result)
    );

    // Single MUX to select the final result based on `sel`
    always @(*) begin
        case (sel)
            3'b000: result = sum;           // Add
            3'b001: result = diff;          // Subtract
            3'b010: result = product;       // Multiply
            3'b011, 3'b100, 3'b101, 3'b110: result = logic_result; // Logic operations
            default: result = 16'b0;        // Default to zero
        endcase
    end

    // Assign carry based on the selected operation
    always @(*) begin
        case (sel)
            3'b000: carry = cout_add;       // Add carry-out
            3'b001: carry = cout_sub;       // Subtract carry-out
            default: carry = 1'b0;          // No carry for other operations
        endcase
    end
endmodule
