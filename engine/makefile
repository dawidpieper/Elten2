CC = gcc
CFLAGS = -g -Wl,--sort-common,--as-needed,-z,relro,-z,now -Wl,--compress-debug-sections=zlib
TARGET = out/elten
SOURCE=src/init.c \
src/main.c \
src/window.c \
src/api/api.c \
src/api/kernel.c \
src/api/speech.c

DIRS=-Iext/include -Lext/lib -I/usr/include/ruby-2.5.0/x86_64-linux -I/usr/include/ruby-2.5.0 -I./src/includes
LIB=-lspeechd -lX11 -lruby -lpthread -lgmp -ldl -lcrypt -lm 
all: $(TARGET)

$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) $(DIRS) $(SOURCE) $(LIB) -o $(TARGET) 

clean:
	$(RM) $(TARGET)