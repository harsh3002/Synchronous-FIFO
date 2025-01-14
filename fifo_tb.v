

`timescale 1ns/1ns



module fifo_tb ;

  localparam 		DEPTH = 4;
  localparam  		WIDTH = 8;
  
  wire	 		full_o;
  wire 			empty_o;
  wire   [WIDTH-1:0]	pop_data_o;
  
  reg 	 		clk_i;
  reg			reset_i;
  
  reg	 		push_i;
  reg			pop_i;
  reg	 [WIDTH-1:0]	push_data_i;
 
  synchronous_fifo #(.DEPTH(DEPTH) , .WIDTH(WIDTH)) dut(
    .*);
	
  initial begin
		    clk_i <= 1'b0;
	forever #5  clk_i <= ~clk_i;
  end
	
  initial begin
	reset_i <=1'b1;
	push_i  <=1'b0;
	pop_i   <=1'b0;

	repeat (2) @(posedge clk_i);
	reset_i <=1'b0;

	repeat (2) @(posedge clk_i);
	push_i  <=1'b1;
	push_data_i <=8'hAB;

	@(posedge clk_i);
	push_i <=1'b0;
	pop_i  <=1'b1;
	

	@(posedge clk_i);
	pop_i<=1'b0;
	push_i<=1'b1;
	push_data_i<=8'hAF;
	
	@(posedge clk_i);
	push_data_i<=8'h10;

	@(posedge clk_i);
	push_data_i<=8'hAA;

	@(posedge clk_i);
	push_data_i<=8'h99;

	@(posedge clk_i);
	push_i<=1'b0;
	pop_i<=1'b1;

	@(posedge clk_i);
	push_i<=1'b1;
	push_data_i<=8'hEF;
	
	@(posedge clk_i);
	push_i<=1'b0;
	pop_i<=1'b0;
	push_data_i<=8'h0;
	
		
end
	
endmodule
