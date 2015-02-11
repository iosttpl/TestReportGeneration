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
#import <UIView+draggable.h>

@interface TTPLTestReportManager () {
  /// Store test case result object in dictionary based on the testcase ID.
  NSMutableDictionary *_testResultDictionary;

  /// TTPLTestCase.plist file content.
  NSDictionary *_testCaseDictionary;

  /// Draggable view
  UIView *_draggableView;
}

@end

@implementation TTPLTestReportManager

#pragma mark - Share Instance -
+ (instancetype)sharedInstance {
  /// If you want to disable the test report generator then set this flag.
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
    /// This will hold all the TestCase objects.
    _testResultDictionary = [[NSMutableDictionary alloc] init];
    /// Path of the TTPLTestCase.plist file
    NSString *path =
        [[NSBundle mainBundle] pathForResource:testCaseListFileName ofType:nil];
    _testCaseDictionary = [NSDictionary dictionaryWithContentsOfFile:path];

    if (enableReportButton) {
      UIWindow *keyWindow = [UIApplication sharedApplication].windows[0];
      dispatch_async(dispatch_get_main_queue(), ^{
          /// Add draggable view on the main thread.
          [self addDraggableViewOnWindow:keyWindow];
      });
    }
  }
  return self;
}

#pragma mark - Draggable view -
- (void)addDraggableViewOnWindow:(UIWindow *)keyWindow {
  _draggableView = nil;
  _draggableView = [[UIView alloc]
      initWithFrame:CGRectMake(
                        CGRectGetMaxX(keyWindow.frame) - draggableViewSize,
                        CGRectGetMaxY(keyWindow.frame) - draggableViewSize,
                        draggableViewSize, draggableViewSize)];
  _draggableView.layer.cornerRadius = draggableViewCornorRadius;
  _draggableView.backgroundColor = [UIColor lightGrayColor];
  [_draggableView enableDragging];
  CGRect cagingRect = keyWindow.frame;
  [_draggableView setCagingArea:cagingRect];
  [keyWindow addSubview:_draggableView];

  UIButton *reportGenerateButton = [UIButton buttonWithType:UIButtonTypeCustom];
  CGRect buttonRect = CGRectZero;
  buttonRect.size.height = draggableViewSize;
  buttonRect.size.width = draggableViewSize;
  [reportGenerateButton setFrame:buttonRect];
  reportGenerateButton.layer.cornerRadius = _draggableView.layer.cornerRadius;
  [reportGenerateButton setTitle:draggableViewMessage
                        forState:UIControlStateNormal];
  [reportGenerateButton.titleLabel
      setFont:[UIFont boldSystemFontOfSize:draggableViewFontSize]];
  reportGenerateButton.titleLabel.textAlignment = NSTextAlignmentCenter;
  reportGenerateButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
  [reportGenerateButton addTarget:self
                           action:@selector(generateReport)
                 forControlEvents:UIControlEventTouchDownRepeat];
  [_draggableView addSubview:reportGenerateButton];
}

#pragma mark - Test Case Update -
- (BOOL)testCaseWithID:(NSString *)testCaseId
                inputs:(NSDictionary *)inputs
                status:(BOOL)status
              comments:(NSString *)comments {
  BOOL isReportUpdated = NO;
  if (!testCaseId.length) {
    /// Test case id should not be empty
    return isReportUpdated;
  }

  /// Read the test case releated content form the plist file.
  /// Exampe  Module : Login, Objecive : value, ExpectedResult : value
  NSDictionary *testCaseDetailDictionary =
      [_testCaseDictionary valueForKey:testCaseId];
  if (!testCaseDetailDictionary) {
    return isReportUpdated;
  }

  /// Create test case model and store it on the dictionary by using test case
  /// id.
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
- (void)generateReport {
  NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
  NSString *appName = info[keyOfBundleName];
  UIAlertView *testerNameAlertView =
      [[UIAlertView alloc] initWithTitle:appName
                                 message:alertMessage
                                delegate:self
                       cancelButtonTitle:alertOkButtonText
                       otherButtonTitles:nil, nil];
  testerNameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
  [testerNameAlertView show];
}

#pragma mark - Send Mail With Report -
- (void)openMailWithReport {
  _draggableView.hidden = YES;
  NSString *filePath = [TTPLReportFileGenerator reportFilePath];

  if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] &&
      [MFMailComposeViewController canSendMail]) {

    /// Get app name
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = info[keyOfBundleName];

    /// Open mail composer to send a report file
    MFMailComposeViewController *mailComposer =
        [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    NSString *subject = [NSString stringWithFormat:emailSubject, appName];
    NSString *mailBody = [NSString stringWithFormat:emailBody, appName];
    // Set the subject of email
    [mailComposer setSubject:subject];
    [mailComposer setMessageBody:mailBody isHTML:NO];
    [mailComposer addAttachmentData:[NSData dataWithContentsOfFile:filePath]
                           mimeType:mimeType
                           fileName:subject];
    [[UIApplication sharedApplication].keyWindow.rootViewController
        presentViewController:mailComposer
                     animated:YES
                   completion:nil];
  }
}

#pragma mark - Mail Composer Delegates -
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
  if (error) {
    NSLog(@"Mail compose error : %@", error);
  }
  if (result != MFMailComposeResultCancelled) {
    [_testResultDictionary removeAllObjects];
  }
  [controller dismissViewControllerAnimated:YES
                                 completion:^{
                                     _draggableView.hidden =
                                         !enableReportButton;
                                 }];
}

#pragma mark - Alert View Delegate -
- (void)alertView:(UIAlertView *)alertView
    didDismissWithButtonIndex:(NSInteger)buttonIndex {
  UITextField *textField = [alertView textFieldAtIndex:0];
  if (textField) {
    self.testerName = textField.text;
    if (!self.testerName.length) {
      self.testerName = notAvailableString;
    }
  }
  // Create Report file
  BOOL isReportGenerated = [TTPLReportFileGenerator
      generateReportStringWithTestCaseDictionary:_testResultDictionary];
  if (isReportGenerated) {
    /// Once file created remove all the existing testcase model from the
    /// dictionary

    [[TTPLTestReportManager sharedInstance] openMailWithReport];
  }
}

@end
