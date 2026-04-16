# Kernel PKGBUILD Comparison

## Files Compared

* `PKGBUILD` (Kiro version)
* `PKGBUILD-CACHYOS` (upstream-based version)

---

## 1. Package Identity

### Kiro (`PKGBUILD`)

* Package names: `linux-kiro`, `linux-kiro-lto`, `linux-kiro-gcc`
* Custom branding and repository URL
* Build host set to `kiro`

### CachyOS (`PKGBUILD-CACHYOS`)

* Package names: `linux-cachyos`, `linux-cachyos-lto`, `linux-cachyos-gcc`
* Upstream CachyOS branding and URLs

**Summary:**
Kiro version is tailored for a custom distribution, while CachyOS stays upstream-compatible.

---

## 2. CPU Scheduler Default

### Kiro

* Default: `bore`

### CachyOS

* Default: `cachyos` (EEVDF-based)

**Summary:**

* `bore`: optimized for desktop responsiveness and gaming
* `cachyos`: closer to upstream kernel scheduling behavior

---

## 3. CPU Optimization

### Kiro

* Default: `generic_v3`

### CachyOS

* Default: none (generic baseline)

**Summary:**
Kiro targets newer CPUs by default, while CachyOS maximizes compatibility.

---

## 4. LTO / Compiler Strategy

### Kiro

* LTO disabled (`_use_llvm_lto=none`)
* Uses LTO suffix naming
* GCC variant disabled by default

### CachyOS

* ThinLTO enabled (`_use_llvm_lto=thin`)
* GCC variant enabled
* No LTO suffix

**Summary:**

* Kiro: simpler, easier to maintain
* CachyOS: more aggressive optimization

---

## 5. Advanced Optimizations

### Kiro

* No AutoFDO
* No Propeller support

### CachyOS

* Includes AutoFDO support
* Includes Propeller optimization
* Profile-based optimization workflow

**Summary:**
CachyOS includes advanced performance tooling; Kiro removes complexity.

---

## 6. Provides / Replaces Handling

### Kiro

* Simplified package relationships

### CachyOS

* More extensive `provides` / `replaces` logic
* Supports LTO package variants

**Summary:**
CachyOS is more flexible for package compatibility.

---

## 7. Scheduler Patch Logic

### Kiro

```bash
case "$_cpusched" in
    cachyos|bore|rt-bore|hardened)
```

### CachyOS

```bash
case "$_cpusched" in
    bore|rt-bore|hardened)
```

**Summary:**
Kiro treats `cachyos` the same as `bore`, which may not reflect intended behavior.

---

## Overall Comparison

### Kiro (`PKGBUILD`)

**Strengths:**

* Simpler and cleaner
* Easier maintenance
* Clear distribution identity
* Desktop-focused defaults

**Tradeoffs:**

* Fewer optimization features
* Less upstream alignment

---

### CachyOS (`PKGBUILD-CACHYOS`)

**Strengths:**

* Feature-rich
* Advanced compiler optimizations
* Closer to upstream

**Tradeoffs:**

* More complex
* Harder to maintain/debug

---

## Recommendation

### Best Base for Custom Distribution

Use **Kiro (`PKGBUILD`)** as the primary base.

### Suggested Approach

* Keep Kiro branding and structure
* Keep defaults simple (no LTO, no AutoFDO)
* Reintroduce features only if needed
* Review scheduler patch logic for correctness

---

## Final Take

* Use `PKGBUILD` for stability and maintainability
* Use `PKGBUILD-CACHYOS` as a reference for advanced optimizations

A hybrid approach is recommended: start simple, then selectively add features.

