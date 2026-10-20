#import <UIKit/UIKit.h>

@interface DebugMenuController : NSObject
+ (void)install;
@end

@implementation DebugMenuController

static UIButton *DebugMenuButton = nil;

+ (UIWindow *)keyWindow {
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if ([scene isKindOfClass:UIWindowScene.class] &&
                scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in ((UIWindowScene *)scene).windows) {
                    if (window.isKeyWindow) {
                        return window;
                    }
                }
            }
        }
    }

    return UIApplication.sharedApplication.windows.firstObject;
}

+ (UIViewController *)topController {
    UIWindow *window = [self keyWindow];
    if (!window) return nil;

    UIViewController *vc = window.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    return vc;
}

+ (void)showMenu {
    UIViewController *root = [self topController];
    if (!root) return;

    UIAlertController *menu =
        [UIAlertController alertControllerWithTitle:@"Debug Menu"
                                            message:@"Menu de test"
                                     preferredStyle:UIAlertControllerStyleAlert];

    [menu addAction:[UIAlertAction actionWithTitle:@"Option 1"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
        NSLog(@"[DebugMenu] Option 1");
    }]];

    [menu addAction:[UIAlertAction actionWithTitle:@"Option 2"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
        NSLog(@"[DebugMenu] Option 2");
    }]];

    [menu addAction:[UIAlertAction actionWithTitle:@"Fermer"
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];

    [root presentViewController:menu animated:YES completion:nil];
}

+ (void)install {
    UIWindow *window = [self keyWindow];
    if (!window) return;

    if (DebugMenuButton != nil) {
        if (DebugMenuButton.superview == nil) {
            [window addSubview:DebugMenuButton];
        }
        return;
    }

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(20.0, 120.0, 56.0, 56.0);
    button.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    button.layer.cornerRadius = 28.0;
    button.layer.masksToBounds = YES;
    button.tintColor = UIColor.whiteColor;
    [button setTitle:@"☰" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:26.0];
    [button addTarget:self action:@selector(showMenu)
     forControlEvents:UIControlEventTouchUpInside];

    UIPanGestureRecognizer *pan =
        [[UIPanGestureRecognizer alloc] initWithTarget:self
                                               action:@selector(drag:)];
    [button addGestureRecognizer:pan];

    [window addSubview:button];
    DebugMenuButton = button;
}

+ (void)drag:(UIPanGestureRecognizer *)gesture {
    UIView *view = gesture.view;
    if (!view || !view.superview) return;

    CGPoint translation = [gesture translationInView:view.superview];
    view.center = CGPointMake(view.center.x + translation.x,
                             view.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:view.superview];
}

@end

__attribute__((constructor))
static void DebugMenuInit(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [DebugMenuController install];
    });
}
