---
name: mitsubishi-gxworks2-plc
description: Guidelines, file formatting rules, and multi-axis control architectures for Mitsubishi Q-Series PLC programming using GX Works2.
---

# Mitsubishi GX Works2 PLC Development & Code Import Skill

This skill documents proven patterns, file formatting rules, and control architecture guidelines for programming Mitsubishi Q-Series PLCs (e.g. Q13UDEHCPU) on GX Works2.

## 1. GX Works2 Import File Formats

### A. Global Device Comment CSV Format (`Read from CSV File...`)
When creating CSV files for importing comments into GX Works2 Device Comment table, the header MUST be:
`"Device Code","Device No.","Comment"`

Example:
```csv
"Device Code","Device No.","Comment"
"X","80","Nút nhấn START"
"Y","A0","Kích hoạt Servo ON"
"D","500","Loadcell Trục Thu T"
```

### B. Global Label Grid Copy-Paste Rules
When pasting variables into GX Works2 `Global_Variables` grid:
- Do NOT include header rows (`Class`, `Label Name`, `Device`), otherwise GX Works2 will throw compile errors: `C5046` (invalid class), `C5043` (invalid character), `C5003` (invalid device), `C5027` (invalid data type).
- Use TAB-separated values (`.tsv`):
  `Label_Name <TAB> Data_Type <TAB> Class <TAB> Constant <TAB> Device <TAB> Comment`

### C. ASC File Import Format (`Read ASC Format File...`)
GX Works2 `Read ASC Format File...` expects Instruction List (IL) / Mnemonic statements starting with `NOP`/`LD` and ending with `END`. It does NOT accept raw Structured Text (ST) files.

---

## 2. Multi-Axis Paper + Metalize Laminating Machine Control Architecture

### Axis & Actuator Map:
- **Master Speed Axis (X2)**: Sets the line speed reference ($0 \sim 100\text{ m/min}$).
- **Feed Axis (X1)**: Identical mechanics as X2 ($300.5\text{ mm}$ roller, $8/1$ gear ratio). Takes Master X2 speed directly as base speed ($v_{\text{X1\_base}} = v_{\text{X2}}$) and applies a light PID tension offset ($\Delta v_{\text{PID\_X1}}$) to maintain paper tension `Weight_X1`.
- **Laminating Nip Axis (Ms)**: 100% absolute line speed synchronization with Master X2 ($v_{\text{Ms}} = v_{\text{X2}}$) without PID speed feedback loop.
- **Coating Roller Axis (S)**: Pure speed ratio (`Speed_Ratio_S`) & offset (`Speed_Offset_S`) synchronization with Master X2 ($v_{\text{S}} = v_{\text{X2}} \cdot \frac{\text{Ratio}}{1000} + \text{Offset}$) without PID tension feedback loop.
- **Rewinder Axis (T)**: Core diameter expansion speed scaling ($v_{\text{T}} = v_{\text{X2}} \cdot \frac{D_{\text{real\_T}}}{D_{\text{core\_T}}} + \Delta v_{\text{PID\_T}}$).
- **Metalize Film Unwinder (Brake M)**: Magnetic Brake Torque command with 3-Phase Dynamic Torque Scaling.
- **Paper Unwinder Axis (U)**: Diameter uncoiling speed scaling ($v_{\text{U}} = v_{\text{X2}} \cdot \frac{D_{\text{max\_U}}}{D_{\text{real\_U}}} + \Delta v_{\text{PID\_U}}$).

### Hardware Configuration (Q-Series Base Rack):
- **Slot 0**: CC-Link Master (`QJ61BT11N`, `H0000`)
  - **Station 1 (Remote ADC AJ65SBT-64AD)**: Reads 4 loadcell tension sensors (`RWr0..RWr3`).
  - **Station 2 & 3 (Remote DAC AJ65VBTCU-68DAVN)**: 8 Channels $-10\text{V} \sim 10\text{V}$ outputting speed/torque commands (`RWw4..RWw11`).
  - **Station 4 (Remote IO AJ65SBT-16DT)**: 5 Servo Ready (`RX60..RX64`) & Servo ON (`RY60..RY64`) bits.
- **Slot 1, 2, 3**: High Speed Counter modules (`QD62`) reading 5 encoders (T, X1, X2, M, S).
- **Slot 4 & 5**: Digital Input `QX40` (`X50` Metalize proximity sensor, `X51` Paper unwinder proximity sensor) and Digital Output `QY40P` (`Y60..Y65` Roll Lifter Solenoid Valves).

### Key Control & Timing Best Practices:
1. **3-Phase Dynamic Uncoiling Torque Scaling (Brake M & Unwind U):**
   - **Phase 1 (0..5 Revolutions):** Lock diameter calculation and output a fixed Pre-Tension Initial Holding Torque (`Init_Holding_Torque`) to prevent false sensor pulses/eccentricity from snapping the web on new roll startup.
   - **Phase 2 (>5 Revolutions):** Unlock diameter calculation and pass raw pulse readings through an IIR Low-Pass Filter:
     $$\text{Real\_Dia}(k) = \text{Real\_Dia}(k-1) + \frac{\text{Raw\_Dia}(k) - \text{Real\_Dia}(k-1)}{5}$$
   - **Phase 3 (Linear Interpolation + PID):** Dynamically scale holding torque between `Min_Torque` (at core diameter) and `Max_Torque` (at full roll diameter), then add Loadcell PID output.

2. **Machine Stop State Controls:**
   - **Hold Torque When Stopped:** Optional holding torque flags (`Hold_Torque_Stop_M` / `Hold_Torque_Stop_U`) to maintain tension on Brake M and Unwinder U when the line stops, preventing web slack/sag.
   - **Anti-Drying Slow Crawl:** Optional crawl flags (`Anti_Dry_Rotate_S` / `Anti_Dry_Rotate_Ms`) to rotate Coating Roller S and Laminating Roller Ms at low creep speed (e.g., $1.0\text{ m/min}$) when the line is stopped, preventing chemical/glue drying on roller surfaces.

3. **Fixed Scan PID Execution & QX40 Input Filter Tuning:**
   - **10ms Fixed Scan PID Loop (`I28`):** All tension PID Function Blocks MUST be executed inside a Fixed Scan 10ms POU (`I28`) to eliminate sampling time jitter ($\Delta t$) in $I$ and $D$ terms.
   - **QX40 Response Filter for Narrow Pulse Flags:** When high-speed proximity sensor flags are narrow (e.g. 10mm width at 100 m/min $\rightarrow$ 6ms pulse width), the QX40 input response filter MUST be changed from 10ms default to **1ms** (or 0.2ms / 0.5ms) in GX Works2 `PLC Parameter` $\rightarrow$ `I/O Assignment` $\rightarrow$ `Switch Setting`.

