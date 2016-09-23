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
#define deltaF 10.7666

@interface Module_B_ViewController ()
@property (strong, nonatomic) Novocaine *audioManager;
@property (strong, nonatomic) CircularBuffer *buffer;
@property (strong, nonatomic) SMUGraphHelper *graphHelper;
@property (strong, nonatomic) FFTHelper *fftHelper;
@property (weak, nonatomic) IBOutlet UISwitch *lockSwitch;
@property (weak, nonatomic) IBOutlet UISlider *pitchSlider;
@property (weak, nonatomic) IBOutlet UILabel *dopplerLabel;
@property float lastLeftAvg;
@property float lastRightAvg;

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
    
    _lastLeftAvg = 0.0;
    _lastRightAvg = 0.0;
    
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
    
    static int onlyUpdate = 0;
    
    float frequency = self.pitchSlider.value;
    
    // get audio stream data
    float* arrayData = calloc(BUFFER_SIZE, sizeof(float));
    float* fftMagnitude = malloc(sizeof(float)*BUFFER_SIZE/2);
    
    [self.buffer fetchFreshData:arrayData withNumSamples:BUFFER_SIZE];
    
    // take forward FFT
    [self.fftHelper performForwardFFTWithData:arrayData
                   andCopydBMagnitudeToBuffer:fftMagnitude];
    
    
    int frequencyOutputIndex = frequency/(deltaF);
    int dopplerVariance = 12;
    float leftDopplerAvg = 0.0;
    float rightDopplerAvg = 0.0;
    
    float sum = 0.0;
    for(int i = frequencyOutputIndex - (dopplerVariance) ; i < frequencyOutputIndex; i++){
        sum+=fftMagnitude[i];
    }
    
    leftDopplerAvg = sum/dopplerVariance;
    
    sum = 0.0;
    for(int i = frequencyOutputIndex+1  ; i < frequencyOutputIndex + (dopplerVariance); i++){
        sum+=fftMagnitude[i];
    }
    
    rightDopplerAvg = sum /dopplerVariance;
    
    
    if (self.lastLeftAvg != 0.0&& self.lastRightAvg != 0.0) {
        NSLog(@"left diff: %f    right diff: %f", leftDopplerAvg/self.lastLeftAvg, rightDopplerAvg/self.lastRightAvg);
        float leftDiff = leftDopplerAvg/self.lastLeftAvg;
        float rightDiff = rightDopplerAvg/self.lastRightAvg;
        if (onlyUpdate == 5) {
            if (leftDiff < rightDiff && leftDiff < .9) {
                self.dopplerLabel.text = @"Away";
            } else if(rightDiff < leftDiff && rightDiff < .9) {
                self.dopplerLabel.text = @"Towards";
            } else {
                self.dopplerLabel.text = @"Stationary";
            }
            onlyUpdate = 0;
        }
        
    }
    
    self.lastLeftAvg = leftDopplerAvg;
    self.lastRightAvg = rightDopplerAvg;
    free(arrayData);
    free(fftMagnitude);
    
    onlyUpdate++;
}
-(void) viewWillDisappear:(BOOL)animated {
    [self.audioManager pause];
    [super viewWillDisappear:false];
}

//  override the GLKView draw function, from OpenGLES
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.graphHelper draw]; // draw the graph
}

@end
