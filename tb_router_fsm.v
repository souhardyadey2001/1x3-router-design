module router_fsm_tb(); 
reg clock;
reg resetn; 
reg pkt_valid;
reg [1:0] data_in; 
reg fifo_full;
reg fifo_empty_0; 
reg fifo_empty_1; 
reg fifo_empty_2; 
reg soft_reset_0; 
reg soft_reset_1; 
reg soft_reset_2; 
reg parity_done; 
reg low_pkt_valid;

wire write_enb_reg; 
wire detect_add;
wire ld_state; 
wire laf_state; 
wire lfd_state; 
wire full_state;
wire rst_int_reg; 
wire busy;

// Instantiate the router_fsm module 
router_fsm uut (
.clock(clock),
.resetn(resetn),
.pkt_valid(pkt_valid),
.data_in(data_in),
.fifo_full(fifo_full),
.fifo_empty_0(fifo_empty_0),
.fifo_empty_1(fifo_empty_1),
.fifo_empty_2(fifo_empty_2),
.soft_reset_0(soft_reset_0),
.soft_reset_1(soft_reset_1),
.soft_reset_2(soft_reset_2),
.parity_done(parity_done),
.low_pkt_valid(low_pkt_valid),
.write_enb_reg(write_enb_reg),
.detect_add(detect_add),
.ld_state(ld_state),
.laf_state(laf_state),
.lfd_state(lfd_state),
.full_state(full_state),
.rst_int_reg(rst_int_reg),
.busy(busy)
 
);

// Clock generation 
always 
begin
#5 clock = ~clock; 
end

// Initialize signals 
initial 
begin
clock = 0;
resetn = 0;
pkt_valid = 0; data_in = 2'b00; fifo_full = 0;
fifo_empty_0 = 0;
fifo_empty_1 = 0;
fifo_empty_2 = 0;
soft_reset_0 = 0;
soft_reset_1 = 0;
soft_reset_2 = 0;
parity_done = 0;
low_pkt_valid = 0;

// Reset router_fsm 
resetn = 1;
#10 resetn = 0;
#10 resetn = 1;

// Execute the test cases using tasks 
t1();
t2();
t3();
t4();

// Add any additional test cases or stimulus here
// ...

// End simulation
$finish; 
end

// Task t1 
task t1(); 
begin
@(negedge clock) 
pkt_valid = 1'b1; 
data_in = 2'b01; 
fifo_empty_1 = 1'b1;
 @(negedge clock) 
@(negedge clock) 
fifo_full = 1'b0;
 
pkt_valid = 1'b0; 
@(negedge clock) 
@(negedge clock) 
fifo_full = 1'b0;
end
endtask


task t2(); 
begin
@(negedge clock) 
pkt_valid = 1'b1; 
data_in = 2'b01; 
fifo_empty_1 = 1'b1; 
@(negedge clock) 
@(negedge clock) 
fifo_full = 1'b1; 
@(negedge clock) 
fifo_full = 1'b0; 
@(negedge clock) 
parity_done = 1'b0;
low_pkt_valid = 1'b1;
 @(negedge clock) 
@(negedge clock) 
fifo_full = 1'b0;
end
endtask


task t3(); 
begin
@(negedge clock) 
pkt_valid = 1'b1; 
data_in = 2'b01; 
fifo_empty_1 = 1'b1; 
@(negedge clock) 
@(negedge clock) 
fifo_full = 1'b1; 
@(negedge clock) 
fifo_full = 1'b0; 
@(negedge clock) 
parity_done = 1'b0;
low_pkt_valid = 1'b0; 
@(negedge clock) 
fifo_full = 1'b0; 
pkt_valid = 1'b0;
 @(negedge clock) 
@(negedge clock) 
fifo_full = 1'b0;
end
endtask
 
task t4(); 
begin
@(negedge clock) 
pkt_valid = 1'b1; 
data_in = 2'b01; 
fifo_empty_1 = 1'b1; 
@(negedge clock) 
@(negedge clock) 
fifo_full = 1'b0; 
pkt_valid = 1'b0; 
@(negedge clock) 
@(negedge clock) 
fifo_full = 1'b1; 
@(negedge clock) 
fifo_full = 1'b0; 
@(negedge clock) 
parity_done = 1'b1; 
end
endtask
endmodule

