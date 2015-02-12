//
//  TTPLReportHTMLGenerator.m
//  TestReportGeneration
//
//  Created by Subramanian on 2/9/15.
//  Copyright (c) 2015 Tarento Technologies Pvt Ltd. All rights reserved.
//

#import "TTPLReportFileGenerator.h"
#import "TTPLTestCase.h"
#import "TRConstant.h"
#import "TTPLTestReportManager.h"
#import <sys/utsname.h>

@implementation TTPLReportFileGenerator

#pragma mark - Start Report Generation Process -
+ (BOOL)generateReportStringWithTestCaseDictionary:
            (NSMutableDictionary *)dictionary {
  NSString *reportString;
  NSString *templateFilePath =
      [[NSBundle mainBundle] pathForResource:templateFileName ofType:nil];
  reportString = [[NSString alloc] initWithContentsOfFile:templateFilePath
                                                 encoding:NSUTF8StringEncoding
                                                    error:nil];

  reportString = [self updateAppInfoWithReportString:reportString];
  /// Update test cases
  reportString =
      [self updateTestCaseOnReport:reportString testCaseDictionary:dictionary];

  /// Create html file
  BOOL isReportGenerated = [self createReportFileWtihContent:reportString];

  return isReportGenerated;
}

#pragma mark - Add App Info -
+ (NSString *)updateAppInfoWithReportString:(NSString *)reportString {

  NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
  /// App name
  NSString *appName = info[keyOfBundleName];
  /// Version number  along with Build number.
  NSString *version =
      [NSString stringWithFormat:@"%@ (%@)", info[keyOfAppVersion],
                                 info[keyOfBundleVersion]];

  // App Name Update
  reportString = [reportString
      stringByReplacingOccurrencesOfString:templatePlaceHolderAppName
                                withString:appName];

  // Version Number
  reportString = [reportString
      stringByReplacingOccurrencesOfString:templatePlaceHolderVersion
                                withString:version];

  // Name
  reportString = [[reportString
      stringByReplacingOccurrencesOfString:templatePlaceHolderName
                                withString:[TTPLTestReportManager
                                                   sharedInstance]
                                               .testerName] capitalizedString];

  // Device
  UIDevice *currentDevice = [UIDevice currentDevice];
  NSString *deviceOS =
      [NSString stringWithFormat:@"%@ %@%@", [self deviceName], iOSName,
                                 currentDevice.systemVersion];
  reportString = [reportString
      stringByReplacingOccurrencesOfString:templatePlaceHolderDevice
                                withString:deviceOS];

  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:reportDateFormat];
  NSString *formattedDateString = [formatter stringFromDate:[NSDate date]];

  // Report Generation time
  reportString =
      [reportString stringByReplacingOccurrencesOfString:templatePlaceHolderDate
                                              withString:formattedDateString];

  return reportString;
}

#pragma mark - Add Test Case Rows -
+ (NSString *)updateTestCaseOnReport:(NSString *)reportString
                  testCaseDictionary:(NSMutableDictionary *)testCaseDictionary {

  NSArray *arrayOfTestCases = [testCaseDictionary allKeys];

  // If it is a string the sort by localizedCaseInsensitiveCompare
  arrayOfTestCases = [arrayOfTestCases
      sortedArrayUsingSelector:@selector(localizedStandardCompare:)];

  for (NSString *testCaseKey in arrayOfTestCases) {
    TTPLTestCase *testCase = testCaseDictionary[testCaseKey];
    /// Status cell color base on the status (PASS/FAIL)
    NSString *statusCSS = (testCase.tcStatus) ? statusPassCSS : statusFailCSS;
    /// Status string (PASS/FAIL)
    NSString *statusString = (testCase.tcStatus) ? statusPass : statusFail;
    /// Update status Table Row Tag
    NSString *statusTagWithValues =
        [NSString stringWithFormat:statusTag, statusCSS, statusString];

    /// Format input values.
    NSString *inputString = emptyString;
    if (testCase.tcInputs) {
      NSArray *inputKeys = testCase.tcInputs.allKeys;
      inputKeys = [inputKeys
          sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
      for (NSString *key in inputKeys) {
        /// Create input string
        inputString =
            [inputString stringByAppendingFormat:@"%@ : %@ <br> ", key,
                                                 testCase.tcInputs[key]];
      }
    } else {
      inputString = notAvailableString;
    }

    /// Comments
    NSString *commentsString =
        (testCase.tcComments.length) ? testCase.tcComments : notAvailableString;

    /// create new Table Row
    NSString *testCaseString = [NSString
        stringWithFormat:tableRow, testCase.tcId, testCase.tcCategory,
                         testCase.tcObjective, testCase.tcExpectedResult,
                         inputString, statusTagWithValues, commentsString];

    /// Updated report
    reportString = [reportString
        stringByReplacingOccurrencesOfString:[templatePlaceHolderTestCase
                                                     lowercaseString]
                                  withString:testCaseString
                                     options:NSCaseInsensitiveSearch
                                       range:NSMakeRange(0,
                                                         reportString.length)];
  }

  return reportString;
}

#pragma mark - Report File Create -
+ (BOOL)createReportFileWtihContent:(NSString *)fileContent {

  /// Create Appname-TestReport.html file on the document directory.
  BOOL isReportGenerated;
  NSString *filePath = [self reportFilePath];

  NSError *error;
  [fileContent writeToFile:filePath
                atomically:YES
                  encoding:NSUTF8StringEncoding
                     error:&error];
  if (error) {
    NSLog(@"Report not generated : %@", error);
  } else {
    isReportGenerated = YES;
  }
  return isReportGenerated;
}

#pragma mark - Report File Path -
+ (NSString *)reportFilePath {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
  NSString *appName = info[keyOfBundleName];

  NSString *fileName = [NSString stringWithFormat:reportFileName, appName];
  NSString *filePath =
      [documentsDirectory stringByAppendingPathComponent:fileName];
  NSLog(@"filePath %@", filePath);
  return filePath;
}

#pragma mark - Device Model Name -
+ (NSString *)deviceName {
  struct utsname systemInfo;
  uname(&systemInfo);

  NSString *deviceModel = [NSString stringWithCString:systemInfo.machine
                                             encoding:NSUTF8StringEncoding];

  NSString *path =
      [[NSBundle mainBundle] pathForResource:deviceModelListFileName
                                      ofType:nil];
  NSDictionary *modelListDictionary =
      [NSDictionary dictionaryWithContentsOfFile:path];
  NSString *modelName = [modelListDictionary valueForKey:deviceModel];
  if (!modelName.length) {
    modelName = deviceModel;
  }

  return modelName;
}
@end
