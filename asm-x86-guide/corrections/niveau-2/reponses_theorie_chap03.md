# Corrigé des Exercices Théoriques — Chapitre 3

## Exercice 1 — Traduction Intel vers AT&T
1. `mov rax, 100` $\rightarrow$ `movq $100, %rax`
2. `mov dword [rdi + 8], ebx` $\rightarrow$ `movl %ebx, 8(%rdi)`
3. `add rsi, [rcx]` $\rightarrow$ `addq (%rcx), %rsi`
4. `xor edx, edx` $\rightarrow$ `xorl %edx, %edx`

---

## Exercice 2 — Prédire l'état du registre RAX
Séquence d'exécution :
1. `mov rax, 0x1122334455667788` $\rightarrow$ `rax = 0x1122334455667788`
2. `mov al, 0xAA` (modifie seulement les 8 bits de poids faible) $\rightarrow$ `rax = 0x11223344556677AA`
3. `mov ax, 0xBBCC` (modifie seulement les 16 bits de poids faible) $\rightarrow$ `rax = 0x112233445566BBCC`
4. `mov eax, 0x12345678` :
   **Règle x86_64** : Une écriture dans un registre 32 bits remet **automatiquement à zéro** la moitié supérieure 64 bits !
   $\rightarrow$ `rax = 0x0000000012345678` !

---

## Exercice 4 — `movzx` vs `movsx` avec `0xFE`
Valeur de départ : `0xFE` (binaire : `1111 1110`, bit 7 = 1) :
1. `movzx rax, al` (Zero-extension) :
   `rax = 0x00000000000000FE` (décimal : 254)
2. `movsx rax, al` (Sign-extension, le bit de signe 1 est répliqué sur les 56 bits restants) :
   `rax = 0xFFFFFFFFFFFFFFFE` (décimal : -2)

---

## Exercice 6 — LEA vs MOV
- `mov rax, [rbx + 8]` :
  Accède physiquement à la mémoire RAM à l'adresse `0x1008` et lit la donnée stockée.
  $\rightarrow$ `rax = 42`.
- `lea rax, [rbx + 8]` (*Load Effective Address*) :
  N'accède **JAMAIS** à la mémoire ! Il utilise l'unité de calcul d'adresse du processeur pour faire une simple addition mathématique : `rbx + 8 = 0x1000 + 8`.
  $\rightarrow$ `rax = 0x1008`.

---

## Exercice 8 — Trouver les 4 bugs de `ex04_bad_mov.asm`
1. `mov [var1], [var2]` : Illégal. Un transfert direct mémoire-vers-mémoire est interdit par l'architecture x86. Il faut charger dans un registre intermédiaire.
2. `mov rax, ecx` : Incompatibilité de taille (64 bits vs 32 bits). Utiliser `mov eax, ecx` ou `movzx rax, ecx`.
3. `mov [rsp], 42` : Ambigüité de taille. NASM ne peut pas deviner si 42 est un byte, word, dword ou qword. Correction : `mov dword [rsp], 42`.
4. `mov rip, _start` : Le registre RIP (Instruction Pointer) ne peut pas être modifié avec `mov`. Pour modifier RIP, utiliser `jmp _start`.
