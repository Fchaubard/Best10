//
//  SignUpViewController.h
//  Best10
//
//  Created by Francois Chaubard on 6/12/14.
//  Copyright (c) 2014 Chaubard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SignUpViewController : UIViewController <MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UILabel *welcomeMessageLabel;
@property  (strong) NSString *verifCode;

@end
