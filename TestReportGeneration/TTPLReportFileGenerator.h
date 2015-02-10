//
//  TTPLReportHTMLGenerator.h
//  TestReportGeneration
//
//  Created by Subramanian on 2/9/15.
//  Copyright (c) 2015 Tarento Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTPLReportFileGenerator : NSObject

+ (BOOL)generateReportStringWithTestCaseDictionary:
        (NSMutableDictionary *)dictionary;

@end
