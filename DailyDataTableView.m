//
//  DailyDataTableView.m
//  Bartender
//
//  Created by Tom Houpt on 12/11/10.
//
//

#import "DailyDataTableView.h"

@implementation DailyDataTableView

- (void) textDidEndEditing:(NSNotification *)notification;
{
    [super textDidEndEditing:notification];
    
    int textMovement = [[notification.userInfo valueForKey:@"NSTextMovement"] intValue];
    if (NSReturnTextMovement == textMovement) {
        
        NSText *fieldEditor = notification.object;
        
        // The row and column for the cell that just ended editing
        NSInteger row = [self rowAtPoint:fieldEditor.frame.origin];
        NSInteger col = [self columnAtPoint:fieldEditor.frame.origin];
        
        if (++row >= self.numberOfRows) {
            row= 0;
            if (++col >= self.numberOfColumns) return;
        }
        
        [self selectRowIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger)row] byExtendingSelection:NO];
        [self editColumn:col row:row withEvent:nil select:YES];
    }
}

@end
