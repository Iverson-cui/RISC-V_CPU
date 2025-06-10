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

    // second pipeline register
    // output declaration of module param_dff
    wire [95:0] q;
    wire[31:0] PCPlus4D;
    wire[31:0] pcD;
    wire[31:0] instrD;
    wire [4:0] Rs1D;
    wire [4;0] Rs2D;
    wire [4;0] RdD;

    param_dff #(
                  .WIDTH 	(96  ))
              u_param_dff(
                  .clk   	(clk    ),
                  .rst_n 	(~reset  ),
                  .flush 	(FlushD  ),
                  .stall 	(StallD  ),
                  .d     	({instr,pc,PCPlus4F}     ),
                  .q     	(q      )
              );

    assign q[31:0]=PCPlus4D;
    assign q[63:32]=pcD;
    assign q[92:64]=instrD;
    // output declaration of module control
    wire jumpD;
    wire branchD;
    wire [1:0] ResultSrcD;
    wire [2:0] ALUControlD;
    wire ALUSrcD;
    wire [1:0] ImmSrcD;
    wire RegWriteD;
    //wire zero;
    control u_control(
                .op         	(instrD[6:0]          ),
                .funct3     	(instrD[14:12]      ),
                .funct7b5   	(instrD[30]    ),
                // .zero       	(zero        ), // from ALU
                .jump       	(jumpD       ),
                .branch     	(branchD     ),
                // .PCSrc      	(PCSrc       ),
                .ResultSrc  	(ResultSrcD   ),
                .MemWrite   	(write_enaD    ),
                .ALUControl 	(ALUControlD  ),
                .ALUSrc     	(ALUSrcD      ),
                .ImmSrc     	(ImmSrcD      ),
                .RegWrite   	(RegWriteD    )
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
    wire [31:0] result;
    // TODO: RegWrite, a3 and wd3 unchanged.
    regfile u_regfile(
                .clk 	(clk  ),
                .we3 	(RegWrite  ),
                .a1  	(instrD[19:15]   ),
                .a2  	(instrD[24:20]   ),
                .a3  	(instrD[11:7]   ),
                .wd3 	(result  ),
                // rd1 and rd2 remain unchanged into the third pipeline register
                .rd1 	(rd1  ),
                .rd2 	(rd2  )
            );

    // output declaration of module extend
    wire [31:0] ImmExtD;

    extend u_extend(
               .instr  	(instrD[31:7]   ),
               .ImmSrc 	(ImmSrcD  ),
               .out    	(ImmExtD     )
           );

    // pc logic
    // output declaration of module adder
    wire [31:0] PCPlus4F;

    adder u_adder(
              .a   	(pc    ),
              .b   	(4    ),
              .sum 	(PCPlus4F  )
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

    // TODO:PCTarget and PCSrc unchanged
    mux2 #(
             .WIDTH 	(32))
         u_mux2(
             .a   	(PCPlus4F    ),
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
             .out 	(result  )
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
