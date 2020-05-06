//
//  DucklingView.m
//  InvertedDuckling
//
//  Created by donbe on 2020/4/26.
//  Copyright © 2020 donbe. All rights reserved.
//

#import "DucklingView.h"


static NSString *defaultFont = @"PingFangSC-Regular";

/// 利用贝塞尔曲线做弹簧动画
/// 参考网站：
/// http://www.flong.com/texts/code/shapers_bez/
/// https://cubic-bezier.com/
/// @param x 输入值x
/// @param a 控制点1 x坐标
/// @param b 控制点1 y坐标
/// @param c 控制点2 x坐标
/// @param d 控制点2 y坐标
float cubicBezier (float x, float a, float b, float c, float d);


@interface DucklingView()

// 真正需要绘制的数据集
@property(nonatomic,strong)NSArray <DucklingModel *> *drawDatas;

// 动画的中间过程值
@property(nonatomic)float percent;

@end


@implementation DucklingView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        // 设置缩放因子默认值
        self.scaleFactor = 1.5;
        
        // 设置最大宽度间隙默认值
        self.padding = 150;
        
        // 设置默认绘制多少条文字
        self.count = 12;
        
        // 设置默认最大字号
        self.maxFontSize = 40;
        
        // 设置默认字体
        self.font = defaultFont;
        
    }
    return self;
}


-(void)drawRect:(CGRect)rect{

    // 移动原点到正中间
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), self.frame.size.width/2, self.frame.size.height/2 + self.originOffsety);
    
    NSArray <DucklingModel *>*items = self.drawDatas;
    CGRect frame = CGRectZero;
    
    float totalScale = 1;

    
    for(int i=0;i<[items count];i++){
        
        if (i>0) {
            frame = [self drawItem:items[i]  preItem:items[i-1] preFrame:frame index:i tstionScale:self.percent totalScale:totalScale];
        }else{
            frame = [self drawItem:items[i]  preItem:nil preFrame:frame index:i tstionScale:self.percent totalScale:totalScale];
        }
        
        // 计算累加的缩放比例
        DMTransitionType animation = items[i].transitionType;
        if (i>0) {
            if (animation == DMTransitionTypeZoomIn) {
                totalScale *= self.scaleFactor;
            }else if (animation == DMTransitionTypeZoomOut) {
                totalScale /= self.scaleFactor;
            }
        }else{// 第一行
            if (animation == DMTransitionTypeZoomIn) {
                totalScale *= self.scaleFactor;
            }else if (animation == DMTransitionTypeZoomOut) {
                totalScale /= self.scaleFactor;
            }
            totalScale = 1 + (totalScale - 1) * self.percent;
        }
    }
}

#pragma mark - 主要的绘图函数

/// 绘制一帧中的某一行
/// @param item                              当前行属性
/// @param preItem                       前一行字的属性，这一行影响了当前行的位置
/// @param preFrame                     前一行字的frame
/// @param index                            当前第几行字
/// @param tstionScale              处于转场百分比,值, 介于0-1 之间
/// @param totalScale                累加缩放
/// @return                 返回最终确定的本行字的frame
-(CGRect )drawItem:(DucklingModel *)item
           preItem:(DucklingModel *)preItem
          preFrame:(CGRect)preFrame
             index:(NSInteger)index
         tstionScale:(float)tstionScale
        totalScale:(float)totalScale
{
    
    NSString *text = item.text;
    NSString *color = item.color;
    if (!item.font) {
        item.font = self.font;
    }
    

    // 检查字体是否存在
    UIFont *f = [UIFont fontWithName:item.font size:10];
    if (f==nil) item.font = defaultFont;
    
    // 预估字体大小
    CGFloat fontSize = [self estimateFontSize:text font:item.font];
    fontSize *= totalScale; // 计算累加缩放
    
    // 终态计算
    NSDictionary* stringAttrs = @{
        NSFontAttributeName : [UIFont fontWithName:item.font size:fontSize],
        NSForegroundColorAttributeName : [UIColor colorFromHexAlphaString:color]
    };
    NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:text attributes:stringAttrs];
    CGRect rect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
    attributes:stringAttrs
       context:nil];
    
    
    // 处理受上一行的转场动画影响到当前行
    DMTransitionType preAnimation = preItem.transitionType;
    // 首行特殊处理
    if (index == 0) preAnimation = item.transitionType;
    
    switch (preAnimation) {
        case DMTransitionTypeRotateLeft:
        case DMTransitionTypeRotateRight: {
            if (index == 0){
                // 旋转第一行
                rect = [self rotateFirstLine:text
                                       color:color
                                        font:item.font
                                    fontSize:fontSize
                                preAnimation:preAnimation
                                    preFrame:preFrame
                                        rect:rect
                                 tstionScale:tstionScale];
            }else if(index == 1){ // 第一行字也需要处理旋转
                // 旋转第二行
                rect = [self rotateOtherLine:attrStr preAnimation:preAnimation preFrame:preFrame rect:rect tstionScale:tstionScale];
            }else{
                // 旋转其他行
                rect = [self rotateOtherLine:attrStr preAnimation:preAnimation preFrame:preFrame rect:rect tstionScale:1];
            }
            
            return rect;
        }
            break;
          
        case DMTransitionTypeZoomIn: // 缩放转场
        case DMTransitionTypeZoomOut:{
            if (index == 0) {
                
                // 缩放第一行
                rect = [self scaleFirstLine:text color:color font:item.font fontSize:fontSize preFrame:preFrame tstionScale:tstionScale];
                
            }else{
                // 计算顶点坐标
                rect.origin.x = -rect.size.width/2;
                rect.origin.y = preFrame.origin.y - self.lineInterval - rect.size.height;
                 
                // 开始写字
                [self drawText:attrStr rect:rect];
                
            }
            return rect;
        }
            
        default: {// 没有任何转场动画，不放大，不缩小，不旋转
            
            // 计算顶点坐标
            rect.origin.x = -rect.size.width/2;
            rect.origin.y = preFrame.origin.y - self.lineInterval - rect.size.height;
             
            // 开始写字
            [self drawText:attrStr rect:rect];
            return rect;
        }
            break;
    }
}


/// 旋转第一行，旋转是通过左上角或者右上角进行旋转
/// @param color                         字的颜色
/// @param fontSize                   字体大小
/// @param preAnimation          前一行的旋转类型，1左旋，2右旋
/// @param preFrame                   前一行字的frame
/// @param rect                            当前行字的frame
/// @param text                            当前行文本
/// @param tstionScale            旋转的中间状态百分比
/// @return                返回最终确定的本行字的frame
- (CGRect)rotateFirstLine:(NSString *)text color:(NSString *)color font:(NSString *)font fontSize:(CGFloat)fontSize preAnimation:(NSInteger)preAnimation preFrame:(const CGRect )preFrame rect:(CGRect)rect tstionScale:(float)tstionScale {
    
    // 计算透明度的中间态
    NSDictionary *stringAttrs = @{
        NSFontAttributeName : [UIFont fontWithName:font size:fontSize],
        NSForegroundColorAttributeName : [[UIColor colorFromHexAlphaString:color] colorWithAlphaComponent:tstionScale]
    };
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text attributes:stringAttrs];
    
    float angle;
    CGPoint newOriginPoint;
    if (preAnimation == 1) { // 左旋
        
        // 旋转弧度
        angle = M_PI_2;
        
        // 计算当前所需旋转弧度
        angle *= 1-tstionScale;
        
        // 左上角坐标
        CGPoint ulp = CGPointMake(-rect.size.width/2, -rect.size.height);
        
        // 计算以字的左上角为原点对坐标轴旋转后的坐标
        newOriginPoint = [DucklingView rotatePoint:CGPointZero basePoint:ulp angle:angle];
    }else{ // 右旋
        
        // 旋转弧度
        angle = -M_PI_2;
        
        // 计算当前所需旋转弧度
        angle *= 1-tstionScale;
        
        // 右上角坐标
        CGPoint urp = CGPointMake(rect.size.width/2, -rect.size.height);
        
        // 计算以字的右上角为原点对坐标轴旋转后的坐标
        newOriginPoint = [DucklingView rotatePoint:CGPointZero basePoint:urp angle:angle];
    }
    
    // 坐标系移动+旋转
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(),newOriginPoint.x,newOriginPoint.y);
    CGContextRotateCTM (UIGraphicsGetCurrentContext(), angle);
    
    // 计算顶点坐标
    rect.origin.x = -rect.size.width/2;
    rect.origin.y = preFrame.origin.y - self.lineInterval - rect.size.height;
    
    // 开始写字
    [self drawText:attrStr rect:rect];
    
    // 反操作，坐标系转回来，移回来，才能正确的画下一行
    CGContextRotateCTM (UIGraphicsGetCurrentContext(), -angle);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(),-newOriginPoint.x,-newOriginPoint.y);
    
    return rect;
}


/// 旋转其他行，并不围绕着某个点旋转，单纯的移动原点来实现
/// @param attrStr                    旋转的字
/// @param preAnimation         左旋还是右旋 1左2右
/// @param preFrame                 上一行字的frame
/// @param rect                          本行字的frame
/// @param tstionScale          旋转的中间状态百分比
/// @return                返回最终确定的本行字的frame
- (CGRect)rotateOtherLine:(NSAttributedString *)attrStr preAnimation:(NSInteger)preAnimation preFrame:(const CGRect )preFrame rect:(CGRect )rect tstionScale:(float)tstionScale {
    
    // 计算原点最终的点和字角度旋转
    CGPoint newOriginPoint;
    float  angle;
    
    if (preAnimation == 1) { // 左旋
        // 旋转弧度
        angle = -M_PI_2;
        
        // 原点坐标
        newOriginPoint.x = preFrame.origin.x - self.lineInterval;
        newOriginPoint.y = preFrame.origin.y + preFrame.size.height - rect.size.width/2;
        
    }else{// 右旋
        // 旋转弧度
        angle = M_PI_2;
        
        // 原点坐标
        newOriginPoint.x = preFrame.size.width/2 + self.lineInterval;
        newOriginPoint.y = preFrame.origin.y + preFrame.size.height - rect.size.width/2;
    }
    
    // 计算中间态
    newOriginPoint.x *= tstionScale;
    newOriginPoint.y *= tstionScale;
    angle *= tstionScale;
    
    // 坐标系的移动和旋转
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(),newOriginPoint.x,newOriginPoint.y);
    CGContextRotateCTM (UIGraphicsGetCurrentContext(), angle);
    
    // 计算顶点坐标
    rect.origin.x = -rect.size.width/2;
    rect.origin.y = - self.lineInterval - rect.size.height;
    
    // 开始写字
    [self drawText:attrStr rect:rect];
    
    return rect;
}




/// 缩放第一行
/// @param text                      缩放的文字
/// @param color                    颜色
/// @param fontSize             字体
/// @param preFrame             前一行frame
/// @param tstionScale      旋转的中间状态百分比
/// @return              返回最终确定的本行字的frame
- (CGRect)scaleFirstLine:(NSString *)text color:(NSString *)color font:(NSString *)font fontSize:(CGFloat )fontSize preFrame:(const CGRect )preFrame tstionScale:(float)tstionScale {
    
    
    //计算弹簧效果中间态
    float easeFontSize = fontSize * [DucklingView cubicBezier:tstionScale];
    NSDictionary *stringAttrs = @{
        NSFontAttributeName : [UIFont fontWithName:font size:easeFontSize],
        NSForegroundColorAttributeName : [UIColor colorFromHexAlphaString:color]
    };
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text attributes:stringAttrs];
    CGRect rect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                            attributes:stringAttrs
                               context:nil];
    // 计算顶点坐标
    rect.origin.x = -rect.size.width/2;
    rect.origin.y = preFrame.origin.y - rect.size.height;
    
    // 开始写字
    [self drawText:attrStr rect:rect];
    
    
    // 重新计算没有弹簧效果的首行中间态,给下一行使用
    fontSize = fontSize * MIN([DucklingView cubicBezier:tstionScale], 1);
    stringAttrs = @{
        NSFontAttributeName : [UIFont fontWithName:font size:fontSize]
    };
    attrStr = [[NSAttributedString alloc] initWithString:text attributes:stringAttrs];
    rect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                            attributes:stringAttrs
                               context:nil];
    
    // 计算顶点坐标
    rect.origin.x = -rect.size.width/2;
    rect.origin.y = preFrame.origin.y - rect.size.height;
    
    return rect;
}


#pragma mark -
-(void)setCursor:(NSTimeInterval)cursor{
    _cursor = cursor;
    
    if ([self.data count] == 0) {
        return;
    }
    
    // 符合条件的数据放入temp中
    NSMutableArray *temp = [NSMutableArray new];
    for (int i=0; i<[self.data count]; i++) {
        DucklingModel *model = self.data[i];
        if (model.startTime <= (int)(cursor * 1000)) {
            [temp addObject:model];
        }
    }
    
    if ([temp count] == 0) {
        return;
    }
    
    //翻转数组
    temp = [[[temp reverseObjectEnumerator] allObjects] mutableCopy];
    
    // 最多取12条
    NSRange range = NSMakeRange(0, MIN([temp count],self.count));
    self.drawDatas = [temp subarrayWithRange:range];
    
    DucklingModel *first = [self.drawDatas firstObject];
    self.percent = MIN(1, MAX((cursor*1000 - first.startTime), 0) / first.duration);

    [self setNeedsDisplay];
}



#pragma mark - help
/// 按照10号字体来预估，应该展示的字号，预估宽度为view的宽度 - self.padding
/// @param text 需要预估的文本
- (CGFloat)estimateFontSize:(NSString *)text font:(NSString *)font{
    
    CGRect tempRect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:@{ NSFontAttributeName : [UIFont fontWithName:font size:10] }
                                         context:nil];
    CGFloat fontSize = floor(10 * ((self.frame.size.width - self.padding) / tempRect.size.width));
    return MIN(fontSize, self.maxFontSize);
}


/// 这个方法提出来，主要是为了加字的背景，方便调试
-(void)drawText:(NSAttributedString *)text rect:(CGRect)rect{
//    [DucklingView drawRectangle:rect];
    [text drawAtPoint:CGPointMake(rect.origin.x, rect.origin.y)];
}


/// 计算 p1 围绕 p2 旋转 angle个弧度后的新坐标
/// @param p1 旋转点
/// @param p2 中心点
/// @param angle 弧度 , 正数为逆时针，负数为顺时针
/// @return 移动后的新坐标
+(CGPoint)rotatePoint:(CGPoint)p1 basePoint:(CGPoint)p2 angle:(CGFloat)angle{
    
    // 计算 p1 - p2
    CGPoint ptemp = CGPointMake(p1.x-p2.x, p1.y-p2.y);
    
    float destx = ptemp.x *cos(angle) - ptemp.y*sin(angle);
    float desty = ptemp.y*cos(angle) + ptemp.x*sin(angle);
    
    // 计算 destination + p2
    return CGPointMake(destx+p2.x, desty+p2.y);
}


/// 画一个矩形
+ (void)drawRectangle:(CGRect)rect
{

//    CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(),
//                             (arc4random() % 100) / 100.f,
//                             (arc4random() % 100) / 100.f,
//                             (arc4random() % 100) / 100.f,
//                             1.0);
    
    CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(),0.8,0.8,0.8,1.0);
    
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    
    //CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 0.5);
    //CGContextStrokeRect(UIGraphicsGetCurrentContext(), rect);    //this will draw the border

}

#pragma mark - Easing functions
+(float)backEaseOut:(float) p
{
    float f = (1 - p);
    return 1 - (f * f * f - f * sin(f * M_PI));
}


+(float)bounceEaseOut:(float) p
{
    if(p < 4/11.0)
    {
        return (121 * p * p)/16.0;
    }
    else if(p < 8/11.0)
    {
        return (363/40.0 * p * p) - (99/10.0 * p) + 17/5.0;
    }
    else if(p < 9/10.0)
    {
        return (4356/361.0 * p * p) - (35442/1805.0 * p) + 16061/1805.0;
    }
    else
    {
        return (54/5.0 * p * p) - (513/25.0 * p) + 268/25.0;
    }
}

+(float)elasticEaseOut:(float) p
{
    return sin(-13 * M_PI_2 * (p + 1)) * pow(2, -10 * p) + 1;
}

+(float)cubicBezier:(float) p
{
    return cubicBezier(p,0.24,0.24,0.8,1.4);
}

@end


#pragma mark - Cubic Bezier
float slopeFromT (float t, float A, float B, float C){
  float dtdx = 1.0/(3.0*A*t*t + 2.0*B*t + C);
  return dtdx;
}


float xFromT (float t, float A, float B, float C, float D){
  float x = A*(t*t*t) + B*(t*t) + C*t + D;
  return x;
}

float yFromT (float t, float E, float F, float G, float H){
  float y = E*(t*t*t) + F*(t*t) + G*t + H;
  return y;
}

float cubicBezier (float x, float a, float b, float c, float d){

  float y0a = 0.00; // initial y
  float x0a = 0.00; // initial x
  float y1a = b;    // 1st influence y
  float x1a = a;    // 1st influence x
  float y2a = d;    // 2nd influence y
  float x2a = c;    // 2nd influence x
  float y3a = 1.00; // final y
  float x3a = 1.00; // final x

  float A =   x3a - 3*x2a + 3*x1a - x0a;
  float B = 3*x2a - 6*x1a + 3*x0a;
  float C = 3*x1a - 3*x0a;
  float D =   x0a;

  float E =   y3a - 3*y2a + 3*y1a - y0a;
  float F = 3*y2a - 6*y1a + 3*y0a;
  float G = 3*y1a - 3*y0a;
  float H =   y0a;

  // Solve for t given x (using Newton-Raphelson), then solve for y given t.
  // Assume for the first guess that t = x.
  float currentt = x;
  int nRefinementIterations = 5;
  for (int i=0; i < nRefinementIterations; i++){
    float currentx = xFromT (currentt, A,B,C,D);
    float currentslope = slopeFromT (currentt, A,B,C);
    currentt -= (currentx - x)*(currentslope);
    currentt = MAX(0, MIN(1, currentt));
  }

  float y = yFromT (currentt,  E,F,G,H);
  return y;
}

