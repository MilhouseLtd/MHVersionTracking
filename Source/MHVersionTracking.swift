//
//  MHVersionTracking.swift
//  VersinTracking
//
//  Created by Patrick on 20/08/2015.
//  Copyright (c) 2015 Milhouse Ltd. All rights reserved.
//

import Foundation


private let kUserDefaultsVersionTrailKey = "kMHVersionTrail"
private let kVersionsKey =                 "kMHVersion"
private let kBuildsKey =                   "kMHBuild"



public class MHVersionTracking {

  public static let sharedInstance = MHVersionTracking()

  private var _versionTrail            = Dictionary<String, [String]>()
  private var _isFirstLaunchEver       = false
  private var _isFirstLaunchForVersion = false
  private var _isFirstLaunchForBuild   = false


  private init() {}


  // MARK: Public API

  public func track() {
    var needsSync = false

    //check if its the first ever launch
    if let oldVersionTrail = NSUserDefaults.standardUserDefaults().objectForKey(kUserDefaultsVersionTrailKey) as? Dictionary<String, [String]> {
      self._isFirstLaunchEver = false
      self._versionTrail = oldVersionTrail
      //needsSync = true
    } else {
      self._isFirstLaunchEver = true
      self._versionTrail = [kVersionsKey:[], kBuildsKey:[]]
    }

    //check if this version was previously launched
    if contains(self._versionTrail[kVersionsKey]!, currentVersion()) {
      self._isFirstLaunchForVersion = false
    } else {
      self._isFirstLaunchForVersion = true
      self._versionTrail[kVersionsKey]?.append(currentVersion())
      needsSync = true
    }

    //check if this build was previously launched
    if contains(self._versionTrail[kBuildsKey]!, currentBuild()) {
      self._isFirstLaunchForBuild = false
    } else {
      self._isFirstLaunchForBuild = true
      self._versionTrail[kBuildsKey]?.append(currentBuild())
      needsSync = true
    }

    //store the new version stuff
    if needsSync {
      NSUserDefaults.standardUserDefaults().setObject(_versionTrail, forKey:kUserDefaultsVersionTrailKey)
      NSUserDefaults.standardUserDefaults().synchronize()
    }
  }

  public func isFirstLaunchEver() -> Bool {
    return self._isFirstLaunchEver
  }

  public func isFirstLaunchForVersion() -> Bool {
    return self._isFirstLaunchForVersion
  }

  public func isFirstLaunchForBuild() -> Bool {
    return self._isFirstLaunchForBuild
  }

  public func isFirstLaunchForVersion(version:String) -> Bool {
    if self.currentVersion() == version {
      return self._isFirstLaunchForVersion
    } else {
      return false
    }
  }

  public func isFirstLaunchForBuild(build:String) -> Bool {
    if self.currentBuild() == build {
      return self._isFirstLaunchForBuild
    } else {
      return false;
    }
  }


  // MARK: Versions

  public func currentVersion() -> String {
    return (NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String)!
  }

  public func previousVersion() -> String? {
    var count = self._versionTrail[kVersionsKey]!.count
    if (count >= 2) {
      return self._versionTrail[kVersionsKey]![count-2];
    } else {
      return nil
    }
  }

  public func firstInstalledVersion() -> String {
    return self._versionTrail[kVersionsKey]!.first!
  }

  public func versionHistory() -> [String] {
    return self._versionTrail[kVersionsKey]!
  }


  // MARK: Builds

  public func currentBuild() -> String {
    return (NSBundle.mainBundle().infoDictionary?[kCFBundleVersionKey] as? String)!
  }

  public func previousBuild() -> String? {
    var count = self._versionTrail[kBuildsKey]!.count
    if (count >= 2) {
      return self._versionTrail[kBuildsKey]![count-2];
    } else {
      return nil
    }
  }

  public func firstInstalledBuild() -> String {
    return self._versionTrail[kBuildsKey]!.first!
  }

  public func buildHistory() -> [String] {
    return self._versionTrail[kBuildsKey]!
  }
}
