//
//  DucklingView.m
//  InvertedDuckling
//
//  Created by donbe on 2020/4/26.
//  Copyright © 2020 donbe. All rights reserved.
//

#import "DucklingView.h"

static CGFloat interval_line = 0;// 上下两行的间距
static CGFloat scaleFactor = 1.3;// 转场动画的放大缩小比例

@interface DucklingView()

@end


@implementation DucklingView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


-(void)drawRect:(CGRect)rect{

    // 移动原点到正中间
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), self.frame.size.width/2, self.frame.size.height/2);
    
    NSArray <DucklingModel *>*items = [self data];
    CGRect frame = CGRectZero;
    
    float totalScale = 1;

    for(int i=0;i<[items count];i++){
        
        if (i>0) {
            frame = [self drawItem:items[i]  preItem:items[i-1] preFrame:frame index:i tstionScale:self.clock totalScale:totalScale];
        }else{
            frame = [self drawItem:items[i]  preItem:nil preFrame:frame index:i tstionScale:self.clock totalScale:totalScale];
        }
        
        // 计算累加的缩放比例
        NSInteger animation = items[i].transitionAnimation;
        if (i>0) {
            if (animation==3) {
                totalScale *= scaleFactor;
            }else if (animation==4) {
                totalScale /= scaleFactor;
            }
        }else{
            if (animation==3) {
                totalScale = totalScale + (scaleFactor-1)*self.clock;
            }else if (animation==4) {
                totalScale = totalScale - (scaleFactor-1)*self.clock;
            }
        }
    }
}

#pragma mark - 主要的绘图函数

// 绘制一帧中的某一行
-(CGRect )drawItem:(DucklingModel *)item         // 当前行属性
           preItem:(DucklingModel *)preItem      // 前一行字的属性，这一行影响了当前行的位置
          preFrame:(CGRect)preFrame             // 前一行字的frame
             index:(NSInteger)index             // 当前第几行字
         tstionScale:(float)tstionScale         // 处于转场百分比,值 0-1 之间
        totalScale:(float)totalScale            // 累加缩放
{
    
    NSString *text = item.text;
    NSString *color = item.color;
    
    // 预估字体大小
    CGFloat fontSize = [self estimateFontSize:text];
    fontSize *= totalScale; // 计算累加缩放
    
    // 终态计算
    NSDictionary* stringAttrs = @{
        NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
        NSForegroundColorAttributeName : [UIColor colorFromHexAlphaString:color]
    };
    NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:text attributes:stringAttrs];
    CGRect rect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
    attributes:stringAttrs
       context:nil];
    
    
    // 处理受上一行的转场动画影响到当前行
    NSInteger preAnimation = preItem.transitionAnimation;
    // 首行特殊处理
    if (index == 0) preAnimation = item.transitionAnimation;
    
    switch (preAnimation) {
        case 1:
        case 2: {
            if (index == 0){
                // 旋转第一行
                rect = [self rotateFirstLine:attrStr
                                       color:color
                                    fontSize:fontSize
                                preAnimation:preAnimation
                                    preFrame:preFrame
                                        rect:rect
                                 stringAttrs:stringAttrs
                                        text:text
                                 tstionScale:tstionScale];
            }else if(index == 1){ // 第一行字也需要处理旋转
                // 旋转第二行
                rect = [self rotateSecondLine:attrStr preAnimation:preAnimation preFrame:preFrame rect:rect tstionScale:tstionScale];
            }else{
                // 旋转其他行
                rect = [self rotateOtherLine:attrStr preAnimation:preAnimation preFrame:preFrame rect:rect];
            }
            
            return rect;
        }
            break;
          
        case 3: // 缩放转场
        case 4:{
            if (index == 0) {
                
                // 缩放第一行
                rect = [self scaleFirstLine:attrStr color:color fontSize:fontSize preFrame:preFrame rect:rect stringAttrs:stringAttrs text:text tstionScale:tstionScale];
                
            }else{
                // 计算顶点坐标
                rect.origin.x = -rect.size.width/2;
                rect.origin.y = preFrame.origin.y - interval_line - rect.size.height;
                 
                // 开始写字
                [self drawText:attrStr rect:rect];
                
            }
            return rect;
        }
            
        default: {// 没有任何转场动画，不放大，不缩小，不旋转
            
            // 计算顶点坐标
            rect.origin.x = -rect.size.width/2;
            rect.origin.y = preFrame.origin.y - interval_line - rect.size.height;
             
            // 开始写字
            [self drawText:attrStr rect:rect];
            return rect;
        }
            break;
    }
}


// 旋转第一行
- (CGRect)rotateFirstLine:(NSAttributedString *)attrStr color:(NSString *)color fontSize:(CGFloat)fontSize preAnimation:(NSInteger)preAnimation preFrame:(const CGRect )preFrame rect:(CGRect)rect stringAttrs:(NSDictionary *)stringAttrs text:(NSString *)text tstionScale:(float)tstionScale {
    
    // 计算透明度的中间态
    stringAttrs = @{
        NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
        NSForegroundColorAttributeName : [[UIColor colorFromHexAlphaString:color] colorWithAlphaComponent:tstionScale]
    };
    attrStr = [[NSAttributedString alloc] initWithString:text attributes:stringAttrs];
    
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
    rect.origin.y = preFrame.origin.y - interval_line - rect.size.height;
    
    // 开始写字
    [self drawText:attrStr rect:rect];
    
    // 反操作，坐标系转回来，移回来，才能正确的画下一行
    CGContextRotateCTM (UIGraphicsGetCurrentContext(), -angle);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(),-newOriginPoint.x,-newOriginPoint.y);
    
    return rect;
}

// 旋转第二行
- (CGRect)rotateSecondLine:(NSAttributedString *)attrStr preAnimation:(NSInteger)preAnimation preFrame:(const CGRect )preFrame rect:(CGRect )rect tstionScale:(float)tstionScale {
    
    // 计算原点最终的点和字角度旋转
    CGPoint newOriginPoint;
    float  angle;
    
    if (preAnimation == 1) { // 左旋
        // 旋转弧度
        angle = -M_PI_2;
        
        // 原点坐标
        newOriginPoint.x = preFrame.origin.x - interval_line - rect.size.height/2;
        newOriginPoint.y = preFrame.origin.y + preFrame.size.height - rect.size.width/2;
        
    }else{// 右旋
        // 旋转弧度
        angle = M_PI_2;
        
        // 原点坐标
        newOriginPoint.x = preFrame.origin.x + preFrame.size.width + interval_line+rect.size.height/2;
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
    rect.origin.y = - interval_line - rect.size.height;
    
    // 开始写字
    [self drawText:attrStr rect:rect];
    
    return rect;
}


// 旋转第三行以及以上
- (CGRect)rotateOtherLine:(NSAttributedString *)attrStr preAnimation:(NSInteger)preAnimation preFrame:(const CGRect )preFrame rect:(CGRect )rect {
    
    // 计算原点最终的点和字角度旋转
    CGPoint newOriginPoint;
    float  angle;
    
    if (preAnimation == 1) { // 左旋
        
        // 旋转弧度
        angle = -M_PI_2;
        
        // 原点坐标
        newOriginPoint.x = preFrame.origin.x - interval_line ;
        newOriginPoint.y = preFrame.origin.y + preFrame.size.height - rect.size.width/2;
        
    }else{// 右旋
        
        // 旋转弧度
        angle = M_PI_2;
        
        // 原点坐标
        newOriginPoint.x = preFrame.size.width/2 + interval_line;
        newOriginPoint.y = preFrame.origin.y + preFrame.size.height - rect.size.width/2;
    }
    
    
    // 坐标系的移动和旋转
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(),newOriginPoint.x,newOriginPoint.y);
    CGContextRotateCTM (UIGraphicsGetCurrentContext(), angle);
    
    // 计算顶点坐标
    rect.origin.x = -rect.size.width/2;
    rect.origin.y = - rect.size.height;
    
    // 开始写字
    [self drawText:attrStr rect:rect];
    
    return rect;
}

// 缩放第一行
- (CGRect)scaleFirstLine:(NSAttributedString *)attrStr color:(NSString *)color fontSize:(CGFloat )fontSize preFrame:(const CGRect )preFrame rect:(CGRect )rect stringAttrs:(NSDictionary *)stringAttrs text:(NSString *)text tstionScale:(float)tstionScale {
    
    // 重新计算首行中间态
    fontSize *= tstionScale;
    stringAttrs = @{
        NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
        NSForegroundColorAttributeName : [UIColor colorFromHexAlphaString:color]
    };
    attrStr = [[NSAttributedString alloc] initWithString:text attributes:stringAttrs];
    rect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                            attributes:stringAttrs
                               context:nil];
    
    
    // 计算顶点坐标
    rect.origin.x = -rect.size.width/2;
    rect.origin.y = preFrame.origin.y - rect.size.height;
    
    // 开始写字
    [self drawText:attrStr rect:rect];
    
    return rect;
}


#pragma mark -




#pragma mark - help
/// 按照10号字体来预估，应该展示的字号，预估宽度为view的宽度-100
/// @param text 需要预估的文本
- (CGFloat)estimateFontSize:(NSString *)text {
    CGRect tempRect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:10] }
                                         context:nil];
    CGFloat fontSize = floor(10 * ((self.frame.size.width - 150) / tempRect.size.width));
    return fontSize;
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

@end
