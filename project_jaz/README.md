# jaz_app

A new Flutter application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

1.Dart types update

        pub run build_runner build

   or

        flutter pub run build_runner build  --delete-conflicting-outputs
      1. //graphql_api.graphql.dart 3462 Description
        String? description;
        late int giataId;
        ProductsQuery$Query$Products$PackageProducts$Hotel$References? references;
        @override
        List<Object?> get props => [
        name,
        description,
        
       2. this (graphql_api.graphql.g.dart) line need to change after run the build
        Map<String, dynamic> _$DateRangeFilterInputToJson(
                DateRangeFilterInput instance) =>
            <String, dynamic>{
              'minDate': instance.minDate?.toIso8601String().substring(0,10),
              'maxDate': instance.maxDate?.toIso8601String().substring(0,10),
            };
       3.     this (graphql_api.graphql.dart) 53 line need to add after run the build
            bool isInFavoritesCheck=false;
            mixin TsbobCollectionOfferFieldsMixin {
       
        4.   (graphql_api.graphql.dart)add nodecode
          @JsonSerializable(explicitToJson: true)
        class Destinations$Query$Options$Destinations extends JsonSerializable
            with EquatableMixin {
            Destinations$Query$Options$Destinations();

            factory Destinations$Query$Options$Destinations.fromJson(
            Map<String, dynamic> json) =>
            _$Destinations$Query$Options$DestinationsFromJson(json);

            String? label;
            String? nodeCode;
            String? value;
            List<Destinations$Query$Options$Destinations$Children>? children;

            @override
            List<Object?> get props => [label, value,nodeCode, children];
                @override
            Map<String, dynamic> toJson() =>
            _$Destinations$Query$Options$DestinationsToJson(this);
            }

         //discound info changes (graphql_api.graphql.dart)
     class name:class DetailOfferDataMixin$Rooms$Room extends JsonSerializable
     add this property ->DetailOfferDataMixin$Price$DiscountInfo? discountInfo;
     add this property ->   String? promoCode;
     in props also add param->discountInfo,promoCode

     //facebook appEvents
     flutter plugins->
     facebook_app_events->ios->facebooki_app_events.podspec->change the version number->'FBSDKCoreKit', '~> 12.2.1'
     facebook_facebook_login->ios->facebook_facebook_login.podspec->change the version number->'FBSDKCoreKit', '~> 12.2.1','FBSDKLoginKit', '~> 12.2.1'
     
     facebook_app_events->android->build.gradle->change the compiled version->30
      ext.kotlin_version = '1.4.21'
     facebook_facebook_login->android->build.gradle->change the compiled version->30
      change depenticies ->api 'com.facebook.android:facebook-login:12.+'






