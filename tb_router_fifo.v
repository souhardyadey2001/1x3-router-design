module router_fifo_tb();
 reg clock;
reg resetn;
reg write_enb; reg read_enb; reg soft_reset; reg lfd_state;
reg [7:0] data_in;
wire [7:0] data_out; wire empty;
wire full;
parameter T = 10;


router_fifo dut (
.clock(clock),
.resetn(resetn),
.write_enb(write_enb),
.read_enb(read_enb),
.soft_reset(soft_reset),
.data_in(data_in),
.lfd_state(lfd_state),
.data_out(data_out),
.empty(empty),
.full(full)
);


always begin #(T/2);
clock=1'b0; #(T/2);
 clock =~clock; 
end

task sft_dut(); 
begin
@(negedge clock); 
soft_reset=1'b1; 
@(negedge clock); 
soft_reset=1'b0;
end
endtask

task reset_dut(); 
begin
@(negedge clock); 
resetn=1'b0; 
@(negedge clock); 
resetn=1'b1;
end
endtask

task read(input i,input j); 
begin
@(negedge clock); 
write_enb=i;
read_enb=j;
end
endtask


task write;
reg[7:0]payload_data,parity,header;
 reg[5:0]payload_len;
reg[1:0]addr; 
integer k;
begin
@(negedge clock); 
payload_len=6'd14; 
addr=2'b01;
header={payload_len,addr}; 
data_in=header;
lfd_state=1'b1; 
write_enb=1;
for(k=0;k<payload_len;k=k+1) 
begin
@(negedge clock); 
lfd_state=0;
payload_data={$random}%256; 
data_in=payload_data;
end
@(negedge clock);
parity={$random}%256;
data_in=parity;
end
endtask

initial 
begin
reset_dut;
 sft_dut;
write;
read(1'b0,1'b1); 
end

endmodule

