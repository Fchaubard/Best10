//
//  CHDraggableView.h
//  ChatHeads
//
//  Created by Matthias Hochgatterer on 4/19/13.
//  Copyright (c) 2013 Matthias Hochgatterer. All rights reserved.
//
#import <MapKit/MapKit.h>
#import <UIKit/UIGestureRecognizer.h>
#import <QuartzCore/QuartzCore.h>
#import "Friend+MKAnnotation.h"

@protocol CHDraggableViewDelegate;
@interface CHDraggableView : MKAnnotationView 

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) Friend *friend;
@property (nonatomic, weak) MKMapView *mapView;
@property (nonatomic, assign) id<CHDraggableViewDelegate> delegate;

- (void)snapViewCenterToPoint:(CGPoint)point ;
- (id)initWithFrame:(CGRect)frame andAnnotation:(id<MKAnnotation>)thisAnnotation withReuseId:(NSString *)string;

@end

@protocol CHDraggableViewDelegate <NSObject>

- (void)draggableViewHold:(CHDraggableView *)view;
- (void)draggableView:(CHDraggableView *)view didMoveToPoint:(CGPoint)point;
- (void)draggableViewReleased:(CHDraggableView *)view;

- (void)draggableViewTouched:(CHDraggableView *)view;

- (void)draggableViewNeedsAlignment:(CHDraggableView *)view;

@end