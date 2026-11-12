# Sujet Officiel — Projet 10 : Serveur Web TCP Minimaliste (`my_server`)

```
Projet            : my_server
Durée estimée     : 15 à 20 heures
Rendu             : Makefile, my_server.asm
Compilation       : nasm -f elf64 / ld (Liaison statique pure sans libc)
Port d'écoute     : 8080 (TCP)
```

## 1. Description du Projet

L'objectif de ce projet est de concevoir un serveur Web HTTP/1.1 minimaliste entièrement programmé en assembleur x86_64, sans aucune bibliothèque externe ni libc.

Le programme interagit directement avec la pile réseau du noyau Linux par l'intermédiaire des appels système réseau :
- `sys_socket` (41) : Création de la socket de streaming IPv4.
- `sys_bind` (49) : Liaison avec le port TCP 8080.
- `sys_listen` (50) : Activation de la file d'attente d'écoute.
- `sys_accept` (43) : Acceptation des connexions entrantes des clients web.
- `sys_read` (0) : Réception de la requête HTTP.
- `sys_write` (1) : Envoi de la réponse HTTP 200 OK.
- `sys_close` (3) : Clôture propre de la connexion.

---

## 2. Test du Serveur

Une fois lancé en arrière-plan :
```bash
./my_server &
```
Tu peux interagir directement avec lui via ton navigateur ou `curl` :
```bash
curl http://localhost:8080
```
Sortie attendue :
```
Hello from x86_64 raw assembly server!
```
