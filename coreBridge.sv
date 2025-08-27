//this module was implemented assuming peripheral address widths up to 32 bits
`timescale 1ns/1ps
module coreBridge #(
    parameter int ADDRESS_WIDTH = 32,
    parameter int DATA_WIDTH = 32
)(
    //system clk
    input logic clk,
    //async reset
    input logic rst,
    

    //axi4-lite slave interface
    axiInterface.slave axi,
    //apb3 master interface
    apbInterface.master apb
);

    //FSM states
    typedef enum logic [2:0]
    {
        //waiting for axi request
        IDLE,
        //apb setup phase - getting ready to communicate
        SETUP,
        //apb access phase - actual transfer
        ACCESS,
        //sending axi write response - telling axi that write worked
        WRITERESPONSE,
        //sending axi read response - giving axi the data it asked for
        READRESPONSE
    }stateTransition;

    stateTransition currentState;
    stateTransition nextState;

    //internal signals/buffers
    //where to r/w
    logic[31:0] addressRegister;
    //what data to write
    logic[31:0] writeDataRegister;
    //which bytes to write
    logic[3:0] wstrbRegister;
    //flag to indivate if current op is a write
    logic writeTransaction;

    //fsm state transition
    always_ff@(posedge clk, posedge rst) begin
        if(rst)
            currentState <= IDLE;
        else
            currentState <= nextState;
    end

    //fsm next state logic
    always_comb begin
        nextState = currentState;
        case(currentState)
            //idle state
            IDLE: begin
                if((axi.AWVALID && axi.AWREADY) || (axi.ARVALID && axi.ARREADY))
                    //write //read request triggers write/read setup
                    nextState = SETUP;
            end

            //setup state
            SETUP: begin
                nextState = ACCESS;
            end
            
            //access state
            ACCESS: begin
                if(apb.PREADY) begin
                    if(writeTransaction)
                        nextState = WRITERESPONSE;
                    else
                        nextState = READRESPONSE;
                end
            end

            //write response state
            WRITERESPONSE: begin
                if(axi.BVALID && axi.BREADY)
                    //write response acknowledged
                    nextState = IDLE;
            end

            //read response state
            READRESPONSE: begin
                if(axi.RVALID && axi.RREADY)
                    //read data acknowledged
                    nextState = IDLE;
            end
            default: begin
                nextState = IDLE;
            end
        endcase
    end

    //fsm output logic
    always_comb begin
        //default outputs
        axi.AWREADY = 1'b0;
        //set to okay
        axi.BRESP = 2'b00;
        axi.BVALID = 1'b0;
        axi.ARREADY = 1'b0;
        axi.RDATA = '0;
        //set to okay
        axi.RRESP = 2'b00;
        axi.RVALID = 1'b0;
        
        apb.PADDR = '0;
        apb.PSEL = 1'b0;
        apb.PENABLE = 1'b0;
        apb.PWRITE = 1'b0;
        apb.PWDATA = '0;
        apb.PSTRB = 4'b0000;

        //output logic based on state
        case(currentState)
            IDLE: begin
                //accept either the write or read address
                if(axi.AWVALID)
                    axi.AWREADY = 1'b1;
                else if(axi.ARVALID)
                    axi.ARREADY = 1'b1;
            end

            //setup phase (cycle 1)
            SETUP: begin
                //assert psel for setup phase
                apb.PSEL = 1'b1;
                apb.PENABLE = 1'b0;
                //drive the address
                apb.PADDR = addressRegister;
                //indicate r/w
                apb.PWRITE = writeTransaction;
                if(writeTransaction) begin
                    //set the apb write data to what we want to write
                    apb.PWDATA = writeDataRegister;
                    //which bytes we want to modify
                    apb.PSTRB = wstrbRegister;
                end
                else begin
                    //the read transaction case
                    //dont mess with prdata here because its an input to the bridge from the peripheral. not supposed to change that value
                    apb.PWDATA = '0;
                    apb.PSTRB = '0;
                end
            end

            //access phase (cycle 2)
            ACCESS: begin
                //keep the psel selected
                apb.PSEL = 1'b1;
                //have to assert enable for access phase
                apb.PENABLE = 1'b1;
                apb.PADDR = addressRegister;
                apb.PWRITE = writeTransaction;
                if(writeTransaction) begin
                    apb.PWDATA = writeDataRegister;
                    apb.PSTRB = wstrbRegister;
                end
                else begin
                    //it is a read transaction here
                    //dont mess with prdata because its an input to the bridge
                    apb.PWDATA = '0;
                    apb.PSTRB = '0;
                end
            end

            WRITERESPONSE: begin
                axi.BVALID = 1'b1;
                //either slverr or okay
                axi.BRESP = apb.PSLVERR ? 2'b10 : 2'b00;
            end

            READRESPONSE: begin
                axi.RVALID = 1'b1;
                axi.RDATA = apb.PRDATA;
                //either slverr or okay
                axi.RRESP = apb.PSLVERR ? 2'b10 : 2'b00;
            end
        endcase
    end

    //------------------------------------------------------------
    //wready should be asserted when the bridge is in a state to accept data
    assign axi.WREADY = (currentState == SETUP) && writeTransaction;
    //-------------------------------------------------------------
    //MOVED WRITE DATA AND WSTRB REGISTER UPDATES TO OUTSIDE OF STATE CHECK. ALSO REMOVED THE READ TRANSACTION UPDATE. PASSED THE WRITE CASE

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            //clearing all registers to begin
            addressRegister <= 32'b0;
            writeDataRegister <= '0;
            wstrbRegister <= '0;
            writeTransaction <= 1'b0;
        end 
        else begin
            //capture address and transaction type when in idle state
            if (currentState == IDLE) begin
                if (axi.AWVALID && axi.AWREADY) begin
                    addressRegister <= axi.AWADDR;
                    //set as write
                    writeTransaction <= 1'b1;
                end 
                else if (axi.ARVALID && axi.ARREADY) begin
                    addressRegister <= axi.ARADDR;
                    //set to read
                    writeTransaction <= 1'b0;
                end
            end
            //capture the write data and strobe when the handshake happens
            //write case failed because this was originally inside the current state check. this should be checking even when not in idle state. outside the current state check.
            if (axi.WVALID && axi.WREADY) begin
                writeDataRegister <= axi.WDATA;
                wstrbRegister <= axi.WSTRB;
            end
        end
    end

    //debug print statement:
    // always_ff @(posedge clk) begin
    //     $display("State: %s -> %s", currentState.name(), nextState.name());
    // end

endmodule