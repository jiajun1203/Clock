//
//  ClockView.m
//  TestClock
//
//  Created by Mr.陈 on 2016/12/28.
//  Copyright © 2016年 Mr.陈. All rights reserved.
//

#import "ClockView.h"

#define OUTERRINGCOLOR [[UIColor blackColor] colorWithAlphaComponent:0.5f]  //外围圆环颜色
#define CALIBRATIONCOLOR [[UIColor grayColor] colorWithAlphaComponent:0.9f] //刻度颜色



#define ANGLE_TO_RADIAN(angle) ((angle) / 180.0 * M_PI)  //角度转弧度

@implementation ClockView
{
    float viewWidth;
    float viewHeight;
    float labRadius; //数字刻度 内部半径
    UIImageView *hourImgV;  //时钟指针
    UIImageView *minutesImgV; //分钟指针
    UIImageView *secondsImgV; //秒钟指针
    
    
    long secondsValue;
    long mintuesValue;
    long hourValue;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.3];
        viewWidth = frame.size.width;
        viewHeight = frame.size.height;
        
        [self paintingOutsideCircle];
        [self ClockDial];
        [self createPointer];
        
        NSDate *date = [NSDate date];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setLocale:locale];//24 小时制 自动转换为12小时制
        [formatter setDateFormat:@"hh:mm:ss"];
        NSString *time = [formatter stringFromDate:date];
        NSArray *timeArr = [time componentsSeparatedByString:@":"];
        
        
        secondsValue = [timeArr[2] intValue];
        mintuesValue = [timeArr[1] intValue]*60+secondsValue;
        hourValue = [timeArr[0] intValue]*60*60+mintuesValue;
        
        NSTimer *hourTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hourMethod) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:hourTimer forMode:UITrackingRunLoopMode];
    }
    return self;
}
- (void)hourMethod
{
    secondsValue++;
    mintuesValue++;
    hourValue ++;
    // 12  == 720  = 43200
    
    if (secondsValue == 60) {
        secondsValue = 0;
    }
    if (mintuesValue == 43200) {
        mintuesValue = 0;
    }
    if (hourValue == 43200 *12) {
        hourValue = 0;
    }
    
    CGAffineTransform secondEndAngle = CGAffineTransformMakeRotation(ANGLE_TO_RADIAN(270+6.0*secondsValue));
    CGAffineTransform mintuesEndAngle = CGAffineTransformMakeRotation(ANGLE_TO_RADIAN(270+(6/60.0)*mintuesValue));
    CGAffineTransform hourEndAngle = CGAffineTransformMakeRotation(ANGLE_TO_RADIAN(270+(30/3600.0)*hourValue));
    [UIView animateWithDuration:0.01 animations:^{
        secondsImgV.transform = secondEndAngle;
        minutesImgV.transform = mintuesEndAngle;
        hourImgV.transform = hourEndAngle;
    }];
}
- (void)createPointer //创建时钟指针
{
    CGPoint centerPoint = CGPointMake(viewWidth/2.0, viewHeight/2.0);
    
    hourImgV = [[UIImageView alloc]init];
    hourImgV.center = centerPoint;
    hourImgV.image = [UIImage imageNamed:@"pointer"];
    hourImgV.bounds = CGRectMake(0, 0, viewHeight/2.0-50, 15);
    hourImgV.layer.anchorPoint = CGPointMake(0, 0.5);
    [self addSubview:hourImgV];
    hourImgV.transform = CGAffineTransformMakeRotation(ANGLE_TO_RADIAN(270));
    
    minutesImgV = [[UIImageView alloc]init];
    minutesImgV.image = [UIImage imageNamed:@"pointer"];
    minutesImgV.center = centerPoint;
    minutesImgV.bounds = CGRectMake(0, 0, viewHeight/2.0-30, 10);
    minutesImgV.layer.anchorPoint = CGPointMake(0, 0.5);
    [self addSubview:minutesImgV];
    minutesImgV.transform = CGAffineTransformMakeRotation(ANGLE_TO_RADIAN(270));
    
    
    secondsImgV = [[UIImageView alloc]init];
    secondsImgV.image = [UIImage imageNamed:@"pointer"];
    secondsImgV.center = centerPoint;
    secondsImgV.bounds = CGRectMake(0, 0, viewHeight/2.0-15, 5);
    secondsImgV.layer.anchorPoint = CGPointMake(0, 0.5);
    [self addSubview:secondsImgV];
    secondsImgV.transform = CGAffineTransformMakeRotation(ANGLE_TO_RADIAN(270));
    
    UIImageView *centerImgV = [[UIImageView alloc]init];
    centerImgV.image = [UIImage imageNamed:@"000"];
    centerImgV.center = centerPoint;
    centerImgV.bounds = CGRectMake(0, 0, 20, 20);
    [self addSubview:centerImgV];
}
- (void)ClockDial //添加时间数字刻度
{
    float valueRadius = viewWidth/2.0-((viewWidth/2.0)*0.2);
    
    for (int i = 0; i <12 ; i++) {
        NSString *tickText = [NSString stringWithFormat:@"%d",i];
        UILabel * text      = [[UILabel alloc] init];
        text.center = [self getTextCenter:ANGLE_TO_RADIAN(-(90-i*30)) center:CGPointMake(viewWidth/2.0, viewHeight/2.0) radius:valueRadius];
        text.bounds = CGRectMake(0, 0, 30, 30);
        text.text          = tickText;
        text.font          = [UIFont systemFontOfSize:15];
        text.textColor     = [UIColor blackColor];
        text.textAlignment = NSTextAlignmentCenter;
        [self addSubview:text];
    }
}
//根据弧度计算 数字刻度中心店
-(CGPoint) getTextCenter :(float) angle center:(CGPoint)point radius:(float)rad
{
    CGFloat x = 0.0;
    CGFloat y = 0.0;
    x = point.x + cosf(angle) * rad;
    y = point.y + sinf(angle) * rad;
    return CGPointMake(x, y);
}
- (void)paintingOutsideCircle//画出最外层圆环
{
    UIBezierPath *path=[UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(viewWidth/2,viewHeight/2) radius:viewWidth/2.0 startAngle:0 endAngle:ANGLE_TO_RADIAN(360) clockwise:YES];
    CAShapeLayer *arcLayer=[CAShapeLayer layer];
    arcLayer.path=path.CGPath;//46,169,230
    arcLayer.fillColor=[UIColor clearColor].CGColor;
    arcLayer.strokeColor=OUTERRINGCOLOR.CGColor;
    arcLayer.lineWidth=3;
    arcLayer.lineCap = kCALineCapRound;
    arcLayer.frame=self.bounds;
    [self.layer addSublayer:arcLayer];
}




// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat minuteRadius = viewWidth * 0.5;
    CGFloat minutePerimeter = M_PI * (viewWidth-minuteRadius*0.1);
    CGFloat minuteWidth = minutePerimeter / 60;
    CGContextSetLineWidth(ctx, 8);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGFloat minuteLength[] = {2, minuteWidth - 2};
    CGContextSetLineDash(ctx, 0, minuteLength, 2);
    [CALIBRATIONCOLOR set];
    CGContextAddArc(ctx, minuteRadius, minuteRadius, minuteRadius-minuteRadius*0.05, 0, ANGLE_TO_RADIAN(360), 0);
    CGContextStrokePath(ctx);
    
    
    
    CGFloat hourRadius = viewWidth * 0.5;
    CGFloat hourPerimeter = M_PI * (viewWidth-hourRadius*0.1);
    CGFloat hourWidth = hourPerimeter / 12;
    CGContextSetLineWidth(ctx, 15);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGFloat hourLength[] = {3, hourWidth - 3};
    CGContextSetLineDash(ctx, 0, hourLength, 2);    [CALIBRATIONCOLOR set];
    CGContextAddArc(ctx, hourRadius, hourRadius, hourRadius-hourRadius*0.05f, 0, ANGLE_TO_RADIAN(360), 0);
    CGContextStrokePath(ctx);
    
    
}


@end
