//
//  DucklingView.m
//  InvertedDuckling
//
//  Created by donbe on 2020/4/26.
//  Copyright © 2020 donbe. All rights reserved.
//

#import "DucklingView.h"


static CGFloat interval_x = 5;// 旋转后的横向间距
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
         headItem:(NSDictionary *)headItem //第一行字属性，这一行字会影响到转场动画
          preFrame:(CGRect)preFrame //前一行字的frame
             index:(NSInteger)index //当前第几行字
         timeScale:(float)timeScale //处于转场过渡的几分之几,值 0-1 之间
{
    
    NSString *text = item[@"text"];
    NSString *color = item[@"color"];
    NSInteger transitionAnimation = [item[@"transition_animation"] intValue];
    CGFloat fontSize = [self estimateFontSize:text];
    CGFloat traFontSize = fontSize *timeScale; //转场中间态字体大小
    
    
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
    NSDictionary* traStringAttrs = @{
        NSFontAttributeName : [UIFont systemFontOfSize:traFontSize],
        NSForegroundColorAttributeName : [UIColor colorFromHexAlphaString:color]
    };
    NSAttributedString* traAttrStr = [[NSAttributedString alloc] initWithString:text attributes:traStringAttrs];
    CGRect traRect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
    attributes:traStringAttrs
       context:nil];
    
    
    // 第一行和第二行字，需要处理旋转转场或缩放转场
    // 其他行只需要处理缩放转场
    
    
    switch (transitionAnimation) {
        case 1://左旋
        case 2://右旋
        {
            if (index == 0){
                float x, y, angle;
                if (transitionAnimation == 1) {
                    x = - rect.size.width/2;
                    y = rect.size.width/2 - rect.size.height;
                    angle = 90;
                    
                    // 以字的左上角进行旋转
                    CGFloat defangle = atan(rect.size.height/(rect.size.width/2));
                    angle = angle - defangle;
                    angle *= 1-timeScale;
                    CGPoint point = [DucklingView point:CGPointMake(rect.size.width/2, rect.size.height) angle:angle];
                    x = point.x - rect.size.width/2;
                    y = point.y - rect.size.height;
                }else{
                    x = rect.size.width/2;
                    y = rect.size.width/2 - rect.size.height;
                    angle = -90;
                    
                    // 以字的右上角进行旋转
                    CGFloat defangle = atan(rect.size.height/(-rect.size.width/2));
                    angle = angle + defangle;
                    angle *= 1-timeScale;
                    CGPoint point = [DucklingView point:CGPointMake(-rect.size.width/2, rect.size.height) angle:angle];
                    x = point.x + rect.size.width/2;
                    y = point.y - rect.size.height;
                }
                
                
                
                
                // 移动+旋转
                CGContextTranslateCTM(UIGraphicsGetCurrentContext(),x,y);
                CGContextRotateCTM (UIGraphicsGetCurrentContext(), angle * (M_PI / 180));
                
                // 计算顶点坐标
                rect.origin.x = -rect.size.width/2;
                rect.origin.y = preFrame.origin.y - interval_y - rect.size.height;
                 
                // 开始写字
                [attrStr drawAtPoint:CGPointMake(rect.origin.x, rect.origin.y)];
                
                // 反操作，转回来，移回来，才能正确的画下一行
                CGContextRotateCTM (UIGraphicsGetCurrentContext(), -angle * (M_PI / 180));
                CGContextTranslateCTM(UIGraphicsGetCurrentContext(),-x,-y);
            }else{
                float x, y, angle;
                if (transitionAnimation == 1) {
                    x = preFrame.origin.x - interval_x - rect.size.height/2;
                    y = preFrame.origin.y + preFrame.size.height - rect.size.width/2;
                    angle = -90;
                }else{
                    x = preFrame.origin.x + preFrame.size.width + interval_x+rect.size.height/2;
                    y = preFrame.origin.y + preFrame.size.height - rect.size.width/2;
                    angle = 90;
                }
                
                // 只有第二条才可能存在中间态
                if (index == 1) {
                    x *= timeScale;
                    y *= timeScale;
                    angle *= timeScale;
                }
                
                CGContextTranslateCTM(UIGraphicsGetCurrentContext(),x,y);
                CGContextRotateCTM (UIGraphicsGetCurrentContext(), angle * (M_PI / 180));
                preFrame = CGRectZero;
                
                // 计算顶点坐标
                rect.origin.x = -rect.size.width/2;
                rect.origin.y = preFrame.origin.y - interval_y - rect.size.height;
                 
                
                // 开始写字
                [attrStr drawAtPoint:CGPointMake(rect.origin.x, rect.origin.y)];
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
        frame = [self drawItem:items[i] headItem:items[0] preFrame:frame index:i timeScale:self.clock];
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
    CGFloat fontSize = floor(10 * ((self.frame.size.width - 100) / tempRect.size.width));
    return fontSize;
}

+(CGPoint)point:(CGPoint)point angle:(CGFloat)angle{
    CGFloat angle1 = angle*M_PI_2/90.0;
    float x = point.x *cos(angle1) - point.y*sin(angle1);
    float y = point.y*cos(angle1) + point.x*sin(angle1);
    return CGPointMake(x, y);
}


@end
