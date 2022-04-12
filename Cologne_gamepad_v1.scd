
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


/*
HID.debug = false;
~myhid.postUsages;
*/

SynthDef(\radioplaypattern, {|out=0 ampBus lengthBus start=0 endBus octave=1 trig=1 reverse=1 bufnum envbuf xpos=0 ypos=0 vectorOut nyquist|
	//var trigger = EnvGen.kr(Env([0,1,0],[0.001,0.001]),trig);
	var amp = In.kr(ampBus, 1);
	var end = In.kr(endBus, 1);
	var length = In.kr(lengthBus, 1);
	var env = Osc1.ar(envbuf, length*Rand(1.0,2.0));
	var sig = BufRd.ar(1, bufnum, Phasor.ar(trig, BufRateScale.kr(bufnum)*reverse*octave,start,end ),loop: 1) * env * 0.5;
	//var sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum),trig, loop: 1);
	//Out.ar(out, Pan2.ar(sig, LFNoise1.kr(Rand(0.8,3.2)).range(pan,pan+0.25)));
	//Out.ar(out, Pan4.ar(sig, xpos, ypos));
	sig = LPF.ar(sig, nyquist);
			sig = HPF.ar(sig, 400);
			sig = HPF.ar(sig, 400);
	Out.ar(out, Pan2.ar(sig*amp, LFNoise0.kr(6.4).range(-1.0,1.0) ));
	/*
	Out.ar(out, Pan2.ar(sig*amp,LFNoise0.kr(3.2).range(-1.0,1.0)) );

	Out.ar(out, PanAz.ar(6, sig*amp,
				LFNoise0.kr(3.2).range(0.0,1.0),1.0,6.0,0.5));
			*/
	//Out.ar(out, sig*amp);

	}).store;

SynthDef(\kick, {|out=0 amp=0.5 release=0.2 bufnum pan=0|
	var env, sig;
	env = EnvGen.ar(Env.perc(0.001, release),doneAction: 2);
	sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), 1, 0,0);
	Out.ar(out, Pan2.ar( sig*env*amp, pan)); }).store;

SynthDef(\perc, {|out=0 amp=0.5 release=0.2 bufnum pan=0|
	var env, sig;
	env = EnvGen.ar(Env.perc(0.001, release),doneAction: 2);
	sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), 1, 0,0);
	Out.ar(out, sig*env*amp, pan); }).store;

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

	//sig = Mix(sig);
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


SynthDef(\sjoerd_in, {|in=0 out=0 amp=0.8 gate=1 delAmount=0|

	var env, sig, delsig;
	env = EnvGen.ar(Env.adsr(3.0,0.1,1,4.0),gate, doneAction: 2);
	sig = SoundIn.ar(in);


	sig = HPF.ar(sig, 35);
	sig = MidEQ.ar(sig,230,0.6,-8);
	sig = MidEQ.ar(sig,2000,0.6,5);
	delsig = sig;
	3.do{|i| var del = (i+1)*0.15;
	delsig = AllpassC.ar(delsig,del,SinOsc.kr(0.003).range(0.01,del),LFNoise1.kr(del).range(1.0,8.0),0.25,delsig*0.9);
	};
	/*
	3.do{|i| var del = (i+1)*0.1;
	delsig = CombC.ar(delsig,del,SinOsc.kr(del*0.001).range(0.01,del),LFNoise1.kr(del).range(1.0,3.0),0.3,delsig*0.7);
	};
	*/
	sig = ((1-delAmount)*sig) + (delAmount * delsig);
	Out.ar(out, Pan2.ar(sig*env*amp,0)    );

}).store;



SynthDef(\mari_in, {|in=0 out=0 amp=0.8 gate=1 delAmount=0 bpAmount=0|

	var env, sig, bpsig, delsig;
	env = EnvGen.ar(Env.adsr(3.0,0.1,1,4.0),gate, doneAction: 2);
	sig = SoundIn.ar(in);


	sig = HPF.ar(sig, 100);
	sig = MidEQ.ar(sig,230,0.6,-12);
	sig = MidEQ.ar(sig,1000,0.6,3);
	sig = MidEQ.ar(sig,2000,0.6,8);
	/*
	bpsig = BPF.ar(sig, 1000,0.3,4.0).tanh;
	sig = ((1-bpAmount)*sig) + (bpAmount * bpsig);
	*/
	delsig = sig;


	//delsig = PitchShift.ar(sig,0.2,1.15,0.1,0.1);

	3.do{|i| var del = (i+1)*0.15;
	delsig = AllpassC.ar(delsig,del,SinOsc.kr(0.003).range(0.01,del),LFNoise1.kr(del).range(1.0,8.0),0.25,delsig*0.9);
	};
	3.do{|i| var del = (i+1)*0.1;
	delsig = CombC.ar(delsig,del,SinOsc.kr(del*0.001).range(0.01,del),LFNoise1.kr(del).range(1.0,3.0),0.3,delsig*0.7);
	};

	sig = ((1-delAmount)*sig) + (delAmount * delsig);
	Out.ar(out, Pan2.ar(sig*env*amp,0));
}).store;



// a custom envelope
SynthDef(\field_grain, { |out=0, gate = 1, amp = 1, sndbuf, envbuf, trate=10 dur=0.1|
    var sig, pan, env, freqdev;

    env = EnvGen.kr(
        Env([0, 1, 0], [1, 1], \sin, 1),
        gate,
        levelScale: amp,
        doneAction: Done.freeSelf);


    Out.ar(out,
        GrainBuf.ar(2, Impulse.kr(trate), dur, sndbuf, LFNoise1.kr.range(0.5, 2),
			LFNoise2.kr(0.4).range(0, 1), 2, FSinOsc.kr(LFNoise0.kr(3.2).range(0.1,60.0)).range(-1.0,1.0), envbuf) * env)
}).store;


SynthDef(\zitarRecorder, {|in=0 amplitudeBus fftbuf recbuf|
var input = SoundIn.ar(in);
var chain = FFT(fftbuf, input);
var onsets = Onsets.kr(chain,0.3);

//input = Compander.ar(input, input, 0.001,1,0.001,0.001,0.1,500);
//amplitude.poll;
RecordBuf.ar(input, recbuf,loop:0,trigger:onsets);
}).store;

~nyquist = s.sampleRate * 0.5;

~modRange = [0.001, 9, \exp, 0.001].asSpec;
~ampRange = [0.25, 1.0, \linear, 0.001].asSpec;
~relRange = [0.1, 2.0, \linear, 0.001].asSpec;
~decRange = [0.001, 30.0, \exp, 0.001].asSpec;
~ratioSpec = [0, 15, \linear, 1].asSpec;

~ratios = [0.25,0.25,0.5,0.75,0.85,0.9,1,1.1,1.2,1.3,1.4,1.5,1.75,1.8,1.9,2.0];

~lengthSpec = [1.0,0.001,\exp].asSpec;
~trateSpec = [1.0,500.0,\exp].asSpec;
//~lengthSpec = [0.001, 1.0,\linear].asSpec;
//~endSpec = [0.001, 1.0,\linear].asSpec;
~endSpec = [1.0,0.0001,\exp].asSpec;
~clockSpec = [0.5, 3.0, \exp].asSpec;
~startSpec = [0.0,0.9,\linear].asSpec;

~mainGroup = Group.new;
~fieldrecGroup = Group.new(~mainGroup);
~percGroup = Group.new(~mainGroup);
~fmGroup = Group.new(~mainGroup);
~fm1Group = Group.new(~fmGroup);
~fm1Group = Group.new(~fmGroup);
~fm1Group = Group.new(~fmGroup);

~percBus = Bus.audio(s, 1);


~combPerc = Synth(\perc_effect, [\in, ~percBus], ~percGroup, \addAfter);

~kick_files = (Platform.resourceDir +/+ "sounds/kicks/*.wav").pathMatch;
~kicks = ~kick_files.collect({|i| Buffer.read(s, i); });

~hat_files = "Drums/HiHat/*.wav".pathMatch;
~hats = ~hat_files.collect({|i| Buffer.read(s, i); });

~cymbal_files = "Drums/Cymbal/*.wav".pathMatch;
~cymbals = ~cymbal_files.collect({|i| Buffer.read(s, i); });

~combo_files = "Drums/Combo/*.wav".pathMatch;
~combo = ~combo_files.collect({|i| Buffer.read(s, i); });

~mallet_files = "Drums/Mallet_Drum/*.wav".pathMatch;
~mallets = ~mallet_files.collect({|i| Buffer.read(s, i); });

~hand_files = "Drums/Hand_Drum/*.wav".pathMatch;
~hand_drums = ~hand_files.collect({|i| Buffer.read(s, i); });

~field_rec_files = "field_recs/*.wav".pathMatch;
~field_recs = ~field_rec_files.collect({|sample| Buffer.read(s, sample); });
~grainfield_recs = ~field_rec_files.collect({|sample| Buffer.readChannel(s, sample, channels: [0] ); });

~recBufs = [ Buffer.alloc(s, 44100*5, 1), Buffer.alloc(s, 44100*5, 1); ];
~samNum1 = 0;
~fftbuf = Buffer.alloc(s, 1024,1);

~freezeSwitch = 0;
~fieldrecSwitch = ~field_recs.size - 1;
~fieldrecnum = 0;

~lengthBus = Bus.control(s, 1).set(0.1);
~startBus = Bus.control(s, 1).set(0.0);
~patAmpBus = Bus.control(s, 1).set(1.0);

~endBus = Bus.control(s, 1).set(~recBufs[~samNum1].numFrames);
~clock = TempoClock.new;

~sine = Env.sine.discretize(1024).putLast(0);
~sineEnv = Buffer.sendCollection(s, ~sine, 1);

~winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
~window = Buffer.sendCollection(s, ~winenv.discretize, 1);


);
(


/*    LOGITECH DUAL ACTION MAPPING */
/* main buttons */
~fmSwitch = 0;

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
			Synth(\field_rec, [\gate,1,\bufnum,~field_recs[~fieldrecnum] ], ~fieldrecGroup);
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


/* eerste joystick */
HIDdef.usage( \x_ax_1, { |value|
	if ( ~freezeSwitch == 0, {
		~fmGroup.set(\mod1, ~modRange.map(value));
	});

	}, \X );
HIDdef.usage( \y_ax_1, { |value|
	if ( ~freezeSwitch == 0, {
		~fmGroup.set(\mod2, ~modRange.map(value));
	});
	}, \Joystick );
HIDdef.usage( \joy_but_1, { |value|  value.postln; }, \b11 );

/* tweede joystick */
HIDdef.usage( \x_ax_2, { |value|
	if ( ~freezeSwitch == 0, {
		~fmGroup.set(\mod3, ~modRange.map(value));
	});
	}, \Y );
HIDdef.usage( \y_ax_2, { |value| if ( ~freezeSwitch == 0, {
	~fmGroup.set(\mod4, ~modRange.map(value));
});
}, \Z );

HIDdef.usage( \joy_but_2, { |value|  value.postln; }, \b12 );



);



Server.default.makeGui


s.boot;



Ndef(\sjoerd_in, {
	var sig = SoundIn.ar(0);

	sig = HPF.ar(sig, 35);
	sig = MidEQ.ar(sig,230,0.6,-8);
	sig = MidEQ.ar(sig,2000,0.6,5);


	sig = sig!2;

}).play;


Ndef(\mariana_in, {
	var sig = SoundIn.ar(1);

	sig = HPF.ar(sig, 35);
	sig = MidEQ.ar(sig,220,0.7,-12);
	sig = MidEQ.ar(sig,1100,0.6,3);
	sig = MidEQ.ar(sig,5000,0.8,2);

	sig = Compander.ar(sig, sig,0.3,1.0,0.2,0.001,0.1,2);

	sig = sig!2;

}).play;






Ndef(\t,{

	var sig = VarSaw.ar(FSinOsc.kr(0.01).range(97.5,98.5),0,FSinOsc.kr(0.02).range(0.2,0.8),0.3);
	sig = MoogFF.ar(sig, SinOsc.kr(LFNoise0.kr(0.4).range(0.001,0.2)).range(50,900),3,0,0.5,sig*0.5);
	sig = AllpassC.ar(sig,0.1,SinOsc.kr(0.003).range(0.001,0.1),SinOsc.kr(0.003).range(1.0,11.0),0.5,sig*0.5);
	sig = LPF.ar(sig, 900);
	sig = LPF.ar(sig, 900,4);

	Pan2.ar(sig, SinOsc.kr(0.0025).range(-1.0,1.0));


}).play;


~freqRange = [500, 5000, \exponential].asSpec; // create a frequency range

HIDdef.usage( \freq, { |value| Ndef( \sinewave ).set( \freq, ~freqRange.map( value ) ); }, \X );
HIDdef.usage( \amp, { |value| Ndef( \sinewave ).set( \amp, value ); }, \Y );


Ndef( \sinewave ).free;

Quarks.gui




(
{
    var ctls = [
        // freq, phase, amp
        [LFNoise1.kr(0.5).range(300, 310), 0, 1],
        [LFNoise1.kr(0.5).exprange(3, 310), 0, 1],
        [LFNoise1.kr(0.5).exprange(3, 100), 0, 1],
        [LFNoise1.kr(0.5).exprange(3, 100), 0, 1],
        [LFNoise1.kr(0.5).exprange(3, 100), 0, 1],
        [LFNoise1.kr(0.5).exprange(3, 100), 0, 1]
    ];
    FM7.arAlgo(1, ctls, MouseX.kr(0, 2))
}.play

)


(
// Courtesy Fredrik Olofsson (2008)
Routine.run{
    var syn, time = 3; // Allow each patch to run for 16sec / 8bars
    inf.do{|i|
        ("// FM7 patch"+i).post;
        syn= ("
            (
            var x= #"++({{{ |i| rrand(0.5, 1.5).round(0.5)}!4}!3}!6).asCompileString++";
            var y= #"++({{{ |i| rrand(0.2, 1.6).round(0.5)}!4}!6}!6).asCompileString++";
            {
                var ctls= x.collect{|a| a.collect{|b| LFSaw.kr(*b)}};
                var mods= y.collect{|a| a.collect{|b| LFPar.kr(*b)}};
                var chans= #[0, 1];
                FM7.ar(ctls, mods).slice(chans)*0.5;
            }.play)").postln.interpret;
        time.wait;
        syn.free;
    };
};
)

(
// Courtesy Fredrik Olofsson (2008), edited by <sk>
// FM7 patch 4 generated on Thu Jun 26 18:27:12 2008







