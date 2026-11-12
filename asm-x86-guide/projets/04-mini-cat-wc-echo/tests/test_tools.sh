#!/bin/bash
# =============================================================================
#  Moulinette de notation — Projet 4 : Utilitaires Système Unix
# =============================================================================

PROJ_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$PROJ_DIR/../../tests/test_framework.sh"

begin_tests "Projet 4 — Utilitaires Unix (my_echo, my_cat, my_wc)"

cd "$PROJ_DIR" || exit 1

make fclean > /dev/null 2>&1
make all > /dev/null 2>&1

echo -e "\n  ${BOLD}[Tests my_echo]${NC}"
test_output "my_echo sans argument" "./my_echo" ""
test_output "my_echo avec 1 argument" "./my_echo 'Hello'" "Hello"
test_output "my_echo avec plusieurs arguments" "./my_echo 'Hello' 'World' '42'" "Hello World 42"

echo -e "\n  ${BOLD}[Tests my_cat]${NC}"
# Création d'un fichier de test
echo "Ceci est un fichier de test pour my_cat." > test_file.txt
echo "Ligne 2." >> test_file.txt

test_output "my_cat sur fichier existant" "./my_cat test_file.txt" "$(cat test_file.txt)"
test_output "my_cat sur stdin (pipe)" "cat test_file.txt | ./my_cat" "$(cat test_file.txt)"
test_exit_code "my_cat sur fichier inexistant (retour 84)" "./my_cat inexistant_123.txt" 84

echo -e "\n  ${BOLD}[Tests my_wc]${NC}"
# 2 lignes, nombre d'octets calculé
EXPECTED_LINES=$(wc -l < test_file.txt | tr -d ' ')
EXPECTED_BYTES=$(wc -c < test_file.txt | tr -d ' ')
test_output "my_wc sur fichier" "./my_wc test_file.txt" "$EXPECTED_LINES $EXPECTED_BYTES"

# Nettoyage
rm -f test_file.txt
make fclean > /dev/null 2>&1

end_tests
