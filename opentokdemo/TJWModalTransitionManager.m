//
//  TJWModalTransitionManager.m
//  Kale
//
//  Created by Teddy Wyly on 1/13/15.
//  Copyright (c) 2015 Teddy Wyly. All rights reserved.
//

#import "TJWModalTransitionManager.h"
#import "InstructionModalViewController.h"

@implementation TJWModalTransitionManager

#pragma mark - UIViewControllerAnimatedTransitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = [transitionContext containerView];
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    InstructionModalViewController *modalVC = !self.presenting ? (InstructionModalViewController *)fromVC : (InstructionModalViewController *)toVC;
    UIViewController *bottomVC = !self.presenting ? toVC : fromVC;
    
    UIView *modalView = modalVC.view;
    UIView *bottomView = bottomVC.view;
    
    if (self.presenting) {
        [self offStageModalController:modalVC];
    }
    
    [containerView addSubview:bottomView];
    [containerView addSubview:modalView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.6 options:0 animations:^{
        
        if (self.presenting) {
            [self onStageModalController:modalVC];
        } else {
            [self offStageModalController:modalVC];
        }
        
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        [[[UIApplication sharedApplication] keyWindow] addSubview:toVC.view];
        
    }];
    
}

- (void)onStageModalController:(InstructionModalViewController *)controller {
    controller.view.alpha = 1.0;
    controller.panelView.transform = CGAffineTransformIdentity;
    
}

- (void)offStageModalController:(InstructionModalViewController *)controller {
    controller.view.alpha = 0.0;
    CGFloat verticalOffset = self.presenting ? -200 : 200;
    controller.panelView.transform = CGAffineTransformMakeTranslation(0, verticalOffset);
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

@end
