# XZ-Utils (5.4.4) for iOS 9

This repository contains a fixed build script and a pre-compiled `.deb` package of `xz-utils` version 5.4.4 specifically optimized to work on older **64-bit** iOS 9 jailbroken devices (iPhone 5S, iPhone 6, iPhone 6S, SE, iPad Air, etc.).

> [!WARNING]
> **64-Bit Only:** This build is natively compiled for the `arm64` architecture. It **will not work** on 32-bit devices like the iPhone 4S, iPhone 5, or iPhone 5C (you will receive a `Bad CPU type in executable` error).

## Why this custom build is necessary

When using modern `xz-utils` or older ones from random repositories on iOS 9, you will usually encounter one of three fatal errors:

1. **`dyld: Symbol not found: _clock_gettime`**: Modern Apple compilers (Xcode 15+) inject `clock_gettime` calls into C binaries. This function was only introduced in iOS 10, meaning binaries will crash on iOS 9 with a `Trace/BPT trap: 5` error.
2. **`Killed: 9` (AMFI Crash)**: Jailbroken iOS still requires executables to have a valid code signature. Without an `ldid` ad-hoc signature, the iOS kernel instantly terminates the process.
3. **`unable to execute... (lzma): No such file or directory`**: Many tweaks (like `libactivator`) are packaged using `.lzma` compression. If your system's `lzma` command is missing or broken, Zebra and Cydia's `dpkg` will fail to extract them. 

**This build fixes all of the above:**
* It disables `clock_gettime` during the `./configure` step, forcing the compiler to use old iOS 9 compatible timing functions.
* It automatically signs the resulting Mach-O binaries with `ldid -S`.
* It provides `lzma` and `unlzma` symlinks (replacing older buggy `lzma` packages) so `dpkg-deb` works perfectly.
* It forces the final `.deb` to use `gzip` compression instead of modern `zstd`, which older Cydia/dpkg versions cannot parse.

---

## How to use the pre-compiled `.deb`

If you just want to fix your device, download the pre-compiled release from the Releases tab, transfer it to your iPhone (via SSH, Filza, etc.), and run:

```bash
dpkg -i xz_5.4.4_iphoneos-arm_ios9_fixed.deb
```
*(If your Zebra/Cydia is currently broken, you must install it via the terminal since GUI package managers might fail to unpack).*

---

## How to build it yourself (macOS)

If you wish to compile the package from source on a Mac:

### Prerequisites:
* Xcode Command Line Tools (`xcode-select --install`)
* Homebrew (`brew`)
* `dpkg` (for building the `.deb` file): `brew install dpkg`
* `ldid` (for jailbreak code-signing): `brew install ldid`

### Building:
1. Clone this repository or download the source folder.
2. Open your terminal and navigate to the folder.
3. Make the build script executable:
   ```bash
   chmod +x build.sh
   ```
4. Run the script:
   ```bash
   ./build.sh
   ```
5. The script will automatically download the XZ source code, patch it, compile it using the iPhoneOS SDK, sign it with `ldid`, and spit out the fixed `.deb` package in the current directory!
