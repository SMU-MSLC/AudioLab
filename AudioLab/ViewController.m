//
//  ViewController.m
//  AudioLab
//
//  Created by Eric Larson on 8/24/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

#import "ViewController.h"
#import "Novocaine.h"


@interface ViewController ()

@property (nonatomic) float frequency;

@property (weak, nonatomic) IBOutlet UILabel *freqLabel;

@property (strong, nonatomic) Novocaine* audioManager;

@property (nonatomic) float phaseIncrement;

@end



@implementation ViewController

-(Novocaine*)audioManager{
    if(!_audioManager){
        _audioManager = [Novocaine audioManager];
    }
    return _audioManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self updateFrequencyInKhz:0.2616255]; // mid C
    
    self.phaseIncrement = 2*M_PI*self.frequency/self.audioManager.samplingRate;
    float phaseInc = 2*M_PI*440.0/self.audioManager.samplingRate;
    __block float phase = 0.0;
    [self.audioManager setOutputBlock:^(float* data, UInt32 numFrames, UInt32 numChannels){
        
        for (int n=0; n<numFrames; n++) {
            data[n] = sin(phase);
            phase += self.phaseIncrement;
        }
        
    }];
    
    [self.audioManager play];
    
}

//for(int i=0;i<numFrames;i++){
//    for(int j=0;j<numChannels;j++){
//        data[i*numChannels+j] = sin(phase);
//    }
//    phase += self.phaseIncrement;
//
//    if(phase>2*M_PI){
//        phase -= 2*M_PI;
//    }
//}

- (IBAction)frequencyChanged:(UISlider *)sender {
    [self updateFrequencyInKhz:sender.value];
    
}

-(void)updateFrequencyInKhz:(float) freqInKHz {
    self.frequency = freqInKHz*1000.0;
    self.freqLabel.text = [NSString stringWithFormat:@"%.4f kHz",freqInKHz];
    self.phaseIncrement = 2*M_PI*self.frequency/self.audioManager.samplingRate;
}


@end
