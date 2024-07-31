global _start
section .data
    two_pi dd 6.28
    A dd 0.0
    B dd 0.0

    percent dd 0.01
    a_update_speed dd 0.02
    b_update_speed dd 0.01
    seven_percent dd 0.07
    two_float dd 2.0
    five_float dd 5.0
    one_float dd 1.0
    fifteen_float dd 15.0
    thirty_float dd 30.0
    eight_float dd 8.0
    newline db 10


    luminance db ".,-~:;=!*#$@"
    len equ $ - luminance
section .bss
    k resd 1
    i resd 1
    j resd 1
    val resd 1
    mess resd 1
    z resd 1760
    b resb 1760
    result resd 1

section .text


memset:
    ; Arguments:
    ; RDI: pointer to the memory area
    ; RSI: value to set (only the lower 8 bits are used)
    ; RDX: number of bytes to set

    test rdx, rdx           
    jz .done                

    mov ax, si      

.loop:
    mov byte [rdi], al      
    inc rdi                 
    dec rdx                 
    jnz .loop               

.done:
    ret  


_start:

_endless:
    mov rdi,b
    mov rsi, 32
    mov rdx, 1760
    call memset

    mov rdi,z
    mov rsi,0
    mov rdx, 7040
    call memset

    mov dword [j], 0
_outer_loop:
    mov dword [i], 0
_inner_loop:

    fld dword [i]
    fsin
    fstp dword [result]
    movss xmm1, [result] ;sini = xmm1

    fld dword [j]
    fcos
    fstp dword [result]
    movss xmm2,[result] ; cosj = xmm2

    fld dword [A]
    fsin
    fstp dword [result]
    movss xmm3, [result] ; sinA = xmm3

    fld dword [j]
    fsin
    fstp dword [result]
    movss xmm4,[result] ; sinj = xmm4

    fld dword [A]
    fcos
    fstp dword [result]
    movss xmm5,[result] ; cosA = xmm5

    movss xmm6, xmm2 
    addss xmm6, [two_float] ;cosj2 = cosj + 2 = xmm2 + 2 = xmm6 

    ;mess (xmm7 is a temp var)
    movss xmm7, xmm1 ;multiply with sini
    mulss xmm7, xmm6 ; with cosj2
    mulss xmm7, xmm3 ; and sinA

    movss xmm0, xmm4 ;multiply sinj with cosA
    mulss xmm0, xmm5

    addss xmm7,xmm0

    addss xmm7, [five_float] ;add 5

    movss xmm0, [one_float]

    divss xmm0, xmm7

    movss [mess], xmm0

    fld dword [i]
    fcos
    fstp dword [result]
    movss xmm7, [result] ; cosi = xmm7

    fld dword [B]
    fcos
    fstp dword [result]
    movss xmm8, [result] ; cosB = xmm8

    fld dword [B]
    fsin
    fstp dword [result]
    movss xmm9, [result]; sinB = xmm9

    movss xmm10, xmm1 ;multiply by sini and cosj2 and cosA
    mulss xmm10, xmm6
    mulss xmm10, xmm5 

    movss xmm0, xmm4 ; sinj * sinA
    mulss xmm0, xmm3

    subss xmm10, xmm0 ; t = xmm10

    ;cosi*cosj2*cosB-t*sinB
    movss xmm11, xmm7
    mulss xmm11, xmm6
    mulss xmm11, xmm8

    movss xmm0, xmm10
    mulss xmm0, xmm9

    subss xmm11, xmm0

    mulss xmm11, [mess]
    mulss xmm11, [thirty_float]

    cvttss2si eax, xmm11
    add eax, 40
    ; -> eax=40+30*mess*(cosi*cosj2*cosB-t*sinB)

    movss xmm11, xmm7 
    mulss xmm11, xmm6
    mulss xmm11, xmm9

    movss xmm0, xmm10
    mulss xmm0, xmm8

    addss xmm11,xmm0

    mulss xmm11, [mess]

    mulss xmm11, [fifteen_float]


    cvttss2si ebx, xmm11
    add ebx, 12
    ; -> ebx = 12+15*mess*(cosi*cosj2*sinB +t*cosB)

    mov edx, ebx
    imul edx, 80
    add edx, eax

    ; -> edx = eax + 80 * ebx
    movss xmm0, xmm4 ;sinj
    mulss xmm0, xmm3 ;sinA

    movss xmm11,xmm1 ;sini
    mulss xmm11,xmm2 ;cosj
    mulss xmm11,xmm5 ;cosA

    subss xmm0, xmm11

    mulss xmm0, xmm8 ;cosB

    movss xmm11, xmm1 ;sini
    mulss xmm11, xmm2 ;cosj
    mulss xmm11, xmm3 ;sinA

    subss xmm0,xmm11


    movss xmm11, xmm4 ;sinj
    mulss xmm11, xmm5 ;cosA

    subss xmm0,xmm11

    movss xmm11, xmm7 ;cosi
    mulss xmm11, xmm2 ;cosj
    mulss xmm11, xmm9 ;sinB

    subss xmm0,xmm11

    mulss xmm0, [eight_float]
    cvttss2si edi, xmm0
    ; -> edi = 8*((sinj*sinA-sini*cosj*cosA)*cosB-sini*cosj*sinA-sinj*cosA-cosi*cosj*sinB)
    
    cmp ebx, 22
    jge _end_inner_loop

    cmp ebx, 0
    jle _end_inner_loop

    cmp eax, 0
    jle _end_inner_loop

    cmp eax, 80
    jge _end_inner_loop

    movss xmm0, [mess]
    movss xmm11, [edx + z]
    ucomiss xmm0,xmm11
    jbe _end_inner_loop

    movss xmm0, [mess]
    movss dword [edx + z], xmm0 


    cmp edi,0
    jg _get_luminance

    mov edi, 0 

_get_luminance:
    mov al, byte [luminance + edi]
    mov byte [b + edx], al

_end_inner_loop:


    movss xmm0, [i]
    addss xmm0, [percent]
    addss xmm0, [percent]

    movss dword [i], xmm0
    ; -> i += 0.02



    movss xmm0, dword [i]
    movss xmm1, dword [two_pi]
    ucomiss xmm0,xmm1 
    ja _end_outer_loop

    


    jmp _inner_loop

_end_outer_loop:
    

    movss xmm0, [j]
    addss xmm0, [seven_percent]

    movss dword [j], xmm0
    ; -> j += 0.07

    movss xmm12, dword [j]
    movss xmm13, dword [two_pi]
    ucomiss xmm12,xmm13 
    ja _finish

    

    jmp _outer_loop

_finish:

    mov dword [k], 0

_render_loop:

    mov eax, [k]

    xor rdx, rdx
    mov rcx, 80

    div rcx
    test rdx,rdx 
    jz _newline
    ; k % 80 != 0
    mov eax, [k]
    lea rsi, byte [b + rax]
    
    mov rax, 1
    mov rdi, 1
    
    

    mov rdx, 1
    syscall
    
    jmp _render_loop_end

_newline:
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

_render_loop_end:
    cmp dword [k], 1761
    jge _render_loop_done
    inc dword [k]

    jmp _render_loop

_render_loop_done:
    movss xmm0, [A]
    addss xmm0, [a_update_speed]
    movss dword [A], xmm0
    ; A += 0.01

    movss xmm0, [B]
    addss xmm0,[b_update_speed]
    movss dword [B], xmm0
    ; B += 0.005

    jmp _endless


    mov rax, 60
    mov rdi, 0
    syscall