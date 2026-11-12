#!/bin/bash
# =============================================================================
#  Moulinette de notation — Projet 3 : Minilibc (strlen & strcmp)
# =============================================================================

PROJ_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$PROJ_DIR/../../tests/test_framework.sh"

begin_tests "Projet 3 — Minilibc : strlen & strcmp"

cd "$PROJ_DIR" || exit 1

make fclean > /dev/null 2>&1
make all > /dev/null 2>&1

if [ -f "test_minilibc" ]; then
    test_exit_code "Exécution des tests unitaires C vs libc" "./test_minilibc" 0
else
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -e "  ${RED}✗ KO${NC}  — Échec de compilation de test_minilibc"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

make fclean > /dev/null 2>&1

end_tests
