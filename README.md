# Vault-C: Encrypted, Deduplicating, Versioned Backup Tool in Pure C

A zero-dependency, systems-level backup and snapshot engine written from scratch in **ISO C99**. It packs folders into a single compressed, encrypted, tamper-checked `.vlt` archive with full snapshot history and time-travel recovery.

---

## Key Features & Algorithms (All Written from Scratch)

| Subsystem | Implementation File | Algorithm / Technique | Real-World Purpose |
| :--- | :--- | :--- | :--- |
| **Content-Defined Chunking** | `src/chunker.c` | Rolling Gear polynomial hash (`1 KB` min, `4 KB` avg, `16 KB` max) | Inserting bytes at the top of a file does not shift subsequent chunks |
| **Deduplication Engine** | `src/chunker.c` | $O(1)$ chained hash table (`4096` buckets) keyed by 256-bit SHA-256 | Identical chunks across files and across backup versions are stored only once |
| **Lossless Compression** | `src/compress.c` | Custom byte-aligned **LZ77** sliding-window (`4 KB` window, `3..18` byte matches) | Shrinks text, source code, and documents before encryption |
| **Stream Encryption** | `src/crypto.c` | **ChaCha20** (RFC 7539, 256-bit key, 20 ARX rounds) + 10,000-round salted SHA-256 KDF | Protects archives on USB drives or cloud storage |
| **Integrity & Bit-Rot Detection** | `src/crypto.c` | Dual-layer **CRC32** (IEEE 802.3) + **SHA-256** (FIPS 180-4) per chunk & per file | Detects silent storage corruption or tampering immediately |
| **Incremental Versioning** | `src/storage.c` | Append-only chunk store + snapshot index + `mtime`/size/SHA-256 fast skip | Instant daily backups and time-travel restore to any version |

---

## Binary `.vlt` Archive Layout

```text
+-----------------------------------------------------------------------+
| Offset 0: VaultHeader (84 bytes)                                      |
|   - Magic: "VAULTC01" (8B), Version (4B), Flags (4B)                  |
|   - Salt (16B), Password Verifier Tag (32B)                           |
|   - Index Offset (8B), Chunk Count (4B), Snapshot Count (4B)          |
+-----------------------------------------------------------------------+
| Chunk Data Store (Append-Only)                                        |
|   [Chunk #0 Payload (LZ77 + ChaCha20)]                                |
|   [Chunk #1 Payload (LZ77 + ChaCha20)]                                |
|   [Chunk #2 Payload ...]                                              |
+-----------------------------------------------------------------------+
| Footer Index Region (at header.index_offset)                          |
|   1. ChunkEntry Table [0 .. chunk_count - 1]                          |
|        (sha256, data_offset, raw_size, stored_size, crc32, flags)     |
|   2. Snapshot Records [1 .. snapshot_count]                           |
|        SnapshotDiskHeader + FileDiskHeader[] + uint32_t chunk_ids[]   |
+-----------------------------------------------------------------------+
```

---

## How to Build

Using **GCC** (Windows MinGW or Linux/macOS):
```bash
gcc -std=c99 -O2 -Wall -Wextra -Iinclude src/main.c src/storage.c src/crypto.c src/compress.c src/chunker.c src/fs_utils.c -o vault
```
Or run `build.bat` on Windows / `make` on Linux & macOS.

---

## Quick Start & Commands

### 1. Run the Automated End-to-End Showcase
```bash
./vault demo
```
Automatically creates a sample project, initializes an encrypted vault, runs two snapshots with modifications, shows deduplication savings, diffs the snapshots, simulates a 1-byte bit-rot attack, catches it with `verify`, heals it, and restores Snapshot #1.

### 2. Daily Backup Workflow
```bash
# 1. Initialize a new encrypted vault
./vault init myvault.vlt -p mySecretPass

# 2. Back up a folder (creates Snapshot #1)
./vault add myvault.vlt ./my_project -m "Initial version" -p mySecretPass

# 3. Back up again after editing files (creates Snapshot #2, deduplicated!)
./vault add myvault.vlt ./my_project -m "Added new module" -p mySecretPass

# 4. List all snapshots and files
./vault list myvault.vlt

# 5. Compare two snapshots
./vault diff myvault.vlt 1 2

# 6. View storage analytics & ASCII disk map
./vault stats myvault.vlt

# 7. Verify archive integrity (CRC32 + decrypted SHA-256)
./vault verify myvault.vlt -p mySecretPass

# 8. Restore any historical snapshot to a folder
./vault restore myvault.vlt 1 ./recovered_v1 -p mySecretPass

# 9. Launch interactive shell mode
./vault shell myvault.vlt -p mySecretPass
```

> **Note:** While ChaCha20 and SHA-256 are implemented according to RFC 7539 and FIPS 180-4 specifications, this tool is designed as an educational systems programming project and has not undergone formal cryptographic auditing.
