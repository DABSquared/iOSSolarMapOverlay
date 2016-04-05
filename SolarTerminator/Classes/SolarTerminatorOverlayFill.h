//
//  SolarTerminatorOverlayView.h
//  SolarTerminator
//
//  Created by Daniel Brooks on 7/8/13.
//  Copyright (c) 2013 Daniel Brooks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SunPosition.h"
#ifndef kCFCoreFoundationVersionNumber_iOS_7_0
#define kCFCoreFoundationVersionNumber_iOS_7_0 847.2
#endif

@interface SolarTerminatorOverlayFill : NSObject<MKOverlay>


//@property (nonatomic) CLLocationCoordinate2D origin;
@property (nonatomic, retain) MKPolylineRenderer *polygon;

-(MKMapRect)boundingMapRect;
-(CLLocationCoordinate2D)coordinate;
-(NSMutableArray *)sunPoints:(NSDate *)date;
-(void)setDate:(NSDate *)date;

@end
