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
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
        NSLog(@"%f", data[0]);
    }];
    
    [self.audioManager play];
}
 


@end
