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

SynthDef(\perc, {|out=0 amp=0.5 release=0.2 bufnum pan=0 phasemIndexBus|
	var env, sig,phasemIndex;
	phasemIndex = In.kr(phasemIndexBus, 1);
	env = EnvGen.ar(Env.perc(0.001, release),doneAction: 2);
	//sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), 1, 0,0);
	sig = SinOsc.ar(440, LFSaw.kr(LFNoise0.kr(16.8).range(0.1,85.0),mul:phasemIndex).range(-2pi,2pi),0.5);
	Out.ar(out, sig*env*amp); }).store;

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

SynthDef(\grain_perc, {|in=0 out=0 amp=0.25 mix=0.0|
	var sig,drysig, wetsig;
	sig = In.ar(in, 1);
	//wetsig = drysig;

			sig = PitchShift.ar(sig, 0.2, SinOsc.kr(0.01).range(0.1,0.25),0.1,0.1);
	sig = GrainIn.ar(1, Impulse.kr(SinOsc.kr(LFNoise2.kr(3.2).range(1,92)).range(35,350)),LFNoise0.kr(1.6).range(0.05,0.3), sig);


	/*3.do{|i| var del = (i+1)*0.1;
		wetsig = CombC.ar(wetsig, del, SinOsc.kr(del*0.1).range(del*0.1,del),(i+1)*decay,0.4,wetsig*0.6);
	};*/
	/*sig = ((1-mix)*drysig) + (mix*wetsig);*/
	sig = FreeVerb.ar(sig, 0.2, 0.7, 0.4);
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


// a custom envelope
~winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
~window = Buffer.sendCollection(s, ~winenv.discretize, 1);

SynthDef(\field_grain, { |out=0, gate = 1, amp = 1,pos=0,sndbuf, envbuf, trate=100 dur=0.25|
    var sig, pan, env, freqdev;

    env = EnvGen.kr(
        Env([0, 1, 0], [1, 1], \sin, 1),
        gate,
        levelScale: amp,
        doneAction: Done.freeSelf);


    Out.ar(out,
        GrainBuf.ar(2, Impulse.kr(trate), dur, sndbuf, 1,
			pos, 2, FSinOsc.kr(LFNoise0.kr(3.2).range(0.1,60.0)).range(-0.1,0.1), envbuf) * env)
}).store;


~nyquist = s.sampleRate * 0.5;

~modRange = [0.001, 9, \exp, 0.001].asSpec;
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

~kick_files = ("/media/numina/T7_numina/Samples/kicks/*.wav").pathMatch;
~kicks = ~kick_files.collect({|i| Buffer.read(s, i); });

~hat_files = "/media/numina/T7_numina/Samples/HiHat/*.wav".pathMatch;
~hats = ~hat_files.collect({|i| Buffer.read(s, i); });

~cymbal_files = "/media/numina/T7_numina/Samples/Cymbal/*.wav".pathMatch;
~cymbals = ~cymbal_files.collect({|i| Buffer.read(s, i); });

~combo_files = "/media/numina/T7_numina/Samples/Combo/*.wav".pathMatch;
~combo = ~combo_files.collect({|i| Buffer.read(s, i); });

~mallet_files = "/media/numina/T7_numina/Samples/Mallet_Drum/*.wav".pathMatch;
~mallets = ~mallet_files.collect({|i| Buffer.read(s, i); });

~hand_files = "/media/numina/T7_numina/Samples/Hand_Drum/*.wav".pathMatch;
~hand_drums = ~hand_files.collect({|i| Buffer.read(s, i); });

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
			Synth(\field_grain, [\gate,1,\bufnum,~grainfield_recs[~fieldrecnum], \envbuf, ~window], ~fieldrecGroup);
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



	~fr_trateRange = [1, 500, \exp,1].asSpec;
	~fr_durRange = [2.0, 0.001, \linear,0.001].asSpec;
	~fr_posRange = [0.0, 0.95, \linear,0.001].asSpec;

/* eerste joystick */
HIDdef.usage( \x_ax_1, { |value|
	if ( ~freezeSwitch == 0, {
		~fmGroup.set(\mod1, ~modRange.map(value));
			~fieldrecGroup.set(\trate, ~fr_trateRange.map(value));
	});

	}, \X );
HIDdef.usage( \y_ax_1, { |value|
	if ( ~freezeSwitch == 0, {
		~fmGroup.set(\mod2, ~modRange.map(value));
		~fieldrecGroup.set(\dur, ~fr_durRange.map(value));
	});
	}, \Joystick );
HIDdef.usage( \joy_but_1, { |value|  value.postln; }, \b11 );

/* tweede joystick */
HIDdef.usage( \x_ax_2, { |value|
	if ( ~freezeSwitch == 0, {
		~fmGroup.set(\mod3, ~modRange.map(value));
		~fieldrecGroup.set(\pos, ~fr_posRange.map(value));
	});
	}, \Y );
HIDdef.usage( \y_ax_2, { |value| if ( ~freezeSwitch == 0, {
	~fmGroup.set(\mod4, ~modRange.map(value));
});
}, \Z );

HIDdef.usage( \joy_but_2, { |value|  value.postln; }, \b12 );



);






Ndef(\sjoerd_in, {
	var sig = SoundIn.ar(0);

	sig = HPF.ar(sig, 35);
	//sig = MidEQ.ar(sig,230,0.6,-8);
	//sig = MidEQ.ar(sig,2000,0.6,5);


	sig = sig!2;

}).play;






};




