module router_reg( input clock,
input resetn,
input pkt_valid, input [7:0] data_in, input fifo_full, input detect_add, input ld_state, input laf_state, input full_state, input lfd_state, input rst_int_reg, output reg err,
output reg parity_done, output reg low_pkt_valid, output reg [7:0] dout
);

reg [7:0] Header_byte;
 
reg [7:0] fifo_full_state_byte;
reg [7:0] Packet_parity;
reg [7:0] Internal_parity;

// dout logic
always @(posedge clock or negedge resetn) 
begin if (~resetn) 
begin
dout <= 8'b0;
end 
else if (lfd_state) 
begin 
dout <= Header_byte;
end 
else if (ld_state && ~fifo_full)
 begin dout <= data_in;
end 
else if (laf_state) 
begin 
dout <= fifo_full_state_byte;
end 
end

// Header_byte and fifo_full_state_byte
always @(posedge clock or negedge resetn) 
begin 
if (~resetn) 
begin
Header_byte <= 8'b0;
fifo_full_state_byte <= 8'b0; 
end 
else 
begin
if (pkt_valid && detect_add) 
begin 
Header_byte <= data_in;
end 
else if (ld_state && fifo_full) 
begin
fifo_full_state_byte <= data_in; 
end
end
 end

// parity_done logic
always @(posedge clock or negedge resetn) 
begin 
if (~resetn)
 begin
parity_done <= 1'b0; 
end 
else 
begin
if (ld_state && ~pkt_valid && ~fifo_full) 
begin 
parity_done <= 1'b1;
end 
else if (laf_state && ~parity_done && low_pkt_valid) 
begin parity_done <= 1'b1;
end 
else 
begin
if (detect_add) 
begin parity_done <= 1'b0;
end 
end
end 
end

// low_pkt_valid logic
always @(posedge clock or negedge resetn) 
begin 
if (~resetn) 
begin 
low_pkt_valid <= 1'b0; 
end 
else 
begin
if (rst_int_reg) 
begin
low_pkt_valid <= 1'b0;
end 
else if (~pkt_valid && ld_state) 
begin low_pkt_valid <= 1'b1;
end
end 
end

// Packet_parity logic
always @(posedge clock or negedge resetn) 
begin 
if (~resetn) 
begin
Packet_parity <= 8'b0;
end 
else if ((ld_state && ~pkt_valid && ~fifo_full) || (laf_state && low_pkt_valid && ~parity_done)) 
begin
Packet_parity <= data_in;
end 
else if (~pkt_valid && rst_int_reg) 
begin Packet_parity <= 8'b0;
end 
else 
begin
if (detect_add) 
begin Packet_parity <= 8'b0;
end 
end
end

// internal_parity
always @(posedge clock or negedge resetn) 
begin 
if (~resetn) 
begin
Internal_parity <= 8'b0;
end 
else if (detect_add) 
begin Internal_parity <= 8'b0;
end 
else if (lfd_state) 
begin
Internal_parity <= Header_byte;
end 
else if (ld_state && pkt_valid && ~full_state) 
begin Internal_parity <= Internal_parity ^ data_in;
end 
else if (~pkt_valid && rst_int_reg) 
begin Internal_parity <= 8'b0;
end 
end

// error logic
always @(posedge clock or negedge resetn) 
begin 
if (~resetn) 
begin
err <= 1'b0;
end 
else 
begin
if (parity_done == 1'b1 && (Internal_parity != Packet_parity)) 
begin 
err <= 1'b1;
end
 else 
begin
err <= 1'b0; 
end
 
end 
end

endmodule

