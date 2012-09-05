//
//  BRMNSMenu.m
//  BibleReadingMenulet
//
//  Created by Tomohisa Takaoka on 9/5/12.
//  Copyright (c) 2012 Yuji Hirose. All rights reserved.
//

#import "BRMNSMenu.h"

@implementation BRMNSMenu
-(void) awakeFromNib {
    [super awakeFromNib];
    self.title = NSLocalizedString(self.title, nil);
}
@end
