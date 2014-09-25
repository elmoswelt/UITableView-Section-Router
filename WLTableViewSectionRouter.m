//
//  WLTableViewSectionRouter.m
//  Wunderlist
//
//  The MIT License (MIT)
//
//  Created by Elmar Tampe on 2/15/13.
//
//  Copyright (c) 2013 6Wunderkinder GmbH
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "WLTableViewSectionRouter.h"


// ------------------------------------------------------------------------------------------


#define kDefaultKey               @"TableViewSectionControllerDefaultKey"
#define kDefaultSectionCount      1
#define kCellDefaultHeight        44.0


// ------------------------------------------------------------------------------------------


@interface WLTableViewSectionRouter()

@property (nonatomic, strong) NSMutableDictionary *sectionControllers;
@property (nonatomic, assign) NSUInteger sectionCount;

@end


// ------------------------------------------------------------------------------------------


@implementation WLTableViewSectionRouter

// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (id)initWithSectionCount:(NSUInteger)sectionCount
{
    if ((self = [self init]))
    {
        self.sectionCount = sectionCount;
    }
    return self;
}


- (id)init
{
    if ((self = [super init]))
    {
        self.sectionControllers = [[NSMutableDictionary alloc] init];
        self.sectionCount = kDefaultSectionCount;
    }
    return self;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Nonretaining Wrap Section Controller Access
// ------------------------------------------------------------------------------------------
- (void)setSectionController:(id<UITableViewDataSource, UITableViewDelegate>)object forKey:(id<NSCopying>)key
{
    if ([self.sectionControllers objectForKey:key] == nil)
    {
        NSValue *nonretainingWrapper = [NSValue valueWithNonretainedObject:object];
        [self.sectionControllers setObject:nonretainingWrapper forKey:key];
    }
    else
    {
        NSLog(@"Warning. The section was already used. The section controller got overriden.");
    }
}


- (id<UITableViewDataSource, UITableViewDelegate>)sectionControllerForKey:(id<NSCopying>)key
{
    id result = nil;

    NSValue *nonretainingWrapper = [self.sectionControllers objectForKey:key];
    if (nonretainingWrapper != nil)
    {
        result = [nonretainingWrapper nonretainedObjectValue];
    }

    return result;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Section Controller Setup
// ------------------------------------------------------------------------------------------
- (void)addSectionController:(id<UITableViewDataSource, UITableViewDelegate>)sectionController
                  forSection:(NSUInteger)section
{
    [self addSectionController:sectionController startSection:section stopSection:section];
}


- (void)addSectionController:(id<UITableViewDelegate, UITableViewDataSource>)sectionController
                startSection:(NSInteger)startSection
                 stopSection:(NSInteger)stopSection
{
    // Add section controller object for the specified section range.
    for (NSInteger section = startSection; section <= stopSection; section++)
    {
        NSNumber *sectionKey = [self sectionKeyForSection:section];
        [self setSectionController:sectionController forKey:sectionKey];
    }
}


- (void)addDefaultSectionController:(id<UITableViewDelegate, UITableViewDataSource>)defaultSectionController
{
    if ([self sectionControllerForKey:kDefaultKey] == nil)
    {
        [self setSectionController:defaultSectionController forKey:kDefaultKey];
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - Section Controller For Section
// ------------------------------------------------------------------------------------------
- (id<UITableViewDelegate, UITableViewDataSource>)sectionControllerForIndex:(NSUInteger)section
{
    id<UITableViewDelegate, UITableViewDataSource> sectionController = nil;

    if ((sectionController = [self sectionControllerForKey:[self sectionKeyForSection:section]]))
    {
        return sectionController;
    }
    else if ((sectionController = [self sectionControllerForKey:kDefaultKey]))
    {
        return sectionController;
    }
    else
    {
        NSLog(@"Section controller object not found.");
        return nil;
    };
}


- (NSNumber *)sectionKeyForSection:(NSUInteger)section
{
    return @(section);
}


// ------------------------------------------------------------------------------------------
#pragma mark - UITableViewDelegate Protocol Implementation
// ------------------------------------------------------------------------------------------
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    id<UITableViewDelegate> controller = [self sectionControllerForIndex:section];

    if ([controller respondsToSelector:@selector(tableView:viewForHeaderInSection:)])
    {
        return [controller tableView:tableView viewForHeaderInSection:section];
    }
    else
    {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    id<UITableViewDelegate> controller = [self sectionControllerForIndex:section];

    if ([controller respondsToSelector:@selector(tableView:heightForHeaderInSection:)])
    {
        return [controller tableView:tableView heightForHeaderInSection:section];
    }
    else
    {
        return 0.0;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<UITableViewDelegate> controller = [self sectionControllerForIndex:indexPath.section];

    if ([controller respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
    {
        [controller tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<UITableViewDelegate> controller = [self sectionControllerForIndex:indexPath.section];

    if ([controller respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)])
    {
        return [controller tableView:tableView editingStyleForRowAtIndexPath:indexPath];
    }
    else
    {
        return UITableViewCellEditingStyleNone;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<UITableViewDelegate> controller = [self sectionControllerForIndex:indexPath.section];

    if ([controller respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
    {
        return [controller tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    else
    {
        return kCellDefaultHeight;
    }
}


-               (NSIndexPath *)tableView:(UITableView *)tableView
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
                     toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    id<UITableViewDelegate> controller = [self sectionControllerForIndex:sourceIndexPath.section];

    SEL moveSelector = @selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:);

    if ([controller respondsToSelector:moveSelector])
    {
        return [controller tableView:tableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath
                 toProposedIndexPath:proposedDestinationIndexPath];
    }
    else
    {
        NSLog(@"Required Method. Please implement the method for correct reorder snap behaviour.");
        return nil;
    }
}


- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<UITableViewDelegate> controller = [self sectionControllerForIndex:indexPath.section];

    SEL selector = @selector(tableView:shouldShowMenuForRowAtIndexPath:);

    if ([controller respondsToSelector:selector])
    {
        return [controller tableView:tableView shouldShowMenuForRowAtIndexPath:indexPath];
    }
    else
    {
        return NO;
    }
}


- (BOOL)tableView:(UITableView *)tableView
 canPerformAction:(SEL)action
forRowAtIndexPath:(NSIndexPath *)indexPath
       withSender:(id)sender
{
    id<UITableViewDelegate> controller = [self sectionControllerForIndex:indexPath.section];

    SEL selector = @selector(tableView:canPerformAction:forRowAtIndexPath:withSender:);

    if ([controller respondsToSelector:selector])
    {
        return [controller tableView:tableView
                    canPerformAction:action
                   forRowAtIndexPath:indexPath
                          withSender:sender];
    }
    else
    {
        return NO;
    }
}


- (void)tableView:(UITableView *)tableView
    performAction:(SEL)action
forRowAtIndexPath:(NSIndexPath *)indexPath
       withSender:(id)sender
{
    id<UITableViewDelegate> controller = [self sectionControllerForIndex:indexPath.section];

    SEL selector = @selector(tableView:performAction:forRowAtIndexPath:withSender:);

    if ([controller respondsToSelector:selector])
    {
        [controller tableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = nil;

    id<UITableViewDelegate> controller = [self sectionControllerForIndex:section];
    if ([controller respondsToSelector:@selector(tableView:viewForFooterInSection:)])
    {
        footerView = [controller tableView:tableView viewForFooterInSection:section];
    }

    return footerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = 0;

    id<UITableViewDelegate> controller = [self sectionControllerForIndex:section];
    if ([controller respondsToSelector:@selector(tableView:heightForFooterInSection:)])
    {
        height = [controller tableView:tableView heightForFooterInSection:section];
    }

    return height;
}


// ------------------------------------------------------------------------------------------
#pragma mark - UITableViewDataSource Protocoll Implementation
// ------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self sectionControllerForIndex:indexPath.section] tableView:tableView cellForRowAtIndexPath:indexPath];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self sectionControllerForIndex:section] tableView:tableView numberOfRowsInSection:section];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionCount;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<UITableViewDataSource> controller = [self sectionControllerForIndex:indexPath.section];

    if ([controller respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)])
    {
        return [controller tableView:tableView canMoveRowAtIndexPath:indexPath];
    }
    else
    {
        return NO;
    }
}


-   (void)tableView:(UITableView *)tableView
 moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
        toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id<UITableViewDataSource> controller = [self sectionControllerForIndex:sourceIndexPath.section];

    if ([controller respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)])
    {
        [[self sectionControllerForIndex:sourceIndexPath.section] tableView:tableView
                                                         moveRowAtIndexPath:sourceIndexPath
                                                                toIndexPath:destinationIndexPath];
    }
}

@end
