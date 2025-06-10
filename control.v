module control
    (
        input [6:0] op,
        input [2:0] funct3,
        input funct7b5,
        input zero,
        output PCSrc,
        output [1:0] ResultSrc,
        output MemWrite,
        output [2:0] ALUControl,
        output ALUSrc,
        output [1:0] ImmSrc,
        output RegWrite
    );

    // output declaration of module maindec
    wire Branch;
    wire Jump;
    wire [1:0] ALUOp;

    maindec u_maindec(
                .op        	(op         ),
                .ResultSrc 	(ResultSrc  ),
                .MemWrite  	(MemWrite   ),
                .Branch    	(Branch     ),
                .ALUSrc    	(ALUSrc     ),
                .RegWrite  	(RegWrite   ),
                .Jump      	(Jump       ),
                .ImmSrc    	(ImmSrc     ),
                .ALUOp     	(ALUOp      )
            );
    assign PCSrc=Jump | (Branch & zero); // PCSrc = Jump or Branch and zero

    // output declaration of module aludec
    reg [2:0] ALUControl;

    aludec u_aludec(
               .opb5       	(op[5]     ),
               .funct3     	(funct3      ),
               .funct7b5   	(funct7b5    ),
               .ALUOp      	(ALUOp       ),
               .ALUControl 	(ALUControl  )
           );


endmodule
