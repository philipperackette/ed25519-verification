# Verification Artifacts

This directory contains the complete, unmodified output of a full verification run (including Schoof's algorithm) performed on 2026-03-26.

## Authenticity

The file `hashes.txt` contains SHA-256 checksums of all artifacts produced during the run. It is signed by the author's PGP key:

```
gpg --verify hashes.txt.asc hashes.txt
```

The public key is available in [`../pgp/philipperackette.asc`](../pgp/philipperackette.asc).

Fingerprint: `BC69 21A8 5B8D DBB5 F3A6 EB81 9055 4E6A 6924 F3C7`

## File naming

The validation script produced artifacts with the filename `ed25519_verify_v2.cpp` (source) and `ed25519_v2` (binary). In this repository, the source file has been renamed to `ed25519_verify.cpp` for clarity. The hash manifest and PGP signature reference the original filenames to preserve signature integrity.

## Hardware

The computation ran on a miniPC with an AMD Ryzen 3 3250U (2 cores / 4 threads, 2.6 GHz) and 6 GB of RAM, running Linux Mint 22.3. The full verification completed in approximately 54 hours of wall-clock time. See `system_info.txt` for complete details.
