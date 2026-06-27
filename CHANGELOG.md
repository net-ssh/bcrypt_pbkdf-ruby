# 1.2.0.beta1

* JRuby support: native Java extension (`-java` gem variant) [#30]
* Fix: missing salt size cap guard (`saltlen > 1<<20`) in Java implementation to match C behavior [#30]
* Fix: memory leak on error state in C extension [#34]
* Sync `bcrypt_pbkdf.c` (v1.13→v1.17) and `blowfish.c` (v1.19→v1.20) from OpenBSD [#36]
* Sync `blf.h` to OpenBSD v1.8, drop advertising clause [#38]
* Fix compatibility with minitest 6 [#28]

# 1.0.0.apha1

  initial version