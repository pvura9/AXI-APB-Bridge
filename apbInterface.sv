//master interface - apb3(because axi --> apb)
//inputs - signal is driven by m/s and used by bridge
//outputs - signal driven by bridge and sent to m/s
//key apb3 signals used in my implementation
//apb peripheral address

`timescale 1ns/1ps
interface apbInterface #(
    parameter int ADDRESS_WIDTH = 32,
    parameter int DATA_WIDTH = 32
);
    //global signals
    logic clk;
    logic rst;

    //signals
    //apb peripheral address
    logic[31:0] PADDR;
    //apb write enable
    logic PWRITE;
    //apb peripheral select
    logic PSEL;
    //apb enable signal
    logic PENABLE;
    //apb write data
    logic[31:0] PWDATA;
    //apb read data
    logic[31:0] PRDATA;
    //apb ready signal
    logic PREADY;
    //apb write strobe
    logic[3:0] PSTRB;
    //apb slave error signal
    logic PSLVERR;


    //inputs --> the "response" signals (master receives these)
    //outputs --> the "command" signals (master drives these)
    modport master (
        input clk, rst,
        input PRDATA, PREADY, PSLVERR,
        output PADDR, PSEL, PENABLE, PWRITE, PWDATA, PSTRB
    );

    //inputs --> the "command" signals
    //outputs --> the "response" signals
    modport slave (
        input clk, rst,
        output PRDATA, PREADY, PSLVERR,
        input PADDR, PSEL, PENABLE, PWRITE, PWDATA, PSTRB
    );

    //penable should only be high when psel is high
    assert property (@(posedge clk) (PENABLE |-> PSEL));
    //psel should be in a stable state during penable
    assert property (@(posedge clk) (PSEL && !PENABLE && !PREADY |=> $stable(PSEL)));

endinterface