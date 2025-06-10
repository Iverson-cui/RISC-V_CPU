module alu (
        input  [31:0] a,
        input  [31:0] b,
        input  [2:0]  ALUControl,
        output [31:0] result,
        output        zero
    );

    reg [31:0] result_reg;
    assign result = result_reg;
    assign zero = (result_reg == 32'b0);

    always @(*) begin
        case (ALUControl)
            3'b000:
                result_reg = a + b; // ADD
            3'b001:
                result_reg = a - b; // SUB
            3'b011:
                result_reg = a | b; // OR
            3'b010:
                result_reg = a ^ b; // AND
            3'b101:
                result_reg = (a < b) ? 32'b1 : 32'b0; // SET LESS THAN
            default:
                result_reg = 32'b0; // undefined case
        endcase
    end
endmodule
