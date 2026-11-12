/* =============================================================================
 * Banc de Tests Unitaires — Minilibc Complète (12 Fonctions)
 * ============================================================================= */

#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include <assert.h>

// Déclarations de nos 12 fonctions asm
extern size_t strlen(const char *s);
extern char  *strchr(const char *s, int c);
extern char  *strrchr(const char *s, int c);
extern void  *memset(void *s, int c, size_t n);
extern void  *memcpy(void *dest, const void *src, size_t n);
extern void  *memmove(void *dest, const void *src, size_t n);
extern int    strcmp(const char *s1, const char *s2);
extern int    strncmp(const char *s1, const char *s2, size_t n);
extern int    strcasecmp(const char *s1, const char *s2);
extern char  *strstr(const char *haystack, const char *needle);
extern char  *strpbrk(const char *s, const char *accept);
extern size_t strcspn(const char *s, const char *reject);

int main(void)
{
    printf("═══════════════════════════════════════════════════════════\n");
    printf("   VALIDATION OFFICIELLE MINILIBC (12 FONCTIONS X86_64)    \n");
    printf("═══════════════════════════════════════════════════════════\n\n");

    // 1. strlen
    assert(strlen("") == 0);
    assert(strlen("Epitech") == 7);
    printf("  [✓] 1. strlen : OK\n");

    // 2. strchr
    char str[] = "Hello World";
    assert(strchr(str, 'W') == &str[6]);
    assert(strchr(str, 'z') == NULL);
    printf("  [✓] 2. strchr : OK\n");

    // 3. strrchr
    char str2[] = "banana";
    assert(strrchr(str2, 'a') == &str2[5]);
    assert(strrchr(str2, 'x') == NULL);
    printf("  [✓] 3. strrchr : OK\n");

    // 4. memset
    char buf_set[10];
    memset(buf_set, 'A', 5);
    buf_set[5] = '\0';
    assert(strcmp(buf_set, "AAAAA") == 0);
    printf("  [✓] 4. memset : OK\n");

    // 5. memcpy
    char src[] = "Copy Me";
    char dst[20];
    memcpy(dst, src, 8);
    assert(strcmp(dst, "Copy Me") == 0);
    printf("  [✓] 5. memcpy : OK\n");

    // 6. memmove (avec chevauchement / overlap)
    char overlap[] = "1234567890";
    memmove(overlap + 2, overlap, 5); // Déplacement vers la droite : "1212345890"
    assert(memcmp(overlap, "1212345890", 10) == 0);
    printf("  [✓] 6. memmove (Overlap test) : OK\n");

    // 7. strcmp
    assert(strcmp("abc", "abc") == 0);
    assert(strcmp("abc", "abd") < 0);
    assert(strcmp("abd", "abc") > 0);
    printf("  [✓] 7. strcmp : OK\n");

    // 8. strncmp
    assert(strncmp("abcdef", "abcxyz", 3) == 0);
    assert(strncmp("abcdef", "abcxyz", 4) < 0);
    printf("  [✓] 8. strncmp : OK\n");

    // 9. strcasecmp
    assert(strcasecmp("Hello", "hElLo") == 0);
    assert(strcasecmp("apple", "Banana") < 0);
    printf("  [✓] 9. strcasecmp : OK\n");

    // 10. strstr
    char text[] = "The quick brown fox";
    assert(strstr(text, "brown") == &text[10]);
    assert(strstr(text, "cat") == NULL);
    assert(strstr(text, "") == text);
    printf("  [✓] 10. strstr : OK\n");

    // 11. strpbrk
    char sample[] = "hello 123";
    assert(strpbrk(sample, "321") == &sample[6]);
    assert(strpbrk(sample, "xyz") == NULL);
    printf("  [✓] 11. strpbrk : OK\n");

    // 12. strcspn
    assert(strcspn("fcba73", "1234567890") == 4);
    assert(strcspn("hello", "xyz") == 5);
    printf("  [✓] 12. strcspn : OK\n");

    printf("\n═══════════════════════════════════════════════════════════\n");
    printf("   RÉSULTAT : LES 12 FONCTIONS SONT 100%% FONCTIONNELLES !  \n");
    printf("═══════════════════════════════════════════════════════════\n");
    return 0;
}
