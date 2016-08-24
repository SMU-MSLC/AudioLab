//
//  ViewController.m
//  AudioLab
//
//  Created by Eric Larson on 8/24/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

#import "ViewController.h"
#import "Novocaine.h"
#import "AudioFileReader.h"

@interface ViewController ()
@property (strong, nonatomic) Novocaine *audioManager;
@property (strong, nonatomic) AudioFileReader *fileReader;

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
    // Do any additional setup after loading the view, typically from a nib.
    
    //    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
    //        NSLog(@"%f", data[0]);
    //    }];
    
    
    NSURL *inputFileURL = [[NSBundle mainBundle] URLForResource:@"satisfaction" withExtension:@"mp3"];
    
    self.fileReader = [[AudioFileReader alloc]
                       initWithAudioFileURL:inputFileURL
                       samplingRate:self.audioManager.samplingRate
                       numChannels:self.audioManager.numOutputChannels];
    
    [self.fileReader play];
    self.fileReader.currentTime = 0.0;
    
    __block ViewController * __weak  weakSelf = self;
    [self.audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         [weakSelf.fileReader retrieveFreshAudio:data numFrames:numFrames numChannels:numChannels];
         NSLog(@"Time: %f", weakSelf.fileReader.currentTime);
     }];
    
    
    [self.audioManager play];
}



@end
