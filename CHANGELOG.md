# 1.2.0.beta1

* JRuby support: native Java extension (`-java` gem variant) [#30]
* Fix: missing salt size cap guard (`saltlen > 1<<20`) in Java implementation to match C behavior [#30]
* Fix: memory leak on error state in C extension [#34]
* Sync `bcrypt_pbkdf.c` (v1.13→v1.17) and `blowfish.c` (v1.19→v1.20) from OpenBSD [#36]
* Sync `blf.h` to OpenBSD v1.8, drop advertising clause [#38]
* Fix compatibility with minitest 6 [#28]

# 1.1.2

* Add Ruby 3.4 support [#26]

# 1.1.1

* Fix cross-compile and native gem publishing [#22]
* Fix compile on Windows (missing bzero)
* Replace Travis CI with GitHub Actions
* Minitest 5.19 compatibility [#21]

# 1.1.0

* Ruby 3.0 support
* Support rubies 2.0–2.7 in Windows cross-compile
* Fix inline static function declarations [#15]
* Add Linux on Power (ppc64) support [#11]
* Use size_t for xmalloc [#7]
* Fix gem summary typo [#9]

# 1.0.1

* Fix compile on Solarish platforms [#3]
* Drop rbnacl test dependency, use native OpenSSL instead [#6]
* Fix spelling in source [#2]

# 1.0.0

* Initial release