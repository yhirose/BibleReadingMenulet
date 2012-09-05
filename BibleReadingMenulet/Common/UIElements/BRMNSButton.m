//
//  BRMNSButton.m
//  BibleReadingMenulet
//
//  Created by Tomohisa Takaoka on 9/5/12.
//  Copyright (c) 2012 Yuji Hirose. All rights reserved.
//

#import "BRMNSButton.h"

@implementation BRMNSButton

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) awakeFromNib {
    [super awakeFromNib];
    [self setTitleWithMnemonic:NSLocalizedString(self.title, nil)];
}
@end
