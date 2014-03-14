# Generate object file from assembly:
nasm -f elf64 -o knapsack.o -g -F dwarf knapsack.asm

# Link object file:
ld knapsack.o -o knapsack
