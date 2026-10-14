// Shared wave-memory client for tnCart UMA. Byte writes, aligned 16-bit reads.
// The UMA ACK is low while busy and returns high after DOUT is registered.
`default_nettype none
module WAVE_UMA_BRIDGE (
    input wire CLK, RESET_n,
    input wire req, we,
    input wire [21:0] addr,
    input wire [7:0] wdata,
    output reg [15:0] rdata,
    output reg done,
    output reg timeout,
    RAM_IF.HOST Ram
);
    localparam IDLE=0, ACCEPT=1, COMPLETE=2, RELEASE=3;
    reg [1:0] state;
    reg refresh_op;
    reg [9:0] refresh_count;
    reg refresh_due;
    reg [15:0] watchdog;
    always @(posedge CLK or negedge RESET_n) begin
        if (!RESET_n) begin
            state<=IDLE; done<=0; rdata<=0; timeout<=0;
            refresh_count<=0; refresh_due<=0; refresh_op<=0; watchdog<=0;
            Ram.ADDR<=0; Ram.DIN<=0; Ram.DIN_SIZE<=RAM::DIN_SIZE_8;
            Ram.OE_n<=1; Ram.WE_n<=1; Ram.RFSH_n<=1;
        end else begin
            done<=0;
            if (refresh_count==10'd755) begin
                refresh_count<=0; refresh_due<=1;
            end else refresh_count<=refresh_count+1'b1;
            case(state)
            IDLE: begin
                watchdog<=0;
                if (refresh_due) begin
                    refresh_op<=1; refresh_due<=0;
                    Ram.RFSH_n<=0; state<=ACCEPT;
                end else if (req) begin
                    refresh_op<=0;
                    Ram.ADDR<=we ? {2'b00,addr} : {2'b00,addr[21:1],1'b0};
                    Ram.DIN<={24'd0,wdata};
                    Ram.DIN_SIZE<=we ? RAM::DIN_SIZE_8 : RAM::DIN_SIZE_16;
                    Ram.WE_n<=!we; Ram.OE_n<=we; state<=ACCEPT;
                end
            end
            ACCEPT: begin
                watchdog<=watchdog+1'b1;
                if (!Ram.ACK_n) begin
                    Ram.OE_n<=1; Ram.WE_n<=1; Ram.RFSH_n<=1;
                    state<=COMPLETE;
                end else if (&watchdog) begin
                    timeout<=1; Ram.OE_n<=1; Ram.WE_n<=1; Ram.RFSH_n<=1;
                    state<=RELEASE;
                    if (!refresh_op) begin rdata<=16'hffff; done<=1; end
                end
            end
            COMPLETE: begin
                watchdog<=watchdog+1'b1;
                if (Ram.ACK_n) begin
                    if (!refresh_op) begin rdata<=Ram.DOUT[15:0]; done<=1; end
                    state<=refresh_op ? IDLE : RELEASE;
                end else if (&watchdog) begin
                    timeout<=1; state<=RELEASE;
                    if (!refresh_op) begin rdata<=16'hffff; done<=1; end
                end
            end
            RELEASE: if (!req || refresh_op) state<=IDLE;
            default: state<=IDLE;
            endcase
        end
    end
endmodule
`default_nettype wire
