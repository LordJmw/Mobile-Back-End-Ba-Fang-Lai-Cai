import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Ba Fang Lai Cai'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @bestRatedThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Best Rated This Week!'**
  String get bestRatedThisWeek;

  /// No description provided for @viewCategoryPage.
  ///
  /// In en, this message translates to:
  /// **'View Category Page'**
  String get viewCategoryPage;

  /// No description provided for @portfolioAndReview.
  ///
  /// In en, this message translates to:
  /// **'Portfolio & Reviews'**
  String get portfolioAndReview;

  /// No description provided for @inspirationAndFeed.
  ///
  /// In en, this message translates to:
  /// **'Inspiration & Feed'**
  String get inspirationAndFeed;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @categoryPhotography.
  ///
  /// In en, this message translates to:
  /// **'Photography &\nVideography'**
  String get categoryPhotography;

  /// No description provided for @categoryEventOrganizer.
  ///
  /// In en, this message translates to:
  /// **'Event Organizer &\nPlanner'**
  String get categoryEventOrganizer;

  /// No description provided for @categoryMakeupFashion.
  ///
  /// In en, this message translates to:
  /// **'Makeup &\nFashion'**
  String get categoryMakeupFashion;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment &\nPerformers'**
  String get categoryEntertainment;

  /// No description provided for @categoryDecorVenue.
  ///
  /// In en, this message translates to:
  /// **'Decoration &\nVenue'**
  String get categoryDecorVenue;

  /// No description provided for @categoryCateringFB.
  ///
  /// In en, this message translates to:
  /// **'Catering &\nF&B'**
  String get categoryCateringFB;

  /// No description provided for @categoryTechEventProduction.
  ///
  /// In en, this message translates to:
  /// **'Technology &\nEvent Production'**
  String get categoryTechEventProduction;

  /// No description provided for @categoryTransportationLogistics.
  ///
  /// In en, this message translates to:
  /// **'Transportation &\nLogistics'**
  String get categoryTransportationLogistics;

  /// No description provided for @categorySupportServices.
  ///
  /// In en, this message translates to:
  /// **'Other\nSupport Services'**
  String get categorySupportServices;

  /// No description provided for @ourProduct.
  ///
  /// In en, this message translates to:
  /// **'Our Products'**
  String get ourProduct;

  /// No description provided for @searchVendorOrCategory.
  ///
  /// In en, this message translates to:
  /// **'Search vendor or category...'**
  String get searchVendorOrCategory;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @yourPurchaseHistory.
  ///
  /// In en, this message translates to:
  /// **'Your Purchase History'**
  String get yourPurchaseHistory;

  /// No description provided for @noPurchasesYet.
  ///
  /// In en, this message translates to:
  /// **'No purchases yet.'**
  String get noPurchasesYet;

  /// No description provided for @pleaseBuyPackage.
  ///
  /// In en, this message translates to:
  /// **'Please buy a package from a vendor.'**
  String get pleaseBuyPackage;

  /// No description provided for @failedToLoadCustomer.
  ///
  /// In en, this message translates to:
  /// **'Failed to load customer data'**
  String get failedToLoadCustomer;

  /// No description provided for @customerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Customer not found'**
  String get customerNotFound;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// No description provided for @orderUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order updated successfully'**
  String get orderUpdatedSuccessfully;

  /// No description provided for @orderDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order deleted successfully'**
  String get orderDeletedSuccessfully;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @eventDate.
  ///
  /// In en, this message translates to:
  /// **'Event Date'**
  String get eventDate;

  /// No description provided for @eventLocation.
  ///
  /// In en, this message translates to:
  /// **'Event Location'**
  String get eventLocation;

  /// No description provided for @specialNotes.
  ///
  /// In en, this message translates to:
  /// **'Special Notes'**
  String get specialNotes;

  /// No description provided for @enterEventLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter event location'**
  String get enterEventLocation;

  /// No description provided for @addNotes.
  ///
  /// In en, this message translates to:
  /// **'Add notes'**
  String get addNotes;

  /// No description provided for @requiredFields.
  ///
  /// In en, this message translates to:
  /// **'Name, email, and phone must be filled'**
  String get requiredFields;

  /// No description provided for @locationAndDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Location and date are required'**
  String get locationAndDateRequired;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @editOrder.
  ///
  /// In en, this message translates to:
  /// **'Edit Order'**
  String get editOrder;

  /// No description provided for @deleteOrder.
  ///
  /// In en, this message translates to:
  /// **'Delete Order'**
  String get deleteOrder;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the order from?'**
  String get confirmDelete;

  /// No description provided for @purchaseDate.
  ///
  /// In en, this message translates to:
  /// **'Purchased on'**
  String get purchaseDate;

  /// No description provided for @eventDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Event date'**
  String get eventDateLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @unknownVendor.
  ///
  /// In en, this message translates to:
  /// **'Unknown vendor'**
  String get unknownVendor;

  /// No description provided for @package.
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get package;

  /// No description provided for @categoryVendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor Categories'**
  String get categoryVendor;

  /// No description provided for @categoryPage.
  ///
  /// In en, this message translates to:
  /// **'Category Page'**
  String get categoryPage;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// No description provided for @ratingFilter.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingFilter;

  /// No description provided for @fiveStars.
  ///
  /// In en, this message translates to:
  /// **'5 stars'**
  String get fiveStars;

  /// No description provided for @starsAndAbove.
  ///
  /// In en, this message translates to:
  /// **'{count} stars and above'**
  String starsAndAbove(Object count);

  /// No description provided for @allRatings.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allRatings;

  /// No description provided for @serviceType.
  ///
  /// In en, this message translates to:
  /// **'Service Type'**
  String get serviceType;

  /// No description provided for @noProductsMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No products match the current filter!'**
  String get noProductsMatchFilter;

  /// No description provided for @paymentPage.
  ///
  /// In en, this message translates to:
  /// **'Payment Page'**
  String get paymentPage;

  /// No description provided for @orderForm.
  ///
  /// In en, this message translates to:
  /// **'Order Form'**
  String get orderForm;

  /// No description provided for @selectedPackage.
  ///
  /// In en, this message translates to:
  /// **'Selected Package'**
  String get selectedPackage;

  /// No description provided for @noPackagesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No packages available'**
  String get noPackagesAvailable;

  /// No description provided for @selectPackage.
  ///
  /// In en, this message translates to:
  /// **'Select Package'**
  String get selectPackage;

  /// No description provided for @addSpecialNotes.
  ///
  /// In en, this message translates to:
  /// **'Add notes or special requests'**
  String get addSpecialNotes;

  /// No description provided for @priceSummary.
  ///
  /// In en, this message translates to:
  /// **'Price Summary'**
  String get priceSummary;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get totalPrice;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loadingData;

  /// No description provided for @loginAsCustomerToBuy.
  ///
  /// In en, this message translates to:
  /// **'Login as customer to purchase a package'**
  String get loginAsCustomerToBuy;

  /// No description provided for @selectEventDateFirst.
  ///
  /// In en, this message translates to:
  /// **'Select event date first'**
  String get selectEventDateFirst;

  /// No description provided for @selectPackageFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a package first'**
  String get selectPackageFirst;

  /// No description provided for @packageNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Package not available. Please choose another package.'**
  String get packageNotAvailable;

  /// No description provided for @purchaseSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Purchase successful! The package has been added to your profile.'**
  String get purchaseSuccessful;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2024 {appName}. All rights reserved.'**
  String copyright(Object appName);

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @customizeYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Customize your app experience'**
  String get customizeYourExperience;

  /// No description provided for @mainSettings.
  ///
  /// In en, this message translates to:
  /// **'MAIN SETTINGS'**
  String get mainSettings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @automatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic;

  /// No description provided for @languageChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChangedTo(Object language);

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'ABOUT APP'**
  String get aboutApp;

  /// No description provided for @aboutApplication.
  ///
  /// In en, this message translates to:
  /// **'About Application'**
  String get aboutApplication;

  /// No description provided for @appInformation.
  ///
  /// In en, this message translates to:
  /// **'Information about {appName}'**
  String appInformation(Object appName);

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// No description provided for @termsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy'**
  String get termsPrivacy;

  /// No description provided for @readOurPolicies.
  ///
  /// In en, this message translates to:
  /// **'Read our policies'**
  String get readOurPolicies;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @indonesianLanguage.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get indonesianLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English (United States)'**
  String get englishLanguage;

  /// No description provided for @indonesia.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get indonesia;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @aboutAppDescription1.
  ///
  /// In en, this message translates to:
  /// **'EventHub is an all-in-one platform to hire professional services for all your event needs.'**
  String get aboutAppDescription1;

  /// No description provided for @aboutAppDescription2.
  ///
  /// In en, this message translates to:
  /// **'This application connects customers with trusted vendors in one easy-to-use place.'**
  String get aboutAppDescription2;

  /// No description provided for @forVendors.
  ///
  /// In en, this message translates to:
  /// **'For Vendors'**
  String get forVendors;

  /// No description provided for @vendorDescription.
  ///
  /// In en, this message translates to:
  /// **'Vendors can add and manage their service packages directly through the app, making it easier to reach more potential customers.'**
  String get vendorDescription;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @vendorProfile.
  ///
  /// In en, this message translates to:
  /// **'Vendor Profile'**
  String get vendorProfile;

  /// No description provided for @failedToLoadVendor.
  ///
  /// In en, this message translates to:
  /// **'Failed to load vendor data'**
  String get failedToLoadVendor;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description yet'**
  String get noDescription;

  /// No description provided for @yourPackages.
  ///
  /// In en, this message translates to:
  /// **'Your Packages'**
  String get yourPackages;

  /// No description provided for @priceNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get priceNotSet;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get noDescriptionAvailable;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete Confirmation'**
  String get deleteConfirmation;

  /// No description provided for @confirmDeletePackage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the package \'{package}\'?'**
  String confirmDeletePackage(Object package);

  /// No description provided for @packageDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Package \'{package}\' deleted successfully.'**
  String packageDeletedSuccessfully(Object package);

  /// No description provided for @vendorNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Vendor not logged in.'**
  String get vendorNotLoggedIn;

  /// No description provided for @noImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected.'**
  String get noImageSelected;

  /// No description provided for @profilePictureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated successfully.'**
  String get profilePictureUpdated;

  /// No description provided for @failedToUpdatePicture.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile picture: {error}'**
  String failedToUpdatePicture(Object error);

  /// No description provided for @editPackagePrice.
  ///
  /// In en, this message translates to:
  /// **'Edit Package Price'**
  String get editPackagePrice;

  /// No description provided for @packageName.
  ///
  /// In en, this message translates to:
  /// **'Package Name'**
  String get packageName;

  /// No description provided for @enterPackagePrice.
  ///
  /// In en, this message translates to:
  /// **'Enter package price (example: 500000)'**
  String get enterPackagePrice;

  /// No description provided for @priceRequired.
  ///
  /// In en, this message translates to:
  /// **'Price cannot be empty'**
  String get priceRequired;

  /// No description provided for @enterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price'**
  String get enterValidPrice;

  /// No description provided for @serviceDescription.
  ///
  /// In en, this message translates to:
  /// **'Service Description (separate with commas)'**
  String get serviceDescription;

  /// No description provided for @serviceExample.
  ///
  /// In en, this message translates to:
  /// **'Example: Photographer, Videographer, Printed Album'**
  String get serviceExample;

  /// No description provided for @serviceDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Service description cannot be empty'**
  String get serviceDescriptionRequired;

  /// No description provided for @useCommaSeparator.
  ///
  /// In en, this message translates to:
  /// **'Use commas (,) to separate services'**
  String get useCommaSeparator;

  /// No description provided for @packagePriceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Package price updated successfully!'**
  String get packagePriceUpdated;

  /// No description provided for @vendorDetails.
  ///
  /// In en, this message translates to:
  /// **'Vendor Details'**
  String get vendorDetails;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @noDescriptionForVendor.
  ///
  /// In en, this message translates to:
  /// **'No description for this vendor.'**
  String get noDescriptionForVendor;

  /// No description provided for @orderNow.
  ///
  /// In en, this message translates to:
  /// **'Order Now'**
  String get orderNow;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @clientReviews.
  ///
  /// In en, this message translates to:
  /// **'Client Reviews'**
  String get clientReviews;

  /// No description provided for @perEvent.
  ///
  /// In en, this message translates to:
  /// **'per event'**
  String get perEvent;

  /// No description provided for @vendorNotFoundInDatabase.
  ///
  /// In en, this message translates to:
  /// **'Vendor not found in database'**
  String get vendorNotFoundInDatabase;

  /// No description provided for @failedToLoadVendorData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load vendor data: {error}'**
  String failedToLoadVendorData(Object error);

  /// No description provided for @packagesDeletedByVendor.
  ///
  /// In en, this message translates to:
  /// **'Packages have been deleted by the vendor.'**
  String get packagesDeletedByVendor;

  /// No description provided for @thisPackageDeletedByVendor.
  ///
  /// In en, this message translates to:
  /// **'This package has been deleted by the vendor.'**
  String get thisPackageDeletedByVendor;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountConsequences.
  ///
  /// In en, this message translates to:
  /// **'All your data, orders, and preferences will be permanently deleted.'**
  String get deleteAccountConsequences;

  /// No description provided for @enterPasswordToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm:'**
  String get enterPasswordToConfirm;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @deletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting account...'**
  String get deletingAccount;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get wrongPassword;

  /// No description provided for @requiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'For security reasons, please log in again before deleting your account.'**
  String get requiresRecentLogin;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get tooManyAttempts;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account. Please try again.'**
  String get deleteAccountFailed;

  /// No description provided for @accountDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully.'**
  String get accountDeletedSuccessfully;

  /// No description provided for @permanentDeleteWarning.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and data'**
  String get permanentDeleteWarning;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// No description provided for @loginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Login to continue'**
  String get loginToContinue;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmailFormat;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get passwordMinLength;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @noAccountRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get noAccountRegister;

  /// No description provided for @loginAsCustomer.
  ///
  /// In en, this message translates to:
  /// **'Login as Customer'**
  String get loginAsCustomer;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccess;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password!'**
  String get invalidCredentials;

  /// No description provided for @loginAsVendor.
  ///
  /// In en, this message translates to:
  /// **'Login as Vendor'**
  String get loginAsVendor;

  /// No description provided for @registerCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Customer Account'**
  String get registerCreateTitle;

  /// No description provided for @registerCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details to register as a customer'**
  String get registerCreateSubtitle;

  /// No description provided for @registerFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get registerFullName;

  /// No description provided for @registerEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmail;

  /// No description provided for @registerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPassword;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPassword;

  /// No description provided for @registerPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get registerPhoneNumber;

  /// No description provided for @registerAddress.
  ///
  /// In en, this message translates to:
  /// **'Full Address'**
  String get registerAddress;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get registerHaveAccount;

  /// No description provided for @errorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get errorNameRequired;

  /// No description provided for @errorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get errorEmailRequired;

  /// No description provided for @errorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get errorEmailInvalid;

  /// No description provided for @errorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get errorPasswordRequired;

  /// No description provided for @errorPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get errorPasswordMinLength;

  /// No description provided for @errorConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required'**
  String get errorConfirmPasswordRequired;

  /// No description provided for @errorPasswordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errorPasswordNotMatch;

  /// No description provided for @errorPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get errorPhoneRequired;

  /// No description provided for @errorPhoneOnlyNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be numeric'**
  String get errorPhoneOnlyNumber;

  /// No description provided for @errorPhoneMinDigit.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be at least 10 digits'**
  String get errorPhoneMinDigit;

  /// No description provided for @errorAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get errorAddressRequired;

  /// No description provided for @permissionContactRequired.
  ///
  /// In en, this message translates to:
  /// **'Contact permission is required for registration.'**
  String get permissionContactRequired;

  /// No description provided for @permissionContactDenied.
  ///
  /// In en, this message translates to:
  /// **'Contact permission denied. Please enable it manually in Settings.'**
  String get permissionContactDenied;

  /// No description provided for @permissionContactBlocked.
  ///
  /// In en, this message translates to:
  /// **'Contact permission blocked. Please enable it manually in Settings.'**
  String get permissionContactBlocked;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account registered successfully!'**
  String get registerSuccess;

  /// No description provided for @registerEmailUsed.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get registerEmailUsed;

  /// No description provided for @registerGeneralError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String registerGeneralError(Object error);

  /// No description provided for @registerVendorTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Vendor Account'**
  String get registerVendorTitle;

  /// No description provided for @registerVendorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details to register as a vendor'**
  String get registerVendorSubtitle;

  /// No description provided for @registerVendorName.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get registerVendorName;

  /// No description provided for @registerVendorEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerVendorEmail;

  /// No description provided for @registerVendorPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerVendorPassword;

  /// No description provided for @registerVendorConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerVendorConfirmPassword;

  /// No description provided for @registerVendorPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get registerVendorPhone;

  /// No description provided for @registerVendorAddress.
  ///
  /// In en, this message translates to:
  /// **'Store Address'**
  String get registerVendorAddress;

  /// No description provided for @registerVendorButton.
  ///
  /// In en, this message translates to:
  /// **'Register Vendor'**
  String get registerVendorButton;

  /// No description provided for @basicPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Basic package price is required'**
  String get basicPriceRequired;

  /// No description provided for @premiumPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Premium package price is required'**
  String get premiumPriceRequired;

  /// No description provided for @customPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Custom package price is required'**
  String get customPriceRequired;

  /// No description provided for @priceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid price'**
  String get priceInvalid;

  /// No description provided for @priceTooHigh.
  ///
  /// In en, this message translates to:
  /// **'Price cannot exceed 10 million'**
  String get priceTooHigh;

  /// No description provided for @paketBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic Package'**
  String get paketBasic;

  /// No description provided for @paketPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium Package'**
  String get paketPremium;

  /// No description provided for @paketCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom Package'**
  String get paketCustom;

  /// No description provided for @hargaBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic Price'**
  String get hargaBasic;

  /// No description provided for @jasaBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic Service'**
  String get jasaBasic;

  /// No description provided for @hargaPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium Price'**
  String get hargaPremium;

  /// No description provided for @jasaPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium Service'**
  String get jasaPremium;

  /// No description provided for @hargaCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom Price'**
  String get hargaCustom;

  /// No description provided for @jasaCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom Service'**
  String get jasaCustom;

  /// No description provided for @hargaBasicWajibDiisi.
  ///
  /// In en, this message translates to:
  /// **'Basic price is required'**
  String get hargaBasicWajibDiisi;

  /// No description provided for @jasaBasicWajibDiisi.
  ///
  /// In en, this message translates to:
  /// **'Basic service is required'**
  String get jasaBasicWajibDiisi;

  /// No description provided for @hargaPremiumWajibDiisi.
  ///
  /// In en, this message translates to:
  /// **'Premium price is required'**
  String get hargaPremiumWajibDiisi;

  /// No description provided for @jasaPremiumWajibDiisi.
  ///
  /// In en, this message translates to:
  /// **'Premium service is required'**
  String get jasaPremiumWajibDiisi;

  /// No description provided for @hargaCustomWajibDiisi.
  ///
  /// In en, this message translates to:
  /// **'Custom price is required'**
  String get hargaCustomWajibDiisi;

  /// No description provided for @jasaCustomWajibDiisi.
  ///
  /// In en, this message translates to:
  /// **'Custom service is required'**
  String get jasaCustomWajibDiisi;

  /// No description provided for @hargaTidakValid.
  ///
  /// In en, this message translates to:
  /// **'Price is not valid'**
  String get hargaTidakValid;

  /// No description provided for @hargaTidakBolehLebihDari10Juta.
  ///
  /// In en, this message translates to:
  /// **'Price cannot exceed 10 million'**
  String get hargaTidakBolehLebihDari10Juta;

  /// No description provided for @registerVendorSuccess.
  ///
  /// In en, this message translates to:
  /// **'Vendor registered successfully!'**
  String get registerVendorSuccess;

  /// No description provided for @permissionContactRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Permission Required'**
  String get permissionContactRequiredTitle;

  /// No description provided for @permissionContactRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow contact access to continue.'**
  String get permissionContactRequiredMessage;

  /// No description provided for @cobaLagi.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get cobaLagi;

  /// No description provided for @batal.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get batal;

  /// No description provided for @permissionDitolakPermanenTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission Permanently Denied'**
  String get permissionDitolakPermanenTitle;

  /// No description provided for @permissionDitolakPermanenMessage.
  ///
  /// In en, this message translates to:
  /// **'Enable contact access from settings.'**
  String get permissionDitolakPermanenMessage;

  /// No description provided for @bukaPengaturan.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get bukaPengaturan;

  /// No description provided for @continueDialog.
  ///
  /// In en, this message translates to:
  /// **'continue'**
  String get continueDialog;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @pleaseAllowContactToRegister.
  ///
  /// In en, this message translates to:
  /// **'Please allow contact access to register.'**
  String get pleaseAllowContactToRegister;

  /// No description provided for @contactPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Contact permission denied.'**
  String get contactPermissionDenied;

  /// No description provided for @contactPermissionBlocked.
  ///
  /// In en, this message translates to:
  /// **'Contact permission blocked. Enable in Settings.'**
  String get contactPermissionBlocked;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @basic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get basic;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @packages.
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get packages;

  /// No description provided for @testimonials.
  ///
  /// In en, this message translates to:
  /// **'Testimonials'**
  String get testimonials;

  /// No description provided for @vendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get vendor;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @buyPackage.
  ///
  /// In en, this message translates to:
  /// **'Buy Package'**
  String get buyPackage;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistory;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @invalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid input'**
  String get invalidInput;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
