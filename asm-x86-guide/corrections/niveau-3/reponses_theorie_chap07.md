# Corrigé des Exercices Théoriques — Chapitre 7

## Exercice 1 — Caller-saved vs Callee-saved
- `rax` : **Caller-saved** (Volatil - valeur de retour)
- `rbx` : **Callee-saved** (Doit être préservé par la fonction)
- `rcx` : **Caller-saved** (4ème argument)
- `rdx` : **Caller-saved** (3ème argument)
- `rsi` : **Caller-saved** (2ème argument)
- `rdi` : **Caller-saved** (1er argument)
- `rbp` : **Callee-saved** (Base Pointer)
- `rsp` : **Callee-saved** (Stack Pointer - doit retrouver son niveau)
- `r12` : **Callee-saved**
- `r15` : **Callee-saved**

---

## Exercice 4 — Le Crash d'alignement de pile
Code problématique :
```asm
extern puts
global main
main:
    sub     rsp, 8
    mov     rdi, msg
    call    puts
    add     rsp, 8
    ret
```
### Explication :
1. À l'entrée dans `main`, la fonction appelante (`__libc_start_main`) a exécuté un `call`. L'adresse de retour (8 octets) a été empilée.
   Donc à l'entrée dans `main` : $RSP \pmod{16} == 8$.
2. Le développeur fait `sub rsp, 8`.
   $RSP$ devient un multiple de 16 ($RSP \pmod{16} == 0$).
3. Mais l'instruction `call puts` pousse à son tour l'adresse de retour (8 octets) !
   À l'entrée dans `puts`, $RSP \pmod{16} == 8$ au lieu de 0.
   La fonction `puts` tente d'utiliser une instruction SIMD (`movaps` qui exige un alignement 16) sur la pile $\rightarrow$ **Crash SIGSEGV immédiat** !

### Correction :
Il faut soustraire `0` ou `8` supplémentaire pour que, **juste avant le call**, $RSP \pmod{16} == 0$ :
```asm
main:
    ; À l'entrée : RSP % 16 == 8
    ; On n'alloue rien, ou bien on alloue un multiple impair de 8 :
    ; sub rsp, 8  (RSP % 16 == 0 avant le call puts !)
    ; Si on utilise un prologue classique :
    push    rbp         ; RSP % 16 == 0
    mov     rbp, rsp
    ; Aucun sub nécessaire si pas de variables locales
    mov     rdi, msg
    call    puts        ; Avant le call, RSP % 16 == 0 -> PARFAIT !
    pop     rbp
    ret
```

---

## Exercice 16 — Structure et Padding
Structure C :
```c
struct Person {
    char  initiale;  // 1 octet
    long  id;        // 8 octets
    short age;       // 2 octets
};
```
1. **Alignement naturel des champs** :
   - `initiale` : placé à l'offset `0`. Taille = 1 octet.
   - `id` (8 octets) : doit impérativement être aligné sur un multiple de 8 !
     Il y a donc **7 octets de remplissage (*padding*)** entre l'offset 1 et l'offset 7.
     `id` commence à l'offset **`8`** et se termine à `15`.
   - `age` (2 octets) : doit être aligné sur un multiple de 2. L'offset 16 est pair $\rightarrow$ `age` est à l'offset **`16`** (taille 2, jusqu'à 17).
2. **Padding final de la structure** :
   La taille totale de la structure doit être un multiple de l'alignement maximal de ses membres (ici 8 octets pour `long`).
   $18$ n'est pas multiple de 8. On ajoute 6 octets de padding de fin.
   $\rightarrow$ **Taille totale = 24 octets** !
