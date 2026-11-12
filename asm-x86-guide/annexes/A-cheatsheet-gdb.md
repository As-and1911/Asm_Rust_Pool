# Aide-Mémoire — Commandes GDB & LLDB pour l'Assembleur

## 1. Démarrer et Configurer
```bash
# Dans GDB
(gdb) set disassembly-flavor intel      # Forcer la syntaxe Intel
(gdb) set pagination off                # Ne pas couper les longs affichages

# Dans LLDB
(lldb) settings set target.x86-disassembly-flavor intel
```

---

## 2. Table de Correspondance Directe

| Action | Commande GDB | Commande LLDB |
|---|---|---|
| Mettre un breakpoint sur un label | `b _start` | `b _start` |
| Mettre un breakpoint sur une adresse | `b *0x401000` | `b -a 0x401000` |
| Démarrer l'exécution | `run` (ou `r`) | `run` (ou `r`) |
| **Pas-à-pas instruction (Step Into)** | **`si`** (ou `stepi`) | **`si`** (ou `thread step-inst`) |
| **Pas-à-pas instruction (Step Over)** | **`ni`** (ou `nexti`) | **`ni`** (ou `thread step-inst-over`) |
| Continuer jusqu'au prochain arrêt | `c` (ou `continue`) | `c` (ou `continue`) |
| Afficher tous les registres | `info registers` (ou `i r`) | `register read` |
| Afficher un registre en hexa | `p/x $rax` | `register read rax` |
| Afficher un registre en binaire | `p/t $rax` | `p/t $rax` |
| Examiner 16 quadwords sur la pile | `x/16gx $rsp` | `x/16gx $rsp` |
| Afficher la chaîne pointée par RDI | `x/s $rdi` | `x/s $rdi` |
| Désassembler 10 instructions | `x/10i $rip` | `disassemble --pc --count 10` |
| Mode interface visuelle (TUI) | `layout asm` / `layout regs` | `gui` |
| Quitter le mode TUI | `Ctrl+X A` | `Esc` |
| Quitter le débogueur | `q` (ou `quit`) | `q` (ou `quit`) |
