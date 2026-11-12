#!/bin/bash
# =============================================================================
#  Moulinette de notation — Projet 2 : Calculatrice Arithmétique
# =============================================================================

PROJ_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$PROJ_DIR/../../tests/test_framework.sh"

begin_tests "Projet 2 — Calculatrice Arithmétique"

cd "$PROJ_DIR" || exit 1

# Helper de compilation paramétrée
compile_with() {
    local a="$1"
    local op="$2"
    local b="$3"
    nasm -f elf64 -DOP_A="$a" -DOP_TYPE="'$op'" -DOP_B="$b" my_calculator.asm -o my_calculator.o 2>/dev/null && \
    ld my_calculator.o -o my_calculator 2>/dev/null
}

echo -e "\n  ${BOLD}[Opérations Arithmétiques de Base]${NC}"

# 1. Multiplication (6 * 7 = 42)
compile_with 6 '*' 7
test_output "Multiplication : 6 * 7" "./my_calculator" "42"
test_exit_code "Multiplication exit code 0" "./my_calculator" 0

# 2. Addition (15 + 27 = 42)
compile_with 15 '+' 27
test_output "Addition : 15 + 27" "./my_calculator" "42"

# 3. Soustraction (50 - 8 = 42)
compile_with 50 '-' 8
test_output "Soustraction : 50 - 8" "./my_calculator" "42"

# 4. Division (85 / 2 = 42)
compile_with 85 '/' 2
test_output "Division entière : 85 / 2" "./my_calculator" "42"

# 5. Modulo (45 % 10 = 5)
compile_with 45 '%' 10
test_output "Modulo : 45 % 10" "./my_calculator" "5"

echo -e "\n  ${BOLD}[Sécurité & Gestion d'Erreur]${NC}"

# 6. Division par Zéro
compile_with 42 '/' 0
ERR_MSG=$(./my_calculator 2>&1 >/dev/null)
test_output "Division par zéro : message sur stderr" "echo -n '$ERR_MSG'" "Error: Division by zero."
test_exit_code "Division par zéro : exit code 84" "./my_calculator" 84

# 7. Modulo par Zéro
compile_with 42 '%' 0
test_exit_code "Modulo par zéro : exit code 84" "./my_calculator" 84

# Nettoyage
rm -f my_calculator my_calculator.o

end_tests
