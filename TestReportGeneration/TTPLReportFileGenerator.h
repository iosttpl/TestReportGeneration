//
//  TTPLReportHTMLGenerator.h
//  TestReportGeneration
//
//  Created by Subramanian on 2/9/15.
//  Copyright (c) 2015 Tarento Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @discussion Generates a HTML content with the test case results.

 ## Version information

 __Version__: 1.0

 __Found__: 2/9/15

 __Last update__: 2/9/15

 __Developer__: Subramanian, Tarento Technologies Pvt Ltd.

 */
@interface TTPLReportFileGenerator : NSObject

/// @name Getter

/*!
 @abstract Generate a HTML report file.

 @param dictionary Dictionary of TTPLTestCase models.

 @return Return TRUE/FALSE base on file created or not.

 @since 1.0
 */
+ (BOOL)generateReportStringWithTestCaseDictionary:
        (NSMutableDictionary *)dictionary;

/*!
 @abstract Returns the file path of the Test Report file.

 @return Returns the file path of the Test Report file.

 @since 1.0
 */
+ (NSString *)reportFilePath;

@end
