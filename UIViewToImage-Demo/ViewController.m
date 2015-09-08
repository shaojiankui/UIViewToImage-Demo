//
//  ViewController.m
//  UIViewToImage-Demo
//
//  Created by Jakey on 15/9/8.
//  Copyright © 2015年 www.skyfox.org. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()

@end

@implementation ViewController
CGFloat DegreesToRadians3(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees3(CGFloat radians) {return radians * 180/M_PI;};

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIPinchGestureRecognizer *zoomGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomImageView:)];
    zoomGesture.delegate = self;
    [self.view addGestureRecognizer:zoomGesture];
    UIPanGestureRecognizer *moveGesture= [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragGestures:)];
    [self.view addGestureRecognizer:moveGesture];
    
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationImageView:)];
    [self.view addGestureRecognizer:rotationGesture];

    
     self.previewView.transform = CGAffineTransformMakeRotation(-DegreesToRadians3(30));
}

- (void)rotationImageView:(UIRotationGestureRecognizer*)gesture {
    //CGPoint location = [gesture locationInView:self];
    //gesture.view.center = CGPointMake(location.x, location.y);
    
    if ([gesture state] == UIGestureRecognizerStateEnded) {
        _lastRotation = 0;
        return;
    }
    CGAffineTransform currentTransform = self.previewView.transform;
    CGFloat rotation = 0.0 - (_lastRotation - gesture.rotation);
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, rotation);
    self.previewView.transform = newTransform;
    _lastRotation = gesture.rotation;
    
}
//缩放手势
- (void)zoomImageView:(UIPinchGestureRecognizer*)pinchGestureRecognizer {
    if([pinchGestureRecognizer state] == UIGestureRecognizerStateEnded) {
        _lastScale = 1.0;
        return;
    }
    
    CGFloat scale = 1.0 - (_lastScale - [(UIPinchGestureRecognizer*)pinchGestureRecognizer scale]);
    CGAffineTransform currentTransform = self.previewView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    
    self.previewView.transform =newTransform;
    _lastScale = [pinchGestureRecognizer scale];
    
}

//拖动手势
-(void)handleDragGestures:(UIPanGestureRecognizer*)dragSender{
    CGPoint point = [dragSender translationInView:self.view];
    self.previewView.center = CGPointMake(self.previewView.center.x + point.x, self.previewView.center.y + point.y);
    [dragSender setTranslation:CGPointMake(0, 0) inView:self.view];
}



- (IBAction)captureTouched:(id)sender {
    UIImage *image = [self screenshot:self.previewView limitWidth:1080];
    self.showImageView.image = image;
    NSLog(@"capture image.size%@",NSStringFromCGSize(image.size));
    UIImageWriteToSavedPhotosAlbum(image, nil, nil,nil);
    
    NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/image.png"];
    NSLog(@"path:\n%@",path);
    //[UIImagePNGRepresentation(image) writeToFile:path atomically:YES];

}


- (UIImage *)screenshot:(UIView *)aView limitWidth:(CGFloat)maxWidth{
    CGAffineTransform oldTransform = aView.transform;
    CGAffineTransform scaleTransform = CGAffineTransformIdentity;
    
//    if (!isnan(scale)) {
//        CGAffineTransform transformScale = CGAffineTransformMakeScale(scale, scale);
//        scaleTransform = CGAffineTransformConcat(oldTransform, transformScale);
//    }
    if (!isnan(maxWidth) && maxWidth>0) {
        CGFloat maxScale = maxWidth/CGRectGetWidth(aView.frame);
        CGAffineTransform transformScale = CGAffineTransformMakeScale(maxScale, maxScale);
        scaleTransform = CGAffineTransformConcat(oldTransform, transformScale);
    
    }
    if(!CGAffineTransformEqualToTransform(scaleTransform, CGAffineTransformIdentity)){
        aView.transform = scaleTransform;
    }
    
    CGRect actureFrame = aView.frame; //已经变换过后的frame
    CGRect actureBounds= aView.bounds;//CGRectApplyAffineTransform();
    
    //begin
    UIGraphicsBeginImageContextWithOptions(actureFrame.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    //    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1, -1);
    CGContextTranslateCTM(context,actureFrame.size.width/2, actureFrame.size.height/2);
    CGContextConcatCTM(context, aView.transform);
    CGPoint anchorPoint = aView.layer.anchorPoint;
    CGContextTranslateCTM(context,
                          -actureBounds.size.width * anchorPoint.x,
                          -actureBounds.size.height * anchorPoint.y);
    if([aView respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
    {
        [aView drawViewHierarchyInRect:aView.bounds afterScreenUpdates:NO];
    }
    else
    {
        [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //end
    aView.transform = oldTransform;
    
    return screenshot;
}


@end
