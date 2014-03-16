%include "os_dependent_stuff.asm"
%include "std.asm"

section .bss
  MAXBUF equ 100000
  buffer resb MAXBUF ; 100,000 bytes of storage
  MAXNUM equ 100000
  num_buf resb MAXNUM ; 100,000 bytes of storage

section .data
file_name:
  db "data/hello_world.txt", 0

section .text

  call open_file
  call convert_file

  mov rax, num_buf
  add rax, 0
  mov rdi, [rax]
  mov rax, SYSCALL_EXIT
  syscall

; converts contents of buffer into integers in the num_buf buffer
; length of buffer is specified by r8
convert_file:
  mov rcx, num_buf ; current position in num_buf buffer
  mov rax, buffer ; current position in text buffer

convert_file_loop:
  call str_to_dec
  mov [rcx], rbx
  inc rax
  inc rcx
  mov rdx, rcx
  sub rdx, num_buf
  cmp rdx, r8
  jl convert_file_loop ; if (rcx-num_buf) < r8
  ret

; accept null terminated string pointed to by rax
; parses integer and puts into rbx
; advances rax to the first non-integer character read
; stops reading number after any non-integer character
; is read
str_to_dec:
  push rcx
  mov rbx, 0 ; eventual output register
  mov rcx, 0 ; for holding the current character being tested

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
