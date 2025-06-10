module hazardunit(
        input wire Rs1D,
        input wire Rs2D,
        input wire Rs1E,
        input wire Rs2E,
        input wire RdE,
        input wire PCSrcE,
        input wire ResultSrcE0,
        input wire RdM,
        input wire RegWriteM,
        input wire RdW,
        input wire RegWriteW,
        output wire StallF,
        output wire StallD,
        output wire FlushD,
        output wire FlushE,
        output wire [1:0] ForwardAE,
        output wire [1:0] ForwardBE
    );

    // Forward logic
    always @(*) begin
        // ForwardAE logic
        if (((Rs1E == RdM) & RegWriteM) & (Rs1E!=0)) begin
            ForwardAE = 2'b10;
        end
        else if (((Rs1E == RdW) & RegWriteW) & (Rs1E!=0)) begin
            ForwardAE = 2'b01;
        end
        else begin
            ForwardAE = 2'b00;
        end

        // ForwardBE logic
        if (((Rs2E == RdM) & RegWriteM) & (Rs2E!=0)) begin
            ForwardBE = 2'b10;
        end
        else if (((Rs2E == RdW) & RegWriteW) & (Rs2E!=0)) begin
            ForwardBE = 2'b01;
        end
        else begin
            ForwardBE = 2'b00;
        end
    end

    // Stall logic
    wire lwStall;
    assign lwStall=ResultSrcE0 & ((Rs1D==RdE) | (Rs2D == RdE));
    assign StallF = lwStall;
    assign StallD = lwStall;

    // Flush logic
    assign FlushD=PCSrcE;
    assign FlushE=lwStall|PCSrcE;

endmodule
