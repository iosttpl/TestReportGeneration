//
//  TTPLReportHTMLGenerator.m
//  TestReportGeneration
//
//  Created by Subramanian on 2/9/15.
//  Copyright (c) 2015 Tarento Technologies Pvt Ltd. All rights reserved.
//

#import "TTPLReportFileGenerator.h"
#import "TTPLTestCase.h"

/// Template file name
static NSString *const templateFileName = @"TTPLReportTemplate.html";

static NSString *const reportFileName = @"%@-TestReport.html";

/// Placeholder on the template file
static NSString *const templatePlaceHolderAppName = @"#AppName#";
static NSString *const templatePlaceHolderVersion = @"#VersionNumber#";
static NSString *const templatePlaceHolderDate = @"#Date#";
static NSString *const templatePlaceHolderTestCase = @"<TR></TR>";

/// Test case row.
static NSString *const tableRow =
    @"<TR> <TD CLASS =\"testResultTableRow\"> %@ </TD>"
    @"<TD CLASS =\"testResultTableRow\"> %@ </TD>"
    @"<TD CLASS =\"testResultTableRow\"> %@ </TD>"
    @"<TD CLASS =\"testResultTableRow\"> %@ </TD>"
    @"<TD CLASS =\"testResultTableRow\"> %@ </TD>"
    @"<TD CLASS =\"testResultTableRow\"> %@ </TD>"
    @"<TD CLASS =\"testResultTableRow\"> %@ </TD> </TR> <TR></TR>";

/// Bundle info dictionary keys
static NSString *const keyOfAppVersion = @"CFBundleShortVersionString";
static NSString *const keyOfBundleVersion = @"CFBundleVersion";

static NSString *const keyOfBundleName = @"CFBundleName";

/// Report date format
static NSString *const reportDateFormat = @"MMM dd, YYYY HH:mm:ss";

static NSString *const emptyString = @"";
static NSString *const notAvailableString = @"N/A";
static NSString *const statusPass = @"PASS";
static NSString *const statusFail = @"FAIL";

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
    NSString *statusString = (testCase.tcStatus) ? statusPass : statusFail;

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
                         inputString, statusString, commentsString];

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
