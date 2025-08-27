//slave interface - axi4-lite(because axi --> apb)
//inputs - signal is driven by m/s and used by bridge
//outputs - signal driven by bridge and sent to m/s

`timescale 1ns/1ps
interface axiInterface #(
    parameter int ADDRESS_WIDTH = 32,
    parameter int DATA_WIDTH = 32
);
    //global signals
    //system clk
    logic clk;
    //async reset
    logic rst;

    //read address channel
    //read address from axi master
    logic[31:0] ARADDR;
    //read ddress valid signal
    logic ARVALID;
    //ready address ready signal
    logic ARREADY;
    //arcache, arprot not used in this implementation - might expand in future

    //read data channel
    //read data returned to axi master
    logic[31:0] RDATA;
    //read response
    logic[1:0] RRESP;
    //read data valid signal
    logic RVALID;
    //read data ready from axi master
    logic RREADY;

    //write address channel
    //write address from axi master
    logic[31:0] AWADDR;
    //write address valid signal
    logic AWVALID;
    //write address ready signal
    logic AWREADY;
    //awcache, awprot not used in this implementation - might expand in future

    //write data channel
    //write data from axi master
    logic[31:0] WDATA;
    //write strobe
    logic[3:0] WSTRB;
    //write data valid signal
    logic WVALID;
    //write data ready signal
    logic WREADY;

    //write response channel
    //write response
    logic[1:0] BRESP;
    //write response valid
    logic BVALID;
    //write response ready from axi master
    logic BREADY;

    //inputs --> the "response" signals (master receives these)
    //outputs --> the "command" signals (master drives these)
    modport master (
        input clk, rst,
        output AWADDR, AWVALID, WDATA, WSTRB, WVALID, BREADY, ARVALID, RREADY,
        
        input AWREADY, WREADY, BRESP, BVALID, ARREADY, RDATA, RRESP, RVALID
    );

    //inputs --> the "command" signals
    //outputs --> the "response" signals
    modport slave (
        input clk, rst,
        input AWADDR, AWVALID, WDATA, WSTRB, WVALID, BREADY, ARADDR, ARVALID, RREADY,

        output AWREADY, WREADY, BRESP, BVALID, ARREADY, RDATA, RRESP, RVALID
    );
endinterface