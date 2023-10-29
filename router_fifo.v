module router_fifo ( input clock,
input resetn, input write_enb, input read_enb, input soft_reset,
input [7:0] data_in, input lfd_state,
output reg [7:0] data_out, output empty,
output full
);
integer i;
reg [8:0] mem [0:15]; // 16x8 memory 
reg [4:0] wr_pt;
reg [4:0] rd_pt;
reg [6:0] fifo_counter; 
reg lfd_state_s;
always@(posedge clock) 
begin
if(!resetn) 
begin
fifo_counter <= 0; 
end
else if(soft_reset)
 begin
fifo_counter <= 0; 
end
else if(read_enb & ~empty)
begin
if(mem[rd_pt[3:0]][8] == 1'b1)
fifo_counter <= mem[rd_pt[3:0]][7:2] + 1'b1; 
else if(fifo_counter != 0)
fifo_counter <= fifo_counter - 1'b1; 
end
end


always@(posedge clock) 
begin
if(!resetn) lfd_state_s <= 0; 
else
lfd_state_s <= lfd_state; 
end


//read operation
always@(posedge clock) 
begin
if(!resetn)
data_out <= 8'b00000000; 
else if(soft_reset)
data_out <= 8'bzzzzzzzz; 
else
begin
if(fifo_counter==0 && data_out != 0) 
data_out <= 8'dz;
else if(read_enb && ~empty) 
data_out <= mem[rd_pt[3:0]];
end
end

//write operation
always@(posedge clock) 
begin
if(!resetn) 
begin
for(i = 0;i<16;i=i+1) 
begin 
mem[i] <= 0;
end
end
else if(soft_reset) 
begin
for(i = 0;i<16;i=i+1) 
begin mem[i] <= 0;
end 
end
else 
begin
if(write_enb && !full)
{mem[wr_pt[3:0]]}<= {lfd_state_s,data_in}; 
end
end

//logic for incrementing pointer 
always@(posedge clock)
begin
if(!resetn) 
begin rd_pt <= 5'b00000;
wr_pt <= 5'b00000; 
end
else if(soft_reset) 
begin 
rd_pt <= 5'b00000;
wr_pt <= 5'b00000; 
end

else 
begin
if(!full && write_enb) 
wr_pt <= wr_pt + 1;
else
wr_pt <= wr_pt;
if(!empty && read_enb) 
rd_pt <= rd_pt + 1;
else
rd_pt <= rd_pt; 
end
end

assign full= (wr_pt=={~rd_pt[4],rd_pt[3:0]})?1'b1:1'b0; 
assign empty=(wr_pt== rd_pt)?1'b1:1'b0;

endmodule

