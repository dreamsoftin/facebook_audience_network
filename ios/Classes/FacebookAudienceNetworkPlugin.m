#import "FacebookAudienceNetworkPlugin.h"
#import <facebook_audience_network-Swift.h>
//#import "facebook_audience_network/facebook_audience_network-Swift.h"

@implementation FacebookAudienceNetworkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [FANPlugin registerWithRegistrar:registrar];
}
@end