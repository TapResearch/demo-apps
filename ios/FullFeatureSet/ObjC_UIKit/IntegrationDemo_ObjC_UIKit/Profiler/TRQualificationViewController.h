#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TRProfileResponse;
@class TRProfileAnswer;

/// Completion used by the UIKit questionnaire to submit answers.
typedef void (^TRQualificationSubmitCompletion)(TRProfileResponse * _Nullable response,
                                                  NSError * _Nullable error);
typedef void (^TRQualificationSubmitHandler)(NSArray<TRProfileAnswer *> *answers,
                                              TRQualificationSubmitCompletion completion);

/// Pure UIKit / Objective-C questionnaire UI for TRProfileResponse.
///
/// The controller owns only transient UI state. The returned TRProfileResponse
/// after every submission is treated as the new source of truth:
///   - accepted questions disappear
///   - invalid questions remain
///   - existing invalid answers stay populated
///   - result.errors / previousError are displayed inline
@interface TRQualificationViewController : UIViewController

- (instancetype)initWithResponse:(TRProfileResponse *)response
                    submitHandler:(TRQualificationSubmitHandler)submitHandler
                           onExit:(nullable void (^)(void))onExit
                       onComplete:(nullable void (^)(TRProfileResponse *response))onComplete NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                          bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@property (nonatomic, strong, readonly) TRProfileResponse *response;

@end

NS_ASSUME_NONNULL_END
