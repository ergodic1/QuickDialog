//
//  QSortingDelegate.h
//  QuickDialog
//
//  Created by Joe Cole on 1/05/14.
//
//

#import <Foundation/Foundation.h>

@protocol QSortingDelegate <NSObject>

- (void)moveElementFromRow:(NSUInteger)from toRow:(NSUInteger)to;

- (void)removeElementForRow:(NSInteger)integer;

@end
