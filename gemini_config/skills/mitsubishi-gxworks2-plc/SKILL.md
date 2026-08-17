---
name: mitsubishi-gxworks2-plc
description: Guidelines, file formatting rules, and multi-axis control architectures for Mitsubishi Q-Series PLC programming using GX Works2.
---

# Mitsubishi GX Works2 PLC Development & Multi-Axis Control Skill

This skill documents proven patterns, compiler invariants, file formatting rules, and multi-axis machine control architecture guidelines for programming Mitsubishi Q-Series PLCs (e.g. Q02U, Q00UJ, Q13UDEH) on GX Works2.

---

## 1. GX Works2 Import File Formats & Compiler Invariants

### A. Label Scope & Declaration Rules (Preventing Errors `F1055` & `C1028`)
1. **Zero Duplicate Declarations (Error `F1055`):**
   - In GX Works2, a label declared in **Global Labels** (`VAR_GLOBAL` assigned to devices like `D766`, `M100`) MUST NEVER be declared in **Local Labels** (`VAR`) of any POU.
   - Declaring the same variable in both scopes causes compile failure `F1055: The identical label name was declared in a global label and a local label`.
2. **Full Label Synchronism (Error `C1028`):**
   - Every variable introduced in Structured Text code MUST exist in either the Global or Local Label table.
   - When generating code, always generate accompanying `.tsv` label files without headers for instant 1-click grid copy-pasting.

### B. Global Device Comment CSV Format (`Read from CSV File...`)
When creating CSV files for importing comments into GX Works2 Device Comment table, the header MUST be:
```csv
"Device Code","Device No.","Comment"
"X","50","Sensor tiem can dem 1 vong cuon M"
"Y","8","Servo ON Truc Thu T"
"D","510","Trong luong Luc cang thuc te T"
```

### C. Global Label Grid Copy-Paste Rules
When pasting variables into GX Works2 `Global_Variables` or `Local_Variables` grid:
- Do NOT include header rows (`Class`, `Label Name`, `Device`), otherwise GX Works2 will throw compile errors: `C5046` (invalid class), `C5043` (invalid character), `C5003` (invalid device), `C5027` (invalid data type).
- Format as TAB-separated values (`.tsv`):
  `Label_Name <TAB> Data_Type <TAB> Class <TAB> Constant <TAB> Device <TAB> Comment`

### D. WDT & Scan Time Tuning for Real-Time Accuracy
- On Q-Series CPUs (Q02U/Q00U), set **`Constant Scanning = 2.0 ms`** and **`WDT = 500 ms`** in `PLC Parameter -> PLC RAS`.
- This stabilizes scan cycle jitter, prevents WDT timeout error `5010`, and guarantees reliable pulse detection on high-speed proximity inputs (`X50/X51`) even at line speeds $\ge 100\text{ m/min}$.

### E. 32-Bit Arithmetic Overflow Protection
- Always cast intermediate products to `Double Word[Signed]` (`DINT`) before multiplying large integers:
  $$\text{Scaled} = \frac{\text{DINT\_Val} \times 4000}{\text{Max\_Limit}}$$
- Performing $4000 \times 4000 = 16,000,000$ in 16-bit INT silently overflows ($> 32,767$) and produces negative/erratic DAC voltages.

---

## 2. Multi-Axis Paper + Metalize Laminating Machine Control Architecture

### Axis & Actuator Map:
- **Master Speed Axis (X2 - 1000 RPM Max)**:
  - Sets the line speed reference ($0 \sim 100\text{ m/min}$).
  - Runs **`pid_X2` (Speed PID Loop)** to regulate line speed against load disturbances.
- **Feed Axis (X1 - 1000 RPM Max)**:
  - Synchronizes to Master X2 line speed + **`pid_X1` (Tension PID Loop)**:
    $$v_{\text{X1}} = \left( v_{\text{X2}} \cdot \frac{\text{Speed\_Ratio\_X1}}{1000} \right) + \Delta v_{\text{PID\_X1}}$$
- **Laminating Nip Axis (Ms - 3000 RPM Max)**:
  - Synchronizes to Master X2 line speed + **`pid_Ms` (Speed PID Loop)**:
    $$v_{\text{Ms}} = \left( \frac{v_{\text{X2}} \cdot D_{\text{Ms}}}{D_{\text{X2}}} \right) \cdot \frac{\text{Speed\_Ratio\_Ms}}{1000} + \Delta v_{\text{PID\_Ms}}$$
- **Coating Roller Axis (S - 3000 RPM Max)**:
  - Synchronizes to Master X2 line speed + **`pid_S` (Speed PID Loop)**:
    $$v_{\text{S}} = \left( v_{\text{X2}} \cdot \frac{\text{Speed\_Ratio\_S}}{1000} \right) + \text{Speed\_Offset\_S} + \Delta v_{\text{PID\_S}}$$
- **Rewinder Axis (T - 1500 RPM Max - Speed/Torque Mode)**:
  - **Speed Reference:** Leads ahead ($105\% \sim 115\%$ via `Speed_Ratio_T = 1050`) based on expanding core diameter:
    $$v_{\text{T\_ref}} = \left( v_{\text{X2}} \cdot \frac{D_{\text{real\_T}}}{D_{\text{core\_T}}} \right) \cdot \frac{\text{Speed\_Ratio\_T}}{1000}$$
  - **Torque Limit Reference:** Controlled dynamically via Tension PID `pid_T` + Taper tension curve ($0 \sim 100\%$) to maintain constant tension across expanding roll diameters without web tearing.
- **Metalize Film Unwinder (Brake M)**:
  - Magnetic Brake Torque command with 3-Phase Dynamic Torque Scaling + Loadcell Tension PID `pid_M`.
- **Paper Unwinder Axis (U)**:
  - Diameter uncoiling speed scaling ($v_{\text{U}} = v_{\text{X2}} \cdot \frac{D_{\text{max\_U}}}{D_{\text{real\_U}}} + \Delta v_{\text{PID\_U}}$).

---

## 3. High-Precision Length Tracking & 2-Phase Auto Stop

1. **Differential Pulse Accumulation:**
   - Measure encoder pulse difference each scan: $\Delta \text{Pulse\_X2} = \text{Curr\_Pulse\_X2} - \text{Last\_Pulse\_X2}$.
   - Calculate exact travel distance in mm:
     $$\Delta \text{Length\_mm} = \frac{\Delta \text{Pulse\_X2} \cdot \pi \cdot D_{\text{X2}}}{8000 \cdot \text{Gear\_Ratio\_X2}}$$
   - Accumulate and increment `Total_Length_Meters` (`D708`) every $1000\text{ mm}$.
2. **2-Phase Target Length Deceleration & Auto-Stop:**
   - **Phase 1 (Early Decel):** When $\text{Total\_Length\_Meters} \ge \text{Set\_Target\_Length} - \text{Decel\_Distance\_Meters}$ $\rightarrow$ Set `Auto_Decel_Flag = TRUE` and automatically ramp down line speed to `Min_Speed_MPM` ($2.0\text{ m/min}$).
   - **Phase 2 (Safe Stop):** When $\text{Total\_Length\_Meters} \ge \text{Set\_Target\_Length}$ $\rightarrow$ Set `State_Machine = 0` (Stop line, automatically release nip pens `M1309/M1310`, and activate holding torque).

---

## 4. Manual / Jog Test Architecture for Commissioning

Provide dedicated test flags and independent speed/torque registers so engineers can test and commission each axis independently when the main line is stopped (`State_Machine = 0`):
- `HMI_Test_T` (`M170`) $\rightarrow$ Speed `D800` & Torque `D801`
- `HMI_Test_X1` (`M171`) $\rightarrow$ Speed `D802`
- `HMI_Test_X2` (`M172`) $\rightarrow$ Speed `D804`
- `HMI_Test_Ms` (`M173`) $\rightarrow$ Speed `D806`
- `HMI_Test_S` (`M174`) $\rightarrow$ Speed `D808`
- `HMI_Test_M` (`M175`) $\rightarrow$ Torque `D810`
- `HMI_Test_U` (`M176`) $\rightarrow$ Speed `D812`

---

## 5. Weintek EasyBuilder Pro HMI Integration

1. **Device Driver:** Select `Mitsubishi Q00/Q00UJ/Q01/QJ71` (RS-232 / COM1: 19200, O, 8, 1 or Ethernet).
2. **Address Tag Library Import:** Pre-generate `weintek_easybuilder_tags_import.csv` with columns `"Name","Device","Address","Data Type","Description"` for 1-click tag import into EasyBuilder Pro.
