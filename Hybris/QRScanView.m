//
//  QRScanView.m
//  QRScanDemo
//
//  Created by Accenture on 14-11-5.
//  Copyright (c) 2014年 Accenture. All rights reserved.
//

#import "QRScanView.h"
#import <QuartzCore/CALayer.h>

#define PICK_WIDTH 150
#define BUTTON_WIDTH 30

@interface QRScanView () {
    
    CALayer *pickLayer;
    UIView *popView;
    UIButton *brightBtn;
    UIButton *contrastBtn;
    UILabel *label;
    UISlider *slider;
}

@end

@implementation QRScanView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initComponent];
        
        [self initLayer];
    }
    return self;
}

- (void)initComponent
{
    self.backgroundColor = [UIColor grayColor];
    
    CGRect rect = CGRectMake((CGRectGetWidth(self.frame) - PICK_WIDTH)/2, (CGRectGetHeight(self.frame) - PICK_WIDTH)/2, PICK_WIDTH, PICK_WIDTH);
    
    UIImageView *pickImageView = [[UIImageView alloc]initWithFrame:rect];
    pickImageView.image = [UIImage imageNamed:@"pick_bg"];
    
    [self addSubview:pickImageView];
    
//    UIButton *popBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [popBtn setFrame:CGRectMake(CGRectGetWidth(self.frame)/2 - 50, (CGRectGetHeight(self.frame) + PICK_WIDTH)/2 + 100, BUTTON_WIDTH, BUTTON_WIDTH)];
//    [popBtn setBackgroundImage:[UIImage imageNamed:@"brightness"] forState:UIControlStateNormal];
//    [popBtn addTarget:self action:@selector(brightnessBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:popBtn];
//    
//    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [closeBtn setFrame:CGRectMake(CGRectGetWidth(self.frame)/2 + 20, (CGRectGetHeight(self.frame) + PICK_WIDTH)/2 + 100, BUTTON_WIDTH, BUTTON_WIDTH)];
//    [closeBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
//    [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:closeBtn];
//    
//    [self initPopView];
}

//- (void)initPopView
//{
//    popView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2 - 130, (CGRectGetHeight(self.frame) + PICK_WIDTH)/2 + 10, 260, 80)];
//    popView.backgroundColor = [UIColor colorWithRed:225/255 green:225/255 blue:225/255 alpha:0.5];
//    [popView setHidden:YES];
//    [self addSubview:popView];
//    
//    brightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [brightBtn setFrame:CGRectMake(10, 10, BUTTON_WIDTH, BUTTON_WIDTH)];
//    [brightBtn setBackgroundImage:[UIImage imageNamed:@"brightness"] forState:UIControlStateNormal];
//    [brightBtn addTarget:self action:@selector(cameraChangeClick:) forControlEvents:UIControlEventTouchUpInside];
//    [brightBtn setTag:10001];
//    [popView addSubview:brightBtn];
//    
//    contrastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [contrastBtn setFrame:CGRectMake(50, 10, BUTTON_WIDTH, BUTTON_WIDTH)];
//    [contrastBtn setBackgroundImage:[UIImage imageNamed:@"disable"] forState:UIControlStateNormal];
//    [contrastBtn addTarget:self action:@selector(cameraChangeClick:) forControlEvents:UIControlEventTouchUpInside];
//    [contrastBtn setTag:10002];
//    [popView addSubview:contrastBtn];
//    
//    label = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 100, 30)];
//    [label setBackgroundColor:[UIColor clearColor]];
//    [label setText:@"brightness"];
//    [label setTextColor:[UIColor whiteColor]];
//    [popView addSubview:label];
//    
//    slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 55, 240, 10)];
//    slider.minimumValue = 0;
//    slider.maximumValue = 1;
//    slider.value = 50;
//    [slider addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
//    [popView addSubview:slider];
//}

- (void)initLayer
{
    pickLayer = [[CALayer alloc]init];
    pickLayer.bounds = CGRectMake(0, 0, PICK_WIDTH, 3);
    pickLayer.position = CGPointMake(CGRectGetWidth(self.frame)/2, (CGRectGetHeight(self.frame) - PICK_WIDTH)/2);
    pickLayer.contents = (id)[UIImage imageNamed:@"line"].CGImage;
    [self.layer addSublayer:pickLayer];
}

-(void)translatonAnimation:(CGPoint)location{

    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    basicAnimation.toValue = [NSValue valueWithCGPoint:location];
    
    basicAnimation.duration = 3.0;
    basicAnimation.repeatCount = HUGE_VALF;
    basicAnimation.removedOnCompletion = NO;
    
    [pickLayer addAnimation:basicAnimation forKey:@"KCBasicAnimation_Translation"];
}

- (void)setupCamera
{
    CGPoint point = CGPointMake(CGRectGetWidth(self.frame)/2, (CGRectGetHeight(self.frame) - PICK_WIDTH)/2 + PICK_WIDTH);
    [self translatonAnimation:point];
    
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    //AVMetadataObjectTypeQRCode
//    NSArray *types = [[NSArray alloc] initWithObjects:AVMetadataObjectTypeQRCode, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeInterleaved2of5Code, AVMetadataObjectTypeITF14Code, AVMetadataObjectTypeDataMatrixCode, nil];
    
    _output.metadataObjectTypes = _output.availableMetadataObjectTypes;
    
    // Preview
    _preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame = self.frame;
    [self.layer insertSublayer:self.preview atIndex:0];
    
    // Start
    [_session startRunning];
}

- (void)restartCamera
{
    if (nil != _session)
    {
        [_session startRunning];
    }
}

//#pragma mark button click
//- (void)brightnessBtnClick:(id)sender
//{
//    UIButton *button = (UIButton*)sender;
//    
//    if (popView.hidden)
//    {
//        [button setBackgroundImage:[UIImage imageNamed:@"Ok"] forState:UIControlStateNormal];
//    }
//    else
//    {
//        [button setBackgroundImage:[UIImage imageNamed:@"brightness"] forState:UIControlStateNormal];
//    }
//    
//    popView.hidden = !popView.hidden;
//    
//}
//
//- (void)closeBtnClick
//{
//    
//}
//
//- (void)cameraChangeClick:(id)sender
//{
//    UIButton *button = (UIButton*)sender;
//    
//    if (10001 == button.tag)
//    {
//        [brightBtn setImage:[UIImage imageNamed:@"brightness"] forState:UIControlStateNormal];
//        [contrastBtn setImage:[UIImage imageNamed:@"disable"] forState:UIControlStateNormal];
//        [label setText:@"brightness"];
//    }
//    else
//    {
//        [brightBtn setImage:[UIImage imageNamed:@"disable"] forState:UIControlStateNormal];
//        [contrastBtn setImage:[UIImage imageNamed:@"contrast"] forState:UIControlStateNormal];
//        [label setText:@"contrast"];
//    }
//}
//
//- (void)updateValue:(id)sender
//{
//    
//}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    [_session stopRunning];
    

    if (self.delegate && [self.delegate respondsToSelector:@selector(scanQRDidFinish:)])
    {
        [self.delegate scanQRDidFinish:stringValue];
    }
}

@end
