global _start

extern GetStdHandle
extern WriteFile
extern ExitProcess
extern GetProcessHeap
extern HeapAlloc
extern HeapFree

section .data
next_point: dq 0
iterate_point: dq 0
start_point: dq 0

previous_address: dq 0
remove_address: dq 0
next_address: dq 0

size: dq 0
test_char: dq 0

section .text
_start:
    mov rcx, 83
    call append

    mov rcx, 65
    call append

    mov rcx, 66
    call append

    mov rcx, 83
    call append

    mov rcx, 3
    call remove

    mov rcx, 1
    call remove

    mov rcx, 72
    call append

    mov rcx, 0
    call get
    
    mov [rel test_char], rax
    call print_test

    ret

append:
    push rcx
    call GetProcessHeap
    sub rsp, 32
    mov rcx, rax
    mov rdx, 8
    mov r8, 16
    call HeapAlloc
    add rsp, 32
    pop rcx
    
    mov r8, [rel size]
    cmp r8, 0
    je set_start_position

    mov qword [rax], rcx
    add rax, 8
    mov rcx, qword [rel next_point]
    mov qword [rcx], rax
    mov qword [rel next_point], rax

    call increment_size
    ret

set_start_position:
    mov qword [rax], rcx

    add rax, 8
    mov qword [rel iterate_point], rax
    mov qword [rel next_point], rax
    mov qword [rel start_point], rax

    call increment_size
    ret

increment_size:
    mov r8, [rel size]
    add r8, 1
    mov [rel size], r8
    ret

decrement_size:
    mov r8, [rel size]
    sub r8, 1
    mov [rel size], r8
    ret

get_iterate:
    mov r8, qword [rel iterate_point]
    mov rdx, qword [r8 - 8]
    mov rax, rdx

    mov rdx, qword [r8]
    mov qword [rel iterate_point], rdx
    
    loop get_iterate
    call set_iterate_point_start
    ret

get:
    add rcx, 1
    call get_iterate
    ret

set_iterate_point_start:
    mov r8, qword [rel start_point]
    mov qword [rel iterate_point], r8
    ret

find_previous_address:
    mov r8, qword [rel iterate_point]
    mov qword [rel previous_address], r8

    mov rdx, qword [r8]
    mov qword [rel iterate_point], rdx

    sub rdx, 8
    mov qword [rel remove_address], rdx

    loop find_previous_address
    call set_iterate_point_start
    ret

find_next_address:
    mov r8, qword [rel iterate_point]
    mov rdx, qword [r8]

    mov qword [rel iterate_point], rdx
    mov qword [rel next_address], rdx
    
    loop find_next_address
    call set_iterate_point_start
    ret

find_last_address:
    mov r8, qword [rel iterate_point]
    mov rdx, qword [r8]

    mov qword [rel iterate_point], rdx
    sub rdx, 8
    mov qword [rel remove_address], rdx
    
    loop find_next_address
    call set_iterate_point_start
    ret

remove_first:
    mov r8, qword [rel start_point]

    mov rdx, qword [r8]
    mov qword [rel start_point], rdx

    sub r8, 8
    mov qword [rel remove_address], r8

    call GetProcessHeap
    sub rsp, 32
    mov rcx, rax
    mov rdx, 1
    mov r8, qword [rel remove_address]
    call HeapFree
    add rsp, 32

    call set_iterate_point_start
    call decrement_size

    ret

remove_last:
    call find_previous_address

    mov rdx, qword [rel previous_address]
    mov qword [rel next_point], rdx

    call GetProcessHeap
    sub rsp, 32
    mov rcx, rax
    mov rdx, 1
    mov r8, qword [rel remove_address]
    call HeapFree
    add rsp, 32

    call set_iterate_point_start
    call decrement_size

    ret

remove:
    cmp rcx, 0
    je remove_first

    mov r8, qword [rel size]
    sub r8, 1
    cmp rcx, r8
    je remove_last

    push rcx
    call find_previous_address
    pop rcx
    add rcx, 1
    call find_next_address

    mov rcx, qword [rel next_address]
    mov rdx, qword [rel previous_address]
    mov qword [rdx], rcx

    call GetProcessHeap
    sub rsp, 32
    mov rcx, rax
    mov rdx, 1
    mov r8, qword [rel remove_address]
    call HeapFree
    add rsp, 32

    call decrement_size
    ret

print_test:
    push rcx
    push rdx
    push r8

    sub  rsp, 40
    mov  rcx, -11
    call GetStdHandle
    mov  rcx, rax
    mov  rdx, test_char
    mov  r8, 1
    xor  r9, r9
    mov  qword [rsp + 32], 0
    call WriteFile
    add  rsp, 40

    pop r8
    pop rdx
    pop rcx
    ret