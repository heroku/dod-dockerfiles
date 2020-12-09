#!/usr/bin/env bash

set -eu -o pipefail

WORKING_DIR=${HOME}
LOCALE_SOURCE_VERSION=$1
TARGET_VERSION=$2
LOCALE_ARCHIVE=/usr/lib/locale/locale-archive

cd "${WORKING_DIR}" || exit && \
apt-get update && apt-get install gnupg python3 vim gcc make gawk wget autoconf g++ git xz-utils bison -y && \
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
git apply --ignore-space-change --ignore-whitespace patch-localecheck.patch && \
mkdir build && cd build && \
../configure --prefix="/opt/glibc-${TARGET_VERSION}-heroku" --disable-werror && \
make -j "$(nproc)" && make install && \
mkdir "/opt/glibc-${TARGET_VERSION}-heroku/lib/locale" && \
"/opt/glibc-${TARGET_VERSION}-heroku"/bin/localedef -i en_US -f UTF-8 /usr/lib/locale/en_US.UTF-8 && \

if [ -f "${LOCALE_ARCHIVE}" ]; then
  rm "${LOCALE_ARCHIVE}"
fi && \

cd "${WORKING_DIR}" || exit && \
rm -rf \
  "glibc-${LOCALE_SOURCE_VERSION}.tar.xz" \
  "glibc-${TARGET_VERSION}.tar.xz" \
  "glibc-${LOCALE_SOURCE_VERSION}" \
  "glibc-${TARGET_VERSION}" \
  "gnu-keyring.gpg" && \
rm -rf /var/lib/apt/lists/*
