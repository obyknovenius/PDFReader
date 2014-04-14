//
//  ReaderAppDelegate.m
//  PDFReader
//
//  Created by Vitaly Dyachkov on 11.03.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import "ReaderAppDelegate.h"

#import "ReaderViewController.h"

@implementation ReaderAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"leaseagreement" withExtension:@"pdf"];
    
    NSString *documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *newFilePath = [documentsDirectoryPath stringByAppendingPathComponent:[fileURL.path lastPathComponent]];
    NSURL *newFileURL = [NSURL fileURLWithPath:newFilePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:newFilePath]) {
        NSError *error;
        if ([[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:newFileURL error:&error]) {
            NSLog(@"Error occured while moving file: %@", [error localizedDescription]);
        }
    }
    
    ReaderViewController *reader = [[ReaderViewController alloc] initWithURL:newFileURL];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:reader];
    
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
