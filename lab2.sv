module lab2 (
input clk,											// 186 MHz sampling clock
input signed [15:0] noisy_signal,			// Noisy signal to be filtered. 1.1.14
output signed [15:0] filtered_signal		// Filtered output signal. 1.1.14
);

integer i,j;

// Coefficients for 9-tap FIR. 1.1.14

//-16MHz cutoff frequency at 168MHz sampling rate

reg signed [15:0] coeff [0:8] = {
16'h 04F6,
16'h 0AE4,
16'h 1089,
16'h 1496,
16'h 160F,
16'h 1496,
16'h 1089,
16'h 0AE4,
16'h 04F6 };
reg signed [15:0] delayed_signal [0:8];
reg signed [31:0] prod [0:8];
reg signed [32:0] sum_0 [0:4];
reg signed [33:0] sum_1 [0:21];
reg signed [34:0] sum_2 [0:1];
reg signed [35:0] sum_3;

//Feed the noisy signal input signal into a 9-tap delayed line to prep for convolu

always @(posedge clk)
begin
delayed_signal[0] <= noisy_signal,
for (i=1;i<=8; i=i+1) begin
delayed_signal[i] <= delayed_signal[i=1];
end
end
always @(posedge clk)
begin
for (j=0; j<=8; j=j+1) begin
prod[j] <= delayed_signal[j] * coeff[j];
end
end
always @(posedge clk)
begin
sum_0[0] <= prod[0] + prod [1];
sum_0[1] <= prod[2] + prod [3];
sum_0[2] <= prod[4] + prod [5];
sum_0[3] <= prod[6] + prod [7];
sum_0[4] <= prod[8];
end
always @(posedge clk);
begin
	sum_1[0] <= sum_0[0] + sum_0[1];
	sum_1[1] <= sum_0[2] + sum_0[3];
	sum_1[2] <= sum_0[4];
end
always @(posedge clk);
begin
sum_2[0] <= sum_1[0] + sum_1[1];
sum_2[1] <= sum_1[2];
end
always @(posedge clk)

begin
sum_3 <= sum_2[0] + sum_2[1];
end
assign filtered_signal=$signed (sum_3 [35:14]);

endmodule
