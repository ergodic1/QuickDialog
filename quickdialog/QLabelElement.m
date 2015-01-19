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


#import "QLabelElement.h"

@implementation QLabelElement {
@private
    UITableViewCellAccessoryType _accessoryType;
}


@synthesize image = _image;
@synthesize value = _value;
@synthesize accessoryType = _accessoryType;
@synthesize keepSelected = _keepSelected;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.subtitleLines = 1;
    }
    return self;
}

- (QLabelElement *)initWithTitle:(NSString *)title Value:(id)value {
    self = [super init];
    _title = title;
    self.accessibilityIdentifier = title;
    self.accessibilityLabel = title;
    [self setIsAccessibilityElement:YES];
    _value = value;
    _keepSelected = YES;
    self.subtitleLines = 1;
    return self;
}

-(void)setImageNamed:(NSString *)name {
    if(name != nil) {
        self.image = [UIImage imageNamed:name];
    }
}

- (NSString *)imageNamed {
    return nil;
}

-(void)setIconNamed:(NSString *)name {
#if __IPHONE_7_0
    if ([self.image respondsToSelector:@selector(imageWithRenderingMode:)] && name != nil) {
        self.image = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
#endif
}


- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {
    QTableViewCell *cell = (QTableViewCell *) [super getCellForTableView:tableView controller:controller];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = _title;
    cell.detailTextLabel.text = [_value description];
    cell.subtitle.text = _subtitle;
    cell.subtitleLines = _subtitleLines;
    cell.imageView.image = _image;
    cell.accessoryType = _accessoryType != UITableViewCellAccessoryNone ? _accessoryType : self.controllerAccessoryAction != nil ? UITableViewCellAccessoryDetailDisclosureButton : ( self.sections!= nil || self.controllerAction!=nil ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone);
    cell.selectionStyle = self.sections!= nil || self.controllerAction!=nil || self.onSelected!=nil ? UITableViewCellSelectionStyleBlue: UITableViewCellSelectionStyleNone;
    return cell;
}


- (CGFloat)getRowHeightForTableView:(QuickDialogTableView *)tableView {
    if( _subtitle != nil ) {
        return self.height > 0 ? self.height : 60 + (MAX(_subtitleLines-1, 0)*18);
    }
    return [super getRowHeightForTableView:tableView];
}


- (void)selected:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller indexPath:(NSIndexPath *)path {
    [super selected:tableView controller:controller indexPath:path];
    if (!self.keepSelected)
        [tableView deselectRowAtIndexPath:path animated:YES];
}


@end
