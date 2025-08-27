`timescale 1ns/1ps
module bridgeTop;

    //system clk
    logic clk = 0;
    //100MHz clock
    always #5 clk = ~clk;

    //async reset
    logic rst;
    
    //following lines are executed sequentially due to the 'initial' keyword
    initial begin
        rst = 1;
        //hold the reset for 5 clock cycles
        repeat (5) @(posedge clk);
        rst = 0;
        //run the test sequence
        testSequence();
        //hold for 100 clock cycles before completion
        repeat (100) @(posedge clk);
        $display("Simulation complete!");
        $finish;
    end

    //instantiate an instance of the axi interface
    axiInterface axi();
    //same with apb interface
    apbInterface apb();

    //make the proper connections for the global signals
    assign axi.clk = clk;
    assign axi.rst = rst;
    assign apb.clk = clk;
    assign apb.rst = rst;

    //make an instante of the core bridge
    coreBridge testBridge(
        .clk(clk),
        .rst(rst),
        //connect to the slave modport
        .axi(axi.slave),
        //connect to the master modport
        .apb(apb.master)
    );

    //make a dummy apb model
    //execute only once at beginning of simulation, time step 0
    initial begin
        apb.PREADY = 0;
        apb.PSLVERR = 0;        
        //execute following continuously
        forever begin
            @(posedge apb.clk);
            //apb not ready yet
            apb.PREADY <= 0;
            //once peripheral selected and enabled
            if (apb.PSEL && apb.PENABLE) begin
                @(posedge apb.clk);
                //assert ready state
                apb.PREADY <= 1;
                apb.PRDATA <= 32'h10101010;
                //if in read transaction mode
                //--------- COMMENT OUT TO TEST BOTH R/W AT ONCE----
                if (apb.PWRITE == 0) begin
                    //dummy read response
                    //expectead read value for this should be a5a5a5a5 + 00001234
                    apb.PRDATA <= apb.PADDR + 32'h00001234;
                end
            end
        end
    end

    logic [31:0] axiAddress;

    //axi write task
    task axiWrite;
        //inputs for write task are address to write to and what data to send and which bytes to write to
        input [31:0] address;
        input [31:0] dataToSend;
        input [3:0] strobe;

        begin
            $display("Starting AXI write to address %h, data %h, strobe %b", address, dataToSend, strobe);

            //the state debug print statements placed in core bridge module will be started from before the fork block.
            
            //execute all threads in this block concurrently
            fork : writeTimeout
                begin
                    //drive write address channel
                    axi.AWADDR = address;
                    axi.AWVALID = 1'b1;

                    //drive write data channel
                    axi.WDATA = dataToSend;
                    axi.WSTRB = strobe;
                    axi.WVALID = 1'b1;
                    axi.BREADY = 1'b1;

                    //wait for address to be accepted
                    wait(axi.AWREADY);
                    @(posedge axi.clk);
                    axi.AWVALID = 1'b0;
                    axi.AWADDR = 32'hx;

                    //wait for data to be accepted
                    wait(axi.WREADY);
                    @(posedge axi.clk);
                    axi.WVALID = 1'b0;
                    axi.WDATA = 32'hx;
                    axi.WSTRB = 4'hx;


                    //----------------------
                    //deassert BREADY
                    // wait(axi.BVALID && axi.BREADY);
                    // @(posedge axi.clk);
                    // axi.BREADY = 1'b0;
                    //-----------------------


                    //wait for write response
                    wait(axi.BVALID);
                    @(posedge axi.clk);
                    $display("Write task done with response %h", axi.BRESP);
                end
                begin
                    //500 units --> 500 ns
                    #500;

                    $display("AXI write timed out!");

                    $display("Debug info:");
                    $display("AWADDR = %h, AWVALID = %h, AWREADY = %b", axiAddress, axi.AWVALID, axi.AWREADY);

                    $display("WDATA = %h, WVALID = %b, WREADY = %b", axi.WDATA, axi.WVALID, axi.WREADY);

                    $display("BVALID = %b, BRESP = %b", axi.BVALID, axi.BRESP);

                    $display("Current state: %s", testBridge.currentState.name());

                    //$finish;
                end
            //the fork block will terminate as soon as any of the inner threads are completed
            join_any
            
            //kill the thread that is still running because we don't need it anymore
            disable writeTimeout;
            
            //clean up signals after timeout
            if (!axi.BVALID) begin
                axi.AWVALID = 1'b0;
                axi.WVALID = 1'b0;
                axi.BREADY = 1'b0;
            end
        end
    endtask

    //added to fix the write issue
    always @(posedge clk) begin
        if(axi.AWVALID && axi.AWREADY) begin
            axiAddress = axi.AWADDR;
        end
    end

    //axi read task
    task axiRead;
        input [31:0] address;
        begin
            $display("Starting AXI read from address %h", address);
            
            fork : readTimeout
                begin
                    //drive read address channel
                    axi.ARADDR = address;
                    axi.ARVALID = 1'b1;
                    axi.RREADY = 1'b1;

                    //wait for address to be accepted
                    wait(axi.ARREADY);
                    @(posedge axi.clk);
                    axi.ARVALID = 1'b0;
                    axi.ARADDR = 'hx;

                    //wait for read data
                    wait(axi.RVALID);
                    @(posedge axi.clk);
                    $display("Read complete: data %b, response %b", axi.RDATA, axi.RRESP);
                end

                begin
                    //500 ns
                    #500;
                    $display("AXI read transaction timed out!");

                    $display("Debug Info:");
                    $display("ARADDR = %h, ARVALID = %b, ARREADY = %b", axi.ARADDR, axi.ARVALID, axi.ARREADY);
                    $display("RDATA = %h, RVALID = %b, RRESP = %b", axi.RDATA, axi.RVALID, axi.RRESP);
                    $display("Current state: %s", testBridge.currentState.name());

                    //$finish;
                end
            join_any
            
            disable readTimeout;
            
            //clean up signals after timeout
            if (!axi.RVALID) begin
                axi.ARVALID = 1'b0;
                axi.RREADY = 1'b0;
            end
        end
    endtask





    //the main testing sequence
    task testSequence;
        $display("=== Test Started! ===");
        
        //write test
        //A VARIETY OF TEST CASES HAVE BEEN TESTED. THESE CASES ARE INCLUDED IN THE REPORT AND HAVE BEEN LEFT COMMENTED
        
        // $display("1. Starting AXI write...");
        // axiWrite(32'hA5A5A5A5, 32'h10101010, 4'b1111);
        // $display("1. Write completed!");


        //read test
        //A VARIETY OF TEST CASES HAVE BEEN TESTED. THESE CASES ARE INCLUDED IN THE REPORT AND HAVE BEEN LEFT COMMENTED

        // $display("2. Starting AXI read...");
        // axiRead(32'hA5A5A5A5);
        // $display("2. Read completed!");

        // $display("=== Test Passed! ===");
        // repeat(100)@(posedge clk);
        $finish;
    endtask

    //monitor apb transactions
    always @(posedge apb.clk) begin
        if(apb.PSEL && apb.PENABLE && apb.PREADY) begin
            if(apb.PWRITE) begin
                $display("APB Write: address %h, data %h, strobe %b", apb.PADDR, apb.PWDATA, apb.PSTRB);
            end
            else begin
                $display("APB Read: address %h", apb.PADDR);
            end
        end
    end
endmodule