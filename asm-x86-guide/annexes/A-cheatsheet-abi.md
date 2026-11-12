# Aide-Mémoire — Convention d'Appel System V AMD64 ABI

## 1. Passage des Arguments
- **Arguments Entiers et Pointeurs** :
  1. `RDI`
  2. `RSI`
  3. `RDX`
  4. `RCX`
  5. `R8`
  6. `R9`
  - Arguments 7 et plus : Empilés sur la **pile** de droite à gauche avant le `call`.
- **Arguments Flottants (Float / Double)** :
  `XMM0` à `XMM7`.
- **Fonctions Variadiques (`printf`, etc.)** :
  Le registre **`AL`** doit contenir le nombre de registres vectoriels XMM utilisés.

---

## 2. Valeur de Retour
- Entiers jusqu'à 64 bits / Pointeurs : **`RAX`**.
- Entiers 128 bits : Couple **`RDX:RAX`** (`rdx` = partie haute, `rax` = partie basse).
- Flottants : **`XMM0`**.

---

## 3. Classification des Registres

```
┌────────────────────────────────────────────────────────┐
│                   CALLEE-SAVED                         │
│  (La fonction appelée DOIT les préserver avec push/pop) │
│                                                        │
│       RBX, RSP, RBP, R12, R13, R14, R15                │
├────────────────────────────────────────────────────────┤
│                   CALLER-SAVED                         │
│       (Volatils : peuvent être écrasés librement)       │
│                                                        │
│       RAX, RCX, RDX, RSI, RDI, R8, R9, R10, R11,       │
│       RFLAGS, XMM0 à XMM15                             │
└────────────────────────────────────────────────────────┘
```

---

## 4. Règle d'Alignement de Pile sur 16 Octets
- **Avant tout `call`** : Le pointeur de pile `RSP` doit être un multiple exact de 16 ($RSP \pmod{16} == 0$).
- **À l'entrée exacte de la fonction appelée** : $RSP \pmod{16} == 8$ (car l'adresse de retour de 8 octets vient d'être empilée).
- Pour réaligner avant un nouvel appel de fonction :
  ```asm
  push rbp
  mov rbp, rsp
  sub rsp, 16    ; Multiple de 16
  call fonction
  leave
  ret
  ```

---

## 5. La Red Zone
- Zone de **128 octets** sous `RSP` (`[rsp - 1]` à `[rsp - 128]`).
- Réservée et garantie non-écrasée par les interruptions/signaux.
- Utilisable sans overhead de pile par les fonctions feuilles (*Leaf Functions*).
