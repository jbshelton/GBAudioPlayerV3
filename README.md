# GBAudioPlayerV3
Version 3\.1 of the incredible Gameboy Audio Player, rebuilt from the ground up in C as a command line program, along with heavily improved playback quality and a new encoding option\!

#### What is GBAudioPlayerV3?
GBAudioPlayerV3 is a continuation of GBAudioPlayerV2 that, of course, allows you to listen to \(high\-quality\) music on \(almost\) any Gameboy\!

---

#### Improvements in Version 3\.0
- The encoding is now lightning fast
- HQ playback is MUCH less noisy
- Added SHQ playback \(which I'll explain\) which is also much less noisy than my first \(unreleased\) iterations of it

---

#### Thanksgiving Weekend Patch 3\.1 Changes
- Fixed unsquashed bugs that caused encoder to not function on release \(yes, I accidentally released unfinished code lol\)
- Added automatic sample rate/divider calculation based on common ROM sizes \(no more complicated math\)
- Added a cool descriptive timeline of my journey creating this audio player\!
- Temporarily removed "how it works" section

---

#### Features
- Can specify the sample rate of the audio to adjust playback speed
- Configuration for both the original Gameboy and Gameboy Color
- Select from stereo and mono configuration for input audio
- 3 different encoding formats supported: Legacy, HQ and SHQ \(covered later\)

---

#### Dependencies
You still have to have various things installed on your system (though less than GBAudioPlayerV2\.) There's tutorials everywhere, so I'm not going to explain all of it\. These are:
- GCC
- [RGBDS](https://rgbds.gbdev.io/)
- FFMPEG

And if you're running Windows:
- WSL \(Windows Subsystem for Linux\) \(or any other Linux\-compatible CLI\)

---

#### How to make a ROM
First, place your audio file into the main GBAudioPlayerV3 directory \(where this README is located\.\) If it has any spaces in it, make sure to put quotations around the file when you make the ROM, like this: `"Obligatory Example File.mp3"`\. If that doesn't work, rename it to something that doesn't use spaces\.

Second, determine what system you're using, if you want the audio to be stereo or mono, and what playback method you want to use\. The system is configured by entering either `gbsystem=gb` for the original Gameboy, and `gbsystem=gbc` for the Gameboy Color\.

Now, configure the other settings for the output audio:
- Mono audio is `channels=mono`, stereo is `channels=stereo`\. 
- For the playback method, type `playback=leg` for Legacy, `playback=hq` for High Quality, or `playback=shq` for Super High Quality\. 
- For ROM size, it defaults to 8 megabytes\. You can choose between 4, 2 and 1 megabytes by specifycing `romsize=4`, `romsize=2` or `romsize=1`\. I highly recommend you stick with 8 megabytes if you can, since the audio usually takes up a lot of space\!

Here's what the full thing should look like \(use this as sort of a template I guess\):
`make SOURCE="Obligatory Example File.mp3" gbsystem=gb playback=hq channels=stereo div=16`

This should produce an audio ROM for the original Gameboy that uses the HQ playback method in stereo at 16,384Hz\.
Additionally, you can override the input sample rate \(to make the audio play faster or slower\) by typing in `samplerate=` and an integer\. Higher rates will play back slower, and lower rates will play back faster\. For example, specifying `samplerate=16000` will cause the audio to play slightly fast since the input sample rate is lower than the rate the Gameboy plays it back at\.

---

### Congrats\! You should now have an audio file that's playable on a real Gameboy\!

---

#### A few things to note
- None of the encoding methods will work properly on a Gameboy Advance \(and the Gameboy Player by extension\), due to it using a digital method of mixing audio that doesn't emulate the analog behavior properly at all\. I apologize for everyone who only has a GBA :\(
- HQ and SHQ on DMG may sound a bit whiny at the sample rate due to the method I implemented for reducing noise
- Legacy uses the least amount of ROM, and SHQ uses the most space\. Specifically, you can only fit slightly less than 1/3rd the amount of stereo SHQ audio in a cartridge compared to stereo Legacy audio\.

---

#### Planned updates
- Deconstruction/debug ROM capability so that anyone can make GBPCM oscilloscope deconstruction videos \(mostly done, but not complete at time of patch 3\.1\)

---

#### Possible updates
- TPP1 mapper support
- A rudimentary GUI that has arbitrary path support \(can get the audio file from anywhere on your computer\)
