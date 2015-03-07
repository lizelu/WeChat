#import "XMPP.h"

#ifdef HAVE_XMPP_SUBSPEC_BANDWIDTHMONITOR
#import "XMPPBandwidthMonitor.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_GOOGLESHAREDSTATUS
#import "XMPPGoogleSharedStatus.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_RECONNECT
#import "XMPPReconnect.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_ROSTER
#import "XMPPRoster.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_SYSTEMINPUTACTIVITYMONITOR
#import "XMPPSystemInputActivityMonitor.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0009
#import "XMPPJabberRPCModule.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0012
#import "XMPPLastActivity.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0016
#import "XMPPPrivacy.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0045
#import "XMPPMUC.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0045
#import "XMPPRoom.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0054
#import "XMPPvCardTempModule.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0060
#import "XMPPPubSub.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0100
#import "XMPPTransports.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0115
#import "XMPPCapabilities.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0136
#import "XMPPMessageArchiving.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0153
#import "XMPPvCardAvatarModule.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0184
#import "XMPPMessageDeliveryReceipts.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0191
#import "XMPPBlocking.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0199
#import "XMPPAutoPing.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0199
#import "XMPPPing.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0202
#import "XMPPAutoTime.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0202
#import "XMPPTime.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0224
#import "XMPPAttentionModule.h"
#endif
