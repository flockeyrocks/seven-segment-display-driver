`timescale 1ns / 1ps

module counter_application
    #(parameter FINAL_VALUE = 256, CLOCK_COUNT = 100000000)(
    input [7:0] X,
    input clk, up, down, load, reset_n,
    output [7:0] AN,
    output [6:0] sseg,
    output DP
    );
    
    wire [7:0] Q;
    wire [11:0] bcd;
    wire [3:0] hex0_value, hex1_value, hex2_value;
    wire [5:0] I0, I1, I2;
    wire up_debounce, down_debounce, load_debounce, up_down_debounce;
    wire enable, en_count;
    wire DP_ctrl;
    
    //always enable
    assign enable = 1;
    //DP always off
    assign DP_ctrl = 1;
    
    reg up_down;
    
    //determine number of BITS from FINAL_VALUE count
    localparam BITS = $clog2(FINAL_VALUE);
    
    button up_button(
        .clk(clk),
        .in(up),
        .out(up_debounce)
    );
    
    button down_button(
        .clk(clk),
        .in(down),
        .out(down_debounce)
    );
    
    button load_button(
        .clk(clk),
        .in(load),
        .out(load_debounce)
    );
    
    always @(up_debounce, down_debounce)
    begin
        up_down = 1;
        case({up_debounce, down_debounce})
            00 : up_down = 0;
            01 : up_down = 0;
            10 : up_down = 1;
            11 : up_down = 1;
            default : up_down = 1;
        endcase
    end
    
    assign en_count = up_debounce | down_debounce | load_debounce;
    
    //counts up or down from 0-255
    //loads switch input if load button is pressed
    udl_counter #(BITS) count_255(
        .clk(clk),
        .reset_n(reset_n),
        .enable(en_count),
        .up(up_down),
        .load(load_debounce),
        .D(X),
        .Q(Q)
    );
    
    bin2bcd convert (
    .bin(Q),
    .bcd(bcd)
    );
    
    //split 12-bit bcd into hex
    assign hex2_value = bcd[11:8];
    assign hex1_value = bcd[7:4];
    assign hex0_value = bcd[3:0];
    
    //always enable, enter hex values, DP always off
    assign I2={enable,hex2_value,DP_ctrl};
    assign I1={enable,hex1_value,DP_ctrl}; 
    assign I0={enable,hex0_value,DP_ctrl}; 
    
    sseg_driver output_driver(
        .I0(I0),
        .I1(I1),
        .I2(I2),
        .clk(clk),
        .AN(AN),
        .bcd(sseg),
        .DP(DP)
    );
    
endmodule
