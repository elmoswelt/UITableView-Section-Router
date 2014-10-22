//
//  WLTableViewSectionRouter.h
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


#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>


/** This class implements the routing logic for sctions in a UITableView. Each section can have its own
 <UITableViewDataSource> and <UITableViewDelegate> implementation in one file which gets routed by the
 WLTableViewSectionRouter. The router just routes the calls. This class can be used as it is or can be subclassed
 to extend the <UITableViewDataSource> and <UITableViewDelegate> for special needs.

 The router can also run in mixed mode where the view controller which handles the TableView can do some of the
 <UITableViewDataSource> and <UITableViewDelegate> logic for special sections which we call the default sections.
 The default sections are all sections which are not set as DEFAULT SECTION CONTROLLER. If you do not need the
 default section set it to <nil> and set the totalSectionCount.*/

@interface WLTableViewSectionRouter : NSObject <UITableViewDelegate, UITableViewDataSource>

/** Initialize a section router with the amount of sections to route. */
- (instancetype)initWithSectionCount:(NSUInteger)sectionCount;

/** Designated Initialzer. Always initialzes the Router with one section as defailt. */
- (instancetype)init;

/** Add a default section controller. If the ViewController which handles the tableView will do some of the
 <UITableViewDataSource> and <UITableViewDelegate> logic, use this method and add self as parameter to it. */
- (void)addDefaultSectionController:(id<UITableViewDataSource, UITableViewDelegate>)defaultSectionController;

/** Add a section controller for one or a range of sections. Specify the sections by passing in the correct section
 numbers. You need to specify a start and a stop value. These values can be the same to set a controller just for
 one section. If a section controller should handle more than one section the start and stop values need to
 differ.*/
- (void)addSectionController:(id<UITableViewDataSource, UITableViewDelegate>)sectionController
                startSection:(NSInteger)startSection
                 stopSection:(NSInteger)stopSection;

/** Add a section controller which just handles one section. */
- (void)addSectionController:(id<UITableViewDataSource, UITableViewDelegate>)sectionController
                  forSection:(NSUInteger)section;


/** Returns an section controller for the specified section. This method should be used when subclassing the
 controller and is never used as an instance method. */
- (id<UITableViewDelegate, UITableViewDataSource>)sectionControllerForIndex:(NSUInteger)section;

@end
