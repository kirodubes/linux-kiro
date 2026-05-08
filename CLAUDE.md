# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Custom Arch Linux kernel package (`linux-kiro`) forked from CachyOS linux-cachyos-bore. Targets an Intel i7-10700K desktop. Provides two switchable presets — Gaming (BORE/1000Hz/full-preempt) and Desktop (EEVDF/500Hz/lazy-preempt) — via an interactive build wrapper script.

## Build Commands

```bash
# Recommended: interactive wrapper (handles presets, checksums, modprobed, artifact storage)
./build-kernel.sh

# Direct makepkg (if PKGBUILD is already configured)
makepkg -si --skippgpcheck

# Cleanup build artifacts before committing
./clean.sh

# Push to GitHub (runs git add/commit/push + cleanup)
./up.sh
```

Build takes 30–60 minutes. With `~/.config/modprobed.db` installed (`modprobed-db` AUR package), the script enables `_localmodcfg=yes` and build time drops by 30–50%.

## Architecture

**PKGBUILD** is the Arch kernel build script. The top ~160 lines are configurable variables — everything about the kernel profile is set here. `build-kernel.sh` is the only safe way to modify these; it creates timestamped `PKGBUILD.backup.*` files before any change.

**build-kernel.sh** abstracts kernel configuration behind two presets encoded as bash arrays. It:
1. Prompts for Gaming or Desktop profile
2. Auto-detects `modprobed.db` and enables hardware-module optimization
3. Runs `updpkgsums` to update checksums
4. Optionally launches `nconfig` for manual config edits
5. Moves built `.pkg.tar.zst` packages into `kernels/<type>/<modprobed>/<timestamp>/` and writes `build-info.md`

**config** is the 287KB kernel `.config` trimmed for this specific hardware: Intel GPU only, no WiFi, no AMD/Nouveau. Versioned configs (`config-7.0.x-1-kiro`) are snapshots.

**original/** holds reference PKGBUILD variants from CachyOS upstream (bore, eevdf, etc.) — read-only reference, never edited.

## Key Variables in PKGBUILD

| Variable | Gaming | Desktop |
|---|---|---|
| `_cpusched` | `bore` | `eevdf` |
| `_HZ_ticks` | `1000` | `500` |
| `_preempt` | `full` | `lazy` |
| `_hugepage` | `always` | `madvise` |
| `_processor_opt` | `native` | `generic_v3` |

Other notable variables: `_cc_harder` (-O3), `_use_llvm_lto`, `_localmodcfg`, `_build_zfs`, `_build_nvidia_open`.

## Post-Build Verification

```bash
uname -r                                         # expect 7.x.x-kiro
cat /proc/sched_debug | grep -E 'BORE|EEVDF'
zcat /proc/config.gz | grep CONFIG_HZ=
zcat /proc/config.gz | grep CONFIG_PREEMPT
cat /sys/kernel/mm/transparent_hugepage/enabled
```

## Editing Rules

- Never edit PKGBUILD directly for profile changes — use `build-kernel.sh` or the script's backup/restore mechanism (`cp PKGBUILD.backup.DATE PKGBUILD`)
- The `config` file is generated upstream; avoid hand-editing it
- `original/` is read-only reference material

## Current State

PKGBUILD bumped to 7.0.5-1 (from 7.0.1-2). BORE gaming preset active, modprobed enabled. Run `./build-kernel.sh` to rebuild — `updpkgsums` will update b2sums automatically. Upstream: `git@github.com:kirodubes/linux-kiro`.
