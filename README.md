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

### Quick Build with build-kernel.sh

The easiest way to build is using the interactive build script:

```bash
cd /home/erik/KIRO/linux-kiro
./build-kernel.sh
```

This will:
1. **Prompt for kernel profile** (Gaming or Desktop)
2. **Check for modprobed.db** and offer hardware-specific module optimization
3. **Update package checksums** before building
4. **Optionally run nconfig** for manual configuration
5. **Build and install** the kernel

The build will take 15-60 minutes depending on:
- Your CPU speed
- Disk I/O performance
- Whether you enable local module config (can save 30-50% build time)

### Manual Build

```bash
cd /home/erik/KIRO/linux-kiro
makepkg -si --skippgpcheck
```

### Kernel Profiles

The `build-kernel.sh` script provides two preset configurations:

**Gaming Kernel** (optimized for responsiveness & FPS)

- BORE scheduler (burst responsiveness)
- 1000Hz tick rate (low latency)
- Full preemption
- Transparent Huge Pages (always enabled)

**Desktop Kernel** (optimized for productivity & power efficiency)

- EEVDF scheduler (fair scheduling)
- 500Hz tick rate (power efficient)
- Lazy preemption (balanced)
- Transparent Huge Pages (madvise)

### Hardware Module Optimization

To significantly reduce build time (30-50% faster), use `modprobed-db` to track which kernel modules your hardware actually needs:

```bash
# Install modprobed-db
yay -S modprobed-db

# Start tracking modules used by your hardware
sudo modprobed-db

# After a few hours/days of normal use, generate the database
modprobed-db

# Next time you run build-kernel.sh, it will ask to enable local module config
./build-kernel.sh
```

With local module config enabled, only your hardware's modules are compiled. The script will automatically detect and use `~/.config/modprobed.db` if it exists.

### Advanced Build Options

For more control, edit the top of `PKGBUILD`:

```bash
# CPU scheduler (default: bore)
_cpusched=bore              # bore, eevdf, bmq, hardened, rt, rt-bore

# Compilation optimization (default: yes = -O3)
_cc_harder=yes             # yes/no

# Tick rate (default: 1000)
_HZ_ticks=1000            # 100, 250, 300, 500, 600, 750, 1000

# Preemption (default: full)
_preempt=full             # full, lazy, dynamic

# CPU optimization (default: generic_v3)
_processor_opt=generic_v3  # native, zen4, generic, generic_v1-v4

# LTO mode (default: none = GCC)
_use_llvm_lto=none        # none, thin, full

# Enable debug symbols
_build_debug=no           # yes/no

# Build optional modules
_build_zfs=no             # yes/no
_build_nvidia_open=no     # yes/no (for NVIDIA Turing+ GPUs)
_build_r8125=no           # yes/no (for r8125 network adapter)

# Use local module config (auto-detected by build-kernel.sh)
_localmodcfg=no           # yes/no
```

### Build Script Features

The `build-kernel.sh` script handles the complete build workflow:

1. **Profile Selection** - Choose between Gaming or Desktop kernel
2. **Module Optimization** - Detects `modprobed.db` and enables hardware-specific modules
3. **Checksum Update** - Automatically runs `updpkgsums` before building
4. **Manual Configuration** - Optional `nconfig` for advanced kernel options
5. **Build & Install** - Compiles and installs the kernel in one step

### Custom Builds

To customize the kernel configuration before building:

```bash
cd /home/erik/KIRO/linux-kiro

# Option 1: Use build script with manual config
./build-kernel.sh
# When prompted, select yes for nconfig

# Option 2: Edit PKGBUILD directly
# Set _makenconfig=yes to open nconfig during build
# OR _makexconfig=yes to open xconfig (requires X11)
nano PKGBUILD
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
