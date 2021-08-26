Server.killAll;

(

SynthDef(\microtonesynth, {|out=0 amp=0.0 freq gate=1 width=0.5 relBus index1Bus|
	var rel,index1, f1,env,sig,sig2,fmmod;
	index1 = In.kr(index1Bus, 1);
	rel = In.kr(relBus, 1);
	f1 = freq;
	env = EnvGen.ar(Env.adsr(0.001,0.001,0.5,rel),gate,doneAction: 2);
	fmmod = Saw.ar(f1) * f1 * index1;

	//sig = VarSaw.ar((freq*1.04)+fmmod,0,SinOsc.kr(Rand(0.1,0.7)).range(0.1,0.9));
	sig = Pulse.ar((freq*1.01)+fmmod,width, 0.125);

	sig2 = Pulse.ar((freq*0.47)+fmmod,width, 0.125);
	sig = Mix(sig+sig2);
	//Out.ar(0, Pan2.ar(sig*env*amp*0.5) );
	Out.ar(out, sig*env*amp);
}).store;

SynthDef(\fm_grain_synth, {|out=0 amp=0.25 freq envbuf width=0.5 durBus relBus index1Bus|
	var rel,index1, f1,env,sig,sig2,fmmod,dur;
	index1 = In.kr(index1Bus, 1);
	rel = In.kr(relBus, 1);
	dur = In.kr(durBus, 1);
	f1 = freq;
	env = Osc1.ar(envbuf, dur);
	fmmod = Saw.ar(f1) * f1 * index1;

	//sig = VarSaw.ar((freq*1.04)+fmmod,0,SinOsc.kr(Rand(0.1,0.7)).range(0.1,0.9));
	sig = Pulse.ar((freq*1.01)+fmmod,width,0.01);

	sig2 = Pulse.ar((freq*0.47)+fmmod,width,0.01);
	sig = Mix(sig+sig2);
	//Out.ar(0, Pan2.ar(sig*env*amp*0.5) );
	Out.ar(out, Pan2.ar(sig*env*amp));
}).store;

SynthDef(\complex_fm_grain_synth, {|out=0 amp=0.25 freq envbuf width=0.5 durBus durampBus relBus index1Bus index2Bus|
	var rel,index1,index2, f1,env,sig,sig2,fmmod,fmmod2,fmmodmod,dur, duramp;
	index1 = In.kr(index1Bus, 1);
	index2 = In.kr(index2Bus, 1);
	rel = In.kr(relBus, 1);
	dur = In.kr(durBus, 1);
	duramp = In.kr(durampBus, 1);
	f1 = freq;
	env = Osc1.ar(envbuf, dur);
	fmmodmod = LFTri.ar(f1*0.1) * f1 * index2;
	fmmod = Saw.ar(f1+fmmodmod) * f1 * index1;
	fmmod2 = SinOsc.ar(f1+fmmodmod) * f1 * index1;
	//sig = VarSaw.ar((freq*1.04)+fmmod,0,SinOsc.kr(Rand(0.1,0.7)).range(0.1,0.9));
	sig = Pulse.ar((freq*1.01)+fmmod,width,duramp);

	sig2 = Pulse.ar((freq*0.47)+fmmod2,width,duramp);
	sig = MoogFF.ar(sig, f1*2*env, 3.5);
	sig2 = MoogFF.ar(sig2, f1*2*env, 3.5);
	//sig = Mix(sig+sig2);
	//Out.ar(0, Pan2.ar(sig*env*amp*0.5) );
	//Out.ar(out, sig*env*amp);
	Out.ar(out, Pan2.ar(sig*env*amp, LFNoise0.kr(3.2).range(-0.6,-0.25)));
	Out.ar(out, Pan2.ar(sig2*env*amp),LFNoise0.kr(6.4).range(0.8,0.1));
}).store;


//
// SynthDef(\combc, {|in out=0 amp=0.5 delBus decayBus|
// 	var del, decay,sig;
// 	del = In.kr(delBus, 1);
// 	decay = In.kr(decayBus, 1);
// 	sig = In.ar(in, 2);
// 	5.do{|i|
// 		d = del / (i + 1);
// 		e = decay / ( i + 1);
// 		sig = CombC.ar(sig, d, d, e, 0.05, sig);
// 	};
// Out.ar(out, Pan2.ar(sig)); }).store;

SynthDef(\combc, {|out=0 in maxdel mix=0.1 delBus decayBus|
	var del, decay, dry, wet,bpsig;
	del = In.kr(delBus, 1);
	decay = In.kr(decayBus, 1);
	dry = In.ar(in, 1);
	wet = dry;
	bpsig = dry;
	10.do{|i| var delay2, decay2, bfreq;
		delay2 = 0.0025 + ((i + 1) * 0.01);
		decay2 = (i + 1) * 1;
		bfreq = 900 + (i * 100);
		wet = CombC.ar(wet, delay2, SinOsc.kr(LFNoise2.kr(Rand(0.1,8.2)).range(0.001,0.1)).range(0.0025, delay2), decay2,0.05, wet);
		//bpsig = BPF.ar(wet, bfreq, 0.9,1.5, bpsig);
		wet = HPF.ar(wet, 40);
	};
	dry = (dry * mix) + (wet * (1-mix));
	dry = Compander.ar(dry, dry, 0.1,1.0,0.2,0.001,0.1,10.0);
	Out.ar(out, Pan2.ar(dry,SinOsc.kr(LFNoise0.kr(0.8).range(13.0,152.0)).range(-0.5,0.5)); )}).store;



fork{

MIDIClient.init;

MIDIIn.connectAll;


6.0.wait;
//MIDIIn.connect(1, MIDIClient.sources.at(3));

//MIDIIn.connect(0, MIDIClient.sources.at(2));

//MIDIIn.connectAll;


//Tuning.directory
~sineEnv = Buffer.sendCollection(s, Signal.welchWindow(1024));
//~sineEnv.put(~sineEnv.size-1, 0);

~notes = Array.fill(128,{ nil });
/*	Tuning.directory;
Scale.directory*/
~newScale = Scale.new((0..23),24,Tuning.harmonic);

/*
~newScale =
	Scale.new((0..40),41,Tuning.et41);*/
/*
Scale.directory
Tuning.directory
Tuning.et53
*/

	//~newScale[40]
	//~quarter[127]
~synthGroup = Group.new;

~comb_in = Bus.audio(s, 2);
~indexBus = Bus.control(s, 1).set(0.0);
~index2Bus = Bus.control(s, 1).set(0.0);
~relBus = Bus.control(s, 1).set(0.001);
~delBus = Bus.control(s, 1).set(0.25);
~decayBus = Bus.control(s, 1).set(5);
~durBus = Bus.control(s, 1).set(0.25);
~durampBus = Bus.control(s, 1).set(0.1);


~quarter =
Array.fill(128, {|i|
	var octave = i / 24;
	var sc = ~newScale;

	sc.semitones.wrapAt(i);

	case
	{ octave < 1; } { sc.semitones.wrapAt(i) }
	{ ((octave == 1) or: (octave > 1)) and: (octave < 2) } { sc.semitones.wrapAt(i) + 12 }
	{ ((octave == 2) or: (octave > 2)) and: (octave < 3)  } { sc.semitones.wrapAt(i) + 24 }
	{ ((octave == 3) or: (octave > 3)) and: (octave < 4)  } { sc.semitones.wrapAt(i) + 48 }
	{ ((octave == 4) or: (octave > 4)) and: (octave < 5)  } { sc.semitones.wrapAt(i) + 60 }
	{ ((octave == 5) or: (octave > 5)) and: (octave < 6)  } { sc.semitones.wrapAt(i) + 72 }
	{ ((octave == 6) or: (octave > 6)) and: (octave < 7)  } { sc.semitones.wrapAt(i) + 71 }

});

~combSynth.free;

~combSynth = Synth(\combc, [\in, ~comb_in, \delBus, ~delBus.index, \decayBus, ~decayBus.index], ~synthGroup, \addAfter);

MIDIdef.noteOn(\keyboard,
	{|vel note chan srcid|


	if ( ~notes[note].isNil, {

		case
				{ chan == 0 }
				{
				[vel, note].postln;
			~notes[note] =
			Synth(\fm_grain_synth, [\out,~comb_in,\envbuf,~sineEnv, \relBus,~relBus.index, \index1Bus, ~indexBus.index, \durBus, ~durBus.index,
		\freq, ~quarter[note].midicps,\amp, vel/127], ~synthGroup, \addToHead);
				}
				{ chan == 1 }
				{
			~notes[note] =
			Synth(\complex_fm_grain_synth, [\out,0,\envbuf,~sineEnv, \relBus,~relBus.index, \index1Bus, ~indexBus.index, \index2Bus,~index2Bus.index, \durBus, ~durBus.index, \durampBus, ~durampBus.index,
		\freq, ~quarter[note].midicps,\amp, vel/127], ~synthGroup, \addToHead);

				}
		});



	},nil
);

MIDIdef.noteOff(\keyboardoff, {|vel note chan srcid|
		//[vel, note, chan, srcid].postln;


		if(~notes[note].notNil, {

		    ~notes[note].set(\gate,0);
			~notes[note] = nil;
			});
	});

~indexSpec = [0.0, 1.0, \linear,0.001].asSpec;
~index2Spec = [0.0, 1.0, \linear,0.001].asSpec;
~relSpec = [0.001, 1.5, \exp,0.001].asSpec;
~delSpec = [0.05, 0.2, \exp,0.001].asSpec;
~decaySpec = [1.0, 6.0, \linear,0.001].asSpec;
~durSpec = [0.001, 2.5, \exp,0.001].asSpec;
~durampSpec = [0.05, 0.02, \linear,0.001].asSpec;


	MIDIdef.cc(\nano, { |val num chan src| [val,num].postln;
	case
		{ num == 82} {
			~indexBus.set(~indexSpec.map(val/127));

		}
		{ num == 83} {
			~index2Bus.set(~index2Spec.map(val/127));

		}
		{ num == 84} {
			~durBus.set(~durSpec.map(val/127).postln;);
			~durampBus.set(~durampSpec.map(val/127).postln;);
		}
		{ num == 85} {
			~delBus.set(~delSpec.map(val/127));

		}
		{ num == 86} {
			~decayBus.set(~decaySpec.map(val/127));

		}
		{ num == 87} {


		};

	}, nil);


};


)