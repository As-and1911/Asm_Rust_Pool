# Aide-Mémoire — Registres x86_64

## 1. Les 16 Registres Généraux 64 Bits

| Registre 64b | Sous-reg 32b | Sous-reg 16b | Sous-reg 8b (Low) | 8b (High) | Rôle ABI System V AMD64 | Préservé ? |
|:---:|:---:|:---:|:---:|:---:|---|:---:|
| **`RAX`** | `EAX` | `AX` | `AL` | `AH` | Valeur de retour / N° Syscall | ❌ Caller-saved |
| **`RBX`** | `EBX` | `BX` | `BL` | `BH` | Base / Registre de travail | ✅ **Callee-saved** |
| **`RCX`** | `ECX` | `CX` | `CL` | `CH` | 4ème argument fonction / Compteur boucle | ❌ Caller-saved |
| **`RDX`** | `EDX` | `DX` | `DL` | `DH` | 3ème argument / Dividende 128b / I/O len | ❌ Caller-saved |
| **`RSI`** | `ESI` | `SI` | `SIL`| - | 2ème argument / Source chaînes | ❌ Caller-saved |
| **`RDI`** | `EDI` | `DI` | `DIL`| - | 1er argument / Destination chaînes | ❌ Caller-saved |
| **`RBP`** | `EBP` | `BP` | `BPL`| - | Pointeur de base (Stack Frame) | ✅ **Callee-saved** |
| **`RSP`** | `ESP` | `SP` | `SPL`| - | Pointeur de sommet de pile | ✅ **Callee-saved** |
| **`R8`**  | `R8D` | `R8W`| `R8B`| - | 5ème argument fonction | ❌ Caller-saved |
| **`R9`**  | `R9D` | `R9W`| `R9B`| - | 6ème argument fonction | ❌ Caller-saved |
| **`R10`** | `R10D`| `R10W`| `R10B`| - | **4ème argument SYSCALL** | ❌ Caller-saved |
| **`R11`** | `R11D`| `R11W`| `R11B`| - | Registre scratch (détruit par syscall) | ❌ Caller-saved |
| **`R12`** | `R12D`| `R12W`| `R12B`| - | Registre général préservé | ✅ **Callee-saved** |
| **`R13`** | `R13D`| `R13W`| `R13B`| - | Registre général préservé | ✅ **Callee-saved** |
| **`R14`** | `R14D`| `R14W`| `R14B`| - | Registre général préservé | ✅ **Callee-saved** |
| **`R15`** | `R15D`| `R15W`| `R15B`| - | Registre général préservé | ✅ **Callee-saved** |

---

## 2. Registres Spéciaux

- **`RIP`** : *Instruction Pointer* (adresse de la prochaine instruction exécutée). Non modifiable avec `mov`.
- **`RFLAGS`** : Registre des drapeaux d'état du CPU :
  - **`ZF`** (bit 6) : Zero Flag (résultat nul ou égalité).
  - **`CF`** (bit 0) : Carry Flag (retenue / débordement non-signé).
  - **`SF`** (bit 7) : Sign Flag (résultat négatif).
  - **`OF`** (bit 11) : Overflow Flag (débordement arithmétique signé).
  - **`PF`** (bit 2) : Parity Flag (parité du nombre de bits à 1).
  - **`DF`** (bit 10) : Direction Flag (`0` = avant avec `cld`, `1` = arrière avec `std`).

---

## 3. Registres Vectoriels (SIMD)
- **`XMM0` à `XMM15`** : 16 registres de 128 bits (SSE).
  - `XMM0` à `XMM7` : Passage d'arguments flottants (`float`, `double`).
  - `XMM0` : Valeur de retour flottante.
- **`YMM0` à `YMM15`** : 16 registres de 256 bits (AVX).
