`include "component_selection_defines.vh"
module pmu_wrapper (
    input logic CLK, nRST, CLK_en,
    output logic CLK_GATED
);
    
    generate
        case (PMU_ENABLED)
            "enabled" : pmu_enabled pmu(.*);
        endcase
    endgenerate
endmodule
