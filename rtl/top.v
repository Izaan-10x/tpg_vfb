`timescale 1ns/1ps

module top (
    // Clock and Reset
    input  wire        clk,
    input  wire        reset,

    // VFB output ? to testbench
    output wire [23:0] vfb_out_tdata,
    output wire        vfb_out_tvalid,
    input  wire        vfb_out_tready,
    output wire        vfb_out_tlast,
    output wire [2:0]  vfb_out_tuser,

    // TPG monitor ? to testbench (read only tap)
    output wire [23:0] tpg_mon_tdata,
    output wire        tpg_mon_tvalid,
    output wire        tpg_mon_tlast,
    output wire [2:0]  tpg_mon_tuser,
    output wire 	tpg_mon_tready,

    // VFB control agent ? to testbench
    input  wire [6:0]  control_agent_address,
    input  wire        control_agent_write,
    input  wire [3:0]  control_agent_byteenable,
    input  wire [31:0] control_agent_writedata,
    input  wire        control_agent_read,
    output wire [31:0] control_agent_readdata,
    output wire        control_agent_readdatavalid,
    output wire        control_agent_waitrequest
);

    // Internal wires between TPG and VFB
    wire [23:0] tpg_tdata;
    wire        tpg_tvalid;
    wire        tpg_tready;  // driven by VFB, goes back to TPG
    wire        tpg_tlast;
    wire [2:0]  tpg_tuser;
   

    // TPG monitor tap ? just observe, no driving
    assign tpg_mon_tdata  = tpg_tdata;
    assign tpg_mon_tvalid = tpg_tvalid;
    assign tpg_mon_tlast  = tpg_tlast;
    assign tpg_mon_tuser  = tpg_tuser;
    assign tpg_mon_tready = tpg_tready;

    system u0 (
        .clk_clk                     (clk),
        .reset_reset                 (reset),

        // TPG output
        .axi4s_vid_out_1_tdata       (tpg_tdata),
        .axi4s_vid_out_1_tvalid      (tpg_tvalid),
        .axi4s_vid_out_1_tready      (tpg_tready),  // input to system, driven by VFB
        .axi4s_vid_out_1_tlast       (tpg_tlast),
        .axi4s_vid_out_1_tuser       (tpg_tuser),

        // VFB input ? wired to TPG output
        .axi4s_vid_in_tdata          (tpg_tdata),
        .axi4s_vid_in_tvalid         (tpg_tvalid),
        .axi4s_vid_in_tready         (tpg_tready),  // output from system, drives TPG tready
        .axi4s_vid_in_tlast          (tpg_tlast),
        .axi4s_vid_in_tuser          (tpg_tuser),

        // VFB output
        .axi4s_vid_out_tdata         (vfb_out_tdata),
        .axi4s_vid_out_tvalid        (vfb_out_tvalid),
        .axi4s_vid_out_tready        (vfb_out_tready),
        .axi4s_vid_out_tlast         (vfb_out_tlast),
        .axi4s_vid_out_tuser         (vfb_out_tuser),

        // Control agent
        .control_agent_address       (control_agent_address),
        .control_agent_write         (control_agent_write),
        .control_agent_byteenable    (control_agent_byteenable),
        .control_agent_writedata     (control_agent_writedata),
        .control_agent_read          (control_agent_read),
        .control_agent_readdata      (control_agent_readdata),
        .control_agent_readdatavalid (control_agent_readdatavalid),
        .control_agent_waitrequest   (control_agent_waitrequest)
    );

endmodule
