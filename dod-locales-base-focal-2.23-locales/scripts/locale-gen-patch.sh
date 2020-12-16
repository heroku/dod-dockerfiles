#!/usr/bin/env bash

set -eu -o pipefail

TARGET_VERSION=$1

cat > patch-locale-gen.patch << "EOF"
diff --git a/usr/sbin/locale-gen b/usr/sbin/locale-gen
index ff9be29..a16bcbe 100755
--- a/usr/sbin/locale-gen
+++ b/usr/sbin/locale-gen
@@ -172,7 +172,7 @@ echo -e "$GENERATE" | sort -u | while read locale charset; do \
                input=$USER_LOCALES/$input
             fi
        fi
-       localedef $no_archive -i $input -c -f $charset $locale_alias $locale || :; \
+       localedef $no_archive -i $input -c -f $charset $locale_alias "/usr/lib/locale/$locale" || :; \
        echo ' done'; \
 done
 echo "Generation complete."
EOF
git apply --ignore-space-change --ignore-whitespace patch-locale-gen.patch || exit 1

echo "PATH=/opt/glibc-${TARGET_VERSION}-heroku/bin:$PATH" > /etc/environment
