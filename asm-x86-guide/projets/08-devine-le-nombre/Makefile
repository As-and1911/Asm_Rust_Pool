# =============================================================================
#  Makefile — Projet 8 : guess_number
# =============================================================================

NAME        = guess_number
SRC         = guess_number.asm
OBJ         = $(SRC:.asm=.o)

ASM         = nasm
ASMFLAGS    = -f elf64 -g -F dwarf
LD          = ld

all: $(NAME)

$(NAME): $(OBJ)
	$(LD) $< -o $@

$(OBJ): $(SRC)
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
