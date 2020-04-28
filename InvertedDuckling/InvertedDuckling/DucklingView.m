//
//  DucklingView.m
//  InvertedDuckling
//
//  Created by donbe on 2020/4/26.
//  Copyright © 2020 donbe. All rights reserved.
//

#import "DucklingView.h"


static CGFloat interval_x = 0;// 旋转后的横向间距
static CGFloat interval_y = 0;// 上下两行的间距

@interface DucklingView()

@property(nonatomic,strong)NSArray *testData;


@end


@implementation DucklingView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerFire) userInfo:nil repeats:YES];
    }
    return self;
}

-(void)timerFire{
    self.clock = self.clock + 0.01;
    self.clock = self.clock - floor(self.clock);
    
    [self setNeedsDisplay];
}



-(CGRect )drawItem:(NSDictionary *)item //当前行属性
           preItem:(NSDictionary *)preItem //前一行字的属性，这一行影响了当前行的位置
          preFrame:(CGRect)preFrame //前一行字的frame
             index:(NSInteger)index //当前第几行字
   tstionAnimation:(NSInteger)tstionAnimation //处于转场百分比,值 0-1 之间
         tstionScale:(float)tstionScale //处于转场百分比,值 0-1 之间
{
    
    // 转场动画
    if (index == 0) {
        tstionAnimation = [item[@"transition_animation"] intValue];
    }
    NSString *text = item[@"text"];
    NSString *color = item[@"color"];
    CGFloat fontSize = [self estimateFontSize:text];
    CGFloat tstionFontSize = fontSize *tstionScale; //转场中间态字体大小
    
    
    
    
    
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
    
    
    // 中间态计算
    NSDictionary* tstionStringAttrs = @{
        NSFontAttributeName : [UIFont systemFontOfSize:tstionFontSize],
        NSForegroundColorAttributeName : [UIColor colorFromHexAlphaString:color]
    };
    NSAttributedString* tstionAttrStr = [[NSAttributedString alloc] initWithString:text attributes:tstionStringAttrs];
    CGRect tstionRect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
    attributes:tstionStringAttrs
       context:nil];
    
    
    // 第一行和第二行字，需要处理旋转转场或缩放转场
    // 其他行只需要处理缩放转场
    
    
    switch (tstionAnimation) {
        // 旋转需要处理 第一行，第二行
        case 1://左旋
        case 2://右旋
        {
            if (index == 0){
                float angle;
                CGPoint newOriginPoint;
                if (tstionAnimation == 1) {
                    angle = M_PI_2;
                    
                    //计算当前所需旋转弧度
                    angle *= 1-tstionScale;
                    
                    // 左上角坐标
                    CGPoint ulp = CGPointMake(-rect.size.width/2, -rect.size.height);
                    
                    // 计算以字的左上角为原点对坐标轴旋转后的坐标
                    newOriginPoint = [DucklingView rotatePoint:CGPointZero basePoint:ulp angle:angle];
                }else{
                    angle = -M_PI_2;
                    
                    //计算当前所需旋转弧度
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
                rect.origin.y = preFrame.origin.y - interval_y - rect.size.height;
                 
                // 开始写字
                [attrStr drawAtPoint:CGPointMake(rect.origin.x, rect.origin.y)];
                
                // 反操作，坐标系转回来，移回来，才能正确的画下一行
                CGContextRotateCTM (UIGraphicsGetCurrentContext(), -angle);
                CGContextTranslateCTM(UIGraphicsGetCurrentContext(),-newOriginPoint.x,-newOriginPoint.y);
            
            }else if(index == 1){ // 第一行字也需要处理旋转
                
                // 计算原点最终的点和字角度旋转
                CGPoint newOriginPoint;
                float  angle;
                
                if (tstionAnimation == 1) { //左旋
                    newOriginPoint.x = preFrame.origin.x - interval_x - rect.size.height/2;
                    newOriginPoint.y = preFrame.origin.y + preFrame.size.height - rect.size.width/2;
                    angle = -M_PI_2;
                }else{//右旋
                    newOriginPoint.x = preFrame.origin.x + preFrame.size.width + interval_x+rect.size.height/2;
                    newOriginPoint.y = preFrame.origin.y + preFrame.size.height - rect.size.width/2;
                    angle = M_PI_2;
                }
                
                // 计算中间态
                newOriginPoint.x *= tstionScale;
                newOriginPoint.y *= tstionScale;
                angle *= tstionScale;
                
                //坐标系的移动和旋转
                CGContextTranslateCTM(UIGraphicsGetCurrentContext(),newOriginPoint.x,newOriginPoint.y);
                CGContextRotateCTM (UIGraphicsGetCurrentContext(), angle);
                
                // 计算顶点坐标
                rect.origin.x = -rect.size.width/2;
                rect.origin.y = - interval_y - rect.size.height;
                 
                // 开始写字
                [attrStr drawAtPoint:CGPointMake(rect.origin.x, rect.origin.y)];
            }else{
                //其他行不用处理这个状态
            }
            
            
        }
            break;
        case 3://放大
        case 4://缩小
        {
            // 计算顶点坐标
            rect.origin.x = -rect.size.width/2;
            rect.origin.y = preFrame.origin.y - interval_y - rect.size.height;
             
            // 开始写字
            [attrStr drawAtPoint:CGPointMake(rect.origin.x, rect.origin.y)];
        }
            break;
        default:
        {
            // 计算顶点坐标
            rect.origin.x = -rect.size.width/2;
            rect.origin.y = preFrame.origin.y - interval_y - rect.size.height;
             
            // 开始写字
            [attrStr drawAtPoint:CGPointMake(rect.origin.x, rect.origin.y)];
        }
            break;
    }
    
    return rect;
}

-(void)drawRect:(CGRect)rect{

    // 移动原点到正中间
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), self.frame.size.width/2, self.frame.size.height/2);
    
//    UIFont* font = [UIFont systemFontOfSize:14];
//    UIColor* textColor = [UIColor redColor];
//    NSDictionary* stringAttrs = @{ NSFontAttributeName : font, NSForegroundColorAttributeName : textColor };
//    [@"原点" drawAtPoint:CGPointMake(0, 0) withAttributes:stringAttrs];
    
    NSArray *items = [self testData];
    CGRect frame = CGRectZero;
    
    for(int i=0;i<[items count];i++){
        NSInteger tstionAnimation = [items[0][@"transition_animation"] intValue];

        if (i>0) {
            frame = [self drawItem:items[i]  preItem:items[i-1] preFrame:frame index:i tstionAnimation:tstionAnimation tstionScale:self.clock];
        }else{
            frame = [self drawItem:items[i]  preItem:nil preFrame:frame index:i tstionAnimation:tstionAnimation tstionScale:self.clock];
        }
        
    }

}
    


-(NSArray *)testData{
    
    if (_testData==nil) {
        NSString *fileName = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"json"];
        NSData *partyData = [[NSData alloc] initWithContentsOfFile:fileName];
        
        NSError *error;
        _testData = [NSJSONSerialization JSONObjectWithData:partyData
          options:0
            error:&error];
    }
    
    return _testData;
}

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


@end
