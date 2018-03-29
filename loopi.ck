// chuck.alsa --adc0 --dac3 joy.ck 

// make HidIn and HidMsg
Hid hi;
HidMsg msg;

0 => int loopNum;

// which joystick
0 => int device;
// get from command line
if( me.args() ) me.arg(0) => Std.atoi => device;

// open joystick 0, exit on fail
if( !hi.openJoystick( device ) ) me.exit();

<<< "joystick '" + hi.name() + "' ready", "" >>>;

0.15 => float maxDeadZone;
-0.15 => float minDeadZone; 

SinOsc m => SinOsc c => dac;

 adc => PitShift pitch => Gain g => dac;

			// carrier frequency
			220 => int carFreq;
			// modulator frequency
			40 => int modFreq;
			// index of modulation
			200 => int modGain;

// ADC => PitShift pitch => Gain g => DAC;

//adc => dac;


// ADC => DAC;
//PitShift pitch; 
//Gain g;

1 => pitch.mix;
now => time startTime;
now => time stopTime;


now => time recStartTime;
now => time recStopTime;

WvOut w;

0 => int recording;

// infinite event loop
while( true )
{
    // wait on HidIn as event
    hi => now;
    //<<< m.freq >>>;
    // messages received
    while( hi.recv( msg ) )
    {
	msg.axisPosition * 200 => float axisMultiplied;
        // joystick axis motion
        if( msg.isAxisMotion() )
        {
            //<<< "Motion" >>>;
            Std.fabs(msg.axisPosition) => float absPos;
            if(absPos > maxDeadZone){
                <<< "joystick axis", msg.which, ":", msg.axisPosition >>>;
            }
            if(msg.which == 0 && Std.fabs(msg.axisPosition) > maxDeadZone){
                //modFreq * (axisMultiplied) => m.freq;
                modFreq * (1 + msg.axisPosition * 5) => m.freq;
                
            }else if(absPos < maxDeadZone && msg.which == 1){
                modFreq => m.freq;
            }
            if(msg.which == 1 && Std.fabs(msg.axisPosition) > maxDeadZone){
                carFreq * (1 + msg.axisPosition * 5) => c.freq;
            }else if(absPos < maxDeadZone && msg.which == 0){
                // carrier frequency
                carFreq => c.freq;

            }
            if(msg.which == 3 && Std.fabs(msg.axisPosition) > .2){
                msg.axisPosition * 1.5 => pitch.shift;
                // .5 => pitch.shift;
            }else if((absPos < .2) && (msg.which == 3)){
                1 => pitch.shift;
            }
            
		//}else{
			//0 => msg.axisPosition;
			//0 => m.freq;
			//1 => pitch.shift;
		//}
		
        }
        
        // joystick button down
        else if( msg.isButtonDown() )
        {
            <<< "joystick button", msg.which, "down" >>>;
		if(msg.which == 0){ // START FREQUENCY NOISE
			// actual FM using sinosc (sync is 0)
			// (note: this is not quite the classic "FM synthesis"; also see fm2.ck)
			
			// modulator to carrier
			
			
			// carrier frequency
			carFreq => c.freq;
			// modulator frequency
			modFreq => m.freq;
			// index of modulation
			modGain => m.gain;
			
			now => startTime;
			
		}
		
		if(msg.which == 1){
			spork ~ newLoop();

			
		}
		if(msg.which == 2){
			if(recording == 0){
				1 => recording;
				1 => w.record;
                
				now => recStartTime;
				// chuck this with other shreds to record to file
				// example> chuck foo.ck bar.ck rec (see also rec2.ck)
				
				// pull samples from the dac
				// WvOut2 -> stereo operation
				dac => w => blackhole;
				
				// set the prefix, which will prepended to the filename
				// do this if you want the file to appear automatically
				// in another directory.  if this isn't set, the file
				// should appear in the directory you run chuck from
				// with only the date and time.
				"chuck-session" => w.autoPrefix;
				
				// this is the output file name
				loopNum + ".wav" => w.wavFilename;
				
				// print it out
				
				
				// any gain you want for the output
				//.5 => g.gain;
				
				// temporary workaround to automatically close file on remove-shred
				// null @=> w;
				
				// infinite time loop...
				// ctrl-c will stop it, or modify to desired duration
				//while( recording == 1 ) 1::second => now;
			}else if(recording == 1){
				
				//now => recStopTime;
				//<<< "time started was: " , startTime >>>;
				//<<< "time stopped was: " , stopTime >>>;
				//stopTime - startTime => dur durationPressed;
				//<<< "Duration was: " , durationPressed >>>;
				//0 => recording;
                
                <<<"writing to file: ", w.filename()>>>;
                
				0 => w.record;
				w.closeFile();
				// null @=> w;
				0 => recording;
			}
						
		}
		if(msg.which == 3){

            spork ~ startLoop();
			
			
		}
		if(msg.which == 4){
				
		//Try to turn back time for loop?!
			now => time timeWas;
			// startTime => now;
			<<< "time started was: " , timeWas >>>;
			<<< "time now is: " , now >>>;
		}
		if(msg.which == 5){
//demonstrate using track=1 mode with LiSa
//
//when track == 1, the input is used to control playback position
//input [0,1] will control playback position within loop marks
//input values less than zero are multiplied by -1, so it is possible to use
//audio signals [-1, 1] to control playback position, as in waveshaping

//signal chain; record a sine wave, play it back
//SinOsc s => LiSa loopme => dac;
//adc => LiSa loopme => dac;
dac => LiSa loopme;
//s => dac;
//440. => s.freq;

//alloc memory
9::second => loopme.duration;
1000::ms => loopme.loopEndRec;
1000::ms => loopme.loopEnd;

//set recording ramp time
loopme.recRamp(50::ms);
loopme.feedback(0.99); //retain some while loop recording

//start recording input
loopme.record(1);

//1 sec later, this time DON'T stop recording....
1000::ms => now;


//set track mode to 1, where the input chooses playback position
 //1 => loopme.track;
//this time don't change the freq; scan through zippy quick

loopme.play(1);
loopme.gain(0.01);
8000::ms => now;
loopme.rampDown(250::ms);
500::ms => now;

//pretty farking scary
//bye bye
		}
        }
        
        // joystick button up
        else if( msg.isButtonUp() )
        {
            <<< "joystick button", msg.which, "up" >>>;
		if(msg.which == 0){ // STOP FREQUENCY NOISE
			0 => c.freq;
			0 => m.freq;
			0 => m.gain;

			now => stopTime;
			//<<< "time started was: " , startTime >>>;
			//<<< "time stopped was: " , stopTime >>>;
			stopTime - startTime => dur durationPressed;
			<<< "Duration was: " , durationPressed >>>; 
		}
		if(msg.which == 1){
		}
		if(msg.which == 2){

			
		}
		if(msg.which == 3){
			
		}
		if(msg.which == 4){
			
		}
        }
        
        // joystick hat/POV switch/d-pad motion
        else if( msg.isHatMotion() )
        {
            <<< "joystick hat", msg.which, ":", msg.idata >>>;
        }
    }
}

fun void startLoop() {
    loopNum => int playNum;
    loopNum + 1 => loopNum;
    // => dur loopLength;
    while(true){
        SndBuf buf;
        playNum + ".wav" => string filename;
        filename => buf.read;
        buf => dac;
        buf.length() => now;
        
    }
     
}

fun void newLoop(){
	//ADC => LiSa saveme => DAC;
	//dac => LiSa saveme;
	SinOsc s => LiSa saveme => dac;
	//s => dac;
	//440 => s.freq;
	//.2 => s.gain;
	
	// required memory allocation
	60::second => saveme.duration;
	
	1 => saveme.rate;
	
	saveme.record(1);
	
	//
	1000::ms => now;
	
	saveme.rampUp(100::ms);
	1000::ms => now;
	
	saveme.rampDown(300::ms);
	//saveme.play(0);
	500::ms => now;
	1 => saveme.loop;
	saveme.loopStart();
	//while(true){
		saveme.play(1);
	//}
}
