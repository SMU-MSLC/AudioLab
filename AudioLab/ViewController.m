//
//  ViewController.m
//  AudioLab
//
//  Created by Eric Larson
//  Copyright © 2016 Eric Larson. All rights reserved.
//

#import "ViewController.h"
#import "Novocaine.h"


@interface ViewController ()
@property (strong, nonatomic) Novocaine *audioManager;

@end



@implementation ViewController

#pragma mark Lazy Instantiation
-(Novocaine*)audioManager{
    if(!_audioManager){
        _audioManager = [Novocaine audioManager];
    }
    return _audioManager;
}



#pragma mark VC Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
    //        NSLog(@"%f", data[0]);
    //    }];
    
    double frequency = 630.0; //starting frequency
    __block float phase = 0.0;
    double phaseIncrement = 2*M_PI*frequency/self.audioManager.samplingRate;
    double sineWaveRepeatMax = 2*M_PI;

    [self.audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         for (int i=0; i < numFrames; ++i)
         {
             data[i] = sin(phase);
             
             phase += phaseIncrement;
             if (phase >= sineWaveRepeatMax) phase -= sineWaveRepeatMax;
             
         }
     }];
    
    
    [self.audioManager play];
}



@end
