module extend
    (
        input [31:7] instr,
        input [1:0] ImmSrc,
        output [31:0] out
    );
    always @(*) begin
        case (ImmSrc)
            2'b00:
                out = { {20{instr[31]}}, instr[31:20] };
            2'b01:
                out = { {20{instr[31]}}, instr[31:25], instr[11:7] };
            2'b10:
                out = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0 };
            2'b11:
                out = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 }; // JALR
            default:
                out = 32'b0;           // Default case
        endcase
    end
endmodule
