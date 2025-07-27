import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'extension.dart';

/// AdBannerWidget - Displays AdMob banner advertisements
/// Handles ad loading, consent management, and platform-specific ad unit IDs
/// Uses Google Mobile Ads SDK for banner ad implementation
class AdBannerWidget extends HookWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {

    /// Ad State Management - Track ad loading status and banner instance
    final adLoaded = useState(false);
    final adFailedLoading = useState(false);
    final bannerAd = useState<BannerAd?>(null);
    // final testIdentifiers = ['2793ca2a-5956-45a2-96c0-16fafddc1a15'];

    /// Banner Unit ID - Returns the appropriate ad unit ID based on platform and build mode
    /// Platform-specific logic for iOS/Android and debug/release modes
    String bannerUnitId() => dotenv.get(
      (!kDebugMode && Platform.isIOS) ? "IOS_BANNER_UNIT_ID":
      (!kDebugMode && Platform.isAndroid) ? "ANDROID_BANNER_UNIT_ID":
      (Platform.isIOS) ? "IOS_BANNER_TEST_ID":
      "ANDROID_BANNER_UNIT_ID"
    );

    /// Load Ad Banner - Creates and loads a banner advertisement
    /// Handles ad loading callbacks and retry logic for failed loads
    Future<void> loadAdBanner() async {
      final adBanner = BannerAd(
        adUnitId: bannerUnitId(),
        size: AdSize.largeBanner,
        request: const AdRequest(),
        listener: BannerAdListener(
          /// Ad Loaded Callback - Called when ad successfully loads
          onAdLoaded: (Ad ad) {
            'Ad: $ad loaded.'.debugPrint();
            adLoaded.value = true;
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
        /// Check if consent form is available and handle consent flow
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          ConsentForm.loadConsentForm((ConsentForm consentForm) async {
            var status = await ConsentInformation.instance.getConsentStatus();
            "status: $status".debugPrint();
            /// Show consent form if required, otherwise load ad directly
            if (status == ConsentStatus.required) {
              consentForm.show((formError) async => await loadAdBanner());
            } else {
              await loadAdBanner();
            }
          }, (formError) {});
        } else {
          /// Load ad directly if no consent form is available
          await loadAdBanner();
        }
      }, (FormError error) {});
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