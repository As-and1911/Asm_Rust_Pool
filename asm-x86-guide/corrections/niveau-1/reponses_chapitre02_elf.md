# Corrigé des exercices d'inspection binaire — Chapitre 2

## Exercice 1 — Nombre magique ELF
Les 4 premiers octets sont : `7f 45 4c 46` :
- `0x7F` : Octet de contrôle binaire (délimiteur non imprimable).
- `0x45` = ASCII 'E'
- `0x4C` = ASCII 'L'
- `0x46` = ASCII 'F'
L'en-tête s'identifie donc textuellement par `\x7fELF`.

---

## Exercice 2 — Adresse du point d'entrée
Typiquement sur un binaire x86_64 ELF non-PIE linké avec `ld`, le point d'entrée se situe à :
`0x401000` (ou une adresse similaire dans la plage `0x400000` - `0x401000`).
C'est à cette adresse précise que réside la première instruction de `_start`.

---

## Exercice 3 — Inspection des sections
1. Un binaire minimal généré par NASM + LD comporte généralement entre 5 et 7 sections (`.text`, `.data`, `.symtab`, `.strtab`, `.shstrtab`...).
2. Adresses typiques :
   - `.text` commence à `0x401000` (drapeaux AX : Alloc + Executable).
   - `.data` commence à `0x402000` (drapeaux WA : Writable + Alloc).

---

## Exercice 4 — Comparaison de taille : .data vs .bss
- `prog_data` fait environ **1 Mégaoctet** sur le disque dur, car chaque octet initialisé à `1` doit physiquement exister dans le fichier ELF stocké sur le disque.
- `prog_bss` ne fait qu'environ **8 à 9 Kilooctets** sur le disque, car la section `.bss` n'enregistre qu'une métadonnée : *"allouer 1 000 000 octets lors du chargement en mémoire vive"*.

---

## Exercice 5 — Opcodes machine
- `mov rax, 1` : encodé par `b8 01 00 00 00` (ou `48 c7 c0 01 00 00 00` selon le format 32/64 bits).
- `mov rax, 60` : `b8 3c 00 00 00` (`0x3c` = 60).
- `syscall` : toujours codé sur exactement 2 octets : **`0f 05`**.

---

## Exercice 6 — Extraction avec strings
La chaîne `"Hello, World!"` est présente dans la section `.data`. Comme elle n'est ni compressée ni chiffrée, l'utilitaire `strings` la détecte comme une suite continue d'octets ASCII imprimables terminée par un retour à la ligne ou un zéro.

---

## Exercice 7 — La commande strip
`strip hello` retire la table des symboles (`.symtab`) et les noms de fonctions/variables (`.strtab`).
- Le programme **fonctionne toujours parfaitement**, car le processeur et le chargeur du noyau n'ont besoin que des adresses mémoires et des Program Headers, pas des noms humains.
- On utilise `strip` pour réduire la taille des fichiers distribués et rendre le reverse engineering plus difficile.

---

## Exercice 8 — Alignement des sections
Les processeurs modernes transfèrent les données entre la mémoire et le cache par blocs alignés (lignes de cache de 64 octets, et pages mémoire virtuelles de **4096 octets** / 4 Ko).
Aligner les sections sur des multiples de 4096 octets permet au noyau de mapper directement les segments disque vers les pages physiques sans chevauchement de droits de sécurité (une page ne peut pas être à la fois Read-Only et Read-Write).

---

## Exercice 9 — Retrouver les syscalls
Dans `hello` :
1. Premier bloc : `mov eax, 0x1` suivi de `syscall` -> `sys_write`.
2. Second bloc : `mov eax, 0x3c` (`60`) suivi de `syscall` -> `sys_exit`.

---

## Exercice 10 — Patch binaire
Exemple avec `sed` ou python en binaire :
```bash
python3 -c "
with open('hello', 'rb') as f: data = f.read()
data = data.replace(b'Hello', b'Jello')
with open('hello_patched', 'wb') as f: f.write(data)
"
chmod +x hello_patched
./hello_patched
# Affiche : Jello, World!
```
Tu as modifié directement le code binaire sans passer par la phase d'assemblage !
