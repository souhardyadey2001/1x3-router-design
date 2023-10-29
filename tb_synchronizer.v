module router_sync_tb(); 
reg clock;
reg resetn;
reg detect_add;
reg write_enb_reg; 
reg read_enb_0;
reg read_enb_1; 
reg read_enb_2; 
reg empty_0;
reg empty_1;
 
reg empty_2; 
reg full_0;
reg full_1;
reg full_2;
reg [1:0] data_in; 
wire vld_out_0; 
wire vld_out_1; 
wire vld_out_2;
wire [2:0] write_enb; 
wire fifo_full;
wire soft_reset_0; 
wire soft_reset_1; 
wire soft_reset_2;

// Instantiate the router_sync 
router_sync u_router_sync (
.clock(clock),
.resetn(resetn),
.detect_add(detect_add),
.write_enb_reg(write_enb_reg),
.read_enb_0(read_enb_0),
.read_enb_1(read_enb_1),
.read_enb_2(read_enb_2),
.empty_0(empty_0),
.empty_1(empty_1),
.empty_2(empty_2),
.full_0(full_0),
.full_1(full_1),
.full_2(full_2),
.data_in(data_in),
.vld_out_0(vld_out_0),
.vld_out_1(vld_out_1),
.vld_out_2(vld_out_2),
.write_enb(write_enb),
.fifo_full(fifo_full),
.soft_reset_0(soft_reset_0),
.soft_reset_1(soft_reset_1),
.soft_reset_2(soft_reset_2)
);
parameter T = 10;

always begin #(T/2);
clock=1'b0; #(T/2);
clock =~clock; end

task reset_dut(); 
begin
 
@(negedge clock); 
resetn=1'b0; 
@(negedge clock); 
resetn=1'b1;
end
endtask

//Synchronizer TB 
task initialze;
begin
detect_add = 1'b0; data_in = 2'b00;
write_enb_reg = 1'b0;
{empty_0,empty_1,empty_2} = 3'b111;
{full_0,full_1,full_2} = 3'b000;
{read_enb_0,read_enb_1,read_enb_2} = 3'b000; 
end
endtask

task addr(input [1:0]m); 
begin
@(negedge clock) 
detect_add = 1'b1; 
data_in = m;
@(negedge clock) 
detect_add = 1'b0; 
end
endtask

task write; 
begin
@(negedge clock)
write_enb_reg = 1'b1; 
@(negedge clock)
write_enb_reg = 1'b0; end
endtask

task stimulus; 
begin
@(negedge clock)
{full_0,full_1,full_2} = 3'b001; 
@(negedge clock)
{read_enb_0,read_enb_1,read_enb_2} = 3'b001; 
@(negedge clock)
{empty_0,empty_1,empty_2} = 3'b110; 
end
endtask

initial 
begin
 
initialze; 
reset_dut;
addr(2'b10);
stimulus; 
#500 $finish; 
end

endmodule

