//
//  ViewController.m
//  AudioLab
//
//  Created by Eric Larson on 8/24/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

#import "ViewController.h"
#import "Novocaine.h"
#import "CircularBuffer.h"
#import "SMUGraphHelper.h"

#define BUFFER_SIZE 22050

@interface ViewController ()
@property (strong, nonatomic) Novocaine* audioManager;
//@property (strong, nonatomic) AudioFileReader *fileReader;
@property (strong, nonatomic) CircularBuffer *buffer;
@property (strong,nonatomic) SMUGraphHelper* graphHelper;
@end



@implementation ViewController


//-(AudioFileReader*)fileReader{
//    if(!_fileReader){
//        NSURL* file = [[NSBundle mainBundle] URLForResource:@"satisfaction" withExtension:@"mp3"];
//        
//        _fileReader = [[AudioFileReader alloc]
//                       initWithAudioFileURL:file
//                       samplingRate:self.audioManager.samplingRate
//                       numChannels:self.audioManager.numInputChannels];
//    }
//    return _fileReader;
//}

-(SMUGraphHelper*)graphHelper{
    if(!_graphHelper){
        _graphHelper = [[SMUGraphHelper alloc]initWithController:self
                                        preferredFramesPerSecond:15
                                                       numGraphs:1
                                                       plotStyle:PlotStyleSeparated
                                               maxPointsPerGraph:BUFFER_SIZE];
        
    }
    return _graphHelper;
}

-(CircularBuffer*)buffer{
    if(!_buffer){
        _buffer = [[CircularBuffer alloc]initWithNumChannels:1
                                               andBufferSize:BUFFER_SIZE];
    }
    return _buffer;
}


-(Novocaine*)audioManager{
    if(!_audioManager){
        _audioManager = [Novocaine audioManager];
    }
    return _audioManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.graphHelper setFullScreenBounds];
    // Do any additional setup after loading the view, typically from a nib.
    __block ViewController* __weak weakSelf = self;
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
        [weakSelf.buffer addNewFloatData:data withNumSamples:numFrames];
    }];
    
//    [self.fileReader play];
//    self.fileReader.currentTime = 0.0;
    
    double frequency = 600;
    __block double phase = 0.0;
    double phaseIncrement = 2*M_PI*frequency/self.audioManager.samplingRate;
    double phaseMax = 2*M_PI;
        [self.audioManager setOutputBlock:^(float* data, UInt32 numFrames, UInt32 numChannels){
//        [weakSelf.fileReader retrieveFreshAudio:data numFrames:numFrames numChannels:numChannels];
        for(int i=0; i<numFrames;++i){
            for(int j=0;j<numChannels;++j){
                data[2*i+j] = sin(phase);
            }
            phase+=phaseIncrement;
            if (phase>phaseMax){
                phase -= phaseMax;
            }
        }
        
    }];
    
    [self.audioManager play];
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self.graphHelper draw];
}


-(void)update{
    float* array = malloc(sizeof(float)*BUFFER_SIZE);
    [self.buffer fetchFreshData:array withNumSamples:BUFFER_SIZE];
    
    [self.graphHelper setGraphData:array
                    withDataLength:BUFFER_SIZE
                     forGraphIndex:0];
    
    [self.graphHelper update];
    free(array);
}

@end
