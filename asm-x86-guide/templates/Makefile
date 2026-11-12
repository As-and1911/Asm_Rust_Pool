# =============================================================================
#  Makefile — Template pour projets assembleur x86_64
# =============================================================================
#
#  Utilisation :
#    make          → Assemble et link le programme
#    make run      → Compile et exécute
#    make clean    → Supprime les fichiers générés
#    make re       → Clean + rebuild
#    make debug    → Compile avec symboles de debug et lance gdb
#
# =============================================================================

# --- Configuration ---
NAME    = programme
SRC     = $(NAME).asm
OBJ     = $(NAME).o

# --- Outils ---
ASM     = nasm
ASMFLAGS = -f elf64 -g -F dwarf
LD      = ld
LDFLAGS =

# --- Règles ---
all: $(NAME)

$(NAME): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

$(OBJ): $(SRC)
	$(ASM) $(ASMFLAGS) $< -o $@

run: $(NAME)
	./$(NAME)

debug: ASMFLAGS += -g -F dwarf
debug: $(NAME)
	gdb -q ./$(NAME)

clean:
	rm -f $(OBJ) $(NAME)

re: clean all

.PHONY: all run debug clean re
