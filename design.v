`timescale 1ns/1ps

//======================================================
// EXACT HALF ADDER
//======================================================
module exact_ha (
    input  a,
    input  b,
    output sum,
    output carry
);

    assign sum   = a ^ b;
    assign carry = a & b;

endmodule


//======================================================
// EXACT FULL ADDER
//======================================================
module exact_fa (
    input  a,
    input  b,
    input  cin,
    output sum,
    output carry
);

    assign sum   = a ^ b ^ cin;

    assign carry = (a & b) |
                   (a & cin) |
                   (b & cin);

endmodule


//======================================================
// APPROXIMATE FULL ADDER
// Paper Eq. (5) and (6)
//======================================================
module approx_fa (
    input  a,
    input  b,
    input  cin,
    output sum,
    output carry
);

    assign sum   = a | b | cin;

    assign carry = (a & b) |
                   (a & cin) |
                   (b & cin);

endmodule


//======================================================
// EXACT 4x4 MULTIPLIER
// Reference / Ground Truth
//======================================================
module exact_4x4 (
    input  [3:0] a,
    input  [3:0] b,
    output [7:0] product
);

    assign product = a * b;

endmodule


//======================================================
// NEC-1
// EC-1 WITHOUT ERROR COMPENSATION
//
// Paper:
// Positive-error compensation unit is replaced
// by exact counterpart.
//
// Therefore Column 4 uses Exact-FA.
//======================================================
module nec1_4x4 (
    input  [3:0] a,
    input  [3:0] b,
    output [7:0] product
);

    //==================================================
    // PARTIAL PRODUCTS
    //==================================================

    wire pp00;

    wire pp01, pp10;

    wire pp02, pp11, pp20;

    wire pp03, pp12, pp21, pp30;

    wire pp13, pp22, pp31;

    wire pp23, pp32;

    wire pp33;


    assign pp00 = a[0] & b[0];

    assign pp01 = a[0] & b[1];
    assign pp10 = a[1] & b[0];

    assign pp02 = a[0] & b[2];
    assign pp11 = a[1] & b[1];
    assign pp20 = a[2] & b[0];

    assign pp03 = a[0] & b[3];
    assign pp12 = a[1] & b[2];
    assign pp21 = a[2] & b[1];
    assign pp30 = a[3] & b[0];

    assign pp13 = a[1] & b[3];
    assign pp22 = a[2] & b[2];
    assign pp31 = a[3] & b[1];

    assign pp23 = a[2] & b[3];
    assign pp32 = a[3] & b[2];

    assign pp33 = a[3] & b[3];


    //==================================================
    // COLUMN 0
    //==================================================

    wire s0;

    assign s0 = pp00;


    //==================================================
    // COLUMN 1
    // OR COMPRESSION
    //==================================================

    wire s1;

    assign s1 = pp01 | pp10;


    //==================================================
    // COLUMN 2
    // OR COMPRESSION
    //==================================================

    wire s2;

    assign s2 = pp02 | pp11 | pp20;


    //==================================================
    // COLUMN 3
    // OR COMPRESSION
    //==================================================

    wire s3;

    assign s3 = pp03 | pp12 | pp21 | pp30;


    //==================================================
    // COLUMN 4
    // EXACT FA
    //
    // WITHOUT ERROR COMPENSATION
    //==================================================

    wire s4;
    wire c4;

    exact_fa FA_C4 (
        .a     (pp13),
        .b     (pp22),
        .cin   (pp31),
        .sum   (s4),
        .carry (c4)
    );


    //==================================================
    // COLUMN 5
    // EXACT FA
    //==================================================

    wire s5;
    wire c5;

    exact_fa FA_C5 (
        .a     (pp23),
        .b     (pp32),
        .cin   (c4),
        .sum   (s5),
        .carry (c5)
    );


    //==================================================
    // COLUMN 6
    // EXACT HA
    //==================================================

    wire s6;
    wire c6;

    exact_ha HA_C6 (
        .a     (pp33),
        .b     (c5),
        .sum   (s6),
        .carry (c6)
    );


    //==================================================
    // OUTPUT
    //==================================================

    assign product = {
        c6,
        s6,
        s5,
        s4,
        s3,
        s2,
        s1,
        s0
    };

endmodule



//======================================================
// EC-1
// WITH ERROR COMPENSATION
//
// C0-C3 : OR compression
// C4    : Approx-FA
// C5    : Exact-FA
// C6    : Exact-HA
//======================================================
module ec1_4x4 (
    input  [3:0] a,
    input  [3:0] b,
    output [7:0] product
);

    //==================================================
    // PARTIAL PRODUCTS
    //==================================================

    wire pp00;

    wire pp01, pp10;

    wire pp02, pp11, pp20;

    wire pp03, pp12, pp21, pp30;

    wire pp13, pp22, pp31;

    wire pp23, pp32;

    wire pp33;


    assign pp00 = a[0] & b[0];

    assign pp01 = a[0] & b[1];
    assign pp10 = a[1] & b[0];

    assign pp02 = a[0] & b[2];
    assign pp11 = a[1] & b[1];
    assign pp20 = a[2] & b[0];

    assign pp03 = a[0] & b[3];
    assign pp12 = a[1] & b[2];
    assign pp21 = a[2] & b[1];
    assign pp30 = a[3] & b[0];

    assign pp13 = a[1] & b[3];
    assign pp22 = a[2] & b[2];
    assign pp31 = a[3] & b[1];

    assign pp23 = a[2] & b[3];
    assign pp32 = a[3] & b[2];

    assign pp33 = a[3] & b[3];


    //==================================================
    // COLUMN 0
    //==================================================

    wire s0;

    assign s0 = pp00;


    //==================================================
    // COLUMN 1
    // OR COMPRESSION
    //==================================================

    wire s1;

    assign s1 = pp01 | pp10;


    //==================================================
    // COLUMN 2
    // OR COMPRESSION
    //==================================================

    wire s2;

    assign s2 = pp02 | pp11 | pp20;


    //==================================================
    // COLUMN 3
    // OR COMPRESSION
    //==================================================

    wire s3;

    assign s3 = pp03 | pp12 | pp21 | pp30;


    //==================================================
    // COLUMN 4
    // APPROXIMATE FA
    //
    // THIS IS THE POSITIVE ERROR
    // COMPENSATION UNIT
    //==================================================

    wire s4;
    wire c4;

    approx_fa FA_C4_APPROX (
        .a     (pp13),
        .b     (pp22),
        .cin   (pp31),
        .sum   (s4),
        .carry (c4)
    );


    //==================================================
    // COLUMN 5
    // EXACT FA
    //==================================================

    wire s5;
    wire c5;

    exact_fa FA_C5 (
        .a     (pp23),
        .b     (pp32),
        .cin   (c4),
        .sum   (s5),
        .carry (c5)
    );


    //==================================================
    // COLUMN 6
    // EXACT HA
    //==================================================

    wire s6;
    wire c6;

    exact_ha HA_C6 (
        .a     (pp33),
        .b     (c5),
        .sum   (s6),
        .carry (c6)
    );


    //==================================================
    // OUTPUT
    //==================================================

    assign product = {
        c6,
        s6,
        s5,
        s4,
        s3,
        s2,
        s1,
        s0
    };

endmodule
