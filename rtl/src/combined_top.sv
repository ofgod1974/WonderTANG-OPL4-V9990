//
// tnCart_board_wt200b_top.sv
//
// BSD 3-Clause License
//
// Copyright (c) 2024, Albert Herranz
//
// Based on tnCart_board_rev1_top.sv
// Copyright (c) 2024, Shinobu Hashimoto
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its
//    contributors may be used to endorse or promote products derived from
//    this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

`default_nettype none

module WONDER_OPL4_V9990_TOP (
    input   wire            CLK_27M,

    // SDRAM
    output  wire            O_sdram_clk,
    output  wire            O_sdram_cke,
    output  wire            O_sdram_cs_n,
    output  wire            O_sdram_cas_n,
    output  wire            O_sdram_ras_n,
    output  wire            O_sdram_wen_n,
    inout   wire    [31:0]  IO_sdram_dq,
    output  wire    [10:0]  O_sdram_addr,
    output  wire    [1:0]   O_sdram_ba,
    output  wire    [3:0]   O_sdram_dqm,

    // BUS
    output  wire            CART_BUSDIR_n,
    output  wire            CART_INT_n,
    output  wire            CART_WAIT_n,
    input   wire            CART_SLTSL_n,
    input   wire            CART_RD_n,
    input   wire            CART_WR_n,
    input   wire            CART_CLOCK,
    input   wire    [7:0]   CART_MUX_SIG,
    output  wire    [2:0]   CART_MUX_CS_n,
    inout   wire    [7:0]   CART_DATA_SIG,
    output  wire            CART_DATA_DIR,

    // DAC
    output  wire            DAC_BCLK,
    output  wire            DAC_LRCLK,
    output  wire            DAC_DIN,
    output  wire            DAC_SDMODE_n,


    // LED
    output  wire            LED,

    // TMDS
    output wire             tmds_clk_p,
    output wire             tmds_clk_n,
    output wire    [2:0]    tmds_data_p,
    output wire    [2:0]    tmds_data_n,

    // SPI FLASH
    output  wire            mspi_cs,
    output  wire            mspi_sclk,
    input   wire            mspi_miso,
    output  wire            mspi_mosi,
    output  wire            mspi_hold,

    // TF
    output  wire            TF_SCLK,    // SCLK
    output  wire            TF_CMD,     // MOSI
    input   wire            TF_DAT0,    // MISO
    inout   wire            TF_DAT1,    // NC
    inout   wire            TF_DAT2,    // NC
    inout   wire            TF_DAT3,    // CS_n

    // UART
    input   wire            UART_RX,
    output  wire            UART_TX
);

    wire CLK_BASE, CLK_MEM, CLK_MEM_P, CLK_BASE_READY, CLK_MEM_READY;
    wire CLK_TMDS_S, CLK_TMDS_P, CLK_TMDS_READY, CLK_21M, CLK_DAC;
    wire CLK_54M, CLK_FM;
    BOARD_WT200B_CLOCK u_clk (
        .RESET_n(1'b1), .CLK_IN(CLK_27M), .CLK_27M,
        .CLK_BASE, .CLK_BASE_READY, .CLK_MEM, .CLK_MEM_P, .CLK_MEM_READY,
        .CLK_TMDS_S, .CLK_TMDS_P, .CLK_TMDS_READY, .CLK_21M, .CLK_DAC
    );
    CLKDIV u_div54(.HCLKIN(CLK_BASE),.CLKOUT(CLK_54M),.RESETN(CLK_BASE_READY),.CALIB(1'b0));
    defparam u_div54.DIV_MODE="2";
    defparam u_div54.GSREN="false";
    CLKDIV u_div27(.HCLKIN(CLK_BASE),.CLKOUT(CLK_FM),.RESETN(CLK_BASE_READY),.CALIB(1'b0));
    defparam u_div27.DIV_MODE="4";
    defparam u_div27.GSREN="false";
    wire sdram_ready;
    reg [3:0] reset_pipe=0;
    always @(posedge CLK_BASE or negedge CLK_BASE_READY)
        if (!CLK_BASE_READY) reset_pipe<=0;
        else reset_pipe<={reset_pipe[2:0],sdram_ready};
    wire RESET_n=reset_pipe[3];
    BUS_IF Bus();
    BUS_IF VBus();
    BOARD_REV1_BUS u_bus (
        .RESET_n, .CLK(CLK_BASE),.CLK_21M,
        .CART_BUSDIR_n,.CART_INT_n,.CART_WAIT_n,.CART_SLTSL_n,.CART_RD_n,.CART_WR_n,
        .CART_CLOCK,.CART_MUX_SIG,.CART_MUX_CS_n,.CART_DATA_SIG,.CART_DATA_DIR,.Bus
    );
    // Pure I/O devices: never expose a ROM or expanded slot on memory reads.
    assign VBus.ADDR=Bus.ADDR;
    assign VBus.DIN=Bus.DIN;
    assign VBus.RD_n=Bus.RD_n;
    assign VBus.WR_n=Bus.WR_n;
    assign VBus.IORQ_n=Bus.IORQ_n | !bus_alive;
    assign VBus.MERQ_n=Bus.MERQ_n;
    assign VBus.SLTSL_n=1'b1;
    assign VBus.RESET_n=Bus.RESET_n;
    assign VBus.M1_n=Bus.M1_n;
    assign VBus.RFSH_n=Bus.RFSH_n;
    assign VBus.CS1_n=Bus.CS1_n;
    assign VBus.CS2_n=Bus.CS2_n;
    assign VBus.CS12_n=Bus.CS12_n;
    assign VBus.CLK=Bus.CLK;
    assign VBus.CLK_EN=Bus.CLK_EN;
    assign VBus.CLK_21M=Bus.CLK_21M;
    assign VBus.CLK_EN_21M=Bus.CLK_EN_21M;
    RAM_IF Ram();
    RAM_IF UmaRam[0:1]();
    UMA_IF Uma();
    // OPL4 wave memory occupies 0..3fffff; video at 780000..7fffff.
    assign Uma.ADDR[0]=24'h000000;
    assign Uma.ADDR[1]=24'h780000;
    SDRAM #(.SDRAM_A_WIDTH(11),.SDRAM_BA_WIDTH(2),.SDRAM_COL_WIDTH(8),
      .SDRAM_ROW_WIDTH(11),.SDRAM_DQ_WIDTH(32)) u_sdram (
        .CLK(CLK_MEM),.CLK_PS(CLK_MEM_P),.RESET_n(CLK_MEM_READY),.READY(sdram_ready),
        .SDRAM_CLK(O_sdram_clk),.SDRAM_CKE(O_sdram_cke),.SDRAM_CS_n(O_sdram_cs_n),
        .SDRAM_CAS_n(O_sdram_cas_n),.SDRAM_RAS_n(O_sdram_ras_n),.SDRAM_WE_n(O_sdram_wen_n),
        .SDRAM_A(O_sdram_addr),.SDRAM_BA(O_sdram_ba),.SDRAM_DQM(O_sdram_dqm),
        .SDRAM_DQ(IO_sdram_dq),.Ram
    );
    UMA #(.COUNT(2),.SYNC_CLK_EN(0),.DIV(30)) u_uma (
        .RESET_n,.CLK(CLK_BASE),.CLK_EN(Bus.CLK_EN),.Primary(Ram),.Secondary(UmaRam),.Uma
    );
    VIDEO_IF Video();
    VIDEO_IF VideoTmds();
    CARTRIDGE_V9990 u_v9990 (
        .RESET_n,.CLK(CLK_BASE),.Bus(VBus),.Ram(UmaRam[1]),.UmaClock(Uma),.Video
    );
    VIDEO_UPSCAN #(.ENABLE_SCANLINE(0)) u_upscan (
        .RESET_n,.DCLK(CLK_TMDS_P),.IN(Video),.OUT(VideoTmds)
    );
    BOARD_REV1_TMDS_OUT u_tmds (
        .RESET_n,.IN(VideoTmds),.TMDS_READY(CLK_TMDS_READY),.CLK_S(CLK_TMDS_S),
        .CLK_P(CLK_TMDS_P),.TMDS_CLKP(tmds_clk_p),.TMDS_CLKN(tmds_clk_n),
        .TMDS_DATAP(tmds_data_p),.TMDS_DATAN(tmds_data_n)
    );
    reg io_n,rd_n,wr_n,m1_n,slot_rst,slot_clk;
    reg [7:0] addr,din;
    always @(posedge CLK_54M) begin
        io_n<=Bus.IORQ_n; rd_n<=Bus.RD_n; wr_n<=Bus.WR_n; m1_n<=Bus.M1_n;
        addr<=Bus.ADDR[7:0]; din<=Bus.DIN; slot_rst<=Bus.RESET_n; slot_clk<=Bus.CLK;
    end
    wire wave_req,wave_we,wave_done,mem_timeout;
    wire [21:0] wave_addr;
    wire [7:0] wave_wdata,opl_rd_data;
    wire [15:0] wave_rdata;
    wire opl_rd_active,opl_wait_n,opl_int_n,por_n,bus_alive;
    wire loaded,load_error,bad_image;
    wire signed [15:0] mix_mono;
    WAVE_UMA_BRIDGE u_wave_bridge (
        .CLK(CLK_BASE),.RESET_n,.req(wave_req),.we(wave_we),.addr(wave_addr),
        .wdata(wave_wdata),.rdata(wave_rdata),.done(wave_done),.timeout(mem_timeout),.Ram(UmaRam[0])
    );
    moontang_shared_core #(.ENG_CE_INC(24'd392),.ENG_CE_MOD(24'd625),
      .ENG_BAUD_DIV(9'd469),.Y8950(0)) u_opl4 (
        .clk_108m(CLK_BASE),.clk_sdram(CLK_MEM_P),.clk_54m(CLK_54M),.clk_27m(CLK_FM),
        .clk_eng(CLK_54M),.pll_locked(RESET_n),.eng_locked(RESET_n),.por_reset_n(por_n),
        .iorq_n(io_n),.rd_n,.wr_n,.m1_n,.addr,.din,.slot_reset_n(slot_rst),.slot_clk,
        .rd_data(opl_rd_data),.rd_active(opl_rd_active),.wait_n(opl_wait_n),.int_n(opl_int_n),
        .bus_reset_n(),.clk_alive(bus_alive),.fm_l(),.fm_r(),.wave_l(),.wave_r(),
        .mix_l(),.mix_r(),.mix_mono,.y8950_vu(),.sample_used_gray(),
        .sdram_init_busy(!sdram_ready),.wl_done(loaded),.wl_error(load_error),.wl_badimg(bad_image),
        .sd_timeout(mem_timeout),.dbg_tx(UART_TX),.mspi_cs,.mspi_sclk,.mspi_miso,.mspi_mosi,
        .ext_req(wave_req),.ext_we(wave_we),.ext_addr(wave_addr),.ext_wdata(wave_wdata),
        .ext_rdata(wave_rdata),.ext_done(wave_done)
    );
    assign Bus.DOUT=opl_rd_active ? opl_rd_data : VBus.DOUT;
    assign Bus.BUSDIR_n=!(opl_rd_active || !VBus.BUSDIR_n);
    assign Bus.INT_n=(opl_int_n & VBus.INT_n) | !bus_alive;
    assign Bus.WAIT_n=(opl_wait_n & VBus.WAIT_n) | !bus_alive;
    wire signed [15:0] sample;
    i2s_feed u_feed(.clk(CLK_54M),.lrclk(DAC_LRCLK),.samp_l(mix_mono),.samp_r(mix_mono),.sample);
    I2S_AUDIO_TX u_i2s(.CLK_DAC,.RESET_n(por_n),.SAMPLE_IN(sample),.REQ(),.DAC_BCLK,.DAC_LRCLK,.DAC_DIN);
    assign DAC_SDMODE_n=por_n;
    assign mspi_hold=1'b1;
    assign TF_SCLK=1'b0;
    assign TF_CMD=1'b1;
    assign TF_DAT1=1'bz;
    assign TF_DAT2=1'bz;
    assign TF_DAT3=1'b1;
    reg [24:0] blink=0;
    always @(posedge CLK_54M) blink<=blink+1'b1;
    assign LED=!RESET_n ? 1'b0 : (load_error || bad_image || mem_timeout) ?
        (blink[24] & blink[21]) : !loaded ? blink[23] : bus_alive;
endmodule
`default_nettype wire
