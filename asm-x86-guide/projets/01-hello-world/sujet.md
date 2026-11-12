# Sujet Officiel — Projet 1 : Hello World & Output Dispatcher

```
Projet            : my_hello
Durée estimée     : 2 à 4 heures
Rendu             : Makefile, my_hello.asm
Compilation       : nasm -f elf64 / ld
Langage           : Assembleur x86_64 pur
Code d'erreur     : 84 (Norme Epitech)
```

## 1. Description du Projet

L'objectif de ce premier projet est de construire un exécutable autonome capable d'afficher des chaînes de caractères sur différents canaux de sortie standardisés (`stdout` et `stderr`), de gérer des codes de retour d'erreur stricts, et de mettre en place une chaîne d'automatisation via un **Makefile** conforme.

---

## 2. Spécifications Fonctionnelles

### Mode 1 : Affichage Standard (stdout)
Lorsqu'il est exécuté sans argument particulier :
```bash
./my_hello
```
Le programme doit écrire exactement la ligne suivante sur le descripteur de fichier 1 (`stdout`) :
```
Hello, World!
```
suivi d'un retour à la ligne (`\n`, code ASCII `10`).
Le code de sortie renvoyé au shell doit être impérativement **`0`**.

### Mode 2 : Affichage d'Erreur (stderr)
Si le code source est assemblé avec le drapeau `-DERROR_MODE=1` :
```bash
make error
./my_hello
```
Le programme doit écrire exactement sur le descripteur de fichier 2 (`stderr`) :
```
[ERROR] Operation failed successfully.
```
suivi d'un retour à la ligne.
Le code de sortie renvoyé au shell doit être impérativement **`84`**.

### Mode 3 : Bannière ASCII Multi-lignes
La commande `make banner` compile un binaire `my_hello_banner` qui affiche une bannière stylisée de 4 lignes minimum.

---

## 3. Makefile Attendu

À la racine de ton projet, tu dois fournir un `Makefile` qui contient obligatoirement les cibles suivantes :

- **`all`** : Assemble et linke `my_hello` (mode standard).
- **`error`** : Compile le binaire en mode erreur (`-DERROR_MODE=1`).
- **`clean`** : Supprime les fichiers objets temporaires (`*.o`).
- **`fclean`** : Exécute `clean` et supprime les binaires générés.
- **`re`** : Exécute `fclean` puis `all`.

---

## 4. Tests Automatisés

Pour lancer la moulinette d'évaluation :
```bash
bash tests/test_hello.sh
```
