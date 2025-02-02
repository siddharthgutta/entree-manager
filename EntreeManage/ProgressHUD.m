//
// Copyright (c) 2014 Related Code - http:// relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ProgressHUD.h"

@implementation ProgressHUD

@synthesize interaction, window, senderWindow, background, hud, spinner, image, label;


+ (ProgressHUD *)shared {
    static dispatch_once_t once = 0;
    static ProgressHUD *progressHUD;
    
    dispatch_once(&once, ^{ progressHUD = [[ProgressHUD alloc] init]; });
    
    return progressHUD;
}

+ (void)dismiss {
    [[self shared] hudHide];
}

+ (void)show:(NSString *)status {
    [self shared].interaction = NO;
    [[self shared] hudMake:status image:nil spin:YES hide:NO];
}

+ (void)show:(NSString *)status Interaction:(BOOL)Interaction {
    [self shared].interaction = Interaction;
    [[self shared] hudMake:status image:nil spin:YES hide:NO];
}

+ (void)showSuccess:(NSString *)status {
    [self shared].interaction = NO;
    [[self shared] hudMake:status image:HUD_IMAGE_SUCCESS spin:NO hide:YES];
}

+ (void)showSuccess:(NSString *)status Interaction:(BOOL)Interaction {
    [self shared].interaction = Interaction;
    [[self shared] hudMake:status image:HUD_IMAGE_SUCCESS spin:NO hide:YES];
}

+ (void)showError:(NSString *)status {
    [self shared].interaction = NO;
    [[self shared] hudMake:status image:HUD_IMAGE_ERROR spin:NO hide:YES];
}

+ (void)showError:(NSString *)status Interaction:(BOOL)Interaction {
    [self shared].interaction = Interaction;
    [[self shared] hudMake:status image:HUD_IMAGE_ERROR spin:NO hide:YES];
}

- (id)init {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    
    id < UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate respondsToSelector:@selector(window)])
        window = [delegate performSelector:@selector(window)];
    else window = [[UIApplication sharedApplication] keyWindow];
    
    background = nil; hud = nil; spinner = nil; image = nil; label = nil;
    
    self.alpha = 0;
    
    return self;
}

- (void)hudMake:(NSString *)status image:(UIImage *)img spin:(BOOL)spin hide:(BOOL)hide {
    [self hudCreate];
    
    CGFloat delay = 0.8;
    
    if (status) {
        label.text = status;
        label.hidden = NO;
        delay = 1.0;
    }
    else
    {
        label.text = nil;
        label.hidden = YES;
    }
    
    if (image) {
        image.image = img;
        image.hidden = NO;
    }
    else
    {
        image.image = nil;
        image.hidden = YES;
    }
    
    if (spin)
        [spinner startAnimating];
    else
        [spinner stopAnimating];
    
    [self hudSize];
    [self hudOrient];
    [self hudPosition:nil];
    [self hudShow];
    
    if (hide)
        [NSThread detachNewThreadSelector:@selector(hideAfterDelay:) toTarget:self withObject:@(delay)];
}

- (void)hudCreate {
    if (hud == nil) {
        hud = [[UIToolbar alloc] initWithFrame:CGRectZero];
        hud.translucent = YES;
        hud.backgroundColor = HUD_BACKGROUND_COLOR;
        hud.layer.cornerRadius = 10;
        hud.layer.masksToBounds = YES;
        [self registerNotifications];
    }
    
    if (hud.superview == nil) {
        if (interaction == NO) {
            CGRect frame = CGRectMake(window.frame.origin.x, window.frame.origin.y, CGRectGetWidth(window.frame), CGRectGetHeight(window.frame));
            background = [[UIView alloc] initWithFrame:frame];
            background.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500];
            [window addSubview:background];
            [background addSubview:hud];
        }
        else [window addSubview:hud];
    }
    
    if (spinner == nil) {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.color = [UIColor blackColor];
        spinner.hidesWhenStopped = YES;
    }
    if (spinner.superview == nil) {
        [hud addSubview:spinner];
    }
    if (image == nil) {
        image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    }
    if (image.superview == nil) [hud addSubview:image];
    
    if (label == nil) {
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = HUD_STATUS_FONT;
        label.textColor = HUD_STATUS_COLOR;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        label.numberOfLines = 0;
    }
    if (label.superview == nil) [hud addSubview:label];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudOrient)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudPosition:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudPosition:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudPosition:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudPosition:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)hudDestroy {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [label removeFromSuperview];		label = nil;
    [image removeFromSuperview];		image = nil;
    [spinner removeFromSuperview];		spinner = nil;
    [hud removeFromSuperview];			hud = nil;
    [background removeFromSuperview];	background = nil;
}

- (void)hudSize {
    CGRect labelRect = CGRectZero;
    CGFloat hudWidth = 100, hudHeight = 100;
    
    if (label.text) {
        NSDictionary *attributes = @{NSFontAttributeName:label.font};
        NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
        labelRect = [label.text boundingRectWithSize:CGSizeMake(200, 300) options:options attributes:attributes context:NULL];
        
        labelRect.origin.x = 12;
        labelRect.origin.y = 66;
        
        hudWidth = labelRect.size.width + 24;
        hudHeight = labelRect.size.height + 80;
        
        if (hudWidth < 100) {
            hudWidth = 100;
            labelRect.origin.x = 0;
            labelRect.size.width = 100;
        }
    }
    
    hud.bounds = CGRectMake(0, 0, hudWidth, hudHeight);
    
    CGFloat imagex = hudWidth/2;
    CGFloat imagey = (label.text == nil) ? hudHeight/2 : 36;
    image.center = spinner.center = CGPointMake(imagex, imagey);
    
    label.frame = labelRect;
}

- (void)hudOrient {
    CGFloat rotate = 0.0;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait)				rotate = 0.0;
    if (orientation == UIInterfaceOrientationPortraitUpsideDown)	rotate = M_PI;
    if (orientation == UIInterfaceOrientationLandscapeLeft)			rotate = - M_PI_2;
    if (orientation == UIInterfaceOrientationLandscapeRight)		rotate = + M_PI_2;
    
    hud.transform = CGAffineTransformMakeRotation(rotate);
}

- (void)hudPosition:(NSNotification *)notification {
    CGFloat heightKeyboard = 0;
    NSTimeInterval duration = 0;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (notification) {
        NSDictionary *keyboardInfo = [notification userInfo];
        duration = [[keyboardInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect keyboard = [[keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        
        if ((notification.name == UIKeyboardWillShowNotification) || (notification.name == UIKeyboardDidShowNotification)) {
            if (UIInterfaceOrientationIsPortrait(orientation))
                heightKeyboard = keyboard.size.height;
            else heightKeyboard = keyboard.size.width;
        }
    }
    else heightKeyboard = [self keyboardHeight];
    
    CGRect screen = [UIScreen mainScreen].bounds;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        CGFloat temp = screen.size.width;
        screen.size.width = screen.size.height;
        screen.size.height = temp;
    }
    
    CGFloat posX = screen.size.width / 2;
    CGFloat posY = (screen.size.height - heightKeyboard) / 2;
    
    CGPoint center;
    if (orientation == UIInterfaceOrientationPortrait)				center = CGPointMake(posX, posY);
    if (orientation == UIInterfaceOrientationPortraitUpsideDown)	center = CGPointMake(posX, screen.size.height-posY);
    if (orientation == UIInterfaceOrientationLandscapeLeft)			center = CGPointMake(posY, posX);
    if (orientation == UIInterfaceOrientationLandscapeRight)		center = CGPointMake(screen.size.height-posY, posX);
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        hud.center = CGPointMake(center.x, center.y);
    } completion:nil];
}

- (CGFloat)keyboardHeight {
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if ([[testWindow class] isEqual:[UIWindow class]] == NO) {
            for (UIView *possibleKeyboard in [testWindow subviews]) {
                if ([possibleKeyboard isKindOfClass:NSClassFromString(@"UIPeripheralHostView")] ||
                    [possibleKeyboard isKindOfClass:NSClassFromString(@"UIKeyboard")])
                    return possibleKeyboard.bounds.size.height;
            }
        }
    }
    return 0;
}

- (void)hudShow {
    if (self.alpha == 0) {
        self.alpha = 1;
        
        hud.alpha = 0;
        hud.transform = CGAffineTransformScale(hud.transform, 1.4, 1.4);
        
        NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut;
        [UIView animateWithDuration:0.15 delay:0 options:options animations:^{
            hud.transform = CGAffineTransformScale(hud.transform, 1/1.4, 1/1.4);
            hud.alpha = 1;
        } completion:nil];
    }
}

- (void)hudHide {
    if (self.alpha == 1) {
        NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn;
        [UIView animateWithDuration:0.15 delay:0 options:options animations:^{
            hud.transform = CGAffineTransformScale(hud.transform, 0.7, 0.7);
            hud.alpha = 0;
        }
                         completion:^(BOOL finished) {
             [self hudDestroy];
             self.alpha = 0;
         }];
    }
}

- (void)hideAfterDelay:(NSNumber *)delay {
    @autoreleasepool {
        // NSUInteger length = label.text.length;
        
        [NSThread sleepForTimeInterval:[delay floatValue]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hudHide];
        });
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
