#import "TUIControl.h"
#import "TUITableView.h"

@interface TUIRefreshControl : TUIControl

// This property returns YES if the refresh
// control is currently refreshing, by either
// manual or automatic control.
@property (nonatomic, assign, readonly) BOOL refreshing;

// Set a custom tint color for the refresh
// control. By default, it's a dull blue.
@property (nonatomic, strong) NSColor *tintColor;

// To use the refresh control, initialize it by
// attaching it to a table view passed. Once this
// has been done, the refresh control will become
// the pullDownView for that table view. It is 
// advised not to modify the pullDownView after
// attachment to avoid refresh control breakage.
- (id)initInTableView:(TUITableView *)tableView;

// Manually begin the refresh process. Note that,
// unlike the automatic bounce-scrolled refresh, this
// manual refresh does not automatically lock and
// display the refresh indicator above the table
// view. This is a deliberate design choice taken
// to accomodate for targeting users who both have
// and do not have a multitouch trackpad. It is more
// natural to not be able to see the refresh
// indicator when using a mouse scroll wheel.
- (void)beginRefreshing;

// End the refresh process. Note that if a bounce
// scroll triggers an automatic refresh process,
// the only way to end it is to call this method.
// By design, the refresh indicator disappears.
- (void)endRefreshing;

@end