//
//  MRC.h
//  自动释放池
//
//  Created by WengHengcong on 2019/1/4.
//  Copyright © 2019 WengHengcong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BFPerson.h"

@interface MRC : NSObject

@property (nonatomic, retain) BFPerson *person;

- (void)test;
- (void)test1;
- (void)test2;
- (void)test3;

@end

