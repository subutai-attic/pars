`timescale 1ns / 1ps

    module deserializer_8b (
        input clk,
        input [4:0] serial,
        input strb,
        output [39:0] datout,
        output [49:0] encode
    );
    
    reg [49:0] data_r;
    
    initial begin
        data_r <= 0;        
    end
    
    always @(posedge clk)
    begin
        if (strb) begin
            data_r[9:0]   <= {data_r[8:0],   serial[0]};
            data_r[19:10] <= {data_r[18:10], serial[1]};
            data_r[29:20] <= {data_r[28:20], serial[2]};
            data_r[39:30] <= {data_r[38:30], serial[3]};
            data_r[49:40] <= {data_r[48:40], serial[4]}; 
        end                
    end
    assign encode = data_r;
    
    decoder dec_00(
        .datain(data_r[9:0]),
        .dataout(datout[7:0])
    );
    decoder dec_01(
        .datain(data_r[19:10]),
        .dataout(datout[15:8])
    ); 
    decoder dec_02(
        .datain(data_r[29:20]),
        .dataout(datout[23:16])
    ); 
    decoder dec_03(
        .datain(data_r[39:30]),
        .dataout(datout[31:24])
    ); 
    decoder dec_04(
        .datain(data_r[49:40]),
        .dataout(datout[39:32])
    );                     

    endmodule
