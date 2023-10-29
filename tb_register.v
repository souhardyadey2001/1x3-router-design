module router_reg_tb(); 
reg clock;
reg resetn; 
reg pkt_valid;
reg [7:0] data_in; 
reg fifo_full;
reg detect_add; 
reg ld_state;
reg laf_state; 
reg full_state; 
reg lfd_state; 
reg rst_int_reg;

wire err;
wire parity_done; 
wire low_pkt_valid; 
wire [7:0] dout;

parameter T = 10; 
router_reg dut (
.clock(clock),
.resetn(resetn),
.pkt_valid(pkt_valid),
.data_in(data_in),
.fifo_full(fifo_full),
.detect_add(detect_add),
.ld_state(ld_state),
.laf_state(laf_state),
.full_state(full_state),
.lfd_state(lfd_state),
.rst_int_reg(rst_int_reg),
.err(err),
.parity_done(parity_done),
.low_pkt_valid(low_pkt_valid),
.dout(dout)
);

always begin #(T/2);
clock=1'b0; #(T/2);
clock =~clock;
 
end


task reset_dut(); 
begin
@(negedge clock); 
resetn=1'b0; 
@(negedge clock); 
resetn=1'b1;
end
endtask

task packet_generation;
reg [7:0]payload_data,parity,header; 
reg [5:0]payload_len;
reg [1:0]addr; 
integer i;
begin
@(negedge clock) 
payload_len=6'd4; 
addr=2'b10;//valid packet pkt_valid=1;
detect_add=1;
header={payload_len,addr}; parity=header;
data_in=header;
@(negedge clock) 
detect_add=0; 
lfd_state=1; 
full_state=0; 
fifo_full=0; 
laf_state=0;
for(i=0;i<payload_len;i=i+1) 
begin
@(negedge clock) 
lfd_state=0; 
ld_state=1;
payload_data={$random}%256; 
data_in=payload_data; 
parity=parity^data_in;
end
@(negedge clock) 
pkt_valid=0; 
data_in=parity; 
@(negedge clock) 
ld_state=0;
end
endtask

initial 
begin 
clock = 0; 
resetn = 0;
pkt_valid = 0;
data_in = 0;
fifo_full = 0;
detect_add = 0;
ld_state = 0;
laf_state = 0;
full_state = 0;
lfd_state = 0;
rst_int_reg = 0; reset_dut();

// Start packet generation task 
packet_generation();
end
endmodule

