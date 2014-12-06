//
//  HMCirImageView.m
//  手动实现循环机制
//
//  Created by mac on 14-10-20.
//  Copyright (c) 2014年 itheima. All rights reserved.
//




#import "HMViewController.h"
#import "UIView+FrameExpand.h"

#define HMImageCount 6
/**
 * 组标题view的高度
 */
#define SectionViewH 44
/**
 *  背景ScrollView垂直方向初始的偏移距离
 */
#define ScrollViewBOffsetY 70
/**
 *  背景scrollView垂直方向上与tableView垂直方向上移动的系数比
 */
#define ScrollViewB2TableViewYFactor 0.3
/**
 *  pageContorl距离父控件中心的比例
 */
#define ScaleX 0.5
#define ScaleY 0.96
/**
 *  定时器时间间隔
 */
#define TimerDuration 2.0
/**
 *  tableView的额外滚动区域
 */
#define ContentInsetY 20
/**
 *  headView的高度
 */
#define HeadViewH 250
/**
 *  cell的行数
 */
#define CellCount 10
/**
 *  cell的高度
 */
#define CellH 44
/**
 *  自定义导航栏标题字体大小
 */
#define NavTextFont 18
/**
 *  自定义组标题字体大小
 */
#define SectionFont 18
/**
 *  高度常量
 */
#define ConstH 44
/**
 *  导航栏高度+状态栏的高度 = 64
 */
#define NavHAndStautsH 64
/**
 *  headView中显示轮播器对应内容的label的高度
 */
#define HeadViewLabel2ScrollViewB 30

@interface HMViewController ()<UITableViewDelegate,UITableViewDataSource>

/**
 *  前面的scrollViewF
 */
@property (strong, nonatomic) UIScrollView *scrollViewF;
@property (assign , nonatomic) NSInteger curPage;
@property (assign , nonatomic) NSInteger totalPages;
/**
 *  存放所有图片的数组
 */
@property (strong , nonatomic) NSMutableArray * imagesArray;
/**
 *  缓冲数组(存放图片)
 */
@property (strong , nonatomic) NSMutableArray * curImages;
/**
 *  添加定时器
 */
@property (strong , nonatomic) NSTimer * timer;

@property (strong , nonatomic) UIPageControl * pageControl;
/**
 *  索引,用来在调用nextImage方法时使图片滚到下一张
 */
@property (assign , nonatomic) int index;

#pragma mark - tableview相关
@property (weak , nonatomic) UIView * headView;
@property (weak, nonatomic) UITableView *tableview;
/**
 *  后面的scrollView
 */
@property (weak , nonatomic) UIScrollView * scrollViewB;
/**
 *  headView上的label
 */
@property (weak , nonatomic) UILabel * headLabel;
/**
 *  组标题label
 */
@property (weak , nonatomic) UILabel * sectionLabel;
#pragma mark - 自定义导航栏和状态栏背景
/**
 *  导航栏背景view,用view的话可以自由控制
 */
@property (weak , nonatomic) UIView * statusView;
/**
 *  自定义导航栏
 */
@property (weak , nonatomic) UILabel * navLabel;
/**
 *  模型数组
 */
@property (strong , nonatomic) NSArray * data;
/**
 *  记录tableView当前的offset.y的值
 */
@property (assign , nonatomic) CGFloat lastOffset;
/**
 *  第一组组标题移动到顶部时,tableView的contentOffset在垂直方向上偏移的距离
 */
@property (assign , nonatomic) CGFloat firstOffsetY;
/**
 *  组模型的行数
 */
@property (assign , nonatomic) CGFloat rowNum;
/**
 *  行高
 */
@property (assign , nonatomic) CGFloat rowHeight;
/**
 *  headView的高度
 */
@property (assign , nonatomic) CGFloat headViewH;
/**
 *  额外的滚动区域
 */
@property (assign , nonatomic) CGFloat contentInsetY;
/**
 *  刷新控件
 */
@property (weak , nonatomic) UIRefreshControl * refreshControl;
@end

@implementation HMViewController


/**
 *  模拟数据
 */

- (NSArray *)data
{
    if (_data == nil) {
        _data = @[@"0组标题",@"1组标题",@"2组标题",@"3组标题",@"4组标题"];
    }
    return _data;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //1 加载所有视图控件
    [self setUpData];
    
}

#pragma mark - 加载视图控件
- (void)setUpData
{
    //1 初始化图片数组
    self.imagesArray = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < HMImageCount; i++) {
        NSString * imageName = [NSString stringWithFormat:@"%d.jpg",i];
        UIImage * image = [UIImage imageNamed:imageName];
        [self.imagesArray addObject:image];
    }
    
    //2 初始化其他相关的值
    _totalPages = _imagesArray.count;
    _curPage = 1;
    _index = 0;
    _curImages = [[NSMutableArray alloc] init];
    
    
    //3 初始化前面的scrollViewF
    UIScrollView * scrollViewB = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    self.scrollViewB = scrollViewB;
    
    scrollViewB.backgroundColor = [UIColor whiteColor];
    scrollViewB.showsHorizontalScrollIndicator = NO;
    scrollViewB.pagingEnabled = YES;
    scrollViewB.delegate = self;
    scrollViewB.contentSize = CGSizeMake(self.view.frame.size.width * HMImageCount,0);
    [self.view addSubview:scrollViewB];
    
    //3 初始化前面的scrollViewF
    UIScrollView * scrollViewF = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, HeadViewH)];
    self.scrollViewF = scrollViewF;
    
    scrollViewF.backgroundColor = [UIColor clearColor];
    scrollViewF.showsHorizontalScrollIndicator = NO;
    scrollViewF.pagingEnabled = YES;
    scrollViewF.delegate = self;
    scrollViewF.contentSize = CGSizeMake(self.view.frame.size.width * HMImageCount,0);
    //    [self.view addSubview:scrollViewF];
    
    //4 初始化headView
	UIView * headView = [[UIView alloc] init];
    headView.backgroundColor = [UIColor clearColor];
    headView.frame = CGRectMake(0, 0, self.view.width, HeadViewH);
    [headView addSubview:scrollViewF];
    self.headView = headView;
    //    [self.view addSubview:headView];
    //添加轮播器说明文字
    UILabel * headLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, headView.height - 44, 320, 30)];
    headLabel.text = @"很漂亮的女孩啊,喜欢";
    headLabel.textAlignment = NSTextAlignmentCenter;
    headLabel.textColor = [UIColor whiteColor];
    headLabel.font = [UIFont boldSystemFontOfSize:15];
    //    label.backgroundColor = [UIColor redColor];
    self.headLabel = headLabel;
    [headView addSubview:headLabel];
    
    
    
    //5 添加 tableView
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableview = tableView;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableHeaderView = headView;
    self.tableview.contentInset = UIEdgeInsetsMake(ContentInsetY, 0, 0, 0);
//    self.tableview.contentOffset = CGPointMake(0, -ContentInsetY);
    [self.view addSubview:tableView];
    
    
    //6 设置状态栏背景
    CGFloat statusH = 20;//状态栏固定高度
    UIView * statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, statusH)];
    //问题:如果用这个view装载label的话,在滚动到导航栏的位置时不能将组标题显示出来,因为需要组标题被顶开的动画(不好实现),所以采用分开设计的方式
    statusView.backgroundColor = [UIColor redColor];
    statusView.alpha = 0;
    //程序启动时,状态栏不是全透明(多重操作引起的),所以开始设置为隐藏(原因不明)
    //开始拖拽时,让隐藏等于NO
    statusView.hidden = YES;
    self.statusView = statusView;
    [self.view addSubview:statusView];
    
    //7 添加自定义导航栏
    UILabel * navLabel = [[UILabel alloc] init];
    self.navLabel = navLabel;
    navLabel.text = self.data[0];
    navLabel.frame = CGRectMake(0, statusView.height, self.view.width, ConstH);
    navLabel.backgroundColor = [UIColor redColor];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.alpha = 0;
    //程序启动时,状态栏不是全透明(多重操作引起的),所以开始设置为隐藏(原因不明)
    //开始拖拽时,让隐藏等于NO
    navLabel.hidden = YES;
    navLabel.font = [UIFont boldSystemFontOfSize:NavTextFont];
    [self.view addSubview:navLabel];
    
    
    //5 计算第一组标题滚动到顶部时tableView的contentOffet的y偏移的距离
    //第一组标题到顶部时:0ffset移动的距离也就是第一次offset垂直方向上偏移的距离(640) = 10 行 * 44行高 + 200(headView的高度) - 20(额外的滚动区域)
    
    self.rowNum = CellCount;// cell的行数,取决于组模型中的item的个数
    self.rowHeight = CellH;//cell的高度
    self.headViewH = HeadViewH;//headView的高度
    self.contentInsetY = ContentInsetY;//额外的滚动区域
    self.firstOffsetY = self.rowNum * self.rowHeight + self.headViewH - self.contentInsetY;
    
    [self refreshScrollView];
    [self addTimer];
    [self addPageControl];
    
    
}

#pragma mark - 添加imageView设置scrollView的contentoffset

- (void)refreshScrollView {
    
    NSArray *subViewsF = [self.scrollViewF subviews];
    if([subViewsF count] != 0) {
        [subViewsF makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self getDisplayImagesWithCurpage:_curPage];
    
    for (int i = 0; i < 3; i++) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.userInteractionEnabled = YES;//打开的话让图片可以和用户交互

        imageView.image = [_curImages objectAtIndex:i];
        
        imageView.frame = CGRectMake(i * self.scrollViewF.width, 0, self.scrollViewF.width, self.scrollViewF.height);
        
        [self.scrollViewF addSubview:imageView];
    }
    
    
    NSArray *subViewsB = [self.scrollViewF subviews];
    if([subViewsB count] != 0) {
        [subViewsB makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }

    for (int i = 0; i < 3; i++) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.userInteractionEnabled = YES;//打开的话让图片可以和用户交互
        
        imageView.image = [_curImages objectAtIndex:i];
        
        imageView.frame = CGRectMake(i * self.scrollViewB.width, 0, self.scrollViewB.width, self.scrollViewB.height);
        
        [self.scrollViewB addSubview:imageView];
    }
    
    [self.scrollViewF setContentOffset:CGPointMake(self.scrollViewF.width, 0)];
    [self.scrollViewB setContentOffset:CGPointMake(self.scrollViewB.width, 0)];
}


- (NSArray *)getDisplayImagesWithCurpage:(NSInteger)page {
    
    NSInteger pre = [self validPageValue:_curPage-1];
    NSInteger last = [self validPageValue:_curPage+1];
    
    if (!_curImages) {
        _curImages = [[NSMutableArray alloc] init];
    }
    
    
    [_curImages removeAllObjects];
    
    [_curImages addObject:[self.imagesArray objectAtIndex:pre-1]];
    [_curImages addObject:[self.imagesArray objectAtIndex:page-1]];
    [_curImages addObject:[self.imagesArray objectAtIndex:last-1]];
    
    #pragma  mark - 在这设置pageControl的页码值是对的
    self.pageControl.currentPage = _curPage - 1;
    
    return _curImages;
}

- (NSInteger)validPageValue:(NSInteger)value {
    
    if(value == 0) value = _totalPages;                   // value＝1为第一张，value = 0为前面一张
    if(value == _totalPages + 1) value = 1;
    
    return value;
}

/*
 *--------------------------------------------------------------------
 */

#pragma mark - 添加定时器
- (void)addTimer
{
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    
    /**
     *  pragma mark - 将定时器添加到主消息循环中,即可在主线程中给NSTimer分配优先级,
     *  让它在主线程中同时运行(属于更新UI界面)
     */
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
}
#pragma mark - 添加pageControl
- (void)addPageControl
{
    UIPageControl * pageControl = [[UIPageControl alloc] init];
    pageControl.pageIndicatorTintColor = [UIColor grayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];

    
    CGFloat centerX = self.scrollViewF.frame.size.width * 0.5;
    CGFloat centerY = self.scrollViewF.frame.size.height * 0.96;
    pageControl.center = CGPointMake(centerX, centerY);
    
    #pragma mark - 9 设置圆点的颜色
    pageControl.pageIndicatorTintColor = [UIColor grayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
    
    #pragma mark - 10 设置分页总数为图片数组的长度
    pageControl.numberOfPages = self.imagesArray.count;
    
    //将pageControl添加到headView上
//    [self.view addSubview:pageControl];
    [self.headView addSubview:pageControl];
    self.pageControl = pageControl;
    
}

#pragma mark - 点击nextImage
- (void)nextImage
{
    int x = self.scrollViewF.contentOffset.x;//当前的offset的x值
//    int y = self.scrollViewB.contentOffset.x;
    #pragma mark - index++ ,让 _scrollView.contentOffset 的值发生变
    _index++;
    [self.scrollViewF setContentOffset:CGPointMake(x * _index, 0) animated:YES];

//    [self.scrollViewB setContentOffset:CGPointMake(y * _index, 0) animated:YES];
}

#pragma  mark - 正在拖拽
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

    if (self.tableview.contentOffset.y >0 ) {
        //判断开始的时候tableView的contentOffset.y如果大于0就让导航栏和状态栏的隐藏 = NO;
        //解决的是程序头次启动时:会看到导航栏和状态栏背景,(因为其他操作到时不能全透明)
        self.navLabel.hidden = NO;
        self.statusView.hidden = NO;
    }

    NSInteger x = self.scrollViewF.contentOffset.x;
    
    if(x >= (2 * self.scrollViewF.frame.size.width)) {
        
        _curPage = [self validPageValue:_curPage + 1];
        
        [self refreshScrollView];
    }
    //上一张
    if(x <= 0) {
        _curPage = [self validPageValue:_curPage-1];
        
        [self refreshScrollView];
    }
    //pragma mark - index = 0 ,让 _scrollView.contentOffset 的值重置
    //因为图片的循环滚动导致必须重置offset的值
    _index = 0;
    
    
    //垂直方向上滚动微调
    CGRect viewF = self.scrollViewB.frame;
    //    NSLog(@"%@",NSStringFromCGRect(self.scrollViewB.frame));
    viewF.origin.y = -(self.tableview.contentOffset.y) * 0.3 - 70;
    self.scrollViewB.frame = viewF;
    
    //水平方向上滚动约束
    CGPoint offset = self.scrollViewF.contentOffset;
    if (offset.x >0 && offset.x < self.view.width * (HMImageCount - 1)) {
        offset.x = self.scrollViewF.contentOffset.x;
        self.scrollViewB.contentOffset = offset;
        
    }
    
    #pragma mark - 一下是决定组标题与导航栏相遇时标题文字更换的操作
    self.lastOffset = self.tableview.contentOffset.y;
    //调整自定义导航栏和状态栏背景的透明度
    self.navLabel.alpha = (self.tableview.contentOffset.y + ContentInsetY)/ (HeadViewH - NavHAndStautsH);
    //获取导航栏透明度的值
    CGFloat al = self.navLabel.alpha;
    //赋值给状态栏背景view的透明度(不要用直接计算的方式,直接计算与导航栏的透明度显示过程不对称)
    self.statusView.alpha = al;
    //第一组的标题滚动到顶部时,tableView.contenOffset.y 总共偏移的距离firstOffsetY(以每组10行cell.cell行高为44,headView的高度为200,额外的滚动区域为20为例,第一次偏移的距离是 == 640,公式在viewDidLoad方法中)
    if (self.lastOffset >= self.firstOffsetY) {
        self.navLabel.alpha = 0;
        //加上这句(可以控制轮播器移出顶部时状态栏的不见的情况)
        self.statusView.alpha = 1;
    }
    
}


#pragma mark - 移除定时器
- (void)removeTimer
{
    [_timer invalidate];
    _timer = nil;
    
}

#pragma mark - 代理方法:开始拖拽时
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    
    [self removeTimer];
    
}

#pragma mark - 代理方法: 停止拖拽时
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self addTimer];
//    NSLog(@"停止拖拽");
}

#pragma mark - tableView数据源方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * ID = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    return cell;
}


#pragma mark - tableView代理方法--返回一个组标题view
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SectionViewH)];
    sectionLabel.text = self.data[section];
    sectionLabel.textAlignment = NSTextAlignmentCenter;
    sectionLabel.textColor = [UIColor blackColor];
    sectionLabel.backgroundColor = [UIColor redColor];
    sectionLabel.font = [UIFont boldSystemFontOfSize:SectionFont];
    self.sectionLabel = sectionLabel;
    return sectionLabel;
}


#pragma mark - 返回组标题的高度 以及处理第0组的标题(设置第0组的标题高度为0)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){//如果是第0组
        return 0;
    }
    return SectionViewH;
}



@end
