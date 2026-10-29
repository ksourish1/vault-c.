@echo off
echo [Vault-C] Compiling pure C source files...
gcc -std=c99 -O2 -Wall -Wextra -Iinclude src/main.c src/storage.c src/crypto.c src/compress.c src/chunker.c src/fs_utils.c -o vault.exe
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Compilation failed. Ensure gcc is in your PATH.
    exit /b 1
)
echo [OK] Built vault.exe successfully!
echo Run "vault.exe demo" to see the full interactive demonstration.
