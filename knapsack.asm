%include "os_dependent_stuff.asm"


;;; --- MACRO -----------------------------------------------
;;; print msg,length
%macro print 2 ; %1 = address %2 = # of chars
 ; pushad ; save all registers
 mov rax, SYSCALL_WRITE
 mov rdi, 1
 mov rsi, %1
 mov rdx, %2
 mov rbx, 1
 syscall
 ; popad ; restore all registers
%endmacro

;;; --- MACRO -----------------------------------------------
;;; print2 "quoted string"
%macro print2 1 ; %1 = immediate string,
 section .data
%%str db %1
%%strL equ $-%%str
 section .text
 print %%str, %%strL
%endmacro

  ; mov rax, input_data
  ; jmp str_to_dec
  ; call str_to_dec

  print2 `testing\n`

  mov rax, SYSCALL_EXIT
  mov rdi, rbx
  syscall

input_data:
  ; db `4 11\n8 4\n10 5\n15 8\n4 3`, 0
  db "15", 0

file_name:
  ; db `4 11\n8 4\n10 5\n15 8\n4 3`, 0
  db "hello.txt", 0


; accept null terminated string pointed to by rax
; parses integer and puts into rbx
str_to_dec:
  mov rbx, 0
  mov rcx, 0

str_to_dec_loop:
  mov cl, [rax]
  cmp rcx, 0
  je return
  cmp rcx, 48
  jl str_to_dec_loop_end  ; if rcx < 60
  cmp rcx, 57
  jg str_to_dec_loop_end  ; if rcx > 71

  imul rbx, 10 ; rbx *= 10
  sub rcx, 48
  add rbx, rcx

str_to_dec_loop_end:
  inc rax
  jmp str_to_dec_loop

open_file:
  mov rax, SYSCALL_OPEN
  mov rbx, file_name
  mov rcx, O_RDONLY
  mov rdx, S_IRUSR|S_IWUSR|S_IXUSR
  syscall

return:
  ret
