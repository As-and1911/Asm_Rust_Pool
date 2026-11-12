# =============================================================================
#  Makefile — Projet 10 : my_server (Serveur TCP pur assembleur)
# =============================================================================

NAME        = my_server
SRC         = my_server.asm
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
