;Calculadora simples em assembly de x86_64 sintax Intel
;recebe a entrada float op float
;calcula e imprime o resultado no arquivo "out.txt"
;linha de montagem e linker: nasm -f elf64 calculadora.asm; gcc -m64 -no-pie calculadora.o -o calculadora.x
;linha de execução: ./calculadora.x

section .data
    align 16, db 0
    strPrint: db "equação: ", 0
    align 16, db 0
    strCtrlScan: db "%f %c %f", 0
    align 16, db 0
    strPrintNotOk : db "%lf %c %lf = funcionalidade não disponível", 10, 0
    align 16, db 0
    strPrintOk: db "%lf %c %lf = %lf", 10, 0
    strFileName: db "out.txt", 0
    strFileMode: db "a+", 0
    zero: dd 0

section .bss
    alignb 16
    op_a      : resd 1
    op_b      : resd 1
    alignb 16
    op        : resb 1
    alignb 16
    resultado : resd 1
    file : resd 1

extern scanf
extern fprintf
extern printf
extern fopen
extern fclose

section .text
    global main

main: 
    push rbp
    mov rbp, rsp

abreFile:
    lea rdi, [strFileName]
    lea rsi, [strFileMode]
    call fopen

    mov [file], eax

print:
    xor rax, rax
    mov rdi, strPrint
    call printf

scan:
    xor rax,rax    
    mov rdi, strCtrlScan 
    lea rsi, [op_a]  
    lea rdx, [op] 
    lea rcx, [op_b]
    call scanf

switch:
    movss xmm0, [op_a]
    movss xmm1, [op_b]
    mov r12b, byte [op]

    case_a:
        cmp r12b, 'a'
        jne case_s
        call adicao
        mov r12b, '+'
        jmp ok
    case_s:
        cmp r12b, 's'
        jne case_m
        call subtracao
        mov r12b, '-'
        jmp ok
    case_m:
        cmp r12b, 'm'
        jne case_d
        call multiplicacao
        mov r12b, '*'
        jmp ok
    case_d:
        cmp r12b, 'd'
        jne case_e
        comiss xmm1, [zero]
        je notOk
        call divisao
        mov r12b, '/'
        jmp ok
    case_e:
        cmp r12b, 'e'
        jne notOk
        comiss xmm1, [zero]
        jb notOk
        call exponenciacao
        mov r12b, '^'
        jmp ok
    notOk:
        cvtss2sd xmm0, [op_a] 
        mov dil, r12b
        cvtss2sd xmm1, [op_b]
        mov esi, [file]
        call escrevesolucaoNOTOK
        jmp fechaFile

ok:
    movss [resultado], xmm0

    cvtss2sd xmm0, [op_a] 
    mov dil, r12b
    cvtss2sd xmm1, [op_b]
    cvtss2sd xmm2, [resultado]
    mov esi, [file]
    call escrevesolucaoOK

fechaFile:
    mov rdi, [file]
    call fclose

mov rsp, rbp
pop rbp

fim:
    mov rax, 60
    mov rdi, 0
    syscall


adicao:
    push rbp
    mov rbp, rsp
    
    ADDSS xmm0, xmm1

    mov rsp, rbp
    pop rbp
    
    ret

subtracao:
    push rbp
    mov rbp, rsp
    
    SUBSS xmm0, xmm1

    mov rsp, rbp
    pop rbp
    
    ret

multiplicacao:
    push rbp
    mov rbp, rsp
    
    MULSS xmm0, xmm1

    mov rsp, rbp
    pop rbp
    
    ret

divisao:
    push rbp
    mov rbp, rsp
    
    DIVSS xmm0, xmm1

    mov rsp, rbp
    pop rbp
    
    ret

exponenciacao:
    push rbp
    mov rbp, rsp


    cvttss2si r8, xmm1; conversao do op2 para inteiro, por truncamento
    movss xmm2, xmm0
    cmp r8, 1
    je fimExp
    cmp r8, 0
    jg laco
    mov r9, 1;caso se zero retorna 1 independe do valor do op 1
    cvtsi2ss xmm0, r9
    jmp fimExp
    laco:
        mulss xmm0, xmm2
        dec r8
        cmp r8, 1
        jg laco

    fimExp:
    mov rsp, rbp
    pop rbp
    
    ret

escrevesolucaoOK:
    push rbp
    mov rbp, rsp
    
    mov dl, dil
    mov edi, esi

    xor rax, rax
    mov rax, 3
    mov rsi, strPrintOk
    call fprintf

    mov rsp, rbp
    pop rbp
    
    ret

escrevesolucaoNOTOK:
    push rbp
    mov rbp, rsp
    
    mov dl, dil
    mov edi, esi

    xor rax, rax
    mov rax, 2
    mov rsi, strPrintNotOk
    call fprintf

    mov rsp, rbp
    
    pop rbp
    ret