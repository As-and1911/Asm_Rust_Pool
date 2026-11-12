# =============================================================================
#  Makefile — Projet 4 : Utilitaires Système Unix
# =============================================================================

BINS        = my_echo my_cat my_wc
ASM         = nasm
ASMFLAGS    = -f elf64 -g -F dwarf
LD          = ld
LDFLAGS     =

all: $(BINS)

%: %.asm
	$(ASM) $(ASMFLAGS) $< -o $@.o
	$(LD) $(LDFLAGS) $@.o -o $@

clean:
	rm -f *.o

fclean: clean
	rm -f $(BINS)

re: fclean all

.PHONY: all clean fclean re
