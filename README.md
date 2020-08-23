# freeradius4

 following arguments can be passed to the builded docker image:\n
   DB_HOST\n
   DB_NAME\n
   DB_USER\n
   DB_PASS\n
   SMTP_SERVER\n
   SMTP_PORT\n
   SMTP_USER\n
   SMTP_PASS\n
   SMTP_ADMIN_EMAIL\n
   SMTP_SENDER_EMAIL\n
   SMTP_SUBJECT\n
   CACHE_TIME\n
   IMAP_TIMEOUT\n
   IMAP_URI\n
   
   you can pass those variables via docker run -e SMTP_SERVER=google.com or set them inside Dockerfile
   


for now  freeradius4 sources has broken module rlm_test which broke all logic ( issue with current github freeradius repo )

CC src/modules/rlm_test/rlm_test.c
src/modules/rlm_test/rlm_test.c: In function 'mod_bootstrap':
src/modules/rlm_test/rlm_test.c:266:46: error: macro "talloc_foreach" passed 3 arguments, but takes just 2
   talloc_foreach(inst->tmpl_m, tmpl_t *, item) INFO("%s", item->name);
                                              ^
src/modules/rlm_test/rlm_test.c:266:3: error: unknown type name 'talloc_foreach'
   talloc_foreach(inst->tmpl_m, tmpl_t *, item) INFO("%s", item->name);
     
