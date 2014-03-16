%include "os_dependent_stuff.asm"
%include "std.asm"

section .bss
  MAXBUF equ 100000
  buffer resb MAXBUF ; 100,000 bytes of storage

section .text

  mov rax, input_data
  call str_to_dec

  mov rdi, rbx
  mov rax, SYSCALL_EXIT
  syscall

  jmp open_file

  print2 `testing!\n`
  mov rax, SYSCALL_EXIT
  mov rdi, rbx
  syscall

input_data:
  ; db `4 11\n8 4\n10 5\n15 8\n4 3`, 0
  db "53 a3", 0

file_name:
  db "data/hello_world.txt", 0

; accept null terminated string pointed to by rax
; parses integer and puts into rbx
; stops reading number after any non-integer character
; is read
str_to_dec:
  mov rbx, 0
  mov rcx, 0

str_to_dec_loop:
  mov cl, [rax]
  cmp rcx, 48
  jl return  ; if rcx < 60
  cmp rcx, 57
  jg return  ; if rcx > 71

  imul rbx, 10 ; rbx *= 10
  sub rcx, 48
  add rbx, rcx

str_to_dec_loop_end:
  inc rax
  jmp str_to_dec_loop

open_file:
  mov rax, SYSCALL_OPEN
  mov rdi, file_name
  mov rsi, O_RDONLY
  mov rdx, S_IRUSR|S_IWUSR|S_IXUSR
  syscall

  test rax, rax
  jns open_file_success ; if rcx > 0
  print2 `File open failed!\n`
  jmp program_end

open_file_success:
  print2 `File open success!\n`
  jmp read_file

read_file:
  mov rdi, rax ; move file descriptor to rdi
  mov r9, rax ; also save file descriptor in r9
  mov rax, SYSCALL_READ
  mov rsi, buffer ; set buffer address for file contents
  mov rdx, MAXBUF
  syscall
  mov r8, rax ; save bytes read

  print buffer, r8
  jmp close_file

close_file:
  mov rax, SYSCALL_CLOSE
  mov rdi, r9 ; set file descriptor
  syscall
  jmp program_end

return:
  ret

program_end:
  mov rdi, rax
  mov rax, SYSCALL_EXIT
  ; mov rdi, 0
  syscall
