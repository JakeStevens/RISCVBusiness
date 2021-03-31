module pmu_enabled (
    input logic CLK, nRST, CLK_en,
    output logic CLK_GATED
);

    logic CLK_en_LATCHED;
    always_comb 
    begin
            CLK_GATED <= CLK && CLK_en_LATCHED;
    end

    always_latch 
    begin
        if (~CLK)
        begin
            CLK_en_LATCHED <= CLK_en;	
        end
    end
endmodule
