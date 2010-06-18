# (C)2004-2008 SourceMod Development Team
# Makefile written by David "BAILOPAN" Anderson

SMSDK = ../..
SRCDS_BASE = ~/srcds
HL2SDK_L4D2 = ../../../hl2sdk-l4d2
MMSOURCE17 = ../../../mmsource-central

#####################################
### EDIT BELOW FOR OTHER PROJECTS ###
#####################################

PROJECT = left4downtown

OBJECTS = sdk/smsdk_ext.cpp extension.cpp natives.cpp vglobals.cpp util.cpp asm/asm.c player_slots.cpp detours/detour.cpp detours/spawn_tank.cpp detours/spawn_witch.cpp detours/clear_team_scores.cpp detours/set_campaign_scores.cpp detours/server_player_counts.cpp detours/first_survivor_left_safe_area.cpp detours/mob_rush_start.cpp detours/try_offering_tank_bot.cpp detours/get_script_value_int.cpp codepatch/patchmanager.cpp

##############################################
### CONFIGURE ANY OTHER FLAGS/OPTIONS HERE ###
##############################################

C_OPT_FLAGS = -DNDEBUG -O3 -funroll-loops -pipe -fno-strict-aliasing
C_DEBUG_FLAGS = -D_DEBUG -DDEBUG -g -ggdb3
C_GCC4_FLAGS = -fvisibility=hidden
CPP_GCC4_FLAGS = -fvisibility-inlines-hidden
CPP = gcc

HL2PUB = $(HL2SDK_L4D2)/public
HL2LIB = $(HL2SDK_L4D2)/lib/linux
CFLAGS += -DSOURCE_ENGINE=6 -DTARGET_L4D2=1 -DTARGET_L4D=0
METAMOD = $(MMSOURCE17)/core
INCLUDE += -I$(HL2SDK_L4D2)/public/game/server -I$(HL2SDK_L4D2)/common -I$(HL2SDK_L4D2)/game/shared
SRCDS = $(SRCDS_BASE)/left4dead2
GAMEFIX = 2.l4d2

LINK += $(HL2LIB)/tier1_i486.a $(HL2LIB)/mathlib_i486.a libvstdlib.so libtier0.so

INCLUDE += -I. -I.. -Isdk -I$(HL2PUB) -I$(HL2PUB)/engine -I$(HL2PUB)/mathlib -I$(HL2PUB)/tier0 \
        -I$(HL2PUB)/tier1 -I$(METAMOD) -I$(METAMOD)/sourcehook -I$(SMSDK)/public -I$(SMSDK)/public/extensions \
        -I$(SMSDK)/public/sourcepawn

CFLAGS += -DSE_EPISODEONE=1 -DSE_DARKMESSIAH=2 -DSE_ORANGEBOX=3 -DSE_ORANGEBOXVALVE=4 -DSE_LEFT4DEAD=5 -DSE_LEFT4DEAD2=6

LINK += -m32 -ldl -lm

CFLAGS += -D_LINUX -Dstricmp=strcasecmp -D_stricmp=strcasecmp -D_strnicmp=strncasecmp -Dstrnicmp=strncasecmp \
        -D_snprintf=snprintf -D_vsnprintf=vsnprintf -D_alloca=alloca -Dstrcmpi=strcasecmp -Wall -Werror -Wno-switch \
        -Wno-unused -mfpmath=sse -msse -DSOURCEMOD_BUILD -DHAVE_STDINT_H -m32

CPPFLAGS += -Wno-non-virtual-dtor -fno-exceptions -fno-rtti -fno-threadsafe-statics

################################################
### DO NOT EDIT BELOW HERE FOR MOST PROJECTS ###
################################################

ifeq "$(DEBUG)" "true"
	BIN_DIR = Debug
	CFLAGS += $(C_DEBUG_FLAGS)
else
	BIN_DIR = Release
	CFLAGS += $(C_OPT_FLAGS)
endif

BIN_DIR := $(BIN_DIR).$(ENGINE)

OS := $(shell uname -s)
ifeq "$(OS)" "Darwin"
	LINK += -dynamiclib
	BINARY = $(PROJECT).ext.$(GAMEFIX).dylib
else
	LINK += -static-libgcc -shared
	BINARY = $(PROJECT).ext.$(GAMEFIX).so
endif

GCC_VERSION := $(shell $(CPP) -dumpversion >&1 | cut -b1)
ifeq "$(GCC_VERSION)" "4"
	CFLAGS += $(C_GCC4_FLAGS)
	CPPFLAGS += $(CPP_GCC4_FLAGS)
endif

OBJ_LINUX := $(OBJECTS:%.cpp=$(BIN_DIR)/%.o)

$(BIN_DIR)/%.o: %.cpp
	$(CPP) $(INCLUDE) $(CFLAGS) $(CPPFLAGS) -o $@ -c $<

all:
	mkdir -p $(BIN_DIR)/sdk
	mkdir -p $(BIN_DIR)/detours
	mkdir -p $(BIN_DIR)/codepatch
	cp $(SRCDS)/bin/libvstdlib.so libvstdlib.so;
	cp $(SRCDS)/bin/libtier0.so libtier0.so;
	$(MAKE) -f Makefile extension

extension: $(OBJ_LINUX)
	$(CPP) $(INCLUDE) $(OBJ_LINUX) $(LINK) -o $(BIN_DIR)/$(BINARY)

debug:
	$(MAKE) -f Makefile all DEBUG=true

default: all

clean:
	find $(BIN_DIR) -iname *.o | xargs rm -f
	rm -rf $(BIN_DIR)/$(BINARY)
	rm ./*.so