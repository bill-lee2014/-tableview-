
/**
 1>> 两个scrollView (前后两个),关联两个scrollView的offset达到同步动作(为的是保留tableView的plain样式下的标题互顶的动画效果)
 2>> 利用tableView的headView占位,并设置成透明,来达到显示背后scrollView的目的
 3>> 将前面scrollView中承载图片的控件设置为button,方便响应点击事件
 4>> 将轮播器内的图片设计成图片模型(包含图片名,网址,以及点击图片显示的对应的数据(数组))
 5>> 问题总结
    y值微调整(-1:IPhone6 自定义的状态栏和导航栏衔接的时候会有一条线,将tableview的contenoffset调整为19就好好了)
    -1 :只是调整自定义导航栏内部的label位置,让其被tebleview第0组标题顶住交换标题文字时出现小跳的现象
    原因:tableView的offsetTop上移1,所以让tebleview第0组标题与导航栏相遇时出现了1的偏差
    解决办法:调整导航栏内部label的y值(本来是:0,0,xx,xx 调整为 0,-1,xx,xx)
 */