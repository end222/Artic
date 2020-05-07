# RISC-V RV32I

[WIP] Open source implementation of the RV32I ISA with a 5 stage pipeline.

## Compiler and tests

There is a mini-compiler included that translates RISC-V assembly code into machine code and inserts the result directly into the VHDL file that contains the memory so as to make it easier to launch a simulation of the test in a program like Vivado.

In order to do this, the following command has to be executed in the root of the repository:
```bash
./compiler.sh path_of_asm_file
```

The tests used to check whether the implemented CPU is working correctly are included in the "tests" folder.
