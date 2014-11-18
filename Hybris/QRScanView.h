//
//  QRScanView.h
//  QRScanDemo
//
//  Created by Accenture on 14-11-5.
//  Copyright (c) 2014年 Accenture. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol QRScanViewDelegate <NSObject>

@required
- (void)scanQRDidFinish:(NSString *)qrcode;

@end

@interface QRScanView : UIView<AVCaptureMetadataOutputObjectsDelegate>

@property (assign, nonatomic) id<QRScanViewDelegate> delegate;
@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureDeviceInput *input;
@property (strong, nonatomic) AVCaptureMetadataOutput *output;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *preview;

- (id)initWithFrame:(CGRect)frame;
- (void)setupCamera;
- (void)restartCamera;

@end
