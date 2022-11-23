/*
work on percussion sounds
*/
/*
frequentie op web sdr: 7074.72
14075.00

THIS ONE WORKS NOW:
13659.72



chinese radioL
13600.15
turkish radio:
13633.86
*/
(

fork{
Require("~/repositories/rationalworld/Cologne_tonalities_v2.scd");
2.0.wait;
	"./pulsejack".unixCmd;
/*	"jack_connect SuperCollider:out_1 system:playback_1".unixCmd;
	"jack_connect SuperCollider:out_2 system:playback_2".unixCmd;*/


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
~insects = Group.tail(~synthGroup);

~recGroup = Group.after(~synthGroup);
~effectGroup = Group.after(~synthGroup);
~effectGroup2 = Group.after(~effectGroup);

~transformChain1 = Group.after(~percGroup);
~transformChain2 = Group.after(~percGroup);
~transformChain3 = Group.after(~percGroup);
~transformChain4 = Group.after(~percGroup);
~transBuses = Array.fill(4, { Bus.audio(s, 1); });



/* transform synth*/
/*
~trans1 = Synth(\transform1, [\in, ~transBuses[0]], ~transformChain1);
~trans2 = Synth(\transform2, [\in, ~transBuses[1]], ~transformChain2);
~trans3 = Synth(\transform3, [\in, ~transBuses[2]], ~transformChain3);
~trans4 = Synth(\transform4, [\in, ~transBuses[3]], ~transformChain4);
*/

~synthChooser = 1;

~notes = Array.fill(16, { nil!128 });
~noteGroups = Array.fill(16, { Group.new(~synthGroup); });


/*BUSES*/
~anaBus = 8;
~tenvolBus = Bus.audio(s, 2);


~combBus = Bus.audio(s, 1);
~combBus2 = Bus.audio(s, 1);
/*for toy piano */
~toycombBus = Bus.audio(s, 1);
/* for tape grin */
~tapecombBus = Bus.audio(s, 1);

~percBus = Bus.audio(s, 1);
~percGrainBus = Bus.audio(s, 1);

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

// a custom envelope
~winenv = Env([0, 1, 0], [3, 1], [8, -8]);
~wenv = Buffer.sendCollection(s, ~winenv.discretize, 1);

~combPerc = Synth(\perc_effect, [\in, ~percBus], ~percGroup, \addAfter);
~grainPerc = Synth(\grain_perc, [\in, ~percGrainBus, \envbuf, ~wenv], ~percGroup, \addAfter);



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
	/*fading web sdr */
	{ num == 40 } { if ( val == 127, {

Ndef(\sdr).fadeTime = 32;

Ndef(\sdr, {

	var sig = SoundIn.ar([4,5],0.2);

	sig = sig;


}).play;
	}, {
		Ndef(\sdr).free;

	}); }
	// comb delay on percussion //
	{ num == 1 } { ~combPerc.set(\mix, val/127); }
	{ num == 57 } { ~combPerc.set(\decay, ~decRange.map(val/127);  ); };

});





	~fcricket_trigBus = Bus.control(s, 1).set(58.82);
	~cicada_trigBus = Bus.control(s, 1).set(0.2);

	~percReleaseBus = Bus.control(s, 1).set(0.001);


	~phasemIndexBus = Bus.control(s, 1).set(0);
	~phaseModFreq = Bus.control(s, 1).set(8);

	~phasemIndexSpec = [0.01, 1000.0, \linear, 0.01].asSpec;
	~freqRange = [100, 800, \linear, 10].asSpec;
	~releaseRange = [0.1,1.0, 5, 0.001].asSpec;
	~relmulSpec = [1.0, 10.0, \exp, 0.001].asSpec;

	~fcrickets_trigSpec = [58.82, 400.0, \linear, 0.01].asSpec;
	~cicada_trigSpec = [0.001, 80.0, \linear, 0.01].asSpec;

	~relMul = 1;








MIDIdef.cc(\secondController, {|val, num, cc, chan|
		[val, num, cc, chan].postln;

		case
		{ num == 82 }
		{ ~phasemIndexBus.set(~phasemIndexSpec.map(val/127)); "setting phase index".postln; }
		{ num == 50 }
		{ ~relMul = ~relmulSpec.map(val/127); "increasing perc rel".postln; }
		{ num == 76 }
		{ if ( val == 127, { 	~fieldcricket = Synth(\fieldcricket, [\tfreqBus, ~fcricket_trigBus.index, \recout, ~anaBus], ~insects); }, { ~fieldcricket.set(\gate, 0); }); }
		{ num == 84 }
		{
			~fcricket_trigBus.set( ~fcrickets_trigSpec.map(val/127));
		}
		{ num == 77 }
		{ if ( val == 127, { 	~cicada_3calls = Synth(\cicada_3calls, [\tfreqBus, ~cicada_trigBus.index, \recout, ~anaBus], ~insects); }, { ~cicada_3calls.set(\gate, 0); }); }
		{ num == 85 }
		{
			~cicada_trigBus.set( ~cicada_trigSpec.map(val/127));
		}

		}, chan: 0);



/* nanoPad */

MIDIdef.new(\nanoPad, {|val num chan dev|
	var output;
	[val, num, chan, dev].postln;

	case
		{ val < 63.5 } { output = ~percBus; "perc".postln; }
	{ val >= 63.5 } { output = ~percGrainBus; "grain".postln; };


	case
	{ num == 36 } { Synth(\perc, [\out, output, \freq, ~freqRange.map(val/127), \phasemIndexBus, ~phasemIndexBus.index, \amp,~ampRange.map(val/127),\release,~releaseRange.map(val/127) * ~relMul , \recout, ~anaBus], ~percGroup);
	}
	{ num == 37 } { Synth(\perc, [\out, output, \freq, ~freqRange.map(val/127), \phasemIndexBus, ~phasemIndexBus.index, \amp,~ampRange.map(val/127),\release,~releaseRange.map(val/127) * ~relMul , \recout, ~anaBus], ~percGroup);
	}
	{ num == 38 } { Synth(\perc, [\out, output, \freq, ~freqRange.map(val/127), \phasemIndexBus, ~phasemIndexBus.index, \amp,~ampRange.map(val/127),\release,~releaseRange.map(val/127) * ~relMul , \recout, ~anaBus ], ~percGroup);
	}
	{ num == 39 } { Synth(\perc, [\out, output,\freq, ~freqRange.map(val/127), \phasemIndexBus, ~phasemIndexBus.index, \amp,~ampRange.map(val/127),\release,~releaseRange.map(val/127) * ~relMul , \recout, ~anaBus ], ~percGroup);
	}
	{ num == 40 } { Synth(\perc, [\out, output, \freq, ~freqRange.map(val/127), \phasemIndexBus, ~phasemIndexBus.index, \amp,~ampRange.map(val/127),\release,~releaseRange.map(val/127) * ~relMul , \recout, ~anaBus ], ~percGroup);
	}
	{ num == 41 } { Synth(\perc, [\out, output, \freq, ~freqRange.map(val/127), \phasemIndexBus, ~phasemIndexBus.index, \amp,~ampRange.map(val/127),\release,~releaseRange.map(val/127) * ~relMul , \recout, ~anaBus ], ~percGroup);
	}
	{ num == 42 } { Synth(\perc, [\out, output, \freq, ~freqRange.map(val/127), \phasemIndexBus, ~phasemIndexBus.index,\amp,~ampRange.map(val/127),\release,~releaseRange.map(val/127)  * ~relMul, \recout, ~anaBus ], ~percGroup);
	}
	{ num == 43 } { Synth(\perc, [\out, output, \freq, ~freqRange.map(val/127), \phasemIndexBus, ~phasemIndexBus.index, \amp,~ampRange.map(val/127),\release,~releaseRange.map(val/127)  * ~relMul, \recout, ~anaBus ], ~percGroup);
	}
	{ num == 44 } { Synth(\perc, [\out, output, \freq, ~freqRange.map(val/127), \phasemIndexBus, ~phasemIndexBus.index, \amp,~ampRange.map(val/127),\release,~releaseRange.map(val/127) * ~relMul , \recout, ~anaBus ], ~percGroup);
	}
	{ num == 45 } { Synth(\perc, [\out, output, \freq, ~freqRange.map(val/127),\phasemIndexBus, ~phasemIndexBus.index, \amp,~ampRange.map(val/127),\release,~releaseRange.map(val/127) * ~relMul, \recout, ~anaBus  ], ~percGroup);
	}
	{ num == 46 } { Synth(\perc, [\out, output, \freq, ~freqRange.map(val/127),\phasemIndexBus, ~phasemIndexBus.index,\amp,~ampRange.map(val/127),\release,~releaseRange.map(val/127)  * ~relMul, \recout, ~anaBus ], ~percGroup);
	}
	{ num == 47 } { Synth(\perc, [\out, output, \freq, ~freqRange.map(val/127),\phasemIndexBus, ~phasemIndexBus.index, \amp,~ampRange.map(val/127),\release,~releaseRange.map(val/127) * ~relMul, \recout, ~anaBus  ], ~percGroup);
	}
	{ num == 48 } { Synth(\perc, [\out, output, \freq, ~freqRange.map(val/127),\phasemIndexBus, ~phasemIndexBus.index, \amp,~ampRange.map(val/127),\release,~releaseRange.map(val/127) * ~relMul, \recout, ~anaBus  ], ~percGroup);
	}
	{ num == 49 } { Synth(\perc, [\out, output, \freq, ~freqRange.map(val/127), \phasemIndexBus, ~phasemIndexBus.index, \amp,~ampRange.map(val/127),\release,~releaseRange.map(val/127) * ~relMul, \recout, ~anaBus  ], ~percGroup);
	}
	{ num == 50 } { Synth(\perc, [\out, output, \freq, ~freqRange.map(val/127), \phasemIndexBus, ~phasemIndexBus.index,\amp,~ampRange.map(val/127),\release,~releaseRange.map(val/127) * ~relMul, \recout, ~anaBus  ], ~percGroup);
	}
	{ num == 51 } { Synth(\perc, [\out, output, \freq, ~freqRange.map(val/127),\phasemIndexBus, ~phasemIndexBus.index,\amp,~ampRange.map(val/127),\release,~releaseRange.map(val/127) * ~relMul, \recout, ~anaBus  ], ~percGroup);
	};


	[num, val].postln}, nil, nil, \noteOn, nil);







};
)
