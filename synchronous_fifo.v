

`timescale 1ns/1ns

module synchronous_fifo
#(parameter DEPTH = 4,
  parameter WIDTH = 8)
  (
  output 			full_o,
  output 			empty_o,
  output [WIDTH-1:0]pop_data_o,
  
  input 			clk_i,
  input 			reset_i,
  
  input 			push_i,
  input 			pop_i,
  input  [WIDTH-1:0]push_data_i);
  
  parameter PUSH = 2'b10;
  parameter POP  = 2'b01;
  parameter PUSH_POP = 2'b11;
  
  localparam 	PTR_W = $clog2(DEPTH-1);
  
  reg [WIDTH-1:0] fifo_mem [DEPTH-1:0];
  
  reg 	[PTR_W-1:0]	rd_ptr;
  reg 	[PTR_W-1:0]	wrt_ptr;
  reg 	[PTR_W-1:0] nxt_rd_ptr;
  reg   [PTR_W-1:0] nxt_wrt_ptr;
  
  reg   [WIDTH-1:0] nxt_data;
  reg 	[WIDTH-1:0] pop_data;
  
  reg  				wrapped_rd_ptr;
  reg 				wrapped_wrt_ptr;
  reg				nxt_wrapped_rd_ptr;
  reg				nxt_wrapped_wrt_ptr;

  always@(posedge clk_i , posedge reset_i) begin
		if(reset_i) begin
			rd_ptr <=0;
			wrt_ptr<=0;
			wrapped_rd_ptr <=0;
			wrapped_wrt_ptr <=0;
		end
		else begin
			rd_ptr <=  nxt_rd_ptr;
			wrt_ptr <= nxt_wrt_ptr;
			wrapped_rd_ptr <= nxt_wrapped_rd_ptr;
			wrapped_wrt_ptr <= nxt_wrapped_wrt_ptr;
		end
  end
  
  always@(*) begin
				nxt_rd_ptr =  rd_ptr;
				nxt_wrt_ptr = wrt_ptr;
				nxt_data   =  fifo_mem[wrt_ptr];
				nxt_wrapped_rd_ptr = wrapped_rd_ptr;
				nxt_wrapped_wrt_ptr = wrapped_wrt_ptr;
				
		case({push_i,pop_i})
		
			PUSH : begin
				nxt_data = push_data_i;
				if(wrt_ptr == PTR_W'(DEPTH-1))  begin
					nxt_wrt_ptr = 0;
					nxt_wrapped_wrt_ptr = ~wrapped_wrt_ptr;
				end
				else 
					nxt_wrt_ptr = wrt_ptr + PTR_W'(1'b1) ;
			end
			
			
			POP  : begin
				pop_data = fifo_mem[rd_ptr[PTR_W-1:0]];
				if(rd_ptr == PTR_W'(DEPTH-1)) begin
					nxt_wrapped_rd_ptr = ~wrapped_rd_ptr;
					nxt_rd_ptr = 0;	
				end
				else 
					nxt_rd_ptr = rd_ptr + PTR_W'(1'b1) ;
			end
			
			
			PUSH_POP: begin
				//PUSH operation
				nxt_data = push_data_i;
				if(wrt_ptr == PTR_W'(DEPTH-1)) begin
					nxt_wrt_ptr = 0;
					nxt_wrapped_wrt_ptr = ~wrapped_wrt_ptr;
				end
				else 
					nxt_wrt_ptr = wrt_ptr + PTR_W'(1'b1) ;
				//POP operation
				pop_data = fifo_mem[rd_ptr[PTR_W-1:0]];
				if(rd_ptr == PTR_W'(DEPTH-1)) begin
				nxt_wrapped_rd_ptr = ~wrapped_rd_ptr;
					nxt_rd_ptr = 0;	
				end
				else 
					nxt_rd_ptr = rd_ptr + PTR_W'(1'b1) ;
			end
			
			
			default : begin
				nxt_rd_ptr =  rd_ptr;
				nxt_wrt_ptr = wrt_ptr;
				nxt_data   =  fifo_mem[wrt_ptr[PTR_W-1:0]];
			end
		
		endcase
  end
  
  always@(posedge clk_i) begin
		fifo_mem[wrt_ptr[PTR_W-1:0]] <= nxt_data;
	end
  
  assign pop_data_o = pop_data;
  
  assign empty_o = ((rd_ptr == wrt_ptr) & (wrapped_rd_ptr == wrapped_wrt_ptr));
  assign full_o  = ((rd_ptr == wrt_ptr) & (wrapped_rd_ptr != wrapped_wrt_ptr));
  endmodule
  
