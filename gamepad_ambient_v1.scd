HID.findAvailable;
HID.postAvailable;

HID.closeAll

HID.openAt( 5 );
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


~ambientpath = "D:/Dropbox/PROJECTS/SC_performances/tenori-on/Ansage_Ende_01052021/AE_Samples/";

~ambientfiles = (~ambientpath++"*.wav").pathMatch;
//~ambients = ~ambientfiles.collect({|i| Buffer.read(s, i); });

~ambientsLeft = ~ambientfiles.collect({|i| Buffer.readChannel(s, i, channels: [0]); });
~ambientsRight = ~ambientfiles.collect({|i| Buffer.readChannel(s, i, channels: [1]); });

SynthDef(\ambient_sampler, {|out=0 amp=0.5 dur=0.2 trate=30 posrate=0.2 bufnumLeft bufnumRight gate=1|
	var env, sig1, sig2, posMod;
	env = EnvGen.ar(Env.adsr(0.1, 0.0, 0.5,3.0), gate, doneAction: 2);
	posMod = LFNoise0.kr(posrate).range(0.0,0.98);
	sig1 = GrainBuf.ar(2, Impulse.ar(trate), dur, bufnumLeft, BufRateScale.ir(bufnumLeft),posMod, pan: SinOsc.kr(LFNoise2.kr(0.4).range(0.01,32.0)).range(0.0,-0.5) );
	sig2 = GrainBuf.ar(2, Impulse.ar(trate), dur, bufnumRight, BufRateScale.ir(bufnumRight),posMod,
		pan: SinOsc.kr(LFNoise1.kr(0.8).range(0.001,22.0)).range(0.0,0.5) );
	Out.ar(out, sig1*env*amp);
	Out.ar(out, sig2*env*amp);
}).store;

// a = Synth(\ambient_sampler, [\bufnumLeft, ~ambientsLeft[0], \bufnumRight, ~ambientsRight[0] ]);
// a.set(\dur, 2.0);
// a.set(\trate, 13.0);
// a.free


(
~ambientGroup = Group.new;
/*    LOGITECH DUAL ACTION MAPPING */
/* main buttons */
~ambientSwitch = 0;
~freezeSwitch = 0;

~durSpec = [0.001, 3.0, \linear, 0.001].asSpec;
~trateSpec = [0.1, 60.0, \linear, 0.001].asSpec;
~posSpec = [0.0,0.99, \linear, 0.001].asSpec;


HIDdef.usage( \button_1, { |value|

	if ( value == 0, {
	if ( ~ambientSwitch != 4, { ~ambientSwitch = ~ambientSwitch + 1;
			~ambientGroup.set(\bufnumLeft, ~ambientsLeft[~ambientSwitch], \bufnumRight, ~ambientsRight[~ambientSwitch]);

		},
		{
			~ambientSwitch = 0;

	});
	("ambient sample : "++~ambientSwitch).postln;

	});

}, \b1 );


/* synth trigger */
HIDdef.usage( \main_but_1, { |value|
	if ( ~freezeSwitch == 0, {
		if ( value == 1, {



		Synth(\ambient_sampler, [\gate,1, \bufnumLeft, ~ambientsLeft[~ambientSwitch], \bufnumRight, ~ambientsRight[~ambientSwitch] ], ~ambientGroup);



		}, { ~ambientGroup.set(\gate, 0);  });

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

	});
	 }, \b7 );


HIDdef.usage( \main_but_4, { |value|
	if ( value == 1, {

		  });

	}, \b8 );


/* eerste joystick */
HIDdef.usage( \x_ax_1, { |value|
	if ( ~freezeSwitch == 0, {
		~ambientGroup.set(\pos, ~posSpec.map(value));
	});

	}, \X );
HIDdef.usage( \y_ax_1, { |value|
	if ( ~freezeSwitch == 0, {
		~ambientGroup.set(\dur, ~durSpec.map(value));
	});
	}, \Joystick );
HIDdef.usage( \joy_but_1, { |value|  value.postln; }, \b11 );

/* tweede joystick */
HIDdef.usage( \x_ax_2, { |value|
	if ( ~freezeSwitch == 0, {
		~ambientGroup.set(\trate, ~trateSpec.map(value));
	});
	}, \Y );
HIDdef.usage( \y_ax_2, { |value| if ( ~freezeSwitch == 0, {
	~ambientGroup.set(\mod4, ~modRange.map(value));
});
}, \Z );

HIDdef.usage( \joy_but_2, { |value|  value.postln; }, \b12 );

)





)

