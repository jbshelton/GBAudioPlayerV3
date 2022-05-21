# GBAudioPlayerV3
Version 3 of the incredible Gameboy Audio Player, rebuilt from the ground up in C as a command line program, along with heavily improved playback quality and a new encoding option\!

### What is GBAudioPlayerV3?
GBAudioPlayerV3 is a continuation of GBAudioPlayerV2 that, of course, allows you to listen to \(high\-quality\) music on \(almost\) any Gameboy\!

---

#### Improvements in Version 3\.0
- The encoding is now lightning fast
- HQ playback is MUCH less noisy
- Added SHQ playback \(which I'll explain\) which is also much less noisy than my first \(unreleased\) iterations of it

---

#### List of Patch Changes
November 2021:
- Fixed unsquashed bugs that caused encoder to not function on release \(yes, I accidentally released unfinished code lol\)
- Added automatic sample rate/divider calculation based on common ROM sizes \(no more complicated math\)
- Added a cool descriptive timeline of my journey creating this audio player\!
- Temporarily removed "how it works" section

December 2021:
- Fixed SHQ not playing at the highest sample rate it could

April 2022:
- Fixed HQ playback for the original Gameboy not playing at the highest sample rate it could

May 2022:
- Fixed low volume issue with Legacy playback code \(forgot to initialize master volume register\)
- Fixed Legacy and HQ ROMs not playing back on 256M bootleg multicarts

---

#### Features
- Can specify the sample rate of the audio to adjust playback speed
- Configuration for both the original Gameboy and Gameboy Color
- Select from stereo and mono configuration for input audio
- 3 different native playback formats supported: Legacy, HQ and SHQ\.

---

#### Audio Playback Formats
- Legacy is the lowest quality of the three playback formats\. The output is 4 bit mono or stereo, meaning there are 16 total audio output levels\. It sounds just fine for audio that already sounds distorted or is consistently loud \(like metal/rock music,\) but does not do well with quiet/soft audio \(like classial music\.\)

- HQ \(which stands for High Quality\) is the second highest quality playback format\. It can be played at the same max sample rate as Legacy, meaning up to 21\.845KHz on the original Gameboy and 43\.691KHz on the Gameboy Color\. It has almost the same quality as 8 bit audio, which has 256 output levels; however, HQ only has 104 total output levels, which are distributed nonlinearly, getting farther apart the farther they get from the audio "zero line"\. IMO, HQ is the most versatile of the playback formats\.

- SHQ \(which stands for Super High Quality\) is the highest quality playback format\. It requires slightly more processing power than Legacy and HQ, which reduces the max sample rate to 16\.384KHz on the original Gameboy and 32\.768KHz on the Gameboy Color\. It has almost the same quality as 9 or 10 bit audio, which have 512 and 1024 output levels respectively, but SHQ has just 226 of them, distributed in a manner similarly to HQ\. It also takes up the most ROM space, and doesn't sound as good on the original Gameboy as the Gameboy Color, so it's a bit less practical than HQ\.

---

#### Dependencies
You still have to have various things installed on your system (though less than GBAudioPlayerV2\.) There's tutorials everywhere, so I'm not going to explain all of it\. These are:
- GCC
- [RGBDS](https://rgbds.gbdev.io/)
- FFMPEG

And if you're running Windows:
- WSL \(Windows Subsystem for Linux\) \(or any other Linux\-compatible CLI\)

If you have a Mac, I'm not sure how the Linux shell works on it, so if you can help me add instructions specifically for Mac systems then I would really appreciate it\!

---

#### How to make a ROM
First, place your audio file into the main GBAudioPlayerV3 directory \(where this README is located\.\) If it has any spaces in it, make sure to put quotations around the file when you make the ROM, like this: `"Obligatory Example File.mp3"`\. If that doesn't work, rename it to something that doesn't use spaces \(I usually replace spaces with underscores\- `obligatory_example_file.mp3`\.\)

Second, determine what system you're using, if you want the audio to be stereo or mono, and what playback method you want to use\. The system is configured by entering either `gbsystem=gb` for the original Gameboy, and `gbsystem=gbc` for the Gameboy Color\. \(Audio ROMs made for the original Gameboy are compatible with the Gameboy Color\.\)

Now, configure the other settings for the output audio:
- Mono audio is `channels=mono`, stereo is `channels=stereo`\. 
- For the playback method, type `playback=leg` for Legacy, `playback=hq` for High Quality, or `playback=shq` for Super High Quality\. 
- For ROM size, it defaults to 8 megabytes\. You can choose between 4, 2 and 1 megabytes by specifycing `romsize=4`, `romsize=2` or `romsize=1`\. I highly recommend you stick with 8 megabytes if you can, since the audio usually takes up a lot of space, and using the biggest ROM space option allows for higher sample rate audio\!

Here's what the full thing should look like \(use this as sort of a template I guess\):
`make SOURCE="Obligatory Example File.mp3" gbsystem=gb playback=hq channels=stereo`

This should produce an audio ROM for the original Gameboy that uses the HQ playback method in stereo\.
Additionally, you can override the input sample rate \(to make the audio play faster or slower\) by typing in `samplerate=` and an integer\. Higher rates will play back slower, and lower rates will play back faster\. For example, specifying `samplerate=16000` if the output sample rate is 16,384Hz \(if you run the encoder once to find out\) will cause the audio to play slightly fast since the input sample rate is lower than the rate the Gameboy plays it back at\. I recommend only using slower sample rates than the provided sample rate in order to not overflow the max amount of ROM space\!

---

### Congrats\! You should now have an audio file that's playable on a real Gameboy\!

---

#### A few things to note
- None of the encoding methods will work properly on a Gameboy Advance \(and the Gameboy Player by extension\), due to it using a digital method of mixing audio that doesn't emulate the analog behavior properly at all\. I apologize for everyone who only has a GBA :\(
- HQ and SHQ on DMG may sound a bit whiny at lower sample rates \(caused by using a smaller ROM setting or a longer audio track\) due to the method I implemented for reducing noise
- Legacy uses the least amount of ROM, and SHQ uses the most space\. Specifically, you can only fit slightly less than 1/3rd the amount of stereo SHQ audio in a cartridge compared to stereo Legacy audio\.

---

#### Planned updates
- A max sample rate calculator to cap the manually altered `samplerate` parameter
- A modified version of Lesserkuma's [256M ROM builder](https://github.com/lesserkuma/256M_ROM_Builder) with a custom menu that allows the audio playback code to fit in the same space as the menu so that 4 8MB audio ROMs can fit onto a 36MB multicart instead of just 3 8MB ROMs
- Deconstruction/debug ROM capability so that anyone can make GBPCM oscilloscope deconstruction videos with either an accurate emulator or real hardware

---

#### Possible updates
- A simple pause/play/scrub system that utilizes joypad interrupts
- A static thumbnail/album cover to show on the screen while the audio is playing
- TPP1 mapper support \(for emulators only at this point\)
- A rudimentary GUI that has arbitrary path support \(can get the audio file from anywhere on your computer\)
