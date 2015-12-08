//
//  UncaughtExceptionHandler.m
//  UncaughtExceptions
//
//  Created by LSJ on 2015/12/04.
//  Copyright 2010 LSJ. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "UncaughtExceptionHandler.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import "Const.h"


NSString * const UncaughtExceptionHandlerSignalExceptionName2 = @"UncaughtExceptionHandlerSignalExceptionName2";
NSString * const UncaughtExceptionHandlerBackTraceKey = @"UncaughtExceptionHandlerBackTraceKey";

volatile int32_t UncaughtExceptionCount2 = 0;
const int32_t UncaughtExceptionMaximum2 = 10;

@implementation UncaughtExceptionHandler

+ (NSArray *)backtrace
{
	 void* callstack[128];
	 int frames = backtrace(callstack, 128);
	 char **strs = backtrace_symbols(callstack, frames);
	 
	 int i;
	 NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
	 for (
	 	i = 3;
	 	i < frames;
		i++)
	 {
	 	[backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
	 }
	 free(strs);
	 
	 return backtrace;
}

- (void)handleException:(NSException *)exception
{
    
    void (^run)() = ^()
    {
        CFRunLoopRef runLoop = CFRunLoopGetCurrent();
        CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
        
        NSDate *nowDate = [NSDate date];
        while ([[NSDate date] timeIntervalSinceDate:nowDate] <= 2)
        {
            for (NSString *mode in (__bridge NSArray *)allModes)
            {
                CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
            }
        }
        
        CFRelease(allModes);
    };
    
	run();

    [exception raise];
}

void saveCriticalApplicationData(NSException *exception)
{

    NSLog(@"Crashing\n%@\n%@", exception.reason, [[exception userInfo] objectForKey:UncaughtExceptionHandlerBackTraceKey]);
    NSString *reason = exception.reason;
    if (reason.length > 255)
    {
        reason = [reason substringToIndex:255];
    }
    else if (reason.length == 0)
    {
        reason = @"None";
    }
    
#ifdef LocationCrash
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *logPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/CrashLog.txt"];
    if (![fileManager fileExistsAtPath:logPath]) {
        [fileManager createFileAtPath:logPath contents:nil attributes:nil];
    }
    NSString *logStr = [NSString stringWithFormat:@"foxitreader Crashing \n data%@\n%@\n",exception.reason, [[exception userInfo] objectForKey:UncaughtExceptionHandlerBackTraceKey]];
    NSString *allLogStr = [NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil];
    allLogStr = [allLogStr stringByAppendingString:logStr];
    [allLogStr writeToFile:logPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
#endif
    
}

void HandleException(NSException *exception)
{
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount2);
	if (exceptionCount > UncaughtExceptionMaximum2)
	{
		return;
	}
    
	NSArray *callStack = [UncaughtExceptionHandler backtrace];
	NSMutableDictionary *userInfo =
    [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
	[userInfo
     setObject:callStack
     forKey:UncaughtExceptionHandlerBackTraceKey];
	
    NSException *newException = [NSException
                                 exceptionWithName:[exception name]
                                 reason:[exception reason]
                                 userInfo:userInfo];
    saveCriticalApplicationData(newException);
    
	[[[UncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:newException
     waitUntilDone:YES];
}

void SignalHandler(int signal)
{
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount2);
	if (exceptionCount > UncaughtExceptionMaximum2)
	{
		return;
	}
	
    NSArray *callStack = [UncaughtExceptionHandler backtrace];
	NSMutableDictionary *userInfo =
    [NSMutableDictionary
     dictionaryWithObject:callStack
     forKey:UncaughtExceptionHandlerBackTraceKey];
	
    NSException *newException = [NSException
                                 exceptionWithName:UncaughtExceptionHandlerSignalExceptionName2
                                 reason:
                                 [NSString stringWithFormat:
                                  NSLocalizedString(@"Signal %d was raised.", nil),
                                  signal]
                                 userInfo:userInfo];
    saveCriticalApplicationData(newException);
    
	[[[UncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:newException
     waitUntilDone:YES];
}

+ (void)installUncaughtExceptionHandler
{
	NSSetUncaughtExceptionHandler(&HandleException);
	signal(SIGABRT, SignalHandler);
	signal(SIGILL, SignalHandler);
	signal(SIGSEGV, SignalHandler);
	signal(SIGFPE, SignalHandler);
	signal(SIGBUS, SignalHandler);
	signal(SIGPIPE, SignalHandler);
}

@end
