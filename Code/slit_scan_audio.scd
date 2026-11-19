s.reboot;
s.meter;
s.plotTree;

(
SynthDef(\playbufDouble, {
	|out=0, loop=1, bufnumA=0, bufnumB=0, bufDelayA=0, bufDelayB=0|
	var sig, sigDelay, rateCtrl, latchCtrl;

	latchCtrl = LFPulse.kr(3);
	rateCtrl = Latch.kr(LFSaw.kr(0.75), latchCtrl).linexp(-1, 1, 0.5, 1);

	sigDelay = [
		PlayBuf.ar(1, bufDelayA, rateCtrl*BufRateScale.ir(1, bufDelayA), loop:loop),
		PlayBuf.ar(1, bufDelayB, rateCtrl*BufRateScale.ir(1, bufDelayB), loop:loop)
	];
	sig = [
		PlayBuf.ar(1, bufnumA, rateCtrl*BufRateScale.ir(1, bufnumA), loop:loop),
		PlayBuf.ar(1, bufnumB, rateCtrl*BufRateScale.ir(1, bufnumB), loop:loop)
	];
	sig.scope;
	// sig = 0.75*sig + (0.25*sigDelay);
	sig = 0.5*sig + (0.25*sigDelay) + (0.125*Delay1.ar(sig)) + (0.0675*Delay1.ar(sigDelay));
	// sig = sig[1] - sig[0];
	// sig = IFFT(PV_MagMul(FFT(LocalBuf(1024), WhiteNoise.ar), bufnumA));
	Out.ar(out, sig);
}).add;
)