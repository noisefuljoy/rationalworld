/*
laten werken met andere patches
maar 1 patch met dieren
kunnen switchen tussen verena, toy piano en tape
volume, mixage
meer ambient samples
midinoten 31,32,33,34

check inputs
check crash - iets met granulaire synthese tenori-on

*/

(


fork {
	// Require("D:/Dropbox/PROJECTS/SC_performances/tenori-on/Ansage_Ende_01052021/Cologne_tonalities_v2.scd");
	//
	// MIDIClient.init;
	// MIDIIn.connectAll;


/*	5.0.wait;*/


~nyquist = s.sampleRate * 0.5;

SynthDef(\ten_volume, {|out=0 in volume=1|
		var sig = In.ar(in, 2);
		Out.ar(out, [sig[0]*volume, sig[1]*volume]); }).store;

SynthDef(\gerrikicksampler, {|anaBus out amp=0.5 gate=1 pan=0.0 bufnum freq realFreq ratio=1 dur=0.5 pos=0|
	var freqRatio, env, filtenv, sig;
	freqRatio = (freq/realFreq);
	//env = Osc1.ar(envbuf, dur,doneAction:2);
	env = EnvGen.ar(Env.perc(0.25*dur,0.75*dur),gate,doneAction: 2);
	filtenv = EnvGen.ar(Env.perc(0.25*dur,0.75*dur));
	sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*ratio,1,pos*BufFrames.kr(bufnum),loop:0);
	sig = MidEQ.ar(sig, Rand(100,250),0.01,12,4);
	//sig = LPF.ar(sig, (filtenv * 800)+25, 4);
	sig = LPF.ar(sig, (filtenv * 900)+25,4,sig*0.5);
	sig = Compander.ar(sig, sig, 0.5,1,0.5,0.001,0.01,100);
	sig = sig * env * amp * 4;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig );
	Out.ar(anaBus, sig);
}).store;

SynthDef(\gerrihatsampler, {|anaBus out amp=0.5 gate=1 pan=0.0 bufnum freq realFreq ratio=1 dur=0.5 pos=0|
	var freqRatio, env, filtenv, sig;
	freqRatio = (freq/realFreq);
	//env = Osc1.ar(envbuf, dur,doneAction:2);
	env = EnvGen.ar(Env.perc(0.25*dur,0.75*dur),gate,doneAction: 2);
	filtenv = EnvGen.ar(Env.perc(0.25*dur,0.75*dur));
	sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*ratio,1,pos*BufFrames.kr(bufnum),loop:0);
	sig = MidEQ.ar(sig, Rand(6000,8000),0.1,8,2);
	//sig = HPF.ar(sig, 10000 - (filtenv*6000), 4).tanh;
	//sig = HPF.ar(sig, 10000 - (filtenv*4000),4,sig*0.5).tanh;

	sig = Compander.ar(sig, sig, 0.01,1,0.1,0.001,0.01,100);
	sig = sig * env * amp * 8;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig );
	Out.ar(anaBus, sig);
}).store;


SynthDef(\gerrisnaresampler, {|anaBus out amp=0.5 gate=1 pan=0.0 bufnum freq realFreq ratio=1 dur=0.5 pos=0 bitcrush=0.1|
	var freqRatio, env, sig;
	freqRatio = (freq/realFreq);
	//env = Osc1.ar(envbuf, dur,doneAction:2);
	env = EnvGen.ar(Env.perc(0.25*dur,0.75*dur),gate,doneAction: 2);
	sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*ratio,1,pos*BufFrames.kr(bufnum),loop:0);
	sig = MidEQ.ar(sig, Rand(800,1500),0.1,12,2).tanh;
	sig = Decimator.ar(sig, 48000 - (40000*bitcrush),12);
	sig = sig * env * amp * 6;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig );
	Out.ar(anaBus, sig);
}).store;

SynthDef(\gerrifloorsampler, {|anaBus out amp=0.5 gate=1 pan=0.0 bufnum freq realFreq ratio=1 dur=0.5 pos=0 bitcrush=0.1|
	var freqRatio, env, sig;
	freqRatio = (freq/realFreq);
	//env = Osc1.ar(envbuf, dur,doneAction:2);
	env = EnvGen.ar(Env.perc(0.25*dur,0.75*dur),gate,doneAction: 2);
	sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*ratio,1,pos*BufFrames.kr(bufnum),loop:0);
	sig = MidEQ.ar(sig, Rand(500,800),0.1,9,2).tanh;
	sig = LPF.ar(sig, 6000, 2);
	//sig = Decimator.ar(sig, 48000 - (45000*bitcrush),8);
	sig = sig * env * amp * 2;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig );
	Out.ar(anaBus, sig);
}).store;


SynthDef(\snareverb, {|inBus out mix=0.4 room=0.8|
		var in, wet, bpsig;
		in = In.ar(inBus, 2);
		in = FreeVerb2.ar(in[0], in[1], mix, room, 0.6,0.75);
		Out.ar(out, in); }).store;

SynthDef(\gerrisampler, {|anaBus out amp=0.5 gate=1 pan=0.0 bufnum freq realFreq ratio=1 dur=0.5 pos=0|
	var freqRatio, env, sig;
	freqRatio = (freq/realFreq);
	//env = Osc1.ar(envbuf, dur,doneAction:2);
	env = EnvGen.ar(Env.perc(0.25*dur,0.75*dur),gate,doneAction: 2);
	sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*ratio,1,pos*BufFrames.kr(bufnum),loop:0);
	sig = sig * env * amp;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig );
	Out.ar(anaBus, sig);
}).store;

SynthDef(\gerripad1sampler, {|anaBus out amp=0.5 gate=1 pan=0.0 bufnum freq realFreq ratio=1 dur=0.5 pos=0|
	var freqRatio, env, sig;
	freqRatio = (freq/realFreq);
	//env = Osc1.ar(envbuf, dur,doneAction:2);
	env = EnvGen.ar(Env.perc(0.25*dur,0.75*dur),gate,doneAction: 2);
	sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*ratio,1,pos*BufFrames.kr(bufnum),loop:0);
	sig = MidEQ.ar(sig, Rand(1000,1500),0.1,12,2).tanh;
	sig = BPF.ar(sig, 1250,0.6,2);
	sig = sig * env * amp * 10;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig );
	Out.ar(anaBus, sig);
}).store;

SynthDef(\gerripad2sampler, {|anaBus out amp=0.5 gate=1 pan=0.0 bufnum freq realFreq ratio=1 dur=0.5 pos=0|
	var freqRatio, env, sig;
	freqRatio = (freq/realFreq);
	//env = Osc1.ar(envbuf, dur,doneAction:2);
	env = EnvGen.ar(Env.perc(0.25*dur,0.75*dur),gate,doneAction: 2);
	sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*ratio,1,pos*BufFrames.kr(bufnum),loop:0);
	sig = MidEQ.ar(sig, Rand(1500,2000),0.1,9,2).tanh;
	sig = BPF.ar(sig, 1750,0.5,2.0);
	sig = sig * env * amp * 10;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig );
	Out.ar(anaBus, sig);
}).store;

SynthDef(\gerripad3sampler, {|anaBus out amp=0.5 gate=1 pan=0.0 bufnum freq realFreq ratio=1 dur=0.5 pos=0|
	var freqRatio, env, sig;
	freqRatio = (freq/realFreq);
	//env = Osc1.ar(envbuf, dur,doneAction:2);
	env = EnvGen.ar(Env.perc(0.25*dur,0.75*dur),gate,doneAction: 2);
	sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*ratio,1,pos*BufFrames.kr(bufnum),loop:0);
	sig = MidEQ.ar(sig, Rand(2000,2500),0.1,9,2).tanh;
	sig = BPF.ar(sig, 2250,0.3,2);
	sig = sig * env * amp * 10;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig );
	Out.ar(anaBus, sig);
}).store;

SynthDef(\gerripad4sampler, {|anaBus out amp=0.5 gate=1 pan=0.0 bufnum freq realFreq ratio=1 dur=0.5 pos=0|
	var freqRatio, env, sig;
	freqRatio = (freq/realFreq);
	//env = Osc1.ar(envbuf, dur,doneAction:2);
	env = EnvGen.ar(Env.perc(0.25*dur,0.75*dur),gate,doneAction: 2);
	sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*ratio,1,pos*BufFrames.kr(bufnum),loop:0);
	sig = MidEQ.ar(sig, Rand(2500,3000),0.5,9,1.5).tanh;
	sig = BPF.ar(sig, 2750,0.5,2);
	sig = sig * env * amp * 10;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig );
	Out.ar(anaBus, sig);
}).store;

SynthDef(\sidechainer, {|out=0 inBus controlBus thresh=0.1 ratio=0.1 controlgain=0.5 volume=1|
			var in,control,sig1,sig2;
			in = In.ar(inBus, 2);
			control = In.ar(controlBus, 2);
			sig1 = Limiter.ar(Compander.ar(in[0],in[0],thresh,1,ratio,0.001,0.1,(1/ratio)*0.5,in[0]*0.5),1,0.001);
			sig2 = Limiter.ar(Compander.ar(in[1],in[1],thresh,1,ratio,0.001,0.1,(1/ratio)*0.5,in[1]*0.5),1,0.001);
			Out.ar(out, [sig1*volume, sig2*volume]); }).store;

SynthDef(\compressor, {|out=0 inBus thresh=0.1 ratio=0.1 gain=1|
			var in,control,sig1,sig2;
			in = In.ar(inBus, 2);
			sig1 = Limiter.ar(Compander.ar(in[0],in[0],thresh,1,ratio,0.001,0.1,1/ratio),1,0.001)*gain;
			sig2 = Limiter.ar(Compander.ar(in[1],in[1],thresh,1,ratio,0.001,0.1,1/ratio),1,0.001)*gain;
			Out.ar(out, [sig1, sig2]);
			//Out.ar(out, in);
		}).store;

SynthDef(\radiorecorder, {|in bufnum|
	var input = In.ar(in, 1);
	input = Limiter.ar(input,1, 0.001);
	//input = Compander.ar(input, input, 0.1, 1, 0.1, 0.001, 0.1,10);
	//input = Compander.ar(input, input, 0.001,1,0.01,0.001,0.1,50);
	//for hardware input
	//RecordBuf.ar(SoundIn.ar(in),bufnum);
	//for bus
	RecordBuf.ar(input,bufnum);
}).store;

//SYNTHS
//second generation sampler
SynthDef(\recrecorder, {|in bufnum|
	//for hardware input
	//RecordBuf.ar(SoundIn.ar(in),bufnum);
	//for bus
	var input = In.ar(in, 1);
	input = Compander.ar(input, input, 0.001,1,0.01,0.001,0.1,200);
	//input = Compander.ar(input, input, 0.001,1,0.01,0.001,0.1,50);
	RecordBuf.ar(input,bufnum,loop:0,doneAction:2);
}).store;
//sampleplayer

SynthDef(\radioplay, {|out amp mainvolBus start end release=0.005 trig=1 octave=1 reverse=1 vectorOut bufnum xpan= -0.5 ypan=1.0 nyquist sampleRate|
	//var start = In.kr(startBus, 1);
	var mainvol = In.kr(mainvolBus, 1);
	var loopdur = (end - start)/sampleRate*(1/octave);

	var trigger = EnvGen.kr(Env([1,0],[loopdur*0.95]),1);
	var env = EnvGen.ar(Env.adsr(loopdur*0.3,loopdur*0.1,1,loopdur*0.05),trigger,doneAction:2);
	var sig = BufRd.ar(1, bufnum, Phasor.ar(trig, BufRateScale.kr(bufnum)*reverse*octave,start,end ),loop: 0) * env * amp;
	//var sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum),trig, loop: 1);
	//Out.ar(out, Pan2.ar(sig, LFNoise1.kr(Rand(0.8,3.2)).range(pan,pan+0.25)));
	//loopdur.poll;
	//Out.ar(out, Pan4.ar(sig, LFNoise2.kr(Rand(0.1,6.4)).range(xpan,xpan+1.0),LFNoise2.kr(Rand(0.1,14.4)).range(ypan,ypan+1.0,)));
	sig = LPF.ar(sig, nyquist);
	sig = HPF.ar(sig, 30,2);
	//Out.ar(out, Pan2.ar(sig*mainvol, LFNoise1.kr(Rand(0.8,3.2)).range(-0.5,0.5)));
	Out.ar(out, Pan2.ar(sig*mainvol,0) );
	Out.ar(vectorOut,sig);
}).store;

//synth for granular patterns
SynthDef(\radioplaypattern, {|out=0 ampBus lengthBus start=0 endBus octave=1 trig=1 reverse=1 bufnum envbuf xpos=0 ypos=0 vectorOut nyquist|
	//var trigger = EnvGen.kr(Env([0,1,0],[0.001,0.001]),trig);
	var amp = In.kr(ampBus, 1);
	var end = In.kr(endBus, 1);
	var length = In.kr(lengthBus, 1);
	var env = Osc1.ar(envbuf, length*Rand(1.0,2.0), doneAction: 2);
	var sig = BufRd.ar(1, bufnum, Phasor.ar(trig, BufRateScale.kr(bufnum)*reverse*octave,start,end ),loop: 1) * env * 0.125;
	sig = LPF.ar(sig, nyquist);
	//Out.ar(out, Pan2.ar(sig*amp, 0));
	Out.ar(out, Pan2.ar(sig*amp, LFNoise0.kr(0.8).range(-1.0,1.0)));
	Out.ar(vectorOut, sig*2);
	}).store;

//for recording zitar
SynthDef(\zitarRecorder, {|in=0 amplitudeBus fftbuf recbuf|
var input = SoundIn.ar(in);
var chain = FFT(fftbuf, input);
var onsets = Onsets.kr(chain,0.3);
var amplitude = Amplitude.kr(input);

input = Compander.ar(input, input, 0.001,1,0.001,0.001,0.1,500);
//amplitude.poll;
RecordBuf.ar(input, recbuf,loop:0,trigger:onsets);
Out.kr(amplitudeBus, amplitude); }).add;


//3rd generation granulation
SynthDef(\regranulate, {|out=0 recOut ampBus lengthBus start=0 endBus octave=1 trig=1 reverse=1 bufnum envbuf pan=0 vectorOut nyquist|
	//var trigger = EnvGen.kr(Env([0,1,0],[0.001,0.001]),trig);
	var amp = In.kr(ampBus, 1);
	var end = In.kr(endBus, 1);
	var length = In.kr(lengthBus, 1);
	var env = Osc1.ar(envbuf, length, doneAction: 2);
	var sig = BufRd.ar(1, bufnum, Phasor.ar(trig, BufRateScale.kr(bufnum)*reverse*octave,start,end ),loop: 1) * env * 0.125;
	//var sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum),trig, loop: 1);
	sig = LPF.ar(sig, nyquist);
	//Out.ar(out, Pan2.ar(sig * amp));
	Out.ar(out, Pan2.ar(sig * amp, LFNoise0.kr(0.9).range(-1.0,1.0)) );
	Out.ar(recOut, sig*2);
	}).store;

SynthDef(\pumper, {|in out amp=0.5|
	var input = In.ar(in, 1);
	input = Compander.ar(input, input, 0.001,1, 0.001, 0.001,0.1,1000);
	//Out.ar(out, Pan2.ar(input*amp))
	Out.ar(out,  input * amp);
		}).store;


~fftbuffers = Array.fill(2,{Buffer.alloc(s, 1024,1)});


~bike0smpls = Array.fill(2, { Buffer.alloc(s, 1.0 * s.sampleRate, 1); });
~bike1smpls = Array.fill(2, { Buffer.alloc(s, 1.0 * s.sampleRate, 1); });

~samplePath2 = "D:/Samples".asString;
~testSample = Buffer.read(s, ~samplePath2++"/Gamelan/Slentem/SlentemPl1.wav" );
~win1 = Buffer.sendCollection(s, Signal.hammingWindow(1024));

~samNum1 = 0;
~samNum2 = 0;

~fbrecBufs = Array.fill(2, { Array.fill(2, { Buffer.alloc(s, s.sampleRate * 10, 1); }); });
~recrecBufs = Array.fill(2, { Buffer.alloc(s, s.sampleRate * 10, 1); });

//boerderij samples
~varken_files = (~samplePath2++"/boerderij/varken/*.wav").pathMatch;
~varken_samples = ~varken_files.collect{ |item| Buffer.read(s, item); };

~koe_files = (~samplePath2++"/boerderij/koe/*.wav").pathMatch;
~koe_samples = ~koe_files.collect{ |item| Buffer.read(s, item); };

~schaap_files = (~samplePath2++"/boerderij/schaap/*.wav").pathMatch;
~schaap_samples = ~schaap_files.collect{ |item| Buffer.read(s, item); };

~ooievaar_files = (~samplePath2++"/boerderij/ooievaar/*.wav").pathMatch;
~ooievaar_samples = ~ooievaar_files.collect{ |item| Buffer.read(s, item); };

~ooievaarkort_files = (~samplePath2++"/boerderij/ooievaar/kort/*.wav").pathMatch;
~ooievaarkort_samples = ~ooievaarkort_files.collect{ |item| Buffer.read(s, item); };

~gjalt_files = (~samplePath2++"/boerderij/gjalt/*.wav").pathMatch;
~gjalt_samples = ~gjalt_files.collect{ |item| Buffer.read(s, item); };

~kikker_files = (~samplePath2++"/boerderij/kikkers/kort/*.wav").pathMatch;
~kikker_samples = ~kikker_files.collect{|item| Buffer.read(s, item); };

~frogs_long = Buffer.read(s, (~samplePath2++"/boerderij/kikkers/lang/kikkers_lang_1.wav"));
~bijen = Buffer.read(s, (~samplePath2++"/boerderij/bijen/bijen_01.wav") );



~firstgeneration_grainsample1 =  {  ~bike0smpls[~samNum1];      };
~firstgeneration_grainsample2 = 	 { ~bike1smpls[~samNum2] ;      };


3.0.wait;
//groups
~synthGroup2 = Group.new;
~gerriGroup = Group.new(~synthGroup2);
~noteGroups2 = Array.fill(8, { Group.new(~gerriGroup); });


~recGroup = Group.new;
//groups for sample loopers
~playGroups = Array.fill(2, { Array.fill(2, { Group.head(~synthGroup2); }); });
~recGroups = Array.fill(2, {|i| Array.fill(2, {|j| Group.after(~playGroups[i][j]); }); });
//sampler groups
//group for resample grain loop
~recrecGroups = Array.fill(2, {|i| Group.after(~synthGroup2); });
~compressGroup = Group.after(~gerriGroup);

~sidechainBus = Bus.audio(s, 2);
~controlBus = Bus.audio(s, 2);
~snareverbBus = Bus.audio(s, 2);
~compressBus = Bus.audio(s, 2);

/*
~sideChainer.free;
~sideChainer.set(\ratio, 0.8);*/
~sideChainer = Synth(\sidechainer, [\inBus, ~sidechainBus, \controlBus, ~controlBus, \thresh, 0.1, \ratio,0.8,\volume,0.75], ~compressGroup);

~snareverbsynth = Synth(\snareverb, [\inBus, ~snareverbBus, \mix, 0.2, \room, 0.4, \out, ~compressBus], ~gerriGroup,\addToTail );

~drumcompressor = Synth(\compressor, [\inBus, ~compressBus, \thresh, 0.01, \ratio,0.1,\gain,1], ~compressGroup, \addAfter);
		//~drumcompressor.set(\ratio,0.1);

//buses for record sample loop
~vectorBuses = Array.fill(2, { Array.fill(2, { Bus.audio(s, 1); }); });

//compress buses
~compressBuses = Array.fill(8, {
	Array.fill(4, {
		Bus.audio(s, 1);}); });
~recrecbus = Array.fill(2, { Array.fill(2, { Bus.audio(s, 1); }); });

//control buses
~lengthBuses = Array.fill(4, { Array.fill(10, {Bus.control(s, 1).set(0.1)}); });
~startBuses = Array.fill(2, { Array.fill(2, { Bus.control(s, 1).set(0.0); }); });

~ampBuses = Array.fill(8, { Bus.control(s, 1).set(0.25); });

~ampBus = Array.fill(2, {  Bus.control(s,1).set(0.001); });

~endBus = [
			Bus.control(s, 1).set(~bike0smpls[~samNum1].numFrames),
			Bus.control(s, 1).set(~bike1smpls[~samNum2].numFrames) ];

~endRecBus = Array.fill(2, {|i| Bus.control(s, 1).set(~recrecBufs[i].numFrames); });

~recordBuf = Buffer.alloc(s, 1024,1);

//specs
~lengthSpec = [1.0,0.001,\exp].asSpec;
//~lengthSpec = [0.001, 1.0,\linear].asSpec;
//~endSpec = [0.001, 1.0,\linear].asSpec;
~endSpec = [1.0,0.0001,\exp].asSpec;
~clockSpec = [0.5, 3.0, \exp].asSpec;
~startSpec = [0.0,0.9,\linear].asSpec;
~vecFreqSpec = [1, 19000,\exp].asSpec;
~octaveSpec = [0,6,\linear,1,1].asSpec;
~radioplayAmpSpec = [0.5,0.1,\linear].asSpec;
//differentiate length specs
~lengthSpecs = Array.fill(10, {|i| [0.75-((i+1)/20.408163265306),0.001,\linear].asSpec; });

~chooseBus = Bus.control(s, 1).set(1);

~whatFirstGrainSample = [0,0];
~whatSecondGrainSample = [0,0];


//tempo clocks for grain patterns
~clocks = Array.fill(4, { TempoClock.new; });
~recordClock = TempoClock.new(1);
//sample buffers

//arrays for buttons / switches
~startValues = [[0.0, 0.0],[0.0,0.0]];
~reverseButtons = [[0,0],[0,0]];
~playButtons  = [[0,0],[0,0]];
~recButtons  = [[0,0],[0,0]];
~starts  = [[0,0],[0,0]];
~playSwitches = [[0,0],[0,0]];
~recSwitches = [[0,0],[0,0]];
~sampleLengths = [[1.0,1.0],[1.0,1.0]];
~octave = [[1,1],[1,1]];
~octaves = [0.0625,0.125,0.25,0.5,1,2,4];
~radioplayAmps = [[0.1,0.1],[0.1,0.1]];
//feedback gates for rec loops
~fbgates = [0,0];

//array for routine names
~routineNames = Array.fill(2,{|j| Array.fill(2, {|i| "~routineName"++j++i; }); });
~timeRoutineNames = Array.fill(2,{|j| Array.fill(2, {|i| "~timeRoutineName"++j++i; }); });


~sine = Env.sine.discretize(1024).putLast(0);
~sineEnv = Buffer.sendCollection(s, ~sine, 1);

Pbindef(\radioplaypattern).fadeTime = 0.0001;

~inSelector1 = 0;
~inSelector2 = 0;
~selectInputs = [0,0];

~drumLengthSelect = 0;
~drumSamSelect = 0;
~drumPitchSelect = 0;


~recresp = CCResponder({|src,chan,num,val|

	//[src, chan, num, val].postln;

	if ( chan == 1, {

	[num,val].postln;
	case
	{ num == 110} {
	if ( ~drumPitchSelect != 2 , { ~drumPitchSelect = ~drumPitchSelect + 1; }, { ~drumPitchSelect = 0; });

	case
	{ ~drumPitchSelect == 0 }
	{
										}
	{ ~drumPitchSelect == 1 }
	{
					};
				}
	// switch drum length
	{ num == 109 } {
	if ( ~drumLengthSelect != 2 , { ~drumLengthSelect = ~drumLengthSelect + 1; }, { ~drumLengthSelect = 0; });

					case
					{ ~drumLengthSelect == 0 } {
						"normal lengths".postln;
						~velpaddurSpec = [0.1,1.5,-3,0.001].asSpec;
						~velfloordurSpec = [0.1,1.5,-3,0.001].asSpec;
						~velkickdurSpec = [0.65,0.15,3,0.001].asSpec;
						~velsnaredurSpec = [0.05,0.75,3,0.001].asSpec;
						~velhatdurSpec = [0.25,0.0125,-0.5,0.001].asSpec;

					}
					{ ~drumLengthSelect == 1 } {
						"all short".postln;
						~velpaddurSpec = [0.025,0.5,-3,0.001].asSpec;
						~velfloordurSpec = [0.025,0.5,-3,0.001].asSpec;
						~velkickdurSpec = [0.5,0.025,3,0.001].asSpec;
						~velsnaredurSpec = [0.025,0.4,3,0.001].asSpec;
						~velhatdurSpec = [0.45,0.0125,-0.5,0.001].asSpec;
					}
					{ ~drumLengthSelect == 2 } {
						"all long".postln;
						~velpaddurSpec = [0.1,2.0,-3,0.001].asSpec;
						~velfloordurSpec = [0.1,2.0,-3,0.001].asSpec;
						~velkickdurSpec = [2.0,0.15,3,0.001].asSpec;
						~velsnaredurSpec = [0.05,2.0,3,0.001].asSpec;
						~velhatdurSpec = [2.0,0.125,-0.5,0.001].asSpec;
					};

				}
	// switch drum samples
	{ num == 108 } {
					if ( ~drumSamSelect != 7, { ~drumSamSelect = ~drumSamSelect + 1; }, { ~drumSamSelect = 0 });
					case
					{ ~drumSamSelect == 0 } {
						"recorder mode otonality".postln;

						~floor_sample = { ~bike0smpls[~samNum1]; };
						~hat_sample = { ~bike1smpls[~samNum2]; };
						~snare_sample = { ~recrecBufs[0] };
						~kick_sample =  { ~fbrecBufs[0][0] };
						~sampad_1 = {  ~fbrecBufs[1][0] };
						~sampad_2 = { ~recrecBufs[1] };
						~sampad_3 = { ~fbrecBufs[0][1] };
						~sampad_4 = { ~fbrecBufs[1][1] };

					}
					{ ~drumSamSelect == 1 } {
						"pig mode".postln;

						// PIG MODE
						~floor_sample = { ~varken_samples.choose; };
						~hat_sample = { ~varken_samples.choose; };
						~snare_sample = { ~varken_samples.choose; };
						~kick_sample =  { ~varken_samples.choose; };
							~sampad_1 = {  ~varken_samples[0]; };
							~sampad_2 = { ~varken_samples[1]; };
							~sampad_3 = { ~varken_samples[2]; };
							~sampad_4 = { ~varken_samples[3]; };

					}
					{ ~drumSamSelect == 2 } {
						"cow mode".postln;

						// PIG MODE
						~floor_sample = { ~koe_samples.choose; };
						~hat_sample = { ~koe_samples.choose; };
						~snare_sample = { ~koe_samples.choose; };
						~kick_sample =  { ~koe_samples.choose; };
							~sampad_1 = {  ~koe_samples[0]; };
							~sampad_2 = { ~koe_samples[1]; };
							~sampad_3 = { ~koe_samples[2]; };
							~sampad_4 = { ~koe_samples[3]; };

					}
					{ ~drumSamSelect == 3 } {
						"sheep mode".postln;

						// PIG MODE
						~floor_sample = { ~schaap_samples.choose; };
						~hat_sample = { ~schaap_samples.choose; };
						~snare_sample = { ~schaap_samples.choose; };
						~kick_sample =  { ~schaap_samples.choose; };
							~sampad_1 = {  ~schaap_samples[0]; };
							~sampad_2 = { ~schaap_samples[1]; };
							~sampad_3 = { ~schaap_samples[2]; };
							~sampad_4 = { ~schaap_samples[3]; };

					}
					{ ~drumSamSelect == 4 } {
						"recorder mode pentatonic minor".postln;

						~floor_sample = { ~bike0smpls[~samNum1]; };
						~hat_sample = { ~bike0smpls[~samNum1]; };
						~snare_sample = { ~bike0smpls[~samNum1]; };
						~kick_sample =  { ~bike0smpls[~samNum1]; };
						~sampad_1 = {  ~bike0smpls[~samNum1]; };
						~sampad_2 = { ~bike0smpls[~samNum1]; };
						~sampad_3 = { ~bike0smpls[~samNum1];  };
						~sampad_4 = { ~bike0smpls[~samNum1]; };

					}
					{ ~drumSamSelect == 5 } {
						"gjalt mode".postln;

						~floor_sample = { ~gjalt_samples.choose; };
						~hat_sample = { ~gjalt_samples.choose;};
						~snare_sample = { ~gjalt_samples.choose; };
						~kick_sample =  { ~gjalt_samples.choose;};
							~sampad_1 = {  ~gjalt_samples[0]; };
							~sampad_2 = { ~gjalt_samples[1]; };
							~sampad_3 = { ~gjalt_samples[2]; };
							~sampad_4 = { ~gjalt_samples[3]; };

					}
					{ ~drumSamSelect == 6 } {
						"frog mode".postln;

						~floor_sample = { ~kikker_samples.choose; };
						~hat_sample = { ~kikker_samples.choose;};
						~snare_sample = { ~kikker_samples.choose; };
						~kick_sample =  { ~kikker_samples.choose;};
							~sampad_1 = {  ~kikker_samples[0]; };
							~sampad_2 = { ~kikker_samples[1]; };
							~sampad_3 = { ~kikker_samples[2]; };
							~sampad_4 = { ~kikker_samples[3]; };

					}
					{ ~drumSamSelect == 7 } {
						"stork mode".postln;

						~floor_sample = { ~ooievaarkort_samples.choose; };
						~hat_sample = { ~ooievaarkort_samples.choose;};
						~snare_sample = { ~ooievaarkort_samples.choose; };
						~kick_sample =  { ~ooievaarkort_samples.choose;};
							~sampad_1 = {  ~ooievaarkort_samples[0]; };
							~sampad_2 = { ~ooievaarkort_samples[1]; };
							~sampad_3 = { ~ooievaarkort_samples[2]; };
							~sampad_4 = { ~ooievaarkort_samples[3]; };

					};

				}
				});

			});



	//[num,val].postln;


//Server.default.makeGui
// loop different parts in buffer
//~playGroups[0][0].set(\trig, 1);
//get start values
2.do{|i|
2.do{|j|
Routine({inf.do{
~startBuses[i][j].get({|val| ~startValues[i].put(j, (val / s.sampleRate)); });
0.01.wait; } }).play; }; };

/*
~outputs = [ [ ~compressBuses[4][0].index, ~compressBuses[5][0].index ],
	[ ~compressBuses[6][0].index, ~compressBuses[7][0].index] ];
*/


//routines for sample looping without clicks and recording
2.do{|i|

2.do{|j|
var reverse = 1, timeRoutine,timeRoutineSwitch=0,time=0.25, start=0;

Routine({
			inf.do{ var playTime = ~sampleLengths[i][j] * s.sampleRate;

//switch on&off loops - routine speed is based on length sample
if ( ~playButtons[i][j] == 1, { if ( ~playSwitches[i][j] == 0, {
		~playSwitches[i].put(j,1); "playing".postln;
		~routineNames[i][j] = Routine({ inf.do{


if ( ~octave[i][j] > 1,  { if ( ~sampleLengths[i][j] < 0.5, { ~sampleLengths[i].put(j, ~sampleLengths[i][j]*2); });
							//"tooooooo short!!!!".postln;
						});
~startBuses[i][j].get({|item| start = item; });
if ( ~octave[i][j] == 4, { if ( start > ((~sampleLengths[i][j]*s.sampleRate)-start), { start = start - ((~sampleLengths[i][j]*s.sampleRate)-start)}); });

//("start : "++start).postln;
if ( start == inf, { start = ~sampleLengths[i][j]*s.sampleRate*0.5;
"inf error".postln; });
time = (~sampleLengths[i][j] - ~startValues[i][j]) * (1/~octave[i][j]);
time = time + (time*0.05);

if ( time < 0.001, { time = 0.01});

if ( time < 0.01, { if ( start < ((~sampleLengths[i][j]*s.sampleRate)*0.8), {
							start = (~sampleLengths[i][j]*s.sampleRate)*0.8;

							 "damn".postln; }); });


								Synth(\radioplay, [\out,if ( i == 0, { ~sidechainBus }, { ~sidechainBus }); ,\amp,~radioplayAmps[i][j],\nyquist, ~nyquist,\sampleRate, s.sampleRate,
									\mainvolBus, if ( i == 0, { if ( j == 0, { ~ampBuses[2].index }, { ~ampBuses[3].index }); },
										{ if ( j == 0, { ~ampBuses[6].index }, { ~ampBuses[7].index }); }); ,
									\start,start,\bufnum, ~fbrecBufs[i][j], \end, ~sampleLengths[i][j]*s.sampleRate,\reverse,reverse,\xpan,j-1.0,\ypan,j-1.0,\octave, ~octave[i][j],
							\vectorOut,~recrecbus[i][j] ],~playGroups[i][j]);

					time.wait; } });
					~routineNames[i][j].play;
				}) },
					{ if ( ~playSwitches[i][j] == 1,
						{ ~playSwitches[i].put(j,0); ~routineNames[i][j].stop; }); });
if ( ~recButtons[i][j] == 1, {
			if ( ~recSwitches[i][j] == 0,{ ~recSwitches[i].put(j, 1);
				"recording".postln;
						Synth(\radiorecorder,[\in,~vectorBuses[i][j], \bufnum, ~fbrecBufs[i][j]],~recGroups[i][j]);
						if ( ~playSwitches[i][j] == 1, {
							~playGroups[i][j].set(\end,~sampleLengths[i][j]*s.sampleRate); ~playGroups[i][j].set(\trig, 1); });

//routine for measuring the length of recording
~timeRoutineNames[i][j] = Routine({
				inf.do{
				10000.do{|k| if ( k != 0 , {
					if ( ~recSwitches[i][j] == 0, {
					~sampleLengths[i].put(j, k * 0.001);
~playGroups[i][j].set(\start,~starts[i][j]*(~sampleLengths[i][j]*s.sampleRate),\end, ~sampleLengths[i][j]*s.sampleRate);  ~timeRoutineNames[i][j].stop;
						"stopped time routine".postln;

						}); });  0.001.wait; } } }).play;
					}); }, { if ( ~recSwitches[i][j] == 1, { ~recSwitches[i].put(j, 0);
						"sample length : ".postln; ~sampleLengths[i][j].postln;
						~startBuses[i][j].set((~starts[i][j]*~sampleLengths[i][j]*s.sampleRate).postln);
/*
~playGroups[j].set(\start,~starts[j]*(~sampleLengths[j]*s.sampleRate),\end, ~sampleLengths[j]*s.sampleRate);
*/
						~recGroups[i][j].freeAll;
						  }); });
				if ( ~reverseButtons[i][j] == 1, { if ( reverse == 1, {
					reverse = -1; if ( ~playSwitches[i][j] == 1, { ~playGroups[i][j].set(\reverse, reverse); }); }); },
			{ if ( reverse == -1, { reverse = 1;
						if ( ~playSwitches[i][j] == 1, { ~playGroups[i][j].set(\reverse, reverse); }); }); });

		0.01.wait;
	};
}).play;
	};
};
(
//clocks for speed recordings tasks
~recclockSpec = [1.0, 40.0, \exp].asSpec;

~recClocks = Array.fill(2, { TempoClock.new(8); });

~resp2 = CCResponder({|src,chan,num,val|

	if ( chan == 1, {
				[num,val].postln;
	//record live audio input for first grain pattern
	case { num == 8 } {

	if ( ~fbgates[0] == 0, {


	if ( val == 127, {
	"rec direct input 0".postln;
							~recsynth1 = Synth(\zitarRecorder, [\in,~selectInputs[0],\recbuf, ~bike0smpls[~samNum1],\fftbuf, ~fftbuffers[0]]); }, { ~recsynth1.free; });
					}, {
	if ( val == 127, {

		"recording grain sample 0".postln;
						Synth(\recrecorder,[\in, ~recrecbus[1][0],\chooseBus,~chooseBus.index,
								\bufnum, ~bike0smpls[~samNum1] ],~recrecGroups[1]); });
					});

					}
//select input
	{ num == 16 }
				{ if ( ~inSelector1 != 6, { ~inSelector1 = ~inSelector1 + 1; }, { ~inSelector1 = 0; });
					case
					{ ~inSelector1 == 0 } { "toypiano".postln; ~selectInputs.put(0, 0);
						~firstgeneration_grainsample1 = {   ~bike0smpls[~samNum1];    }; }
					{ ~inSelector1 == 1 } { "tape".postln; ~selectInputs.put(0, 2); }
					{ ~inSelector1 == 2 } { "recorder".postln; ~selectInputs.put(0, 1); }
					{ ~inSelector1 == 3 } { "frogs".postln;
						~firstgeneration_grainsample1 = {  ~frogs_long;     };
					}
					{ ~inSelector1 == 4 } { "bijen".postln;
						~firstgeneration_grainsample1 = {  ~bijen;     };
					}
					{ ~inSelector1 == 5 } { "ooievaar".postln;
						~firstgeneration_grainsample1 = {  ~ooievaar_samples.choose;     };
					}
					{ ~inSelector1 == 6 } { "gjalt".postln;
						~firstgeneration_grainsample1 = {  ~gjalt_samples.choose;     };
					};




	}


	//record live audio input for second grain pattern
	{ num == 9 } {
	if ( ~fbgates[1] == 0, {

	if ( val == 127 , {
	"rec direct input 1".postln;
	~recsynth2 = Synth(\zitarRecorder, [\in,~selectInputs[1],\recbuf, ~bike1smpls[~samNum2],\fftbuf, ~fftbuffers[0]]); }, { ~recsynth2.free; }); }, {
	if ( val == 127, {
							"recording grain sample 1".postln;
							Synth(\recrecorder,[\in, ~recrecbus[1][1],
								\bufnum, ~bike1smpls[~samNum2] ],~recrecGroups[1]); });
				}); }
		// select input
		{ num == 17 }
				{ if ( ~inSelector2 !=6, { ~inSelector2 = ~inSelector2 + 1; }, { ~inSelector2 = 0; });
					case
					{ ~inSelector2 == 0 } { "toypiano".postln; ~selectInputs.put(1, 3);
						~firstgeneration_grainsample2 = {   ~bike1smpls[~samNum2];    };
					}
					{ ~inSelector2 == 1 } { "tape".postln; ~selectInputs.put(1, 2); }
					{ ~inSelector2 == 2 } { "voice".postln; ~selectInputs.put(1, 0); }
					{ ~inSelector2 == 3 } { "frogs".postln;
						~firstgeneration_grainsample2 = {  ~frogs_long;     };
					}
					{ ~inSelector2 == 4 } { "bijen".postln;
						~firstgeneration_grainsample2 = {  ~bijen;     };
					}
					{ ~inSelector2 == 5 } { "ooievaar".postln;
						~firstgeneration_grainsample2 = {  ~ooievaar_samples.choose;     };
					}
					{ ~inSelector2 == 6 } { "gjalt".postln;
						~firstgeneration_grainsample2 = {  ~gjalt_samples.choose;     };
					};
	}




	//start&stop pattern 1
	{ num == 24 } {
	"playing pattern 1".postln;
	if ( val == 127, {
10.do{|i|var pan = ((i+1)*0.1)-1,dur = 0.1 + (i*0.01);
Pbindef(("grainpattern1"++i).asSymbol,\instrument, \radioplaypattern,
\group,~synthGroup2, \out,~sidechainBus,
\nyquist, ~nyquist,
\octave, 1,
\start,0,\endBus,~endBus[0].index,\lengthBus, ~lengthBuses[0][i].index,\dur,dur,\reverse,Pwrand([1,-1],[0.6,0.4],inf),
\bufnum,
Pfunc({ ~firstgeneration_grainsample1.value}),
\envbuf, ~sineEnv,\ampBus,~ampBuses[0].index,\pan,Pwhite(pan,pan+0.1),
\vectorOut, ~vectorBuses[0][0] ).play(~clocks[0]);
};	},{ 10.do{|i| Pbindef(("grainpattern1"++i).asSymbol).pause; }; }); }
	//change speed + length grains
	{ num == 32 }
	{ ~clocks[0].tempo = ~clockSpec.map(val/127).postln;
		10.do{|i| ~lengthBuses[0][i].set(~lengthSpec.map(val/127);); } }
	//end position in sample
	{ num == 0 }
				{ ~endBus[0].set(~lengthSpec.map(val/127)*(~firstgeneration_grainsample1.value).numFrames); }


//start&stop pattern 2
{ num == 25 } { if ( val == 127, {
5.do{|i|var pan = (i+1)*0.1,dur = 0.1 + (i*0.01);
Pbindef(("grainpattern2"++i).asSymbol,\instrument, \radioplaypattern,\group,~synthGroup2,
\out,~sidechainBus,
\nyquist, ~nyquist,
\octave, 1,
\start,0,
\endBus,~endBus[1].index,
\lengthBus, ~lengthBuses[1][i].index,
\dur,dur,\reverse,Pwrand([1,-1],[0.6,0.4],inf),
							\bufnum,Pfunc({~firstgeneration_grainsample2.value}),\envbuf, ~sineEnv,
							\ampBus,~ampBuses[1].index,
\vectorOut, ~vectorBuses[0][1] ).play(~clocks[1]); } },
		{ 10.do{|i| Pbindef(("grainpattern2"++i).asSymbol).pause; }; }); }
	//change speed + length grains
	{ num == 33 }
	{ ~clocks[1].tempo = ~clockSpec.map(val/127).postln;
		10.do{|i| ~lengthBuses[1][i].set( ~lengthSpec.map(val/127).postln; ); }; }
	//change end position grain pattern
	{ num == 1 }
	{ //~length2 = ~lengthSpec.map(val/127).postln;
		~endBus[1].set(~lengthSpec.map(val/127)*(~firstgeneration_grainsample2.value).numFrames);
	}
	//3rd granular pattern samples the sampler
	//start&stop pattern
	{ num == 28 } { if ( val == 127, {
"pattern3 started".postln;
5.do{|i|var pan = ((i+1)*0.19)-1;
Pbindef(("grainpattern3"++i).asSymbol,\instrument, \regranulate,
\group,~synthGroup2,
\nyquist, ~nyquist,
\ampBus,~ampBuses[4].index,
\out, ~sidechainBus,
\octave, 1,
\start,0,
\endBus,~endRecBus[0].index,
\lengthBus, ~lengthBuses[2][i].index,
\dur,0.1,
\reverse,Pwrand([1,-1],[0.6,0.4],inf),
\bufnum,~recrecBufs[0],\envbuf, ~sineEnv,\pan,Pwhite(pan,pan+0.1),
				\recOut, ~vectorBuses[1][0] ).play(~clocks[2]);
};	},
	{ 10.do{|i| Pbindef(("grainpattern3"++i).asSymbol).stop;};	"pattern 3 stopped".postln; }); }
	{ num == 36 }
	{
		~clocks[2].tempo = ~clockSpec.map(val/127).postln;
		10.do{|i| ~lengthBuses[2][i].set(~lengthSpecs[i].map(val/127);); }
	}
	{ num == 4 }
	{ ~endRecBus[0].set( ((~lengthSpec.map(val/127))*~recrecBufs[0].numFrames).postln;); }

{ num == 20 }
	{ if ( val == 127, { ~durVar3 = Routine({ inf.do{ 100.do{|i| var dur = ~clocks[2].tempo.reciprocal*0.5, time = 0.001 + rrand(0.0001,0.001);
		10.do{|i|
			~lengthBuses[2][i].set(rrand(dur*0.001,dur)); }; time.wait; } }}).play; "dur routine playing".postln; },
		{ ~durVar3.stop; "dur routine stop".postln; });
	}

{ num == 29 } { if ( val == 127, {
"pattern4 started".postln;
5.do{|i|var pan = ((i+1)*0.19)-1,dur = 0.1 + (i*0.001);
Pbindef(("grainpattern4"++i).asSymbol,
\instrument, \regranulate,
\group,~synthGroup2,
\nyquist, ~nyquist,
\ampBus,~ampBuses[5].index,
\out, ~sidechainBus,
\octave, 1,
\start,0,
\endBus,~endRecBus[1].index,
\lengthBus, ~lengthBuses[3][i].index,
\dur,0.1,
\reverse,Pwrand([1,-1],[0.6,0.4],inf),
\bufnum,~recrecBufs[1],\envbuf, ~sineEnv,
				\recOut, ~vectorBuses[1][1]).play(~clocks[3]);
};	},
		{ 10.do{|i| Pbindef(("grainpattern4"++i).asSymbol).stop;};	"pattern 4 stopped".postln; }); }
{ num == 37 }
{
		~clocks[3].tempo = ~clockSpec.map(val/127).postln;
		10.do{|i| ~lengthBuses[2][i].set(~lengthSpecs[i].map(val/127);); }
}
{ num == 5 }
{
		~endRecBus[1].set( ((~lengthSpec.map(val/127))*~recrecBufs[1].numFrames).postln;);
}

{ num == 21 }
	{ if ( val == 127, { ~durVar = Routine({ inf.do{ 100.do{|i| var dur = ~clocks[3].tempo.reciprocal*0.5, time = 0.001 + rrand(0.0001,0.001);
		10.do{|i|
			~lengthBuses[3][i].set(rrand(dur*0.001,dur)); }; time.wait; } }}).play; "dur routine playing".postln; },
		{ ~durVar4.stop; "dur routine stop".postln; });
	}
	//record sampler for grain pattern 3
	{ num == 12 } { "rec 1".postln;
		Synth(\recrecorder,[\in, ~recrecbus[0][0], \bufnum, ~recrecBufs[0]],~recrecGroups[0]); }
	//record sampler for grain pattern 4
	{ num == 13 } { "rec 1".postln;
		Synth(\recrecorder,[\in, ~recrecbus[0][1], \bufnum, ~recrecBufs[1]],~recrecGroups[1]); };





if ( num == 10,
		{  if ( val == 127, {"sampling grain pattern 1".postln;~recButtons[0].put(0,1); },{ ~recButtons[0].put(0,0); }); });
	//play sample
	if ( num == 18,
		{ if ( val == 127, { "playing grain loop 1".postln;~playButtons[0].put(0,1); },{ "stopped grain loop 1".postln; ~playButtons[0].put(0,0); }); });
	//reversed on / off
	if ( num == 26,
		{ if ( val == 127, { "reverse on".postln; ~reverseButtons[0].put(0,1) }, { "reverse off".postln; ~reverseButtons[0].put(0,0) }); });
	//set start position
	if ( num == 34, { ~starts[0].put(0, ~startSpec.map(val/127); ); ~starts[0][0].postln;
		~startBuses[0][0].set(~starts[0][0]*~sampleLengths[0][0]*s.sampleRate);
		~radioplayAmps[0].put(0, ~radioplayAmpSpec.map(val/127); ); ~radioplayAmps[0][0].postln;
	});
	//octave shifting
	if ( num == 2, {
		~octave[0].put(0, ~octaves[~octaveSpec.map(val/127)];); ~octave[0][0].postln;
		if ( ~playSwitches[0][0] == 1, {
			~playGroups[0][0].set(\octave, ~octave[0][0]); }); });
	//record sample 2 from grain pattern 2
	if ( num == 11, {
		if ( val == 127, { "sampling grain pattern 2".postln; ~recButtons[0].put(1,1); },{ ~recButtons[0].put(1,0); });});
	if ( num == 19, { if ( val == 127, { "playing grain loop 2".postln; ~playButtons[0].put(1,1); }, { ~playButtons[0].put(1,0); });});
	//reversed on /off
	if ( num == 27,
	{ if ( val == 127, { "reverse on".postln; ~reverseButtons[0].put(1,1); },{ "reverse off".postln; ~reverseButtons[0].put(1, 0); });});
	//set start position
	if ( num == 35, {
	~starts[0].put(1, ~startSpec.map(val/127) ); ~starts[0][1].postln;
	~startBuses[0][1].set(~starts[0][1]*~sampleLengths[0][1]*s.sampleRate);
	~radioplayAmps[0].put(1, ~radioplayAmpSpec.map(val/127); ); ~radioplayAmps[0][1].postln;
	});
	//octave shifting
	if ( num == 3, {
		~octave[0].put(1, ~octaves[~octaveSpec.map(val/127)]); ~octave[0][1].postln;
		if ( ~playSwitches[0][1] == 1, {
			~playGroups[0][1].set(\octave, ~octave[0][1]); }); });
	//SECOND
		if ( num == 14,
		{  if ( val == 127, {"sampling grain pattern 1".postln;~recButtons[1].put(0,1); },{ ~recButtons[1].put(0,0); }); });
	//play sample
	if ( num == 22,
	{ if ( val == 127, { "playing grain loop 1".postln;~playButtons[1].put(0,1); },{ "stopped grain loop 1".postln; ~playButtons[1].put(0,0); }); });
	//reversed on / off
	if ( num == 30,
	{ if ( val == 127, { "reverse on".postln; ~reverseButtons[1].put(0,1) }, { "reverse off".postln; ~reverseButtons[1].put(0,0) }); });
	//set start position
	if ( num == 38, { ~starts[1].put(0, ~startSpec.map(val/127); ); ~starts[1][0].postln;
		~startBuses[1][0].set(~starts[1][0]*~sampleLengths[1][0]*s.sampleRate);
		~radioplayAmps[1].put(0, ~radioplayAmpSpec.map(val/127); ); ~radioplayAmps[1][0].postln;
	});
	//octave shifting
	if ( num == 6, {
		~octave[1].put(0, ~octaves[~octaveSpec.map(val/127)];); ~octave[1][0].postln;
		if ( ~playSwitches[1][0] == 1, {
			~playGroups[1][0].set(\octave, ~octave[1][0]); }); });
	//record sample 2 from grain pattern 2
	if ( num == 15, {
		if ( val == 127, { "sampling grain pattern 2".postln; ~recButtons[1].put(1,1); },{ ~recButtons[1].put(1,0); });});

	//play sample loop
	if ( num == 23, { if ( val == 127, { "playing grain loop 2".postln; ~playButtons[1].put(1,1); }, { ~playButtons[1].put(1,0); });});
	//reversed on /off
	if ( num == 31,
	{ if ( val == 127, { "reverse on".postln; ~reverseButtons[1].put(1,1); },{ "reverse off".postln; ~reverseButtons[1].put(1, 0); });});
	//set start position
	if ( num == 39, {
		~starts[1].put(1, ~startSpec.map(val/127) ); ~starts[1][1].postln;
		~startBuses[1][1].set(~starts[1][1]*~sampleLengths[1][1]*s.sampleRate);
		~radioplayAmps[1].put(1, ~radioplayAmpSpec.map(val/127); ); ~radioplayAmps[1][1].postln;
	});
	//octave shifting
	if ( num == 7, {
		~octave[1].put(1, ~octaves[~octaveSpec.map(val/127)]); ~octave[1][1].postln;
		if ( ~playSwitches[1][1] == 1, {
			~playGroups[1][1].set(\octave, ~octave[1][1]); }); });
	//rec loops
	if ( num == 100, {
		if ( val == 127, { "rec loop 0 running".postln;
	~recRoutine0 = Routine({
				inf.do{
		"recording sample loop 0".postln;
		~recButtons[0].put(0,1);
		rrand(0.5,2.0).wait;
		"stopped recording sample loop 0".postln;
		~recButtons[0].put(0,0);
		rrand(0.5,2.0).wait;
		"recording grain sample 1".postln;
		Synth(\recrecorder,[\in, ~recrecbus[0][0], \bufnum, ~recrecBufs[0]],~recrecGroups[0]);
		rrand(0.5,2.0).wait;
		"recording sample loop 1".postln;
		~recButtons[1].put(0,1);
		rrand(0.5,2.0).wait;
		"stopped recording sample loop 0".postln;
		~recButtons[1].put(0,0);
		rrand(0.5,2.0).wait;
		if ( ~fbgates[0] == 1, {
		"recording grain sample 0".postln;

						Synth(\recrecorder,[\in, ~recrecbus[1][0],\chooseBus,~chooseBus.index,
							\bufnum, ~bike0smpls[~samNum1] ],~recrecGroups[1]);
						1.0.wait;
						10.do{|i| Pbindef(("grainpattern1"++i).asSymbol,\bufnum,~bike0smpls[~samNum1] ); };
					});
				}
				}).play(~recClocks[0]); }, { "rec loop 0 stopped".postln; ~recButtons[0].put(0,0); ~recButtons[0].put(1,0); ~recRoutine0.stop; }); } );
		if ( num == 101, {
		if ( val == 127, { "rec loop 1 running".postln;
		~recRoutine1 = Routine({
	inf.do{

		~recButtons[0].put(1,1);
		rrand(0.5,2.0).wait;
		~recButtons[0].put(1,0);
		rrand(0.5,2.0).wait;
		Synth(\recrecorder,[\in, ~recrecbus[0][1], \bufnum, ~recrecBufs[1]],~recrecGroups[0]);
		rrand(0.5,2.0).wait;
		~recButtons[1].put(1,1);
		rrand(0.5,2.0).wait;
		~recButtons[1].put(1,0);
		rrand(0.5,2.0).wait;
		if ( ~fbgates[1] == 1, {

		Synth(\recrecorder,[\in, ~recrecbus[1][1],
							\bufnum, ~bike1smpls[~samNum2] ],~recrecGroups[1]);
							1.0.wait;
								10.do{|i| Pbindef(("grainpattern2"++i).asSymbol,\bufnum,~bike1smpls[~samNum2]  ); };
			 });
	}
}).play(~recClocks[1]);
 }, { "rec loop 1 stopped".postln; ~recButtons[1].put(0,0); ~recButtons[1].put(1,0); ~recRoutine1.stop; }); } );
//open close feedback gates
	if ( num == 106, {
		if ( val == 127, {"gate 0 opened".postln; ~fbgates.put(0, 1); },
			{"gate 0 closed".postln; ~fbgates.put(0, 0); }); });
	if ( num == 107, {
		if ( val == 127, {"gate 1 opened".postln; ~fbgates.put(1, 1); },
			{"gate 1 closed".postln; ~fbgates.put(1, 0); }); });


	//second sampler

				});
});
);






~velpaddurSpec = [0.1,1.5,-3,0.001].asSpec;
~velfloordurSpec = [0.1,1.5,-3,0.001].asSpec;
~velkickdurSpec = [0.65,0.15,3,0.001].asSpec;
~velsnaredurSpec = [0.05,0.75,3,0.001].asSpec;
~velhatdurSpec = [0.45,0.025,-0.5,0.001].asSpec;
~velampSpec = [0.001,1.0,\exp,0.001].asSpec;
~kickvelampSpec = [0.001,1.0,\linear,0.001].asSpec;



~velfloorratioSpec = [0,36,-2,1].asSpec;
~velhatratioSpec = [0,64,3,1].asSpec;
~velkickratioSpec = [0,12,-2,1].asSpec;
~velsnareratioSpec = [0,48,-2,1].asSpec;
~velpadratioSpec = [0,24,-2,1].asSpec;


//~midinotes = [36,45,46,72,58,38,39,50];

//~midinotes = [35,50,46,36,38,39,58,72];
// 36 - kick
//46 - snare
//45 - floor
// 50 - bekkentje
// rest is sample pad

// FLUTE MODE
	~floor_sample = { ~bike0smpls[~samNum1]; };
	~hat_sample = { ~bike1smpls[~samNum2]; };
	~snare_sample = { ~recrecBufs[0] };
	~kick_sample =  { ~fbrecBufs[0][0] };
	~sampad_1 = {  ~fbrecBufs[1][0] };
	~sampad_2 = { ~recrecBufs[1] };
	~sampad_3 = { ~fbrecBufs[0][1] };
	~sampad_4 = { ~fbrecBufs[1][1] };

/*
	~floor_ratio = { ~drumscale[~velfloorratioSpec.map(vel/127)] };
	~hat_ratio = { ~drumscale[~velhatratioSpec.map(vel/127)] };
	~snare_ratio = { ~drumscale[~velsnareratioSpec.map(vel/127)] };
	~kick_ratio = { ~drumscale[~velkickratioSpec.map(vel/127)] };
	~pad_ratio = { ~drumscale[~velpadratioSpec.map(vel/127)] };
*/

//drumratios
~drumscale = ~otonratios[0];


2.0.wait;

(

(
MIDIdef.noteOn(\drumnoteon, {|vel note chan srcid|

if ( srcid == 4, {

		[vel, note, chan, srcid].postln;

		case
			{ ~drumSamSelect == 0 } {

				~drumscale = ~otonratios[0];


				        ~velfloorratioSpec = [0,36,-2,1].asSpec;
						~velhatratioSpec = [0,64,3,1].asSpec;
						~velkickratioSpec = [0,12,-2,1].asSpec;
						~velsnareratioSpec = [0,48,-2,1].asSpec;
						~velpadratioSpec = [0,24,-2,1].asSpec;

						~floor_ratio = { ~drumscale[~velfloorratioSpec.map(vel/127)] };
						~hat_ratio = { ~drumscale[~velhatratioSpec.map(vel/127)] };
						~snare_ratio = { ~drumscale[~velsnareratioSpec.map(vel/127)] };
						~kick_ratio = { ~drumscale[~velkickratioSpec.map(vel/127)] };
				~pad_ratio = { ~drumscale[~velpadratioSpec.map(vel/127)] };

			}
			{ ~drumSamSelect == 1 } {

				        ~velfloorratioSpec = [0.6,1.5,-1,0.001].asSpec;
						~velkickratioSpec = [0.25,0.75,-2,0.001].asSpec;
						~velsnareratioSpec = [0.75,1.25,-2,0.001].asSpec;
						~velhatratioSpec = [0.5,1.75,-0.5,0.001].asSpec;
						~velpadratioSpec = [0.9,1.5,4,0.001].asSpec;

						~floor_ratio = { ~velfloorratioSpec.map(vel/127); };
						~hat_ratio = { ~velhatratioSpec.map(vel/127); };
						~snare_ratio = { ~velsnareratioSpec.map(vel/127); };
						~kick_ratio = { ~velkickratioSpec.map(vel/127); };
						~pad_ratio = { ~velpadratioSpec.map(vel/127); };
			}
			{ ~drumSamSelect == 2 } {

				        ~velfloorratioSpec = [0.6,1.5,-2,0.001].asSpec;
						~velkickratioSpec = [0.5,1.0,-2,0.001].asSpec;
						~velsnareratioSpec = [0.75,1.25,-2,0.001].asSpec;
						~velhatratioSpec = [1.0,1.5,3,0.001].asSpec;
						~velpadratioSpec = [0.9,1.5,4,0.001].asSpec;

						~floor_ratio = { ~velfloorratioSpec.map(vel/127); };
						~hat_ratio = { ~velhatratioSpec.map(vel/127); };
						~snare_ratio = { ~velsnareratioSpec.map(vel/127); };
						~kick_ratio = { ~velkickratioSpec.map(vel/127); };
						~pad_ratio = { ~velpadratioSpec.map(vel/127); };
			}
			{ ~drumSamSelect == 3 } {

				        ~velfloorratioSpec = [0.9,1.1,-2,0.001].asSpec;
						~velkickratioSpec = [0.5,1.0,-2,0.001].asSpec;
						~velsnareratioSpec = [0.75,1.25,-2,0.001].asSpec;
						~velhatratioSpec = [1.0,2.0,3,0.001].asSpec;
						~velpadratioSpec = [0.9,1.5,4,0.001].asSpec;

						~floor_ratio = { ~velfloorratioSpec.map(vel/127); };
						~hat_ratio = { ~velhatratioSpec.map(vel/127); };
						~snare_ratio = { ~velsnareratioSpec.map(vel/127); };
						~kick_ratio = { ~velkickratioSpec.map(vel/127); };
						~pad_ratio = { ~velpadratioSpec.map(vel/127); };
			}
			{ ~drumSamSelect == 4 } {


				~drumscale = ~minorratios;


				      ~velfloorratioSpec = [0,19,5,1].asSpec;
						~velhatratioSpec = [0,19,5,1].asSpec;
						~velkickratioSpec = [0,19,10,1].asSpec;
						~velsnareratioSpec = [0,19,5,1].asSpec;
						~velpadratioSpec = [0,19,5,1].asSpec;

						~floor_ratio = { ~drumscale[~velfloorratioSpec.map(vel/127)] };
				~hat_ratio = { ~drumscale[~velhatratioSpec.map(vel/127)] };
				~snare_ratio = { ~drumscale[~velsnareratioSpec.map(vel/127)] };
				~kick_ratio = { ~drumscale[~velkickratioSpec.map(vel/127)] };
				~pad_ratio = { ~drumscale[~velpadratioSpec.map(vel/127)] };
			}
			{ ~drumSamSelect == 5 } {


				  ~velfloorratioSpec = [0.99,1.01,-2,0.001].asSpec;
						~velkickratioSpec = [0.99,1.01,-2,0.001].asSpec;
						~velsnareratioSpec = [0.98,1.01,-2,0.001].asSpec;
						~velhatratioSpec = [0.99,1.03,3,0.001].asSpec;
						~velpadratioSpec = [0.9,1.5,4,0.001].asSpec;

						~floor_ratio = { ~velfloorratioSpec.map(vel/127); };
						~hat_ratio = { ~velhatratioSpec.map(vel/127); };
						~snare_ratio = { ~velsnareratioSpec.map(vel/127); };
						~kick_ratio = { ~velkickratioSpec.map(vel/127); };
						~pad_ratio = { ~velpadratioSpec.map(vel/127); };
			};




	case
	{ chan == 9 } // verander terug naar 9
	{
					[vel, note, chan, srcid].postln;
			case
			// floor
			{ note == 31 }
			{
			Synth(\gerrifloorsampler,
						[\bufnum, ~floor_sample.value,\ratio, ~floor_ratio.value,
						\amp, ~velampSpec.map(vel/127),\dur, ~velfloordurSpec.map(vel/127),\anaBus, ~controlBus, \out, ~compressBus], ~noteGroups2[0] );
			}
			//bekkentje
			{ note == 32 }
			{

				Synth(\gerrihatsampler,
						[\bufnum, ~hat_sample.value, \envbuf, ~win1,\ratio,~hat_ratio.value,
					\amp, ~velampSpec.map(vel/127),\dur, ~velhatdurSpec.map(vel/127),\anaBus, ~controlBus, \out, ~compressBus], ~noteGroups2[1] );
			}
			// SNARE
			{ note == 33 }
			{

			Synth(\gerrisnaresampler, [\bufnum, ~snare_sample.value, \envbuf, ~win1,
					\bitcrush, vel/127, \ratio, ~snare_ratio.value,
					\amp, ~velampSpec.map(vel/127),
					\dur, ~velsnaredurSpec.map(vel/127),\anaBus, ~controlBus, \out, ~snareverbBus], ~noteGroups2[2]);
			}
			//KICK
			{ note == 56 }
			{
			Synth(\gerrikicksampler, [
							// \bufnum, ~bike1smpls[~samNum2],
						\bufnum, ~kick_sample.value, \ratio, ~kick_ratio.value ,
					\amp, ~kickvelampSpec.map(vel/127),
							\dur, ~velkickdurSpec.map(vel/127),\anaBus, ~controlBus, \out, ~compressBus], ~noteGroups2[3]);
			}
			// pad sample 1
			{ note == 34 }
			{

			Synth(\gerripad1sampler, [\bufnum, ~sampad_1.value, \envbuf, ~win1,
						\ratio, ~pad_ratio.value,\amp, ~velampSpec.map(vel/127),
						\dur, ~velpaddurSpec.map(vel/127),\anaBus, ~controlBus, \out, ~compressBus], ~noteGroups2[4]);

			}
			// sample pad 2
			{ note == 39 }
			{

			Synth(\gerripad2sampler, [\bufnum, ~sampad_2.value, \envbuf, ~win1,
						\ratio,~pad_ratio.value, \amp, ~velampSpec.map(vel/127),
						\dur, ~velpaddurSpec.map(vel/127),\anaBus, ~controlBus, \out, ~compressBus], ~noteGroups2[5]);


			}
			// sample pad 3
			{ note == 58 }
			{

					Synth(\gerripad3sampler, [\bufnum, ~sampad_3.value,
						\envbuf, ~win1,\ratio, ~pad_ratio.value,\amp, ~velampSpec.map(vel/127),
					\dur, ~velpaddurSpec.map(vel/127),\anaBus, ~controlBus, \out, ~snareverbBus], ~noteGroups2[6]);

			}
			// sample pad 4
			{ note == 72 }
			{

					Synth(\gerripad4sampler, [\bufnum,~sampad_4.value,
						\ratio, ~pad_ratio.value,\amp, ~velampSpec.map(vel/127),
					\dur, ~velpaddurSpec.map(vel/127),\anaBus, ~controlBus, \out, ~snareverbBus], ~noteGroups2[7]);

			}
			};
				});



});
	);


//~volumeResp.remove;
//~volumeResp.remove;
//Server.default.makeGui

~drumGainSpec = [-90.dbamp,-5.dbamp,\linear,0.001].asSpec;
	~roomSpec = [0.000001,1.0,\linear].asSpec;




(
~gerriResponder = CCResponder({|src chan num val|


		if ( chan == 2, {
		[src, chan, num, val].postln;



		case
		// fader nummer nog in te stellen
		{ num == 0 } {
				~drumcompressor.set(\gain,~drumGainSpec.map(val/127));
			}
		// snare verb mix //nr nog in te stellen
			{ num == 1 } {
				~snareverbsynth.set(\mix, val/127);
			}
			// nr nog in te stellen
			{ num == 2 } {
				~snareverbsynth.set(\room, ~roomSpec.map(val/127); );
			}
		//drum lengths
		/*
		{ num == 48  } {
						"normal lengths".postln;
				        ~drumLengthSelect = 0;
				~velampSpec = [0.001,1.0,\exp,0.001].asSpec;

						~velpaddurSpec = [0.1,1.5,-3,0.001].asSpec;
						~velfloordurSpec = [0.1,1.5,-3,0.001].asSpec;
						~velkickdurSpec = [0.65,0.15,3,0.001].asSpec;
						~velsnaredurSpec = [0.05,0.75,3,0.001].asSpec;
						~velhatdurSpec = [0.45,0.025,-0.5,0.001].asSpec;

					}
		*/
		{ num == 49   } {
						"all short".postln;
				       ~velampSpec = [0.75,2.0,\exp,0.001].asSpec;

				        ~drumLengthSelect = 1;
						~velpaddurSpec = [0.0125,0.15,-3,0.001].asSpec;
						~velfloordurSpec = [0.0125,0.15,-3,0.001].asSpec;
						~velkickdurSpec = [1.0,0.25,3,0.001].asSpec;
						~velsnaredurSpec = [0.0125,0.15,3,0.001].asSpec;
						~velhatdurSpec = [0.15,0.0125,-0.5,0.001].asSpec;
					}
		{ num == 48 } {
						"all long".postln;
				~velampSpec = [0.001,1.0,\exp,0.001].asSpec;

				       ~drumLengthSelect = 2;
						~velpaddurSpec = [0.1,2.0,-3,0.001].asSpec;
						~velfloordurSpec = [0.1,2.0,-3,0.001].asSpec;
						~velkickdurSpec = [2.0,0.15,3,0.001].asSpec;
						~velsnaredurSpec = [0.05,2.0,3,0.001].asSpec;
						~velhatdurSpec = [2.0,0.125,-0.5,0.001].asSpec;
					}
		{ num == 32 } {
				~drumSamSelect = 0;
						"recorder + autoharp mode otonality".postln;

						~floor_sample = { ~bike0smpls[~samNum1]; };
						~hat_sample = { ~bike1smpls[~samNum2]; };
						~snare_sample = { ~recrecBufs[0] };
						~kick_sample =  { ~fbrecBufs[0][0]; };
						~sampad_1 = {  ~fbrecBufs[0][0]; };
						~sampad_2 = { ~recrecBufs[1] };
						~sampad_3 = { ~fbrecBufs[0][1] };
						~sampad_4 = { ~fbrecBufs[1][1] };

					}
					{ num == 33 } {
						"field recording mode".postln;
				 ~drumSamSelect = 1;

						// PIG MODE
						~floor_sample = { ~ambientsLeft.choose; };
						~hat_sample = { ~ambientsLeft.choose; };
						~snare_sample = { ~ambientsLeft.choose; };
						~kick_sample =  { ~ambientsLeft.choose; };
						~sampad_1 = {  ~ambientsLeft.choose; };
						~sampad_2 = { ~ambientsLeft.choose; };
						~sampad_3 = { ~ambientsLeft.choose; };
						~sampad_4 = { ~ambientsLeft.choose; };

					}
					{ num == 34  } {
				~drumSamSelect = 2;
						"malm mode".postln;

						// PIG MODE
						~floor_sample = { ~malm.choose; };
						~hat_sample = { ~malm.choose; };
						~snare_sample = { ~malm.choose; };
						~kick_sample =  { ~malm.choose; };
						~sampad_1 = {  ~malm.choose; };
						~sampad_2 = { ~malm.choose; };
						~sampad_3 = { ~malm.choose; };
						~sampad_4 = { ~malm.choose; };

					}
					{ num == 35 } {
				~drumSamSelect = 3;
						"auto harp mode".postln;

						// PIG MODE
						~floor_sample = { ~bike1smpls[~samNum2]; };
						~hat_sample = { ~fbrecBufs[1][1]; };
						~snare_sample = { ~bike1smpls[~samNum2]; };
						~kick_sample =  { ~bike1smpls[~samNum2]; };
						~sampad_1 = {  ~fbrecBufs[1][1]; };
						~sampad_2 = { ~fbrecBufs[1][1]; };
						~sampad_3 = { ~fbrecBufs[1][0]; };
						~sampad_4 = { ~fbrecBufs[1][0]; };

					}
					{ num == 36 } {
				~drumSamSelect = 4;
						"recorder mode pentatonic minor".postln;

						~floor_sample = { ~bike0smpls[~samNum1]; };
						~hat_sample = { ~bike0smpls[~samNum1]; };
						~snare_sample = { ~bike0smpls[~samNum1]; };
						~kick_sample =  { ~bike0smpls[~samNum1]; };
						~sampad_1 = {  ~bike0smpls[~samNum1]; };
						~sampad_2 = { ~bike0smpls[~samNum1]; };
						~sampad_3 = { ~bike0smpls[~samNum1];  };
						~sampad_4 = { ~bike0smpls[~samNum1]; };

					}
					{ num == 37 } {
				~drumSamSelect = 5;
						"gjalt mode".postln;

						~floor_sample = { ~gjalt_samples.choose; };
						~hat_sample = { ~gjalt_samples.choose;};
						~snare_sample = { ~gjalt_samples.choose; };
						~kick_sample =  { ~gjalt_samples.choose;};
						~sampad_1 = {  ~gjalt_samples.choose; };
						~sampad_2 = { ~gjalt_samples.choose; };
						~sampad_3 = { ~gjalt_samples.choose; };
						~sampad_4 = { ~gjalt_samples.choose; };

					}
					{ num == 38 } {
				~drumSamSelect = 6;
						"another auto harp mode".postln;

						~floor_sample = { ~bike1smpls[~samNum2]; };
						~hat_sample = { ~fbrecBufs[1][1]; };
						~snare_sample = { ~bike1smpls[~samNum2]; };
						~kick_sample =  { ~bike1smpls[~samNum2]; };
						~sampad_1 = {  ~fbrecBufs[1][1]; };
						~sampad_2 = { ~fbrecBufs[1][1]; };
						~sampad_3 = { ~fbrecBufs[1][0]; };
						~sampad_4 = { ~fbrecBufs[1][0]; };

					}
					{ num == 39 } {
				~drumSamSelect = 7;
						"animal mode".postln;

						~floor_sample = { ~koe_samples.choose;  };
						~hat_sample = { ~schaap_samples.choose; };
						~snare_sample = { ~koe_samples.choose; };
						~kick_sample =  { ~varken_samples.choose; };
						~sampad_1 = { ~varken_samples.choose;};
						~sampad_2 = { ~schaap_samples.choose;};
						~sampad_3 = { ~varken_samples.choose;};
						~sampad_4 = { ~ooievaarkort_samples.choose; };

					};



		});


	});
	);

	Ndef(\directIn, {
	var sig = SoundIn.ar(0)*2.25;
	sig = sig!2;
	}).play;

/*
		Ndef(\directIn, {
	var sig = SoundIn.ar(2)*1;
	sig = sig!2;
	}).play;*/





)

};

);