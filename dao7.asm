SECTION .bss
buffer      resb 101
nextbuf     resb 101
numBuf      resb 3

SECTION .data
sizeMsg db "Input size is: "
sizeMsgLen equ $ - sizeMsg

invalidMsg db "Invalid character: "
invalidMsgLen equ $ - invalidMsg

largeMsg db "Input should be smaller than 99 characters.",10
largeMsgLen equ $ - largeMsg

newline db 10

SECTION .text
global _start

_start:

mov rax, 0
mov rdi, 0
mov rsi, buffer
mov rdx, 101
syscall

mov r12, rax

cmp r12, 100
jne size_ok

mov rax, 1
mov rdi, 2
mov rsi, largeMsg
mov rdx, largeMsgLen
syscall

mov rax, 60
mov rdi, 1
syscall

size_ok:

dec r12

mov rax, 1
mov rdi, 1
mov rsi, sizeMsg
mov rdx, sizeMsgLen
syscall

mov rax, r12
mov rbx, 10
xor rdx, rdx
div rbx

cmp rax, 0
je one_digit

add al, '0'
mov [numBuf], al

add dl, '0'
mov [numBuf+1], dl

mov rax, 1
mov rdi, 1
mov rsi, numBuf
mov rdx, 2
syscall

jmp after_number

one_digit:

add dl, '0'
mov [numBuf], dl

mov rax, 1
mov rdi, 1
mov rsi, numBuf
mov rdx, 1
syscall

after_number:

mov rax, 1
mov rdi, 1
mov rsi, newline
mov rdx, 1
syscall

mov rcx, 0

validate_loop:

cmp rcx, r12
je validation_done

mov al, [buffer + rcx]

cmp al, 'x'
je valid_char

cmp al, 'o'
je valid_char

cmp al, '-'
je valid_char

mov rax, 1
mov rdi, 2
mov rsi, invalidMsg
mov rdx, invalidMsgLen
syscall

mov [numBuf], al

mov rax, 1
mov rdi, 2
mov rsi, numBuf
mov rdx, 1
syscall

mov rax, 1
mov rdi, 2
mov rsi, newline
mov rdx, 1
syscall

mov rax, 60
mov rdi, 1
syscall

valid_char:

inc rcx
jmp validate_loop

validation_done:

call print_map

mov r13, 0

step_loop:

cmp r13, r12
je exit_program

mov rcx, 0

clear_loop:

cmp rcx, r12
je clear_done

mov byte [nextbuf + rcx], '-'

inc rcx
jmp clear_loop

clear_done:

mov rcx, 0

simulate_loop:

cmp rcx, r12
je simulation_done

mov al, [buffer + rcx]

cmp al, 'x'
je process_rock

cmp al, 'o'
je process_hole

inc rcx
jmp simulate_loop

process_hole:

cmp rcx, 0
je hole_stays

mov r8, rcx
dec r8

mov bl, [buffer + r8]

cmp bl, 'x'
je hole_filled

hole_stays:

mov byte [nextbuf + rcx], 'o'

inc rcx
jmp simulate_loop

hole_filled:

inc rcx
jmp simulate_loop

process_rock:

mov r8, rcx
inc r8

cmp r8, r12
je rock_stays

mov bl, [buffer + r8]

cmp bl, '-'
je rock_moves

cmp bl, 'o'
je rock_fills_hole

jmp rock_stays

rock_moves:

mov byte [nextbuf + r8], 'x'

inc rcx
jmp simulate_loop

rock_fills_hole:

inc rcx
jmp simulate_loop

rock_stays:

mov byte [nextbuf + rcx], 'x'

inc rcx
jmp simulate_loop

simulation_done:

mov rcx, 0

copy_loop:

cmp rcx, r12
je copy_done

mov al, [nextbuf + rcx]
mov [buffer + rcx], al

inc rcx
jmp copy_loop

copy_done:

call print_map

inc r13
jmp step_loop

print_map:

mov byte [buffer + r12], 10

mov rax, 1
mov rdi, 1
mov rsi, buffer
mov rdx, r12
inc rdx
syscall

ret

exit_program:

mov rax, 60
mov rdi, 0
syscall
