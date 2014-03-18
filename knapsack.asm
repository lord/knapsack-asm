%include "os_dependent_stuff.asm"
%include "std.asm"

section .bss
  MAXBUF equ 100000
  buffer resb MAXBUF ; 100,000 bytes of storage
  MAXNUM equ 100000
  num_buf resb MAXNUM ; 100,000 bytes of storage

section .data
file_name:
  db "data/1.txt", 0

section .text

  call open_file
  call convert_file
  jmp knapsack_start

;   mov r10, num_buf
; testblah:
;   mov r11, qword [r10]
; foo:
;   add r10, 8
;   cmp qword [r10], qword 0
;   jne testblah

knapsack_start:
  mov r10, -1 ; cursor depth
  mov r11, 0 ; cursor position/choices
  mov r12, num_buf ; item pointer, points to item just added or ignored by cursor
  mov r13, 0 ; best solution choices
  mov r14, 0 ; best solution value
  mov r15, 11000 ; maximum weight of knapsack TODO READ FROM FILE NOT JUST 11
  mov r8, 0 ; current value of selections
  mov r9, 0 ; current weight of selections
  mov rdx, -1 ; last move, -1 for movement down, 0 for up from non-selection, 1 for up from selection

  jmp knapsack_down_node_no_select

knapsack_node_start:
  cmp rdx, 1
  je knapsack_node_check_up

  ; check if current weight is greater than capacity, if true, go up
  cmp r9, r15
  jg knapsack_node_check_up

  ; going down, check if at bottom
  mov rax, r12
  add rax, 16
  cmp qword [rax], qword 0
  jne knapsack_node_check_down
  ; next value is 0, so this is the bottom
  ; we need to compare this weight and value with max, to see if best
  cmp r8, r14
  jle knapsack_up_node
  ; we found a new best solution!
best_solution_found:
  mov r13, r11
  mov r14, r8
  ; print2 `new best solution!\n`
  jmp knapsack_up_node

knapsack_node_check_down:
  cmp rdx, -1
  je knapsack_down_node_no_select
  cmp rdx, 0
  je knapsack_down_node_select

knapsack_node_check_up:
  ; going up, check if already at top
  cmp r10, -1
  je program_end
  jmp knapsack_up_node

knapsack_down_node_select:
  inc r10 ; increment cursor depth
  push r8 ; push current value to stack
  push r9 ; push current weight to stack
  push qword 1 ; push choice onto the stack
  add r12, 16
  add r8, qword [r12] ; add value of new item
  add r12, 8
  add r9, qword [r12] ; add weight of new item
  sub r12, 8
  mov rdx, -1 ; push last move to rdx

  ; set bit #r10 in r11 to 1
  bts r11, r10
  jmp knapsack_node_start

knapsack_down_node_no_select:
  inc r10 ; increment cursor depth
  push r8 ; push current value to stack
  push r9 ; push current weight to stack
  push qword 0 ; push choice onto the stack
  add r12, 16
  mov rdx, -1 ; push last move to rdx

  ; set bit #r10 in r11 to 0
  btr r11, r10
  jmp knapsack_node_start

knapsack_up_node:
  pop rdx ; pop last selection to rdx
  pop r9 ; pop current weight
  pop r8 ; pop current value
  sub r12, 16 ; move item pointer down by two
  dec r10 ; decrement cursor depth
  jmp knapsack_node_start

; converts contents of buffer into integers in the num_buf buffer
; length of buffer is specified by r8
; number buffer ends with two 0s
convert_file:
  mov rax, buffer ; current position in text buffer
  mov r9, num_buf ; current position in num_buf buffer

convert_file_loop:
  call str_to_dec
  mov qword [r9], rbx
  inc rax
  ; inc rcx
  add r9, 8
  mov rdx, rax
  sub rdx, buffer
  cmp rdx, r8
  jl convert_file_loop ; if (rax-buffer) < r8
  mov qword [r9], qword 0
  ; inc rcx
  add r9, 8
  mov qword [r9], qword 0
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
  jl str_to_dec_return ; if rcx < 60
  cmp rcx, 57
  jg str_to_dec_return ; if rcx > 71

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
  mov rdi, 0
  mov rax, SYSCALL_EXIT
  ; mov rdi, 0
  syscall
