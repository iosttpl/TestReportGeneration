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

  /// TTPLTestCase.plist file content.
  NSDictionary *_testCaseDictionary;

  /// Draggable button
  UIButton *_draggableButton;

  /// Draggable button max and min co-ordinates
  CGFloat _draggableButtonMinX;
  CGFloat _draggableButtonMinY;

  CGFloat _draggableButtonMaxX;
  CGFloat _draggableButtonMaxY;
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
      /// Default properties fo draggable view.
      _draggableViewBackGroundColor = [UIColor lightGrayColor];
      _draggableViewMessage = draggableViewMessage;
      _draggableViewTextColor = [UIColor whiteColor];

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
  [self calcualteButtonMaxMinCoordinates];

  _draggableButton = [UIButton buttonWithType:UIButtonTypeCustom];
  CGRect buttonRect =
      CGRectMake(CGRectGetMaxX(keyWindow.frame) - draggableViewSize,
                 CGRectGetMaxY(keyWindow.frame) - draggableViewSize,
                 draggableViewSize, draggableViewSize);
  [_draggableButton setFrame:buttonRect];
  [_draggableButton setTitle:self.draggableViewMessage
                    forState:UIControlStateNormal];
  [_draggableButton.titleLabel
      setFont:[UIFont boldSystemFontOfSize:draggableViewFontSize]];
  [_draggableButton addTarget:self
                       action:@selector(generateReport)
             forControlEvents:UIControlEventTouchDownRepeat];
  [_draggableButton addTarget:self
                       action:@selector(wasDragged:withEvent:)
             forControlEvents:UIControlEventTouchDragInside];
  _draggableButton.backgroundColor = self.draggableViewBackGroundColor;
  [_draggableButton setTitleColor:self.draggableViewTextColor
                         forState:UIControlStateNormal];
  _draggableButton.layer.cornerRadius = draggableViewCornorRadius;
  _draggableButton.titleLabel.textAlignment = NSTextAlignmentCenter;
  _draggableButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
  [keyWindow addSubview:_draggableButton];
}

- (void)calcualteButtonMaxMinCoordinates {
  UIWindow *keyWindow = [UIApplication sharedApplication].windows[0];
  _draggableButtonMinX = keyWindow.frame.origin.x;
  _draggableButtonMaxX = keyWindow.frame.size.width;
  _draggableButtonMinY = keyWindow.frame.origin.y;
  _draggableButtonMaxY = keyWindow.frame.size.height;
}

- (void)wasDragged:(UIButton *)button withEvent:(UIEvent *)event {
  // get the touch
  UITouch *touch = [[event touchesForView:button] anyObject];

  // get delta
  CGPoint previousLocation = [touch previousLocationInView:button];
  CGPoint location = [touch locationInView:button];
  CGFloat delta_x = location.x - previousLocation.x;
  CGFloat delta_y = location.y - previousLocation.y;

  // move button
  CGFloat moveToX = button.center.x + delta_x;
  CGFloat moveToY = button.center.y + delta_y;

  // Min & Max coordinates check.
  if (moveToX < _draggableButtonMinX) {
    moveToX = _draggableButtonMinX;
  } else if (moveToX > _draggableButtonMaxX) {
    moveToX = _draggableButtonMaxX;
  }

  if (moveToY < _draggableButtonMinY) {
    moveToY = _draggableButtonMinY;
  } else if (moveToY > _draggableButtonMaxY) {
    moveToY = _draggableButtonMaxY;
  }

  button.center = CGPointMake(moveToX, moveToY);
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

  isReportUpdated = YES;

  /// If the test case failed before then no need to update test case with the
  /// current current status.
  TTPLTestCase *testCase = _testResultDictionary[testCaseId];
  if (testCase) {
    if (!testCase.tcStatus) {
      return isReportUpdated;
    } else {
      /// Update dynamic inputs.
      testCase.tcInputs = inputs;
      testCase.tcStatus = status;
      testCase.tcComments = comments;
    }
  } else {
    /// Create test case model and store it on the dictionary by using test case
    /// id.
    testCase = [[TTPLTestCase alloc] init];
    testCase.tcId = testCaseId;
    testCase.tcCategory = testCaseDetailDictionary[category];
    testCase.tcObjective = testCaseDetailDictionary[objective];
    testCase.tcExpectedResult = testCaseDetailDictionary[expectedResult];
    testCase.tcInputs = inputs;
    testCase.tcStatus = status;
    testCase.tcComments = comments;
  }
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
  _draggableButton.hidden = YES;
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
                                     _draggableButton.hidden =
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

#pragma mark - Draggable View Property -
- (void)setDraggableViewBackGroundColor:
            (UIColor *)draggableViewBackGroundColor {
  _draggableViewBackGroundColor = draggableViewBackGroundColor;
  [_draggableButton setBackgroundColor:draggableViewBackGroundColor];
}

- (void)setDraggableViewMessage:(NSString *)draggableViewMessage {
  _draggableViewMessage = draggableViewMessage;
  [_draggableButton setTitle:draggableViewMessage
                    forState:UIControlStateNormal];
}

- (void)setDraggableViewTextColor:(UIColor *)draggableViewTextColor {
  _draggableViewTextColor = draggableViewTextColor;
  [_draggableButton setTitleColor:draggableViewTextColor
                         forState:UIControlStateNormal];
}

@end
