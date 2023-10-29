module router_fsm(input clock,resetn,pkt_valid,
input [1:0] data_in, input
fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done, low_pkt_valid,
output
write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);

parameter DECODE_ADDRESS = 3'b000, LOAD_FIRST_DATA = 3'b001, LOAD_DATA = 3'b010, FIFO_FULL_STATE = 3'b011, LOAD_AFTER_FULL = 3'b100, LOAD_PARITY = 3'b101, CHECK_PARITY_ERROR = 3'b110, WAIT_TILL_EMPTY = 3'b111;
reg [2:0] present_state, next_state; 
reg [2:0] addr;
//present_state logic 
always@(posedge clock) 
begin
if(~resetn)
present_state<= DECODE_ADDRESS; 
else
if((soft_reset_0 && data_in==2'b00) || (soft_reset_1 && data_in==2'b01) || (soft_reset_2 && data_in==2'b10))
present_state <= DECODE_ADDRESS; 
else
present_state <= next_state; 
end


//internal variable addr logic 
always@(posedge clock)
begin 
if(~resetn) 
addr<=0;
else if((soft_reset_0 && data_in==2'b00) || (soft_reset_1 && data_in==2'b01) || (soft_reset_2 && data_in==2'b10))
addr <= 0;
else if(detect_add)
 addr <= data_in;
end

//next_state logic 
always@(*)
begin
next_state = present_state;
 begin
case(present_state)
 
DECODE_ADDRESS : if((pkt_valid && (data_in==0) && fifo_empty_0)||(pkt_valid && (data_in==1) && fifo_empty_1) ||(pkt_valid && (data_in==2) && fifo_empty_2))
next_state=LOAD_FIRST_DATA;
else if((pkt_valid && (data_in==0) && ~fifo_empty_0) ||(pkt_valid && (data_in==1) && ~fifo_empty_1) ||(pkt_valid && (data_in==2) && ~fifo_empty_2)) 
next_state=WAIT_TILL_EMPTY;
else next_state = DECODE_ADDRESS;
LOAD_FIRST_DATA : next_state = LOAD_DATA; 
LOAD_DATA : if(fifo_full)
next_state = FIFO_FULL_STATE; 
else if(!fifo_full && !pkt_valid) next_state = LOAD_PARITY;
else next_state = LOAD_DATA;
default : next_state = DECODE_ADDRESS; 
LOAD_PARITY : next_state = CHECK_PARITY_ERROR; 
CHECK_PARITY_ERROR : if(!fifo_full)
next_state = DECODE_ADDRESS; 
else
next_state = FIFO_FULL_STATE;
 FIFO_FULL_STATE : if(fifo_full) next_state = FIFO_FULL_STATE; 
else
next_state = LOAD_AFTER_FULL;
LOAD_AFTER_FULL : if(!parity_done && !low_pkt_valid) next_state = LOAD_DATA;
else if(!parity_done && low_pkt_valid)
next_state=LOAD_PARITY;
else next_state = DECODE_ADDRESS;
WAIT_TILL_EMPTY : if((fifo_empty_0 && (addr == 0)) || (fifo_empty_1 && (addr ==1)) || (fifo_empty_2 && (addr == 2)))
next_state = LOAD_FIRST_DATA;
else next_state = WAIT_TILL_EMPTY; 
endcase
end
 end
//output signals
assign detect_add = (present_state == DECODE_ADDRESS) ? 1'b1 : 1'b0; 
assign lfd_state =(present_state==LOAD_FIRST_DATA) ? 1'b1 : 1'b0; 
assign ld_state=(present_state==LOAD_DATA) ? 1'b1 : 1'b0;
assign full_state=(present_state==FIFO_FULL_STATE) ? 1'b1 : 1'b0; 
assign laf_state=(present_state==LOAD_AFTER_FULL) ? 1'b1 : 1'b0;
assign rst_int_reg=(present_state==CHECK_PARITY_ERROR) ? 1'b1 : 1'b0; 
assign write_enb_reg=((present_state==LOAD_DATA)||(present_state==LOAD_AFTER_FULL)||(present_state==LOAD_PARITY)) ? 1'b1 : 1'b0;
assign busy=((present_state==LOAD_FIRST_DATA)||(present_state==FIFO_FULL_STATE)||(present_state==LOAD_AFTER_FULL)||(present_state==LOAD_PARITY)||(present_state==CHECK_PARITY_ERROR)||(present_state==WAIT_TILL_EMPTY)) ? 1'b1 : 1'b0;

endmodule

