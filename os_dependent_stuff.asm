%ifidn __OUTPUT_FORMAT__,elf64
%define SYSCALL_READ 0
%define SYSCALL_WRITE 1
%define SYSCALL_OPEN 2
%define SYSCALL_CLOSE 3
%define SYSCALL_EXIT 60
%elifidn __OUTPUT_FORMAT__,macho64
%define SYSCALL_WRITE 0x2000004
%define SYSCALL_EXIT 0x2000001
%define SYSCALL_OPEN 0x2000005
%define SYSCALL_CLOSE 0x2000006
%endif

%assign O_RDONLY 000000q ; file is read-only
%assign O_WRONLY 000001q ; file is write-only
%assign O_RDWR 000002q ; read or write
%assign O_CREAT 000100q ; create file or erase it

%assign S_IRUSR 00400q ; user permission to read
%assign S_IWUSR 00200q ; to write
%assign S_IXUSR 00100q ; to execute


  global start
  global _start

section .text

start:
_start:
