//
//  ViewController.m
//  AudioLab
//
//  Created by Eric Larson on 8/24/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

#import "ViewController.h"



@interface ViewController ()

@property (nonatomic) float frequency;

@property (weak, nonatomic) IBOutlet UILabel *freqLabel;

@end



@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateFrequencyInKhz:0.2616255]; //mid C
    
    
}

- (IBAction)frequencyChanged:(UISlider *)sender {
    [self updateFrequencyInKhz:sender.value];
    
}

-(void)updateFrequencyInKhz:(float) freqInKHz {
    self.frequency = freqInKHz*1000.0;
    self.freqLabel.text = [NSString stringWithFormat:@"%.4f kHz",freqInKHz];
}


@end
