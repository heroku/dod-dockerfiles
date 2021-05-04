#!/usr/bin/env bash

set -eu -o pipefail

WORKING_DIR=${HOME}
LOCALE_SOURCE_VERSION=$1
TARGET_VERSION=$2

cd "${WORKING_DIR}" || exit && \
wget "https://ftp.gnu.org/gnu/gnu-keyring.gpg" && \
wget "https://ftp.gnu.org/gnu/glibc/glibc-${LOCALE_SOURCE_VERSION}.tar.xz" && \
wget "https://ftp.gnu.org/gnu/glibc/glibc-${LOCALE_SOURCE_VERSION}.tar.xz.sig" && \
wget "https://ftp.gnu.org/gnu/glibc/glibc-${TARGET_VERSION}.tar.xz" && \
wget "https://ftp.gnu.org/gnu/glibc/glibc-${TARGET_VERSION}.tar.xz.sig" && \
gpg --verify --keyring "./gnu-keyring.gpg" "glibc-${LOCALE_SOURCE_VERSION}.tar.xz.sig" || exit 1 && \
gpg --verify --keyring "./gnu-keyring.gpg" "glibc-${TARGET_VERSION}.tar.xz.sig" || exit 1 && \
tar -xf "glibc-${LOCALE_SOURCE_VERSION}.tar.xz" && \
tar -xf "glibc-${TARGET_VERSION}.tar.xz" && \
cp -R "glibc-${LOCALE_SOURCE_VERSION}"/localedata "glibc-${TARGET_VERSION}" && \
cd "glibc-${TARGET_VERSION}" && \
cat > patch-localecheck.patch << "EOF"
diff --git a/locale/programs/ld-identification.c b/locale/programs/ld-identification.c
index df0257b..b82e841 100644
--- a/locale/programs/ld-identification.c
+++ b/locale/programs/ld-identification.c
@@ -194,8 +194,8 @@ No definition for %s category found"), "LC_IDENTIFICATION");
              matched = true;

          if (matched != true)
-           record_error (0, 0, _("\
-%s: unknown standard `%s' for category `%s'"),
+           fprintf (stderr, "[warning] \
+%s: unknown standard `%s' for category `%s'",
                          "LC_IDENTIFICATION",
                          identification->category[num],
                          category_name[num]);
EOF
cat > evil-archive.patch << "EOF"
diff --git a/locale/programs/localedef.c b/locale/programs/localedef.c
index d74c5a34..2c771db5 100644
--- a/locale/programs/localedef.c
+++ b/locale/programs/localedef.c
@@ -519,10 +519,10 @@ construct_output_path (char *path)
       ssize_t n;
       if (normal == NULL)
        n = asprintf (&result, "%s%s/%s%c", output_prefix ?: "",
-                     COMPLOCALEDIR, path, '\0');
+                     "/usr/lib/locale", path, '\0');
       else
        n = asprintf (&result, "%s%s/%.*s%s%s%c",
-                     output_prefix ?: "", COMPLOCALEDIR,
+                     output_prefix ?: "", "/usr/lib/locale",
                      (int) (startp - path), path, normal, endp, '\0');

       if (n < 0)
diff --git a/locale/programs/locarchive.c b/locale/programs/locarchive.c
index dccaf04e..012e1dd4 100644
--- a/locale/programs/locarchive.c
+++ b/locale/programs/locarchive.c
@@ -57,7 +57,7 @@

 extern const char *output_prefix;

-#define ARCHIVE_NAME COMPLOCALEDIR "/locale-archive"
+#define ARCHIVE_NAME "/usr/lib/locale" "/locale-archive"

 static const char *locnames[] =
   {
EOF
git apply --ignore-space-change --ignore-whitespace patch-localecheck.patch && \
git apply --ignore-space-change --ignore-whitespace evil-archive.patch && \
mkdir build && cd build && \
../configure --prefix="/opt/glibc-${TARGET_VERSION}-heroku" --disable-werror && \
make -j "$(nproc)" && make install && \
"/opt/glibc-${TARGET_VERSION}-heroku"/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 && \

cd "${WORKING_DIR}" || exit && \
rm -rf \
  "glibc-${LOCALE_SOURCE_VERSION}.tar.xz" \
  "glibc-${TARGET_VERSION}.tar.xz" \
  "glibc-${LOCALE_SOURCE_VERSION}" \
  "glibc-${TARGET_VERSION}" \
  "gnu-keyring.gpg" && \
rm -rf *.xz.sig && \
rm -rf /var/lib/apt/lists/*
