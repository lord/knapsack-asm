;;; --- MACRO ---
;;; print msg,length
%macro print 2 ; %1 = address %2 = # of chars
  ; save registers
  push rax
  push rdi
  push rsi

  ; write to stdout
  mov rax, SYSCALL_WRITE
  mov rdi, 1
  mov rsi, %1
  mov rdx, %2
  syscall

  ; restore registers
  pop rsi
  pop rdi
  pop rax
%endmacro

;;; --- MACRO ---
;;; print2 "quoted string"
%macro print2 1 ; %1 = immediate string,
 section .data
   %%str db %1
   %%strL equ $-%%str
 section .text
   print %%str, %%strL
%endmacro
