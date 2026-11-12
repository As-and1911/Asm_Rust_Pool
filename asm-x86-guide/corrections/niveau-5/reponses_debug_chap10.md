# Corrigé des Exercices de Diagnostic et Débogage — Chapitre 10

## Exercice 1 — L'Erreur de Division Mystère
- **Cause** : L'instruction `div rbx` divise le dividende 128 bits **`RDX:RAX`**.
  Au démarrage du programme, le registre `rdx` contient des résidus non nuls (sur Linux, `rdx` contient parfois un pointeur de fonction de terminaison enregistré par l'OS).
  Le dividende vaut donc une valeur astronomique supérieure à $2^{64}$. Le quotient ne tient pas dans les 64 bits de `RAX`, ce qui déclenche une exception matérielle `#DE` (Divide Error / SIGFPE) pour dépassement de capacité.
- **Correction** : Toujours insérer **`xor rdx, rdx`** immédiatement avant `div`.

---

## Exercice 2 — Le Segfault du `ret`
- **Cause** : `my_routine` a fait deux `push` (empilant 10 puis 20), mais n'a fait qu'un seul `pop rax` (dépilant 20).
  Au moment d'exécuter `ret`, le sommet de la pile `[rsp]` contient la valeur `10` au lieu de l'adresse de retour !
  Le processeur charge `RIP = 10` (`0x000000000000000A`) et tente d'exécuter l'adresse mémoire 10 qui est dans la zone nulle interdite $\rightarrow$ **Segmentation Fault immédiat**.
- **Correction** : Rééquilibrer la pile avec un deuxième `pop` ou `add rsp, 8` avant `ret`.

---

## Exercice 3 — L'Écriture Interdite
- **Cause** : `counter` a été déclaré dans la section **`.rodata`** (*Read-Only Data*).
  Les pages mémoire virtuelles de `.rodata` sont mappées par le noyau avec les droits **Lecture Seule (`R--`)**.
  Tenter d'y écrire via `inc byte [counter]` déclenche une violation de protection de page matérielle $\rightarrow$ **`SIGSEGV`**.
- **Correction** : Déclarer `counter` dans la section **`.data`** (initialisée, droits `RW-`) ou **`.bss`**.

---

## Exercice 4 — La Boucle Infernale de `RCX`
- **Deux catastrophes** :
  1. **Déséquilibre de pile cumulatif** : À chaque tour de boucle, `push rcx` décrémente `RSP` sans jamais faire de `pop`. La pile grandit indéfiniment jusqu'à heurter la limite de pile (*Stack Overflow*).
  2. **Destruction de `RCX` par le syscall** : L'instruction `syscall` écrase systématiquement `RCX` avec l'adresse de retour de l'instruction suivante ! L'instruction `loop` lit donc un `RCX` corrompu par le noyau au lieu du compteur de boucle initial.

---

## Exercice 5 — L'Appel `printf` qui S'Effondre
- **Les 2 erreurs critiques** :
  1. **Oubli de mettre `AL` à zéro** : `printf` est une fonction variadique. Elle exige que `al = 0` s'il n'y a pas d'arguments flottants dans les registres vectoriels `XMM`. Sans `xor eax, eax`, `printf` lit des registres SSE non initialisés et segfault.
  2. **Désalignement de la pile sur 16 octets** : À l'entrée dans `main`, $RSP \pmod{16} == 8$. Faire `call printf` sans avoir fait de `push rbp` ou `sub rsp, 8` appelle `printf` avec une pile désalignée, ce qui fait crasher les instructions `movaps` de la libc.

---

## Exercice 6 — L'Argument Perdu du Syscall
- **Cause** : Dans la convention des appels système x86_64, le 4ème argument est **`R10`**, alors que dans l'ABI de fonction C c'est `RCX`.
  Le développeur a placé le 4ème paramètre de `mmap` dans `RCX`.
  Pire : l'instruction `syscall` a écrasé `RCX` avec l'adresse de retour `RIP` !
  Le noyau Linux a donc lu ce qui traînait dans `R10` (une valeur invalide) $\rightarrow$ rejet de l'appel avec `EINVAL`.

---

## Exercice 7 — L'Instruction Fantôme (SIGILL)
- **Cause** : Un pointeur de fonction corrompu ou une adresse de retour sur la pile écrasée par un débordement de tampon (*Buffer Overflow*) a pointé vers la section `.data`.
  Comme la section `.data` contient des variables et non du code machine valide (et qu'elle est marquée non-exécutable grâce au bit **NX / No-Execute**), le CPU refuse d'exécuter ou décode des octets de données comme une instruction invalide $\rightarrow$ **`SIGILL`** ou **`SIGSEGV`**.

---

## Exercice 8 — La Relocation PIE
- `mov rsi, msg` utilise un adressage absolu 32 bits signé (`R_X86_64_32S`). Cela suppose que l'adresse de `msg` est fixe et connue avant l'exécution.
- Dans les binaires modernes **PIE** (*Position Independent Executable*), le programme est chargé à une adresse virtuelle aléatoire par l'ASLR. L'éditeur de liens refuse donc l'adressage absolu.
- `lea rsi, [rel msg]` utilise un adressage relatif au compteur d'instruction (`RIP + offset`). Cet offset reste rigoureusement identique quelle que soit l'adresse de chargement en mémoire.
