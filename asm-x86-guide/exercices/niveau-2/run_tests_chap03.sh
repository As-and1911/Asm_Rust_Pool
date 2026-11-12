#!/bin/bash
# =============================================================================
#  Tests moulinette — Niveau 2 : Chapitre 3 (Syntaxe, Registres, MOV)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../tests/test_framework.sh"

begin_tests "Niveau 2 — Registres et Instructions de Base"
EX_DIR="$SCRIPT_DIR"

compile_and_run() {
    local file="$1"
    local desc="$2"
    local expected_out="$3"
    local expected_code="$4"
    local is_stderr="$5"

    local base="${file%.asm}"
    if [ -f "$EX_DIR/$file" ]; then
        nasm -f elf64 "$EX_DIR/$file" -o "$EX_DIR/$base.o" 2>/dev/null && \
        ld "$EX_DIR/$base.o" -o "$EX_DIR/$base" 2>/dev/null
        if [ $? -eq 0 ]; then
            if [ -n "$expected_out" ]; then
                if [ "$is_stderr" = "1" ]; then
                    test_output "$desc (stderr)" "$EX_DIR/$base 2>&1 >/dev/null" "$expected_out"
                else
                    test_output "$desc (stdout)" "$EX_DIR/$base" "$expected_out"
                fi
            fi
            if [ -n "$expected_code" ]; then
                test_exit_code "$desc (exit code)" "$EX_DIR/$base" "$expected_code"
            fi
        else
            TESTS_TOTAL=$((TESTS_TOTAL + 1))
            echo -e "  ${RED}✗ KO${NC}  — Erreur de compilation pour $file"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        echo -e "  ${YELLOW}⊘ SKIP${NC} — $file non trouvé"
    fi
}

compile_and_run "ex01_putchar.asm" "Ex 03 : Putchar 'Z'" "Z" 0
compile_and_run "ex02_putstr_err.asm" "Ex 05 : Putstr sur stderr" "Erreur: fichier introuvable." 1 1
compile_and_run "ex03_reg_pack.asm" "Ex 07 : Assemblage de registres" "" 52
compile_and_run "ex05_countdown_static.asm" "Ex 09 : Compte à rebours statique" "3 2 1 0" 0
compile_and_run "ex06_sign_extension.asm" "Ex 10 : Extension signée (-15)" "" 241
compile_and_run "ex07_str_len_equ.asm" "Ex 11 : Longueur de chaîne via EQU" "" 26
compile_and_run "ex08_dynamic_char.asm" "Ex 12 : Caractère calculé ('D')" "D" 0

end_tests
