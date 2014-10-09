//
//  MapViewController.m
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "MapViewController.h"
#import "MyCLLocationManager.h"
#import "AppDelegate.h"
#import "CHAvatarView.h"
#import "CHDraggableView+Avatar.h"
#import "ChatViewController.h"
#import "FXLabel.h"
@interface MapViewController ()
@end

@implementation MapViewController

// sets up self as the MKMapView's delegate
// notes (one time only) that we should zoom in on our annotations

- (UIViewController *)draggingCoordinator:(CHDraggingCoordinator *)coordinator viewControllerForDraggableView:(CHDraggableView *)draggableView
{
    ChatViewController *vc = (ChatViewController *) [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"JS Chat View"];
    vc.friend = draggableView.friend;
    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isFinishedLoading = false;
    self.mapView.delegate = self;
    self.needUpdateRegion = YES;
    self.mapView.showsUserLocation=false;
       _draggingCoordinator = [[CHDraggingCoordinator alloc] initWithWindow:[(AppDelegate *)[UIApplication sharedApplication].delegate window] draggableViewBounds:CGRectMake(0,0,66,66)];
    
    _draggingCoordinator.delegate = self;
    _draggingCoordinator.snappingEdge = CHSnappingEdgeBoth;
    UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(didTapMap:)];
    [self.draggingCoordinator.backgroundView addGestureRecognizer:tapRec];
    CLLocation *loc = [MyCLLocationManager sharedSingleton].locationManager.location;
    
    
    
}


-(void)notifyMapViewThatMOCChanged{
    
    
        int64_t delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (self.draggingCoordinator.state != CHInteractionStateConversation && (self.draggingCoordinator.placeholderCoordinate.latitude==0.0) ) {
                
                [self refreshMapView];
                
            }else if(self.draggingCoordinator.state != CHInteractionStateConversation){
                self.draggingCoordinator.placeholderCoordinate=CLLocationCoordinate2DMake(0.0, 0.0);
            }
        });
}

-(void)refreshMapView{

    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    NSArray *friends = [self.fetchedResultsController fetchedObjects];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:friends];
}
// when someone touches on a pin, this gets called
// all it does is set the thumbnail (if the annotation has one)
//   in the leftCalloutAccessoryView (if that is a UIImageView)

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[UIView class]]) {
        
        for (MKAnnotationView *an in mapView.selectedAnnotations) {
            //[mapView deselectAnnotation:an animated:NO];
            /* this happens automatically
            if([an isKindOfClass:[CHAvatarView class]])
            {
                [(CHAvatarView *)an showSmallView];
            } http://stackoverflow.com/questions/15831612/custom-callout-in-mkmapview-in-ios
             */
        }
        // Hide another annotation if it is shown
        /*if (mapView.selectedAnnotationView != nil && [mapView.selectedAnnotationView isKindOfClass:[CHAvatarView class]] && mapView.selectedAnnotationView != view) {
            [mapView.selectedAnnotationView showSm];
        }
        mapView.selectedAnnotationView = view;
        
        //WolfAnnotationView *annotationView = (WolfAnnotationView *)view;
        
        // This just adds *calloutView* as a subview
        
        *//* Here the trickiest piece of code goes */
        
        /* 1. We capture _annotation's (not callout's)_ frame in its superview's (map's!) coordinate system resulting in something like (CGRect){4910547.000000, 2967852.000000, 23.000000, 28.000000} The .origin.x and .origin.y are especially important! */
       
    }/*
    
    
    if ([view.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)(view.leftCalloutAccessoryView);
        if ([view.annotation respondsToSelector:@selector(thumbnail)]) {
            // this should be done in a different thread!
            imageView.image = [view.annotation performSelector:@selector(thumbnail)];
        }
    }*/
}




- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    NSNumber *latitude = [[NSNumber alloc] initWithDouble:userLocation.location.coordinate.latitude ];
    NSNumber *longitude = [[NSNumber alloc] initWithDouble:userLocation.location.coordinate.longitude ];
    NSArray *array = @[latitude ,longitude];
    if (userLocation.location.horizontalAccuracy > 0) {
        [mapView setCenterCoordinate:CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue)];
        
        [[NSUserDefaults standardUserDefaults] setValue:array forKey:@"current_coordinates"];
    }
    
}



-(void)didTapMap:(id)__unused sender{
    
    if (self.draggingCoordinator.state == CHInteractionStateConversation) {
        // put this crap in here because double taps were killing heads
        self.mapView.zoomEnabled = YES;
        self.mapView.scrollEnabled = YES;
        self.mapView.userInteractionEnabled = YES;
        
        [self.draggingCoordinator dismissPresentedNavigationController];
        
    }
}

// the MKMapView calls this to get the MKAnnotationView for a given id <MKAnnotation>
// our implementation returns a standard MKPinAnnotation
//   which has callouts enabled
//   and which has a leftCalloutAccessory of a UIImageView
//   and a rightCalloutAccessory of a detail disclosure button
//     (but only if delegate responds to mapView:annotationView:calloutAccessoryControlTapped:)

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *reuseId = @"MapViewController";
    
    
    //CHDraggableView *view = (CHDraggableView*)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    
    
    //if (!view) {
        if (![annotation isKindOfClass:MKUserLocation.class]) {
            
            //CHDraggableView *view = [self makeCHDraggableViewForThisMapWithAnnotaion:annotation andReuseID:reuseId andMapView:mapView];
            
            
        }/*else{
            // this is the current location annotation
            view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
            
        }*/
        
         /*if ([annotation coordinate].latitude == [(NSNumber *)[coords objectAtIndex:0] doubleValue] && [annotation coordinate].longitude ==[(NSNumber *)[coords objectAtIndex:1] doubleValue] ) {
         
             // this is the current location annotation
             view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
         
         
         }else{*/
       CHDraggableView *view = [self makeCHDraggableViewForThisMapWithAnnotaion:annotation andReuseID:reuseId andMapView:mapView];
         //}
        view.annotation = annotation;

    //}
    
    
    return view;
}



-(CHDraggableView *)makeCHDraggableViewForThisMapWithAnnotaion:(id<MKAnnotation>)annotation andReuseID:(NSString *)reuseId andMapView:(MKMapView *)mapView
{
    
    CHDraggableView *headView = [[CHDraggableView alloc] initWithFrame:CGRectMake(0,0,66,66) andAnnotation:annotation withReuseId:reuseId];
    
    CHAvatarView *avatarView = [[CHAvatarView alloc] initWithFrame:CGRectInset(headView.bounds, 4, 4)];
    avatarView.backgroundColor = [UIColor clearColor];
    [avatarView setImage:[UIImage imageNamed:@"avatar.png"]];
    avatarView.center = CGPointMake(CGRectGetMidX(headView.bounds), CGRectGetMidY(headView.bounds));
    [headView addSubview:avatarView];
    
    headView.annotation = annotation;
    headView.friend = (Friend*)annotation;
    headView.tag = (NSInteger)[headView.friend userID]; // sketchy step
    
    headView.mapView = mapView;
    
    headView.delegate = _draggingCoordinator;
    
    FXLabel *activity =[[FXLabel alloc] init];
    activity.shadowColor = nil;
    activity.shadowOffset = CGSizeMake(0.0f, 2.0f);
    activity.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    activity.shadowBlur = 5.0f;
    
    activity.text =  [NSString stringWithFormat:@" %@ ",[(Friend *)headView.annotation status]];
    
    activity.textAlignment=NSTextAlignmentCenter;
    //activity.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    activity.backgroundColor = [UIColor cyanColor];
    [activity.layer setCornerRadius:6];
    
    activity.font = [UIFont systemFontOfSize:14];
    CGSize stringsize1 = [activity.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    activity.frame=CGRectMake(headView.frame.origin.x + (avatarView.frame.size.width - stringsize1.width)/2, headView.frame.origin.y - stringsize1.height/2 - 5,  stringsize1.width, stringsize1.height );
    [activity sizeToFit];
    [headView addSubview:activity];
    [headView bringSubviewToFront:activity];
    
    return  headView;
}

// after we have appeared, zoom in on the annotations (but only do that once)

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self updateRegion];
    
}

// zooms to a region that encloses the annotations
// kind of a crude version
// (using CGRect for latitude/longitude regions is sorta weird, but CGRectUnion is nice to have!)

- (void)updateRegion:(NSNumber *)mode
{
    
    // mode 1 is 50 miles around you..
    // mode 2 is all your wolfpack
    self.needUpdateRegion = NO;
    CGRect boundingRect;
    BOOL started = NO;
    
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        CGRect annotationRect = CGRectMake(annotation.coordinate.latitude, annotation.coordinate.longitude, 0, 0);
        if (annotation.coordinate.latitude!=0 && annotation.coordinate.latitude!=0) {
            if (!started) {
                started = YES;
                boundingRect = annotationRect;
            } else {
                
                boundingRect = CGRectUnion(boundingRect, annotationRect);
            }
         }
    }
    if (started) {
        boundingRect = CGRectInset(boundingRect, -0.2, -0.2);
        //if ((boundingRect.size.width < 20) && (boundingRect.size.height < 20)) {
        
        MKCoordinateRegion region;
        if (mode.intValue==1) {
            
            region.center.latitude = boundingRect.origin.x + boundingRect.size.width/2;
            region.center.longitude = boundingRect.origin.y + boundingRect.size.height/2;
            region.span.latitudeDelta =boundingRect.size.height+0.3*boundingRect.size.height;
            region.span.longitudeDelta =boundingRect.size.width+0.7*boundingRect.size.width;
        }else if (mode.intValue==2){
            CLLocation *loc = [MyCLLocationManager sharedSingleton].locationManager.location;
            region.center = loc.coordinate; //for niko
            region.span.latitudeDelta =0.02;
            region.span.longitudeDelta =0.02;
            
        }
        
        
        [self.mapView setRegion:region animated:YES];
           
        //}
    }
     
  
}









@end
