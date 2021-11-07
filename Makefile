ifneq ($(gbsystem),gbc)
gbsystem = gb
TIM_BASE = 262144
div ?= 16
SPEED = ss
FIXER = -v -t "GBAP3DMG" -m 0x19 -p 0 $@
endif

ifeq ($(gbsystem),gbc)
TIM_BASE = 524288
div ?= 32
SPEED = ds
FIXER = -C -v -t "GBAP3GBC" -m 0x19 -p 0 $@
endif

ifeq ($(playback),shq)
pcm_fmt = s16le
aud_codec = pcm_s16le
else
pcm_fmt = u8
aud_codec = pcm_u8
endif

ifeq ($(playback),)
playback = leg
endif

ifeq ($(channels),mono)
AUD_CHANNELS = 1
else
AUD_CHANNELS = 2
channels = stereo
endif

OUT := output/$(basename $(notdir $(SOURCE)))

BUILD = output/build

$(shell if [ -d $(OUT) ] then rm $(OUT)/*)
$(shell if [ -d $(BUILD) ] then rm $(BUILD)/*)

$(shell mkdir -p $(OUT))

CC ?= clang
FFMPEG := ffmpeg -loglevel warning -stats -hide_banner
samplerate ?= $(shell expr $(TIM_BASE) / $(div))

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