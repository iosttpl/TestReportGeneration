//
//  TTPLTestCase.h
//  TestReportGeneration
//
//  Created by Subramanian on 2/9/15.
//  Copyright (c) 2015 Tarento Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTPLTestCase : NSObject

@property(nonatomic, strong) NSString *tcId;
@property(nonatomic, strong) NSString *tcCategory;
@property(nonatomic, strong) NSString *tcObjective;
@property(nonatomic, strong) NSString *tcExpectedResult;
@property(nonatomic, strong) NSDictionary *tcInputs;
@property(nonatomic, assign, getter=isTestCasePassed) BOOL tcStatus;
@property(nonatomic, strong) NSString *tcComments;

@end
