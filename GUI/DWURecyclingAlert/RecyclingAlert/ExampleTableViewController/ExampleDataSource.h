//
//  ExampleDataSource.h
//  RecyclingAlert
//
//  Created by Di Wu on 6/7/15.
//  Copyright (c) 2015 Di Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UITableViewController.h>

@class ExampleItem;

typedef void (^ConfigureExampleCell)(id, ExampleItem *);

@interface ExampleDataSource : NSObject <UITableViewDataSource>

- (instancetype)initWithItems: (NSArray *)itemsArr cellIdentifier: (NSString *)cellIdentifier configureCellBlock: (ConfigureExampleCell)configureExampleCell;

@end
