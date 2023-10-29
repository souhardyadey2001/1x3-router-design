module router_sync( input
clock,resetn,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2,
input [1:0]data_in,
output wire vld_out_0,vld_out_1,vld_out_2, 
output reg [2:0]write_enb,
output reg fifo_full, soft_reset_0,soft_reset_1,soft_reset_2);

reg [4:0] timer_0, timer_1, timer_2; 
reg [1:0] int_addr_reg;

//timer_0 and soft_reset_0 logic 
always@(posedge clock)
begin 
if(~resetn) 
begin
timer_0<=0; 
soft_reset_0<=0; 
end
else if(vld_out_0) 
begin
if(!read_enb_0) 
begin
if(timer_0==5'd29)
begin
soft_reset_0<=1'b1; 
timer_0<=0;
end

else
 begin
begin
soft_reset_0<=0;
timer_0<=timer_0+1'b1; 
end
end
end 
end
end

//timer_1 and soft_reset_1 logic 
always@(posedge clock)
begin
if(~resetn) 
begin
timer_1<=0;
soft_reset_1<=0; 
end
else if(vld_out_1)
begin
if(!read_enb_1) 
begin
if(timer_1==5'd29) 
begin
soft_reset_1<=1'b1;
timer_1<=0; 
end
else 
begin
begin
soft_reset_1<=0;
timer_1<=timer_1+1'b1; 
end
end
end
end
end

//timer_2 and soft_reset_2 logic 
always@(posedge clock)
begin 
if(~resetn) 
begin
timer_2<=0; 
soft_reset_2<=0; 
end
else if(vld_out_2) 
begin
if(!read_enb_2) 
begin
if(timer_2==5'd29) 
begin
soft_reset_2<=1'b1; 
timer_2<=0;
end
else 
begin
begin
soft_reset_2<=0;
timer_2<=timer_2+1'b1; 
end
end
end
end
end

//int_addr_reg logic
always@(posedge clock)
begin
if (~resetn) 
int_addr_reg<=0;
else if(detect_add) 
int_addr_reg<=data_in;
end

//write enb logic 
always@(*)
begin
write_enb = 3'b000; 
if(write_enb_reg) 
begin
case(int_addr_reg)
2'b00 : write_enb = 3'b001; 
2'b01 : write_enb = 3'b010; 
2'b10 : write_enb = 3'b100; 
default:write_enb = 3'b000; 
endcase
end 
end

//fifo_full logic 
always@(*)
begin
case(int_addr_reg)
 2'b00 : fifo_full = full_0; 
2'b01 : fifo_full = full_1; 
2'b10 : fifo_full = full_2; 
default:fifo_full = 1'b0; 
endcase
end

assign vld_out_0 = ~empty_0; 
assign vld_out_1 = ~empty_1; 
assign vld_out_2 = ~empty_2; 
endmodule





