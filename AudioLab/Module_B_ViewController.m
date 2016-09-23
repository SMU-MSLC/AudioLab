//
//  Module_B_ViewController.m
//  AudioLab
//
//  Created by Omar Roa on 9/22/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

#import "Module_B_ViewController.h"
#import "Novocaine.h"
#import "CircularBuffer.h"
#import "SMUGraphHelper.h"
#import "FFTHelper.h"

#define BUFFER_SIZE 4096
#define deltaF 5.3833

@interface Module_B_ViewController ()
@property (strong, nonatomic) Novocaine *audioManager;
@property (strong, nonatomic) CircularBuffer *buffer;
@property (strong, nonatomic) SMUGraphHelper *graphHelper;
@property (strong, nonatomic) FFTHelper *fftHelper;
@property (weak, nonatomic) IBOutlet UISwitch *lockSwitch;
@property (weak, nonatomic) IBOutlet UISlider *pitchSlider;
@property (weak, nonatomic) IBOutlet UILabel *dopplerLabel;

@end

@implementation Module_B_ViewController

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
                                                       numGraphs:2
                                                       plotStyle:PlotStyleSeparated
                                               maxPointsPerGraph:BUFFER_SIZE];
    }
    return _graphHelper;
}

-(FFTHelper*)fftHelper{
    if(!_fftHelper){
        _fftHelper = [[FFTHelper alloc]initWithFFTSize:BUFFER_SIZE];
    }
    
    return _fftHelper;
}


#pragma mark VC Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [self.graphHelper setScreenBoundsBottomHalf];
    
    __block Module_B_ViewController * __weak  weakSelf = self;
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
        [weakSelf.buffer addNewFloatData:data withNumSamples:numFrames];
    }];
    
    
    double frequency = self.pitchSlider.value; //starting frequency
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



- (IBAction)onSliderChange:(id)sender {
    double frequency = self.pitchSlider.value; //starting frequency
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

#pragma mark GLK Inherited Functions
- (void)update{
    
    float frequency = self.pitchSlider.value;
    
    // get audio stream data
    float* arrayData = calloc(BUFFER_SIZE*2, sizeof(float));
    float* fftMagnitude = malloc(sizeof(float)*BUFFER_SIZE);
    
    [self.buffer fetchFreshData:arrayData withNumSamples:BUFFER_SIZE];
    [self.graphHelper setGraphData:arrayData
                    withDataLength:BUFFER_SIZE
                     forGraphIndex:0];
    
    
    // take forward FFT
    [self.fftHelper performForwardFFTWithData:arrayData
                   andCopydBMagnitudeToBuffer:fftMagnitude];
    
    [self.graphHelper setGraphData:fftMagnitude
                    withDataLength:BUFFER_SIZE/2
                     forGraphIndex:1
                 withNormalization:64.0
                     withZeroValue:-60];
    
    int frequencyOutputIndex = frequency/deltaF;
    int dopplerVariance = 20;
    float leftDopplerAvg = 0.0;
    float rightDopplerAvg = 0.0;
    
    float sum = 0.0;
    
    for(int i = frequencyOutputIndex - dopplerVariance ; i < frequencyOutputIndex; i++){
        
        sum+=fftMagnitude[i];
        NSLog(@"array: %f", arrayData[i]);

    }
    
    leftDopplerAvg = sum/dopplerVariance;
    
    sum = 0.0;
    
    for(int i = frequencyOutputIndex  ; i < frequencyOutputIndex + dopplerVariance; i++){
        
        sum+=fftMagnitude[i];
//        NSLog(@"right sum: %f", fftMagnitude[i]);
        
    }
    
    rightDopplerAvg = sum /dopplerVariance;
    NSLog(@"left: %f    right: %f", leftDopplerAvg, rightDopplerAvg);
    if(leftDopplerAvg > rightDopplerAvg){
        self.dopplerLabel.text = @"Away";
    }
    else{
        self.dopplerLabel.text = @"Towards";
    }
    
    
    [self.graphHelper update];
    free(arrayData);
    free(fftMagnitude);
}

//  override the GLKView draw function, from OpenGLES
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.graphHelper draw]; // draw the graph
}

@end
