# Custom Arch Linux Kernel — Claude Onboarding Template

> **Load this guide into Claude Code**: https://claude.ai/claude-code/onboard/WWvIE2tARwuU

This is a template CLAUDE.md for anyone building a custom Arch Linux kernel package with Claude Code, using the CachyOS pre-patched tarball as a base. Copy the relevant sections into your own project's `CLAUDE.md` and fill in your specifics.

---

## How to use this template

1. Create a directory for your kernel project: `mkdir ~/my-kernel && cd ~/my-kernel`
2. Copy your `PKGBUILD`, `config`, and patch files in
3. Create a `CLAUDE.md` from the template below
4. Open Claude Code in that directory — it reads `CLAUDE.md` automatically

---

## Template: CLAUDE.md

```markdown
# CLAUDE.md

## Project

Custom Arch Linux kernel package (`<pkgname>`) forked from CachyOS linux-cachyos-bore.
Built for: <your hardware — e.g. Intel i7-10700K, AMD Ryzen 7 5800X, etc.>
Provides two switchable presets — Gaming and Desktop — via an interactive build wrapper.

## Kernel profiles

| Setting        | Gaming          | Desktop         |
|----------------|-----------------|-----------------|
| Source         | CachyOS pre-patched tarball    ||
| Scheduler      | BORE            | EEVDF           |
| HZ             | 1000            | 500             |
| Preemption     | full            | lazy            |
| CPU opt        | native          | generic_v3      |
| THP            | always          | madvise         |
| TCP            | BBR3            | BBR3            |
| O3             | yes             | yes             |
| Localmod       | optional (modprobed-db) ||

## Build commands

./build-kernel.sh           # interactive wrapper (recommended)
makepkg -si --skippgpcheck  # direct build (PKGBUILD must already be configured)
./clean.sh                  # remove build artifacts

## Architecture

**PKGBUILD** — core build script. The top ~160 lines are configurable variables.
Never edit PKGBUILD directly for profile changes — use `build-kernel.sh`, which
creates timestamped `PKGBUILD.backup.*` files before any change.

**build-kernel.sh** — interactive wrapper that:
1. Prompts for Gaming or Desktop profile
2. Auto-detects modprobed.db and enables hardware-module optimization
3. Runs updpkgsums to update checksums
4. Optionally launches nconfig for manual config edits
5. Moves built packages into kernels/<type>/<modprobed>/<timestamp>/ and writes build-info.md

**config** — kernel .config trimmed for this specific hardware. Versioned configs
(config-7.0.x-1-kiro) are snapshots taken after each build.

**original/** — read-only reference PKGBUILDs from CachyOS upstream (bore, eevdf, etc.).
Never edit these.

## Key PKGBUILD variables

| Variable        | Gaming   | Desktop    |
|-----------------|----------|------------|
| _cpusched       | bore     | eevdf      |
| _HZ_ticks       | 1000     | 500        |
| _preempt        | full     | lazy       |
| _hugepage       | always   | madvise    |
| _processor_opt  | native   | generic_v3 |

Other notable variables: _cc_harder (-O3), _use_llvm_lto, _localmodcfg,
_build_zfs, _build_nvidia_open.

## Upstream references

- CachyOS PKGBUILD: https://github.com/CachyOS/linux-cachyos/blob/master/linux-cachyos-bore/PKGBUILD
- CachyOS kernel source: https://github.com/CachyOS/linux
- CachyOS patches: https://github.com/CachyOS/kernel-patches
- BORE scheduler: https://github.com/firelzrd/bore-scheduler

## Updating to a new kernel version

1. Check CachyOS releases for the new cachyos-X.Y.Z-N tarball
2. Update _minor and _tagrel in PKGBUILD
3. Run ./build-kernel.sh — updpkgsums recalculates automatically
4. The existing config is forward-compatible; new symbols get kernel defaults via yes "" | make config

## Post-build verification

uname -r                                    # expect 7.x.x-kiro
cat /proc/sched_debug | grep -E 'BORE|EEVDF'
zcat /proc/config.gz | grep CONFIG_HZ=
zcat /proc/config.gz | grep CONFIG_PREEMPT
cat /sys/kernel/mm/transparent_hugepage/enabled

## Hardware notes

- CPU: <your CPU>
- GPU: <your GPU — note if you disabled wifi/AMD/nouveau in config>
- Network: <wired / wifi>

## Editing rules

- Never edit PKGBUILD directly for profile changes — use build-kernel.sh
- The config file is generated upstream; avoid hand-editing it
- original/ is read-only reference material

## Current state

<Short description — e.g. "PKGBUILD at 7.0.5-1, BORE gaming preset active, modprobed enabled.">
```

---

## Tips for working with Claude on kernel builds

### Be specific about your hardware

The kernel config is hardware-dependent. Tell Claude exactly what CPU, GPU, and network card you have. Options like `-march=native`, WiFi module inclusion, and GPU driver selection all depend on this.

### Share your PKGBUILD variables

When asking Claude to help tune settings, paste the variable block at the top of your PKGBUILD. Claude needs to see `_cpusched`, `_HZ_ticks`, `_preempt`, `_hugepage`, etc. to give accurate advice.

### Use modprobed-db

Install `modprobed-db` from the AUR and let it run for a few hours before building. It reduces build time by 30–50% by compiling only modules your hardware actually uses. Ask Claude to wire it into your build script.

### Keep a CHANGELOG.md

Ask Claude to update it after each session. It becomes the project memory — version bumps, config changes, and decisions made are all recorded there.

### Useful starting questions for Claude

- "Read my PKGBUILD and explain what each variable at the top does"
- "Compare my PKGBUILD with [upstream URL] and tell me what's different"
- "Write a build-kernel.sh wrapper with Gaming and Desktop presets"
- "What should I verify after installing this kernel to confirm it's running correctly?"
- "My build failed with this error: [paste error] — what's wrong?"
- "I'm on kernel X.Y.Z — what do I need to update to bump to X.Y.Z+1?"

### Scheduler quick reference

| Scheduler | Good for | Source |
|-----------|----------|--------|
| BORE | Gaming, low-latency desktop | CachyOS / linux-kiro |
| PDS | Low-latency desktop | Liquorix lqx patchset |
| EEVDF | Balanced desktop/server | Vanilla kernel (default) |
| BMQ | Alternative desktop | Liquorix lqx patchset |
| CFS | Generic / server | Vanilla kernel (legacy) |

### Common PKGBUILD patterns

**localmodconfig with modprobed-db:**
```bash
if [ -f "$HOME/.config/modprobed.db" ]; then
    make LSMOD="$HOME/.config/modprobed.db" localmodconfig
fi
```

**Native CPU:**
```bash
scripts/config -e X86_NATIVE_CPU
```

**BORE scheduler:**
```bash
scripts/config -e SCHED_BORE
```

**Arch-specific tweaks (always include these):**
```bash
scripts/config -e CONFIG_DEBUG_INFO_DWARF5
scripts/config --set-str CONFIG_SECURITY_TOMOYO_POLICY_LOADER "/usr/bin/tomoyo-init"
scripts/config --set-str CONFIG_SECURITY_TOMOYO_ACTIVATION_TRIGGER "/usr/lib/systemd/systemd"
scripts/config --set-str CONFIG_LSM "landlock,lockdown,yama,bpf"
```

---

## Real examples to study

- **linux-kiro** — CachyOS/BORE kernel, gaming + desktop presets: https://github.com/kirodubes/linux-kiro
- **linux-kiro-lqx** — Liquorix/PDS kernel, single fixed profile, native CPU: https://github.com/kirodubes/linux-kiro-lqx
- **linux-cachyos-bore** — upstream CachyOS BORE reference: https://github.com/CachyOS/linux-cachyos/blob/master/linux-cachyos-bore/PKGBUILD
- **linux-lqx (Chaotic-AUR)** — upstream Liquorix reference: https://gitlab.com/chaotic-aur/pkgbuilds/-/blob/main/linux-lqx/PKGBUILD
