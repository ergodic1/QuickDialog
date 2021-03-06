//                                
// Copyright 2011 ESCOZ Inc  - http://escoz.com
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this 
// file except in compliance with the License. You may obtain a copy of the License at 
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF 
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

#import "QuickDialogTableView.h"
#import "QuickDialog.h"
#import "QuickDialogDelegate.h"

@interface QuickDialogTableView ()
@end

@implementation QuickDialogTableView {
    BOOL _deselectRowWhenViewAppears;
}

@synthesize root = _root;
@synthesize deselectRowWhenViewAppears = _deselectRowWhenViewAppears;

- (QuickDialogController *)controller {
    return _controller;
}

- (QuickDialogTableView *)initWithController:(QuickDialogController *)controller {
    self = [super initWithFrame:CGRectMake(0, 0, 0, 0) style:controller.root.grouped ? UITableViewStyleGrouped : UITableViewStylePlain];
    if (self!=nil){
        self.controller = controller;
        self.root = _controller.root;
        self.deselectRowWhenViewAppears = YES;

        self.quickDialogDataSource = [[QuickDialogDataSource alloc] initForTableView:self];
        self.dataSource = self.quickDialogDataSource;

        self.quickDialogTableDelegate = [[QuickDialogTableDelegate alloc] initForTableView:self];
        self.delegate = self.quickDialogTableDelegate;

        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

-(void)setRoot:(QRootElement *)root{
    _root = root;
    int index = 0;
    for (QSection *section in _root.sections) {
        if( index == 0 ){
            // this solves the problem of the first section being offset by ~30 pixels on modern devices
            if ([[UIDevice currentDevice].systemVersion floatValue] >= 7){
                // the controller is nil when we are embedded in a uiview
                if( section.contentOffsetOverride != 0 ){
                    self.contentInset = UIEdgeInsetsMake(section.contentOffsetOverride, 0, 0, 0);
                }else {
                    self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                }
            }
            index++;
        }
        if (section.needsEditing){
            [self setEditing:YES animated:YES];
            self.allowsSelectionDuringEditing = YES;
        }
    }
    // this fixes a bug where when setroot is the current root, it doesnt retain seletion after changing for some reason.
    self.allowsSelection = YES;
    [self reloadData];
}

- (void)reloadData
{
    [self applyAppearanceForRoot:self.root];
    [super reloadData];
}


- (void)applyAppearanceForRoot:(QRootElement *)element {
    if (element.appearance.tableGroupedBackgroundColor !=nil){
        
        self.backgroundColor = element.grouped 
                ? element.appearance.tableGroupedBackgroundColor
                : element.appearance.tableBackgroundColor;

        self.backgroundView = element.appearance.tableBackgroundView;
    }
    if (element.appearance.tableBackgroundView!=nil && !element.grouped)
        self.backgroundView = element.appearance.tableBackgroundView;

    if (element.appearance.tableGroupedBackgroundView!=nil && element.grouped)
        self.backgroundView = element.appearance.tableGroupedBackgroundView;

    if (element.appearance.tableSeparatorColor!=nil)
        self.separatorColor = element.appearance.tableSeparatorColor;

}

- (NSIndexPath *)indexForElement:(QElement *)element {
    for (int i=0; i< [_root.sections count]; i++){
        QSection * currSection = [_root.sections objectAtIndex:(NSUInteger) i];

        for (int j=0; j< [currSection.elements count]; j++){
            QElement *currElement = [currSection.elements objectAtIndex:(NSUInteger) j];
            if (currElement == element){
                return [NSIndexPath indexPathForRow:j inSection:i];
            }
        }
    }
    return NULL;
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    super.contentInset = contentInset;
    self.scrollIndicatorInsets = contentInset;
}


- (UITableViewCell *)cellForElement:(QElement *)element {
    if (element.hidden)
        return nil;
    UITableViewCell *cell = [self cellForRowAtIndexPath:[element getIndexPath]];
    cell.accessibilityLabel = element.accessibilityLabel;
    cell.accessibilityIdentifier = cell.accessibilityIdentifier;
    return cell;
}

- (void)deselectRows
{
    NSArray *selected = nil;
    if ([self indexPathForSelectedRow]!=nil && _deselectRowWhenViewAppears){
        NSIndexPath *selectedRowIndex = [self indexPathForSelectedRow];
        selected = [NSArray arrayWithObject:selectedRowIndex];
        [self reloadRowsAtIndexPaths:selected withRowAnimation:UITableViewRowAnimationNone];
        [self selectRowAtIndexPath:selectedRowIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self deselectRowAtIndexPath:selectedRowIndex animated:YES];
    };
}

- (void)reloadCellForElements:(QElement *)firstElement, ... {
    va_list args;
    va_start(args, firstElement);
    NSMutableArray *indexes = [[NSMutableArray alloc] init];
    QElement * element = firstElement;
    while (element != nil) {
        if (!element.hidden && !element.parentSection.hidden)
            [indexes addObject:element.getIndexPath];
        element = va_arg(args, QElement *);
    }
    [self reloadRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationNone];

    va_end(args);
}


- (void)reloadRowHeights
{
    [self beginUpdates];
    [self endUpdates];
}

- (void)endEditingOnVisibleCells
{
    for (UITableViewCell *cell in self.visibleCells)
        if (cell.isEditing)
            [cell endEditing:YES];

}
@end
