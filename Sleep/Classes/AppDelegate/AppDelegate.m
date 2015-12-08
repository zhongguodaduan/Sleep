//
//  AppDelegate.m
//  Sleep
//
//  Created by LSJ on 15/12/4.
//  Copyright © 2015年 LSJ. All rights reserved.
//

#import "AppDelegate.h"
#import "Const.h"
#import "JPEngine.h"
#import "UncaughtExceptionHandler.h"
#import "AlarmClockViewController.h"
#import "StatisticsViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+(void)initialize
{
    [AppDelegate initEnv];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.view.backgroundColor = [UIColor grayColor];
    self.window.rootViewController = tabBarController;
    
    AlarmClockViewController *alarmClockCtr = [[AlarmClockViewController alloc] initWithNibName:@"AlarmClockViewController" bundle:nil];
    alarmClockCtr.view.backgroundColor = [UIColor darkGrayColor];
    alarmClockCtr.tabBarItem.title = NSLocalizedString(@"kAlarmClock", nil);
    alarmClockCtr.tabBarItem.image = [UIImage imageNamed:@"alarmclock"];
    
    StatisticsViewController *statisticsCtr = [[StatisticsViewController alloc] initWithNibName:@"StatisticsViewController" bundle:nil];
    statisticsCtr.view.backgroundColor = [UIColor grayColor];
    statisticsCtr.tabBarItem.title = NSLocalizedString(@"kStatistics", nil);
    statisticsCtr.tabBarItem.image = [UIImage imageNamed:@"alarmclock"];
    
    
    tabBarController.viewControllers = @[alarmClockCtr,statisticsCtr];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

+(void)initEnv
{
    NSLog(@"%@",NSHomeDirectory());
    
    //setup jspath : dynamic fixed bugs      online
//    [JSPatch startWithAppKey:JSPatch_Key];
    
    [JPEngine startEngine];
    [JPEngine evaluateScript:@""];
    
    //setup crashlytics : crashlytics the crashs
    
    //setup record location crash
    [UncaughtExceptionHandler installUncaughtExceptionHandler];
    
}

@end
