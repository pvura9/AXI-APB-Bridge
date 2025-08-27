library verilog;
use verilog.vl_types.all;
entity coreBridge is
    generic(
        ADDRESS_WIDTH   : integer := 32;
        DATA_WIDTH      : integer := 32
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic
    );
end coreBridge;
