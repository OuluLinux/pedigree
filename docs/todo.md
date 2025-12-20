# Maestro Development TODO

**Last Updated**: 2025-01-01

---

## Track: Build System Core

- *track_id*: *buildsys-core*
- *priority*: 0
- *status*: *planned*
- *completion*: 0%

Ensure track/phase/task entries can be created, edited, and reorganized from the CLI.
Provide both editor and direct text workflows for quick updates.


---

### Phase bs1: Requirements & CLI Design

- *phase_id*: *bs1*
- *status*: *planned*
- *completion*: 0


- [ ] **bs1.1: Scope build system replacement**

- [ ] **bs1.2: CLI surface for build tool**

- [ ] **bs1.3: Config schema + defaults**

### Phase bs2: Build Graph + Config

- *phase_id*: *bs2*
- *status*: *planned*
- *completion*: 0


- [ ] **bs2.1: Build graph model**

- [ ] **bs2.2: USE flags design**

- [ ] **bs2.3: Target selection + profiles**

### Phase bs3: Execution Engine + Logging

- *phase_id*: *bs3*
- *status*: *planned*
- *completion*: 0


- [ ] **bs3.1: Planner + executor pipeline**

- [ ] **bs3.2: Incremental builds + artifacts**

- [ ] **bs3.3: Logging + diagnostics**

## Track: Portage-Compatible Ebuilds

- *track_id*: *ebuilds*
- *priority*: 0
- *status*: *planned*
- *completion*: 0%

Ensure track/phase/task entries can be created, edited, and reorganized from the CLI.
Provide both editor and direct text workflows for quick updates.


---

### Phase eb1: Repo Layout + Metadata

- *phase_id*: *eb1*
- *status*: *planned*
- *completion*: 0


- [ ] **eb1.1: Repo layout aligned with portage**

- [ ] **eb1.2: Ebuild naming + manifest rules**

- [ ] **eb1.3: Pedigree repo overlay structure**

### Phase eb2: Ebuild Parser + Model

- *phase_id*: *eb2*
- *status*: *planned*
- *completion*: 0


- [ ] **eb2.1: Ebuild parser**

- [ ] **eb2.2: Metadata model + cache**

- [ ] **eb2.3: Ebuild execution hooks**

### Phase eb3: Dependency Resolution + USE Flags

- *phase_id*: *eb3*
- *status*: *planned*
- *completion*: 0


- [ ] **eb3.1: Dependency solver**

- [ ] **eb3.2: USE flag evaluation**

- [ ] **eb3.3: Profile + keyword handling**

## Track: Kernel + Prereqs + PUP Pipeline 🚧 **[In Progress]**

- *track_id*: *build-pipeline*
- *priority*: 0
- *status*: *in_progress*
- *completion*: 0%
- *status_summary*: *Status badge sync*
- *status_changed*: *2025-12-20T22:43:57*

Ensure track/phase/task entries can be created, edited, and reorganized from the CLI.
Provide both editor and direct text workflows for quick updates.

### Phase bp1: Toolchain + Prereqs

- *phase_id*: *bp1*
- *status*: *planned*
- *completion*: 0


- [ ] **bp1.1: Toolchain bootstrap flow**

- [ ] **bp1.2: Prerequisite packages as ebuilds**

- [ ] **bp1.3: Source fetch + cache**

### Phase bp2: Kernel Build Integration

- *phase_id*: *bp2*
- *status*: *planned*
- *completion*: 0


- [ ] **bp2.1: Kernel config generation**

- [ ] **bp2.2: Kernel build steps**

- [ ] **bp2.3: Kernel artifact packaging**

### Phase bp3: PUP Packages Integration 🚧 **[In Progress]**

- *phase_id*: *bp3*
- *status*: *in_progress*
- *completion*: 0
- *status_summary*: *Status badge sync*
- *status_changed*: *2025-12-20T22:43:46*


- [ ] **bp3.1: PUP package inventory**

- [ ] **bp3.2: PUP ebuild templates**

- [ ] **bp3.3: PUP pipeline integration**

- [x] **bp3.4: PUP ebuild: apache2**
  - Package file: ../pedigree-apps/packages/apache2/package.py

- [ ] **bp3.5: PUP ebuild: apr**
  - Package file: ../pedigree-apps/packages/apr/package.py

- [ ] **bp3.6: PUP ebuild: atk**
  - Package file: ../pedigree-apps/packages/atk/package.py

- [ ] **bp3.7: PUP ebuild: autoconf**
  - Package file: ../pedigree-apps/packages/autoconf/package.py

- [ ] **bp3.8: PUP ebuild: bash**
  - Package file: ../pedigree-apps/packages/bash/package.py

- [ ] **bp3.9: PUP ebuild: bind**
  - Package file: ../pedigree-apps/packages/bind/package.py

- [ ] **bp3.10: PUP ebuild: binutils**
  - Package file: ../pedigree-apps/packages/binutils/package.py

- [ ] **bp3.11: PUP ebuild: bsdtar**
  - Package file: ../pedigree-apps/packages/bsdtar/package.py

- [ ] **bp3.12: PUP ebuild: cairo**
  - Package file: ../pedigree-apps/packages/cairo/package.py

- [ ] **bp3.13: PUP ebuild: coreutils**
  - Package file: ../pedigree-apps/packages/coreutils/package.py

- [ ] **bp3.14: PUP ebuild: curl**
  - Package file: ../pedigree-apps/packages/curl/package.py

- [ ] **bp3.15: PUP ebuild: dialog**
  - Package file: ../pedigree-apps/packages/dialog/package.py

- [ ] **bp3.16: PUP ebuild: diffutils**
  - Package file: ../pedigree-apps/packages/diffutils/package.py

- [ ] **bp3.17: PUP ebuild: dosbox**
  - Package file: ../pedigree-apps/packages/dosbox/package.py

- [ ] **bp3.18: PUP ebuild: dropbear**
  - Package file: ../pedigree-apps/packages/dropbear/package.py

- [ ] **bp3.19: PUP ebuild: e2fsprogs**
  - Package file: ../pedigree-apps/packages/e2fsprogs/package.py

- [ ] **bp3.20: PUP ebuild: expat**
  - Package file: ../pedigree-apps/packages/expat/package.py

- [ ] **bp3.21: PUP ebuild: fontconfig**
  - Package file: ../pedigree-apps/packages/fontconfig/package.py

- [ ] **bp3.22: PUP ebuild: fuse**
  - Package file: ../pedigree-apps/packages/fuse/package.py

- [ ] **bp3.23: PUP ebuild: gawk**
  - Package file: ../pedigree-apps/packages/gawk/package.py

- [ ] **bp3.24: PUP ebuild: gcc**
  - Package file: ../pedigree-apps/packages/gcc/package.py

- [ ] **bp3.25: PUP ebuild: gdbm**
  - Package file: ../pedigree-apps/packages/gdbm/package.py

- [ ] **bp3.26: PUP ebuild: gettext**
  - Package file: ../pedigree-apps/packages/gettext/package.py

- [ ] **bp3.27: PUP ebuild: git**
  - Package file: ../pedigree-apps/packages/git/package.py

- [ ] **bp3.28: PUP ebuild: glib**
  - Package file: ../pedigree-apps/packages/glib/package.py

- [ ] **bp3.29: PUP ebuild: gnumake**
  - Package file: ../pedigree-apps/packages/gnumake/package.py

- [ ] **bp3.30: PUP ebuild: grep**
  - Package file: ../pedigree-apps/packages/grep/package.py

- [ ] **bp3.31: PUP ebuild: grub2**
  - Package file: ../pedigree-apps/packages/grub2/package.py

- [ ] **bp3.32: PUP ebuild: gzip**
  - Package file: ../pedigree-apps/packages/gzip/package.py

- [ ] **bp3.33: PUP ebuild: harfbuzz**
  - Package file: ../pedigree-apps/packages/harfbuzz/package.py

- [ ] **bp3.34: PUP ebuild: inetutils**
  - Package file: ../pedigree-apps/packages/inetutils/package.py

- [ ] **bp3.35: PUP ebuild: less**
  - Package file: ../pedigree-apps/packages/less/package.py

- [ ] **bp3.36: PUP ebuild: libbind**
  - Package file: ../pedigree-apps/packages/libbind/package.py

- [ ] **bp3.37: PUP ebuild: libffi**
  - Package file: ../pedigree-apps/packages/libffi/package.py

- [ ] **bp3.38: PUP ebuild: libfreetype**
  - Package file: ../pedigree-apps/packages/libfreetype/package.py

- [ ] **bp3.39: PUP ebuild: libgmp**
  - Package file: ../pedigree-apps/packages/libgmp/package.py

- [ ] **bp3.40: PUP ebuild: libiconv**
  - Package file: ../pedigree-apps/packages/libiconv/package.py

- [ ] **bp3.41: PUP ebuild: libmpc**
  - Package file: ../pedigree-apps/packages/libmpc/package.py

- [ ] **bp3.42: PUP ebuild: libmpfr**
  - Package file: ../pedigree-apps/packages/libmpfr/package.py

- [ ] **bp3.43: PUP ebuild: libpcre**
  - Package file: ../pedigree-apps/packages/libpcre/package.py

- [ ] **bp3.44: PUP ebuild: libpipeline**
  - Package file: ../pedigree-apps/packages/libpipeline/package.py

- [ ] **bp3.45: PUP ebuild: libpng**
  - Package file: ../pedigree-apps/packages/libpng/package.py

- [ ] **bp3.46: PUP ebuild: libtool**
  - Package file: ../pedigree-apps/packages/libtool/package.py

- [ ] **bp3.47: PUP ebuild: llvm**
  - Package file: ../pedigree-apps/packages/llvm/package.py

- [ ] **bp3.48: PUP ebuild: lua**
  - Package file: ../pedigree-apps/packages/lua/package.py

- [ ] **bp3.49: PUP ebuild: lynx**
  - Package file: ../pedigree-apps/packages/lynx/package.py

- [ ] **bp3.50: PUP ebuild: m4**
  - Package file: ../pedigree-apps/packages/m4/package.py

- [ ] **bp3.51: PUP ebuild: man-db**
  - Package file: ../pedigree-apps/packages/man-db/package.py

- [ ] **bp3.52: PUP ebuild: mesa**
  - Package file: ../pedigree-apps/packages/mesa/package.py

- [ ] **bp3.53: PUP ebuild: mtools**
  - Package file: ../pedigree-apps/packages/mtools/package.py

- [ ] **bp3.54: PUP ebuild: nano**
  - Package file: ../pedigree-apps/packages/nano/package.py

- [ ] **bp3.55: PUP ebuild: nasm**
  - Package file: ../pedigree-apps/packages/nasm/package.py

- [ ] **bp3.56: PUP ebuild: ncurses**
  - Package file: ../pedigree-apps/packages/ncurses/package.py

- [ ] **bp3.57: PUP ebuild: netsurf**
  - Package file: ../pedigree-apps/packages/netsurf/package.py

- [ ] **bp3.58: PUP ebuild: newlib**
  - Package file: ../pedigree-apps/packages/newlib/package.py

- [ ] **bp3.59: PUP ebuild: openssl**
  - Package file: ../pedigree-apps/packages/openssl/package.py

- [ ] **bp3.60: PUP ebuild: pango**
  - Package file: ../pedigree-apps/packages/pango/package.py

- [ ] **bp3.61: PUP ebuild: pedigree-base**
  - Package file: ../pedigree-apps/packages/pedigree-base/package.py

- [ ] **bp3.62: PUP ebuild: pedigree-devel**
  - Package file: ../pedigree-apps/packages/pedigree-devel/package.py

- [ ] **bp3.63: PUP ebuild: pedigree-kernel**
  - Package file: ../pedigree-apps/packages/pedigree-kernel/package.py

- [ ] **bp3.64: PUP ebuild: pedigree-modules**
  - Package file: ../pedigree-apps/packages/pedigree-modules/package.py

- [ ] **bp3.65: PUP ebuild: perl**
  - Package file: ../pedigree-apps/packages/perl/package.py

- [ ] **bp3.66: PUP ebuild: pixman**
  - Package file: ../pedigree-apps/packages/pixman/package.py

- [ ] **bp3.67: PUP ebuild: prboom**
  - Package file: ../pedigree-apps/packages/prboom/package.py

- [ ] **bp3.68: PUP ebuild: pth**
  - Package file: ../pedigree-apps/packages/pth/package.py

- [ ] **bp3.69: PUP ebuild: pup**
  - Package file: ../pedigree-apps/packages/pup/package.py

- [ ] **bp3.70: PUP ebuild: python27**
  - Package file: ../pedigree-apps/packages/python27/package.py

- [ ] **bp3.71: PUP ebuild: qemu**
  - Package file: ../pedigree-apps/packages/qemu/package.py

- [ ] **bp3.72: PUP ebuild: readline**
  - Package file: ../pedigree-apps/packages/readline/package.py

- [ ] **bp3.73: PUP ebuild: sed**
  - Package file: ../pedigree-apps/packages/sed/package.py

- [ ] **bp3.74: PUP ebuild: slang**
  - Package file: ../pedigree-apps/packages/slang/package.py

- [ ] **bp3.75: PUP ebuild: sqlite**
  - Package file: ../pedigree-apps/packages/sqlite/package.py

- [ ] **bp3.76: PUP ebuild: vim**
  - Package file: ../pedigree-apps/packages/vim/package.py

- [ ] **bp3.77: PUP ebuild: vttest**
  - Package file: ../pedigree-apps/packages/vttest/package.py

- [ ] **bp3.78: PUP ebuild: wget**
  - Package file: ../pedigree-apps/packages/wget/package.py

- [ ] **bp3.79: PUP ebuild: zlib**
  - Package file: ../pedigree-apps/packages/zlib/package.py

### Phase bp4: Replace easy_build Scripts

- *phase_id*: *bp4*
- *status*: *planned*
- *completion*: 0


- [ ] **bp4.1: Map easy_build scripts to pipeline steps**

- [ ] **bp4.2: Port fixes from easy_build_x64.sh**

- [ ] **bp4.3: Deprecation + docs**


---
