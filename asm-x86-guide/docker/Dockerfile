# =============================================================================
#  Dockerfile — Environnement x86_64 pour l'apprentissage de l'assembleur
#  Cible : linux/amd64 (émulé via Rosetta ou QEMU sur Apple Silicon)
# =============================================================================
#
#  Construction :
#    docker build --platform linux/amd64 -t asm-x86 ./docker
#
#  Lancement :
#    docker run --platform linux/amd64 -it --rm \
#      --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
#      -v "$(pwd)":/workspace \
#      -w /workspace \
#      asm-x86
#
# =============================================================================

FROM --platform=linux/amd64 ubuntu:22.04

LABEL maintainer="asm-x86-guide"
LABEL description="Environnement x86_64 pour apprendre l'assembleur (NASM/GCC/GDB)"

# Éviter les prompts interactifs pendant l'installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Installation des outils essentiels
RUN apt-get update && apt-get install -y --no-install-recommends \
    # --- Assembleur et compilation ---
    nasm \
    build-essential \
    gcc \
    binutils \
    # --- Débogage ---
    gdb \
    strace \
    ltrace \
    # --- Outils d'analyse binaire ---
    xxd \
    file \
    # --- Utilitaires ---
    make \
    man-db \
    manpages-dev \
    less \
    vim-tiny \
    nano \
    # --- Pour les projets avancés (interface C) ---
    libc6-dev \
    && rm -rf /var/lib/apt/lists/*

# Créer un alias pratique pour objdump en syntaxe Intel
RUN echo 'alias objdump="objdump -M intel"' >> /root/.bashrc && \
    echo 'alias od="objdump -d -M intel"' >> /root/.bashrc && \
    echo 'alias gdb="gdb -q"' >> /root/.bashrc && \
    echo '' >> /root/.bashrc && \
    echo '# Prompt personnalisé pour savoir qu'\''on est dans le conteneur' >> /root/.bashrc && \
    echo 'export PS1="\[\033[1;34m\][asm-x86]\[\033[0m\] \w $ "' >> /root/.bashrc

# Configurer GDB pour la syntaxe Intel par défaut
RUN echo 'set disassembly-flavor intel' > /root/.gdbinit && \
    echo 'set pagination off' >> /root/.gdbinit && \
    echo 'set confirm off' >> /root/.gdbinit

# Répertoire de travail par défaut
WORKDIR /workspace

# Commande par défaut : shell interactif
CMD ["/bin/bash"]
