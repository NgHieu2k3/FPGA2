module lab2_tb ();
localparam CORDIC_CLK_PERIOD = 2;
localparam FIR_CLK_PERIOD = 10;
localparam signed [15:0] PI_POS = 16'h 6488;
localparam signed [15:0] PI_NEG = 16'h 9878;
localparam PHASE_INC_2MHZ = 200;
localparam PHASE_INC_30MHZ = 3000;
reg cordic_clk = 1'b0;
reg fir_clk = 1'b0;
reg phase_tvalid = 1'b0;
reg signed [15:0] phase_2MHz = 0;
reg signed [15:0] phase_30MHz = 0;
wire sincos_2MHz_tvalid;
wire signed [15:0] sin_2MHz, cos_2MHz;
wire sincos_30MHz_tvalid;
wire signed [15:0] sin_30MHz, cos_30MHz;
reg signed [15:0] noisy_signal = 0;
wire signed [15:0] filtered_signal;

cordic_0 cordic_inst_0 ( 
.aclk						(cordic_clk),
.s_axis_phase_tvalid	(phase_tvalid),
.s_axis_phase_tdata	(phase_2MHz),
.m_axis_dout_tvalid	(sincos_2MHz_tvalid),
.m_axis_dout_tdata 	({sin_2MHz, cos_2MHz})
);

cordic_0 cordic_inst_0 ( 
.aclk						(cordic_clk),
.s_axis_phase_tvalid	(phase_tvalid),
.s_axis_phase_tdata	(phase_30MHz),
.m_axis_dout_tvalid	(sincos_30MHz_tvalid),
.m_axis_dout_tdata 	({sin_30MHz, cos_30MHz})
);

always @(posedge cordic_clk)
begin
phase_tvalid <= 1'b1;
// Sweep phase to synthesize 2MHz sine 
if (phase_2MHz + PHASE_INC_2MHz < PI_POS) begin
phase_2MHz <= phase_2MHz + PHASE_INC_2MHz;
end else begin
phase_2MHz <= PI_NEG + (phase_2MHz+PHASE_INC_2MHz - PI_POS);
end
// Sweep phase to synthesize 30MHz sine
if (phase_30MHz + PHASE_INC_30MHz <= PI_POS) begin phase_30MHz <= phase_30MHz + PHASE_INC_30MHz;
end else begin
phase_30MHz <= PI_NEG + (phase_30MHz+PHASE_INC_30MHz - PI_POS);
end
end
// Create 500MHz Cordic clock
always begin
cordic_clk = # (CORDIC_CLK_PERIOD/2) ~cordic_clk;
end
// Create 186MHz FIR clock
always begin
fir_clk = #(FIR_CLK_PERIOD/2) ~fir_clk;
end
// Noisy signal 2MHz sine + 30MHz sine
// Noisy signal is resampled at 100MHz FIR sampling rate
always @(posedge fir_clk)
begin
noisy_signal <= (sin_2MHz + sin_30MHz) / 2;
end

fir fir_inst (
	.clk 	(fir_clk),
	.noisy_signal (noisy_signal),
	.filtered_signal (filtered_signal)
	);

endmodule
