CC      = gcc
CFLAGS  = -std=c99 -O2 -Wall -Wextra -Iinclude
SRCS    = src/main.c src/storage.c src/crypto.c src/compress.c src/chunker.c src/fs_utils.c
TARGET  = vault

all: $(TARGET)

$(TARGET): $(SRCS) include/vault.h
	$(CC) $(CFLAGS) $(SRCS) -o $(TARGET)

demo: $(TARGET)
	./$(TARGET) demo

clean:
	rm -f $(TARGET) $(TARGET).exe demo_vault.vlt
	rm -rf demo_sample_project demo_restored_v1
