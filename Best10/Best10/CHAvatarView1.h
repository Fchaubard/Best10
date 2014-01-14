//
//  AvatarView.h
//
//  Created by Matthias Hochgatterer on 21.11.12.
//  Copyright (c) 2012 Matthias Hochgatterer. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIGestureRecognizer.h>
#import <QuartzCore/QuartzCore.h>
#import "Friend+MKAnnotation.h"

@interface CHAvatarView1 : MKAnnotationView <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIImage *avatarImage;
@property (nonatomic, strong) Friend *friend;
@property (nonatomic, strong) UIPanGestureRecognizer *recognizer;
@property (nonatomic, strong) UILabel *activity;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) int radius;
@property (nonatomic, weak) MKMapView *mapView;


- (id)initWithFrame:(CGRect)frame andAnnotation:(id<MKAnnotation>)thisAnnotation withReuseId:(NSString *)string;

@end
