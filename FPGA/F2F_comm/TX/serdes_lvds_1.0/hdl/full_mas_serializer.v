`timescale 1ns / 1ps

    module full_mas_serializer(
        input clk,
        input reset,
        input [183:0] data_i,
        input [4:0] st_flag,
        input [4:0] start_i,
        input end_flag_i,
        output [4:0] lvds_busy,
        output [4:0] lvds_control,
        output [4:0] serial_o
     );
          
     serializer_8b ser_0(
         .clk(clk),
         .reset(reset),
         .data_i(data_i[7:0]),
         .start_i(start_i[0]),
         .st_flag(st_flag[0]),
         .end_flag_i(end_flag_i),
         .lvds_busy(lvds_busy[0]),
         .lvds_control(lvds_control[0]),
         .serial_o(serial_o[0])
     );     
     serializer_8b ser_1(
         .clk(clk),
         .reset(reset),
         .data_i(data_i[15:8]),
         .start_i(start_i[1]),
         .st_flag(st_flag[1]),
         .end_flag_i(end_flag_i),
         .lvds_busy(lvds_busy[1]),
         .lvds_control(lvds_control[1]),         
         .serial_o(serial_o[1])
     );   
     serializer_8b ser_2(
         .clk(clk),
         .reset(reset),
         .data_i(data_i[23:16]),
         .start_i(start_i[2]),
         .st_flag(st_flag[2]),
         .end_flag_i(end_flag_i),
         .lvds_busy(lvds_busy[2]),
         .lvds_control(lvds_control[2]),
         .serial_o(serial_o[2])
     );   
     serializer_8b ser_3(
         .clk(clk),
         .reset(reset),
         .data_i(data_i[31:24]),
         .start_i(start_i[3]),
         .st_flag(st_flag[3]),
         .end_flag_i(end_flag_i),
         .lvds_busy(lvds_busy[3]),
         .lvds_control(lvds_control[3]),
         .serial_o(serial_o[3])
     );      
     serializer_8b ser_4(
         .clk(clk),
         .reset(reset),
         .data_i(data_i[39:32]),
         .start_i(start_i[4]),
         .st_flag(st_flag[4]),
         .end_flag_i(end_flag_i),
         .lvds_busy(lvds_busy[4]),
         .lvds_control(lvds_control[4]),
         .serial_o(serial_o[4])
     );  
//     serializer_8b ser_5(
//         .clk(clk),
//         .reset(reset),
//         .data_i(data_i[47:40]),
//         .start_i(start_i[5]),
//         .st_flag(st_flag[5]),
//         .lvds_busy(lvds_busy[5]),
//         .lvds_control(lvds_control[5]),
//         .serial_o(serial_o[5])
//     );  
//     serializer_8b ser_6(
//         .clk(clk),
//         .reset(reset),
//         .data_i(data_i[55:48]),
//         .start_i(start_i[6]),
//         .st_flag(st_flag[6]),
//         .lvds_busy(lvds_busy[6]),
//         .lvds_control(lvds_control[6]),
//         .serial_o(serial_o[6])
//     );  
//     serializer_8b ser_7(
//         .clk(clk),
//         .reset(reset),
//         .data_i(data_i[63:56]),
//         .start_i(start_i[7]),
//         .st_flag(st_flag[7]),
//         .lvds_busy(lvds_busy[7]),
//         .lvds_control(lvds_control[7]),
//         .serial_o(serial_o[7])
//     );  
//     serializer_8b ser_8(
//         .clk(clk),
//         .reset(reset),
//         .data_i(data_i[71:64]),
//         .start_i(start_i[8]),
//         .st_flag(st_flag[8]),
//         .lvds_busy(lvds_busy[8]),
//         .lvds_control(lvds_control[8]),
//         .serial_o(serial_o[8])
//     );  
//     serializer_8b ser_9(
//         .clk(clk),
//         .reset(reset),
//         .data_i(data_i[79:72]),
//         .start_i(start_i[9]),
//         .st_flag(st_flag[9]),
//         .lvds_busy(lvds_busy[9]),
//         .lvds_control(lvds_control[9]),
//         .serial_o(serial_o[9])
//     );  
//     serializer_8b ser_10(
//         .clk(clk),
//         .reset(reset),
//         .data_i(data_i[87:80]),
//         .start_i(start_i[10]),
//         .st_flag(st_flag[10]),
//         .lvds_busy(lvds_busy[10]),
//         .lvds_control(lvds_control[10]),
//         .serial_o(serial_o[10])
//     );  
//     serializer_8b ser_11(
//         .clk(clk),
//         .reset(reset),
//         .data_i(data_i[95:88]),
//         .start_i(start_i[11]),
//         .st_flag(st_flag[11]),
//         .lvds_busy(lvds_busy[11]),
//         .lvds_control(lvds_control[11]),
//         .serial_o(serial_o[11])
//     );  
//     serializer_8b ser_12(
//         .clk(clk),
//         .reset(reset),
//         .data_i(data_i[103:96]),
//         .start_i(start_i[12]),
//         .st_flag(st_flag[12]),
//         .lvds_busy(lvds_busy[12]),
//         .lvds_control(lvds_control[12]),
//         .serial_o(serial_o[12])
//     );  
//     serializer_8b ser_13(
//         .clk(clk),
//         .reset(reset),
//         .data_i(data_i[111:104]),
//         .start_i(start_i[13]),
//         .st_flag(st_flag[13]),
//         .lvds_busy(lvds_busy[13]),
//         .lvds_control(lvds_control[13]),
//         .serial_o(serial_o[13])
//     );  
//     serializer_8b ser_14(
//         .clk(clk),
//         .reset(reset),
//         .data_i(data_i[119:112]),
//         .start_i(start_i[14]),
//         .st_flag(st_flag[14]),
//         .lvds_busy(lvds_busy[14]),
//         .lvds_control(lvds_control[14]),
//         .serial_o(serial_o[14])
//     );  
//     serializer_8b ser_15(
//         .clk(clk),
//         .reset(reset),
//         .data_i(data_i[127:120]),
//         .start_i(start_i[15]),
//         .st_flag(st_flag[15]),
//         .lvds_busy(lvds_busy[15]),
//         .lvds_control(lvds_control[15]),
//         .serial_o(serial_o[15])
//     );  
//     serializer_8b ser_16(
//         .clk(clk),
//         .reset(reset),
//         .data_i(data_i[135:128]),
//         .start_i(start_i[16]),
//         .st_flag(st_flag[16]),
//         .lvds_busy(lvds_busy[16]),
//         .lvds_control(lvds_control[16]),
//         .serial_o(serial_o[16])
//     );  
//     serializer_8b ser_17(
//         .clk(clk),
//         .reset(reset),
//         .data_i(data_i[143:136]),
//         .start_i(start_i[17]),
//         .st_flag(st_flag[17]),
//         .lvds_busy(lvds_busy[17]),
//         .lvds_control(lvds_control[17]),
//         .serial_o(serial_o[17])
//     );  
//     serializer_8b ser_18(
//         .clk(clk),
//         .reset(reset),
//         .data_i(data_i[151:144]),
//         .start_i(start_i[18]),
//         .st_flag(st_flag[18]),
//         .lvds_busy(lvds_busy[18]),
//         .lvds_control(lvds_control[18]),
//         .serial_o(serial_o[18])
//     );  
//     serializer_8b ser_19(
//         .clk(clk),
//         .reset(reset),
//         .data_i(data_i[159:152]),
//         .start_i(start_i[19]),
//         .st_flag(st_flag[19]),
//         .lvds_busy(lvds_busy[19]),
//         .lvds_control(lvds_control[19]),
//         .serial_o(serial_o[19])
//     );  
//     serializer_8b ser_20(
//         .clk(clk),
//         .reset(reset),
//         .data_i(data_i[167:160]),
//         .start_i(start_i[20]),
//         .st_flag(st_flag[20]),
//         .lvds_busy(lvds_busy[20]),
//         .lvds_control(lvds_control[20]),
//         .serial_o(serial_o[20])
//     );  
//     serializer_8b ser_21(
//         .clk(clk),
//         .reset(reset),
//         .data_i(data_i[175:168]),
//         .start_i(start_i[21]),
//         .st_flag(st_flag[21]),
//         .lvds_busy(lvds_busy[21]),
//         .lvds_control(lvds_control[21]),
//         .serial_o(serial_o[21])
//     );  
//     serializer_8b ser_22(
//         .clk(clk),
//         .reset(reset),
//         .data_i(data_i[183:176]),
//         .start_i(start_i[22]),
//         .st_flag(st_flag[22]),
//         .lvds_busy(lvds_busy[22]),
//         .lvds_control(lvds_control[22]),
//         .serial_o(serial_o[22])
//     );                                                                                                                
                    
    endmodule
