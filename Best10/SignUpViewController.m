//
//  SignUpViewController.m
//  Best10
//
//  Created by Francois Chaubard on 6/12/14.
//  Copyright (c) 2014 Chaubard. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)signUpByTextToTwilio:(id)sender {
    
    // randomly generate some Text
    _verifCode = [self shuffledAlphabet];
    
    // send it to Parse
    PFObject *pfObj = [PFObject objectWithClassName:@"VerificationCode"];
    pfObj[@"verifCode"] = _verifCode;
    [pfObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // When finished pull up Text Message and send it to 347 380 9728
        [self showSMS:_verifCode];
    }];
   
}

- (void)showSMS:(NSString*)textMessage {
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSArray *recipents = @[@"+13473809728"];
    NSString *message = [NSString stringWithFormat:@"%@", textMessage];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            // User hit cancel.. whatev!
            break;
            
        case MessageComposeResultFailed:
        {
            // SMS didnt work.. bad :(
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
        {
            // SMS sent! Give it 3.5 seconds to send
            [NSThread sleepForTimeInterval:3.5];
            // on return from sending text, call parse on the verifCode and get the number. If it exists create a new user with the number as the unique ID.
            PFQuery *query = [PFQuery queryWithClassName:@"VerificationCode"];
            [query whereKey:@"verifCode" equalTo:_verifCode];
            
            //TODO: error checking for this..
            PFObject *pfObj = [query getFirstObject];
            // if number is empty.. bad
            if(pfObj[@"number"]){
                // Twilio worked!
                // Sign the user up..
                PFUser *user = [PFUser user];
                user[@"phone"] = pfObj[@"number"];
                user.username = pfObj[@"number"];
                user.password = pfObj[@"number"];
               
                [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        // Hooray! Let them use the app now.
                        
                        NSString *successString = pfObj[@"number"];
                        // TODO: Show the errorString somewhere and let the user try again.
                        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Saved Number as:" message:successString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [warningAlert show];

                        
                        
                    } else {
                        NSString *errorString = [error userInfo][@"error"];
                        // TODO: Show the errorString somewhere and let the user try again.
                        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [warningAlert show];
                    }
                }];

            }else{
                // TODO: Twilio did not work.. output error
                NSString *errorString = @"Twilio bugged out.";
                // TODO: Show the errorString somewhere and let the user try again.
                UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [warningAlert show];
            }
          
            // TODO: Then get your contacts like Jesus did and let you friend people..
            
            
            [pfObj delete];
            
            
            break;
        }
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSString *)shuffledAlphabet {
    NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    // Get the characters into a C array for efficient shuffling
    NSUInteger numberOfCharacters = [alphabet length];
    unichar *characters = calloc(numberOfCharacters, sizeof(unichar));
    [alphabet getCharacters:characters range:NSMakeRange(0, numberOfCharacters)];
    
    // Perform a Fisher-Yates shuffle
    for (NSUInteger i = 0; i < numberOfCharacters; ++i) {
        NSUInteger j = (arc4random_uniform(numberOfCharacters - i) + i);
        unichar c = characters[i];
        characters[i] = characters[j];
        characters[j] = c;
    }
    
    // Turn the result back into a string
    NSString *result = [NSString stringWithCharacters:characters length:numberOfCharacters];
    free(characters);
    return result;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
