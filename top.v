module top
    (
        input clk,
        input reset,


    );

    // output declaration of module imem
    wire [31:0] instr;
    wire [31:0] pc;
    imem u_imem(
             .a  	(pc   ),
             .rd 	(instr  )
         );

    // output declaration of module dmem
    wire [31:0] read_data; // read data result
    wire write_ena; // write enable
    wire [31:0] DataAddr; // address to read or write
    wire [31:0] write_data; // data to write

    dmem u_dmem(
             .a   	(DataAddr    ),
             .wd  	(write_data   ),
             .clk 	(clk  ),
             .we  	(write_ena   ),
             .rd  	(read_data   )
         );



    RISCVsingle u_RISCVsingle(
                    .clk(clk),
                    .reset(reset),
                    .instr(instr),
                    .read_data(read_data),
                    .pc(pc),
                    .write_data(write_data),
                    .write_ena(write_ena),
                    .DataAddr(DataAddr)
                );
endmodule
