# XZ-Utils (5.4.4) for 64-bit iOS 9 (arm64)

built to work on older **64-bit** iOS 9 jailbroken devices (iPhone 5S, iPhone 6, iPhone 6S, SE, iPad Air, etc.).

> [!WARNING]
> **64-Bit Only:** compiled only for `arm64`. It **will not work** on 32-bit devices like the iPhone 4S, iPhone 5, or iPhone 5C.

## Why?

`xz-utils` from repo like `rakeri.net/cydia` on iOS 9 on a 64-bit device refuses to run, in my case it throw errors like `Killed: 9` (related to code signature). I tried using ldid to sign it but turns out it was made for 32-bit. 

`xz` from repo `apt.bingner.com` did run on 64-bit but returns `dyld: Symbol not found: _clock_gettime` error while installing packages that needs lzma to decompress.

## Download

release page

## Build on macOS

If you want to build it on your own, you will need:

* Xcode Command Line Tools (`xcode-select --install`)
* Homebrew (`brew`)
* `dpkg` (for building the `.deb` file): `brew install dpkg`
* `ldid` (for jailbreak code-signing): `brew install ldid`

### Building:
1. Clone this repo
2. `cd` into the folder
3. ```bash
   chmod +x build.sh
   ```
4. ```bash
   ./build.sh
   ```

Output file: `xz_5.4.4_iphoneos-arm_ios9_fixed.deb`
