# =============================================================================
#  CORRECTION — Exercice 5 : Makefile pour le niveau 0
# =============================================================================
#
#  Ce Makefile compile tous les fichiers .asm du répertoire courant.
#
# =============================================================================

ASM      = nasm
ASMFLAGS = -f elf64 -g -F dwarf
LD       = ld

# Trouver tous les fichiers .asm
SRCS     = $(wildcard *.asm)
OBJS     = $(SRCS:.asm=.o)
BINS     = $(SRCS:.asm=)

all: $(BINS)

# Règle générique : .asm → .o → exécutable
%: %.asm
	$(ASM) $(ASMFLAGS) $< -o $@.o
	$(LD) $@.o -o $@

clean:
	rm -f $(OBJS) $(BINS)

re: clean all

.PHONY: all clean re
