# =============================================================================
#  Makefile — Projet 5 : my_hexdump
# =============================================================================

NAME        = my_hexdump
SRC         = my_hexdump.asm
OBJ         = $(SRC:.asm=.o)

ASM         = nasm
ASMFLAGS    = -f elf64 -g -F dwarf
LD          = ld
LDFLAGS     =

all: $(NAME)

$(NAME): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

$(OBJ): $(SRC)
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
