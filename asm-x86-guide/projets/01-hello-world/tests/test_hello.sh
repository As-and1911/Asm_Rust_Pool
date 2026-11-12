#!/bin/bash
# =============================================================================
#  Moulinette de notation — Projet 1 : Hello World
# =============================================================================

PROJ_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$PROJ_DIR/../../tests/test_framework.sh"

begin_tests "Projet 1 — Hello World & Dispatcher (Barème /100)"

cd "$PROJ_DIR" || exit 1

# 1. Vérification du Makefile (10 pts)
echo -e "\n  ${BOLD}[Étape 1 : Vérification Makefile]${NC}"
if [ -f "Makefile" ]; then
    make fclean > /dev/null 2>&1
    make all > /dev/null 2>&1
    if [ -f "my_hello" ]; then
        echo -e "  ${GREEN}✓ OK${NC}  — Makefile 'all' compile avec succès (10/10)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗ KO${NC}  — Makefile 'all' n'a pas produit 'my_hello'"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
else
    echo -e "  ${RED}✗ KO${NC}  — Aucun Makefile trouvé"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# 2. Test Jalon 1 : Standard stdout + return 0 (40 pts)
echo -e "\n  ${BOLD}[Étape 2 : Jalon 1 (stdout + return 0)]${NC}"
test_output "my_hello affiche 'Hello, World!' sur stdout" "./my_hello" "Hello, World!"
test_exit_code "my_hello retourne 0" "./my_hello" 0

# Vérifier que rien ne sort sur stderr
STDERR_OUT=$(./my_hello 2>&1 >/dev/null)
TESTS_TOTAL=$((TESTS_TOTAL + 1))
if [ -z "$STDERR_OUT" ]; then
    echo -e "  ${GREEN}✓ OK${NC}  — Rien d'imprimé sur stderr"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "  ${RED}✗ KO${NC}  — Pollution détectée sur stderr"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# 3. Test Jalon 2 : Mode Error stderr + return 84 (30 pts)
echo -e "\n  ${BOLD}[Étape 3 : Jalon 2 (stderr + return 84)]${NC}"
make fclean > /dev/null 2>&1
make error > /dev/null 2>&1

if [ -f "my_hello" ]; then
    ERR_OUT=$(./my_hello 2>&1 >/dev/null)
    test_output "Message d'erreur sur stderr" "echo -n '$ERR_OUT'" "[ERROR] Operation failed successfully."
    test_exit_code "Code de retour 84" "./my_hello" 84
else
    echo -e "  ${RED}✗ KO${NC}  — 'make error' n'a pas produit de binaire"
    TESTS_FAILED=$((TESTS_FAILED + 2))
    TESTS_TOTAL=$((TESTS_TOTAL + 2))
fi

# 4. Nettoyage
make fclean > /dev/null 2>&1

end_tests
