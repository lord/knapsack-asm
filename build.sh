# Generate object file from assembly:
nasm -f macho64 -o knapsack.o knapsack.asm

# Link object file:
ld knapsack.o -o knapsack
