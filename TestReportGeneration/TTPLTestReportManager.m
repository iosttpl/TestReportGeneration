//
//  TTPLTestReportManager.m
//  TestReportGeneration
//
//  Created by Subramanian on 2/9/15.
//  Copyright (c) 2015 Tarento Technologies Pvt Ltd. All rights reserved.
//

#import "TTPLTestReportManager.h"
#import "TTPLTestCase.h"
#import "TTPLReportFileGenerator.h"
#import "TRConstant.h"

@interface TTPLTestReportManager () {
  /// Store test case result object in dictionary based on the testcase ID.
  NSMutableDictionary *_testResultDictionary;
  NSDictionary *_testCaseDictionary;
}

@end

@implementation TTPLTestReportManager

#pragma mark - Share Instance -
+ (instancetype)sharedInstance {
  if (disableReportGenerator) {
    return nil;
  }
  static TTPLTestReportManager *reportManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken,
                ^{ reportManager = [[TTPLTestReportManager alloc] init]; });
  return reportManager;
}

- (instancetype)init {
  if (self = [super init]) {
    _testResultDictionary = [[NSMutableDictionary alloc] init];
    NSString *path =
        [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    _testCaseDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
  }
  return self;
}

#pragma mark - Test Case Update -
- (BOOL)testCaseWithID:(NSString *)testCaseId
                inputs:(NSDictionary *)inputs
                status:(BOOL)status
              comments:(NSString *)comments {
  BOOL isReportUpdated = NO;
  if (!testCaseId.length) {
    return isReportUpdated;
  }

  NSDictionary *testCaseDetailDictionary =
      [_testCaseDictionary valueForKey:testCaseId];
  if (!testCaseDetailDictionary) {
    return isReportUpdated;
  }

  TTPLTestCase *testCase = [[TTPLTestCase alloc] init];
  testCase.tcId = testCaseId;
  testCase.tcCategory = testCaseDetailDictionary[category];
  testCase.tcObjective = testCaseDetailDictionary[objective];
  testCase.tcExpectedResult = testCaseDetailDictionary[expectedResult];
  testCase.tcInputs = inputs;
  testCase.tcStatus = status;
  testCase.tcComments = comments;
  _testResultDictionary[testCaseId] = testCase;

  return isReportUpdated;
}

#pragma mark - Report Generator -
- (BOOL)generateReport {
  BOOL isReportGenerated = NO;
  // Create Report file
  isReportGenerated = [TTPLReportFileGenerator
      generateReportStringWithTestCaseDictionary:_testResultDictionary];
  if (isReportGenerated) {
    [_testResultDictionary removeAllObjects];
  }
  return isReportGenerated;
}

@end
