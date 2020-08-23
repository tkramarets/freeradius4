# freeradius4

for now  freeradius4 sources has broken module rlm_test which broke all logic
CC src/modules/rlm_test/rlm_test.c
src/modules/rlm_test/rlm_test.c: In function 'mod_bootstrap':
src/modules/rlm_test/rlm_test.c:266:46: error: macro "talloc_foreach" passed 3 arguments, but takes just 2
   talloc_foreach(inst->tmpl_m, tmpl_t *, item) INFO("%s", item->name);
                                              ^
src/modules/rlm_test/rlm_test.c:266:3: error: unknown type name 'talloc_foreach'
   talloc_foreach(inst->tmpl_m, tmpl_t *, item) INFO("%s", item->name);
   ^~~~~~~~~~~~~~
In file included from src/freeradius-devel/server/request.h:45:0,
                 from src/freeradius-devel/server/auth.h:31,
                 from src/freeradius-devel/server/base.h:29,
                 from src/modules/rlm_test/rlm_test.c:29:
src/freeradius-devel/server/log.h:130:19: error: expected declaration specifiers or '...' before '&' token
 #  define LOG_DST &default_log
                   ^
src/freeradius-devel/server/log.h:132:45: note: in expansion of macro 'LOG_DST'
 #define _FR_LOG_DST(_lvl, _fmt, ...) fr_log(LOG_DST, _lvl, __FILE__, __LINE__, _fmt, ## __VA_ARGS__)
                                             ^~~~~~~
src/freeradius-devel/server/log.h:150:43: note: in expansion of macro '_FR_LOG_DST'
 #  define _FR_LOG_PREFIX(_lvl, _fmt, ...) _FR_LOG_DST(_lvl, LOG_PREFIX _fmt, ## __VA_ARGS__)
                                           ^~~~~~~~~~~
src/freeradius-devel/server/log.h:174:26: note: in expansion of macro '_FR_LOG_PREFIX'
 #define INFO(_fmt, ...)  _FR_LOG_PREFIX(L_INFO, _fmt, ## __VA_ARGS__)
                          ^~~~~~~~~~~~~~
src/modules/rlm_test/rlm_test.c:266:48: note: in expansion of macro 'INFO'
   talloc_foreach(inst->tmpl_m, tmpl_t *, item) INFO("%s", item->name);
                                                ^~~~
src/freeradius-devel/server/log.h:174:41: error: expected declaration specifiers or '...' before 'L_INFO'
 #define INFO(_fmt, ...)  _FR_LOG_PREFIX(L_INFO, _fmt, ## __VA_ARGS__)
                                         ^
src/freeradius-devel/server/log.h:132:54: note: in definition of macro '_FR_LOG_DST'
 #define _FR_LOG_DST(_lvl, _fmt, ...) fr_log(LOG_DST, _lvl, __FILE__, __LINE__, _fmt, ## __VA_ARGS__)
                                                      ^~~~
src/freeradius-devel/server/log.h:174:26: note: in expansion of macro '_FR_LOG_PREFIX'
 #define INFO(_fmt, ...)  _FR_LOG_PREFIX(L_INFO, _fmt, ## __VA_ARGS__)
                          ^~~~~~~~~~~~~~
src/modules/rlm_test/rlm_test.c:266:48: note: in expansion of macro 'INFO'
   talloc_foreach(inst->tmpl_m, tmpl_t *, item) INFO("%s", item->name);
                                                ^~~~
src/modules/rlm_test/rlm_test.c:266:69: error: expected declaration specifiers or '...' before string constant
   talloc_foreach(inst->tmpl_m, tmpl_t *, item) INFO("%s", item->name);
                                                                     ^
src/modules/rlm_test/rlm_test.c:266:69: error: expected declaration specifiers or '...' before numeric constant
   talloc_foreach(inst->tmpl_m, tmpl_t *, item) INFO("%s", item->name);
                                                                     ^
src/modules/rlm_test/rlm_test.c:27:20: error: expected declaration specifiers or '...' before string constant
 #define LOG_PREFIX "rlm_test - "
                    ^
src/freeradius-devel/server/log.h:132:80: note: in definition of macro '_FR_LOG_DST'
 #define _FR_LOG_DST(_lvl, _fmt, ...) fr_log(LOG_DST, _lvl, __FILE__, __LINE__, _fmt, ## __VA_ARGS__)
                                                                                ^~~~
src/freeradius-devel/server/log.h:150:61: note: in expansion of macro 'LOG_PREFIX'
 #  define _FR_LOG_PREFIX(_lvl, _fmt, ...) _FR_LOG_DST(_lvl, LOG_PREFIX _fmt, ## __VA_ARGS__)
                                                             ^~~~~~~~~~
src/freeradius-devel/server/log.h:174:26: note: in expansion of macro '_FR_LOG_PREFIX'
 #define INFO(_fmt, ...)  _FR_LOG_PREFIX(L_INFO, _fmt, ## __VA_ARGS__)
                          ^~~~~~~~~~~~~~
src/modules/rlm_test/rlm_test.c:266:48: note: in expansion of macro 'INFO'
   talloc_foreach(inst->tmpl_m, tmpl_t *, item) INFO("%s", item->name);
                                                ^~~~
src/modules/rlm_test/rlm_test.c:266:59: error: unknown type name 'item'
   talloc_foreach(inst->tmpl_m, tmpl_t *, item) INFO("%s", item->name);
                                                           ^
src/freeradius-devel/server/log.h:132:89: note: in definition of macro '_FR_LOG_DST'
 #define _FR_LOG_DST(_lvl, _fmt, ...) fr_log(LOG_DST, _lvl, __FILE__, __LINE__, _fmt, ## __VA_ARGS__)
                                                                                         ^~~~~~~~~~~
src/freeradius-devel/server/log.h:174:26: note: in expansion of macro '_FR_LOG_PREFIX'
 #define INFO(_fmt, ...)  _FR_LOG_PREFIX(L_INFO, _fmt, ## __VA_ARGS__)
                          ^~~~~~~~~~~~~~
src/modules/rlm_test/rlm_test.c:266:48: note: in expansion of macro 'INFO'
   talloc_foreach(inst->tmpl_m, tmpl_t *, item) INFO("%s", item->name);
                                                ^~~~
make[2]: *** [build/objs/src/modules/rlm_test/rlm_test.lo] Error 1
scripts/boiler.mk:704: recipe for target 'build/objs/src/modules/rlm_test/rlm_test.lo' failed
make[2]: Leaving directory '/usr/local/src/repositories/freeradius-server'
debian/rules:125: recipe for target 'build-arch-stamp' failed
