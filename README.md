# DucklingView

![image](https://github.com/donbe/inverted_duckling/blob/master/ducklingview.gif =150x)

倒鸭子字幕特效

 * Easy to use
 * Flexible configuration
 * Superior performance
 

### How to use

 * Import DucklingView.h DucklingView.m DucklingModel.h DucklingModel.m
 
 and use like this:
```
    // 创建
    self.iDuckling = [[DucklingView alloc] initWithFrame:CGRectMake(0, 88, 320, 320)];
 
    // 设置显示数据
    self.iDuckling.data = data;
    
    // 添加，搞定
    [self.view addSubview:self.iDuckling];

```

### Configuration
```
// 绘制最近多少条，默认12条
@property(nonatomic)int count;

// 动画原点y轴的偏移量,默认正中间
@property(nonatomic)float originOffsety;

// 上下两行的间距，默认0
@property(nonatomic)float lineInterval;

// 字的最大宽度到视图两侧的间隙,默认150
@property(nonatomic)float padding;

// 转场动画的放大缩小比例, 默认1.5倍
@property(nonatomic)float scaleFactor;

// 设置最大字号,默认40
@property(nonatomic)float maxFontSize;

// 设置默认字体，默认PingFangSC-Regular
@property(nonatomic,strong)NSString *font;
```


enjoy it :)
