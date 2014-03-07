%ifidn __OUTPUT_FORMAT__,elf64
%define SYSCALL_READ 0
%define SYSCALL_WRITE 1
%define SYSCALL_OPEN 2
%define SYSCALL_CLOSE 3
%define SYSCALL_EXIT 60
%elifidn __OUTPUT_FORMAT__,macho64
%define SYSCALL_WRITE 0x2000004
%define SYSCALL_EXIT 0x2000001
%endif

  global start
  global _start

section .text

start:
_start:
