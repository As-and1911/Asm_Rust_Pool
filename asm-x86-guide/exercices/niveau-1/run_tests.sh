#!/bin/bash
# =============================================================================
#  Tests moulinette — Niveau 1 : Fondations ordinateur & calcul binaire
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../tests/test_framework.sh"

begin_tests "Niveau 1 — Fondations Matérielles & Numération"
EX_DIR="$SCRIPT_DIR"

# Helper de compilation rapide
build_and_test() {
    local name="$1"
    local desc="$2"
    local expected_code="$3"

    if [ -f "$EX_DIR/$name.asm" ]; then
        nasm -f elf64 "$EX_DIR/$name.asm" -o "$EX_DIR/$name.o" 2>/dev/null && \
        ld "$EX_DIR/$name.o" -o "$EX_DIR/$name" 2>/dev/null
        if [ $? -eq 0 ]; then
            test_exit_code "$desc" "$EX_DIR/$name" "$expected_code"
        else
            TESTS_TOTAL=$((TESTS_TOTAL + 1))
            echo -e "  ${RED}✗ KO${NC}  — Erreur de compilation pour $name.asm"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        echo -e "  ${YELLOW}⊘ SKIP${NC} — $name.asm non trouvé"
    fi
}

echo -e "\n  ${BOLD}[Exercices pratiques de calculs bit à bit]${NC}"
build_and_test "ex06_bitwise_and" "Ex 06 : Bitwise AND (attendu: 48)" 48
build_and_test "ex07_shift_mul" "Ex 07 : Multiplication par 10 via SHL/ADD (attendu: 50)" 50
build_and_test "ex08_zeroing" "Ex 08 : Remise à zéro avec XOR (attendu: 0)" 0
build_and_test "ex09_xor_swap" "Ex 09 : Échange XOR sans variable temporaire (attendu: 30)" 30
build_and_test "ex10_parity" "Ex 10 : Détection de parité avec masque (attendu: 1)" 1
build_and_test "ex11_twos_complement" "Ex 11 : Complément à deux manuel (attendu: -10 mod 256 = 246)" 246
build_and_test "ex13_extract_byte" "Ex 13 : Extraction Little-Endian (attendu: 51)" 51
build_and_test "ex14_permission_flags" "Ex 14 : Gestion de flags de permission (attendu: 4)" 4
build_and_test "ex15_popcount_manual" "Ex 15 : Comptage de bits à un manuel (attendu: 4)" 4

end_tests
