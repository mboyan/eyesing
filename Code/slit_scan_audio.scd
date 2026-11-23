s.reboot;
s.meter;
s.plotTree;

(
SynthDef(\playbufDouble, {
	|out=0, loop=1, rateMidiNote=57, bufnumA=0, bufnumB=0, bufDelayA=0, bufDelayB=0, gate=0, atk=0.01, dec=0.3, susLvl=0.5, rel=1.0|
	var sig, sigDelay, rate, env;//, rateCtrl, latchCtrl;

	//latchCtrl = LFPulse.kr(3);
	//rateCtrl = Latch.kr(LFSaw.kr(0.75), latchCtrl).linexp(-1, 1, 0.5, 1);

	rate = rateMidiNote.midicps / 220.0;

	env = EnvGen.ar(Env.adsr(atk, dec, susLvl, rel), gate);

	sigDelay = [
		PlayBuf.ar(1, bufDelayA, rate*BufRateScale.ir(1, bufDelayA), loop:loop),
		PlayBuf.ar(1, bufDelayB, rate*BufRateScale.ir(1, bufDelayB), loop:loop)
	];
	sig = [
		PlayBuf.ar(1, bufnumA, rate*BufRateScale.ir(1, bufnumA), loop:loop),
		PlayBuf.ar(1, bufnumB, rate*BufRateScale.ir(1, bufnumB), loop:loop)
	];
	sig.scope;
	// sig = 0.75*sig + (0.25*sigDelay);
	sig = 0.5*sig + (0.25*sigDelay) + (0.125*Delay1.ar(sig)) + (0.0675*Delay1.ar(sigDelay));
	// sig = sig[1] - sig[0];
	// sig = IFFT(PV_MagMul(FFT(LocalBuf(1024), WhiteNoise.ar), bufnumA));
	Out.ar(out, sig*env);
}).add;
)

/*MIDIClient.init;
MIDIIn.connectAll;

(
MIDIdef.noteOn(
	\opzNoteOn, {
		|...args|
		args.postln;
}).add;
)

MIDIdef.freeAll*/