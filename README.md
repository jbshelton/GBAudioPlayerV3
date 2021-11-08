# GBAudioPlayerV3
Version 3\.0 of the incredible Gameboy Audio Player, rebuilt from the ground up in C as a command line program, along with heavily improved playback quality and a new encoding option\!

#### What is GBAudioPlayerV3?
GBAudioPlayerV3 is a continuation of GBAudioPlayerV2 that, of course, allows you to listen to \(high\-quality\) music on \(almost\) any Gameboy\!

---

#### Improvements in Version 3\.0
- The encoding is now lightning fast
- HQ playback is MUCH less noisy
- Added SHQ playback (which I'll explain) which is also much less noisy than my first \(unreleased\) iterations of it

---

#### Features
- Can specify the sample rate of the audio to override the timer divider
- Configuration for both the original Gameboy and Gameboy Color
- Select from stereo and mono configuration for input audio
- 3 different encoding formats supported: Legacy, HQ and SHQ \(covered later\)

---

#### Dependencies
You still have to have various things installed on your system (though less than GBAudioPlayerV2\.) There's tutorials everywhere, so I'm not going to explain all of it\. These are:
- GCC
- RGBDS \(Rednex Game Boy Development System\) \(Only tested with version 0\.4\.2, YMMV\)
- FFMPEG

And if you're running Windows:
- WSL \(Windows Subsystem for Linux\) \(or any other Linux\-compatible CLI\)

---

#### How to make a ROM
First, you need to define your sample rate\. This is done by using the `div` variable on your CLI\. The number is how much you want to divide the base timer frequency to get your desired sample rate\. On the original Gameboy, the base frequency is 262,144Hz, and on the Gameboy Color, it's 524,288Hz\. The number must be an integer, and the sample rate must not exceed what I describe in the 'a few things to note' section \(so go read that\.\) The optimal timer divider for the sample rate can be calculated with this method:
- Take the cartridge size \(8MB is 8,388,608 bytes, 4MB is 4,194,304 bytes, etc\.\) and subtract 16,384 from it
- Divide that number by how long the audio is in seconds, then divide that number by 2 if the audio is stereo, or if you want to use the Legacy playback method\. I'll cover the SHQ equation later\.
- Divide the base timer frequency by that number and truncate the result so there are no decimals

Second, place your audio file into the main GBAudioPlayerV3 directory \(probably where this README is located\.\) If it has any spaces in it, make sure to put quotations around the file when you make the ROM, like this: `"Obligatory Example File.mp3"`\. If that doesn't work, rename it to something that doesn't use spaces\.

Lastly, determine what system you're using, if you want the audio to be stereo or mono, and what playback method you want to use\. The system is configured by entering either `gbsystem=gb` for the original Gameboy, and `gbsystem=gbc` for the Gameboy Color; mono audio is `channels=mono`, stereo is `channels=stereo`; and either `playback=leg` for Legacy, `playback=hq` for High Quality, or `playback=shq` for Super High Quality\. Here's what the full thing should look like:
`make SOURCE="Obligatory Example File.mp3" gbsystem=gb playback=hq channels=stereo div=16`

This should produce an audio ROM for the original Gameboy that uses the HQ playback method in stereo at 16,384Hz\.
Additionally, you can override the input sample rate \(to make the audio play faster or slower\) by typing in `samplerate=` and an integer\. Higher rates will play back slower, and lower rates will play back faster\.

The method for calculating the maximum sample rate for SHQ audio is a bit different\. For mono audio, use the same calculation method as stereo HQ audio\. For stereo SHQ, however, it's more complicated:
- Take the base cartridge size calculated in step 1 of HQ audio calculation and divide that by 16,384
- Multiply that number by 5,461 \(which is the number of samples that can fit in one bank\), which will result in the number of samples that can fit on the cartridge
- Divide that by the length of the audio in seconds, which will result in the sample rate
- Use the timer divider calculation method I explained earlier

---

#### A few things to note
- None of the encoding methods will work properly on a Gameboy Advance \(and the Gameboy Player by extension\), due to it using a digital method of mixing audio that doesn't emulate the analog behavior properly at all\. I apologize for everyone who only has a GBA :\(
- The maximum sample rate for Legacy and HQ is 23,831Hz on DMG, and 43,690Hz on GBC \(timer dividers of 12; div=12\)
- The maximum sample rate for SHQ is 16,384Hz on DMG, and 32,768Hz on GBC \(timer dividers of 16; div=16\)
- HQ and SHQ on DMG may sound a bit whiny at the sample rate due to the method I implemented for reducing noise
- Legacy uses half as much data as raw 8-bit PCM, HQ uses the same amount of data as 8-bit PCM, and SHQ \(in stereo\) uses 3/4ths the amount of data as 16-bit PCM, but can only use 16,383 out of 16,384 bytes per ROM bank\. Consider that when choosing an audio file to encode\. However, mono SHQ uses the same amount of data as mono 16-bit PCM\.

---

### Congrats\! You should now have an audio file that's playable on a real Gameboy\!

---

#### Planned updates
- Automatic best sample rate calculation with audio length and cartridge size
- Deconstruction/debug ROM capability so that anyone can make GBPCM oscilloscope deconstruction videos \(mostly done, but not complete at time of release\)

---

#### Possible updates
- TPP1 mapper support
- A rudimentary GUI that has arbitrary path support \(can get the audio file from anywhere on your computer\)

---

### Credits, origin story and technical explanation of how it works
This is kind of a copy from GBAudioPlayerV2, but I don't want to force you to go look at that to learn how this audio player works\.
I'm not the first person to get audio playing on a Gameboy\. Far from it\- **LIJI32's GBVideoPlayer2** for the GBC implements stereo 3\-bit PCM with the encoded video, and **ISSOtm's SmoothPlayer** uses a combination of all the Gameboy's channels to produce different DC offsets that are used in combination with the Gameboy's channel mixer to play back stereo 4\-bit samples \(and there's probably plenty of others that I don't know, and a lot of tech demos that play back audio\.\) 
I originally got inspiration from GBVideoPlayer2 because I wanted a way to play back audio on a Gameboy without sacrificing cartridge space for video I didn't need\. So, I went on an adventure to figure out how to play audio on the Gameboy\. It took me just a few weeks \(it was in September or October 2020, I forget lol\) to figure out how to use the pulse channels to play back audio, another week to get a player just using the pulse channels working, and surprisingly only another few weeks after conceptualizing the HQ playback method to get THAT working\. I put that code on Github as GBAudioPlayer \(the crappy first version,\) then I made GBAudioPlayerV2, which worked but was finicky to get working on Windows and Linux and had some things that didn't really work, and now after a year of blood, sweat and tears, the method has been perfected\- and in a package that's hopefully easier to get working than GBAudioPlayerV2\.
In a way, GBAudioPlayerV3 is a combination of GBVideoPlayer2 and SmoothPlayer\- using some of the Gameboy's standard beep\-boop channels and the 3\-bit master volume register\. However, there is one BIG difference: 
**GBAudioPlayerV3's High Quality \(HQ for short\) encoder uses both the pulse volume control and the master volume control to output a much greater range of amplitudes\- 104 total, to be exact, with 8-bit precision\.** 
Basically, it just uses the 3\-bit master volume control as a scaling factor to determine how big the voltage steps of the pulse channels are\.
**In addition, the new encoding method, dubbed Super High Quality \(SHQ for short\) uses the noise and wave channels as offsets on top of the pulse channels\. This allows it to have between 9 and 10 bits of precision, with 226 unique amplitudes\.**
Also, GBAudioPlayerV3 \(and V2\) is \(I believe\) the *only* audio player for both the original Gameboy and Gameboy Color that uses this method of encoding, as well as be able to output that at *near CD\-quality 43,690Hz stereo* on GBC, and about half that on the original GB\.
