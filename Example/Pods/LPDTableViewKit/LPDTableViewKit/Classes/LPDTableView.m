//
//  LPDTableView.m
//  LPDTableViewKit
//
//  Created by foxsofter on 16/1/5.
//  Copyright © 2016年 eleme. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "LPDTableView.h"
#import "LPDTableViewModel+Private.h"

@interface LPDTableView ()

@property (nullable, nonatomic, weak, readwrite) __kindof id<LPDTableViewModelProtocol> viewModel;

@end

@implementation LPDTableView

- (void)bindingTo:(__kindof id<LPDTableViewModelProtocol>)viewModel {
  NSParameterAssert(viewModel);

  self.viewModel = viewModel;

  @weakify(self);
  RACSignal *viewDidLoadedSignal = [self rac_signalForSelector:@selector(didMoveToSuperview)];
  [[viewDidLoadedSignal takeUntil:[self rac_signalForSelector:@selector(removeFromSuperview)]]
   subscribeNext:^(id x) {
    @strongify(self);

    LPDTableViewModel *tableViewModel = (LPDTableViewModel*)self.viewModel;
    super.delegate = tableViewModel.delegate;
    super.dataSource = tableViewModel.dataSource;

    [[[tableViewModel.reloadDataSignal takeUntil:[self rac_signalForSelector:@selector(removeFromSuperview)]]
      deliverOnMainThread] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        [self reloadData];
      }];

    [[[tableViewModel.insertSectionsSignal takeUntil:[self rac_signalForSelector:@selector(removeFromSuperview)]]
      deliverOnMainThread] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        UITableViewRowAnimation animation = [tuple.second integerValue];
        if (animation == UITableViewRowAnimationNone) {
          [self reloadData];
        } else {
          [self insertSections:tuple.first withRowAnimation:animation];
        }
      }];

    [[[tableViewModel.deleteSectionsSignal takeUntil:[self rac_signalForSelector:@selector(removeFromSuperview)]]
      deliverOnMainThread] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        UITableViewRowAnimation animation = [tuple.second integerValue];
        if (animation == UITableViewRowAnimationNone) {
          [self reloadData];
        } else {
          [self deleteSections:tuple.first withRowAnimation:animation];
        }
      }];

    [[[tableViewModel.replaceSectionsSignal takeUntil:[self rac_signalForSelector:@selector(removeFromSuperview)]]
      deliverOnMainThread] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        UITableViewRowAnimation animation = [tuple.second integerValue];
        if (animation == UITableViewRowAnimationNone) {
          [self reloadData];
        } else {
          NSIndexSet *indexSet = tuple.first;
          UITableViewRowAnimation removeAnimation = animation;
          if (animation == UITableViewRowAnimationRight) {
            removeAnimation = UITableViewRowAnimationLeft;
          } else if (animation == UITableViewRowAnimationLeft) {
            removeAnimation = UITableViewRowAnimationRight;
          } else if (animation == UITableViewRowAnimationTop) {
            removeAnimation = UITableViewRowAnimationBottom;
          } else if (animation == UITableViewRowAnimationBottom) {
            removeAnimation = UITableViewRowAnimationTop;
          }
          
          [self beginUpdates];
          [self deleteSections:indexSet withRowAnimation:removeAnimation];
          [self insertSections:indexSet withRowAnimation:animation];
          [self endUpdates];
        }
      }];

    [[[tableViewModel.reloadSectionsSignal takeUntil:[self rac_signalForSelector:@selector(removeFromSuperview)]]
      deliverOnMainThread] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        UITableViewRowAnimation animation = [tuple.second integerValue];
        if (animation == UITableViewRowAnimationNone) {
          [self reloadData];
        } else {
          [self reloadSections:tuple.first withRowAnimation:animation];
        }
      }];

    [[[tableViewModel.insertRowsAtIndexPathsSignal takeUntil:[self rac_signalForSelector:@selector(removeFromSuperview)]]
      deliverOnMainThread] subscribeNext:^(RACTuple *tuple) {
      @strongify(self);
      UITableViewRowAnimation animation = [tuple.second integerValue];
      if (animation == UITableViewRowAnimationNone) {
        [self reloadData];
      } else {
        [self insertRowsAtIndexPaths:tuple.first withRowAnimation:animation];
      }
    }];

    [[[tableViewModel.deleteRowsAtIndexPathsSignal takeUntil:[self rac_signalForSelector:@selector(removeFromSuperview)]]
      deliverOnMainThread] subscribeNext:^(RACTuple *tuple) {
      @strongify(self);
      NSArray<NSIndexPath *> *indexPaths = tuple.first;
      if (indexPaths.count > 0) {
        UITableViewRowAnimation animation = [tuple.second integerValue];
        if (animation == UITableViewRowAnimationNone) {
          [self reloadData];
        } else {
          [self deleteRowsAtIndexPaths:tuple.first withRowAnimation:animation];
        }
      }
    }];

    [[[tableViewModel.reloadRowsAtIndexPathsSignal takeUntil:[self rac_signalForSelector:@selector(removeFromSuperview)]]
     deliverOnMainThread] subscribeNext:^(RACTuple *tuple) {
      @strongify(self);
      UITableViewRowAnimation animation = [tuple.second integerValue];
      if (animation == UITableViewRowAnimationNone) {
        [self reloadData];
      } else {
        [self reloadRowsAtIndexPaths:tuple.first withRowAnimation:animation];
      }
    }];

    [[[tableViewModel.replaceRowsAtIndexPathsSignal takeUntil:[self rac_signalForSelector:@selector(removeFromSuperview)]]
     deliverOnMainThread] subscribeNext:^(RACTuple *tuple) {
      @strongify(self);
      UITableViewRowAnimation animation = [tuple.third integerValue];
      if (animation == UITableViewRowAnimationNone) {
        [self reloadData];
      } else {
        NSArray *oldIndexPaths = tuple.first;
        NSArray *newIndexPaths = tuple.second;
        UITableViewRowAnimation removeAnimation = animation;
        if (animation == UITableViewRowAnimationRight) {
          removeAnimation = UITableViewRowAnimationLeft;
        } else if (animation == UITableViewRowAnimationLeft) {
          removeAnimation = UITableViewRowAnimationRight;
        } else if (animation == UITableViewRowAnimationTop) {
          removeAnimation = UITableViewRowAnimationBottom;
        } else if (animation == UITableViewRowAnimationBottom) {
          removeAnimation = UITableViewRowAnimationTop;
        }
        
        [self beginUpdates];
        [self deleteRowsAtIndexPaths:oldIndexPaths withRowAnimation:removeAnimation];
        [self insertRowsAtIndexPaths:newIndexPaths withRowAnimation:animation];
        [self endUpdates];
      }
    }];
  }];
}

@end
