import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'extension.dart';
import 'constant.dart';

/// AdBannerWidget: displays an AdMob banner and handles consent and loading.
/// Ad unit IDs are platform-specific.
class AdBannerWidget extends HookWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {

    /// Ad State Management - Track ad loading status and banner instance
    final adLoaded = useState(false);
    final adFailedLoading = useState(false);
    final bannerAd = useState<BannerAd?>(null);
    // Ref, not state: the consent callbacks resolve after this widget can be
    // gone, and writing to a disposed ValueNotifier asserts in debug
    final isAdRequested = useRef(false);
    // final testIdentifiers = ['2793ca2a-5956-45a2-96c0-16fafddc1a15'];

    /// Banner Unit ID - Returns the appropriate ad unit ID based on platform and build mode
    /// Platform-specific logic for iOS/Android and debug/release modes
    String bannerUnitId() =>
      // Production units come from .env; demo units are Google's published constants,
      // so a missing .env key cannot break a debug build
      (!kDebugMode && Platform.isIOS) ? dotenv.get("IOS_BANNER_UNIT_ID"):
      (!kDebugMode && Platform.isAndroid) ? dotenv.get("ANDROID_BANNER_UNIT_ID"):
      (Platform.isIOS) ? iosBannerTestId:
      // Debug on Android used to fall through to the production unit, so
      // development traffic landed on the live ad unit
      androidBannerTestId;

    /// Load Ad Banner - Creates and loads a banner advertisement
    /// Handles ad loading callbacks and retry logic for failed loads
    Future<void> loadAdBanner() async {
      // largeBanner asked for a fixed 320x100 inside a box sized by admobWidth
      // and admobHeight. Inline adaptive asks for that box's width and height
      final cap = context.admobHeight().toInt();
      final size = AdSize.getInlineAdaptiveBannerAdSize(
          context.admobWidth().toInt(), cap);
      final adBanner = BannerAd(
        adUnitId: bannerUnitId(),
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          /// Ad Loaded Callback - Called when ad successfully loads
          onAdLoaded: (Ad ad) async {
            'Ad: $ad loaded.'.debugPrint();
            // Mount first; the await below only feeds a debug line
            adLoaded.value = true;
            if (kDebugMode) {
              // Requested and served together: neither alone separates the size
              // asked for from the creative Google had to hand
              final served = await (ad as BannerAd).getPlatformAdSize();
              'AdSize: ${size.width} x cap $cap / served: ${served?.width} x ${served?.height}'.debugPrint();
            }
          },
          /// Ad Failed to Load Callback - Called when ad loading fails
          /// Implements retry logic with 30-second delay
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            'Ad: $ad failed to load: $error'.debugPrint();
            adFailedLoading.value = true;
            // Retry loading after 30 seconds if not already loaded or failed
            Future.delayed(const Duration(seconds: 30), () {
              if (!adLoaded.value && !adFailedLoading.value) {
                loadAdBanner();
              }
            });
          },
        ),
      );
      adBanner.load();
      bannerAd.value = adBanner;
    }

    /// Single gate for the ad request. canRequestAds is the SDK's own verdict (region,
    /// TCF, Additional Consent); false also covers "could not tell", so never bypass it
    Future<void> requestAdIfAllowed() async {
      if (isAdRequested.value) return;
      if (!await ConsentInformation.instance.canRequestAds()) return;
      // Both callers race across that await. The claim happens with no await in
      // between, so the second to resume sees the flag and makes no second BannerAd
      if (isAdRequested.value) return;
      isAdRequested.value = true;
      await loadAdBanner();
    }

    /// UseEffect for Ad Initialization - Handles consent management and ad loading
    /// Manages the complete ad lifecycle from consent to display
    useEffect(() {
      /// Consent Information Update - Request consent information update
      /// Handles GDPR compliance for European users
      ConsentInformation.instance.requestConsentInfoUpdate(ConsentRequestParameters(
        // consentDebugSettings: ConsentDebugSettings(
        //   debugGeography: DebugGeography.debugGeographyEea,
        //   testIdentifiers: testIdentifiers,
        // ),
      ), () async {
        // The SDK decides whether a form is required and shows it. Do not load the ad
        // from the form callback: it fires on close even when the user declined
        await ConsentForm.loadAndShowConsentFormIfRequired((formError) async {
          if (formError != null) {
            "formError: ${formError.errorCode}: ${formError.message}".debugPrint();
          }
          await requestAdIfAllowed();
        });
      }, (FormError error) async {
        // The update failed, but consent from an earlier session still stands and
        // canRequestAds can still say yes, so do not stop here
        "error: ${error.errorCode}: ${error.message}".debugPrint();
        await requestAdIfAllowed();
      });
      "bannerAd: ${bannerAd.value}".debugPrint();
      /// Cleanup function - Dispose of banner ad when widget unmounts
      return () => bannerAd.value?.dispose();
    }, []);

    /// Ad Display Widget - Returns the banner ad widget or null if not loaded
    /// Uses responsive sizing based on context
    return SizedBox(
      width: context.admobWidth(),
      height: context.admobHeight(),
      child: (adLoaded.value) ? AdWidget(ad: bannerAd.value!): null,
    );
  }
}