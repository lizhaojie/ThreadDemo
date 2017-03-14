//
//  ViewController.m
//  ThreadDemo
//
//  Created by lizhaojie on 17/3/14.
//  Copyright © 2017年 LIStudy. All rights reserved.
//

#import "ViewController.h"
/*
 多线程分类：pthread，NSThread，NSOperation，GCD
 多线程队列：串行队列，并行队列，全局队列，主队列
 执行的方法：同步执行，异步执行
 
 pthread：跨平台
 
 GCD和NSOperation
 NSOperation底层也通过GCD实现，换个说法就是NSOperation是对GCD更高层次的抽象
 区别： GCD的核心概念是将一个任务添加到队列，指定任务执行的方法，然后执行
 NSOperation：是直接将一个操作添加到队列中
 */
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self testSerialSync];
    
    [self testSerialAsync];
    
    [self testConcurrentAsync];
    
    [self testConcurrentSync];
    
    [self testMainQueue];
    
//    [self mainQueueSyn];
    
    [self gloablQueuAsyn];
    
    // Do any additional setup after loading the view, typically from a nib.
}
//串行队列，并行执行
/*
 
 不会开辟新的线程，在主线程中顺序执行，阻塞主线程，全部执行完后才执行主线程的打印
 
 */
- (void)testSerialSync{
    dispatch_queue_t queue = dispatch_queue_create("serialSyn", NULL);
    
    for (int i=0; i<10; i++) {
        dispatch_sync(queue, ^{
            
//            NSLog(@"thread == %@,%d",[NSThread currentThread],i);

        });
    }
//    NSLog(@"main thread == %@",[NSThread currentThread]);
//    NSLog(@"main print!!!");
}
/*
 开辟了一条异步线程，顺序执行
 主线程打印的顺序不定
 */
- (void)testSerialAsync{
    dispatch_queue_t queue = dispatch_queue_create("serialSyn", NULL);
    for (int i = 0; i<10; i++) {
        dispatch_async(queue, ^{
           
//            NSLog(@"SerialAsynThread == %@,%d",[NSThread currentThread],i);
        });
        
    }
//    NSLog(@"main thread == %@",[NSThread currentThread]);
//    NSLog(@"main print!!!");

}
/*
 主线程在不确定的位置执行
 创建多个异步线程，顺序不确定执行
 */
- (void)testConcurrentAsync{
    dispatch_queue_t queue = dispatch_queue_create("concurrentAsyn", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i<10; i++) {
        dispatch_async(queue, ^{
            
//            NSLog(@"concurrentAsynThread == %@,%d",[NSThread currentThread],i);

        });
    }
//    NSLog(@"main thread == %@",[NSThread currentThread]);
//    NSLog(@"main print!!!");

}
/*
 
 同步执行，串行队列
 不开线程，在主线程书序执行
 */

- (void)testConcurrentSync{
    dispatch_queue_t queue = dispatch_queue_create("concurrentAsyn", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i<10; i++) {
        dispatch_sync(queue, ^{
            
//            NSLog(@"concurrentSynThread == %@,%d",[NSThread currentThread],i);
            
        });
    }
//    NSLog(@"main thread == %@",[NSThread currentThread]);
//    NSLog(@"main print!!!");
    
}
/*
 
 综上：同步，异步是决定开一条还是多条线程
 所以一旦同步执行，队列不管是并行还是串行没区别了
 */

/*
 主队列，异步执行
 
 主队列的任务是放到主线程中执行，但是如果主线程中有任务，要先执行主线程里的，在执行主队列里的
 */
- (void)testMainQueue{
    dispatch_queue_t queue = dispatch_get_main_queue();
    for (int i = 0; i<10; i++) {
        dispatch_async(queue, ^{
//            NSLog(@"mainQueueThread == %@,%d",[NSThread currentThread],i);
        });
    }
    [NSThread sleepForTimeInterval:3.0];
    
//    NSLog(@"main thread == %@",[NSThread mainThread]);
}
/*循环等待：主队列，同步执行：造成死锁*/
- (void)mainQueueSyn{
    dispatch_sync(dispatch_get_main_queue(), ^{
       
        NSLog(@"main Queue");
    });
    
    NSLog(@"main thread");
}
/*
 全局队列的本质是并非队列：只是在后面加入了，“服务质量”，和“调度优先级” 两个参数，这两个参数一般为了系统间的适配，最好直接填0和0。
 */
- (void)gloablQueuAsyn{
    dispatch_queue_t q = dispatch_get_global_queue(0, 0);
    
    for (int i = 0; i < 10; i++) {
        dispatch_async(q, ^{
            NSLog(@"%@ %d", [NSThread currentThread], i);
        });
    }
//    [NSThread sleepForTimeInterval:1.0];
    NSLog(@"com here");
}
/*
 
 1. 开不开线程，取决于执行任务的函数，同步不开，异步开。
 
 2. 开几条线程，取决于队列，串行开一条，并发开多条(异步)
 
 3. 主队列：  专门用来在主线程上调度任务的"队列"，主队列不能在其他线程中调度任务！
 
 4. 如果主线程上当前正在有执行的任务，主队列暂时不会调度任务的执行！主队列同步任务，会造成死锁。原因是循环等待
 
 5. 同步任务可以队列调度多个异步任务前，指定一个同步任务，让所有的异步任务，等待同步任务执行完成，这是依赖关系。
 
 6. 全局队列：并发，能够调度多个线程，执行效率高，但是相对费电。 串行队列效率较低，省电省流量，或者是任务之间需要依赖也可以使用串行队列。
 
 7. 也可以通过判断当前用户的网络环境来决定开的线程数。WIFI下6条，3G/4G下2～3条。
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
