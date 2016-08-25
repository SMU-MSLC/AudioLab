//
//  ViewController.m
//  AudioLab
//
//  Created by Eric Larson
//  Copyright © 2016 Eric Larson. All rights reserved.
//

#import "ViewController.h"
#import "Novocaine.h"
#import "CircularBuffer.h"
#import "SMUGraphHelper.h"

#define BUFFER_SIZE 2048

@interface ViewController ()
@property (strong, nonatomic) Novocaine *audioManager;
@property (strong, nonatomic) CircularBuffer *buffer;
@property (strong, nonatomic) SMUGraphHelper *graphHelper;
@end



@implementation ViewController

#pragma mark Lazy Instantiation
-(Novocaine*)audioManager{
    if(!_audioManager){
        _audioManager = [Novocaine audioManager];
    }
    return _audioManager;
}

-(CircularBuffer*)buffer{
    if(!_buffer){
        _buffer = [[CircularBuffer alloc]initWithNumChannels:1 andBufferSize:BUFFER_SIZE];
    }
    return _buffer;
}

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



#pragma mark VC Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
   
    [self.graphHelper setScreenBoundsBottomHalf];
    
    __block ViewController * __weak  weakSelf = self;
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
        [weakSelf.buffer addNewFloatData:data withNumSamples:numFrames];
    }];
    
    [self.audioManager play];
}

#pragma mark GLK Inherited Functions
//  override the GLKViewController update function, from OpenGLES
- (void)update{
    // just plot the audio stream
    
    // get audio stream data
    float* arrayData = malloc(sizeof(float)*BUFFER_SIZE);
    [self.buffer fetchFreshData:arrayData withNumSamples:BUFFER_SIZE];
    
    //send off for graphing
    [self.graphHelper setGraphData:arrayData
                    withDataLength:BUFFER_SIZE
                     forGraphIndex:0];
    
    [self.graphHelper update]; // update the graph
    free(arrayData);
}

//  override the GLKView draw function, from OpenGLES
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.graphHelper draw]; // draw the graph
}


@end
