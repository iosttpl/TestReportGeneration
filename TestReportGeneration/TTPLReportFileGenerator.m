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

@implementation TTPLReportFileGenerator

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
  BOOL isReportGenerated = [self createReportFileWtihContent:reportString];
  return isReportGenerated;
}

+ (NSString *)updateAppInfoWithReportString:(NSString *)reportString {
  NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
  NSString *appName = info[keyOfBundleName];
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

  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:reportDateFormat];
  NSString *formattedDateString = [formatter stringFromDate:[NSDate date]];

  // Report Generation time
  reportString =
      [reportString stringByReplacingOccurrencesOfString:templatePlaceHolderDate
                                              withString:formattedDateString];

  return reportString;
}

+ (NSString *)updateTestCaseOnReport:(NSString *)reportString
                  testCaseDictionary:(NSMutableDictionary *)testCaseDictionary {
  NSArray *arrayOfTestCases = [testCaseDictionary allKeys];
  arrayOfTestCases = [arrayOfTestCases
      sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

  for (NSString *testCaseKey in arrayOfTestCases) {
    TTPLTestCase *testCase = testCaseDictionary[testCaseKey];
    /// Status string
    NSString *statusCSS = (testCase.tcStatus) ? statusPassCSS : statusFailCSS;
    NSString *statusString = (testCase.tcStatus) ? statusPass : statusFail;
    NSString *statusTagWithValues =
        [NSString stringWithFormat:statusTag, statusCSS, statusString];

    /// Format input values.
    NSString *inputString = emptyString;
    if (testCase.tcInputs) {
      NSArray *inputKeys = testCase.tcInputs.allKeys;
      for (NSString *key in inputKeys) {
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

    NSString *testCaseString = [NSString
        stringWithFormat:tableRow, testCase.tcId, testCase.tcCategory,
                         testCase.tcObjective, testCase.tcExpectedResult,
                         inputString, statusTagWithValues, commentsString];

    /// Updated report
    reportString = [reportString
        stringByReplacingOccurrencesOfString:templatePlaceHolderTestCase
                                  withString:testCaseString];
  }

  return reportString;
}

+ (BOOL)createReportFileWtihContent:(NSString *)fileContent {
  BOOL isReportGenerated;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
  NSString *appName = info[keyOfBundleName];

  NSString *fileName = [NSString stringWithFormat:reportFileName, appName];
  NSString *filePath =
      [documentsDirectory stringByAppendingPathComponent:fileName];
  NSLog(@"filePath %@", filePath);

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
@end
