module router_top_tb();

reg clock, resetn, read_enb_0, read_enb_1, read_enb_2, pkt_valid; 
reg [7:0]data_in;
wire [7:0]data_out_0, data_out_1, data_out_2; 
wire vld_out_0, vld_out_1, vld_out_2, err, busy; 
integer i;

router_top DUT(.clock(clock),
.resetn(resetn),
.read_enb_0(read_enb_0),
.read_enb_1(read_enb_1),
.read_enb_2(read_enb_2),
.pkt_valid(pkt_valid),
.data_in(data_in),
.data_out_0(data_out_0),
.data_out_1(data_out_1),
.data_out_2(data_out_2),
.vld_out_0(vld_out_0),
.vld_out_1(vld_out_1),
.vld_out_2(vld_out_2),
.err(err),
.busy(busy) );
parameter Tp = 10; 
always
begin
#(Tp/2) clock = 1'b0;
 #(Tp/2) clock = 1'b1; 
end

task rstn; 
begin
@(negedge clock) 
resetn = 1'b0; 
@(negedge clock) 
resetn = 1'b1;
end
endtask

task initialize; 
begin
{read_enb_0,read_enb_1,read_enb_2,pkt_valid,data_in}=0; 
resetn=0;
end
endtask
 
task pkt_gen_14;
reg [7:0]payload_data,parity,header; 
reg [5:0]payload_len;
reg [1:0]addr; 
integer i;
begin
@(negedge clock) 
wait(~busy) 
@(negedge clock)
payload_len=6'd14; 
addr=2'b00;
header={payload_len,addr}; 
parity=0;
data_in=header; 
pkt_valid=1; 
parity=parity^header;
 @(negedge clock)
wait(~busy) 
for(i=0;i<payload_len;i=i+1) 
begin
@(negedge clock) 
wait(~busy)
payload_data={$random}%256; 
data_in=payload_data; 
parity=parity^data_in;
end
@(negedge clock) 
pkt_valid=0; 
data_in=parity;
end
endtask

initial 
begin
initialize;
 rstn;
 fork
pkt_gen_14; 
begin
repeat(2)
@(negedge clock)
 read_enb_0 = 1'b1; 
end
join 
end
endmodule

