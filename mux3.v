module mux3
    #(
         parameter WIDTH = 32  // Default width is 32 bit
     )
     (
         input [WIDTH-1:0] a,     // First input
         input [WIDTH-1:0] b,     // Second input
         input [WIDTH-1:0] c,     // Third input
         input [1:0] sel,        // Select line: 00 selects a, 01 selects b, 10 selects c
         output [WIDTH-1:0] out   // Output
     );

    // Multiplexer logic using ternary operator
    assign out = sel[1] ? c :
           (sel[0] ? b : a);

endmodule
