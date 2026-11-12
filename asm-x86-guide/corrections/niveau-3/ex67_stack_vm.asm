; =============================================================================
; CORRECTION — Exercice 67 : Mini Machine Virtuelle à Pile
; =============================================================================

section .data
    prog db 0x01, 5, 0x01, 8, 0x02, 0x01, 2, 0x03, 0xFF

section .text
    global _start

vm_exec:
    ; rdi = pointeur vers le flux de bytecode
    ; On utilise la vraie pile x86 comme pile d'exécution de notre VM
.fetch:
    movzx   eax, byte [rdi]     ; Lit l'opcode
    inc     rdi

    cmp     al, 0x01            ; Opcode PUSH VAL
    je      .op_push
    cmp     al, 0x02            ; Opcode ADD
    je      .op_add
    cmp     al, 0x03            ; Opcode MUL
    je      .op_mul
    cmp     al, 0xFF            ; Opcode HALT
    je      .op_halt
    jmp     .fetch

.op_push:
    movzx   rax, byte [rdi]
    inc     rdi
    push    rax
    jmp     .fetch

.op_add:
    pop     rdx
    pop     rax
    add     rax, rdx
    push    rax
    jmp     .fetch

.op_mul:
    pop     rdx
    pop     rax
    imul    rax, rdx
    push    rax
    jmp     .fetch

.op_halt:
    pop     rax                 ; Valeur finale retournée
    ret

_start:
    mov     rdi, prog
    call    vm_exec

    mov     rdi, rax            ; exit(26)
    mov     rax, 60
    syscall
