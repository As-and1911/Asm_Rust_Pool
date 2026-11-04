# Day 00

## Ce que j'ai codé

Un hello world en assembleur x86-64 (NASM) : [src/day00/](../src/day00/)
Un hello world en Rust de deux façons différents : avec l'interface std::io::Write d'un côté et avec la fonction write de la libC de l'autre : [src/day00/](../src/day00/)

## Questions

1- Pourquoi le point d'entrée d'un programme en assembleur s'appelle _start et non main ?
C'est simplement parce que _start est le véritabe point d'entrée brut attendu par l'éditeur de lien (linker) et le système d'exploitation alors que main est une convention propre au langage C

******                   DIFFÉRENCES FONDAMENTALES ENTRE _START ET MAIN                 ******


_START:
- c'est l'adresse exacte où le système d'exploitation transfère le contrôle lorsque le programme est chargé en mémoire

- À ce stade rien n'est initialisé. Il n'y a pas de gestionnaire d'exceptions, pas de variables globales configurées et la pile (stack) contient les arguments bruts de la ligne de commande

- Si on quitte _start avec une simple instruction de retour comme un ret, le programme va crasher (Segmentation fault). Il faut obligatoirement utiliser un appel système (syscall) comme sys_exit pour arrêter proprement le programme.

MAIN:

- En c, le compilateur ajoute automatiquement un code invisible en arrière plan appelé la bibliothèque s'éxectution C (CRT ou crt0)

- C'est le code de la CRT qui contient le véritable _start. Il s'oocupe de configurer l'environnement (initialiser la mémoire, préparer argc et argv)

- Une fois que tout est prêt, la CRT appelle la fonction main. Quand le main se termine, le contrôle revient à la CRT qui se charge d'appeler le syscall de sortie à notre place.


2- Que se passe t il si l'on supprime le syscall sys_exit ? Pourquoi?


Quand on supprime le syscall sys_exit le programme segfault.

La raison ? Le processeur continue d'éxecuter aveuglément les instructions suivantes en mémoire jusqu'à ce qu'il tente de lire ou d'exécuter une zone en mémoire interdite

Voici ce qui se passe techniquement :

- En assembleur le processeur lit les instructions du code ligne par ligne (via le pointeur d'instruction rip ou eip). une fois la dernière ligne du code atteinte, le processeur ne s'arrête pas automatiquemne t.

- Si on ne lui dit pas explicitement de s'arrêter, il continue sa course dans la mémoire RAM juste après le code. Il commence alors à interprèter des données aléatoires ou du vide comme si c'étaient des instructions valides.

-Très rapidement, cette course folle l'amène à sauter hors de la section de mémoire réservée à notre programme (la section de texte/code autorisée par le système d'exploitation).

- Dès que le processeur tente d'accéder à cette adresse non autorisée ou d'éxecuter une instruction invalide, le système d'exploitation intervient instantanément pour protéger le reste de l'ordinateur. Il tue le process et affiche l'erreur : segmentation fault

@@@         ERREUR CLASSIQUE : Utiliser ret au lieu de sys_exit         @@@

Si vous écrivez ret(return) à la fin de _start, le processeur va chercher sur la pile l'adresse de retour pour savoir où aller. Or, au démarrage de _start, il n'y a aucune adresse de retour sur la pile (il n'y a que les arguments comme argc et argv). Le processeur va donc dépiler une valeur qui n'est pas une adresse valide et tenter d'y sauter, ce qui provoque immédiatement le crash

Donc pour éviter ça le seul moyen propre est de court-circuiter le processeur en passant par un syscall (sys_exit), ce qui revient à lever la main et dire au système d'exploitation "j'ai fini, tu peux reprendre les clés du processeur et fermer le programme."


@@@ COMMENT L'OS INTERVIENT POUR PROTÉGER L'ORDINATEUR DANS CE GENRE DE SITUATION? @@@

L'os agit comme un garde du corps et un gestionnaire d'espaces étanches entre les programmes. Il protège l'ordinateur contre trois menaces majeures :

A- La corruption des autres programmes en cour d'exécution

Sur un ordinateur moderne, des dizaines de programmes tournent en même temps (le navigateur web, la musique, le système lui-même).
- Le danger : Si un programme pouvait écrire n'importe où dans la mémoire RAM, un bug dans le code assembleur pourrait aller les données du navigateur web et voler vos mots de passe ou modifier le code d'un autre logiciel.
- La protection: Grâce à un mécanisme matériel appelé la pagination (la mémoire virtuelle), l'OS fait croire à chaque programme qu'il est seul au monde et qu'il possède toute la mémoire. Un programme ne peut physiquement pas voir ni toucher la mémoire d'un autre. S'il tente de sortir de sa boîte, l'OS le détecte et le détruit (le fameux segfault).


B- Le crash complet de la machine (Écran bleu ou Kernel Panic)
Le coeur de l'os (kernel ou noyau) réside lui aussi dans la mémoire RAM.
- Le danger: Si votre programme continuait à s'éxecuter dans le vide et finissait par écraser les données vitales du noyau de l'OS, l'ordinateur entier cesserait instantanément de fonctionner. C'est ce qui provoquait les écrans bleus systématiques sur les vieux systèmes comme Windows 95 qui protégeaient mal la mémoire.
- La protection : l'os utilise des niveaux de privilèges (les Anneaux de protections / Rings). Votre programme tourne dans le Ring 3 (le moins privilégié), tandis que le noyau tourne dans le Ring 0 (accès total). Un programme en Ring 3 n'a pas le droit d'écrire dans les zones du Ring 0


C- La perte de contrôle du processeur
Le processeur (CPU) est partagé entre toutes les tâches via un mécanisme de répartition du temps.
- Le danger : Si un programme entre dans une boucle infinie ou exécute des instructions invalides en boucle, il pourrait monopoliser le processeur à 100%, figeant totalement l'ordinateur. Plus rien ne répondrait (ni la souris, ni le clavier).
-la protection : l'OS utilise des interruptions matérielles (des minuteur) pour reprendre régulièrement et de force le contrôle du processeur. Si le processeur signale qu'un programme tente d'exécuter une instruction interdite ou inexistante (ce qui arrive quand du code assembleur dérive dans le vide), l'OS reprend immédiatement la main pour tuer le processus fautif



@@@        LA PRIVATION DE CPU OU FAMINE DE CPU (CPU STARVATION)       @@@


C'est le fait qu'un processus monopolise le processeur à 100%, laissant les autres programmes attendre indéfiniment.
Selon le contexte exact, on utilise des termes plus spécifiques :
- UN thread / processus CPU-bound (ou intensif en calcul): c'est le terme technique normal si l e programme fait légitimenment des calculs lourds (ex: rendu vidéo, compilation)
- Une boucle infinie (ou boucle active / busy waiting): c'est le terme utilisé s'il s'agit d'un bug (ex: while (true) {} en C ou un saut infini en assembleur). Le processeur tourne à fond à vide.
- Un gel, un blocage ou un système suspendu (hang/freeze): c'est l'effet visible pour l'utilisateur quand l'interface quand l'interface ne réponds plus


@@@       COMMENT LE PROCESSEUR EST IL PARTAGÉ ENTRE LES PROGRAMMES      @@@


Pour éviter qu'un seul programme ne bloque tout, les os modernes utilisent un mécanisme appelé le multitâche préemptif.
Le processeur ne tourne pas du tout en simultané pour tout le monde (sur un coeur donné). Au lieu de cela, il découpe le temps en fractions minuscules (quelques millisecondes) et passe d'un programme à l'autre à toute vitesse, donnant l'illusion que tout tourne en même temps.


Voici les trois composants clés qui permettent ce partage:
A- l'Ordonnanceur (Scheduler): le chef d'orchestre
L'ordonnaceur est un composant central de l'OS. c'est lui qui gère la file d'attente des programmes. Il attribue à chaque processus un temps de parole appelé un quantum de temps (entre 10 et 100 miilisecondes). Une fois le quantum écoulé, l'ordonnanceur siffle la fin du tour de ce programme et donne le processeur au suivant, en fonction de priorités définies.
B- l'Interruption de la minuterie : L'arbitre matériel
C'est le point de sécurité crucial. Un programme malveillant ou buggé pourrait décider de ne jamais rendre la main. Pour contrer cela, l'ordinateur possède une horloge matérielle (puce électronique) indépendante du processeur.
. Toutes les quelques millisecondes, cette horloge envoie un impulsion électrique (une interruption matérielle) directement au processeur.
. Cette impulsion force le processeur à s'arrêter immédiatement, peu importe ce que le programme en cours faisait.
. Le processeur passe alors le contrôle à l'OS permettant à l'ordonnanceur de reprendre la main et de choisir un autre programme. C'est pour cela qu'on parle de multitâche préemptif: L'OS a le pouvoir de préempter (interrompre de force) un processus.
C- Le changement de contexte (Context Switch) : la sauvegarde
Pour passer du Programme A au Programme B sans perdre le fil, l'OS effectue une manipulation ultra rapide:
1- Il gèle le Programme A
2- Il sauvegarde l'état exact de ses régistres (dont le fameux pointeur d'instruction rip qui dit où on en était dans le code).
3- Il charge en mémoire les régistres et le pointeur du programme B
4 - Il laisse le programme B s'éxécuter pendant son quantum de temps


Grâce à cette gymnastique qui se produit des centaines de fois par seconde, même si votre programme assembleur boucle à l'infini à 100%, l'interruption horloge permettra toujours à l'OS de reprendre le contrôle pour faire bouger votre souris ou fermer le programme buggé



@@@           CONTEXT SWITCH (In case of register in assembly)          @@@


C'est l'opération basse couche la plus fondamentale d'un système d'exploitation. Elle représente l'action physique de photographier l'état d'un programme pour le figer puis de restaurer la photographi d'un autre programme afin qu'il reprenne sa course exactement là où il s'était arrêté.
Pour le processeur, un programme n'est rien d'autre qu'un ensemble de valeurs stockés dans des régistres (les case mémoires ultra rapides du CPU) et une zone de mémoire appélée la pile (stack). Faire un changement de contexte revient donc à manipuler ces régistres



Voilà comment cela se passe concrètement au coeur de l'architecture x86_64:


**La Photocopie d'un programme (L'état du CPU)**
Pour suspendre le programme A , l'OS doit sauvegarder son contexte. Ce contexte est composé de :
- RIP (Instruction Pointer): l'adresse de la ligne de code en train d'être exécutée
- RSP (Stack Pointer) : l'adresse du sommet de la pile du programme
- Les régistres généraux : rax, rbx, rcx, rdx, rsi, rdi, r8 à r15 (les variables de travail immédiates du processeur)
- RFLAGS : l'état des indicateurs (si le dernier calcul a donné zéro, un résultat négatif, etc)

Ces infos sont stockées dans une structure de données en mémoire gérée par l'OS, souvent appelé le PCB (Le Process Control Block) ou le Thread Control Block


**Le Scénario en Assembleur (Pas à pas)**

Imaginons que le Programme A soit interrompu par l'horloge matérielle. Le processeur bascule en mode noyau (RING 0) et exécute le code assembleur dde l'OS dédié au changement de contexte

Étape 1: La sauvegarde automatique par le CPU
Dès que l'interruption se produit, le processeur effectue lui-même une première sauvegarde d'urgence sur la pile noyau . Il y pousse automatiquement:
. SS (Stack segment)
. RSP (le pointeur de pile du programme A)
. RFLAGS
. CS (code segment)
. RIP (l'adresse où le programme A devra reprendre)


Étape 2: La sauvegarde manuelle des régistres (Code de l'OS)

L'OS doit maintenant sauvegarder le reste des régistrezs généraux qui étaient utilisés par le Programme A. Le code assembleur du noyau ressemble à une suite de push:


; (Entrée dans le gestionnaire d'interruption de l'OS)
push rbp
push rax
push rbx
push rcx
push rdx
push rsi
push rdi
push r8
push r9
push r10
push r11
push r12
push r13
push r14
push r15

; À ce stade, la pile contient TOUT le contexte du Programme A.
; L'OS va maintenant sauvegarder le pointeur de cette pile (RSP) 
; dans la structure de données (PCB) du Programme A.
mov [programme_a_pcb_rsp], rsp

NB: L'instruction push sert à placer une valeur au sommet de la pile (stack) et à décrémenter le pointeur de pile (rsp)


Étape 3 : Le choix de l'Ordonnanceur

Le code C/Assembleur de l'ordonnanceur de l'OS s'éxecute pour décider que sera le prochain programme à tourner (le programme B). il va chercher le pointeur de pile sauvegardé du Programme B. Il ne reste plus qu'à dépiler son ancien contexte dans l'ordre inverse


; On bascule sur la pile du Programme B
mov rsp, [programme_b_pcb_rsp]

; On restaure ses registres généraux
pop r15
pop r14
pop r13
pop r12
pop r11
pop r10
pop r9
pop r8
pop rdi
pop rsi
pop rdx
pop rcx
pop rbx
pop rax
pop rbp

; L'instruction magique de fin d'interruption
iretq 

NB: l'instruction pop en sert principalement à récupérer une donnée située au sommet de la pile (stack) et à la stocker dans une destination (généralement un régistre), tout en incrémentant le pointeur de pile (rsp)
L'instuction iretq (Interrupt Return 64-bits) est l'étape finale. Elle dépile automatiquement rip, cs rflags, rsp et ss que le cpu y avait mis lors de la suspension du programme B


le processeur se retrouve instantanément configuré exactement comme l'était le programme B avant d'être interrompu. Il reprend son exécution au RIP restauré, sans même avoir conscience qu'il a été arrêté



@@@          IL Y A T IL UNE PILE ET DES RÉGISTRES POUR CHAQUE PROCESSUS?         @@@

En réalité, chaque processus dispose de sa propre pile (virtuelle), mais ils partagent tous physiquement les mêmes régistres du processeur.
C'est la tout le génie de l'architecture d'un ordinateur. Voici précisément comment le processeur et le système d'exploitation s'organisent pour ne jamais rien confondre.

1- La pile (La stack): Une par processus

Chaque processus possède sa propre pile. Plus préciséement, chaque processus dispose d'un espace de mémoire RAM qui lui est totalement réservé.
Pour éviter qu'un processus n'écrive sur la pile d'un autre, le processeur utilise un composant matériel appelé la MMU (Memory Management Unit) et un mécanisme appelé la mémoire virtuelle:
-L'illusion: Quand un programme est compilé, il a l'impression d'avoir une pile à une adreese fixe (par exemple 0x7fffffffe000) Tous les programmes croient avoir la même adresse.
-La réalité: La MMU possède une "table de traduction" (gérée par l'OS). Lorsque le process A accède à son adresse 0x7fff... , la MMU la traduit en une case physique réelle dans la RAM (ex: Case n°1250). Lorsque le process B accède à la même adresse virtuelle;, la MMU la traduit vers une tout autre case physique (ex: Case n°8400)
Puisque les espaces physiques de la RAM sont totalement étanches, il est impossible pour un process de confondre ou de modifier la pile d'un autre.

2-Les Régistres: Un seul jeu physique pour tout le monde
Les régistres (rax, rbx, rsp, etc.) sont des circuits électroniques gravés directement à l'intérieur du processeur. Ils sont extrêmement rapides, mais ils sont uniques. IL n'y a pas un jeu de régistres par programme.
Le processeur ne peut donc gérer qu'un seul contexte à la fois

§§ Comment le processeur évite de les confondre ?
Il ne le fait pas parce qu'il applique la règle du partage dans le temps via le changement de contexte (que nous avons vu juste avant). le processeur ne sait pas ce qu'est un processus, il ne fait qu'executer les instructions. C'est l'OS qui fait le travail de passe-passe:
a- Le processeur travaille pour le process A: les régistres contiennent les donnés du processA
b- L'heure tourne(fin du quantum) : L'OS intervient. Il prend une "photo" des régistres et va copier toutes les valeurs dans la RAM, dans une zone sécurisée réservée au process A(le PCB)
c- Le processeur travaille pour le process B: Le processeur continue sa course. les données du processus A ne sont pas perdues, elles "dorment" sagement dans la RAM attendant leur tour


*** Que calcule equ $ - msg et quand cette valeur est elle déterminée ?? ***

    Elle sert à calculer automatiquement la longueur en octets de la chaîne de caractères msg

Le symbole $ (jeton de position actuelle): représente l'adresse mémoire actuelle (le pointeur d'emplacement) à la ligne où il est écrit. Càd l'adresse mémoire juste après la fin de la chaînes de caractères

msg est l'étiquette (le label) qui pointe sur l'adresse mémoire du tout premier caractère de la chaîne

la soustraction $ - msg permet d'obtenir le nbr exact d'octets qui séparent ces deux points. C'est donc la longueur de la chaîne.

Comme ça on évite de compter manuellement les caractères


      - La valeur de $ - msg est déterminer au moment de la compilation ou de l'assemblage et non pendant l'exécution du programme

           . Le mot-clé equ (equate / assimiler) definit une constante de compilation. Il fonction un peu comme un #define en langage C.
           . Lorsque l'on lance le compilateur assembleur (comme NASM) il lit la chaîne, calcule la différence d'adresse trouve par exemple le nombre 22 et remplace définitivement le mot len par 22 partout dans le code



*** Quelle est la différence entre lea rsi, [rel msg] et mov rsi, msg ??? ***

Elle réside dans la façon dont l'adresse mémoire est calculée et représentée dans le code machine final et cela est intimement lié à la sécurité des systèmes s'exploitation modernes (la protection RIP-relative).


     . COMPARATIF DIRECT:
           - mov rsi, msg (adresse absolue et fixe)
           . Ce qu'il fait : Il copie l'adresse de msg directement dans le régistre rsi
           . Comment ça marche : L'adresse est codée "en dur" dans l'instruction machine. Par exemple, si au moment de la compilation msg est placé à l'adresse fixe 0x401000, l'instruction devient : << Mets la valeur 0x401000 dans RSI>>".
           . Le problème moderne : Les systèmes d'exploitation actuels utilisent une sécurité appelée ASLR (Adress Space Layout Randomization). À chaque fois que votre programme se lance, l'OS change aléatoirement son emplacement en mémoire RAM pour empêcher les piratages. Si votre adresse est écrite en dur avec un mov, le programme va chercher à la mauvaise adresse et va crash (segfault)


           -lea rsi, [rel msg] (Adresse relative, compatible ASLR)
                .Ce qu'il fait : LEA (pour Load Effective Adress) calcule l'adresse de msg et la met dans rsi
                .Comment ça marche : Le mot clé rel indique un adressage relatif au pointeur d'instruction (rip). L'instruction machine ne contient plus une adresse fixe mais un offset (écart). Elle dit au processeur << Prends l'adresse de la ligne de code que tu es en train d'éxecuter (rip), ajoute y exactement X octets et mets le résultat dans rsi>>
                . L'avantage moderne : C'est le mode par défaut exigé sur les systèmes 64-bits modernes pour générer du code PIE (POSITION INDEPENDENT EXECUTABLE). Même si l'OS déplace le programme n'importe où en mémoire RAM à caude de ASLR, la distance entre votre instruction lea et la variable msg reste toujours strictement la même. Le programme ne plantera jamais

*** À QUOI SERT CONCRÈTEMENT LE MOT-CLÉ UNSAFE ***

          Il sert à désarçonner les contrôles et vérifications strictes du compilateur Rust pour pouvoir, par exemple, importer du code d'autres langages de programmation comme le c

          Il dit clairement : "Cher compilateur, je sais que tu ne peux pas vérifier ce morceau de code. Ne panique pas, je prends l'entière responsabilté de la sécurité ici."

          Il permet par la même d'autoriser des actions normalement interdites:  En dehors d'un bloc unsafe , Rust interdirait formellement de manipuler des pointeurs bruts(comme le *const u8 que nous avons utilisé) car un pointeur peut pointer vers une zone mémoire invalide et faire crasher l'ordinateur


*** COMBIEN D'APPELS SYSTÈMES FONT CHAQUE VERSION DU HELLO WORLD EN RUST ***

     1- VERSION IDIOMATIQUE (Avec le trait std::io::Write)
       -Number of syscalls: 66

       -Number of sys_write call: 1

       -Tableau récapitulatif de ces différents appels systèmes (strace - c)
       % time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ------------------
 35.21    0.003202        3202         1           execve
 18.59    0.001691         130        13           mmap
 13.10    0.001191         297         4           openat
  6.17    0.000561         112         5           mprotect
  3.82    0.000347          69         5           read
  3.42    0.000311          77         4           close
  3.41    0.000310         155         2           lseek
  2.39    0.000217          72         3           newfstatat
  2.31    0.000210         105         2           prlimit64
  1.95    0.000177          35         5           rt_sigaction
  1.76    0.000160          53         3           brk
  1.65    0.000150          37         4           fstat
  1.55    0.000141         141         1           sched_getaffinity
  1.18    0.000107          53         2           sigaltstack
  1.02    0.000093          46         2           getrandom
  0.53    0.000048          48         1           write
  0.47    0.000043          43         1           gettid
  0.41    0.000037          37         1           arch_prctl
  0.38    0.000035          35         1           set_robust_list
  0.38    0.000035          35         1           rseq
  0.31    0.000028          28         1           set_tid_address
  0.00    0.000000           0         1           poll
  0.00    0.000000           0         1         1 access
------ ----------- ----------- --------- --------- ------------------
100.00    0.009094         142  

          2-VERSION AVEC LA LIBC (extern "C" et unsafe)

          -Number of syscalls: 66

          -Number of sys_write call: 1

          -Tableau récapitulatif de ces différents appels systèmes:

% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ------------------
 32.82    0.003492        3492         1           execve
 17.95    0.001910         146        13           mmap
  7.85    0.000835         208         4           openat
  6.20    0.000660         132         5           read
  6.08    0.000647         215         3           newfstatat
  5.29    0.000563         112         5           mprotect
  5.21    0.000554         138         4           fstat
  5.20    0.000553         138         4           close
  2.24    0.000238         119         2           lseek
  1.99    0.000212          42         5           rt_sigaction
  1.94    0.000206          68         3           brk
  0.93    0.000099          49         2           getrandom
  0.91    0.000097          48         2           prlimit64
  0.81    0.000086          43         2           sigaltstack
  0.74    0.000079          79         1           sched_getaffinity
  0.69    0.000073          73         1           poll
  0.69    0.000073          73         1         1 access
  0.68    0.000072          72         1           rseq
  0.56    0.000060          60         1           set_tid_address
  0.53    0.000056          56         1           set_robust_list
  0.39    0.000042          42         1           write
  0.32    0.000034          34         1           gettid
  0.00    0.000000           0         1           arch_prctl
------ ----------- ----------- --------- --------- ------------------
100.00    0.010641         166        64         1 total


*** POURQUOI PRINTLN! NE SE COMPORTE PAS COMME UN WRITE?? ***

Il y a deux raisons principales à cela : la gestion automatique du saut de ligne et du flush, et la sécurité des threads grâce à un verrouillage interne (locking)

1- Le verrouillage implicite (Thread safety)

     .println! verrouille automatiquement stdout à chaque invocation. Pour éviter que plusieurs threads n'entremêlent leurs lignes à l'écran. Il acquiert un verrou (mutex) sur le flux de sortie standard, écrit les données, puis relâche le verrou

     .write! (std::io::stdout().write()) est brut. Si vous l'utilisez directement sans verrouiller manuellement, chaque appel système d'écriture est indépendant. Dans un contexte multithread, cela  peut fragmenter le texte. De plus, acquérir et relâcher le verrou à chaque ligne dans une boucle rapide avec un println! génère une surcharge de performance (overhead) importante.

2- Le saut de ligne et le "Flushing" (Tanmpon de sortie)
     . println! ajoute un \n et force l'affichage. Par défaut, stdout e Rust est équipé d'un tampon(buffered). Les données restent en mémoire tant que le tampon n'est pas plein ou qu'un saut de ligne n'est pas rencontré. println! garantit que le texte est immédiatement poussé(flushed) vers le terminal.

     .write! n'effectue aucun flush automatique. Si vous écrivez du texte avec write!, il se peut qu'il n'apparaisse pas immédiatement à l'écran tant que vous n'appelez pas explicement .flush().


3- Voici une façon d'obtenir les perfomances du write brut proprement 


use std::io::{self, Write};

fn main() -> io::Result<()> {
    let stdout = io::stdout();
    let mut handle = io::BufWriter::new(stdout.lock()); // Un seul verrou et un tampon de mémoire

    for i in 0..10_000 {
        writeln!(handle, "Ligne numéro {}", i)?; // Rapide, pas de verrouillage répété
    }

    handle.flush()?; // On vide le tampon à la fin
    Ok(())
}
