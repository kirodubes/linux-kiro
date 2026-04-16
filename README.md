# linux-kiro

A custom Arch Linux kernel optimized for gaming and desktop use, forked from `linux-cachyos-bore`.

## Features

- **BORE Scheduler**: Burst-Oriented Response Enhancer for improved interactivity and gaming responsiveness
- **CachyOS Optimizations**: Pre-patched kernel with Cachy Sauce enhancements
- **Performance**: -O3 compiler optimization, 1000Hz tick rate, full preemption
- **Gaming-Ready**: Configured for low-latency responsiveness in games and interactive workloads

## Building

### Prerequisites

```bash
sudo pacman -S base-devel
```

### Quick Build

```bash
cd /home/erik/KIRO/linux-kiro
makepkg -si --skippgpcheck
```

The build will take 30-60 minutes depending on your CPU and disk speed.

### Build Options

Edit the top of `PKGBUILD` to customize:

```bash
# CPU scheduler (default: bore)
_cpusched=bore              # bore, eevdf, bmq, hardened, rt, rt-bore

# Compilation optimization (default: yes = -O3)
_cc_harder=yes             # yes/no

# Tick rate (default: 1000)
_HZ_ticks=1000            # 100, 250, 300, 500, 600, 750, 1000

# Preemption (default: full)
_preempt=full             # full, lazy, dynamic

# CPU optimization (default: native detection)
_processor_opt=            # native, zen4, generic, generic_v1-v4

# LTO mode (default: none = GCC)
_use_llvm_lto=none        # none, thin, full

# Enable debug symbols
_build_debug=no           # yes/no

# Build optional modules
_build_zfs=no             # yes/no
_build_nvidia_open=no     # yes/no (for NVIDIA Turing+ GPUs)
_build_r8125=no           # yes/no (for r8125 network adapter)
```

### Custom Builds

To customize the kernel configuration before building:

```bash
cd /home/erik/KIRO/linux-kiro
# Edit PKGBUILD and set:
_makenconfig=yes          # Opens kernel config tool (nconfig)
# OR
_makexconfig=yes          # Opens kernel config tool (xconfig) - needs X11

# Then build as usual
makepkg -si --skippgpcheck
```

## Verification

After installation:

```bash
# Check kernel version
uname -r
# Should show: 7.0.0-kiro

# Check BORE scheduler is active
cat /proc/sched_debug | grep BORE

# Check compilation optimization
grep "CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE_O3" /boot/config-7.0.0-kiro

# Check preemption
grep "CONFIG_PREEMPT" /boot/config-7.0.0-kiro
```

## Key Differences from Stock Arch Linux

| Feature | Arch Linux | linux-kiro |
|---------|-----------|------------|
| Kernel Version | Latest stable | 7.0.0 (CachyOS pre-patched) |
| Scheduler | EEVDF (default) | BORE |
| Compiler Flags | Standard | -O3 optimization |
| Preemption | Dynamic | Full |
| Tick Rate | 1000Hz | 1000Hz |
| Transparent Hugepages | madvise | always |
| CPU Detection | Native | Native (or specify) |

## For kiro-iso Integration

Add to `/home/erik/KIRO/kiro-iso/archiso/packages.x86_64`:

```
linux-kiro
linux-kiro-headers
```

The linux-kiro kernel will be included in the ISO and automatically selected as the boot kernel.

## Troubleshooting

### Build fails with missing dependencies

```bash
sudo pacman -S base-devel
makepkg --syncdeps -si --skippgpcheck
```

### Kernel doesn't boot

- Ensure you have proper bootloader configuration (grub/refind/systemd-boot)
- Check BIOS/UEFI firmware for any device-specific issues
- Try with stock Arch kernel to isolate if it's a linux-kiro issue

### Gaming performance issues

Check if BORE scheduler is properly loaded:
```bash
dmesg | grep -i bore
```

Adjust BORE scheduler parameters:
```bash
# Lower latency for games
sysctl kernel.sched_burst_penalty_offset=10
sysctl kernel.sched_burst_penalty_scale=100
sysctl kernel.sched_burst_cache_lifetime=30000000
```

## Source

- Kernel Source: [CachyOS/linux](https://github.com/CachyOS/linux)
- BORE Scheduler: [BORE Scheduler Repository](https://github.com/firelzrd/bore-scheduler)
- CachyOS Patches: [CachyOS/kernel-patches](https://github.com/CachyOS/kernel-patches)

## License

GPL-2.0-only (same as Linux kernel)

## Credits

- **BORE Scheduler**: Hamad Al Marri
- **CachyOS**: CachyOS project (Peter Jung, Piotr Gorski, Vasiliy Stelmachenok)
- **linux-kiro**: Erik Dubois (based on linux-cachyos-bore)

## Notes

- This kernel is optimized for gaming and interactive desktop use
- Not recommended for production servers (use linux-cachyos-server for that)
- Security updates: Monitor upstream CachyOS for kernel updates
- BORE scheduler is known to improve gaming FPS consistency and reduce stutter
