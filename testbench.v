`timescale 1ns/1ps

module tb_ec1_comparison;

    //==================================================
    // INPUTS
    //==================================================

    reg [3:0] a;
    reg [3:0] b;


    //==================================================
    // OUTPUTS
    //==================================================

    wire [7:0] exact_result;
    wire [7:0] nec1_result;
    wire [7:0] ec1_result;


    //==================================================
    // ERROR VALUES
    //==================================================

    integer error_without;
    integer error_with;


    //==================================================
    // EXACT MULTIPLIER
    //==================================================

    exact_4x4 U_EXACT (
        .a       (a),
        .b       (b),
        .product (exact_result)
    );


    //==================================================
    // NEC-1
    // WITHOUT ERROR COMPENSATION
    //==================================================

    nec1_4x4 U_NEC1 (
        .a       (a),
        .b       (b),
        .product (nec1_result)
    );


    //==================================================
    // EC-1
    // WITH ERROR COMPENSATION
    //==================================================

    ec1_4x4 U_EC1 (
        .a       (a),
        .b       (b),
        .product (ec1_result)
    );


    //==================================================
    // WAVEFORM
    //==================================================

    initial begin

        $dumpfile("ec1_comparison.vcd");
        $dumpvars(0, tb_ec1_comparison);

    end


    //==================================================
    // SIMULATION
    //==================================================

    integer i;
    integer j;

    integer count_without;
    integer count_with;


    initial begin

        count_without = 0;
        count_with    = 0;


        //================================================
        // HEADER
        //================================================

        $display("");
        $display("==============================================================");
        $display("          4x4 EC-1 ERROR COMPENSATION COMPARISON");
        $display("==============================================================");

        $display(" A     B       EXACT       NEC-1       EC-1");
        $display("             (REFERENCE)  (WITHOUT)    (WITH)");
        $display("--------------------------------------------------------------");


        //================================================
        // PAPER EXAMPLE
        // A = 1110
        // B = 1011
        //================================================

        a = 4'b1110;
        b = 4'b1011;

        #10;

        error_without = nec1_result - exact_result;
        error_with    = ec1_result  - exact_result;

        $display("");
        $display("PAPER EXAMPLE");
        $display("A = %b", a);
        $display("B = %b", b);

        $display("Exact       = %b (%0d)",
                 exact_result,
                 exact_result);

        $display("Without EC  = %b (%0d)",
                 nec1_result,
                 nec1_result);

        $display("With EC     = %b (%0d)",
                 ec1_result,
                 ec1_result);

        $display("Error Without Compensation = %0d",
                 error_without);

        $display("Error With Compensation    = %0d",
                 error_with);


        //================================================
        // OTHER TEST CASES
        //================================================

        a = 4'b0011;
        b = 4'b0011;

        #10;

        error_without = nec1_result - exact_result;
        error_with    = ec1_result - exact_result;

        $display("");
        $display("A=%b  B=%b  Exact=%0d  NEC-1=%0d  EC-1=%0d",
                 a,b,exact_result,nec1_result,ec1_result);

        $display("Error without = %0d, Error with = %0d",
                 error_without,error_with);


        a = 4'b1111;
        b = 4'b1111;

        #10;

        error_without = nec1_result - exact_result;
        error_with    = ec1_result - exact_result;

        $display("");
        $display("A=%b  B=%b  Exact=%0d  NEC-1=%0d  EC-1=%0d",
                 a,b,exact_result,nec1_result,ec1_result);

        $display("Error without = %0d, Error with = %0d",
                 error_without,error_with);


        //================================================
        // EXHAUSTIVE 256 TEST
        //================================================

        $display("");
        $display("==============================================================");
        $display("             EXHAUSTIVE 256 INPUT TEST");
        $display("==============================================================");

        for (i = 0; i < 16; i = i + 1) begin

            for (j = 0; j < 16; j = j + 1) begin

                a = i;
                b = j;

                #2;

                error_without = nec1_result - exact_result;
                error_with    = ec1_result - exact_result;

                if (error_without != 0)
                    count_without = count_without + 1;

                if (error_with != 0)
                    count_with = count_with + 1;

            end

        end


        //================================================
        // FINAL SUMMARY
        //================================================

        $display("");
        $display("==============================================================");
        $display("                    FINAL SUMMARY");
        $display("==============================================================");

        $display("Total input combinations       = 256");

        $display("Non-zero error cases - NEC-1   = %0d",
                 count_without);

        $display("Non-zero error cases - EC-1    = %0d",
                 count_with);

        $display("==============================================================");

        #10;

        $finish;

    end

endmodule
