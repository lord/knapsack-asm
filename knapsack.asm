%include "os_dependent_stuff.asm"

  mov rax, input_data
  jmp str_to_dec

program_end:
  mov rax, SYSCALL_EXIT
  mov rdi, rbx
  syscall

input_data:
  ; db `4 11\n8 4\n10 5\n15 8\n4 3`, 0
  db "142", 0


; accept null terminated string pointed to by rax
; parses integer and puts into rbx
str_to_dec:
  mov rbx, 0
  mov rcx, 0

str_to_dec_loop:
  mov cl, [rax]
  cmp rcx, 0
  je str_to_dec_end
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

str_to_dec_end:
  jmp program_end
