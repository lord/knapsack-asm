%include "os_dependent_stuff.asm"
%include "std.asm"

section .bss
  MAXBUF equ 100000
  buffer resb MAXBUF ; 100,000 bytes of storage

section .text

  call open_file
  print buffer, r8
  jmp program_end

input_data:
  db "53 a3", 0

file_name:
  db "data/hello_world.txt", 0

; accept null terminated string pointed to by rax
; parses integer and puts into rbx
; stops reading number after any non-integer character
; is read
str_to_dec:
  push rcx ; save contents of rcx
  mov rbx, 0 ; eventual output register
  mov rcx, 0 ; for tracking the current position in the string

str_to_dec_loop:
  mov cl, [rax]
  cmp rcx, 48
  jl str_to_dec_return  ; if rcx < 60
  cmp rcx, 57
  jg str_to_dec_return  ; if rcx > 71

  imul rbx, 10 ; rbx *= 10
  sub rcx, 48
  add rbx, rcx
  inc rax
  jmp str_to_dec_loop

str_to_dec_return:
  pop rcx
  ret

; reads the file file_name into the buffer buffer
; and the bytes read into r8
; exits the program if failed
open_file:
  push rax
  push rdi
  push rsi
  push rdx
  push r9
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
  ; file open success! now we will load the file into the buffer
  mov rdi, rax ; move file descriptor to rdi
  mov r9, rax ; also save file descriptor in r9
  mov rax, SYSCALL_READ
  mov rsi, buffer ; set buffer address for file contents
  mov rdx, MAXBUF
  syscall
  mov r8, rax ; save bytes read

  ; close the file and return
  mov rax, SYSCALL_CLOSE
  mov rdi, r9 ; set file descriptor
  syscall

  pop r9
  pop rdx
  pop rsi
  pop rdi
  pop rax
  ret

program_end:
  mov rdi, rax
  mov rax, SYSCALL_EXIT
  ; mov rdi, 0
  syscall
