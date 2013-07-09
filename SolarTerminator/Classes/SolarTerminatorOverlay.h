//
//  SolarTerminatorOverlayView.h
//  SolarTerminator
//
//  Created by Daniel Brooks on 7/8/13.
//  Copyright (c) 2013 Daniel Brooks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SolarTerminatorOverlay : NSObject <MKOverlay>


//@property (nonatomic) CLLocationCoordinate2D origin;
@property (nonatomic, retain) MKPolygon *polygon;

//@property (nonatomic) MKMapRect rect;

-(MKMapRect)boundingMapRect;
-(CLLocationCoordinate2D)coordinate;

@end
