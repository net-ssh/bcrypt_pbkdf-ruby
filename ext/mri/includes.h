#include "blf.h"
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <strings.h>

void explicit_bzero(void *p, size_t n);
int
bcrypt_pbkdf(const char *pass, size_t passlen, const u_int8_t *salt, size_t saltlen,
    u_int8_t *key, size_t keylen, unsigned int rounds);
void bcrypt_hash(const u_int8_t *sha2pass, const u_int8_t *sha2salt, u_int8_t *out);

#define BCRYPT_WORDS 8
#define BCRYPT_HASHSIZE (BCRYPT_WORDS * 4)
