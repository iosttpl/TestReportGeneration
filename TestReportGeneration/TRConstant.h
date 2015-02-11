//
//  TRConstant.h
//  TestReportGeneration
//
//  Created by Subramanian on 2/10/15.
//  Copyright (c) 2015 Tarento Technologies Pvt Ltd. All rights reserved.
//

#ifndef TestReportGeneration_TRConstant_h
#define TestReportGeneration_TRConstant_h

//*****************************************************************************//
//  Configuration
//*****************************************************************************//

#pragma mark - Configuration
// You want to enable reporter then set this flag TRUE
static const BOOL disableReportGenerator = NO;
/// Enable draggable window button to generate report
static const BOOL enableReportButton = YES;

//*****************************************************************************//
//  Report Manager
//*****************************************************************************//

#pragma mark - Report Manager -

/// Plist
static NSString *const testCaseListFileName = @"TTPLTestCase.plist";
static NSString *const category = @"Module";
static NSString *const objective = @"Objective";
static NSString *const expectedResult = @"ExpectedResult";

/// Device Model List
static NSString *const deviceModelListFileName = @"DeviceModelList.plist";

/// Email
static NSString *const emailSubject = @"%@ - Test Report";
static NSString *const emailBody =
    @"Hi, \n \n %@ test report has been generated. "
    @"Please find an attachment here. \n \n -------- \n Thanks";

static NSString *const mimeType = @"text/html";

static const NSInteger draggableViewSize = 75;
static const float draggableViewFontSize = 14;
static const float draggableViewCornorRadius = 38.0f;
static NSString *const draggableViewMessage = @"Generate Report";

//*****************************************************************************//
//  AlertMessage
//*****************************************************************************//
static NSString *const alertMessage = @"\n Tested by : ";
static NSString *const alertOkButtonText = @"Ok";

//*****************************************************************************//
//  Report Generator
//*****************************************************************************//

#pragma mark - Report Generator file -
/// Template file name
static NSString *const templateFileName = @"TTPLReportTemplate.html";

static NSString *const reportFileName = @"%@-TestReport.html";

/// Placeholder on the template file
static NSString *const templatePlaceHolderAppName = @"#AppName#";
static NSString *const templatePlaceHolderVersion = @"#VersionNumber#";
static NSString *const templatePlaceHolderDate = @"#Date#";
static NSString *const templatePlaceHolderName = @"#Name#";
static NSString *const templatePlaceHolderDevice = @"#Device#";
static NSString *const templatePlaceHolderTestCase = @"<TR></TR>";

/// Test case row.
static NSString *const tableRow =
    @"<TR> <TD CLASS =\"testResultTableRow\"> %@ </TD>"
    @"<TD CLASS =\"testResultTableRow\"> %@ </TD>"
    @"<TD CLASS =\"testResultTableRow\"> %@ </TD>"
    @"<TD CLASS =\"testResultTableRow\"> %@ </TD>"
    @"<TD CLASS =\"testResultTableRow\"> %@ </TD>" @"%@"
    @"<TD CLASS =\"testResultTableRow\"> %@ </TD> </TR> <TR></TR>";

/// Status tag need to update the color based on the test case success/fail
static NSString *const statusTag = @"<TD CLASS =\"%@\"> %@ </TD>";

/// CSS name for PASS/FAIL
static NSString *const statusPassCSS = @"testResultPass";
static NSString *const statusFailCSS = @"testResultFail";

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
static NSString *const iOSName = @"iOS ";

#endif
