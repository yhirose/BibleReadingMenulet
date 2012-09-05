//
//  BRMNSTableColumn.m
//  BibleReadingMenulet
//
//  Created by Tomohisa Takaoka on 9/5/12.
//  Copyright (c) 2012 Yuji Hirose. All rights reserved.
//

#import "BRMNSTableColumn.h"

@implementation BRMNSTableColumn
-(void) awakeFromNib {
    [super awakeFromNib];
    [self.headerCell setStringValue:NSLocalizedString([self.headerCell stringValue], nil)];
}

@end
