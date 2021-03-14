`timescale 1ns / 1ps

module first_sseg_driver_test
    #(parameter FINAL_VALUE = 500000, BITS = 3)(
    //input [2:0] X,
    //input DP_ctrl,
    //input en,
    input clk,
    output [6:0] bcd,
    output [7:0] AN,
    output DP
    );
    
    wire [BITS - 1:0] X, active_digit;
    wire slow_clk;
    
    timer_parameter #(FINAL_VALUE) clk_div (
        .clk(clk),
        .reset_n(1),
        .enable(1),
        .done(slow_clk)
    );
    
    udl_counter #(BITS)(
        .clk(clk),
        .reset_n(1),
        .enable(slow_clk),
        .up(1),
        .load(0),
        .D(0),
        .Q(X)
    );
    
    assign active_digit = X;
    
    first_sseg_driver driver(
    .num(X),
    .active_digit(active_digit),
    .DP_ctrl(1),
    .en(1),
    .bcd(bcd),
    .AN(AN),
    .DP(DP)
    );
    
endmodule
