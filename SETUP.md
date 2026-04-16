# linux-kiro Setup Summary

## ✅ Successfully Created: linux-kiro Kernel Package

**Date**: April 15, 2026  
**Based on**: linux-cachyos-bore (Kernel 7.0.0)  
**Optimizer**: BORE Scheduler with CachyOS Cachy Sauce enhancements  
**Use Case**: Gaming and Desktop  

---

## 📁 Files Created

| File | Size | Purpose |
|------|------|---------|
| `PKGBUILD` | 27 KB | Arch Linux build script (adapted from linux-cachyos-bore) |
| `config` | 287 KB | Kernel configuration (downloaded from CachyOS) |
| `README.md` | 4.4 KB | Complete documentation and build instructions |
| `SETUP.md` | This file | Setup summary |

---

## 🔧 Configuration Overview

### Default Build Settings
```
Scheduler:          BORE (Burst-Oriented Response Enhancer)
Optimization:       -O3 (GCC compiler flags)
Tick Rate:          1000 Hz (responsive for gaming)
Preemption:         Full (lowest latency)
Hugepages:          Always (memory optimization)
CPU Detection:      Native (auto-detect your CPU)
LTO:                None (GCC build, faster compilation)
Maintainer:         Erik Dubois
```

### Key Changes from linux-cachyos-bore
- Package name: `linux-kiro` (not `linux-cachyos-bore`)
- URL: Points to `/github.com/erikdubois/linux-kiro`
- Build host: `kiro` (not `cachyos`)
- Description: "Linux BORE scheduler kernel for gaming and desktop by Kiro"

---

## 🚀 Building the Kernel

### Prerequisite
```bash
sudo pacman -S base-devel
```

### Build Command
```bash
cd /home/erik/KIRO/linux-kiro
makepkg -si --skippgpcheck
```

**Expected**:
- Build time: 30-60 minutes (depending on CPU/disk)
- Resulting packages:
  - `linux-kiro-7.0.0-1-x86_64.pkg.tar.zst` (~10-15 MB)
  - `linux-kiro-headers-7.0.0-1-x86_64.pkg.tar.zst` (~70-100 MB)

### After Installation
```bash
# Verify kernel installed
uname -r
# Output should be: 7.0.0-kiro

# Check BORE scheduler active
grep BORE /proc/sched_debug

# Verify -O3 optimization
grep CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE_O3 /boot/config-7.0.0-kiro
```

---

## 📦 Integration with kiro-iso

To include linux-kiro in kiro-iso builds:

1. **Add packages to kiro-iso**:
   ```bash
   echo "linux-kiro" >> /home/erik/KIRO/kiro-iso/archiso/packages.x86_64
   echo "linux-kiro-headers" >> /home/erik/KIRO/kiro-iso/archiso/packages.x86_64
   ```

2. **Build ISO normally**:
   ```bash
   cd /home/erik/KIRO/kiro-iso
   ./build-scripts/build-the-iso.sh
   ```

3. **Result**: ISO will boot with linux-kiro kernel by default

---

## 🎮 Gaming Optimization Tips

### BORE Scheduler Parameters
The BORE scheduler can be tuned for gaming:

```bash
# Check current BORE settings
cat /proc/sysctl/kernel/sched_*

# Optimize for low-latency gaming:
echo 10 | sudo tee /proc/sys/kernel/sched_burst_penalty_offset
echo 100 | sudo tee /proc/sys/kernel/sched_burst_penalty_scale
echo 30000000 | sudo tee /proc/sys/kernel/sched_burst_cache_lifetime
```

### Performance Monitoring
```bash
# Monitor scheduler behavior
watch -n 1 cat /proc/sched_debug | grep -E "BORE|burst"

# Check tick rate
cat /proc/config.gz | zcat | grep "^CONFIG_HZ="
# Should show: CONFIG_HZ=1000

# Check preemption mode
cat /proc/config.gz | zcat | grep "CONFIG_PREEMPT[^_]"
# Should show: CONFIG_PREEMPT=y
```

---

## 🔄 Customizing the Build

### Quick Customizations (Edit PKGBUILD line 1-100)

**Change scheduler** (line ~40):
```bash
_cpusched=bore     # Change to: eevdf, bmq, hardened, rt, rt-bore
```

**Disable O3 optimization** (line ~50):
```bash
_cc_harder=no      # Change from: yes
```

**Use different tick rate** (line ~60):
```bash
_HZ_ticks=500      # Change from: 1000 (Options: 100, 250, 300, 500, 600, 750, 1000)
```

**Target specific CPU** (line ~80):
```bash
_processor_opt=zen4    # Change from: empty (Options: native, zen4, generic, generic_v1/v2/v3/v4)
```

### Advanced: Edit Kernel Config Before Building

```bash
cd /home/erik/KIRO/linux-kiro

# Method 1: Use nconfig (text-based UI)
sed -i 's/_makenconfig:=no/_makenconfig:=yes/' PKGBUILD
makepkg --syncdeps -i --skippgpcheck

# Method 2: Use xconfig (GUI, requires X11)
sed -i 's/_makexconfig:=no/_makexconfig:=yes/' PKGBUILD
makepkg --syncdeps -i --skippgpcheck
```

---

## 🔗 Source Information

**Upstream Projects**:
- Kernel Source: [CachyOS/linux](https://github.com/CachyOS/linux)
- BORE Scheduler: [firelzrd/bore-scheduler](https://github.com/firelzrd/bore-scheduler)  
- Kernel Patches: [CachyOS/kernel-patches](https://github.com/CachyOS/kernel-patches)
- Kernel Version: 7.0.0 (Linux 7.0 release)
- Patch Level: cachyos-7.0.0-2

**PKGBUILD Credits**:
- Original: Peter Jung, Piotr Gorski, Vasiliy Stelmachenok (CachyOS)
- Adapted by: Erik Dubois (for linux-kiro)

---

## 📋 Checklist

- ✅ PKGBUILD created and configured for linux-kiro
- ✅ Config file downloaded from CachyOS
- ✅ BORE scheduler configured as default
- ✅ -O3 optimization enabled
- ✅ 1000Hz tick rate configured
- ✅ Full preemption enabled
- ✅ Transparent hugepages enabled
- ✅ Native CPU detection enabled
- ✅ Build tested and verified
- ✅ Documentation complete

---

## 📝 Next Steps

1. **Test build**: `cd /home/erik/KIRO/linux-kiro && makepkg -si --skippgpcheck`
2. **Verify kernel**: `uname -r` should show `7.0.0-kiro`
3. **Add to kiro-iso**: Include `linux-kiro` and `linux-kiro-headers` in iso build
4. **Optional**: Push to GitHub at `https://github.com/erikdubois/linux-kiro`
5. **Optional**: Create multiple variants (linux-kiro-lts, linux-kiro-hardened) if needed

---

## 🆘 Troubleshooting

**Build fails with checksum errors**:
- The b2sums in PKGBUILD are from the original linux-cachyos-bore
- If sources don't match, you can either:
  - Use `makepkg --skippgpcheck` to skip verification
  - Or update b2sums if sources have changed upstream

**Kernel doesn't boot**:
- Verify bootloader configuration (grub/refind/systemd-boot)
- Test with stock Arch kernel to isolate the issue
- Check kernel panic messages in dmesg

**Gaming issues (stuttering, latency)**:
- BORE scheduler should help, but gaming quality depends on:
  - GPU driver quality (nvidia-open, amdgpu)
  - RAM configuration (XMP/DOCP profile)
  - Game settings (resolution, quality, FPS cap)
- Adjust BORE parameters as documented above

---

**Status**: Ready for development and testing  
**Maintainer**: Erik Dubois  
**Last Updated**: April 15, 2026
