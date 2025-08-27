vlib work
vmap work work

vlog -sv -novopt \
    axiInterface.sv \
    apbInterface.sv \
    coreBridge.sv \
    bridgeTop.sv

vsim -novopt -t 1ns bridgeTop
add wave -position insertpoint sim:/bridgeTop/*

run -all
wave zoom full