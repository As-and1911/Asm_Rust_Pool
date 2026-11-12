/* =============================================================================
 * Programme de test de validation Minilibc (strlen & strcmp)
 * Compare les résultats des fonctions assembleur avec la glibc
 * ============================================================================= */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

// Déclarations des fonctions assembleur externes
extern size_t my_strlen(const char *s);
extern int    my_strcmp(const char *s1, const char *s2);

int test_strlen(void)
{
    printf("[TEST] Validation my_strlen...\n");

    const char *tests[] = {
        "",
        "a",
        "Hello, World!",
        "Epitech Paris & Marseille 2026",
        "L'assembleur x86_64, c'est puissant et elegant.",
        NULL
    };

    for (int i = 0; tests[i] != NULL; i++) {
        size_t expected = strlen(tests[i]);
        size_t actual   = my_strlen(tests[i]);

        if (expected != actual) {
            fprintf(stderr, "  [FAIL] Pour '%s' : attendu %zu, obtenu %zu\n",
                    tests[i], expected, actual);
            return 1;
        }
    }
    printf("  -> my_strlen : TOUS LES TESTS PASSENT AVEC SUCCES (OK)\n");
    return 0;
}

int test_strcmp(void)
{
    printf("[TEST] Validation my_strcmp...\n");

    struct {
        const char *s1;
        const char *s2;
    } cases[] = {
        {"", ""},
        {"abc", "abc"},
        {"abc", "abd"},
        {"abd", "abc"},
        {"hello world", "hello"},
        {"hello", "hello world"},
        {"Epitech", "epitech"},
        {NULL, NULL}
    };

    for (int i = 0; cases[i].s1 != NULL; i++) {
        int expected = strcmp(cases[i].s1, cases[i].s2);
        int actual   = my_strcmp(cases[i].s1, cases[i].s2);

        // On vérifie le signe et le zéro
        int sign_expected = (expected > 0) - (expected < 0);
        int sign_actual   = (actual > 0) - (actual < 0);

        if (sign_expected != sign_actual) {
            fprintf(stderr, "  [FAIL] Pour ('%s', '%s') : attendu signe %d, obtenu signe %d\n",
                    cases[i].s1, cases[i].s2, sign_expected, sign_actual);
            return 1;
        }
    }
    printf("  -> my_strcmp : TOUS LES TESTS PASSENT AVEC SUCCES (OK)\n");
    return 0;
}

int main(void)
{
    if (test_strlen() != 0 || test_strcmp() != 0) {
        return 84;
    }
    printf("\n>>> MINILIBC PART 1 : 100%% DE SUCCES <<<\n");
    return 0;
}
