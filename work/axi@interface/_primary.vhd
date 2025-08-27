library verilog;
use verilog.vl_types.all;
entity axiInterface is
    generic(
        ADDRESS_WIDTH   : integer := 32;
        DATA_WIDTH      : integer := 32
    );
end axiInterface;
