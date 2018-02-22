//
//  ViewController.m
//  CoreGraphicsWaveform
//
//  Created by Syed Haris Ali on 12/1/13.
//  Updated by Syed Haris Ali on 1/23/16.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "ViewController.h"
#import "LFHeatMap.h"
//------------------------------------------------------------------------------
#pragma mark - ViewController (Interface Extension)
//------------------------------------------------------------------------------

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *bigImageView;



@property (nonatomic, strong) NSArray *inputs;
@end

//------------------------------------------------------------------------------
#pragma mark - ViewController (Implementation)
//------------------------------------------------------------------------------

@implementation ViewController
{
    int callCount;
    //int secCount;
    //NSTimer *timer;
    NSMutableArray *pointsArray;
    NSMutableArray *arrayOfIntensities;
    NSMutableArray *newArray;
    
    UIImage *heatImage1;
    UIImage *heatImage2;
    UIImage *heatImage3;
    UIImage *heatImage4;
    UIImage *heatImage5;
    UIImage *heatImage6;
    UIImage *heatImage7;
    UIImage *heatImage8;
    UIImage *heatImage9;
    
    
    float *floatBuffer;
}



//------------------------------------------------------------------------------
#pragma mark - View Style
//------------------------------------------------------------------------------

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];

    //
    // Setup the AVAudioSession. EZMicrophone will not work properly on iOS
    // if you don't do this!
    //
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    [session setActive:YES error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    }

    //
    // Customizing the audio plot's look
    //
    
    //
    // Background color
    //
    self.audioPlot.backgroundColor = [UIColor blackColor]; //[UIColor colorWithRed:0.984 green:0.471 blue:0.525 alpha:1.0];
    self.audioPlot2.backgroundColor = [UIColor blackColor]; //[UIColor colorWithRed:0.984 green:0.471 blue:0.525 alpha:1.0];

    //
    // Waveform color
    //
    self.audioPlot.color = [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:1.0];
    self.audioPlot2.color = [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:1.0];


    //
    // Plot type
    //
    self.audioPlot.plotType = EZPlotTypeRolling;
    self.audioPlot2.plotType = EZPlotTypeBuffer;
    self.audioPlot2.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;


    //
    // Create the microphone
    //
    self.microphone = [EZMicrophone microphoneWithDelegate:self];

    //
    // Set up the microphone input UIPickerView items to select
    // between different microphone inputs. Here what we're doing behind the hood
    // is enumerating the available inputs provided by the AVAudioSession.
    //
    self.inputs = [EZAudioDevice inputDevices];
    self.microphoneInputPickerView.dataSource = self;
    self.microphoneInputPickerView.delegate = self;

    //
    // Start the microphone
    //
    [self.microphone startFetchingAudio];
    self.microphoneTextLabel.text = @"Microphone On";
    
    
    callCount = 0;
    
    pointsArray = [NSMutableArray array];
    arrayOfIntensities = [NSMutableArray array];
    newArray = [NSMutableArray array];
    
    
    for (int j = 0; j < 86; j++) {
        for (int i = 0; i < 255; i++) {
            CGPoint point = CGPointMake(j, (254 - i));
            [pointsArray addObject:[NSValue valueWithCGPoint:point]];
            //[newArray addObject:[NSNumber numberWithInteger:0]];
        }
    }
    

    floatBuffer = malloc((sizeof(float)*512) * 86);
    
    
}


/*
- (void)timerCalled {
//    secCount++;
    NSLog(@"%d calls over", callCount);
} */

//------------------------------------------------------------------------------
#pragma mark - UIPickerViewDataSource
//------------------------------------------------------------------------------

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//------------------------------------------------------------------------------

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    EZAudioDevice *device = self.inputs[row];
    return device.name;
}

//------------------------------------------------------------------------------

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView
             attributedTitleForRow:(NSInteger)row
                      forComponent:(NSInteger)component
{
    EZAudioDevice *device = self.inputs[row];
    UIColor *textColor = [device isEqual:self.microphone.device] ? self.audioPlot.backgroundColor : [UIColor blackColor];
    return  [[NSAttributedString alloc] initWithString:device.name
                                            attributes:@{ NSForegroundColorAttributeName : textColor }];
}

//------------------------------------------------------------------------------

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.inputs.count;
}

//------------------------------------------------------------------------------

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    EZAudioDevice *device = self.inputs[row];
    [self.microphone setDevice:device];
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (void)changePlotType:(id)sender
{
    NSInteger selectedSegment = [sender selectedSegmentIndex];
    switch (selectedSegment)
    {
        case 0:
            [self drawBufferPlot];
            break;
        case 1:
            [self drawRollingPlot];
            break;
        default:
            break;
    }
}

//------------------------------------------------------------------------------

- (void)toggleMicrophone:(id)sender
{
    BOOL isOn = [sender isOn];
    if (!isOn)
    {
        [self.microphone stopFetchingAudio];
        self.microphoneTextLabel.text = @"Microphone Off";
    }
    else
    {
        [self.microphone startFetchingAudio];
        self.microphoneTextLabel.text = @"Microphone On";
    }
}

//------------------------------------------------------------------------------

- (void)toggleMicrophonePickerView:(id)sender
{
    BOOL isHidden = self.microphoneInputPickerViewTopConstraint.constant != 0.0;
    [self setMicrophonePickerViewHidden:!isHidden];
}

//------------------------------------------------------------------------------

- (void)setMicrophonePickerViewHidden:(BOOL)hidden
{
    CGFloat pickerHeight = CGRectGetHeight(self.microphoneInputPickerView.bounds);
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.55
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.5
                        options:(UIViewAnimationOptionBeginFromCurrentState|
                                 UIViewAnimationOptionCurveEaseInOut|
                                 UIViewAnimationOptionLayoutSubviews)
                     animations:^{
                         weakSelf.microphoneInputPickerViewTopConstraint.constant = hidden ? -pickerHeight : 0.0f;
                         [weakSelf.view layoutSubviews];
                     } completion:nil];
}

//------------------------------------------------------------------------------
#pragma mark - Utility
//------------------------------------------------------------------------------

//
// Give the visualization of the current buffer (this is almost exactly the
// openFrameworks audio input eample)
//
- (void)drawBufferPlot
{
    self.audioPlot.plotType = EZPlotTypeBuffer;
    self.audioPlot.shouldMirror = NO;
    self.audioPlot.shouldFill = NO;
}

//------------------------------------------------------------------------------

//
// Give the classic mirrored, rolling waveform look
//
-(void)drawRollingPlot
{
    self.audioPlot.plotType = EZPlotTypeRolling;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
}

#pragma mark - EZMicrophoneDelegate
#warning Thread Safety
//
// Note that any callback that provides streamed audio data (like streaming
// microphone input) happens on a separate audio thread that should not be
// blocked. When we feed audio data into any of the UI components we need to
// explicity create a GCD block on the main thread to properly get the UI
// to work.
//
- (void)microphone:(EZMicrophone *)microphone
  hasAudioReceived:(float **)buffer
    withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels
{

    //
    // Getting audio data as an array of float buffer arrays. What does that mean?
    // Because the audio is coming in as a stereo signal the data is split into
    // a left and right channel. So buffer[0] corresponds to the float* data
    // for the left channel while buffer[1] corresponds to the float* data
    // for the right channel.
    //

    //
    // See the Thread Safety warning above, but in a nutshell these callbacks
    // happen on a separate audio thread. We wrap any UI updating in a GCD block
    // on the main thread to avoid blocking that audio flow.
    //
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        //
        // All the audio plot needs is the buffer data (float*) and the size.
        // Internally the audio plot will handle all the drawing related code,
        // history management, and freeing its own resources.
        // Hence, one badass line of code gets you a pretty plot :)
        //
        
        callCount++;
        
        float maxVal = 0;
  
        
        [weakSelf.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];


     
        
        
        
        
        
        EZAudioFFT *audioFFT = [EZAudioFFT fftWithMaximumBufferSize:512 sampleRate:44100];
        float *fftPoint = [audioFFT computeFFTWithBuffer:buffer[0] withBufferSize:512];
        maxVal = 0;
        for(int i = 0 ; i < 255; i++){
            if(maxVal < fftPoint[i]){
                maxVal = fftPoint[i];
            }
        }
        
        for(int i = 0 ; i < 255; i++){
            fftPoint[i] /= maxVal;
            //printf("%f\n",fftPoint[i]);
        }
        
        [weakSelf.audioPlot2 updateBuffer:fftPoint withBufferSize:bufferSize/2];
        
        [weakSelf createArrayOfIntensities:fftPoint];
        
        
        if (callCount % 86 == 0) {
            [weakSelf setupImageStrip];
            [arrayOfIntensities removeAllObjects];
            callCount = 0;
        }

    });
}


- (void)movePointsArrayForward {
    [pointsArray enumerateObjectsUsingBlock:^(NSValue *_Nonnull value, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint oldValue = [value CGPointValue];
        CGPoint newValue = CGPointMake(oldValue.x + 86, oldValue.y);
        value = [NSValue valueWithCGPoint:newValue];
    }];
    
    
}

- (void)createArrayOfIntensities:(float *)fftPoint {
    
    for (int i = 0; i < 255; i++) {
        NSNumber *number = [NSNumber numberWithInteger:(long)(fftPoint[i] * 50)];
        [arrayOfIntensities addObject:number];
    }
    
}

- (void)setupImageStrip {
    
    
    heatImage9 = heatImage8 != nil? heatImage8 : [self createBlankImage];
    heatImage8 = heatImage7 != nil? heatImage7 : [self createBlankImage];
    heatImage7 = heatImage6 != nil? heatImage6 : [self createBlankImage];
    heatImage6 = heatImage5 != nil? heatImage5 : [self createBlankImage];
    heatImage5 = heatImage4 != nil? heatImage4 : [self createBlankImage];
    heatImage4 = heatImage3 != nil? heatImage3 : [self createBlankImage];
    heatImage3 = heatImage2 != nil? heatImage2 : [self createBlankImage];
    heatImage2 = heatImage1 != nil? heatImage1 : [self createBlankImage];
    
    
    CGRect heatmapRect = CGRectMake(0, 0, 86, 256);
    
    heatImage1 = [LFHeatMap heatMapWithRect:heatmapRect boost:0.1 points:pointsArray weights:arrayOfIntensities weightsAdjustmentEnabled:YES groupingEnabled:NO];
    
    self.bigImageView.image = [self combinedImage:@[heatImage5, heatImage4, heatImage3, heatImage2, heatImage1]];
    
    

}




//------------------------------------------------------------------------------

- (void)microphone:(EZMicrophone *)microphone hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription
{
    //
    // The AudioStreamBasicDescription of the microphone stream. This is useful
    // when configuring the EZRecorder or telling another component what
    // audio format type to expect.
    //
    [EZAudioUtilities printASBD:audioStreamBasicDescription];
}

//------------------------------------------------------------------------------

- (void)microphone:(EZMicrophone *)microphone
     hasBufferList:(AudioBufferList *)bufferList
    withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels
{
    //
    // Getting audio data as a buffer list that can be directly fed into the
    // EZRecorder or EZOutput. Say whattt...
    //
}

//------------------------------------------------------------------------------

- (void)microphone:(EZMicrophone *)microphone changedDevice:(EZAudioDevice *)device
{
    NSLog(@"Microphone changed device: %@", device.name);

    //
    // Called anytime the microphone's device changes
    //
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *name = device.name;
        NSString *tapText = @" (Tap To Change)";
        NSString *microphoneInputToggleButtonText = [NSString stringWithFormat:@"%@%@", device.name, tapText];
        NSRange rangeOfName = [microphoneInputToggleButtonText rangeOfString:name];
        NSMutableAttributedString *microphoneInputToggleButtonAttributedText = [[NSMutableAttributedString alloc] initWithString:microphoneInputToggleButtonText];
        [microphoneInputToggleButtonAttributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0f] range:rangeOfName];
        [weakSelf.microphoneInputToggleButton setAttributedTitle:microphoneInputToggleButtonAttributedText forState:UIControlStateNormal];

        //
        // Reset the device list (a device may have been plugged in/out)
        //
        weakSelf.inputs = [EZAudioDevice inputDevices];
        [weakSelf.microphoneInputPickerView reloadAllComponents];
        [weakSelf setMicrophonePickerViewHidden:YES];
    });
}

- (UIImage *)combinedImage:(NSArray *)images {
    
    UIImage *sampleImage = (UIImage *)images[0];
    CGSize size = CGSizeMake(sampleImage.size.width * images.count, sampleImage.size.height);
    UIGraphicsBeginImageContext(size);
    CGFloat previousImageWidth = 0;
    for (UIImage *image in images) {
        CGFloat xcod = previousImageWidth;
        CGFloat ycod = 0;
        CGFloat width = image.size.width;
        CGFloat height = size.height;
        [image drawInRect:CGRectMake(xcod, ycod, width, height)];
        previousImageWidth += width;
    }
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}

- (UIImage *)createBlankImage {
    CGSize imageSize = CGSizeMake(86, 256);
    UIColor *fillColor = [UIColor blackColor];
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [fillColor setFill];
    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
