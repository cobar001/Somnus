//
//  AppDelegate.swift
//  Somnus
//
//  Created by Chris Cobar on 1/1/19.
//  Copyright © 2019 Chris Cobar. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var mWindow: UIWindow?
	var mSomnusViewController: SomnusViewController?
	var mOnBoardingPageViewController: PageOnBoardingPageViewController?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		print("did finish loading")
		
		UIApplication.shared.isIdleTimerDisabled = true
		
		mWindow = UIWindow(frame: UIScreen.main.bounds)
		mWindow?.backgroundColor = UIColor.darkGray
		
		mOnBoardingPageViewController = PageOnBoardingPageViewController()
		mSomnusViewController = SomnusViewController()
		
		// Check if first time launching app, if so, send to onboarding welcome.
		let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
		if /*launchedBefore*/false  {
			print("Not first launch.")
			let indexNavController = UINavigationController(rootViewController: mSomnusViewController!)
			mWindow?.rootViewController = indexNavController
		} else {
			print("First launch, setting UserDefault.")
			UserDefaults.standard.set(true, forKey: "launchedBefore")
			mWindow?.rootViewController = mOnBoardingPageViewController
		}
		mWindow?.makeKeyAndVisible()
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
		print("application will resign active")
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		print("application did enter background")
		pushEnteringBackgroundNotification()
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
		print("application will enter background")
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		print("application did become active")
		if (mSomnusViewController?.mIsSomnusSessionActive)! {
			UIScreen.main.brightness = CGFloat(0.01)
		}
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		print("application will terminate")
	}
	
	func pushEnteringBackgroundNotification() {
		guard let somnusVC = mSomnusViewController else { return }
		if somnusVC.mIsSomnusSessionActive {
			let notificationContent: UNMutableNotificationContent = UNMutableNotificationContent()
			notificationContent.title = "App Entered Background"
			notificationContent.body = "The alarm has been disabled. Please reset" +
			" the alarm and be sure not to close the app."
			let trigger: UNTimeIntervalNotificationTrigger =
				UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
			let request: UNNotificationRequest = UNNotificationRequest(
				identifier: "SomnusLocalNotification", content: notificationContent, trigger: trigger)
			UNUserNotificationCenter.current().add(request) { (error) in
				if let error = error {
					print("Error: \(error.localizedDescription)")
				}
			}
		}
	}
}

