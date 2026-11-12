# Sujet Officiel — Projet 6 : La Minilibc Complète (`libasm.so`)

```
Projet            : Minilibc Epitech Complète
Durée estimée     : 12 à 20 heures
Rendu             : Makefile, strlen.asm, strchr.asm, strrchr.asm, memset.asm,
                    memcpy.asm, memmove.asm, strcmp.asm, strncmp.asm,
                    strcasecmp.asm, strstr.asm, strpbrk.asm, strcspn.asm
Binaire produit   : libasm.so (Bibliothèque partagée dynamique)
Compilation       : nasm -f elf64 / gcc -shared -fPIC
Conventions       : ABI System V AMD64 stricte
```

## 1. Description du Projet

Le projet **Minilibc** est le projet phare du cursus assembleur x86_64 d'Epitech.
Tu dois recoder en assembleur x86_64 pur une sélection de 12 fonctions standard de la bibliothèque C (`<string.h>`).

Le binaire produit doit être une **bibliothèque partagée dynamique (`libasm.so`)** capable de s'interfacer sans aucun avertissement avec n'importe quel exécutable C, et utilisable via `LD_PRELOAD`.

---

## 2. Prototypes Officiels des 12 Fonctions

```c
#include <stddef.h>

size_t strlen(const char *s);
char  *strchr(const char *s, int c);
char  *strrchr(const char *s, int c);
void  *memset(void *s, int c, size_t n);
void  *memcpy(void *dest, const void *src, size_t n);
void  *memmove(void *dest, const void *src, size_t n);
int    strcmp(const char *s1, const char *s2);
int    strncmp(const char *s1, const char *s2, size_t n);
int    strcasecmp(const char *s1, const char *s2);
char  *strstr(const char *haystack, const char *needle);
char  *strpbrk(const char *s, const char *accept);
size_t strcspn(const char *s, const char *reject);
```

---

## 3. Contraintes Techniques

- Chaque fonction doit résider dans son propre fichier source `.asm` dédié portant le nom exact de la fonction (ex: `strlen.asm`, `memcpy.asm`...).
- Les fonctions ne doivent appeler **aucune autre fonction** ni aucun appel système.
- Aucun registre *callee-saved* (`rbx, rbp, r12, r13, r14, r15, rsp`) ne doit être corrompu.
- Le Makefile doit produire la bibliothèque dynamique `libasm.so`.
