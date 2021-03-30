package pipe5_types_pkg;

    /** Determine which register file is the origin **/
    typedef enum logic {
        INTEGER,
        FP
    } regsource_t;

    /** Reg # + origin **/
    typedef struct packed {
        regsource_t src;
        logic [4:0] addr;
    } rsel_t;

    typedef enum logic[1:0] {
        NO_FWD,
        FWD_M,
        FWD_W
    } bypass_t;

endpackage
