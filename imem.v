module imem
    (
        input  [31:0] a,
        output [31:0] rd
    );
    // 64 words, each with 32 bits
    // input a is the byte address. Four bytes make a word. output rd with a=0,1,2,3 is the same,

    reg [31:0] RAM[63:0];
    assign rd = RAM[a[31:2]]; // word aligned
    // address is 32 bits, but we only have 64 entries(6 bits). We need to divide by 4, 0000, 0001, 0010, 0011 all points to the 0th entry. This is for turning byte address into word address.
endmodule
