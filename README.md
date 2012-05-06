AVPlayerWithTrackSelector
=========================

This is a very basic AVPlayer implementation that allows you to play/pause a video
as well as modify the audio settings if other tracks exist.

**WARNING**

This takes advantage of selectors only available in iOS5 and greater.

This was quick and dirty, borrowing mostly from Apple's 
[AVFoundation Programming Guide](http://developer.apple.com/library/ios/#DOCUMENTATION/AudioVideo/Conceptual/AVFoundationPG/Articles/02_Playback.html#//apple_ref/doc/uid/TP40010188-CH3-SW2), with some of my work
layered on.

-------
**Classes**

* AudioTrackSelectorViewController - This is the class that actually does the selection of the alternate tracks.
* PlayerViewController - A very basic playback view controller with some controls.
* PlayerView - Standard AVPlayerLayer view.

There's some interesting things that seem to happen with the tracks in that you'll see doubles of each subtitle track listed. One of the tracks will be listed as a forced sub track with a reference pointing to the other track it seems. I haven't tracked down exactly what this is, but just be aware it's there.

Please feel free to open an issue on the Github page for this project to discuss issues you see, or are having with the project. Additionally, please reach out to me on Twitter if you'd like, [@brianmichel](http://www.twitter.com/brianmichel).

Enjoy!