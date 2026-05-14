
## Overview

This project simulates a complete Intel FPGA video pipeline using Quartus Prime Pro 25.1.1 and Questa 2021.2. A Test Pattern Generator (TPG) IP produces EBU color bars over AXI4-Stream, which are buffered through the Video Frame Buffer (VFB) IP into On-Chip Memory. The testbench captures the output pixel stream and a Python script reconstructs it as a PNG image for visual verification.

## Pipeline Architecture

```
TPG (64x64 EBU Bars) --> AXI4-Stream --> VFB (Triple Buffered OCM)
        |                                          |
        | monitor tap                    AXI4-Stream out
        v                                          v
   tpg_output.hex                       output_frame.hex
        |                                          |
        v                                          v
   tpg_output.png                      output_frame.png
```

## Tools

| Tool | Version | Purpose |
|---|---|---|
| Quartus Prime Pro | 25.1.1 | Project management, Platform Designer |
| Questa Intel FPGA | 2021.2 | RTL simulation |
| Python 3 | 3.x | Hex to PNG image conversion |
| Pillow | Latest | Image creation |

## Project Structure

```
tpg_vfb/
    rtl/
        top.v               # RTL wrapper - wires TPG to VFB, exposes monitor tap
    testbench.v             # SystemVerilog testbench
    scripts/
        hex_to_image.py     # Converts hex dump to PNG image
    ip/system/              # Platform Designer .ip files
    system.qsys             # Platform Designer system definition
    tpg_vfb.qpf            # Quartus project file
    tpg_vfb.qsf            # Quartus settings file
```

## IP Configuration

### Test Pattern Generator

| Parameter | Value |
|---|---|
| Resolution | 64 x 64 pixels |
| Pattern | EBU Color Bars |
| Color Space | RGB |
| Bits per sample | 8 |
| Pixels in parallel | 1 |
| Output format | 4:4:4 |

### Video Frame Buffer

| Parameter | Value |
|---|---|
| Mode | Full (not Lite) |
| Buffer behavior | Triple buffering |
| Color planes | 3 (RGB) |
| Bits per sample | 8 |
| Memory | On-Chip RAM (65536 bytes) |
| Memory mapped control | Enabled |

## How to Run

### Step 1 - Generate HDL

Open Platform Designer in Quartus and click:
```
Generate --> Generate HDL --> Simulation: Questa Intel FPGA
```

### Step 2 - Run Simulation

```bash
cd /home/izaan/tpg_vfb/system/sim/mentor
vsim &
```

In Questa transcript:

```
do msim_setup.tcl
vlog -sv /home/izaan/tpg_vfb/rtl/top.v
vlog -sv /home/izaan/tpg_vfb/testbench.v
elab_debug
run -all
```

### Step 3 - Reconstruct Images

```bash
python3 scripts/hex_to_image.py
eog sim/tpg_output.png &
eog sim/output_frame.png &
```

## Testbench Flow

1. Assert reset for 300 cycles (datasheet minimum 256)
2. Release reset, wait 100 cycles
3. Read VID_PID register 0x00 - verify VFB returns 0x6AF70237
4. Poll INPUT_STATUS 0x140 - wait until bit 0 = 1
5. Wait 500 more cycles for triple buffer to fill
6. Write OUTPUT_CONTROL 0x15C = 1 - enable VFB output
7. Assert tready - open pixel stream
8. Capture pixels filtering IIP packets (tuser[1]=1) and SOF beat (tuser[0]=1)
9. Stop after one complete 64x64 frame

## AXI4-Stream tuser Bits

| Bit | Value | Meaning |
|---|---|---|
| tuser[0] | 1 | Start of Frame - first beat of new frame |
| tuser[0] | 0 | Normal pixel data beat |
| tuser[1] | 1 | IIP control packet - NOT pixel data |
| tuser[1] | 0 | Data packet - real RGB pixel |

## VFB Register Map

| Word Addr | Byte Addr | Register | Description |
|---|---|---|---|
| 0x00 | 0x000 | VID_PID | Always 0x6AF70237 |
| 0x50 | 0x140 | INPUT_STATUS | Bit 0 = VFB receiving frames |
| 0x51 | 0x144 | NUM_INPUT_FIELDS | Count of frames received |
| 0x57 | 0x15C | OUTPUT_CONTROL | Write 1 to start output |

## Branch History

| Branch | Description |
|---|---|
| master | Stable base and README |
| feature/clean-frame-capture | Fixed IIP filtering and startup frame skipping |
| feature/tpg-monitor | Added top.v wrapper and dual TPG+VFB capture |
