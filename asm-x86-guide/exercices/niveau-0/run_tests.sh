#!/bin/bash
# =============================================================================
#  Tests moulinette — Niveau 0 : Exercices d'environnement
# =============================================================================
# Utilisation : ./run_tests_niveau0.sh
# Prérequis   : être dans le conteneur Docker asm-x86
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../tests/test_framework.sh"

begin_tests "Niveau 0 — Environnement"

# --- Test 0 : Outils installés ---
echo -e "\n  ${BOLD}[Vérification des outils]${NC}"
test_exit_code "nasm est installé" "which nasm" 0
test_exit_code "ld est installé" "which ld" 0
test_exit_code "gcc est installé" "which gcc" 0
test_exit_code "make est installé" "which make" 0
test_exit_code "objdump est installé" "which objdump" 0
test_exit_code "xxd est installé" "which xxd" 0

# --- Test 1 : Hello World compile ---
echo -e "\n  ${BOLD}[Exercice 1 : Hello World]${NC}"
EX_DIR="$SCRIPT_DIR/../exercices/niveau-0"

if [ -f "$EX_DIR/hello.asm" ]; then
    test_compile "hello.asm compile" "$EX_DIR/hello.asm"
    test_output "hello affiche 'Hello, World!'" "$EX_DIR/hello" "Hello, World!"
    test_exit_code "hello retourne 0" "$EX_DIR/hello" 0
else
    echo -e "  ${YELLOW}⊘ SKIP${NC} — hello.asm non trouvé"
fi

# --- Test 2 : Exercice ex01_mon_nom.asm ---
echo -e "\n  ${BOLD}[Exercice 2 : Afficher ton nom]${NC}"
if [ -f "$EX_DIR/ex01_mon_nom.asm" ]; then
    test_compile "ex01_mon_nom.asm compile" "$EX_DIR/ex01_mon_nom.asm"
    # On vérifie juste que ça produit une sortie non vide
    OUTPUT=$(eval "$EX_DIR/ex01_mon_nom" 2>/dev/null)
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    if [ -n "$OUTPUT" ]; then
        echo -e "  ${GREEN}✓ OK${NC}  — Le programme affiche quelque chose : '$OUTPUT'"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗ KO${NC}  — Le programme n'affiche rien"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
else
    echo -e "  ${YELLOW}⊘ SKIP${NC} — ex01_mon_nom.asm non trouvé (à toi de le créer !)"
fi

# --- Test 3 : Exercice ex02_code_retour.asm ---
echo -e "\n  ${BOLD}[Exercice 3 : Code de retour 42]${NC}"
if [ -f "$EX_DIR/ex02_code_retour.asm" ]; then
    test_compile "ex02_code_retour.asm compile" "$EX_DIR/ex02_code_retour.asm"
    test_exit_code "Le programme retourne 42" "$EX_DIR/ex02_code_retour" 42
else
    echo -e "  ${YELLOW}⊘ SKIP${NC} — ex02_code_retour.asm non trouvé (à toi de le créer !)"
fi

# --- Test 4 : Exercice ex03_multi_lignes.asm ---
echo -e "\n  ${BOLD}[Exercice 4 : Affichage multi-lignes]${NC}"
if [ -f "$EX_DIR/ex03_multi_lignes.asm" ]; then
    test_compile "ex03_multi_lignes.asm compile" "$EX_DIR/ex03_multi_lignes.asm"
    OUTPUT=$(eval "$EX_DIR/ex03_multi_lignes" 2>/dev/null)
    LINES=$(echo "$OUTPUT" | wc -l)
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    if [ "$LINES" -ge 3 ]; then
        echo -e "  ${GREEN}✓ OK${NC}  — Le programme affiche $LINES lignes (minimum 3 attendues)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗ KO${NC}  — Le programme affiche $LINES ligne(s), minimum 3 attendues"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
else
    echo -e "  ${YELLOW}⊘ SKIP${NC} — ex03_multi_lignes.asm non trouvé (à toi de le créer !)"
fi

# --- Test 5 : Exercice ex04_triangle.asm ---
echo -e "\n  ${BOLD}[Exercice 5 : Triangle d'étoiles]${NC}"
if [ -f "$EX_DIR/ex04_triangle.asm" ]; then
    test_compile "ex04_triangle.asm compile" "$EX_DIR/ex04_triangle.asm"
    EXPECTED="*
**
***
****
*****"
    test_output "Le programme affiche un triangle de 5 lignes" "$EX_DIR/ex04_triangle" "$EXPECTED"
else
    echo -e "  ${YELLOW}⊘ SKIP${NC} — ex04_triangle.asm non trouvé (à toi de le créer !)"
fi

# --- Test 6 : Exercice ex05_makefile ---
echo -e "\n  ${BOLD}[Exercice 6 : Makefile]${NC}"
if [ -f "$EX_DIR/Makefile" ]; then
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    # Vérifier que le Makefile contient les cibles attendues
    if grep -q "^all:" "$EX_DIR/Makefile" && grep -q "^clean:" "$EX_DIR/Makefile"; then
        echo -e "  ${GREEN}✓ OK${NC}  — Le Makefile contient les cibles 'all' et 'clean'"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗ KO${NC}  — Le Makefile doit contenir au moins les cibles 'all' et 'clean'"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
else
    echo -e "  ${YELLOW}⊘ SKIP${NC} — Makefile non trouvé (à toi de le créer !)"
fi

end_tests
