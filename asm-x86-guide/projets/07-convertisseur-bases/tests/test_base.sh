#!/bin/bash
# =============================================================================
#  Moulinette de notation — Projet 7 : my_base_converter
# =============================================================================

PROJ_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$PROJ_DIR/../../tests/test_framework.sh"

begin_tests "Projet 7 — Convertisseur de Bases Universel"

cd "$PROJ_DIR" || exit 1

make fclean > /dev/null 2>&1
make all > /dev/null 2>&1

test_output "Base 10 -> Base 16 : 42 en hexa" "./my_base_converter '42' '10' '16'" "2a"
test_output "Base 2 -> Base 10 : 101010 en décimal" "./my_base_converter '101010' '2' '10'" "42"
test_output "Base 16 -> Base 2 : 2A en binaire" "./my_base_converter '2A' '16' '2'" "101010"
test_output "Base 10 -> Base 8 : 42 en octal" "./my_base_converter '42' '10' '8'" "52"
test_exit_code "Base invalide (retour 84)" "./my_base_converter '42' '7' '10'" 84
test_exit_code "Nombre d'arguments invalide (retour 84)" "./my_base_converter '42'" 84

make fclean > /dev/null 2>&1

end_tests
