module mux2
    #(
         parameter WIDTH = 32  // Default width is 32 bit
     )
     (
         input [WIDTH-1:0] a,     // First input
         input [WIDTH-1:0] b,     // Second input
         input sel,               // Select line: 0 selects a, 1 selects b
         output [WIDTH-1:0] out   // Output
     );

    // Multiplexer logic using ternary operator
    assign out = sel ? b : a;

endmodule
