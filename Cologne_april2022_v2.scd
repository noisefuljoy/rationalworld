/*
work on percussion sounds


*/




/*
frequentie op web sdr: 7074.72
14075.00
chinese radioL 13809.97
*/


(
fork{
Require("~/repositories/rationalworld/Cologne_tonalities_v2.scd");
2.0.wait;

MIDIClient.init;
MIDIIn.connectAll;
	// 5.0.wait;
	//
	// Require("D:/Dropbox/PROJECTS/SC_performances/tenori-on/Ansage_Ende_01052021/animals_grainpatch_v5.scd");

4.0.wait;
//stereo
~channels = Array.fill(16,{ 0});
	//multichannel (to mixer)
//~channels = [0,2,4,6,7,8,9];

~synthGroup = Group.new;
~percGroup = Group.tail(~synthGroup);
~recGroup = Group.after(~synthGroup);
~effectGroup = Group.after(~synthGroup);
~effectGroup2 = Group.after(~effectGroup);7074.72

~synthChooser = 1;

~notes = Array.fill(16, { nil!128 });
~noteGroups = Array.fill(16, { Group.new(~synthGroup); });


/*BUSES*/
~anaBus = Bus.audio(s, 1);
~tenvolBus = Bus.audio(s, 2);


~combBus = Bus.audio(s, 1);
~combBus2 = Bus.audio(s, 1);
/*for toy piano */
~toycombBus = Bus.audio(s, 1);
/* for tape grin */
~tapecombBus = Bus.audio(s, 1);

~percBus = Bus.audio(s, 1);


~dronesideBus = Bus.audio(s, 1);
~droneverbBus = Bus.audio(s, 2);
~toypianoverbBus = Bus.audio(s, 1);
~voiceverbBus = Bus.audio(s, 1);
~slenverbBus = Bus.audio(s, 1);
~sineverbBus = Bus.audio(s, 1);
~sawverbBus = Bus.audio(s, 1);
~pulseBus = Bus.audio(s, 2);
~crushBus = Bus.audio(s, 1);

/*control buses */
~maingrainDurBus = Bus.control(s, 1).set(0.5);
~fmodBus = Bus.control(s, 1).set(0.01);
~widthBus = Bus.control(s, 1).set(0.5);
~phasemodBus = Bus.control(s,1).set(0.1);
~bpmodBus = Bus.control(s,1).set(0.1);
~fmfreqBus = Bus.control(s, 1).set(10);
~fmindexBus = Bus.control(s, 1).set(0.01);
~fmfreqBus2 = Bus.control(s, 1).set(10);
~fmindexBus2 = Bus.control(s, 1).set(0.01);

~ampVBus = Bus.control(s, 1).set(0); //bus for switching amplitude variation
~srBus = Bus.control(s, 1).set(48000);
~pitchBus = Bus.control(s, 1);

//~combC.free
//~crusher.free;
/* EFFECT SYNTHS */

~combPerc = Synth(\perc_effect, [\in, ~percBus], ~percGroup, \addAfter);

~combC = Synth(\tenoricomb, [\in, ~combBus,\mix,0.2,\out,~channels[3] ], ~effectGroup);


/*	~tapecombC.set(\mix, 0.5);
	~toycombC.set(\mix, 0.5);*/
~toycombC = Synth(\toycomb, [\in, ~toycombBus,\mix,0.5,\out,~channels[4] ], ~effectGroup);

~tapecombC = Synth(\tapecomb, [\in, ~tapecombBus,\mix,0.5,\out,~channels[5] ], ~effectGroup);



~crusher = Synth(\ten_crusher, [\in, ~crushBus,\mix,0.8,\out, ~channels[4] ], ~effectGroup);
~percsynth1 = Synth(\ten_perc_effect, [\in, ~perc1Bus, \out,~channels[5]],~effectGroup);
~percsynth2 = Synth(\ten_perc_effect, [\in, ~perc2Bus, \out,~channels[6]],~effectGroup);
~pulseVerb = Synth(\ten_droneverb, [\in, ~pulseBus,\mix,0.05,\out, ~channels[2]], ~effectGroup);
~slenVerb = Synth(\ten_monoverb, [\in, ~slenverbBus,\mix,0.25,\out, ~channels[4] ], ~effectGroup2);
~sineVerb = Synth(\ten_monoverb, [\in, ~sineverbBus,\mix,0.25,\out, ~channels[5] ], ~effectGroup2);
~sawVerb = Synth(\ten_monoverb, [\in, ~sawverbBus,\mix,0.25,\out, ~channels[6] ], ~effectGroup2);
~droneChain = Synth(\ten_sidechainer, [\in, ~dronesideBus,\side,~scBus,\out,~droneverbBus],~effectGroup1);
~droneVerb = Synth(\ten_droneverb, [\in, ~droneverbBus,\mix,0.9, ~channels[1]], ~effectGroup2);
	~droneVerb.set(\mix, 0.35);
~toyVerb = Synth(\ten_monoverb, [\in, ~toypianoverbBus,\mix,0.25,\out, ~channels[4]], ~effectGroup2);
	//~toyVerb.set(\mix,0.0);
~voiceVerb = Synth(\ten_monoverb, [\in, ~voiceverbBus,\mix,0.85,\out, ~channels[6]], ~effectGroup2);
/*MASTER VOLUME*/
~tenoriVolume = Synth(\ten_volume, [\in, ~tenvolBus,\volume,1], ~effectGroup2, \addAfter);

//SAMPLES
//~samplePath = "D:/Samples".asString;
~samplePath = "/media/numina/DATAPANIC/Dropbox/Samples".asString;

~voicefiles = (~samplePath++"/saar/1.C/*.wav").pathMatch;
~voice = ~voicefiles.collect({|i| Buffer.read(s, i); });
~voiceFreqArray = Array.fill(8, { 261.63 });

~analogfiles = (~samplePath++"/tenorion/analogkit/*.wav").pathMatch;
~analog = ~analogfiles.collect({|i| Buffer.read(s, i); });

~snarefiles = (~samplePath++"/tenorion/snaredrums/*.WAV").pathMatch;
~snares = ~snarefiles.collect({|i| Buffer.read(s, i); });

~kickfiles = (~samplePath++"/tenorion/kicks/*.aif").pathMatch;
~kicks = ~kickfiles.collect({|i| Buffer.read(s, i); });

~cymbalFiles = (~samplePath++"/tenorion/cymbals/*.WAV").pathMatch;
~cymbals = ~cymbalFiles.collect({|i| Buffer.read(s, i); });

~perc_files = (Platform.resourceDir +/+ "sounds/Percussion/*.aif").pathMatch;
~percSamples1 = ~perc_files.collect({|i| Buffer.read(s, i); });

~harpsifiles = (~samplePath++"/tenorion/*.wav").pathMatch;
~harpsi = ~harpsifiles.collect({|i| Buffer.read(s, i); });

~lutefiles = (~samplePath++"/tenorion/lute/*.wav").pathMatch;
~lute = ~lutefiles.collect({|i| Buffer.read(s, i); });


~droneFiles = (~samplePath++"/tenorion/drones/*.aif").pathMatch;
~drones = ~droneFiles.collect({|i| Buffer.read(s, i); });
~dronePitchBuses = Array.fill(~drones.size, { Bus.control(s, 1); });
~droneFreqArray = Array.fill(~drones.size, { 0 });


fork{
~drones.size.do{|i|
	Synth(\pitchFinder, [\bufnum,~drones[i],\outBus, ~dronePitchBuses[i],\dur,1]);  };
1.0.wait;
~drones.size.do{|i|
		~dronePitchBuses[i].get({|item| ~droneFreqArray.put(i, item); }); };  };

/* AMBIENT FILES */
~ambientpath = "/media/numina/DATAPANIC/Dropbox/PROJECTS/SC_performances/tenori-on/Ansage_Ende_01052021/AE_Samples/";

~ambientfiles = (~ambientpath++"*.wav").pathMatch;
//~ambients = ~ambientfiles.collect({|i| Buffer.read(s, i); });

~ambientsLeft = ~ambientfiles.collect({|i| Buffer.readChannel(s, i, channels: [0]); });
~ambientsRight = ~ambientfiles.collect({|i| Buffer.readChannel(s, i, channels: [1]); });

~ambientsLeftPitchBuses = Array.fill(~ambientsLeft.size, { Bus.control(s, 1); });
~ambientsLeftFreqArray = Array.fill(~ambientsLeft.size, { 0 });

fork{
~ambientsLeft.size.do{|i|
	Synth(\pitchFinder, [\bufnum,~ambientsLeft[i],\outBus, ~ambientsLeftPitchBuses[i],\dur,1]);  };
1.0.wait;
~ambientsLeft.size.do{|i|
		~ambientsLeftPitchBuses[i].get({|item| ~ambientsLeftFreqArray.put(i, item); }); };  };

~ambientsRightPitchBuses = Array.fill(~ambientsRight.size, { Bus.control(s, 1); });
~ambientsRightFreqArray = Array.fill(~ambientsRight.size, { 0 });

fork{
~ambientsRight.size.do{|i|
	Synth(\pitchFinder, [\bufnum,~ambientsRight[i],\outBus, ~ambientsRightPitchBuses[i],\dur,1]);  };

1.0.wait;
~ambientsRight.size.do{|i|
		~ambientsRightPitchBuses[i].get({|item| ~ambientsRightFreqArray.put(i, item); }); };  };

~malmPath = "/media/numina/DATAPANIC/Dropbox/PROJECTS/SC_performances/tenori-on/Ansage_Ende_01052021/Malm_samples/";
~malmfiles = (~malmPath++"*.wav").pathMatch;
~malm = ~malmfiles.collect({|i| Buffer.read(s, i); });


~malmPitchBuses = Array.fill(~malm.size, { Bus.control(s, 1); });
~malmFreqArray = Array.fill(~malm.size, { 0 });

fork{
~malm.size.do{|i|
	Synth(\pitchFinder, [\bufnum,~malm[i],\outBus, ~malmPitchBuses[i],\dur,5]);  };

5.0.wait;
~ambientsRight.size.do{|i|
		~malmPitchBuses[i].get({|item| ~malmFreqArray.put(i, item); }); };  };


~toneFiles = (~samplePath++"/tenorion/strangetones/*.wav").pathMatch;
~strangeTones = ~toneFiles.collect({|i| Buffer.read(s, i); });

~microFiles = (~samplePath++"/tenorion/microsounds/*.aiff").pathMatch;
~microsounds = ~microFiles.collect({|i| Buffer.read(s, i); });

~slenFiles = (~samplePath++"/micromoog/*.wav").pathMatch;
~slentem = ~slenFiles.collect({|i| Buffer.read(s, i); });
~slentemPitchBuses = Array.fill(~slentem.size, { Bus.control(s, 1); });
~slentemFreqArray = Array.fill(~slentem.size, { 0 });

//freq finder function
fork{
~slentem.size.do{|i|
	Synth(\pitchFinder, [\bufnum,~slentem[i],\outBus, ~slentemPitchBuses[i],\dur,1]);
 };
2.0.wait;
~slentem.size.do{|i|
		~slentemPitchBuses[i].get({|item| ~slentemFreqArray.put(i, item); }); };
};

/* BUFFERS for recording */
~recBufs = [Buffer.alloc(s, s.sampleRate*2,1), Buffer.alloc(s, s.sampleRate*2,1)];
~recBufs2 = [Buffer.alloc(s, s.sampleRate*2,1), Buffer.alloc(s, s.sampleRate*2,1)];
~recBufs3 = [Buffer.alloc(s, s.sampleRate*2,1), Buffer.alloc(s, s.sampleRate*2,1)];
~playBuf = ~recBufs[0];

~fftBuf = Buffer.alloc(s, 1024, 1);
~fftBuf2 = Buffer.alloc(s, 1024, 1);
~fftBuf3 = Buffer.alloc(s, 1024, 1);

~recFreqBus = [Bus.control(s, 1), Bus.control(s, 1)];
~recFreqBus2 = [Bus.control(s, 1), Bus.control(s, 1)];
~recFreqArr = Array.fill(2, { 0});
~grainFreqArray = Array.fill(2, {0 });

//windows for grains
~win1 = Buffer.sendCollection(s, Signal.hammingWindow(1024));
~win2 = Buffer.sendCollection(s, Signal.hanningWindow(1024));
~win3 = Buffer.sendCollection(s, Signal.welchWindow(1024));

3.0.wait;
~baseFreqs = [32.7, 65.41, 130.81, 261.63, 523.25];


~whatDrone = 0;
~whatSlen = 0;
~scaleNum = 0;

~typeScale = ~oton;
~typeScaleNum = 0;
~scale = ~typeScale[~scaleNum];
~scale = ~micro[0];
~index = 1;
~index2 = 0;
~index3 = 0;
~playBuf = ~recBufs[0];
~pelogChoose = 0;
~myscaleChoose = 0;
~myscaleChoose2 = 0;
~whatBuf = 0;
~whatMalm = 0;
~whatBallBuf = 0;
~sampleColState = 0;
~sampleCol = ~harpsi;
~sampleBallCol = ~harpsi;
//duration for drones
~dur = 2.0;
~grainAmp = 0.1;
~durSpec = [0.001, 2.0,\exp,0.001,2.0].asSpec;
~ampSpec = [0.004,0.05,\exp].asSpec;

~grainDurSpec = [2.0,0.01,\exp].asSpec;
~grainAmpSpec = [0.025,0.035,\exp].asSpec;
~maingrainDurSpec = [4.0,0.01,\exp].asSpec;
~droneMul = 0.5;
~droneMulChoose = 0;
~dronemularr = [0.5,1,0.25];

~ffreqSpec = [250,8000,\linear].asSpec;
~srateSpec = [250,32000,\exp].asSpec;

~widthSpec = [0.01,0.99,\exp].asSpec;
~fmodSpec = [0.001,300.0,\exp].asSpec;
~phasemodSpec = [0.01,80.0,\exp].asSpec;
~bpmodSpec = [0.01,500.0, \linear].asSpec;
~fmfreqSpec = [1.0,100,\linear].asSpec;
~fmindexSpec = [0.0,1,\linear].asSpec;

~modRange = [0.001, 9, \exp, 0.001].asSpec;
~ampRange = [0.25, 1.0, \linear, 0.001].asSpec;
~relRange = [0.1, 2.0, \linear, 0.001].asSpec;
~decRange = [0.001, 30.0, \exp, 0.001].asSpec;
~ratioSpec = [0, 15, \linear, 1].asSpec;


2.0.wait;
~defChoose = 0;


Require("~/repositories/rationalworld/Cologne_grainpatch_april2022.scd");

4.0.wait;
Require("~/repositories/rationalworld/Cologne_gamepad_v1.scd");
2.0.wait;


MIDIdef.cc(\white_control, {|val, num, cc, chan|
	[val, num,cc, chan].postln;
	case
	{ num == 40 } { if ( val == 127, {

Ndef(\sdr).fadeTime = 32;

Ndef(\sdr, {

	var sig = SoundIn.ar([4,5]);

	sig = sig;


}).play;
	}, {
		Ndef(\sdr).free;

	}); }
	// comb delay on percussion //
	{ num == 1 } { ~combPerc.set(\mix, val/127); }
	{ num == 57 } { ~combPerc.set(\decay, ~decRange.map(val/127);  ); };

});



/*
MIDIdef.cc(\firstController, {|val, num, cc, chan|
		[val, num, cc, chan].postln;
		if ( num == 86,  { ~percsynth1.set(\srate,~srateSpec.map(val/127) ); });
		if ( num == 87,  { ~percsynth2.set(\srate,~srateSpec.map(val/127) ); });
		if ( num == 78,  { ~percsynth1.set(\ffreq,~ffreqSpec.map(val/127) ); });
		if ( num == 79,  { ~percsynth2.set(\ffreq,~ffreqSpec.map(val/127) ); });

		/* SET TUNING */
		if ( num == 39, {
			if ( ~myscaleChoose2 != 2, {
				~myscaleChoose2 = ~myscaleChoose2 + 1 }, { ~myscaleChoose2 = 0; });
			case
			{ ~myscaleChoose2 == 0 } { "chinese".postln; ~scale = ~chinese[0]; }
			{ ~myscaleChoose2 == 1 } { "pseudoquarter".postln;~scale = ~quarter[0]; }
			{ ~myscaleChoose2 == 2 } { "thirtyseven".postln;~scale = ~thirtyseven[0]; }; });

		if ( num == 42, {
		if ( ~scaleNum != 5, { ~scaleNum = ~scaleNum + 1;  }, { ~scaleNum = 0; });
		~scale = ~typeScale[~scaleNum]; ~scaleNum.postln; });
		if ( num == 43, {
		if ( ~scaleNum != 0, { ~scaleNum = ~scaleNum - 1;  }, { ~scaleNum = 5; });
		~scale = ~typeScale[~scaleNum]; ~scaleNum.postln; });
	//select scale type
		if ( num == 44, { if ( ~typeScaleNum != 1, { ~typeScaleNum = ~typeScaleNum + 1; },
		{ ~typeScaleNum = 0; });
		case
		{ ~typeScaleNum == 0 }  { ~typeScale = ~oton }
		{ ~typeScaleNum == 1 }  { ~typeScale = ~uton };
		~scale = ~typeScale[~scaleNum]; ~typeScaleNum.postln; });

		if ( num == 40, {
			if ( ~myscaleChoose != 9, {
				~myscaleChoose = ~myscaleChoose + 1 }, { ~myscaleChoose = 0; });
			"microtonal".postln; ~scale = ~micro[~myscaleChoose]; });
		if ( num == 41, { "pelog".postln;
			if ( ~pelogChoose != 2, { ~pelogChoose = ~pelogChoose + 1; } , { ~pelogChoose = 0 });
			~scale = ~pelog[~pelogChoose]; });
		~pelogChoose.postln;
	//select scale number

		if ( num == 74, {
			if ( ~whatBuf != (~ambientsLeft.size - 1), {
				~whatBuf = ~whatBuf + 1;
		}, { ~whatBuf = 0;   });
		});

		if ( num == 75, { "malm sample".postln;
			if ( ~whatMalm != (~malm.size - 1), {
				~whatMalm = ~whatMalm + 1;
		}, { ~whatMalm = 0;   });
		});

		/* set main grain duration */
		if ( num == 50, {
			~maingrainDurBus.set( ~maingrainDurSpec.map(val/127));
		});

		if ( num == 84, {
			~toycombC.set(\mix, val/127);

		});


		if ( num == 85, {
			~tapecombC.set(\mix, val/127);
		});


	//record toy piano
		case
		{ num == 68 }
		{ if ( val == 127, { "record toy piano. input 0".postln;
			fork{
				if ( ~index == 0, {
					~rec1 = Synth(\tenori_recorder,[\in,0,\fftbuf, ~fftBuf,\recbuf, ~recBufs[1] ], ~recGroup);
				}, {
					~rec1 = Synth(\tenori_recorder,[\in,0,\fftbuf, ~fftBuf,\recbuf, ~recBufs[0] ], ~recGroup);
				});


				if ( ~index == 0, { ~index=1;}, { ~index=0; });
			};
			},{ ~rec1.free; });
		}
		//record tape
		{ num == 69 }
		{
			if ( val == 127, { "record tape. input 2".postln;
			fork{
				if ( ~index2 == 0, {
					~rec2 = Synth(\tenori_recorder,[\in,2,\fftbuf, ~fftBuf2,\recbuf, ~recBufs2[1] ], ~recGroup);
				}, {
					~rec2 = Synth(\tenori_recorder,[\in,2,\fftbuf, ~fftBuf2,\recbuf, ~recBufs2[0] ], ~recGroup);
				});


				if ( ~index2 == 0, { ~index2 =1;}, { ~index2 =0; });
			};
			},
			{
			~rec2.free;
			}
			);
	}
	//record voice
	{ num == 70 }
	{
			if ( val == 127, { "record recorder. input 1".postln;
			fork{
				if ( ~index3 == 0, {
					~rec3 = Synth(\tenori_recorder,[\in,1,\fftbuf, ~fftBuf3,\recbuf, ~recBufs3[1] ], ~recGroup);
				}, {
					~rec3 = Synth(\tenori_recorder,[\in,1,\fftbuf, ~fftBuf3,\recbuf, ~recBufs3[0] ], ~recGroup);
				});


				if ( ~index3 == 0, { ~index3 =1;}, { ~index3 =0; });
			};
			},
			{
			~rec3.free;
			}
			);
	};
	if ( num == 82, { ~combC.set(\mix, val/127); });
	if ( num == 83, { ~crusher.set(\mix, val/127); });
	if ( num == 59, {
			if ( ~whatSlen != (~slentem.size - 1), { ~whatSlen = ~whatSlen + 1; }, { ~whatSlen = 0; });
		~whatSlen.postln; });
	if ( num == 65, {
			if ( ~whatDrone != (~drones.size - 1), { ~whatDrone = ~whatDrone + 1; }, { ~whatDrone = 0; });
		~whatDrone.postln; });
		if ( num == 89, { ~dur = ~durSpec.map(val/127); ~grainAmp = ~ampSpec.map(val/127); });
		if ( num == 57, {
			if ( ~droneMulChoose != 2, { ~droneMulChoose = ~droneMulChoose + 1; },
				{ ~droneMulChoose = 0; });
			~droneMul = ~dronemularr[~droneMulChoose];    });
	//synth manipulation
	if ( num == 32, {
			~widthBus.set(~widthSpec.map(val/127));
		});

	if ( num == 0, {
	~sideChainer.set(\volume, ~drumGainSpec.map(val/127));
			//~fmodBus.set(~fmodSpec.map(val/127));
		});

	if ( num == 33, {
			~phasemodBus.set(~phasemodSpec.map(val/127));
		});
	if ( num == 1, {
	~tenoriVolume.set(\volume, ~drumGainSpec.map(val/127));


			//~bpmodBus.set(~bpmodSpec.map(val/127));
		});

	if ( num == 34, {
			~fmfreqBus.set(~fmfreqSpec.map(val/127));
		});
	if ( num == 2, {
			~fmindexBus.set(~fmindexSpec.map(val/127));
		});
		if ( num == 35, {
			~fmfreqBus2.set(~fmfreqSpec.map(val/127));
		});
	if ( num == 3, {
			~fmindexBus2.set(~fmindexSpec.map(val/127));
		});

	}, chan: 0);
*/


/* nanoPad */

MIDIdef.new(\nanoPad, {|val num chan dev|
	[val, num, chan, dev].postln;
	case
	{ num == 36 } { Synth(\perc, [\out, ~percBus, \bufnum, ~percSamples1.choose, \amp,~ampRange.map(val/127) ], ~percGroup);
			}
	{ num == 37 } { Synth(\perc, [\out, ~percBus, \bufnum, ~percSamples1.choose, \amp,~ampRange.map(val/127) ], ~percGroup);
	}
	{ num == 38 } { Synth(\perc, [\out, ~percBus, \bufnum, ~percSamples1.choose, \amp,~ampRange.map(val/127) ], ~percGroup);
	}
	{ num == 39 } { Synth(\perc, [\out, ~percBus, \bufnum, ~percSamples1.choose, \amp,~ampRange.map(val/127) ], ~percGroup);
	}
	{ num == 40 } { Synth(\perc, [\out, ~percBus, \bufnum, ~percSamples1.choose, \amp,~ampRange.map(val/127) ], ~percGroup);
	}
	{ num == 41 } { Synth(\perc, [\out, ~percBus, \bufnum, ~percSamples1.choose, \amp,~ampRange.map(val/127) ], ~percGroup);
	}
	{ num == 42 } { Synth(\perc, [\out, ~percBus, \bufnum, ~percSamples1.choose, \amp,~ampRange.map(val/127) ], ~percGroup);
	}
	{ num == 43 } { Synth(\perc, [\out, ~percBus, \bufnum, ~percSamples1.choose, \amp,~ampRange.map(val/127) ], ~percGroup);
	}
	{ num == 44 } { Synth(\perc, [\out, ~percBus, \bufnum, ~percSamples1.choose, \amp,~ampRange.map(val/127) ], ~percGroup);
	}
	{ num == 45 } { Synth(\perc, [\out, ~percBus, \bufnum, ~percSamples1.choose, \amp,~ampRange.map(val/127) ], ~percGroup);
	}
	{ num == 46 } { Synth(\perc, [\out, ~percBus, \bufnum, ~percSamples1.choose, \amp,~ampRange.map(val/127) ], ~percGroup);
	}
	{ num == 47 } { Synth(\perc, [\out, ~percBus, \bufnum, ~percSamples1.choose, \amp,~ampRange.map(val/127) ], ~percGroup);
	}
	{ num == 48 } { Synth(\perc, [\out, ~percBus, \bufnum, ~percSamples1.choose, \amp,~ampRange.map(val/127) ], ~percGroup);
	}
	{ num == 49 } { Synth(\perc, [\out, ~percBus, \bufnum, ~percSamples1.choose, \amp,~ampRange.map(val/127) ], ~percGroup);
	}
	{ num == 50 } { Synth(\perc, [\out, ~percBus, \bufnum, ~percSamples1.choose, \amp,~ampRange.map(val/127) ], ~percGroup);
	}
	{ num == 51 } { Synth(\perc, [\out, ~percBus, \bufnum, ~percSamples1.choose, \amp,~ampRange.map(val/127) ], ~percGroup);
	};


	[num, val].postln}, nil, nil, \noteOn, nil);





MIDIdef.noteOff(\noteoff, {|vel note chan srcid|
		//[vel, note, chan, srcid].postln;

		if ( chan > 10,
{
	if ( chan != 14, {
	if(~notes[chan][note].notNil, {
						~notes[chan][note].set(\gate, 0); ~notes[chan][note] = nil;
			});
				},
				{
					~notes[chan][note].stop; ~notes[chan][note] = nil;
				});
}, {
				if(~notes[chan][note].notNil, {

			if ( (chan == 7) or: (chan == 8) or: (chan == 9) or: (chan == 14), { ~notes[chan][note].stop; },
				{

		~notes[chan][note].set(\gate, 0);
			});
			//~notes[chan][note].do{|item| item.set(\gate, 0); };
			~notes[chan][note] = nil;
			});
		});
});
};
)

/*
MIDIdef.cc(\secondController, {|val, num, chan, cc| [val, num, chan, cc].postln; }, chan: 1);

MIDIdef.cc(\gerriController, {|val, num, chan, cc| [val, num, chan, cc].postln; }, chan: 2);


MIDIdef.noteOn(\nanoPad, {|vel note chan cc| [vel, note].postln; }, chan: 9);*/