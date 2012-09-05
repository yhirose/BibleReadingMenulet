//
//  BRMNSMenuItem.m
//  BibleReadingMenulet
//
//  Created by Tomohisa Takaoka on 9/5/12.
//  Copyright (c) 2012 Yuji Hirose. All rights reserved.
//

#import "BRMNSMenuItem.h"

@implementation BRMNSMenuItem
-(void) awakeFromNib {
    [super awakeFromNib];
    self.title = NSLocalizedString(self.title, nil);
}

@end
