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
    wire [95:0] q2;
    wire[31:0] PCPlus4D;
    wire[31:0] pcD;
    wire[31:0] instrD;
    wire [4:0] Rs1D;
    wire [4:0] Rs2D;
    wire [4:0] RdD;
    assign Rs1D = instrD[19:15];
    assign Rs2D = instrD[24:20];
    assign RdD = instrD[11:7];

    param_dff #(
                  .WIDTH 	(96  ))
              u_param_dff(
                  .clk   	(clk    ),
                  .rst_n 	(~reset  ),
                  .flush 	(FlushD  ),
                  .stall 	(StallD  ),
                  .d     	({instr,pc,PCPlus4F}     ),
                  .q     	(q2      )
              );

    assign q2[31:0]=PCPlus4D;
    assign q2[63:32]=pcD;
    assign q2[92:64]=instrD;
    // output declaration of module control
    wire jumpD;
    wire branchD;
    wire [1:0] ResultSrcD;
    wire [2:0] ALUControlD;
    wire ALUSrcD;
    wire [1:0] ImmSrcD;
    wire RegWriteD;
    wire zeroE;
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
    wire PCSrcE;

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
    wire [31:0] ALUResultE;
    wire [31:0] SrcAE;
    wire [31:0] SrcBE;
    alu u_alu(
            .a          	(SrcAE           ),
            .b          	(SrcBE          ),
            .ALUControl 	(ALUControlE  ),
            .result     	(ALUResultE      ),
            .zero       	(zeroE        )
        );

    assign PCSrcE= (ZeroE & branchE) | jumpE;

    assign DataAddr=ALUResultE;
    // output declaration of module regfile

    // forth pipeline register
    // output declaration of module param_dff
    reg [127:0] q4;

    param_dff #(
                  .WIDTH 	(128  ))
              u_param_dff(
                  .clk   	(clk    ),
                  .rst_n 	(~reset  ),
                  .flush 	(0  ),
                  .stall 	(0  ),
                  .d     	({ALUResultE,WriteDataE,PCPlus4E,RegWriteE,ResultSrcE,MemWriteE,RdE}     ),
                  .q     	(q4      )
              );

    // {ALUResultM,WriteDataM,PCPlus4M,RegWriteM,ResultSrcM,MemWriteM,RdM}
    wire [31:0] ALUResultM, WriteDataM, PCPlus4M;
    wire RegWriteM;
    wire [1:0] ResultSrcM;
    wire MemWriteM;
    wire [4:0] RdM;
    assign ALUResultM = q4[127:96];  // 32 bits
    assign WriteDataM = q4[95:64];    // 32 bits
    assign PCPlus4M = q4[63:32];      // 32 bits
    assign RegWriteM = q4[31];        // 1 bit
    assign ResultSrcM = q4[30:29];    // 2 bits
    assign MemWriteM = q4[28];       // 1 bit
    assign RdM = q4[27:23];           // 5 bits

    // connect output with the signals
    assign DataAddr = ALUResultM;
    assign write_ena = MemWriteM;
    assign write_data = WriteDataM;
    wire [31:0] M;
    assign ReadDataM = read_data;

    wire [31:0] rd2;
    assign write_data=rd2;
    wire [31:0] result;

    regfile u_regfile(
                .clk 	(clk  ),
                .we3 	(RegWriteW  ),
                .a1  	(instrD[19:15]   ),
                .a2  	(instrD[24:20]   ),
                .a3  	(RdW   ),
                .wd3 	(ResultW  ),
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


    // output declaration of module mux3 RD1E

    // b and c remain unchanged.
    mux3 #(
             .WIDTH 	(32  ))
         u_mux3(
             .a   	(rd1E    ),
             .b   	(b    ),
             .c   	(c    ),
             .sel 	(ForwardAE  ),
             .out 	(SrcAE  )
         );

    // output declaration of module mux3 RD2E
    // b and c remain unchanged.
    wire [31:0] WriteDataE;
    mux3 #(
             .WIDTH 	(32  ))
         u_mux3(
             .a   	(rd2E    ),
             .b   	(b    ),
             .c   	(c    ),
             .sel 	(ForwardBE  ),
             .out 	(WriteDataE  )
         );

    // output declaration of module mux2 SrcBE
    // wire [31:0] out;

    mux2 #(
             .WIDTH 	(32  ))
         u_mux2(
             .a   	(WriteDataE    ),
             .b   	(ImmExtD    ),
             .sel 	(ALUSrcE  ),
             .out 	(SrcBE  )
         );




    // third pipeline register
    // output declaration of module param_dff
    // 6 words
    wire [191:0] q3;

    param_dff #(
                  .WIDTH 	(192  ))
              u_param_dff(
                  .clk   	(clk    ),
                  .rst_n 	(~reset  ),
                  .flush 	(FlushE  ),
                  .stall 	(0  ),
                  .d     	({rd1,rd2,pcD,ImmExtD,PCPlus4D,RegWriteD,ResultSrcD,write_enaD,jumpD,branchD,ALUControlD,ALUSrcD,Rs1D,Rs2D,RdD}      ),
                  .q     	(q3      )
              );
    // Assign individual signals from the 192-bit output
    wire [31:0] rd1E, rd2E, pcE, ImmExtE, PCPlus4E;
    wire RegWriteE;
    wire [1:0] ResultSrcE;
    wire MemWriteE;
    wire jumpE, branchE;
    wire [2:0] ALUControlE;
    wire ALUSrcE;
    wire [4:0] Rs1E, Rs2E, RdE;
    assign rd1E = q3[191:160];        // 32 bits
    assign rd2E = q3[159:128];        // 32 bits
    assign pcE = q3[127:96];          // 32 bits
    assign ImmExtE = q3[95:64];       // 32 bits
    assign PCPlus4E = q3[63:32];      // 32 bits
    assign RegWriteE = q3[31];        // 1 bit
    assign ResultSrcE = q3[30:29];    // 2 bits
    assign MemWriteE = q3[28];       // 1 bit
    assign jumpE = q3[27];            // 1 bit
    assign branchE = q3[26];          // 1 bit
    assign ALUControlE = q3[25:23];   // 3 bits
    assign ALUSrcE = q3[22];          // 1 bit
    assign Rs1E = q3[21:17];          // 5 bits
    assign Rs2E = q3[16:12];          // 5 bits
    assign RdE = q3[11:7];            // 5 bits




    // pc logic
    // output declaration of module adder
    wire [31:0] PCPlus4F;

    adder u_adder(
              .a   	(pc    ),
              .b   	(4    ),
              .sum 	(PCPlus4F  )
          );

    // output declaration of module adder
    wire [31:0] PCTargetE;

    adder u_adder_target(
              .a   	(pcE    ),
              .b   	(ImmExtE    ),
              .sum 	(PCTargetE  )
          );

    // output declaration of module mux2
    wire [31:0] PCNext;

    mux2 #(
             .WIDTH 	(32))
         u_mux2(
             .a   	(PCPlus4F    ),
             .b   	(PCTargetE    ),
             .sel 	(PCSrcE      ),
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

    // fifth pipeline register
    // output declaration of module param_dff
    reg [127:0] q5;

    param_dff #(
                  .WIDTH 	(128  ))
              u_param_dff(
                  .clk   	(clk    ),
                  .rst_n 	(~reset  ),
                  .flush 	(0  ),
                  .stall 	(0  ),
                  .d     	({ALUResultM,ReadDataM,PCPlus4M,RegWriteM,ResultSrcM,RdM}     ),
                  .q     	(q5      )
              );

    wire [31:0] ALUResultW, ReadDataW, PCPlus4W;
    wire RegWriteW;
    wire [1;0] ResultSrcW;
    wire [4:0] RdW;
    assign ALUResultW = q5[127:96];  // 32 bits
    assign ReadDataW = q5[95:64];    // 32 bits
    assign PCPlus4W = q5[63:32];      // 32 bits
    assign RegWriteW = q5[31];        // 1 bit
    assign ResultSrcW = q5[30:29];    // 2 bits
    assign RdW = q5[27:23];           // 5 bits

    // output declaration of module mux3 ReadDataW
    wire [31:0] ResultW;

    mux3 #(
             .WIDTH 	(32  ))
         u_mux3(
             .a   	(ALUResultW    ),
             .b   	(ReadDataW    ),
             .c   	(PCPlus4W  ),
             .sel 	(ResultSrcW  ),
             .out 	(ResultW  )
         );



endmodule

.c   	(c    ),
      .sel 	(sel  ),
      .out 	(out  )
      );



endmodule
