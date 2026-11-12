#!/bin/bash
# =============================================================================
#  Tests moulinette — Niveau 2 : Chapitre 4 (Arithmétique, RFLAGS, LEA)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../tests/test_framework.sh"

begin_tests "Niveau 2 — Arithmétique Machine & Drapeaux"
EX_DIR="$SCRIPT_DIR"

compile_and_check_code() {
    local file="$1"
    local desc="$2"
    local expected_code="$3"

    local base="${file%.asm}"
    if [ -f "$EX_DIR/$file" ]; then
        nasm -f elf64 "$EX_DIR/$file" -o "$EX_DIR/$base.o" 2>/dev/null && \
        ld "$EX_DIR/$base.o" -o "$EX_DIR/$base" 2>/dev/null
        if [ $? -eq 0 ]; then
            test_exit_code "$desc" "$EX_DIR/$base" "$expected_code"
        else
            TESTS_TOTAL=$((TESTS_TOTAL + 1))
            echo -e "  ${RED}✗ KO${NC}  — Erreur de compilation pour $file"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        echo -e "  ${YELLOW}⊘ SKIP${NC} — $file non trouvé"
    fi
}

compile_and_check_code "ex09_mul_simple.asm" "Ex 02 : MUL simple (6 * 7)" 42
compile_and_check_code "ex10_div_mod.asm" "Ex 03 : Modulo 100 % 7" 2
compile_and_check_code "ex11_lea_math.asm" "Ex 04 : Polynôme LEA (9x + 7 pour x=5)" 52
compile_and_check_code "ex12_idiv_signed.asm" "Ex 05 : Division signée (-50 / 4)" 244
compile_and_check_code "ex13_average.asm" "Ex 06 : Moyenne entière de 3 entiers" 25
compile_and_check_code "ex14_rotations.asm" "Ex 08 : Rotation ROL 0x81 -> 3" 3
compile_and_check_code "ex15_fast_mul15.asm" "Ex 09 : Multiplier par 15 sans MUL" 60
compile_and_check_code "ex16_ascii_to_digit.asm" "Ex 10 : ASCII '7' -> chiffre 7" 7
compile_and_check_code "ex18_power_of_two.asm" "Ex 12 : Test puissance de 2 (N=16)" 1
compile_and_check_code "ex19_gauss_sum.asm" "Ex 13 : Somme de Gauss (n=10)" 55
compile_and_check_code "ex20_sign_extract.asm" "Ex 14 : Extraction de signe sans saut" 1
compile_and_check_code "ex21_add128.asm" "Ex 15 : Addition 128 bits avec ADC" 2

end_tests
