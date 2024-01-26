// Alice
const apigateway = '10.0.2.2:8080';
const imageStorageHost = '10.0.2.2:8080';
const imageStoragePath = '/a-image-storage';
const locationHostname = 'http://localhost:8080';

// Paths

// Customer service
const customerStampCardPath = '/customer/api/v1/card';
const customerStampCardListPath = '/customer/api/v1/card/list';
const customerNumIssuedCardsPath = '/customer/api/v1/card/numIssues';
const customerBlueprintPath = '/customer/api/v1/blueprint';
const customerBlueprintListPath = '/customer/api/v1/blueprint/list';
const customerStoreListPath = '/customer/api/v1/store/list';
const customerRedeemRequestPath = '/customer/api/v1/redeemRequest';
const customerRedeemRequestExistsPath = '/customer/api/v1/redeemRequest/exists';
const customerRedeemExistsPath = '/customer/api/v1/redeem/exists';
const customerRedeemRuleListPath = '/customer/api/v1/redeemRule/list';

final customerStampCardLocationPattern =
    RegExp('(?<=$locationHostname$customerStampCardPath/).+');
final customerRedeemRequestLocationPattern =
    RegExp('(?<=$locationHostname$customerRedeemRequestPath/).+');

// Owner service
const ownerBlueprintPath = '/owner/api/v1/blueprint';
const ownerBlueprintListPath = '/owner/api/v1/blueprint/list';
const ownerStorePath = '/owner/api/v1/store';
const ownerStoreListPath = '/owner/api/v1/store/list';
const ownerStampGrantPath = '/owner/api/v1/stampGrant';
const ownerStampCardPath = '/owner/api/v1/card';
const ownerRedeemPath = '/owner/api/v1/redeem'; // TODO: Implement front/backend
const ownerRedeemListPath =
    '/owner/api/v1/redeem/list'; // TODO: Implement front/backend
const ownerRedeemRuleListPath = '/owner/api/v1/redeemRule/list';
const ownerRedeemRequestListPath = '/owner/api/v1/redeemRequest/list';
const _ownerRedeemRequestApprovePath =
    '/owner/api/v1/redeemRequest/{id}/approve';
String ownerRedeemRequestApprovePath(String redeemRequestId) {
  return _ownerRedeemRequestApprovePath.replaceFirst('{id}', redeemRequestId);
}

final ownerBlueprintLocationPattern =
    RegExp('(?<=$locationHostname$ownerBlueprintPath/).+');
final ownerStoreLocationPattern =
    RegExp('(?<=$locationHostname$ownerStorePath/).+');
final ownerRedeemLocationPattern =
    RegExp('(?<=$locationHostname$ownerRedeemPath/).+');
final ownerStampGrantLocationPattern =
    RegExp('(?<=$locationHostname$ownerStampGrantPath/).+');
