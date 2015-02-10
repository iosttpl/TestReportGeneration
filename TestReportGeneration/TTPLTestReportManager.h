//
//  TTPLTestReportManager.h
//  TestReportGeneration
//
//  Created by Subramanian on 2/9/15.
//  Copyright (c) 2015 Tarento Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

/*!
 @discussion This is the manager class to handle the report generation and
 update the report list with the new test cases.

 ## Version information

 __Version__: 1.0

 __Found__: 2/9/15

 __Last update__: 2/9/15

 __Developer__: Subramanian, Tarento Technologies Pvt Ltd.

 */

@interface TTPLTestReportManager
    : NSObject <MFMailComposeViewControllerDelegate>

/// @name Getter

/*!
 @abstract Returns the shared instance of the test report manager class.

 @return Return the instancetype of the TTPLReportManager

 @since 1.0
 */
+ (instancetype)sharedInstance;

/*!
 @abstract Add / Update a test case list.

 @discussion This will create a new TTPLTestCase model with the given values.
 And this will update the test case dictionary with the model. Test case id is
 the key of the Dictionary, So it will be unique. This will read the test case
 module and objectives from the TTPLTestCase.plist file.

 @param testCaseId Test case id.
 @param inputs Dictionary of input values. (Example : Username : value, Password
 : value). If no input values then send nil
 @param status TRUE/FALSE of the test case status.
 @param comments Its optional. Send a string if there any comments.

 @return Returns TREU if the test case add/updated on the list. Else FALSE.

 @since 1.0
 */
- (BOOL)testCaseWithID:(NSString *)testCaseId
                inputs:(NSDictionary *)inputs
                status:(BOOL)status
              comments:(NSString *)comments;

/*!
 @abstract This will generate the report HTML file

 @discussion This will read the report template file and update the file with
 the list of test cases. Finally create a HTML report file.

 @return Returns TREU if the report file is created Else FALSE.

 @since 1.0
 */
- (BOOL)generateReport;

/*!
 @abstract Open a mail application along with the created test report file.

 @since 1.0
 */
- (void)openMailWithReport;

@end
