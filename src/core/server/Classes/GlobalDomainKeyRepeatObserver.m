#import "GlobalDomainKeyRepeatObserver.h"
#import "PreferencesKeys.h"
#import "PreferencesManager.h"

@interface GlobalDomainKeyRepeatObserver () {
  PreferencesManager* preferencesManager_;
  NSTimer* timer_;

  int previousInitialKeyRepeat_;
  int previousKeyRepeat_;
}
@end

@implementation GlobalDomainKeyRepeatObserver

- (instancetype)initWithPreferencesManager:(PreferencesManager*)manager {
  self = [super init];

  if (self) {
    preferencesManager_ = manager;
  }

  return self;
}

- (void)start {
  timer_ = [NSTimer scheduledTimerWithTimeInterval:1
                                            target:self
                                          selector:@selector(timerFireMethod:)
                                          userInfo:nil
                                           repeats:YES];
}

- (void)timerFireMethod:(NSTimer*)timer {
  if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsOverwriteKeyRepeat]) {
    previousInitialKeyRepeat_ = -1;
    previousKeyRepeat_ = -1;
    return;
  }

  NSDictionary* dictionary = [[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain];
  int currentInitialKeyRepeat = [self getInitialKeyRepeatFromDictionary:dictionary];
  int currentKeyRepeat = [self getKeyRepeatFromDictionary:dictionary];

  if (previousInitialKeyRepeat_ != currentInitialKeyRepeat) {
    [preferencesManager_ setValue:currentInitialKeyRepeat forName:@"repeat.initial_wait"];
    previousInitialKeyRepeat_ = currentInitialKeyRepeat;
  }
  if (previousKeyRepeat_ != currentKeyRepeat) {
    [preferencesManager_ setValue:currentKeyRepeat forName:@"repeat.wait"];
    previousKeyRepeat_ = currentKeyRepeat;
  }
}

- (int)getInitialKeyRepeatFromDictionary:(NSDictionary*)dictionary {
  // If System Preferences has never changed, dictionary[@"InitialKeyRepeat"] is nil.
  // (We can confirm in Guest account.)
  if (!dictionary || !dictionary[@"InitialKeyRepeat"]) {
    return [preferencesManager_ value:@"repeat.initial_wait"];
  }
  // The unit of InitialKeyRepeat is 1/60 second.
  return (int)([dictionary[@"InitialKeyRepeat"] floatValue] * 1000 / 60);
}

- (int)getKeyRepeatFromDictionary:(NSDictionary*)dictionary {
  // If System Preferences has never changed, dictionary[@"KeyRepeat"] is nil.
  // (We can confirm in Guest account.)
  if (!dictionary || !dictionary[@"KeyRepeat"]) {
    return [preferencesManager_ value:@"repeat.wait"];
  }
  // The unit of KeyRepeat is 1/60 second.
  return (int)([dictionary[@"KeyRepeat"] floatValue] * 1000 / 60);
}

@end