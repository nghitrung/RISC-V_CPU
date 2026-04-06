# 🖥️ Build RISC-V CPU from stratch (SystemVerilog)
A 32-bit RISC-V (RV32I) processor based on a single-cycle architecture designed using SystemVerilog. This project implements a complete hardware datapath and control unit capable of executing fundamental instructions from the RISC-V ISA.

## 🚀 Technical Highlights
* **Hierarchical RTL Design:** Organized into a clean top-level wrapper `top_module` that integrates specialized logic blocks for the PC, Memories, and ALU.
* **Instruction Set Support:** Implements core R-type, I-type, S-type, and SB-type instructions.
* **Modular Data Path:** Features independent modules for the Register File (32x32-bit), Instruction/Data Memories (64 words each), and a parameterized ALU.
* **Deterministic Control Logic:** Uses a centralized `Control unit` and `ALU_control` to generate precise enable signals and operation codes based on 7-bit opcodes.
* **Automated Verification:** Includes a robust testbench top_module_tb with task-based checkers for register and memory consistency.

## 📋 System Overview
The processor executes one instruction per clock cycle following these stages:
1. **Fetch:** Program Counter (PC) provides the address to Instruction Memory.
2. **Decode:** The Control Unit decodes the opcode while the Register File fetches operands.
3. **Execute:** The ALU performs arithmetic or logic operations based on the decoded function.
4. **Memory:** Data is read from or written to Data Memory for load/store instructions.
5. **Write-back:** Results from the ALU or Memory are written back to the destination register.

## 🔄 Operation Modes
* **R-Type:** Arithmetic operations between registers (e.g., add x13, x16, x25).
* **I-Type:** Immediate arithmetic and Loads (e.g., addi x22, x21, 3 or lw).
* **S-Type:*** Stores data from registers to memory (e.g., sw).
* **SB-Type:** Conditional branching (e.g., beq) using an Immediate Generator for offset calculation.

## 📂 File Structure
* **top_module.sv:** The main system wrapper interconnecting all CPU components.
* **risc_cpu_logic.sv:** Core logic containing definitions for the ALU, Control Unit, Register File, and Memories.
* **top_module_tb.sv:** Comprehensive testbench for functional verification and debugging.

## 💻 Requirements
* Software: Xilinx Vivado Design Suite.
* Language: SystemVerilog.

## 📉 Simulation & Verification
* Verified Test Cases:
![my_images](https://github.com/nghitrung/RISC-V_CPU/blob/main/images/RISC-testcase.png)

* Simulation result:
![my_images](https://github.com/nghitrung/RISC-V_CPU/blob/main/images/RISC-testcase.png)


# Authors 
[@ng_trung1405](https://github.com/nghitrung)
