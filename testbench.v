`timescale 1ns/1ps

module testbench;

    // =========================================================
    // Parameters
    // =========================================================
    parameter IMG_WIDTH  = 64;
    parameter IMG_HEIGHT = 64;
    parameter TOTAL_PIX  = IMG_WIDTH * IMG_HEIGHT; // 4096

    // =========================================================
    // Signals
    // =========================================================
    reg         clk;
    reg         reset;

    wire [23:0] axi4s_vid_out_tdata;
    wire        axi4s_vid_out_tvalid;
    reg         axi4s_vid_out_tready;
    wire        axi4s_vid_out_tlast;
    wire [2:0]  axi4s_vid_out_tuser;

    reg  [6:0]  control_agent_address;
    reg         control_agent_write;
    reg  [3:0]  control_agent_byteenable;
    reg  [31:0] control_agent_writedata;
    reg         control_agent_read;
    wire [31:0] control_agent_readdata;
    wire        control_agent_readdatavalid;
    wire        control_agent_waitrequest;

    // =========================================================
    // DUT
    // =========================================================
    system u0 (
        .clk_clk                     (clk),
        .reset_reset                 (reset),
        .axi4s_vid_out_tdata         (axi4s_vid_out_tdata),
        .axi4s_vid_out_tvalid        (axi4s_vid_out_tvalid),
        .axi4s_vid_out_tready        (axi4s_vid_out_tready),
        .axi4s_vid_out_tlast         (axi4s_vid_out_tlast),
        .axi4s_vid_out_tuser         (axi4s_vid_out_tuser),
        .control_agent_address       (control_agent_address),
        .control_agent_write         (control_agent_write),
        .control_agent_byteenable    (control_agent_byteenable),
        .control_agent_writedata     (control_agent_writedata),
        .control_agent_read          (control_agent_read),
        .control_agent_readdata      (control_agent_readdata),
        .control_agent_readdatavalid (control_agent_readdatavalid),
        .control_agent_waitrequest   (control_agent_waitrequest)
    );

    // =========================================================
    // Clock 150MHz
    // =========================================================
    initial clk = 0;
    always  #3.33 clk = ~clk;

    // =========================================================
    // Tasks
    // =========================================================
    task write_reg;
        input [6:0]  addr;
        input [31:0] data;
        begin
            @(posedge clk);
            control_agent_address    <= addr;
            control_agent_writedata  <= data;
            control_agent_byteenable <= 4'hF;
            control_agent_write      <= 1'b1;
            @(posedge clk);
            while (control_agent_waitrequest === 1'b1) @(posedge clk);
            control_agent_write      <= 1'b0;
            $display("[%0t] WRITE reg[0x%02h] = 0x%08h", $time, addr, data);
        end
    endtask

    task read_reg;
        input [6:0] addr;
        begin
            @(posedge clk);
            control_agent_address    <= addr;
            control_agent_byteenable <= 4'hF;
            control_agent_read       <= 1'b1;
            @(posedge clk);
            while (control_agent_waitrequest === 1'b1) @(posedge clk);
            control_agent_read       <= 1'b0;
            @(posedge clk);
            wait (control_agent_readdatavalid === 1'b1);
            $display("[%0t] READ  reg[0x%02h] = 0x%08h",
                     $time, addr, control_agent_readdata);
        end
    endtask

    // Poll INPUT_STATUS until bit0 goes high
    // meaning VFB has received at least one frame
    task wait_for_input;
        integer timeout;
        begin
            timeout = 0;
            $display("[%0t] Waiting for VFB to receive first frame...", $time);
            forever begin
                read_reg(7'h50); // INPUT_STATUS
                if (control_agent_readdata[0] === 1'b1) begin
                    $display("[%0t] INPUT_STATUS = 1, VFB is receiving!", $time);
                    disable wait_for_input;
                end
                timeout = timeout + 1;
                if (timeout > 500) begin
                    $display("[%0t] TIMEOUT waiting for INPUT_STATUS!", $time);
                    $stop;
                end
                repeat(200) @(posedge clk);
            end
        end
    endtask

    // =========================================================
    // Pixel capture
    // =========================================================
    integer file_out;
    integer pix_count;
    integer frame_count;

    initial begin
        file_out    = $fopen("/home/izaan/tpg_vfb/sim/output_frame.hex", "w");
        pix_count   = 0;
        frame_count = 0;
    end

    always @(posedge clk) begin
        if (axi4s_vid_out_tvalid && axi4s_vid_out_tready) begin
            if (axi4s_vid_out_tuser[0]) begin
                $display("[%0t] SOF ? Frame %0d starting", $time, frame_count);
                pix_count = 0;
            end
            $fdisplay(file_out, "%h", axi4s_vid_out_tdata);
            pix_count = pix_count + 1;
            if (axi4s_vid_out_tlast)
                $display("[%0t] EOL at pixel %0d", $time, pix_count);
            if (pix_count == TOTAL_PIX) begin
                $display("[%0t] *** FRAME %0d COMPLETE ***", $time, frame_count);
                frame_count = frame_count + 1;
                if (frame_count == 2) begin
                    $display("[%0t] 2 frames done. Stopping.", $time);
                    $fclose(file_out);
                    $stop;
                end
            end
        end
    end

    // =========================================================
    // Main stimulus
    // =========================================================
    initial begin
        // Init everything
        reset                    <= 1'b1;
        axi4s_vid_out_tready     <= 1'b0;
        control_agent_address    <= 7'h00;
        control_agent_write      <= 1'b0;
        control_agent_read       <= 1'b0;
        control_agent_writedata  <= 32'h0;
        control_agent_byteenable <= 4'hF;

        // Reset for 300 cycles (datasheet minimum is 256)
        repeat(300) @(posedge clk);
        reset <= 1'b0;
        $display("[%0t] Reset released", $time);
        repeat(100) @(posedge clk);

        // Step 1: verify VFB is alive
        $display("--- VID_PID check (expect 0x6AF70237) ---");
        read_reg(7'h00);

        // Step 2: wait until TPG has fed at least one frame into VFB
        wait_for_input;

        // Step 3: wait a bit more so triple buffer has a full frame ready
        repeat(500) @(posedge clk);

        // Step 4: read stats before enabling output
        $display("--- NUM_INPUT_FIELDS ---");
        read_reg(7'h51); // 0x51*4 = 0x144

        // Step 5: enable output
        $display("--- Enabling VFB output ---");
        write_reg(7'h57, 32'h0000_0001); // OUTPUT_CONTROL

        // Step 6: open ready so pixels flow out
        @(posedge clk);
        axi4s_vid_out_tready <= 1'b1;
        $display("[%0t] tready asserted, pixels flowing...", $time);

        // Step 7: watchdog
        #5_000_000;
        $display("[%0t] WATCHDOG: no complete frame. Check waveform.", $time);
        $fclose(file_out);
        $stop;
    end

endmodule
