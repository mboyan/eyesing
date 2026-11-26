s.reboot;
s.meter;
s.plotTree;

(
SynthDef(\playbufDouble, {
	|out=0, loop=1, rateMidiNote=57, bufA=0, bufB=0, bufDelayA=0, bufDelayB=0, bufLFO=0, gate=0, atk=0.01, dec=0.3, susLvl=0.5, rel=1.0, rateLFO=0.001, ampLFO=0.0|
	var sig, sigDelay, rate, env, lfo;//, rateCtrl, latchCtrl;

	//latchCtrl = LFPulse.kr(3);
	//rateCtrl = Latch.kr(LFSaw.kr(0.75), latchCtrl).linexp(-1, 1, 0.5, 1);

	rate = rateMidiNote.midicps / 220.0;

	env = EnvGen.ar(Env.adsr(atk, dec, susLvl, rel), gate);

	sigDelay = [
		PlayBuf.ar(1, bufDelayA, rate*BufRateScale.ir(1, bufDelayA), loop:loop),
		PlayBuf.ar(1, bufDelayB, rate*BufRateScale.ir(1, bufDelayB), loop:loop)
	];
	sig = [
		PlayBuf.ar(1, bufA, rate*BufRateScale.ir(1, bufA), loop:loop),
		PlayBuf.ar(1, bufB, rate*BufRateScale.ir(1, bufB), loop:loop)
	];
	lfo = PlayBuf.ar(1, bufLFO, rateLFO*BufRateScale.ir(1, bufLFO), loop:loop).range(0, 1);
	// sig.scope;
	lfo.scope;
	// sig = 0.75*sig + (0.25*sigDelay);
	sig = 0.5*sig + (0.25*sigDelay) + (0.125*Delay1.ar(sig)) + (0.0675*Delay1.ar(sigDelay));
	// sig = sig[1] - sig[0];
	// sig = IFFT(PV_MagMul(FFT(LocalBuf(1024), WhiteNoise.ar), bufnumA));
	// Out.ar(out, sig*env*(1.0 + ((lfo - 1.0)*ampLFO)));
	// sig = FreeVerb.ar(sig*env*(1.0 + ((lfo - 1.0)*ampLFO)));
	sig = AllpassC.ar(sig*env*(1.0 + ((lfo - 1.0)*ampLFO)), 0.2, 0.05, 0.02, 2.0);
	Out.ar(out, sig);
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

ServerOptions.devices[1]
s.options.outDevice_(ServerOptions.devices[1])

s.options.outDevice

{SinOsc.ar(40, mul:0.5)}.play