onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /bridgeTop/clk
add wave -noupdate -format Logic /bridgeTop/rst
add wave -noupdate -format Literal /bridgeTop/axiAddress
add wave -noupdate -format Logic /bridgeTop/clk
add wave -noupdate -format Logic /bridgeTop/rst
add wave -noupdate -format Literal /bridgeTop/axiAddress
add wave -noupdate -format Literal /bridgeTop/axiWrite/address
add wave -noupdate -format Literal /bridgeTop/axiWrite/dataToSend
add wave -noupdate -format Literal /bridgeTop/axiWrite/strobe
add wave -noupdate -format Literal /bridgeTop/axiRead/address
add wave -noupdate -format Logic /bridgeTop/axi/clk
add wave -noupdate -format Logic /bridgeTop/axi/rst
add wave -noupdate -format Literal /bridgeTop/axi/ARADDR
add wave -noupdate -format Logic /bridgeTop/axi/ARVALID
add wave -noupdate -format Logic /bridgeTop/axi/ARREADY
add wave -noupdate -format Literal /bridgeTop/axi/RDATA
add wave -noupdate -format Literal /bridgeTop/axi/RRESP
add wave -noupdate -format Logic /bridgeTop/axi/RVALID
add wave -noupdate -format Logic /bridgeTop/axi/RREADY
add wave -noupdate -format Literal /bridgeTop/axi/AWADDR
add wave -noupdate -format Logic /bridgeTop/axi/AWVALID
add wave -noupdate -format Logic /bridgeTop/axi/AWREADY
add wave -noupdate -format Literal /bridgeTop/axi/WDATA
add wave -noupdate -format Literal /bridgeTop/axi/WSTRB
add wave -noupdate -format Logic /bridgeTop/axi/WVALID
add wave -noupdate -format Logic /bridgeTop/axi/WREADY
add wave -noupdate -format Literal /bridgeTop/axi/BRESP
add wave -noupdate -format Logic /bridgeTop/axi/BVALID
add wave -noupdate -format Logic /bridgeTop/axi/BREADY
add wave -noupdate -format Logic /bridgeTop/apb/clk
add wave -noupdate -format Logic /bridgeTop/apb/rst
add wave -noupdate -format Literal /bridgeTop/apb/PADDR
add wave -noupdate -format Logic /bridgeTop/apb/PWRITE
add wave -noupdate -format Logic /bridgeTop/apb/PSEL
add wave -noupdate -format Logic /bridgeTop/apb/PENABLE
add wave -noupdate -format Literal /bridgeTop/apb/PWDATA
add wave -noupdate -format Literal /bridgeTop/apb/PRDATA
add wave -noupdate -format Logic /bridgeTop/apb/PREADY
add wave -noupdate -format Literal /bridgeTop/apb/PSTRB
add wave -noupdate -format Logic /bridgeTop/apb/PSLVERR
add wave -noupdate -format Logic /bridgeTop/testBridge/clk
add wave -noupdate -format Logic /bridgeTop/testBridge/rst
add wave -noupdate -format Literal /bridgeTop/testBridge/currentState
add wave -noupdate -format Literal /bridgeTop/testBridge/nextState
add wave -noupdate -format Literal /bridgeTop/testBridge/addressRegister
add wave -noupdate -format Literal /bridgeTop/testBridge/writeDataRegister
add wave -noupdate -format Literal /bridgeTop/testBridge/wstrbRegister
add wave -noupdate -format Logic /bridgeTop/testBridge/writeTransaction
add wave -noupdate -format Logic /bridgeTop/testBridge/axi/clk
add wave -noupdate -format Logic /bridgeTop/testBridge/axi/rst
add wave -noupdate -format Literal /bridgeTop/testBridge/axi/ARADDR
add wave -noupdate -format Logic /bridgeTop/testBridge/axi/ARVALID
add wave -noupdate -format Logic /bridgeTop/testBridge/axi/ARREADY
add wave -noupdate -format Literal /bridgeTop/testBridge/axi/RDATA
add wave -noupdate -format Literal /bridgeTop/testBridge/axi/RRESP
add wave -noupdate -format Logic /bridgeTop/testBridge/axi/RVALID
add wave -noupdate -format Logic /bridgeTop/testBridge/axi/RREADY
add wave -noupdate -format Literal /bridgeTop/testBridge/axi/AWADDR
add wave -noupdate -format Logic /bridgeTop/testBridge/axi/AWVALID
add wave -noupdate -format Logic /bridgeTop/testBridge/axi/AWREADY
add wave -noupdate -format Literal /bridgeTop/testBridge/axi/WDATA
add wave -noupdate -format Literal /bridgeTop/testBridge/axi/WSTRB
add wave -noupdate -format Logic /bridgeTop/testBridge/axi/WVALID
add wave -noupdate -format Literal /bridgeTop/testBridge/currentState
add wave -noupdate -format Logic /bridgeTop/testBridge/writeTransaction
add wave -noupdate -format Logic /bridgeTop/testBridge/axi/WREADY
add wave -noupdate -format Literal /bridgeTop/testBridge/axi/BRESP
add wave -noupdate -format Logic /bridgeTop/testBridge/axi/BREADY
add wave -noupdate -format Logic /bridgeTop/testBridge/apb/clk
add wave -noupdate -format Logic /bridgeTop/testBridge/apb/rst
add wave -noupdate -format Literal /bridgeTop/testBridge/apb/PADDR
add wave -noupdate -format Logic /bridgeTop/testBridge/apb/PWRITE
add wave -noupdate -format Logic /bridgeTop/testBridge/apb/PSEL
add wave -noupdate -format Logic /bridgeTop/testBridge/axi/BVALID
add wave -noupdate -format Logic /bridgeTop/testBridge/apb/PENABLE
add wave -noupdate -format Literal /bridgeTop/testBridge/apb/PWDATA
add wave -noupdate -format Literal /bridgeTop/testBridge/apb/PRDATA
add wave -noupdate -format Logic /bridgeTop/testBridge/apb/PREADY
add wave -noupdate -format Literal /bridgeTop/testBridge/apb/PSTRB
add wave -noupdate -format Logic /bridgeTop/testBridge/apb/PSLVERR
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {63 ns} 0}
configure wave -namecolwidth 241
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {442 ns}
