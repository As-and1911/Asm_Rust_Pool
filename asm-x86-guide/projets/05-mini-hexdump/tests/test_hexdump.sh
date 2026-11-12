#!/bin/bash
# =============================================================================
#  Moulinette de notation — Projet 5 : my_hexdump
# =============================================================================

PROJ_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$PROJ_DIR/../../tests/test_framework.sh"

begin_tests "Projet 5 — Visualisateur Hexadécimal (my_hexdump)"

cd "$PROJ_DIR" || exit 1

make fclean > /dev/null 2>&1
make all > /dev/null 2>&1

echo -n "Hello, World!" > test_hex.txt

echo -e "\n  ${BOLD}[Comparaison hexdump standard]${NC}"
# Vérification du binaire
if [ -f "my_hexdump" ]; then
    OUTPUT=$(./my_hexdump test_hex.txt)
    # Vérifier la présence des octets 48 65 6c 6c 6f et de |Hello, World!|
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    if echo "$OUTPUT" | grep -q "48 65 6c 6c 6f" && echo "$OUTPUT" | grep -q "|Hello, World!|"; then
        echo -e "  ${GREEN}✓ OK${NC}  — Format hexadécimal et colonne ASCII conformes"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗ KO${NC}  — Sortie non conforme"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi

    # Vérification fichier inexistant -> retour 84
    test_exit_code "Fichier inexistant (retour 84)" "./my_hexdump non_existant.bin" 84
else
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -e "  ${RED}✗ KO${NC}  — my_hexdump n'a pas été produit"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

rm -f test_hex.txt
make fclean > /dev/null 2>&1

end_tests
