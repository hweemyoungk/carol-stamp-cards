// Alice
const apigateway = '10.0.2.2:8080';
// (localk8s) In your host machine: ncat -k -p 8080 -l -c "ncat 192.168.49.2 30001"
const imageStorageHost = '10.0.2.2:8080';
const imageStoragePath = '/a-image-storage';
const locationHostname = 'http://localhost:8080';

// Paths

// App service
const appServiceHost = '10.0.2.2:8082'; // if profile is 'local'
const appPublicMinRequirementsPath =
    '/app/api/v1/public/minRequirements'; // GET
const appPublicCustomerMembershipMapPath =
    '/app/api/v1/public/customer/membership/map'; // GET
const appPublicOwnerMembershipMapPath =
    '/app/api/v1/public/owner/membership/map'; // GET

// Customer service
const customerStampCardPath = '/customer/api/v1/card'; // POST,GET,PUT,DELETE
const customerStampCardListPath = '/customer/api/v1/card/list'; // GET
const customerNumCustomerIssuedCardsPath =
    '/customer/api/v1/card/numIssues'; // GET
const customerBlueprintPath = '/customer/api/v1/blueprint'; // GET
const customerBlueprintListPath = '/customer/api/v1/blueprint/list'; // GET
const customerNumTotalIssuedCardsPath =
    '/customer/api/v1/blueprint/numIssues'; // GET
const customerStorePath = '/customer/api/v1/store'; // GET
const customerStoreListPath = '/customer/api/v1/store/list'; // GET
const customerRedeemRequestPath =
    '/customer/api/v1/redeemRequest'; // POST,DELETE
const _customerRedeemRequestExistsPath =
    '/customer/api/v1/redeemRequest/{id}/exists'; // GET
String customerRedeemRequestExistsPath(String redeemRequestId) {
  return _customerRedeemRequestExistsPath.replaceFirst(
    '{id}',
    redeemRequestId.toString(),
  );
}

const customerRedeemListExistsPath =
    '/customer/api/v1/redeem/list/exists'; // GET
const customerRedeemRuleListPath = '/customer/api/v1/redeemRule/list'; // GET

final customerStampCardLocationPattern =
    RegExp('(?<=$locationHostname$customerStampCardPath/).+');
final customerRedeemRequestLocationPattern =
    RegExp('(?<=$locationHostname$customerRedeemRequestPath/).+');

// Owner service
const ownerBlueprintPath = '/owner/api/v1/blueprint'; // POST,GET,PUT
const ownerBlueprintListPath = '/owner/api/v1/blueprint/list'; // GET
const ownerStorePath = '/owner/api/v1/store'; // POST,GET,PUT,DELETE
const ownerStoreListPath = '/owner/api/v1/store/list'; // GET
const ownerStampGrantPath = '/owner/api/v1/stampGrant'; // POST
const ownerStampCardPath = '/owner/api/v1/card'; // GET
// const ownerRedeemPath = '/owner/api/v1/redeem'; // TODO: Implement front/backend
// const ownerRedeemListPath = '/owner/api/v1/redeem/list'; // TODO: Implement front/backend
const ownerRedeemRuleListPath = '/owner/api/v1/redeemRule/list'; // GET
const ownerRedeemRequestListPath = '/owner/api/v1/redeemRequest/list'; // GET
const _ownerRedeemRequestApprovePath =
    '/owner/api/v1/redeemRequest/{id}/approve'; // POST
String ownerRedeemRequestApprovePath(String redeemRequestId) {
  return _ownerRedeemRequestApprovePath.replaceFirst(
    '{id}',
    redeemRequestId.toString(),
  );
}

final ownerBlueprintLocationPattern =
    RegExp('(?<=$locationHostname$ownerBlueprintPath/).+');
final ownerStoreLocationPattern =
    RegExp('(?<=$locationHostname$ownerStorePath/).+');
// final ownerRedeemLocationPattern = RegExp('(?<=$locationHostname$ownerRedeemPath/).+');
final ownerStampGrantLocationPattern =
    RegExp('(?<=$locationHostname$ownerStampGrantPath/).+');
