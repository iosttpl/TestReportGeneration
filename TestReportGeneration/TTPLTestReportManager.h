//
//  TTPLTestReportManager.h
//  TestReportGeneration
//
//  Created by Subramanian on 2/9/15.
//  Copyright (c) 2015 Tarento Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTPLTestReportManager : NSObject

+ (instancetype)sharedInstance;

- (BOOL)testCaseWithID:(NSString *)testCaseId
                inputs:(NSDictionary *)inputs
                status:(BOOL)status
              comments:(NSString *)comments;

- (BOOL)generateReport;

@end
