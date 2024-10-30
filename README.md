# IOPMP (I/O Protection Management Unit) in SystemVerilog


## Overview
The **IOPMP** (I/O Protection Management Unit) is a hardware module designed to manage protection for memory regions from I/O devices. It ensures that only authorized bus masters can access certain regions of memory. This is especially important in SoC (System-on-Chip) environments where multiple masters and peripherals share the same bus.

This project implements the IOPMP in **SystemVerilog**, simulating the functionality of a protection unit that can be configured to control access permissions to different memory regions based on master IDs.

### Key Features:
- **Region-based Protection**: Configurable regions to allow or deny access.
- **Master ID Filtering**: Protection based on Master IDs.
- **Configurable Permissions**: Supports read, write permissions.
- **Uses TileLink UL**.

---

## Architecture
The IOPMP is based on a SRCMD table, MD table and Entry table. Each SRCMD entry contains MDs associated with the RRID. Each MD contains the top index of entries which is included in that memory region. Each entry includes:
- An address .
- Permissions (Read/Write).
- Interrupt suppressor configuration.

The module monitors all transactions on the bus and checks if the initiating master has the necessary permission to access the requested memory region.

---



---

## Description of Modules

### IOPMP Array Top  
This module is responsible for receiving incoming address requests and their associated request types, which could involve read, write operations. Once the address and request type are captured, the module extracts the relevant Memory Domains (MDs) associated with the Requester ID (RRID). After identifying the MDs, it retrieves the corresponding entries linked to those domains. This data, which includes access permissions and other configuration details, is subsequently sent to the IOPMP checker for validation, ensuring that the request complies with the defined access policies before it is granted or denied.

### IOPMP Control Port  
The primary role of this module is to facilitate the configuration and programming of the IOPMP registers. These registers store critical information, such as the memory region boundaries, permissions for various masters, and other control parameters that dictate how the IOPMP behaves. Through this module, system software can update or modify the protection settings, ensuring that the IOPMP operates with the most current configuration at all times.

### IOPMP Request Handler TLUL  
This module serves as the interface responsible for processing incoming requests from bus masters. Upon receiving a request, the module evaluates it based on the results provided by the IOPMP, which determines whether the requesting master is allowed access to the targeted memory region. Depending on the outcome of this evaluation, the request is either forwarded to the intended slave device for further action or blocked if the access is not permitted. This module ensures that only authorized transactions proceed, maintaining the integrity of the system's memory access.

### Top  
This is the top-level module that acts as the integration point for the main components of the IOPMP system. It brings together the IOPMP Control Port, the IOPMP Array Top, and the Request Handler TLUL, ensuring that they work together as a cohesive unit. The top module coordinates the flow of data between these submodules, allowing the overall IOPMP design to function correctly, providing protection and management for I/O memory access across the system.

---

## Testbench
### Tb_Top 
This is a traditional SystemVerilog testbench designed to apply stimuli to the Top module of the IOPMP project. The testbench generates a variety of input signals that simulate real-world scenarios, including valid and invalid memory access requests. By driving these inputs into the Top module, the testbench checks the system's overall behavior in response to different memory access requests, permissions, and master IDs. The results of each transaction are observed to verify whether the IOPMP functions correctly, ensuring that the protection mechanism is robust. This testbench serves as a fundamental validation tool to ensure that the IOPMP system behaves as expected under various conditions before more complex testing is performed using UVM.

### Tb UVM Control Port
This testbench is built using the Universal Verification Methodology (UVM) framework, specifically designed to test the IOPMP Control Port module. The UVM environment allows for more sophisticated verification through the use of UVM components, such as agents, drivers, monitors, and the scoreboard. In this testbench, UVM sequences are employed to generate randomized data that exercises the control port's functionality. The test focuses on verifying that the control port correctly programs the IOPMP registers, allowing configuration of memory regions and access permissions. Data is collected through an interface and compared against expected results in the UVM scoreboard, ensuring correctness. The UVM methodology also facilitates constrained random testing, increasing the test coverage by running multiple variations of control port configurations and scenarios.

### Tb UVM Request Handler
Similar to the control port testbench, this UVM testbench targets the IOPMP Request Handler module. Using the UVM framework, this testbench thoroughly verifies the behavior of the request handler by generating randomized requests from simulated bus masters. These requests are processed by the request handler, which either forwards or blocks them based on the access permissions set by the IOPMP. The UVM sequences are responsible for generating diverse traffic patterns, including different memory access types (read, write), and memory regions, to ensure the request handler performs as expected under a variety of conditions. Data is monitored and collected through an interface, and the results are compared in the scoreboard to verify the handler's functionality.






