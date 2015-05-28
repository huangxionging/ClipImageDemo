//
//  ViewController.m
//  DashLine
//
//  Created by huangxiong on 15/5/19.
//  Copyright (c) 2015年 New_Life. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) NSMutableArray *pointArray;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, assign) CGMutablePathRef path;
@property (weak, nonatomic) IBOutlet UIImageView *lineImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _pointArray = [NSMutableArray array];
    
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.frame = _lineImage.bounds;
    [_lineImage.layer addSublayer: _shapeLayer];
    _path = CGPathCreateMutable();
    
    _shapeLayer.lineWidth = 1;
    
    
    
    _shapeLayer.strokeColor = [UIColor purpleColor].CGColor;
    _shapeLayer.fillColor = [UIColor clearColor].CGColor;
    

}


- (UIImage *) clipImageRectWith: (NSString *)fileName andRect: (CGRect) rect {
    UIImage *image = [UIImage imageNamed: fileName];
    
    CGColorSpaceRef colorRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, image.size.width * 4, colorRef, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGContextClipToRect(ctx, rect);
    
    // 绘制图片
    CGContextDrawImage(ctx, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    
    UIImage *imageDst = [UIImage imageWithCGImage: imageRef scale: [UIScreen mainScreen].scale orientation: UIImageOrientationUp];
    
    return imageDst;
}

- (UIImage *) clipImageWith: (NSString *)fileName andPoints: (NSArray *)pointArray {
    
    UIImage *image = [UIImage imageNamed: fileName];
    CGColorSpaceRef colorRef = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef ctx =  CGBitmapContextCreate(nil, _lineImage.frame.size.width, _lineImage.frame.size.height, 8, _lineImage.frame.size.width * 4, colorRef, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    
    
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPoint start = CGPointZero;
    
    for (NSInteger index = 0; index < pointArray.count; ++index) {
        NSAssert([pointArray[index] respondsToSelector: @selector(CGPointValue)], @"不能获得点");
        
        CGPoint point = [pointArray[index] CGPointValue];
        
        if (index == 0) {
            CGPathMoveToPoint(path, NULL, point.x,_lineImage.frame.size.height - point.y);
            start = point;
        }
        else {
            CGPathAddLineToPoint(path, NULL, point.x,_lineImage.frame.size.height - point.y);
        }
    }
    
    //    CGContextTranslateCTM(ctx, 0, _lineImage.frame.size.height);
    //    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGPathAddLineToPoint(path, NULL, start.x, _lineImage.frame.size.height - start.y);
    CGPathCloseSubpath(path);
    CGContextAddPath(ctx, path);
    CGContextClip(ctx);
    CGPathRelease(path);
    
    CGContextDrawImage(ctx, CGRectMake(0, 0, _lineImage.frame.size.width, _lineImage.frame.size.height), image.CGImage);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    
    //    UIImage *imageDst = [UIImage imageWithCGImage: imageRef scale: [UIScreen mainScreen].scale orientation: UIImageOrientationUp];
    
    UIImage *imageDst = [UIImage imageWithCGImage: imageRef];
    
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorRef);
    
    return imageDst;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView: _lineImage];
    
    //  CGPathAddEllipseInRect(_path, NULL, CGRectMake(point.x -1, point.y -1, 2, 2));
    NSValue *value = [NSValue valueWithCGPoint: point];
    [_pointArray addObject:value];
    NSLog(@"%@", NSStringFromCGPoint(point));
    [self drawLayer];
    
    //_shapeLayer.path = _path;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView: _lineImage];
    
    NSValue *value = [NSValue valueWithCGPoint: point];
    [_pointArray addObject:value];
    
    
    [self drawLayer];
}

- (void) drawLayer{
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    for (NSInteger index = 0; index < _pointArray.count; ++index) {
        NSAssert([_pointArray[index] respondsToSelector: @selector(CGPointValue)], @"不能获得点");
        
        CGPoint point = [_pointArray[index] CGPointValue];
        CGPoint start = CGPointZero;
        
        if (index == 0) {
            CGPathMoveToPoint(path, NULL, point.x, point.y);
            start = point;
        }
        else {
            CGPathAddLineToPoint(path, NULL, point.x, point.y);
        }
    }
    _shapeLayer.path = path;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _imageView.image = [self clipImageWith: @"user_back_03" andPoints: _pointArray];
    [_pointArray removeAllObjects];
}

@end
