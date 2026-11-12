# =============================================================================
#  Makefile — Projet 6 : Minilibc Complète (libasm.so)
# =============================================================================

NAME        = libasm.so
TEST_BIN    = unit_tests

SRCS        = strlen.asm \
              strchr.asm \
              strrchr.asm \
              memset.asm \
              memcpy.asm \
              memmove.asm \
              strcmp.asm \
              strncmp.asm \
              strcasecmp.asm \
              strstr.asm \
              strpbrk.asm \
              strcspn.asm

OBJS        = $(SRCS:.asm=.o)

ASM         = nasm
ASMFLAGS    = -f elf64 -g -F dwarf
CC          = gcc
CFLAGS      = -Wall -Wextra -g -no-pie

all: $(NAME)

# 1. Compilation des objets en position-indépendant
%.o: %.asm
	$(ASM) $(ASMFLAGS) $< -o $@

# 2. Création de la bibliothèque partagée dynamique (.so)
$(NAME): $(OBJS)
	$(CC) -shared -fPIC $(OBJS) -o $(NAME)

# 3. Compilation de la suite de tests unitaires
test: $(NAME) test_suite.c
	$(CC) $(CFLAGS) test_suite.c -L. -lasm -Wl,-rpath=. -o $(TEST_BIN)
	./$(TEST_BIN)

clean:
	rm -f $(OBJS) test_suite.o

fclean: clean
	rm -f $(NAME) $(TEST_BIN)

re: fclean all

.PHONY: all test clean fclean re
