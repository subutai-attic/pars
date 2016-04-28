`timescale 1ns / 1ps

    module full_mas_deserializer (
        input clk,
        input reset,
        input [4:0] serial_i,
        input [4:0] lvds_control,
        output [4:0] st_flag,
        output [183:0] data_o
     );
     
     deserializer_8b des_0 (
         .clk(clk),
         .reset(reset),
         .serial_i(serial_i[0]),
         .lvds_control(lvds_control[0]),
         .st_flag(st_flag[0]),
         .data_o(data_o[7:0])
     );
    deserializer_8b des_1 (
         .clk(clk),
         .reset(reset),
         .serial_i(serial_i[1]),
         .lvds_control(lvds_control[1]),
         .st_flag(st_flag[1]),
         .data_o(data_o[15:8])
     );
    deserializer_8b des_2 (
         .clk(clk),
         .reset(reset),
         .serial_i(serial_i[2]),
         .lvds_control(lvds_control[2]),
         .st_flag(st_flag[2]),
         .data_o(data_o[23:16])
     );
    deserializer_8b des_3 (
         .clk(clk),
         .reset(reset),
         .serial_i(serial_i[3]),
         .lvds_control(lvds_control[3]),
         .st_flag(st_flag[3]),
         .data_o(data_o[31:24])
     );
    deserializer_8b des_4 (
         .clk(clk),
         .reset(reset),
         .serial_i(serial_i[4]),
         .lvds_control(lvds_control[4]),
         .st_flag(st_flag[4]),
         .data_o(data_o[39:32])
     );
//    deserializer_8b des_5 (
//         .clk(clk),
//         .reset(reset),
//         .serial_i(serial_i[5]),
//         .st_flag(st_flag[5]),
//         .data_o(data_o[47:40])
//     );
//    deserializer_8b des_6 (
//         .clk(clk),
//         .reset(reset),
//         .serial_i(serial_i[6]),
//         .st_flag(st_flag[6]),
//         .data_o(data_o[55:48])
//     );
//    deserializer_8b des_7 (
//         .clk(clk),
//         .reset(reset),
//         .serial_i(serial_i[7]),
//         .st_flag(st_flag[7]),
//         .data_o(data_o[63:56])
//     );
//    deserializer_8b des_8 (
//         .clk(clk),
//         .reset(reset),
//         .serial_i(serial_i[8]),
//         .st_flag(st_flag[8]),
//         .data_o(data_o[71:64])
//     );
//    deserializer_8b des_9 (
//         .clk(clk),
//         .reset(reset),
//         .serial_i(serial_i[9]),
//         .st_flag(st_flag[9]),
//         .data_o(data_o[79:72])
//     );
//    deserializer_8b des_10 (
//         .clk(clk),
//         .reset(reset),
//         .serial_i(serial_i[10]),
//         .st_flag(st_flag[10]),
//         .data_o(data_o[87:80])
//     );
//    deserializer_8b des_11 (
//         .clk(clk),
//         .reset(reset),
//         .serial_i(serial_i[11]),
//         .st_flag(st_flag[11]),
//         .data_o(data_o[95:88])
//     );
//    deserializer_8b des_12 (
//         .clk(clk),
//         .reset(reset),
//         .serial_i(serial_i[12]),
//         .st_flag(st_flag[12]),
//         .data_o(data_o[103:96])
//     );
//    deserializer_8b des_13 (
//         .clk(clk),
//         .reset(reset),
//         .serial_i(serial_i[13]),
//         .st_flag(st_flag[13]),
//         .data_o(data_o[111:104])
//     );
//    deserializer_8b des_14 (
//         .clk(clk),
//         .reset(reset),
//         .serial_i(serial_i[14]),
//         .st_flag(st_flag[14]),
//         .data_o(data_o[119:112])
//     );
//    deserializer_8b des_15 (
//         .clk(clk),
//         .reset(reset),
//         .serial_i(serial_i[15]),
//         .st_flag(st_flag[15]),
//         .data_o(data_o[127:120])
//     );
//    deserializer_8b des_16 (
//         .clk(clk),
//         .reset(reset),
//         .serial_i(serial_i[16]),
//         .st_flag(st_flag[16]),
//         .data_o(data_o[135:128])
//     );
//    deserializer_8b des_17 (
//         .clk(clk),
//         .reset(reset),
//         .serial_i(serial_i[17]),
//         .st_flag(st_flag[17]),
//         .data_o(data_o[143:136])
//     );
//    deserializer_8b des_18 (
//         .clk(clk),
//         .reset(reset),
//         .serial_i(serial_i[18]),
//         .st_flag(st_flag[18]),
//         .data_o(data_o[151:144])
//     );
//    deserializer_8b des_19 (
//         .clk(clk),
//         .reset(reset),
//         .serial_i(serial_i[19]),
//         .st_flag(st_flag[19]),
//         .data_o(data_o[159:152])
//     );
//    deserializer_8b des_20 (
//         .clk(clk),
//         .reset(reset),
//         .serial_i(serial_i[20]),
//         .st_flag(st_flag[20]),
//         .data_o(data_o[167:160])
//     );
//    deserializer_8b des_21 (
//         .clk(clk),
//         .reset(reset),
//         .serial_i(serial_i[21]),
//         .st_flag(st_flag[21]),
//         .data_o(data_o[175:168])
//     );
//    deserializer_8b des_22 (
//         .clk(clk),
//         .reset(reset),
//         .serial_i(serial_i[22]),
//         .st_flag(st_flag[22]),
//         .data_o(data_o[183:176])
//     );                                                                                                   
        
endmodule
