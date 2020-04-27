//
//  DucklingView.m
//  InvertedDuckling
//
//  Created by donbe on 2020/4/26.
//  Copyright © 2020 donbe. All rights reserved.
//

#import "DucklingView.h"

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

/// transitionAnimation 1左旋，2右旋，3放大，4缩小
-(CGRect )drawItem:(NSDictionary *)item preFrame:(CGRect)preFrame index:(NSInteger)index timeScale:(float)timeScale{
    
    CGFloat interval_x = 5;// 旋转后的横向间距
    CGFloat interval_y = 0;// 上下两行的间距
    
    NSString *text = item[@"text"];
    NSString *color = item[@"color"];
    NSInteger transitionAnimation = [item[@"transition_animation"] intValue];
    
    
    // 计算所学字体大小
    CGRect tempRect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
    attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:10] }
       context:nil];
    CGFloat fontSize = floor(10 * ((self.frame.size.width - 100) / tempRect.size.width));
    // 第一条存在中间态
    if (index == 0) {
        fontSize = fontSize *timeScale;
    }
    
    
    UIFont* font = [UIFont systemFontOfSize:fontSize];
    UIColor* textColor = [UIColor colorFromHexAlphaString:color];
    NSDictionary* stringAttrs = @{ NSFontAttributeName : font, NSForegroundColorAttributeName : textColor };
    NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:text attributes:stringAttrs];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
    attributes:stringAttrs
       context:nil];
    

    if (!CGRectEqualToRect(CGRectZero, preFrame)){
        switch (transitionAnimation) {
            case 1://左旋
            case 2://右旋
            {
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
            }
                break;
            case 3://放大
            case 4://缩小
            {
                
            }
                break;
            default:
                break;
        }
    }
    

    // 计算顶点坐标
    rect.origin.x = -rect.size.width/2;
    rect.origin.y = preFrame.origin.y - interval_y - rect.size.height;
     
    
    // 开始写字
    [attrStr drawAtPoint:CGPointMake(rect.origin.x, rect.origin.y)];
    
    
    return rect;
}

-(void)drawRect:(CGRect)rect{

    // 移动原点到正中间
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), self.frame.size.width/2, self.frame.size.height/2);
    
    NSArray *items = [self testData];
    CGRect frame = CGRectZero;
    
    for(int i=0;i<[items count];i++)
        frame = [self drawItem:items[i] preFrame:frame index:i timeScale:self.clock];

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


@end
