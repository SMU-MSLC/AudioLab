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



@property (strong, nonatomic) Novocaine* audioManager;


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
    

    [self.audioManager setOutputBlock:^(float* data, UInt32 numFrames, UInt32 numChannels){
        
       
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




@end
