import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:graphql/client.dart';
import 'package:http/http.dart' as http;
import 'package:jaz_app/helper/graphqlconnectivity/constants.dart';
import 'package:jaz_app/helper/search_service.dart';
import 'package:jaz_app/models/currencyModel.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/http_client.dart';
import 'package:intl/intl.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/utils/strings.dart';
import '../graphql_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CommonUtils {
  HttpClient httpClient = HttpClient();
  FirebaseAuth auth = FirebaseAuth.instance;

  getHotelDetails() async {
    HashMap<String, dynamic> params = HashMap();
    params.putIfAbsent("renderPage", () => "about");
    params.putIfAbsent("_locale", () => "en-gb");
    var response;
    httpClient.getRenderData(params, "/api/renders", null).then((value) {
      response = value;
      if (response.statusCode == 200 && json.decode(response.body) != null) {
        var result = json.decode(response.body);
        result["content"]["footer"]["children"].forEach((element) {
          if (element["children"].length > 0) {
            element["children"].forEach((e) {
              if (e["module"]["result"]["links"] != null) {
                e["module"]["result"]["links"].forEach((termsLink) {

                  if (element["children"][0]["module"]["result"] != null) {
                    GlobalState.contactUsLinks =
                    element["children"][0]["module"]["result"];
                  }
                  if (termsLink["label"]
                      .toString()
                      .contains("Terms & Conditions")) {
                    GlobalState.termsAndConditionUrl =
                        termsLink["path"].toString();
                  }
                });
              }
            });
          }
          if (result["content"]["footer"]["children"][1] != null) {
            if (result["content"]["footer"]["children"][1]["module"] != null) {
              GlobalState.socialMediaLinks = result["content"]["footer"]
              ["children"][1]["module"]['result']['socialMediaLinks']; // get social media links
            }}
        });

        if (result["content"]["main"]["children"][0]["module"]["result"]
                ["headline"] !=
            null) {
          GlobalState.aboutsHeadLine = result["content"]["main"]["children"][0]
              ["module"]["result"]["headline"];
        } // get and save about us headline

        if (result["content"]["main"]["children"][2]["module"]["result"]
                ["headline"] !=
            null) {
          GlobalState.aboutUsContentHeadLine = result["content"]["main"]
              ["children"][2]["module"]["result"]["headline"];
        }

        List<String> imageList = [];

        // about us
        result["content"]["main"]["children"][2]["module"]["result"]["images"]
            .forEach((images) {
          imageList.add(AppUtility().getProxyImage(images));
        //   if (images!=null&&images['image']['secure_url'] != null) {
        //     imageList.add(images['image']['secure_url']);
        //   }
          // get image path and save in global state
        });
        GlobalState.imageList = imageList;
        if (result["content"]["main"]["children"][2]["module"]["result"]
                ["text"] !=
            null) {
          GlobalState.aboutUsContent = AppUtility().parseHtmlString(
              result["content"]["main"]["children"][2]["module"]["result"]
                  ['text']);
        } // get and save about us content
        // about us
      } else {}
    });
  }

  Future<HashMap<String, dynamic>> checkAvailablity(
      HashMap<String, dynamic> params,
      String roomTypeCode,
      String roomRatePlanCode,
      String hotelId,
      String price,
      String ratePlanCurrencyCode,
      String selectedPromoCode,
       int roomIndex,
      String children,
      String adult) async {
    int roomLength = 1;
    List selectedRoomList = GlobalState.selectedRoomList;
    selectedRoomList.forEach((element) {
      if(element.roomDetail["roomTypeCode"]==roomTypeCode&&element.roomDetail["roomRatePlanCode"]==roomRatePlanCode){
        roomLength = roomLength+1;
      }
    });
    List<int> refs = [];
    int refId = 0;
    List<TravellersRoomInput> roomRef =[];
    List<TravellerFilterInput> roomRefType=[];
    selectedRoomList[roomIndex-1].adultList.forEach((adult) {
      roomRefType.add(TravellerFilterInput(age: adult, refId: ++refId));
      refs.add(refId);
    });
    selectedRoomList[roomIndex-1].childList.forEach((child) {
      roomRefType
          .add(TravellerFilterInput(age: int.parse(child), refId: ++refId));
      refs.add(refId);
    });
    TravellersRoomInput selectedRoomRef = TravellersRoomInput(refIds: refs);
    roomRef.add(selectedRoomRef);


    HashMap<String, dynamic> policyParams = HashMap();
    policyParams.putIfAbsent("hotel_crs_code", () => params["hotel_crs_code"]);
    HashMap<String, dynamic> selectedRoom = HashMap();
    DateFormat startFormatter = DateFormat('yyyy-MM-dd');
    String checkInDate = startFormatter.format(GlobalState.checkInDate);
    String checkOutDate = startFormatter.format(GlobalState.checkOutDate);
    params.putIfAbsent("check_in", () => checkInDate);
    params.putIfAbsent("check_out", () => checkOutDate);
    params.putIfAbsent("rooms", () => "1");
    params.putIfAbsent("adults", () => adult);
    params.putIfAbsent("children", () => children);
    params.putIfAbsent("promo_code", () => selectedPromoCode);
    EasyLoading.show();
    HashMap<String, dynamic> paymentParams = HashMap();
    paymentParams.putIfAbsent("hotel_id", () => hotelId);

    List<Future<dynamic>> requestList = [
      httpClient.getData(params, "check_hotel_availability", null),
      httpClient.getData(paymentParams, "get_payment_info", null),
      httpClient.getData(policyParams, "get_hotel_policies", null)];
    try {
      if(GlobalState.selectedCurrency!=Strings.usd) {
        GetOfferListArguments args = SearchService().getOfferListArguments(int.parse(hotelId.toString()),"USD",selectedPromoCode,roomRefType,roomRef);
        requestList.add(client.query(QueryOptions(
            document: GET_OFFER_LIST_QUERY_DOCUMENT,
            variables: args.toJson()),
        ));
      }
      List allResponse = await Future.wait(requestList);
      var response = allResponse[0];
      var paymentResponse = allResponse[1];
      var policyResponse = allResponse[2];
      var currencyResponse;


      if(GlobalState.selectedCurrency!=Strings.usd) {
        currencyResponse = allResponse[3];
        final exception = currencyResponse.hasException.hashCode;
        if (currencyResponse.hasException) {
          if (exception is NetworkException) {
            currencyResponse = Strings.noInternet;
          } else {
            currencyResponse = Strings.errorMessage;
          }
          selectedRoom.putIfAbsent(
              "currencyResponseCode", () => Strings.failure);
        }
        else {
          GetOfferList$Query offerList = GetOfferList$Query.fromJson(
              currencyResponse.data ?? {});
          offerList.productOffers!.hotels!.forEach((hotels) {
            hotels.offers.forEach((offers) {
              if (offers.rooms!.room![0].opCode == roomTypeCode && offers.rooms!.room![0].board!.opCode == roomRatePlanCode ){
                selectedRoom.putIfAbsent("currencyResponseCode", () => Strings.success);
                selectedRoom.putIfAbsent(
                    "price", () => (offers.rooms!.room![0].price!.amount+offers.rooms!.room![0].price!.taxAmount).toStringAsFixed(2).toString());
                selectedRoom.putIfAbsent("ratePlanCountryCode",
                        () =>offers.rooms!.room![0].price!.currency);
                selectedRoom.putIfAbsent("convertedPrice", () => price);
              }
            });
          });
        }
      }else{
        selectedRoom.putIfAbsent("price", () => price);
        selectedRoom.putIfAbsent("ratePlanCountryCode", () =>ratePlanCurrencyCode);
        selectedRoom.putIfAbsent("convertedPrice", () => price);
      }


      if (paymentResponse.statusCode == 200 &&
          json.decode(paymentResponse.body) != null) {
        var res = (json.decode(paymentResponse.body));
        selectedRoom.putIfAbsent("profileId", () => res["test"]["profile_id"]);
        selectedRoom.putIfAbsent("serverKey", () => res["test"]["server_key"]);
        selectedRoom.putIfAbsent("clientKey", () => res["test"]["client_key"]);
        selectedRoom.putIfAbsent("uae_profileId", () => res["test_uae"]["profile_id"]);
        selectedRoom.putIfAbsent("uae_serverKey", () => res["test_uae"]["server_key"]);
        selectedRoom.putIfAbsent("uae_clientKey", () => res["test_uae"]["client_key"]);
        // selectedRoom.putIfAbsent("profileId", () => res["live"]["profile_id"]);
        // selectedRoom.putIfAbsent("serverKey", () => res["live"]["server_key"]);
        // selectedRoom.putIfAbsent("clientKey", () => res["live"]["client_key"]);
        // selectedRoom.putIfAbsent("uae_profileId", () => res["live_uae"]["profile_id"]);
        // selectedRoom.putIfAbsent("uae_serverKey", () => res["live_uae"]["server_key"]);
        // selectedRoom.putIfAbsent("uae_clientKey", () => res["live_uae"]["client_key"]);
        selectedRoom.putIfAbsent("paymentResponseCode", () => Strings.success);
      } else {
        selectedRoom.putIfAbsent("paymentResponseCode", () => Strings.failure);
      }
      if (response.statusCode == 200 && json.decode(response.body) != null) {
        bool isSuccess = false;
        List room = (json.decode(response.body)['OTA_HotelAvailRS']['RoomStays']
        ['RoomStay']['RoomRates']['RoomRate'] as List);
        room.forEach((element) {
          var attr = element['_attributes'];
          if (attr['RoomTypeCode'] == roomTypeCode &&
              attr['RatePlanCode'] == roomRatePlanCode &&
              int.parse(attr['NumberOfUnits']) >= roomLength) {
            isSuccess = true;
            var rates = element['Rates'];
            var hotelcountrycode = json
                .decode(response.body)['OTA_HotelAvailRS']['RoomStays']
            ['RoomStay']['BasicPropertyInfo']['Address']['CountryName']
            ['_attributes']['Code']
                .toString();
            var nonRefundableRatePlan = rates["Rate"]["CancelPolicies"]
            ["CancelPenalty"]["_attributes"]["PolicyCode"].toString();
            selectedRoom.putIfAbsent("hotelcountrycode", () => hotelcountrycode);
            selectedRoom.putIfAbsent("nonRefundableRatePlan", () => nonRefundableRatePlan);
            selectedRoom.putIfAbsent("roomTypeCode", () => roomTypeCode);
            selectedRoom.putIfAbsent("roomRatePlanCode", () => roomRatePlanCode);

            selectedRoom.putIfAbsent("cancelPolicyDescription", () => rates["Rate"]["CancelPolicies"]
            ["CancelPenalty"]["PenaltyDescription"]["Text"]["_text"]);
            selectedRoom.putIfAbsent("guaranteeDescription", () => rates["Rate"]["PaymentPolicies"]
            ["GuaranteePayment"]["Description"]["Text"]["_text"]);
          }
        });
        if(isSuccess){
          selectedRoom.putIfAbsent("responseCode", () => Strings.success);
        }else{
          selectedRoom.putIfAbsent("responseCode", () => Strings.failure);
        }
      } else {
        selectedRoom.putIfAbsent("responseCode", () => Strings.failure);
      }

      if (policyResponse.statusCode == 200 &&
          json.decode(policyResponse.body) != null) {
        var policyResult = (json.decode(policyResponse.body));
        selectedRoom.putIfAbsent("cancelPolicyDescription", () => policyResult["CancelPolicies"]
        ["CancelPenalty"]["PenaltyDescription"]["Text"]["_text"]);
        selectedRoom.putIfAbsent("guaranteeDescription", () => policyResult["PaymentPolicy"]
        ["RequiredPayment"]["PaymentDescription"]["Text"]["_text"]);
        selectedRoom.putIfAbsent("petPolicyDescription", () => policyResult["PetsPolicies"]
        ["PetsPolicy"]["Description"]["Text"]["_text"]);
        selectedRoom.putIfAbsent("petPolicyDescription", () => policyResult["PetsPolicies"]
        ["PetsPolicy"]["Description"]["Text"]["_text"]);
        if(policyResult["PolicyInfoCodes"]!=null&& policyResult["PolicyInfoCodes"]["PolicyInfoCode"]!=null){
          policyResult["PolicyInfoCodes"]["PolicyInfoCode"].forEach((policyDesc){
            if(policyDesc["Description"]["_attributes"]["Name"]=="Family Policy"){
              selectedRoom.putIfAbsent("familyPolicyDescription", () => policyDesc["Description"]["Text"]["_text"]);
            }
            if(policyDesc["Description"]["_attributes"]["Name"]=="Group Policy"){
              selectedRoom.putIfAbsent("groupPolicyDescription", () => policyDesc["Description"]["Text"]["_text"]);
            }
          });

        }
      }

    } catch (e) {
      selectedRoom.putIfAbsent("responseCode", () => Strings.failure);
      selectedRoom.putIfAbsent("paymentResponseCode", () => Strings.failure);
      if(GlobalState.selectedCurrency!=Strings.usd) {
        selectedRoom.putIfAbsent("currencyResponseCode", () => Strings.failure);
      }
    }
    EasyLoading.dismiss();
    return selectedRoom;
  }

  Future<CurrencyResponse> readCurrencies() async {
    final String response =
        await rootBundle.loadString('assets/currency/currencies.json');
    final data = await json.decode(response);
    return CurrencyResponse.fromJson(data);
  }

  Future<HashMap<String, dynamic>> getOverView(String giataId) {
    HashMap<String, dynamic> params = HashMap();
    HashMap<String,dynamic> descResult = HashMap();
    params.putIfAbsent("renderPage", () => "/hoteldetail\/" + giataId);
    params.putIfAbsent("_locale", () => "en-gb");
   return httpClient.getRenderData(params, "/api/renders", null).then((value) {
    if (value.statusCode == 200 && json.decode(value.body) != null) {
      var result = json.decode(value.body);
      HashMap<String, String> listPage = HashMap();
      var pages = result["content"]["hoteldetailNavigation"]["children"][0]
      ["module"]["result"]["pages"];
      pages.forEach((page) {
        listPage.putIfAbsent(page["name"], () => page["resource"]);
      });
      descResult.putIfAbsent("bottomList", () => listPage);
      descResult.putIfAbsent("overViewResponseCode", () => Strings.success);
      HashMap<String, dynamic> descParam = HashMap();
      String description = "";
      List expansionList = [];
      List<String> proxy_images=[];
      List<String> gallery_images=[];

      descParam.putIfAbsent("renderPage",
              () => "/hoteldetail/" + giataId + "/" + listPage["Resort Overview"].toString());
      descParam.putIfAbsent("_locale", () => "en-gb");
      return httpClient.getRenderData(descParam, "/api/renders", null).then((value) {
        if (value.statusCode == 200 && json.decode(value.body) != null) {
          var result = json.decode(value.body);
          result["content"]["main"]["children"].forEach((overview) {
            if (overview["module"]["result"]["subheadline"] != null) {
              description = overview["module"]["result"]["subheadline"] != null ? overview["module"]["result"]["subheadline"].toString() : "";
            }
            if(description=="") {
              if (overview["children"] != null) {
                overview["children"].forEach((childrenDesc){
                  description = childrenDesc["module"]["result"]["text"] != null ? AppUtility().parseHtmlString(childrenDesc["module"]["result"]["text"].toString()) : "";
                });
              }
            }
           
            if (overview["module"]["result"]["headline"] != null &&
                overview["module"]["result"]["text"] != null) {
              HashMap<String, dynamic> expansionDetails = HashMap();
              expansionDetails.putIfAbsent("name", () => overview["module"]["result"]["headline"].toString());
              expansionDetails.putIfAbsent("desc", () => overview["module"]["result"]["text"].toString());
             // expansionDetails.putIfAbsent("image", () => overview["module"]["result"]["image"]["url"].toString());
               expansionDetails.putIfAbsent("image", () => AppUtility().getProxyImage(overview["module"]["result"]));
              expansionList.add(expansionDetails);
            }
            if( overview["module"]["result"]["headlines"]==null && overview["module"]["result"]["headline"]==null&& overview["module"]["result"]["images"] != null){
              overview["module"]["result"]["images"].forEach((image){
                proxy_images.add(AppUtility().getProxyImage(image));
                gallery_images.add(AppUtility().getGalleryViewImage(image));
              });
            }
          });
          descResult.putIfAbsent("proxy_images", () => proxy_images);
          descResult.putIfAbsent("original_images", () => gallery_images);
          descResult.putIfAbsent("description", () => description);
          descResult.putIfAbsent("expansion", () => expansionList);
          descResult.putIfAbsent("descResponseCode", () => Strings.success);

        } else {
          descResult.putIfAbsent("descResponseCode", () => Strings.failure);
        }
        return descResult;
      });
    } else {
      descResult.putIfAbsent("overViewResponseCode", () => Strings.failure);
      return descResult;
    }

  });

  }

  Future<String> convertCurrency(String price,String currencyCode) async {
    var selectedPrice ="";
    HashMap<String, dynamic> currencyParams = HashMap();
    currencyParams.putIfAbsent("from", () => Strings.usd);
    currencyParams.putIfAbsent("to", () => currencyCode);
    currencyParams.putIfAbsent("amount", () => price);
    var response = await httpClient.convertCurrency(currencyParams);
    EasyLoading.dismiss();
    if (response.statusCode == 200 &&
        json.decode(response.body) != null) {
        var resp = json.decode(response.body);
        selectedPrice = resp["to"][0]["mid"].toStringAsFixed(2).toString();
      } else {
       selectedPrice = Strings.failure;
    }
    return selectedPrice;
  }

  Future<HashMap<String, dynamic>> memberShipPrice(String hotelId) async {
    ProductsQueryArguments args = SearchService().getProductQueryArguments(
        GlobalState.checkInDate,
        GlobalState.checkOutDate,
        hotelId,
        GlobalState.themeValue,
        GlobalState.selectedRoomRef,
        GlobalState.selectedRoomRefType,membershipCode);
    args.resultsPerPage = 10;
    args.showingResultsFrom = 0;
    print(args);
    HashMap<String,dynamic> memberResult = HashMap();
     List<Future<dynamic>> requestQuery = [
        client.query(
          QueryOptions(
              document: PRODUCTS_QUERY_QUERY_DOCUMENT,
              variables: args.toJson()),
        ),
      ];
      List allResponse = await Future.wait(requestQuery);
      EasyLoading.dismiss();
      QueryResult queryResult = allResponse[0];
      final exception = queryResult.hasException.hashCode;
      var errorMessage;
      if (queryResult.hasException) {
        if (exception is NetworkException) {
          errorMessage = Strings.noInternet;
        } else {
          errorMessage = Strings.errorMessage;
        }
        memberResult.putIfAbsent("memberResponseCode", () => Strings.failure);
        memberResult.putIfAbsent("memberResponseMessage", () => errorMessage);
      } else {
        ProductsQuery$Query product = ProductsQuery$Query.fromJson(queryResult.data ?? {});
        var discountProduct = product.products!.packageProducts;
        if(discountProduct!.length>0) {
          var discountPrice = discountProduct[0].topOffer.price!.discountInfo!
               .perNightFullAmount!.toStringAsFixed(2).toString();
          var originalPrice =
               discountProduct[0].topOffer.price!.amount.toStringAsFixed(2)
                   .toString();
          memberResult.putIfAbsent("memberResponseCode", () => Strings.success);
          memberResult.putIfAbsent("discountPrice", () => discountPrice);
          memberResult.putIfAbsent("originalPrice", () => originalPrice);
        }
      }

    return memberResult;
  }

}
