#!/bin/bash
# =============================================================================
#  Moulinette de notation — Projet 6 : Minilibc Complète
# =============================================================================

PROJ_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$PROJ_DIR/../../tests/test_framework.sh"

begin_tests "Projet 6 — Minilibc Complète (libasm.so & 12 fonctions)"

cd "$PROJ_DIR" || exit 1

make fclean > /dev/null 2>&1
make all > /dev/null 2>&1

if [ -f "libasm.so" ]; then
    test_exit_code "Compilation de la bibliothèque partagée libasm.so" "file libasm.so | grep -q 'shared object'" 0
    make test > /dev/null 2>&1
    test_exit_code "Exécution du banc de test unitaire des 12 fonctions" "./unit_tests" 0
else
    TESTS_TOTAL=$((TESTS_TOTAL + 2))
    echo -e "  ${RED}✗ KO${NC}  — libasm.so non produite"
    TESTS_FAILED=$((TESTS_FAILED + 2))
fi

make fclean > /dev/null 2>&1

end_tests
