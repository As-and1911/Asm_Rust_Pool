#!/bin/bash
# =============================================================================
#  Tests moulinette — Niveau 3 : Pile, Fonctions & ABI System V
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../tests/test_framework.sh"

begin_tests "Niveau 3 — Pile, Fonctions et ABI"
EX_DIR="$SCRIPT_DIR"

compile_and_check() {
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

compile_and_check "ex51_func_add.asm" "Ex 02 : Fonction add2 (18 + 24)" 42
compile_and_check "ex52_func_linear.asm" "Ex 03 : Fonction linéaire à 4 paramètres" 26
compile_and_check "ex53_local_vars.asm" "Ex 05 : Variables locales sur la pile" 42
compile_and_check "ex55_eight_args.asm" "Ex 07 : Fonction à 8 paramètres (pile)" 36
compile_and_check "ex56_recursive_fact.asm" "Ex 08 : Factorielle récursive (5!)" 120
compile_and_check "ex57_recursive_fibo.asm" "Ex 09 : Fibonacci récursif (F_6)" 8
compile_and_check "ex63_hanoi_count.asm" "Ex 15 : Tours de Hanoï récursif (N=5)" 31
compile_and_check "ex64_struct_access.asm" "Ex 17 : Accès à une structure Point" 25
compile_and_check "ex65_ackermann.asm" "Ex 18 : Fonction Ackermann A(2, 2)" 7
compile_and_check "ex67_stack_vm.asm" "Ex 20 : Mini machine virtuelle à pile" 26

end_tests
