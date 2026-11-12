# =============================================================================
#  Makefile — Projet 2 : my_calculator
# =============================================================================

NAME        = my_calculator
SRC         = my_calculator.asm
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
