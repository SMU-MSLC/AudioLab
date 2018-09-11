//
//  ViewController.m
//  AudioLab
//
//  Created by Eric Larson
//  Copyright © 2016 Eric Larson. All rights reserved.
//

#import "ViewController.h"
#import "Novocaine.h"
#import "AudioFileReader.h"

@interface ViewController ()
@property (strong, nonatomic) Novocaine *audioManager;
@property (strong, nonatomic) AudioFileReader *fileReader;
@property (nonatomic) float volume;
@end



@implementation ViewController

#pragma mark Lazy Instantiation
-(Novocaine*)audioManager{
    if(!_audioManager){
        _audioManager = [Novocaine audioManager];
    }
    return _audioManager;
}

-(AudioFileReader*)fileReader{
    if(!_fileReader){
        NSURL *inputFileURL = [[NSBundle mainBundle] URLForResource:@"satisfaction" withExtension:@"mp3"];
        _fileReader = [[AudioFileReader alloc]
                       initWithAudioFileURL:inputFileURL
                       samplingRate:self.audioManager.samplingRate
                       numChannels:self.audioManager.numOutputChannels];
    }
    return _fileReader;
}
- (IBAction)volumeChanged:(UISlider *)sender {
    self.volume = sender.value;
}

#pragma mark VC Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
    //        NSLog(@"%f", data[0]);
    //    }];
    self.volume = 0.5;
    
    [self.fileReader play];
    self.fileReader.currentTime = 0.0;
    
    __block ViewController * __weak  weakSelf = self; // don't incrememt ARC'
    [self.audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         [weakSelf.fileReader retrieveFreshAudio:data numFrames:numFrames numChannels:numChannels];
         for(int i=0;i<numFrames*numChannels;i++){
             data[i] = data[i]*weakSelf.volume;
         }
         NSLog(@"Time: %f", weakSelf.fileReader.currentTime);
     }];
    
    
    [self.audioManager play];
}



@end
