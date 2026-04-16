# KIRO Kernel Build Script

The `build-kernel.sh` script provides an easy way to switch between gaming and desktop kernel configurations before building.

## Quick Start

```bash
./build-kernel.sh
```

## Features

✅ **Interactive menu** - Choose between gaming or desktop configuration  
✅ **Automated configuration** - Modifies only the necessary PKGBUILD parameters  
✅ **Backup creation** - Automatically backs up PKGBUILD before making changes  
✅ **Change summary** - Shows exactly what was modified  
✅ **Optional build** - Asks if you want to build immediately after configuration  
✅ **Interactive config option** - Option to run `nconfig` for manual kernel tweaking  

## What Gets Changed

### Gaming Kernel (Option 1)
This is the current/default configuration - optimized for responsive gaming:

| Parameter | Value |
|-----------|-------|
| CPU Scheduler | BORE |
| Performance Governor | Disabled |
| TCP BBR3 | Disabled |
| Tick Rate | 1000Hz |
| Preemption | Full |
| Transparent Hugepages | Always |

### Desktop Kernel (Option 2)
Recommended for productivity work - better for sustained workloads:

| Parameter | Value |
|-----------|-------|
| CPU Scheduler | EEVDF |
| Performance Governor | Enabled |
| TCP BBR3 | Enabled |
| Tick Rate | 500Hz |
| Preemption | Lazy |
| Transparent Hugepages | Madvise |

## Usage Examples

### Example 1: Switch to Desktop Kernel

```bash
$ ./build-kernel.sh

╔════════════════════════════════════════════════════════════╗
║        KIRO Linux Kernel Build Configuration Script       ║
╚════════════════════════════════════════════════════════════╝

Select kernel configuration:

  1) Gaming Kernel
     - BORE scheduler (burst responsiveness)
     - 1000Hz tick rate (low latency)
     - Full preemption
     - THP always enabled

  2) Desktop Kernel
     - EEVDF scheduler (fair scheduling)
     - 500Hz tick rate (power efficient)
     - Lazy preemption (balanced)
     - THP madvise (predictable latency)

Enter your choice (1 or 2): 2

Configuring for Desktop Kernel...
✓ Backup created: /home/erik/KIRO/linux-kiro/PKGBUILD.backup.20260416_143025

Changes made to PKGBUILD:

-: "${_cpusched:=bore}"
+: "${_cpusched:=eevdf}"
-: "${_per_gov:=no}"
+: "${_per_gov:=yes}"
-: "${_tcp_bbr3:=no}"
+: "${_tcp_bbr3:=yes}"
-: "${_HZ_ticks:=1000}"
+: "${_HZ_ticks:=500}"
-: "${_preempt:=full}"
+: "${_preempt:=lazy}"
-: "${_hugepage:=always}"
+: "${_hugepage:=madvise}"

✓ Desktop kernel configuration applied

Additional Options:

Do you want to run 'nconfig' for manual kernel configuration? (y/n) n

Configuration complete!
Do you want to build the kernel now? (y/n) y

Starting kernel build...
⏱ This will take 30-60 minutes

[kernel build proceeds...]
```

### Example 2: Switch to Gaming Kernel

```bash
$ ./build-kernel.sh
# ... (menu shown)
Enter your choice (1 or 2): 1

Configuring for Gaming Kernel...
# ... (changes shown, all reverted to original gaming defaults)
```

### Example 3: Configure Only (No Build)

```bash
$ ./build-kernel.sh
# ... (select option and configure)
Do you want to build the kernel now? (y/n) n

Build skipped. Run the following when ready:
  cd /home/erik/KIRO/linux-kiro
  makepkg -si --skippgpcheck
```

## Backups

Whenever you run the script, it automatically creates a timestamped backup:

```
PKGBUILD.backup.20260416_143025
PKGBUILD.backup.20260416_150000
PKGBUILD.backup.20260416_155030
```

To restore from a backup:

```bash
cp PKGBUILD.backup.20260416_143025 PKGBUILD
```

## Manual Kernel Configuration (nconfig)

If you want to tweak kernel options beyond the preset configurations:

1. Run the script normally
2. When asked "Do you want to run 'nconfig' for manual kernel configuration?", answer `y`
3. The kernel configuration tool will open during the build
4. Make your changes and save

## What the Script Actually Modifies

The script **only changes** these 6 parameters in PKGBUILD:

1. `_cpusched` - CPU scheduler selection
2. `_per_gov` - Performance governor default
3. `_tcp_bbr3` - TCP BBR3 network congestion control
4. `_HZ_ticks` - Kernel timer tick rate
5. `_preempt` - Preemption type
6. `_hugepage` - Transparent Hugepage mode

**Everything else remains untouched**, including:
- CPU architecture optimization (stays as `generic_v3`)
- Compiler optimization flags (stays as `-O3`)
- Build dependencies
- Module options
- LTO settings
- All other kernel configs

## Advanced: Creating Multiple Kernel Variants

You can keep multiple compiled kernels installed:

```bash
# Build gaming variant
./build-kernel.sh
# Choose option 1, complete build
# Install boots to linux-kiro

# Restore previous config
cp PKGBUILD.backup.DATE PKGBUILD

# Build desktop variant  
./build-kernel.sh
# Choose option 2, complete build
# Install boots to linux-kiro (overwrites previous)

# Switch at boot time using your bootloader
```

## Troubleshooting

### Build fails with missing dependencies
```bash
cd /home/erik/KIRO/linux-kiro
makepkg --syncdeps -si --skippgpcheck
```

### Restore original PKGBUILD
```bash
git checkout PKGBUILD
```

### Check which kernel is running
```bash
uname -r
cat /proc/sched_debug | grep -E "BORE|EEVDF"
```

## Notes

- The script is **non-destructive** - it always creates a backup first
- You can undo any changes by restoring from a backup
- The build process takes 30-60 minutes depending on your CPU
- The kernel is compiled with `-O3` optimization for maximum performance
- Both variants use your CPU's native instruction set (generic_v3 for i7-10700K)

## Support

For more detailed information about the configurations:
- See `OPTIMIZATION_ANALYSIS.md` for technical details
- See `README.md` for general kernel information
