# Apprentissage de l'assembleur (x86-64) et de Rust

Dépôt d'apprentissage. Une note par session dans `notes/`, le code du jour dans `src/`, les questions en vrac dans `questions.md`.

## Commandes

### Docker

**Build**

```bash
docker build --platform linux/amd64 -t cpool-asm .
```

**Run**

```bash
docker run --rm -it --platform linux/amd64 -v "$PWD":/work cpool-asm
```

### Compiler l'assembleur (NASM)

```bash
nasm -f elf64 file.asm -o name.o
ld name.o -o binary
```

## Notes

- [Day 00 : `_start`, `sys_exit`, protection de l'OS, multitâche, context switch](notes/day00.md)

## Questions ouvertes

Voir [questions.md](questions.md).
