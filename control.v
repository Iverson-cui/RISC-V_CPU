module control
    (
        input [6:0] op,
        input [2:0] funct3,
        input funct7b5,
        // in pipeline, zero is not needed.
        // input zero
        ,
        //output PCSrc,
        // in pipeline, remove PCSrc, add Jump and Branch. PCSrc is out of control now, a individual signal.
        output jump,
        output branch,
        output [1:0] ResultSrc,
        output MemWrite,
        output [2:0] ALUControl,
        output ALUSrc,
        output [1:0] ImmSrc,
        output RegWrite
    );

    // output declaration of module maindec
    wire [1:0] ALUOp;

    maindec u_maindec(
                .op        	(op         ),
                .ResultSrc 	(ResultSrc  ),
                .MemWrite  	(MemWrite   ),
                .Branch    	(branch     ),
                .ALUSrc    	(ALUSrc     ),
                .RegWrite  	(RegWrite   ),
                .Jump      	(jump       ),
                .ImmSrc    	(ImmSrc     ),
                .ALUOp     	(ALUOp      )
            );
    // assign PCSrc=Jump | (Branch & zero); // PCSrc = Jump or Branch and zero

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
