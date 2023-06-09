ifneq ($(gbsystem),gbc)
gbsystem = gb
TIM_BASE = 262144
SPEED = ss
FIXER = -v -t "GBAP3DMG" -m 0x19 -p 0 $@
endif

ifeq ($(gbsystem),gbc)
TIM_BASE = 524288
SPEED = ds
FIXER = -C -v -t "GBAP3GBC" -m 0x19 -p 0 $@
endif

ifeq ($(channels),mono)
AUD_CHANNELS = 1
else
AUD_CHANNELS = 2
channels = stereo
endif

ifeq ($(playback),)
playback = leg
ifeq ($(AUD_CHANNELS),1)
BANKSAMPLES = 32768
else
BANKSAMPLES = 16384
endif
endif

ifeq ($(playback),shq)
pcm_fmt = s16le
aud_codec = pcm_s16le
ifeq ($(AUD_CHANNELS),1)
BANKSAMPLES = 8192
else
BANKSAMPLES = 5461
endif
else
pcm_fmt = u8
aud_codec = pcm_u8
ifeq ($(playback),hq)
ifeq ($(AUD_CHANNELS),1)
BANKSAMPLES = 16384
else
BANKSAMPLES = 8192
endif
endif
endif

BANKS ?= 511

ifeq ($(romsize),4)
BANKS = 255
ifeq ($(romsize),2)
BANKS = 127
ifeq ($(romsize),1)
BANKS = 63
endif
endif
endif

FFMPEG := ffmpeg -loglevel warning -stats -hide_banner

DURATION := $(shell ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $(SOURCE))
DURATION := $(shell echo "scale=1; $(DURATION) + 1" | bc -l)
DURATION := $(shell printf "%.0f" $(DURATION))
$(info Audio duration is ${DURATION} seconds)

samples_per_rom = $(shell expr $(BANKSAMPLES) \* $(BANKS))

raw_samplerate := $(shell echo "scale=6; $(samples_per_rom)/$(DURATION)" | bc -l)
raw_samplerate := $(shell printf "%.0f" $(raw_samplerate))

div := $(shell echo "scale=1; ($(TIM_BASE)/$(raw_samplerate)) + 1" | bc -l)
div := $(shell printf "%.0f" $(div))

ifeq ($(playback),shq)
ifeq ($(AUD_CHANNELS),2)
div := $(shell if [ $(div) -lt 16 ]; then printf "16"; else printf $(div); fi)
else
div := $(shell if [ $(div) -lt 14 ]; then printf "14"; else printf $(div); fi)
endif
else
div := $(shell if [ $(div) -lt 12 ]; then printf "12"; else printf $(div); fi)
endif

ifeq ($(samplerate),)
samplerate := $(shell echo "scale=1; ($(TIM_BASE)/$(div))" | bc -l)
endif
samplerate := $(shell printf "%.0f" $(samplerate))

$(info Sample rate is ${samplerate}Hz)

OUT := output/$(basename $(notdir $(SOURCE)))

BUILD := output/build

$(shell if [ -d $(OUT) ]; then rm $(OUT)/*; fi)
$(shell	if [ -d $(BUILD) ]; then rm $(BUILD)/*; fi)

$(shell mkdir -p $(OUT))
$(shell mkdir -p $(BUILD))

CC ?= clang

TITLE = "\033[1m\033[36m"
TITLE_END = "\033[0m"

ASM_SOURCE = $(SPEED)_$(playback)_$(channels)

MAIN_ASM = output/build/$(ASM_SOURCE).asm
MAIN_ROM_IN = output/build/audio.$(gbsystem)
MAIN_ROM_OUT = $(OUT)/$(basename $(notdir $(SOURCE))).$(gbsystem)

all: $(MAIN_ASM) $(MAIN_ROM_IN) $(MAIN_ROM_OUT)

$(MAIN_ROM_OUT): output/build/audio.$(gbsystem) $(OUT)/audio_encoded.raw
	@echo $(TITLE)Creating audio ROM...$(TITLE_END)
	cat $^ > $@
	rgbfix $(FIXER)

$(MAIN_ASM): src/$(ASM_SOURCE).asm output/build/div.asm src/timer_init.asm
	@echo $(TITLE)Attaching player components...$(TITLE_END)
	cat $^ > $@
	
$(MAIN_ROM_IN): output/build/$(ASM_SOURCE).asm
	@echo $(TITLE)Compiling player...$(TITLE_END)
	rgbasm -o $@.o $^
	rgblink -o $@ $@.o

output/build/encoder: encoder.c
	@echo $(TITLE)Cleaning build folder and compiling encoder...$(TITLE_END)
	rm -r $(BUILD)
	mkdir $(BUILD)
	$(CC) -g -Ofast -std=c11 -Werror -Wall -o $@ $^

$(OUT)/audio.raw: $(SOURCE)
	@echo $(TITLE)Extracting PCM audio...$(TITLE_END)
	$(eval GAIN := 0$(shell ffmpeg -i $^ -filter:a volumedetect -f null /dev/null 2>&1 | sed -n "s/.*max_volume: -\(.*\) dB/\1/p"))
	$(FFMPEG) -i $^ -f $(pcm_fmt) -acodec $(aud_codec) -ar $(samplerate) -ac $(AUD_CHANNELS) -filter:a "volume=$(GAIN)dB" $@ 

$(OUT)/audio_encoded.raw output/build/div.asm: output/build/encoder $(OUT)/audio.raw
	@echo $(TITLE)Encoding audio...$(TITLE_END)
	output/build/encoder $(basename $(notdir $(SOURCE))) $(playback) $(AUD_CHANNELS) $(div)