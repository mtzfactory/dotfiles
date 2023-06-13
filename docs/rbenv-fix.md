# Ruby environment

## Install

Follow this [link][rbenv]

## Static declaration of 'xxx' follows non-static declaration

[Error fix link][fix-static-declaration]

Save this into a file called my_custom_patch_file.patch

```
diff --git a/configure.ac b/configure.ac
index 2dcebdde9f..b11809c6d5 100644
--- a/configure.ac
+++ b/configure.ac
@@ -191,6 +191,13 @@ AS_CASE(["${build_os}"],
 ],
 [aix*], [
     AC_PATH_TOOL([NM], [nm], [/usr/ccs/bin/nm], [/usr/ccs/bin:$PATH])
+],
+[darwin*], [
+    AS_IF([libtool 2>&1 | grep no_warning_for_no_symbols > /dev/null], [
+        ac_cv_prog_ac_ct_RANLIB=:
+        ac_cv_prog_ac_ct_AR='libtool -static'
+        rb_cv_arflags='-no_warning_for_no_symbols -o'
+    ])
 ])
 AS_CASE(["${target_os}"],
 [cygwin*|mingw*], [
```

Install via rbenv:

```bash
$ export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
$ rbenv install --patch 3.0.2 < /path/to/my_custom_patch_file.patch

Downloading ruby-3.0.2.tar.gz...
-> https://cache.ruby-lang.org/pub/ruby/3.0/ruby-3.0.2.tar.gz
Installing ruby-3.0.2...
patching file configure.ac
ruby-build: using readline from homebrew
Installed ruby-3.0.2 to /Users/asgeo1/.rbenv/versions/3.0.2

$ rbenv local 3.0.2
$ ruby --version
ruby 3.0.2p107 (2021-07-07 revision 0db68f0233) [x86_64-darwin19]
```

## ld: building for macOS-x86_64 but attempting to link with file built for macOS-x86_64

[Error fix link][fix-ld]

Make sure that /usr/bin comes in your `$PATH` before `/usr/local/bin` and `/opt/local/bin`.
When you run `which -a ranlib`, the first result in the list should be `/usr/bin/ranlib`.
Same for `which -a ar` -- the first result should be `/usr/bin/ar`.
If it is not so, you need to fix your `$PATH`.

```bash
$ which -a ranlib
$ which -a ar

$ echo $PATH
```

[rbenv]: https://github.com/rbenv/rbenv#installation
[fix-static-declaration]: https://github.com/rbenv/ruby-build/issues/1505
[fix-ld]: https://stackoverflow.com/questions/70126695/ld-building-for-macos-x86-64-but-attempting-to-link-with-file-built-for-macos-x