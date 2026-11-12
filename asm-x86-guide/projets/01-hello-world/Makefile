# =============================================================================
#  Makefile — Projet 1 : my_hello
# =============================================================================

NAME        = my_hello
SRC         = my_hello.asm
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

error:
	$(ASM) $(ASMFLAGS) -DERROR_MODE=1 $(SRC) -o $(OBJ)
	$(LD) $(LDFLAGS) $(OBJ) -o $(NAME)

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME) my_hello_banner

re: fclean all

.PHONY: all error clean fclean re
