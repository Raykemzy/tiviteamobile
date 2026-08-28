import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:tivi_tea/core/response/base_response.dart';
import 'package:tivi_tea/core/response/generic_paginated_response.dart';
import 'package:tivi_tea/features/artisans/model/artisan_response_model.dart';
import 'package:tivi_tea/features/artisans/model/quotation_model.dart';
import 'package:tivi_tea/features/artisans/model/quotation_request_bodies.dart';
import 'package:tivi_tea/features/artisans/model/request_quotation_request_body.dart';
import 'package:tivi_tea/features/favorites/model/favorite_listing_model.dart';
import 'package:tivi_tea/features/favorites/model/favorite_listing_request_body.dart';
import 'package:tivi_tea/features/history/model/booking_history_model.dart';
import 'package:tivi_tea/features/home/model/client/category_response_model.dart';
import 'package:tivi_tea/features/home/model/artisan/artisan_dashboard_model.dart';
import 'package:tivi_tea/features/home/model/client/client_dashboard_model.dart';
import 'package:tivi_tea/features/home/model/general/listing_response_model.dart';
import 'package:tivi_tea/features/home/model/service_provider/service_provider_dashboard_model.dart';
import 'package:tivi_tea/features/marketplace/model/create_marketplace_item_request_body.dart';
import 'package:tivi_tea/features/marketplace/model/create_marketplace_payment_request_body.dart';
import 'package:tivi_tea/features/marketplace/model/edit_marketplace_item_request_body.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_add_remove_cart_request_body.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_cart_item_model.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_create_order_request_body.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_order_create_response.dart';
import 'package:tivi_tea/features/marketplace/model/owner_marketplace_item_model.dart';
import 'package:tivi_tea/features/kyc/model/client_kyc_request_body.dart';
import 'package:tivi_tea/features/kyc/model/partner_kyc_request_body.dart';
import 'package:tivi_tea/features/login/model/general/delete_account_request_body.dart';
import 'package:tivi_tea/features/login/model/general/login_request_object.dart';
import 'package:tivi_tea/features/login/model/general/login_response_object.dart';
import 'package:tivi_tea/features/notifications/model/notification_model.dart';
import 'package:tivi_tea/features/payment/model/create_payment_response.dart';
import 'package:tivi_tea/features/payment/model/payout_models.dart';
import 'package:tivi_tea/features/reviews/model/review_models.dart';
import 'package:tivi_tea/features/payment/model/wallet_details_model.dart';
import 'package:tivi_tea/features/profile/model/change_password_model.dart';
import 'package:tivi_tea/features/profile/model/create_other_entity_account_request_body.dart';
import 'package:tivi_tea/features/profile/model/edit_profile_model.dart';
import 'package:tivi_tea/features/profile/model/switch_account_request_body.dart';
import 'package:tivi_tea/features/registration/model/artisan/artisan_sign_up_request_body.dart';
import 'package:tivi_tea/features/registration/model/client/customer_sign_up_request_body.dart';
import 'package:tivi_tea/features/registration/model/client/social_auth_model.dart';
import 'package:tivi_tea/features/registration/model/client/social_auth_response.dart';
import 'package:tivi_tea/features/registration/model/service_provider/service_provider_sign_up_request_body.dart';
import 'package:tivi_tea/features/registration/model/service_provider/service_provider_sign_up_response.dart';
import 'package:tivi_tea/features/services/model/bank_model.dart';
import 'package:tivi_tea/features/services/model/book_work_tool_model.dart';
import 'package:tivi_tea/features/services/model/book_workspace_model.dart';
import 'package:tivi_tea/features/services/model/book_workspace_response.dart';
import 'package:tivi_tea/features/services/model/create_foot_soldier_model.dart';
import 'package:tivi_tea/features/services/model/create_foot_soldier_response.dart';
import 'package:tivi_tea/features/services/model/create_transfer_recipient_model.dart';
import 'package:tivi_tea/features/services/model/create_transfer_recipient_response.dart';
import 'package:tivi_tea/features/services/model/get_account_details_request_body.dart';
import 'package:tivi_tea/features/services/model/get_account_details_response.dart';
import 'package:tivi_tea/features/services/model/post_listing_model.dart';
import 'package:tivi_tea/features/services/model/post_worktool_model.dart';
import 'package:tivi_tea/models/user_model.dart';

part 'rest_client.g.dart';

@RestApi()
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  //<====================> Authentication <====================>
  @POST('/authentication/partner/sign-up')
  Future<BaseResponse<ServiceProviderSignUpResponse>> signUpAsServiceProvider(
    @Body() ServiceProviderSignUpRequestBody data,
  );
  @POST('/authentication/artisan/sign-up')
  Future<BaseResponse<ServiceProviderSignUpResponse>> signUpAsArtisan(
    @Body() ArtisanSignUpRequestBody data,
  );
  @POST('/authentication/client/sign-up')
  Future<BaseResponse<CustomerSignUpResponseBody>> signUpAsCustomer(
    @Body() CustomerSignUpRequestBody data,
  );
  @POST('/authentication/login')
  Future<BaseResponse<LoginResponseObject>> login(
    @Body() LoginRequestObject data,
  );
  @POST('/authentication/reset-password')
  Future<BaseResponse> forgotPassword(@Body() ForgotPasswordRequestObject data);
  @PUT('/authentication/change-password')
  Future<BaseResponse> changePassword(@Body() ChangePasswordModel data);
  @POST('/authentication/partner/submit-kyc')
  Future<BaseResponse> submitKyc(@Body() PartnerKycRequestBody data);
  @POST('/authentication/client/submit-kyc')
  Future<BaseResponse> submitClientKyc(@Body() ClientKYCRequestBody data);
  @POST('/authentication/artisan/submit-kyc')
  Future<BaseResponse> submitArtisanKyc(@Body() ClientKYCRequestBody data);
  @POST('/authentication/client/social-auth')
  Future<BaseResponse<SocialAuthResponse>> signUpWithSocialAuth(
      @Body() SocialAuthModel data);
  @DELETE('/authentication/delete-account')
  Future<BaseResponse> deleteAccount(@Body() DeleteAccountRequestBody data);

  //<====================> Service <====================>
  @GET('/listings/')
  Future<BaseResponse<GenericPaginatedResponse<ListingResponseModel>>>
      getListing(@Query('page') int page, {@Query('name') String? name});

  @POST('/listings/')
  Future<BaseResponse<ListingResponseModel>> postWorkSpace(
    @Body() PostListingModel data,
  );
  @GET('/listings/{listingId}')
  Future<BaseResponse<ListingResponseModel>> getListingId(
    @Path('listingId') String listingId,
  );
  @DELETE('/listings/{listingId}')
  Future<BaseResponse> deleteListing(@Path('listingId') String listingId);
  @PUT('/listings/{listingId}')
  Future<BaseResponse<ListingResponseModel>> editWorkSpace(
    @Path('listingId') String listingId,
    @Body() PostListingModel data,
  );
  @PUT('/listings/{listingId}')
  Future<BaseResponse<ListingResponseModel>> editWorkTool(
    @Path('listingId') String listingId,
    @Body() WorkToolListing data,
  );

  @POST('/dashboard/partner/foot-soldier/create')
  Future<BaseResponse<CreateFootSoldierResponse>> createFootSoldier(
      @Body() CreateFootSoldierModel data);
  @GET('/payment/banks/list')
  Future<BaseResponse<ListBanksResponse>> getBanks();
  /// Verifies a bank account before it can receive payouts.
  ///
  /// Must be POST: the endpoint answers GET with 405 Method Not Allowed, so
  /// while this was declared `@GET` account verification always failed and the
  /// "Add account details" step could never complete.
  @POST('/payment/resolve_bank_info')
  Future<BaseResponse<GetAccountDetailsResponse>> getAccountDetails(
    @Body() GetAccountDetailsRequestBody data,
  );
  @POST('/payment/create_transfer_recipient')
  Future<BaseResponse<CreateTransferRecipientResponse>> createTransferRecipient(
    @Body() CreateTransferRecipientModel data,
  );

  ///This is the same endpoint as [postWorkSpace] above.
  ///However we'll call them separetly in case the endpoints are different in the future.
  @POST('/listings/')
  Future<BaseResponse> postToolOrOtherListing(@Body() WorkToolListing data);

  @GET('/listings/partner/listings')
  Future<BaseResponse<GenericPaginatedResponse<ListingResponseModel>>>
      getPartnerListing(@Query('page') int page);
  @GET('/listings/artisans')
  Future<BaseResponse<GenericPaginatedResponse<ArtisanResponseModel>>>
      getArtisansList(@Query('page') int page);
  @GET('/listings/artisan/{artisanId}')
  Future<BaseResponse<ArtisanResponseModel>> getArtisan(
    @Path('artisanId') String artisanId,
  );
  /// Artisan replies to a quotation request with a price.
  @POST('/bookings/send-quotation/{quotationId}')
  Future<BaseResponse<QuotationModel>> sendQuotation(
    @Path('quotationId') String quotationId,
    @Body() SendQuotationRequestBody data,
  );

  /// Either side counters. Capped at two counters each by the backend.
  @POST('/bookings/counter-quotation-price/{quotationId}')
  Future<BaseResponse<QuotationModel>> counterQuotationPrice(
    @Path('quotationId') String quotationId,
    @Body() CounterQuotationRequestBody data,
  );

  /// `action` is "accept" or "decline".
  @POST('/bookings/accept-or-decline-quotation/{quotationId}')
  Future<BaseResponse<QuotationModel>> acceptOrDeclineQuotation(
    @Path('quotationId') String quotationId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/bookings/request-quotation/{artisanId}')
  Future<BaseResponse<QuotationModel>> requestQuotation(
    @Path('artisanId') String artisanId,
    @Body() RequestQuotationRequestBody data,
  );
  @GET('/listings/categories')
  Future<BaseResponse<GenericPaginatedResponse<CategoryResponseModel>>>
      getCategories();
  @GET('/listings/market-place/items')
  Future<BaseResponse<GenericPaginatedResponse<ListingResponseModel>>>
      getMarketPlaceItems(@Query('page') int page);
  @GET('/listings/market-place/owners-items')
  Future<BaseResponse<GenericPaginatedResponse<OwnerMarketplaceItemModel>>>
      getOwnersMarketPlaceItems(@Query('page') int page);
  @POST('/listings/market-place/item/create')
  Future<BaseResponse<dynamic>> createMarketplaceItem(
    @Body() CreateMarketplaceItemRequestBody data,
  );
  @PUT('/listings/market-place/item/{item_id}')
  Future<BaseResponse<dynamic>> editMarketplaceItem(
    @Path('item_id') String itemId,
    @Body() EditMarketplaceItemRequestBody data,
  );
  @POST('/listings/market-place/item/publish/{item_id}')
  Future<BaseResponse<dynamic>> publishMarketplaceItem(
    @Path('item_id') String itemId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/listings/market-place/item/{item_id}')
  Future<dynamic> deleteMarketplaceItem(
    @Path('item_id') String itemId,
  );

  @GET('/listings/market-place/item/{item_id}')
  Future<BaseResponse<ListingResponseModel>> getMarketPlaceItem(
    @Path('item_id') String itemId,
  );

  @POST('/listings/market-place/add-or-remove-cart-items/{item_id}')
  Future<BaseResponse<dynamic>> addOrRemoveMarketPlaceCartItem(
    @Path('item_id') String itemId,
    @Body() MarketplaceAddRemoveCartRequestBody body,
  );

  @GET('/listings/market-place/cart/items')
  Future<
      BaseResponse<
          GenericPaginatedResponse<MarketplaceCartItemModel>>> getMarketPlaceCartItems();

  @POST('/listings/market-place/order')
  Future<BaseResponse<MarketplaceOrderCreateResponse>> createMarketPlaceOrder(
    @Body() MarketplaceCreateOrderRequestBody body,
  );

  @POST('/listings/market-place/order/item/cancel/{order_id}')
  Future<BaseResponse<dynamic>> cancelMarketPlaceOrderItem(
    @Path('order_id') String orderId,
  );

  @POST('/payment/market-place/{orderId}')
  Future<BaseResponse<CreatePaymentResponse>> createMarketPlaceOrderPayment(
    @Path('orderId') String orderId,
    @Body() CreateMarketplacePaymentRequestBody body,
  );

  //<====================> Notifications <====================>
  @GET('/notifications/')
  Future<BaseResponse<GenericPaginatedResponse<NotificationModel>>>
      getNotifications(@Query('page') int page);
  @POST('/notifications/mark-as-read')
  Future<BaseResponse<dynamic>> markNotificationsAsRead(
    @Body() Map<String, dynamic> data,
  );
  @POST('/notifications/mark-all-as-read')
  Future<BaseResponse<dynamic>> markAllNotificationsAsRead();
  @POST('/notifications/archive-notifications')
  Future<BaseResponse<dynamic>> archiveNotifications(
    @Body() Map<String, dynamic> data,
  );

  //<====================> Bookings <====================>
  @POST('/bookings/client/{listingId}')
  Future<BaseResponse<BookWorkSpaceResponse>> bookWorkspace(
    @Path() String listingId,
    @Body() BookWorkSpaceModel data,
  );

  @POST('/bookings/client/{listingId}')
  Future<BaseResponse<BookWorkSpaceResponse>> bookWorktool(
    @Path() String listingId,
    @Body() BookWorkToolModel data,
  );

  @GET('/bookings/list')
  Future<BaseResponse<GenericPaginatedResponse<BookingHistoryModel>>>
      getBookingHistory(@Query('page') int page);

  @POST('/bookings/{bookingId}/check-in-or-out')
  Future<BaseResponse> checkInCheckOut({
    @Path('bookingId') required String bookingId,
  });

  @GET('/bookings/{bookingId}')
  Future<BaseResponse<BookingHistoryModel>> getSingleBookingDetails({
    @Path('bookingId') required String bookingId,
  });

  /// Cancels a booking. Client entities only — partners follow up on bookings
  /// rather than cancelling them.
  @POST('/bookings/{bookingId}')
  Future<BaseResponse<dynamic>> cancelBooking({
    @Path('bookingId') required String bookingId,
  });

  //<====================> Dashboard <====================>
  @GET('/dashboard/partner')
  Future<BaseResponse<ServiceProviderDashboardModel>>
      getServiceProviderDashboard();
  @GET('/dashboard/client')
  Future<BaseResponse<ClientDashboardModel>> getClientDashboard();
  @GET('/dashboard/artisan')
  Future<BaseResponse<ArtisanDashboardModel>> getArtisanDashboard();
  @GET('/dashboard/user/profile')
  Future<BaseResponse<GetUserProfileResponse>> getUserProfile();
  @POST('/dashboard/edit-profile')
  Future<BaseResponse<User>> updateUserProfile(@Body() EditProfileModel data);
  @POST('/authentication/user/switch-account')
  Future<BaseResponse<dynamic>> switchAccount(
    @Body() SwitchAccountRequestBody data,
  );
  @POST('/authentication/user/create-other-entity-account')
  Future<BaseResponse<dynamic>> createOtherEntityAccount(
    @Body() CreateOtherEntityAccountRequestBody data,
  );
  @POST('/dashboard/client/listing/favorite')
  Future<BaseResponse> favoriteListing(@Body() FavoriteListingRequestBody data);
  @GET('/dashboard/client/listing/favorite')
  Future<BaseResponse<GenericPaginatedResponse<FavoriteListingModel>>>
      getFavoriteListings(@Query('page') int page);

  //<====================> Miscellaneous <====================>
  @MultiPart()
  @POST('/misc/upload/')
  Future<UploadProfilePicResponse> uploadProfilePic({
    @Part() required File image,
  });

  //<====================> Payment <====================>
  @POST('/payment/{bookingId}')
  Future<BaseResponse<CreatePaymentResponse>> createPayment({
    @Path('bookingId') required String bookingId,
  });
  @GET('/bookings/')
  Future<BaseResponse<PaymentCallbackResponse>> getPaymentStatus({
    @Query('payment_id') required String paymentId,
  });

  //<====================> Wallet <====================>
  @GET('/payment/wallet')
  Future<BaseResponse<WalletDetailsModel>> getWalletDetails();
  @POST('/payment/create-transaction-pin')
  Future<BaseResponse> createTransactionPin(@Body() UpdatePinModel data);
  @POST('/payment/withdraw-from-wallet')
  Future<BaseResponse> withdrawFromWallet(@Body() WithdrawFromWalletModel data);

  //<====================> Reviews <====================>
  /// Client reviews a completed booking.
  @POST('/bookings/{bookingId}/reviews')
  Future<BaseResponse<BookingReviewModel>> reviewBooking(
    @Path('bookingId') String bookingId,
    @Body() SubmitReviewRequestBody data,
  );

  @DELETE('/bookings/{bookingId}/reviews/{reviewId}')
  Future<dynamic> deleteBookingReview(
    @Path('bookingId') String bookingId,
    @Path('reviewId') String reviewId,
  );

  /// Reviews left on the signed-in partner's listings.
  @GET('/bookings/partner/booking-reviews')
  Future<BaseResponse<GenericPaginatedResponse<BookingReviewModel>>>
      getPartnerBookingReviews(@Query('page') int page);

  /// Client reviews the artisan who did the job.
  @POST('/bookings/{bookingId}/artisan-reviews')
  Future<BaseResponse<ArtisanReviewModel>> reviewArtisan(
    @Path('bookingId') String bookingId,
    @Body() SubmitReviewRequestBody data,
  );

  @GET('/bookings/artisan-reviews/{artisanId}')
  Future<BaseResponse<GenericPaginatedResponse<ArtisanReviewModel>>>
      getArtisanReviews(
    @Path('artisanId') String artisanId,
    @Query('page') int page,
  );

  @DELETE('/bookings/artisan-reviews/{reviewId}/delete')
  Future<dynamic> deleteArtisanReview(@Path('reviewId') String reviewId);

  @POST('/listings/market-place/item/review/{itemId}')
  Future<BaseResponse<dynamic>> reviewMarketplaceItem(
    @Path('itemId') String itemId,
    @Body() SubmitReviewRequestBody data,
  );

  /// Client confirms the service was delivered, releasing the booking.
  /// Takes no body.
  @POST('/bookings/service-confirmation/{bookingId}')
  Future<BaseResponse<dynamic>> confirmServiceCompletion(
    @Path('bookingId') String bookingId,
  );

  //<====================> Wallet & payouts <====================>
  /// Money moved out of the wallet to a bank account.
  @GET('/payment/transfers')
  Future<BaseResponse<GenericPaginatedResponse<TransferModel>>> getTransfers(
    @Query('page') int page,
  );

  @GET('/payment/transfer/{transferId}')
  Future<BaseResponse<TransferModel>> getTransfer(
    @Path('transferId') String transferId,
  );

  /// Bookings settled by a given transfer.
  @GET('/payment/transfer/{transferId}/bookings')
  Future<BaseResponse<GenericPaginatedResponse<dynamic>>> getTransferBookings(
    @Path('transferId') String transferId,
    @Query('page') int page,
  );

  /// Every credit and debit against the wallet.
  @GET('/payment/wallet-transactions')
  Future<BaseResponse<GenericPaginatedResponse<WalletTransactionModel>>>
      getWalletTransactions(@Query('page') int page);

  @GET('/payment/wallet-transaction/{transactionId}')
  Future<BaseResponse<WalletTransactionModel>> getWalletTransaction(
    @Path('transactionId') String transactionId,
  );

  /// Saved payout destinations.
  @GET('/payment/instruments')
  Future<BaseResponse<GenericPaginatedResponse<PaymentInstrumentModel>>>
      getPaymentInstruments(@Query('page') int page);

  //<====================> Contact Us <====================>
  @POST('/contact_us/')
  Future<BaseResponse<dynamic>> contactUs(
    @Body() Map<String, dynamic> data,
  );
}
