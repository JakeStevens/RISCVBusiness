module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);
  reg[15:0] float1, float2, expected_sum, sum;
  assign float2 =         {1'b0, 5'b10101, 10'b0011001100};
  assign float1 =         {1'b0, 5'b10101, 10'b0011100011};
  assign expected_sum =   {1'b0, 5'b11011, 10'b0111011100};
  
  half_FP_add add1(.clk(hz100), .rst(1'b0), .float1(float1), .float2(float2), .sum_out(sum));  
  
  assign blue = (sum == expected_sum) ? 1'b1 : 1'b0;
  assign left = sum[15:8];
  assign right = sum[7:0];
  
  
endmodule

// Add more modules down here...

module half_FP_add (
  input clk, rst, 
  input [15:0] float1, float2,
  output[15:0] sum_out
);
  logic sign1, sign2, sign_s, hidden_bit1, hidden_bit2;
  logic [4:0] exp1, exp2, exp_s;
  logic [9:0] mant1, mant2, mant_s;
  logic [13:0] sum;
  logic guard, round_bit, sticky;
  
  typedef enum logic [2:0] { 
    initializing,
    special_case,
    align,
    add,
    normalise_1,
    normalise_2,
    round,
    assemble
  } state_t;
  
  state_t state;
  state_t next_state;
  
  always_comb begin
    case(state)
      initializing: begin
        sign1 = float1[15];
        sign2 = float2[15];
        
        exp1 = float1[14:10];
        exp2 = float2[14:10];
        
        mant1 = float1[9:0];
        mant2 = float2[9:0];
        hidden_bit1 = 1'b1;
        hidden_bit2 = 1'b1;
        
        next_state = special_case;
      end
      
      special_case: begin
        next_state = align;
      end
      
      align: begin
        if(exp1 > exp2) begin
          exp2 = exp2 + 1;
          mant2 = mant2 >> 1;
        end
        else if(exp2 > exp1) begin
          exp1 = exp1 + 1;
          mant1 = mant1 >> 1;
        end
        else begin
          next_state = add;
        end
      end
      
      add: begin
        exp_s = exp1;
        if(sign1 == sign2) begin
          sum = {4'b0000, mant1 + mant2};
          sign_s = sign1;
        end
        else begin
          if(mant1 >= mant2) begin
            sum = {4'b0000, mant1 - mant2};
            sign_s = sign1;
          end
          else begin
            sum = {4'b0000, mant2 - mant1};
            sign_s = sign2;
          end
        end
        
        if(sum[9]) begin
          mant_s = sum[13:4];
          guard = sum[3];
          round_bit = sum[2];
          sticky = sum[1] | sum[0];
          exp_s = exp_s + 1;
        end
        else begin
          mant_s = sum[12:3];
          guard = sum[2];
          round_bit = sum[1];
          sticky = sum[0];
        end
        
        next_state = normalise_1;
      end
      
      normalise_1: begin
        if(mant_s[9] == 0 && exp_s > 0) begin
          exp_s = exp_s - 1;
          mant_s = mant_s << 1;
          mant_s[0] = guard;
          guard = round_bit;
          round_bit = 0;
        end
        else begin
          next_state = normalise_2;
        end
      end
      
      normalise_2: begin
        if(exp_s == 0) begin
          exp_s = exp_s + 1;
          mant_s = mant_s >> 1;
          guard = mant_s[0];
          round_bit = guard;
          sticky = sticky | round_bit;
        end
        else begin
          state = round;
        end
      end
      
      round: begin
        if(guard && (round_bit | sticky | mant_s[0])) begin
          if(mant_s == 10'b1111111111) begin
            exp_s = exp_s + 1;
          end
        end
        next_state = assemble;
      end
      
      assemble: begin
        sum_out[15] = sign_s;
        sum_out[14:10] = exp_s;
        sum_out[9:0] = mant_s;
      end
      
      default: begin
        sign_s = 0;
        sign1 = 0;
        sign2 = 0;
        
        exp_s = 0;
        exp1 = 0;
        exp2 = 0;
        
        hidden_bit1 = 0;
        hidden_bit2 = 0;
        
        mant_s = 0;
        mant1 = 0;
        mant2 = 0;
        
        guard = 0;
        round_bit = 0;
        sticky = 0;
        sum = 0;

        next_state = state;
      end
    endcase
  end
  
  always_ff @(posedge clk, posedge rst) begin
    if(rst == 1'b1) begin
      state <= initializing;
    end
    else state <= next_state;
  end
endmodule
