module float_mult_16bit (
  input logic clk, n_rst, 
  input logic [15:0] float1, 
  input logic [15:0] float2,
  output logic [15:0] product
);
  
  logic sign1, sign2, sign_p; 
  logic hidden_lead1, hidden_lead2;
  
  logic signed_exponent;
  logic [4:0] exp1, exp2; 
  logic [4:0] exp_p;
  logic signed [4:0] exp_p_signed;
  
  logic [5:0] exp_comb;
  logic [9:0] mant1, mant2, mant_p;
  
  logic [21:0] mant_multiplied;
  logic guard, round_bit, sticky, dummy;
  
  typedef enum logic [2:0] { 
    initializing,
    special_case,
    multiply,
    normalize_exp,
    normalize_mant,
    assemble
  } state_t;
  
  state_t state;
  state_t next_state;
  
  always_comb begin
    case(state)
      // Currently goes
      // initializing ->
      // special_case ->
      // multiplying ->
      // normalize_exp ->
      // normalize_mant ->
      // assemble
      initializing: begin
        sign1 = float1[15];
        sign2 = float2[15];

        exp1  = float1[14:10];
        exp2  = float2[14:10];
        
        hidden_lead1 = 1'b1;
        hidden_lead2 = 1'b1;
        
        mant1   = float1[9:0];
        mant2   = float2[9:0];
        product = 'd0;

        next_state =  special_case;
      end
      
      special_case: begin
        // if either number is infinity, output is infinity
        if((exp1 == 5'b11111 & mant1 == 0) | (exp2 == 5'b11111 & mant2 == 0)) begin
          sign_p =    sign1 ^ sign2; // Accounts for +/- infinity
          exp_p =     5'b11111;
          mant_p =    10'b0000000000;
          next_state = assemble;
        end
        
        // if either number is quiet NaN, return quiet Nan
        else if((exp1 == 5'd31 & mant1[9] == 1'b0) | (exp2 == 5'd31 & mant2[9] == 1'b0)) begin
          sign_p =    1'b1;
          exp_p =     5'b11111;
          mant_p =    10'b0111111111;
          next_state = assemble;
        end
        
        // if either number is signalling NaN, return signalling Nan
        else if((exp1 == 5'd31 & mant1[9] == 1'b1) | (exp2 == 5'd31 & mant2[9] == 1'b1)) begin
          sign_p =    1'b1;
          exp_p =     5'b11111;
          mant_p =    10'b1111111111;
          next_state = assemble;
        end
        
        // if either number is zero, return zero
        else if((exp1 == 0 & mant1 == 0) | (exp2 == 0 & mant2 == 0)) begin
          sign_p =    sign1 ^ sign2; // IEE754 mandates signed zero
          exp_p =     5'b00000;
          mant_p =    10'b0000000000;
          next_state = assemble;
        end
        
        else begin
          if(exp1 == 0) begin
            hidden_lead1 = 1'b0;
          end
          if(exp2 == 0) begin
            hidden_lead2 = 1'b0;
          end
          next_state = multiply;
        end
      end
      
      multiply: begin
        sign_p = sign1 ^ sign2;
        
        if((exp1 + exp2) < 15) begin
          exp_p = 0;
          exp_p_signed = exp1 + exp2 - 5'd15;
          signed_exponent = 1'b1;
        end
        else begin
          exp_p = exp1 + exp2 - 5'd15;
          exp_p_signed = 0;
          signed_exponent = 1'b0;
        end
        
        mant_multiplied = {hidden_lead1, mant1} * {hidden_lead2, mant2};
        
        if(signed_exponent) begin
          next_state = normalize_exp;
          mant_multiplied = mant_multiplied >> 1;
        end
        else begin
          next_state = normalize_mant;
        end
      end
      
      normalize_exp: begin
        if(exp_p_signed < 0) begin
          exp_p_signed = exp_p_signed + 1;
          mant_multiplied = mant_multiplied >> 1;
        end
        else begin
          next_state = normalize_mant;
        end
      end
      
      normalize_mant: begin
        if(mant_multiplied[21] == 1'b1) begin
          exp_p = exp_p + 1;
          mant_multiplied = mant_multiplied >> 1;
        end
        
        mant_p = mant_multiplied[19:10];
        
        guard = mant_multiplied[9];
        round_bit = mant_multiplied[8];
        
        if(guard) begin
          round_bit = guard;
          guard = mant_p[0];
          mant_p = mant_p + 1;
        end
        
        next_state = assemble;
      end
      
      assemble: begin
        product[15] = sign_p;
        product[14:10] = signed_exponent ? exp_p_signed : exp_p;
        product[9:0] = mant_p;

        // if (float1 || float2) next_state = initializing;
      end
      
      default: begin
        sign_p = 0;
        sign1 = 0;
        sign2 = 0;
        
        exp_p = 0;
        exp_p_signed = 0;
        exp1 = 0;
        exp2 = 0;
        
        hidden_lead1 = 0;
        hidden_lead2 = 0;
        
        mant_p = 0;
        mant1 = 0;
        mant2 = 0;
        
        guard = 0;
        round_bit = 0;
        sticky = 0;
        mant_multiplied = 0;

        next_state = state;
      end
    endcase
  end
  
  // always_comb begin
  //       product[15] = sign_p;
  //       product[14:10] = signed_exponent ? exp_p_signed : exp_p;
  //       product[9:0] = mant_p;
  // end

  always_ff @(posedge clk, negedge n_rst) begin
    if(!n_rst) begin
      state <= initializing;
    end
    else state <= next_state;
  end
endmodule
