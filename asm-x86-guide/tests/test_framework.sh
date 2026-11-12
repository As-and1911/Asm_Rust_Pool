#!/bin/bash
# =============================================================================
#  test_framework.sh — Framework de tests « moulinette » pour les exercices
# =============================================================================
#
#  Utilisation dans un script de test :
#    source ../../tests/test_framework.sh
#    begin_tests "Nom du test"
#    test_output "description" "./programme" "sortie attendue"
#    test_exit_code "description" "./programme" 42
#    end_tests
#
# =============================================================================

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Compteurs
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Début des tests
begin_tests() {
    local test_name="$1"
    echo ""
    echo -e "${BOLD}${BLUE}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${BLUE}║  MOULINETTE — ${test_name}${NC}"
    echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Tester la sortie standard d'un programme
# Usage : test_output "description" "commande" "sortie_attendue"
test_output() {
    local description="$1"
    local command="$2"
    local expected="$3"
    local input="$4"  # Optionnel : entrée stdin

    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    local actual
    if [ -n "$input" ]; then
        actual=$(echo -e "$input" | eval "$command" 2>/dev/null)
    else
        actual=$(eval "$command" 2>/dev/null)
    fi

    if [ "$actual" = "$expected" ]; then
        echo -e "  ${GREEN}✓ OK${NC}  — $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗ KO${NC}  — $description"
        echo -e "         ${YELLOW}Attendu :${NC} $(echo "$expected" | head -3)"
        echo -e "         ${YELLOW}Obtenu  :${NC} $(echo "$actual" | head -3)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Tester la sortie standard (avec des octets bruts, sans trailing newline)
# Usage : test_output_raw "description" "commande" "sortie_attendue_hex"
test_output_raw() {
    local description="$1"
    local command="$2"
    local expected="$3"

    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    local actual
    actual=$(eval "$command" 2>/dev/null | xxd -p | tr -d '\n')

    if [ "$actual" = "$expected" ]; then
        echo -e "  ${GREEN}✓ OK${NC}  — $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗ KO${NC}  — $description"
        echo -e "         ${YELLOW}Attendu (hex) :${NC} $expected"
        echo -e "         ${YELLOW}Obtenu  (hex) :${NC} $actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Tester le code de retour d'un programme
# Usage : test_exit_code "description" "commande" code_attendu
test_exit_code() {
    local description="$1"
    local command="$2"
    local expected_code="$3"

    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    eval "$command" > /dev/null 2>&1
    local actual_code=$?

    if [ "$actual_code" -eq "$expected_code" ]; then
        echo -e "  ${GREEN}✓ OK${NC}  — $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗ KO${NC}  — $description"
        echo -e "         ${YELLOW}Code attendu :${NC} $expected_code"
        echo -e "         ${YELLOW}Code obtenu  :${NC} $actual_code"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Tester qu'un fichier compile sans erreur
# Usage : test_compile "description" "fichier.asm"
test_compile() {
    local description="$1"
    local source="$2"
    local output="${source%.asm}"

    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    local compile_output
    compile_output=$(nasm -f elf64 "$source" -o "${output}.o" 2>&1 && \
                     ld "${output}.o" -o "$output" 2>&1)
    local compile_result=$?

    if [ $compile_result -eq 0 ]; then
        echo -e "  ${GREEN}✓ OK${NC}  — $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗ KO${NC}  — $description"
        echo -e "         ${YELLOW}Erreur de compilation :${NC}"
        echo "$compile_output" | head -5 | sed 's/^/         /'
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Tester qu'un fichier compile avec gcc (pour les projets avec la libc)
# Usage : test_compile_gcc "description" "fichier.asm" [flags_gcc_supplémentaires]
test_compile_gcc() {
    local description="$1"
    local source="$2"
    local extra_flags="$3"
    local output="${source%.asm}"

    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    local compile_output
    compile_output=$(nasm -f elf64 "$source" -o "${output}.o" 2>&1 && \
                     gcc ${extra_flags} "${output}.o" -o "$output" -no-pie 2>&1)
    local compile_result=$?

    if [ $compile_result -eq 0 ]; then
        echo -e "  ${GREEN}✓ OK${NC}  — $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗ KO${NC}  — $description"
        echo -e "         ${YELLOW}Erreur de compilation :${NC}"
        echo "$compile_output" | head -5 | sed 's/^/         /'
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Fin des tests — afficher le résumé
end_tests() {
    echo ""
    echo -e "${BOLD}──────────────────────────────────────────────────${NC}"
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${BOLD}${GREEN}  RÉSULTAT : $TESTS_PASSED/$TESTS_TOTAL tests passés ✓${NC}"
    else
        echo -e "${BOLD}${RED}  RÉSULTAT : $TESTS_PASSED/$TESTS_TOTAL tests passés ($TESTS_FAILED échec(s))${NC}"
    fi
    echo -e "${BOLD}──────────────────────────────────────────────────${NC}"
    echo ""

    # Retourner un code d'erreur si des tests ont échoué
    [ $TESTS_FAILED -eq 0 ]
}
