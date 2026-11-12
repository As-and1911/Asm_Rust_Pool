# Chapitre 11 — Les Projets Intégrateurs Avancés : Du Shell Unix au Serveur TCP

## 🎯 Objectifs de ce chapitre

Tu es arrivé au sommet de la pratique. Tu as désormais toutes les bases matérielles, algorithmiques et système.
Ce chapitre présente les 4 grands projets d'intégration qui vont prouver ta maîtrise absolue de l'assembleur x86_64 :

1. **Projet 7 — Le Convertisseur de Bases Universel** : Conversions bidirectionnelles (Binaire, Octal, Décimal, Hexadécimal) avec parsing robuste et détection de débordement.
2. **Projet 8 — Le Jeu "Devine le Nombre"** : Implémentation d'un PRNG (*Pseudo-Random Number Generator*) matériel en assembleur pur (Algorithme XORShift 64 bits), boucle de jeu interactive sur le terminal et compteur d'essais.
3. **Projet 9 — Le Mini-Shell Unix (`my_sh`)** : Un interpréteur de commandes interactif en assembleur pur (Prompt, lecture clavier, découpage de chaîne en arguments, résolution de binaire, `fork`, `execve`, `wait4`, et commande intégrée `exit`).
4. **Projet 10 — Le Serveur Web TCP Minimaliste** : Écoute réseau brute sans aucune bibliothèque via les syscalls `sys_socket`, `sys_bind`, `sys_listen`, `sys_accept`, `sys_read`, `sys_write`. Un vrai serveur HTTP qui répond aux navigateurs !

---

## 11.1 — Projet 7 : Le Convertisseur de Bases Universel

### Le Concept :
L'ordinateur ne connaît que les nombres binaires. Toute conversion entre texte humain et mémoire machine repose sur deux fonctions jumelles :
- **`atoi_base(str, base)`** : Lit une chaîne textuelle dans une base donnée et produit un entier machine dans `RAX`.
- **`itoa_base(val, buf, base)`** : Prend un entier machine dans `RAX` et écrit sa représentation textuelle dans `buf`.

```
                  ┌──────────────────────┐
                  │ Chaîne textuelle     │ "101010" (base 2) ou "2A" (base 16)
                  └──────────┬───────────┘
                             │ atoi_base
                             ▼
                  ┌──────────────────────┐
                  │ Valeur 64b brute     │ 42 (0x000000000000002A)
                  └──────────┬───────────┘
                             │ itoa_base
                             ▼
                  ┌──────────────────────┐
                  │ Nouvelle base        │ "52" (base 8) ou "42" (base 10)
                  └──────────────────────┘
```

---

## 11.2 — Projet 8 : Le Jeu "Devine le Nombre" & PRNG en Asm

### Comment générer du hasard en assembleur sans libc ?
La fonction C `rand()` n'est pas magique : c'est un calcul déterministe qui mélange les bits.
L'un des générateurs pseudo-aléatoires les plus élégants et rapides au monde s'appelle **XORShift 64** :

```asm
; =============================================================================
; xorshift64 — Générateur de nombre pseudo-aléatoire 64 bits
; Entrée  : RDI = graine (seed non nulle)
; Sortie  : RAX = nouveau nombre pseudo-aléatoire
; =============================================================================
xorshift64:
    mov     rax, rdi
    mov     rbx, rax
    shl     rbx, 13
    xor     rax, rbx            ; x ^= x << 13

    mov     rbx, rax
    shr     rbx, 7
    xor     rax, rbx            ; x ^= x >> 7

    mov     rbx, rax
    shl     rbx, 17
    xor     rax, rbx            ; x ^= x << 17
    ret
```
Ce court algorithme produit une séquence uniforme de période $2^{64}-1$ avec d'excellentes propriétés statistiques, en seulement 9 instructions d'une rapidité fulgurante !

---

## 11.3 — Projet 9 : Le Mini-Shell Unix (`my_sh`)

Concevoir un Shell en assembleur pur est l'exercice de synthèse par excellence. Il met en jeu tous les concepts système vus jusqu'ici :

```
         ┌────────────────────────────────────────────────────────┐
         │ 1. AFFICHER LE PROMPT ("my_sh$ ")                      │
         └──────────────────────────┬─────────────────────────────┘
                                    │
                                    ▼
         ┌────────────────────────────────────────────────────────┐
         │ 2. LIRE LA COMMANDE (sys_read sur stdin)               │
         └──────────────────────────┬─────────────────────────────┘
                                    │
                                    ▼
         ┌────────────────────────────────────────────────────────┐
         │ 3. PARSER LA LIGNE (Découper mots & créer argv[])      │
         └──────────────────────────┬─────────────────────────────┘
                                    │
               Commande "exit" ? ───┴───► OUI ──► sys_exit(0)
                                    │ NON
                                    ▼
         ┌────────────────────────────────────────────────────────┐
         │ 4. sys_fork (Cloner le processus)                      │
         └──────────────────────────┬─────────────────────────────┘
                                    │
                   ┌────────────────┴────────────────┐
                   │                                 │
            PARENT (PID > 0)                    FILS (PID == 0)
                   ▼                                 ▼
         ┌───────────────────┐             ┌─────────────────────┐
         │ 5. sys_wait4      │             │ 5. sys_execve       │
         │ (Attend le fils)  │             │ (Remplace par le    │
         └─────────┬─────────┘             │  nouveau binaire)   │
                   │                       └─────────────────────┘
                   └──────────── Reboucler vers le Prompt !
```

---

## 11.4 — Projet 10 : Le Serveur Web TCP Minimaliste

Oui, il est possible d'écrire un serveur Web complet en assembleur x86_64 qui répond aux requêtes de Google Chrome ou `curl` !

### Les 6 Syscalls Réseau indispensables :
1. **`sys_socket` (RAX = 41)** :
   `socket(AF_INET = 2, SOCK_STREAM = 1, 0)` $\rightarrow$ Crée le point de terminaison réseau (FD socket).
2. **`sys_bind` (RAX = 49)** :
   Associe la socket à une adresse IP (`0.0.0.0`) et un port d'écoute (`8080`) via une structure `sockaddr_in`.
3. **`sys_listen` (RAX = 50)** :
   Passe la socket en mode écoute passive en définissant la file d'attente.
4. **`sys_accept` (RAX = 43)** :
   Attend qu'un client se connecte et renvoie un nouveau descripteur dédié au client !
5. **`sys_read` / `sys_write`** :
   Lit la requête HTTP du navigateur et renvoie la réponse :
   ```http
   HTTP/1.1 200 OK\r\n
   Content-Length: 38\r\n
   Content-Type: text/plain\r\n
   \r\n
   Hello from x86_64 raw assembly server!
   ```
6. **`sys_close` (RAX = 3)** :
   Ferme la connexion avec le client et retourne attendre le prochain visiteur dans une boucle infinie !

---

> 🏅 **Badge débloqué : Architecte système** — Découvrons le code complet de chacun de ces 4 projets dans leurs répertoires respectifs !
