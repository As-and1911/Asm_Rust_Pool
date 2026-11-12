# =============================================================================
#  Makefile — Projet 3 : Minilibc (strlen & strcmp)
# =============================================================================

NAME        = test_minilibc
LIBNAME     = libasm.a

SRCS_ASM    = my_strlen.asm my_strcmp.asm
OBJS_ASM    = $(SRCS_ASM:.asm=.o)

SRCS_C      = main_test.c
OBJS_C      = $(SRCS_C:.c=.o)

ASM         = nasm
ASMFLAGS    = -f elf64 -g -F dwarf
CC          = gcc
CFLAGS      = -Wall -Wextra -g -no-pie

all: $(NAME)

# 1. Assemblage des fichiers NASM
%.o: %.asm
	$(ASM) $(ASMFLAGS) $< -o $@

# 2. Création de la bibliothèque statique
$(LIBNAME): $(OBJS_ASM)
	ar rcs $(LIBNAME) $(OBJS_ASM)

# 3. Compilation du binaire de test unitaire en liant avec la lib
$(NAME): $(LIBNAME) $(SRCS_C)
	$(CC) $(CFLAGS) $(SRCS_C) -L. -lasm -o $(NAME)

clean:
	rm -f $(OBJS_ASM) $(OBJS_C)

fclean: clean
	rm -f $(NAME) $(LIBNAME)

re: fclean all

.PHONY: all clean fclean re
