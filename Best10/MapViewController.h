//
//  MapViewController.h
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//
//  Will display a thumbnail in leftCalloutAccessoryView if the
//   annotation implements the method "thumbnail" (return UIImage)

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CHDraggingCoordinator.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CHDraggingCoordinatorDelegate>

// a more powerful MapViewController might make mapView private
// and instead make some methods public to add/remove annotations
// (so that it might get involved when annotations are added/removed)
// this is a simple MapViewController though
@property (strong, nonatomic) CHDraggingCoordinator *draggingCoordinator;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic) bool  needUpdateRegion;
@property (nonatomic) bool isFinishedLoading;
- (void)updateRegion:(NSNumber *)i;
- (void)notifyMapViewThatMOCChanged;

@end
