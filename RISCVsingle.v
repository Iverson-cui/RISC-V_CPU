module RISCVsingle(
        input  clk,
        input  reset,
        // aside from what's needed to interact with imem and dmem, what's left is the clk and reset
        input  [31:0] instr,
        input  [31:0] read_data,
        output [31:0] pc,
        output [31:0] write_data,
        output        write_ena,
        output [31:0] DataAddr,
    );

    // output declaration of module control
    wire PCSrc;
    wire [1:0] ResultSrc;
    wire [2:0] ALUControl;
    wire ALUSrc;
    wire [1:0] ImmSrc;
    wire RegWrite;
    wire zero;
    control u_control(
                .op         	(instr[6:0]          ),
                .funct3     	(instr[14:12]      ),
                .funct7b5   	(instr[30]    ),
                .zero       	(zero        ), // from ALU
                .PCSrc      	(PCSrc       ),
                .ResultSrc  	(ResultSrc   ),
                .MemWrite   	(write_ena    ),
                .ALUControl 	(ALUControl  ),
                .ALUSrc     	(ALUSrc      ),
                .ImmSrc     	(ImmSrc      ),
                .RegWrite   	(RegWrite    )
            );

    // output declaration of module hazardunit
    // only declaration. how it connects to this RISCVsingle module is not finished.
    wire StallF;
    wire StallD;
    wire FlushD;
    wire FlushE;
    wire [1:0] ForwardAE;
    wire [1:0] ForwardBE;

    hazardunit u_hazardunit(
                   .Rs1D        	(Rs1D         ),
                   .Rs2D        	(Rs2D         ),
                   .Rs1E        	(Rs1E         ),
                   .Rs2E        	(Rs2E         ),
                   .RdE         	(RdE          ),
                   .PCSrcE      	(PCSrcE       ),
                   .ResultSrcE0 	(ResultSrcE0  ),
                   .RdM         	(RdM          ),
                   .RegWriteM   	(RegWriteM    ),
                   .RdW         	(RdW          ),
                   .RegWriteW   	(RegWriteW    ),
                   .StallF      	(StallF       ),
                   .StallD      	(StallD       ),
                   .FlushD      	(FlushD       ),
                   .FlushE      	(FlushE       ),
                   .ForwardAE   	(ForwardAE    ),
                   .ForwardBE   	(ForwardBE    )
               );




    // output declaration of module alu
    wire [31:0] ALUResult;
    wire [31:0] rd1;
    wire [31:0] SrcB;
    alu u_alu(
            .a          	(rd1           ),
            .b          	(SrcB          ),
            .ALUControl 	(ALUControl  ),
            .result     	(ALUResult      ),
            .zero       	(zero        )
        );

    assign DataAddr=ALUResult;
    // output declaration of module regfile

    wire [31:0] rd2;
    assign write_data=rd2;
    wire [31:0] wd3;
    regfile u_regfile(
                .clk 	(clk  ),
                .we3 	(RegWrite  ),
                .a1  	(instr[19:15]   ),
                .a2  	(instr[24:20]   ),
                .a3  	(instr[11:7]   ),
                .wd3 	(wd3  ),
                .rd1 	(rd1  ),
                .rd2 	(rd2  )
            );

    // output declaration of module extend
    wire [31:0] ImmExt;

    extend u_extend(
               .instr  	(instr   ),
               .ImmSrc 	(ImmSrc  ),
               .out    	(ImmExt     )
           );

    // pc logic
    // output declaration of module adder
    wire [31:0] PCPlus4;

    adder u_adder(
              .a   	(pc    ),
              .b   	(4    ),
              .sum 	(PCPlus4  )
          );

    // output declaration of module adder
    wire [31:0] PCTarget;

    adder u_adder_target(
              .a   	(pc    ),
              .b   	(ImmExt    ),
              .sum 	(PCTarget  )
          );

    // output declaration of module mux2
    wire [WIDTH-1:0] PCNext;

    mux2 #(
             .WIDTH 	(32))
         u_mux2(
             .a   	(PCPlus4    ),
             .b   	(PCTarget    ),
             .sel 	(PCSrc      ),
             .out 	(PCNext  )
         );

    // // output declaration of module flopr
    // reg [31:0] q;


    // flopr #(
    //           .WIDTH 	(32  ))
    //       u_flopr(
    //           .clk   	(clk    ),
    //           .reset 	(0  ),
    //           .d     	(PCNext      ),
    //           .q     	(pc      )
    //       );

    // first pipeline register
    param_dff #(
                  .WIDTH 	(32  ))
              u_param_dff(
                  .clk   	(clk    ),
                  // in the module, reset is active low
                  .rst_n 	(~reset  ),
                  .flush 	(0  ),
                  .stall 	(StallF  ),
                  .d     	(PCNext      ),
                  .q     	(pc      )
              );


    // output declaration of module mux3
    wire [31:0] out;

    mux3 #(
             .WIDTH 	(32  ))
         u_mux3(
             .a   	(ALUResult    ),
             .b   	(read_data    ),
             .c   	(PCPlus4  ),
             .sel 	(ResultSrc  ),
             .out 	(wd3  )
         );

    // output declaration of module mux2

    mux2 #(
             .WIDTH 	(32  ))
         u_mux2(
             .a   	(rd2    ),
             .b   	(ImmExt    ),
             .sel 	(ALUSrc    ),
             .out 	(SrcB      )
         );

endmodule
