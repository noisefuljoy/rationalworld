fork{


(
Tdef( 'tryOpenHID' , {
   var keepLooking = true;
   while ( { keepLooking } ){
      if ( ~myhid.notNil ){
         if ( ~myhid.isOpen ){
            keepLooking = false;
         }
      };
      if ( keepLooking ){
         HID.findAvailable;
         if ( HID.findBy(1133, 49686).size > 0 ){
            ~myhid = HID.open( 1133, 49686 );
            if ( ~myhid.notNil ){
               ~myhid.closeAction = {
                    "device closed".postln;
                    Tdef( \tryOpenHID ).reset.play;
               };
               keepLooking = false;
            }{
               3.0.wait;
            };
         }{
            3.0.wait;
         }
      }
   }
} );

Tdef( 'tryOpenHID' ).play;

/*insects*/
SynthDef(\fieldcricket, {|out=0 recout=100 tfreqBus gate=1 amp=1|
	var tfreq, env, trig, seq, demand, cricket;
	tfreq = In.kr(tfreqBus, 1);
	env = EnvGen.ar(Env.adsr(15,0.0,1,15),gate, doneAction: 2);

	// instead of [metro], Impulse.kr is used here. Delta t = 17 ms equates to 58.82 Hz.
	trig = Impulse.kr(tfreq);

	// the main idea of the following line was to use an approach
	// that uses the same coefficients as described in the pd patch
	seq = Dseq(Array.fill(41, {|i| if(i<7, {(i+2)/9},{0}) }),inf);
	demand = Demand.kr(trig,0,seq);

	// Implementation of the pd code for pulses including amplitude grow:
	// cricket = EnvGen.ar(Env.new([0, 1, 1, 0], [0.0001, 0.0001, 0]), trig) * demand;

	// 2nd implementation: pure data seemed to slightly disobey its own specifications,
	// so I analysed the waveform and came up with this:
	cricket = EnvGen.ar(Env.new([0, 1, 0], [4/44100, 0]), trig) * demand;


	cricket = OnePole.ar(cricket, exp(-2pi * (1000 * SampleDur.ir)));
	cricket = (
			// changed the Q factor of the first 3 BPFs to approximate farnells sound
			BPF.ar(cricket, 4500 + ((0..2)*50), 300.reciprocal, 100)).sum
			+ BPF.ar(cricket, 9000, 500.reciprocal, 42
	);
	cricket = ((cricket - OnePole.ar(cricket, exp(-2pi * (4000 * SampleDur.ir)))) * 0.5);
			Out.ar(out, Pan2.ar(cricket*env*amp) );
			Out.ar(recout, cricket*env*amp );
		}).store;




SynthDef(\cicada_3calls, {|out=0 recout=100 tfreqBus amp=1 gate=1|
	var tfreq, env, sig, trig, seq, freq, mul, vals;
	tfreq = In.kr(tfreqBus, 1);
	env = EnvGen.ar(Env.adsr(15,0.0,1,15),gate, doneAction: 2);

	trig = Impulse.kr(tfreq);
	vals = [
		[0.5, 128],
		[8,6],
		[30,3]
	];
	freq = TChoose.kr(trig, vals);


	sig = WhiteNoise.ar;
	// The one pole filters in pure data and SC differ, so I changed the coefficents
	// a little. Also the  multiplication by 5 is not in the book, but helps to
	// approach the audible result of Farnells patch.
	sig = (sig - OnePole.ar(sig, exp(-2pi * (8000 * SampleDur.ir))));
	sig = (sig - OnePole.ar(sig, exp(-2pi * (8000 * SampleDur.ir))));
	sig = OnePole.ar(sig, exp(-2pi * (10000 * SampleDur.ir)));
	sig = OnePole.ar(sig, exp(-2pi * (10000 * SampleDur.ir)));
	sig = sig * 5;


	sig = BPF.ar(sig, [7500, 5500], 40.reciprocal).sum * SinOsc.ar(500);
	sig = sig * (1 / (SinOsc.ar( freq[0], 0, freq[1] ).squared + 1));
	sig = (sig - OnePole.ar(sig, exp(-2pi * (4000 * SampleDur.ir)))) * 4;

			Out.ar(out, sig*env*amp);
			Out.ar(recout, sig*env*amp);
		}).store;



/*perc synths */
SynthDef(\perc, {|out=0 freq=440 amp=0.5 release=0.2 bufnum pan=0 phasemIndexBus|
	var env, sig,phasemIndex;
	phasemIndex = In.kr(phasemIndexBus, 1);
	env = EnvGen.ar(Env.perc(0.001, release),doneAction: 2);
	//sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), 1, 0,0);
	sig = SinOsc.ar(freq, LFSaw.kr(LFNoise0.kr(16.8).range(0.1,85.0),mul:phasemIndex).range(-2pi,2pi),0.5);
	Out.ar(out, sig*env*amp); }).store;

SynthDef(\perc2, {|out=0 freq=440 ffreq=1 fmIndex=1 amp=0.5 release=1 dur=3 bufnum pan=0 phasemIndexBus|
	var env, sig,phasemIndex, fmod,gate;
	gate = EnvGen.kr(Env([1,0],[dur]),1);
	phasemIndex = In.kr(phasemIndexBus, 1);
	env = EnvGen.ar(Env.adsr(0.01,0.0,1,release),gate,doneAction: 2);
	fmod = SinOsc.kr(freq,0,fmIndex);
			sig = SinOsc.ar(freq*fmod);
	//sig = Saw.ar(freq*fmod,0.5);
	//sig = VarSaw.ar([freq*0.8*fmod,freq*1*fmod,freq*1.2*fmod],[-0.25,0,0.25],SinOsc.kr(LFNoise0.kr(0.4).range(0.1,85.0)).range(0.1,0.9)!3,0.2);
	sig = Mix(sig);
	sig = LPF.ar(sig, 800);
	Out.ar(out, sig*env*amp); }).store;


SynthDef(\transform1, {|in=0 out=0 amp=1.0 mix=0.2 decay=4|
	var sig,drysig, wetsig;
	drysig = In.ar(in, 1);
	wetsig = drysig;

	1.do{|i| var del = (i+1)*0.1;
		wetsig = CombC.ar(wetsig, del, SinOsc.kr(del*0.1).range(del*0.1,del),(i+1)*decay,0.8,wetsig*0.6);
	};
	sig = ((1-mix)*drysig) + (mix*wetsig);
	Out.ar(out, Pan2.ar(sig*amp, SinOsc.kr(LFNoise0.kr(0.8).range(0.1,80.0)).range(-0.25,0.25)));
}).store;

SynthDef(\transform2, {|in=0 out=0 amp=1.0 mix=0.2 decay=1 pitchRatio=0.5|
	var sig,drysig, wetsig;
	drysig = In.ar(in, 1);
	wetsig = drysig;

	sig = PitchShift.ar(drysig, 0.4, pitchRatio, 0.05, 0.4, 0.5, drysig*0.5);
	sig = FreeVerb.ar(sig, 0.2, 0.6, 0.4);
	//sig = ((1-mix)*drysig) + (mix*wetsig);
	Out.ar(out, Pan2.ar(sig*amp, SinOsc.kr(LFNoise0.kr(0.8).range(0.1,80.0)).range(-0.25,0.25)));
}).store;

SynthDef(\transform3, {|in=0 out=0 amp=1.0 mix=0.2 decay=1 pitchRatio=0.25|
	var sig,drysig, wetsig;
	drysig = In.ar(in, 1);
	wetsig = drysig;

	sig = PitchShift.ar(drysig, 0.6, pitchRatio, 0.05, 0.4, 0.6, drysig*0.5);
	sig = Decimator.ar(sig, SinOsc.kr(LFNoise0.kr(0.4).range(1,32.0)).range(10000,9000),8);
	sig = FreeVerb.ar(sig, 0.2, 0.9, 0.4);
	//sig = ((1-mix)*drysig) + (mix*wetsig);
	Out.ar(out, Pan2.ar(sig*amp, SinOsc.kr(LFNoise0.kr(0.8).range(0.1,80.0)).range(-0.25,0.25)));
}).store;

SynthDef(\transform4, {|in=0 out=0 amp=1.0 mix=0.2 decay=1 pitchRatio=0.25|
	var sig,drysig, wetsig,mod;
	drysig = In.ar(in, 1);
	wetsig = drysig;
	wetsig = PitchShift.ar(drysig, 2, 4, 0.05, 2,1);
	mod = SinOsc.ar(LFNoise2.kr(0.6).range(0.001,50.0),0,0.5, 1);
	sig = (wetsig * mod) + (drysig * (1 - mod));

	sig = FreeVerb.ar(sig, 0.5, 0.95, 0.4);
	//sig = ((1-mix)*drysig) + (mix*wetsig);
	Out.ar(out, Pan2.ar(sig*amp, SinOsc.kr(LFNoise0.kr(0.8).range(0.1,80.0)).range(-0.75,0.75)));
}).store;

/* transform chains sketch */
/*
~percGroup = Group.new;
~transformChain1 = Group.after(~percGroup);
~transformChain2 = Group.after(~percGroup);
~transformChain3 = Group.after(~percGroup);
~transformChain4 = Group.after(~percGroup);
~transBuses = Array.fill(4, { Bus.audio(s, 1); });

		~trans1 = Synth(\transform1, [\in, ~transBuses[0]], ~transformChain1);
		~trans2 = Synth(\transform2, [\in, ~transBuses[1]], ~transformChain2);
		~trans3 = Synth(\transform3, [\in, ~transBuses[2]], ~transformChain3);
		~trans4 = Synth(\transform4, [\in, ~transBuses[3]], ~transformChain4);

~r = Routine({
			inf.do{
				var dur = rrand (0.01, 0.5);

				Synth(\perc2,[\out, ~transBuses.choose,\freq, [110,220,330,440].choose,\ffreq, rrand(5.0, 120.0),\fmIndex, rrand(10,1000), \dur, dur],~percGroup);

				dur.wait; };
		}).play;

~r.stop;
*/

SynthDef(\perc_effect, {|in=0 out=0 amp=1.0 mix=0.0 decay=1|
	var sig,drysig, wetsig;
	drysig = In.ar(in, 1);
	wetsig = drysig;
	3.do{|i| var del = (i+1)*0.1;
		wetsig = CombL.ar(wetsig, del, SinOsc.kr(del*0.1).range(del*0.1,del),(i+1)*decay,0.4,wetsig*0.6);
	};
	sig = ((1-mix)*drysig) + (mix*wetsig);
	Out.ar(out, Pan2.ar(sig*amp, SinOsc.kr(LFNoise0.kr(0.8).range(0.1,80.0)).range(-0.25,0.25)));
}).store;

SynthDef(\grain_perc, {|in=0 out=0 amp=0.5 mix=0.0 envbuf|
	var sig,drysig, wetsig;
	sig = In.ar(in, 1);
	//wetsig = drysig;

			sig = PitchShift.ar(sig, 0.4, SinOsc.kr(0.2).range(0.5,0.75),0.1,0.3);
			sig = GrainIn.ar(1, Impulse.ar(SinOsc.kr(0.1).range(32, 85)),0.05, sig,0,envbuf,256);

	Out.ar(out, Pan2.ar(sig*amp, SinOsc.kr(LFNoise0.kr(0.8).range(0.1,80.0)).range(-0.75,0.8)));
}).store;

SynthDef(\dist_effect, {|in=0 out=0 amp=1.0 mix=0.0 decay=1|
	var sig,drysig, wetsig;
	drysig = In.ar(in, 1);
	wetsig = drysig;
	wetsig = Decimator.ar(wetsig, 10000,8);
	2.do{|i| var del = (i+1)*0.1;
		wetsig = CombC.ar(wetsig, del, SinOsc.kr(del*0.1).range(del*0.1,del),(i+1)*decay,0.4,wetsig*0.6);
	};
	sig = ((1-mix)*drysig) + (mix*wetsig);
	Out.ar(out, Pan2.ar(sig*amp, SinOsc.kr(LFNoise0.kr(0.8).range(0.1,80.0)).range(-0.25,0.25)));
}).store;

SynthDef(\field_rec, {|out=0 amp=0.4 gate=1 bufnum|
	var env, sig;
	env = EnvGen.ar(Env.adsr(1.0,0.1,0.5,3.0),gate,doneAction: 2);
	sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), 1, 0, 1);
	Out.ar(out, sig*env*amp); }).add;

SynthDef(\fm7, {|out=0 amp=0.4 mod1=0, mod2=0, mod3=0, mod4=0 gate=1|
    var env, ctls, mods, chans, sig;
	env = EnvGen.ar(Env.adsr(1.0,0.1,0.5,2.0),gate, doneAction: 2);
    ctls = [
        // freq, phase, amp
        [LFNoise1.kr(0.5).range(300, 310), 0, 1],
        [LFNoise1.kr(0.5).exprange(3, 310), 0, 1],
        [LFNoise1.kr(0.5).exprange(3, 100), 0, 1],
        [LFNoise1.kr(0.5).exprange(3, 100), 0, 1],
        [LFNoise1.kr(0.5).exprange(3, 100), 0, 1],
        [LFNoise1.kr(0.5).exprange(3, 100), 0, 1]
    ];
    mods = [
        [Line.kr(0, 0.001, 2), Line.kr(0.1, 0, 4), 0, mod2, 0, 0],
        [mod1, 0, 0, 0, 0, 0],
        [0, mod4, 0, 0, mod3, 0],
        [0, mod3, 0, 0, mod4, 0],
        [mod4, 0, 0, 0, 0, 0],
        [mod3, 0, 0, 0, 0, 0]
    ];
    chans = [0, 1];
    sig = FM7.ar(ctls, mods).slice(chans) * -12.dbamp; // using "slice" to select specific channels
	sig = CombC.ar(sig, 0.1, LFNoise2.kr(1.8).range(0.001,0.1),SinOsc.kr(LFNoise2.kr(0.4).range(0.001,0.5)).range(0.1,8.0),0.5,sig*0.5);
	//sig = FreeVerb2.ar(sig[0],sig[1], 0.4, 0.7,0.8);
	Out.ar(out, sig*env*amp);
}).store;

 SynthDef(\fmseven, {|out=0 amp=0.25 gate=1 mod1=1 mod2=1 mod3=1 mod4=1|

	var env = EnvGen.ar(Env.adsr(5.0,0.1,1.0,6.0),gate, doneAction: 2);
            var x= #[ [ [ 0.0, -0.33333333333333, -1.0, 0.0 ], [ 0.75, 0.75, 0.0, -0.5 ], [ -0.5, -0.25, 0.25, -0.75 ], [ -0.5, 1.0, 1.0, 1.0 ], [ 0.0, 0.16666666666667, -0.75, -1.0 ], [ 0.5, 0.5, -0.5, 0.33333333333333 ] ], [ [ -0.33333333333333, 0.5, -0.5, -0.5 ], [ 0.5, 0.75, 0.25, 0.75 ], [ -0.83333333333333, 0.25, -1.0, 0.5 ], [ 1.5, 0.25, 0.25, -0.25 ], [ -0.66666666666667, -0.66666666666667, -1.0, -0.5 ], [ -1.0, 0.0, -0.83333333333333, -0.33333333333333 ] ], [ [ 0.25, -0.5, -0.5, -1.0 ], [ -0.5, 1.0, -1.5, 0.0 ], [ -1.0, -1.5, -0.5, 0.0 ], [ 0.5, -1.0, 1.1666666666667, -0.5 ], [ 0.83333333333333, -0.75, -1.5, 0.5 ], [ 0.25, -1.0, 0.5, 1.0 ] ], [ [ 1.0, 0.33333333333333, 0.0, -0.75 ], [ -0.25, 0.0, 0.0, -0.5 ], [ -0.5, -0.5, 0.0, 0.5 ], [ 1.0, 0.75, 0.5, 0.5 ], [ 0.0, 1.5, -0.5, 0.0 ], [ 1.0, 0.0, -0.25, -0.5 ] ], [ [ 0.5, -0.25, 0.0, 0.33333333333333 ], [ 0.25, -0.75, 0.33333333333333, -1.0 ], [ -0.25, -0.5, 0.25, -1.1666666666667 ], [ 0.0, 0.25, 0.5, 0.16666666666667 ], [ -1.0, -0.5, 0.83333333333333, -0.5 ], [ 0.83333333333333, -0.75, -0.5, 0.0 ] ], [ [ 0.0, -0.75, -0.16666666666667, 0.0 ], [ 1.0, 0.5, 0.5, 0.0 ], [ -0.5, 0.0, -0.5, 0.0 ], [ -0.5, -0.16666666666667, 0.0, 0.5 ], [ -0.25, 0.16666666666667, -0.75, 0.25 ], [ -1.1666666666667, -1.3333333333333, -0.16666666666667, 1.5 ] ] ];
            var y= #[ [ [ 0.0, -0.5, 1.0, 0.0 ], [ -0.5, 1.0, 0.5, -0.5 ], [ 0.0, 0.33333333333333, 1.0, 1.0 ] ], [ [ -0.5, 0.5, 1.0, 1.0 ], [ 0.0, 0.33333333333333, 0.0, 1.5 ], [ -0.5, 0.83333333333333, 1.0, 0.0 ] ], [ [ 0.25, -0.66666666666667, 0.25, 0.0 ], [ 0.5, -0.5, -0.5, -0.5 ], [ 0.5, -0.5, -0.75, 0.83333333333333 ] ], [ [ -0.25, 1.0, 0.0, 0.33333333333333 ], [ -1.25, -0.25, 0.5, 0.0 ], [ 0.0, -1.25, -0.25, -0.5 ] ], [ [ 0.75, -0.25, 1.5, 0.0 ], [ 0.25, -1.5, 0.5, 0.5 ], [ -0.5, -0.5, -0.5, -0.25 ] ], [ [ 0.0, 0.5, -0.5, 0.25 ], [ 0.25, 0.5, -0.33333333333333, 0.0 ], [ 1.0, 0.5, -0.16666666666667, 0.5 ] ] ];

                var ctls= x.collect{|a| a.collect{|b| SinOsc.ar(*b)}};
                var mods= y.collect{|a| a.collect{|b| Pulse.ar(*b)}};
                var chans= #[0, 1, 2, 4, 5];
	var sig = (FM7.ar(ctls, mods).slice(chans) * [mod1*2, mod2*2, LFSaw.kr(mod3*3).range(0, -12.dbamp), mod4, -3.dbamp]).clump(2).sum*0.5;

	3.do{|i| var del = (i+2)*0.1;
		sig = AllpassC.ar(sig,del,LFNoise0.kr(del).range(0.01,del),FSinOsc.kr(LFNoise0.kr(del*mod2).range(0.01,30.0)).range(0.1,(i+1)*(mod4)),0.75,sig*0.25); };

	sig = Mix(sig);
	Out.ar(out, Pan2.ar(sig*env*amp, LFSaw.kr(LFNoise0.kr(0.8*mod3).range(3.0,120.0)).range(-1.0,1.0) ) );
}).store;


SynthDef(\magic_drone,{|out=0 amp=1.0 gate=1 ratio=1|

	var env = EnvGen.ar(Env.adsr(3.0,0.1,1,4.0),gate, doneAction: 2);
	var sig = VarSaw.ar([82.41,184.995,329.64]*ratio,[0,0,0],
		[ SinOsc.kr(0.01).range(0.3,0.8), LFSaw.kr(0.02).range(0.01,0.5), LFTri.kr(0.04).range(0.5,0.99) ],
		0.33!3);

	sig = Mix(sig);
	3.do{ |i| var del = (i+3)*0.1;

		sig = AllpassC.ar(sig,0.3,SinOsc.kr(0.003).range(0.001,0.3),LFNoise1.kr(0.2).range(1.0,8.0),0.5,sig*0.5);

	};
	Out.ar(out, Pan2.ar(sig*env*amp, SinOsc.kr(0.1).range(-0.4,0.7))    );

}).store;


// a custom envelope
~winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
~window = Buffer.sendCollection(s, ~winenv.discretize, 1);

SynthDef(\field_grain, { |out=0, gate = 1, amp = 1,posBus,bufnum, envbuf, trateBus durBus|
    var sig,sig1,sig2, pan, env, freqdev,trate, dur, pos;
			trate = In.kr(trateBus, 1);
			dur = In.kr(durBus, 1);
			pos = In.kr(posBus, 1);

    env = EnvGen.kr(
        Env([0, 1, 0], [1, 1], \sin, 1),
        gate,
        levelScale: amp,
        doneAction: Done.freeSelf);

	sig = GrainBuf.ar(2, Impulse.kr(trate), dur, bufnum, 1,
				pos, 2, FSinOsc.kr(LFNoise0.kr(0.2).range(0.01,350.0)).range(-0.1,0.1), envbuf);
			sig1 = PitchShift.ar(sig[0], 0.4,0.1, 0.2, 0.4, 0.5, sig[0]*0.5) * env;
			sig2 = PitchShift.ar(sig[1], 0.4, 0.125, 0.2, 0.4, 0.5, sig[1]*0.5) * env;


			Out.ar(out, [sig1, sig2]);
}).store;


~nyquist = s.sampleRate * 0.5;

~modRange = [0.1, 9, \exp, 0.001].asSpec;
~ampRange = [0.25, 1.0, \linear, 0.001].asSpec;
~relRange = [0.1, 2.0, \linear, 0.001].asSpec;
~decRange = [0.001, 30.0, \exp, 0.001].asSpec;
~ratioSpec = [0, 15, \linear, 1].asSpec;

~ratios = [0.25,0.25,0.5,0.75,0.85,0.9,1,1.1,1.2,1.3,1.4,1.5,1.75,1.8,1.9,2.0];

~mainGroup = Group.new;
~fieldrecGroup = Group.new(~mainGroup);
~percGroup = Group.new(~mainGroup);
~fmGroup = Group.new(~mainGroup);
~fm1Group = Group.new(~fmGroup);
~fm1Group = Group.new(~fmGroup);
~fm1Group = Group.new(~fmGroup);

~percBus = Bus.audio(s, 1);


~combPerc = Synth(\perc_effect, [\in, ~percBus], ~percGroup, \addAfter);

~field_rec_files = "~/repositories/rationalworld/AE_Samples/*.wav".pathMatch;
~field_recs = ~field_rec_files.collect({|sample| Buffer.read(s, sample); });
~grainfield_recs = ~field_rec_files.collect({|sample| Buffer.readChannel(s, sample, channels: [0] ); });

~recBufs = [ Buffer.alloc(s, 44100*5, 1), Buffer.alloc(s, 44100*5, 1); ];
~samNum1 = 0;
~fftbuf = Buffer.alloc(s, 1024,1);

~freezeSwitch = 0;
~fieldrecSwitch = ~field_recs.size - 1;
~fieldrecnum = 0;


~winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
~window = Buffer.sendCollection(s, ~winenv.discretize, 1);


);
(


/*    LOGITECH DUAL ACTION MAPPING */
/* main buttons */
~fmSwitch = 0;


	~sdr_fft = Buffer.alloc(s, 512, 1);
	~sdr_rec_buf = Buffer.alloc(s, s.sampleRate*4, 1);
		2.0.wait;
		~sdr_rec = Synth(\zitarRecorder, [\in, 4, \fftbuf, ~sdr_fft, \recbuf, ~sdr_rec_buf]);



HIDdef.usage( \button_1, { |value|

	if ( value == 0, {
	if ( ~fmSwitch != 1, { ~fmSwitch = ~fmSwitch + 1; },
		{
			~fmSwitch = 0;

	});
	("fm synth : "++~fmSwitch).postln;

	});

}, \b1 );


/* synth trigger */
HIDdef.usage( \main_but_1, { |value|
	if ( ~freezeSwitch == 0, {
		if ( value == 1, {

			case
			{ ~fmSwitch == 0 }
			{

				Synth(\fm7, [\gate,1], ~fm1Group); }
			{ ~fmSwitch == 1 }
			{
				Synth(\fmseven, [\gate,1], ~fm1Group);

			};


		}, { ~fm1Group.set(\gate, 0);  });

		});


	}, \b5 );

/* freeze button */
HIDdef.usage( \main_but_2, { |value|
	if ( value == 1, {
		if ( ~freezeSwitch == 0, { ~freezeSwitch = 1; "frozen".postln; }, { ~freezeSwitch = 0; "unfrozen".postln; });
	});
}, \b6 );

HIDdef.usage( \main_but_3, { |value|
	if ( value == 1, {
		if ( ~fieldrecSwitch == 0, { "play field rec".postln;
			Synth(\field_grain, [\gate,1,\bufnum,~sdr_rec_buf, \envbuf, ~window, \trateBus, ~fr_trateBus.index, \durBus, ~fr_durBus.index, \posBus, ~fr_posBus.index
					], ~fieldrecGroup);
			~fieldrecSwitch = 1;

		},
		{  "stop field rec".postln; ~fieldrecGroup.set(\gate, 0);  ~fieldrecSwitch = 0; });
	});
	 }, \b7 );


HIDdef.usage( \main_but_4, { |value|
	if ( value == 1, {
		if ( ~fieldrecnum == (~field_recs.size-1), { ~fieldrecnum = 0; }, { ~fieldrecnum = ~fieldrecnum + 1; });
		"fieldrec sample: "++~fieldrecnum.postln;
		  });

	}, \b8 );

	~fr_trateBus = Bus.control(s, 1).set(1);
	~fr_durBus = Bus.control(s, 1).set(1.0);
	~fr_posBus = Bus.control(s, 1).set(0.0);


	~fr_trateRange = [1, 100, \linear,0.001].asSpec;
	~fr_durRange = [1.0, 0.001, \linear,0.001].asSpec;
	~fr_posRange = [0.05, 0.75, \linear,0.001].asSpec;

/* eerste joystick */
HIDdef.usage( \x_ax_1, { |value|
	if ( ~freezeSwitch == 0, {
		~fmGroup.set(\mod1, ~modRange.map(value));
		~fr_trateBus.set(~fr_trateRange.map(value));
	});

	}, \X );
HIDdef.usage( \y_ax_1, { |value|
	if ( ~freezeSwitch == 0, {
		~fmGroup.set(\mod2, ~modRange.map(value));
		~fr_durBus.set(~fr_durRange.map(value));
	});
	}, \Joystick );
HIDdef.usage( \joy_but_1, { |value|  value.postln; }, \b11 );

/* tweede joystick */
HIDdef.usage( \x_ax_2, { |value|
	if ( ~freezeSwitch == 0, {
		~fmGroup.set(\mod3, ~modRange.map(value));
		~fr_posBus.set(~fr_posRange.map(value));
	});
	}, \Y );
HIDdef.usage( \y_ax_2, { |value| if ( ~freezeSwitch == 0, {
	~fmGroup.set(\mod4, ~modRange.map(value));
});
}, \Z );

HIDdef.usage( \joy_but_2, { |value|  value.postln; }, \b12 );

);






Ndef(\sjoerd_in, {
	var sig = SoundIn.ar(0)*0.01;

	sig = HPF.ar(sig, 35);
	//sig = MidEQ.ar(sig,230,0.6,-8);
	//sig = MidEQ.ar(sig,2000,0.6,5);


	sig = sig!2;

}).play;






};




