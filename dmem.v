module dmem
    (
        input [31:0] a,
        input [31:0] wd,
        input clk,
        input we, // write enable
        output [31:0] rd
    );
    // 64 words, each with 32 bits
    reg [31:0] RAM[63:0];
    assign rd = RAM[a[31:2]]; // word aligned
    // address is 32 bits, but we only have 64 entries(6 bits). We need to divide by 4, 0000, 0001, 0010, 0011 all points to the 0th entry. This is for turning byte address into word address.
    always @(posedge clk) begin
        if (we) begin
            RAM[a[31:2]] <= wd; // write data to memory
        end
    end
endmodule
