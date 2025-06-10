// Enhanced Parameterized D Flip-Flop Module with Pipeline Control
// This flip-flop includes flush and stall functionality commonly used in processor pipelines
module param_dff #(
        parameter WIDTH = 8  // Default width is 8 bits, but can be overridden
    ) (
        input  wire             clk,    // Clock signal
        input  wire             rst_n,  // Active-low asynchronous reset (highest priority)
        input  wire             flush,  // Active-high flush signal (second priority)
        input  wire             stall,  // Active-high stall signal (third priority)
        input  wire [WIDTH-1:0] d,      // Data input (WIDTH bits wide)
        output reg  [WIDTH-1:0] q       // Data output (WIDTH bits wide)
    );

    // Sequential logic block - executes on clock edges or reset
    // Priority order: reset > flush > stall > normal operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Highest priority: Asynchronous reset
            // This happens immediately when rst_n goes low, regardless of clock
            q <= {WIDTH{1'b0}};  // Clear all bits to 0

        end
        else begin
            // All other operations happen synchronously on rising clock edge

            if (flush) begin
                // Second priority: Flush operation
                // Clear the register contents to simulate pipeline flush
                q <= {WIDTH{1'b0}};  // Set all bits to 0

            end
            else if (stall) begin
                // Third priority: Stall operation
                // Maintain current value - do not update from input
                q <= q;  // Keep the same value (this line is actually redundant but makes intent clear)

            end
            else begin
                // Lowest priority: Normal operation
                // Load new data from input on rising clock edge
                q <= d;
            end
        end
    end

endmodule
