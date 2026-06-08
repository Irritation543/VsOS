CC = gcc
CXX = g++
ASM = nasm
LD = g++
OBJCOPY = objcopy
PYTHON = python

CFLAGS = -m32 -ffreestanding -fno-builtin -fno-stack-protector -Wall -Wextra -Ikernel -Iarch/i386 -I.
CXXFLAGS = $(CFLAGS) -fno-exceptions -fno-rtti
ASMFLAGS = -f win32
LDFLAGS = -m32 -T linker.ld -nostdlib -Wl,--image-base=0

OBJDIR = obj

C_FILES := $(wildcard kernel/*.c commands/*.c)
CPP_FILES := $(wildcard kernel/*.cpp commands/*.cpp)
ASM_FILES := $(wildcard boot/*.asm arch/i386/*.asm)
C_OBJS := $(patsubst %.c,$(OBJDIR)/%.o,$(notdir $(C_FILES)))
CPP_OBJS := $(patsubst %.cpp,$(OBJDIR)/%.o,$(notdir $(CPP_FILES)))
ASM_OBJS := $(patsubst %.asm,$(OBJDIR)/%.o,$(notdir $(ASM_FILES)))
OBJS := $(C_OBJS) $(CPP_OBJS) $(ASM_OBJS)

vpath %.c kernel:commands
vpath %.cpp kernel:commands
vpath %.asm boot:arch/i386

kernel/font.h: tools/fontgen.py
	$(PYTHON) $<

all: vsos.bin

$(OBJDIR)/%.o: %.c kernel/font.h | $(OBJDIR)
	$(CC) $(CFLAGS) -c -o $@ $<

$(OBJDIR)/%.o: %.cpp kernel/font.h | $(OBJDIR)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OBJDIR)/%.o: %.asm | $(OBJDIR)
	$(ASM) $(ASMFLAGS) -o $@ $<

vsos.pe: $(OBJS) linker.ld
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

vsos.bin: vsos.pe
	$(OBJCOPY) -O elf32-i386 $< $@

$(OBJDIR):
	mkdir -p $(OBJDIR)

clean:
	rm -rf $(OBJDIR) vsos.pe vsos.bin kernel/font.h

run: vsos.bin
	qemu-system-i386 -kernel vsos.bin

.PHONY: all clean run
