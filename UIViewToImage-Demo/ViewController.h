//
//  ViewController.h
//  UIViewToImage-Demo
//
//  Created by Jakey on 15/9/8.
//  Copyright © 2015年 www.skyfox.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIGestureRecognizerDelegate>
{
    CGAffineTransform rotationT;
    CGFloat _lastScale;
    CGFloat _lastRotation;

}
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIImageView *showImageView;
- (IBAction)captureTouched:(id)sender;
@end

