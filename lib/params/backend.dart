// Alice
const apigateway = '10.0.2.2:8080';
const imageStorageHost = '10.0.2.2:8080';
const imageStoragePath = '/a-image-storage';

// Paths

// Customer service
const customerStampCardPath = '/customer/api/v1/card'; // Done
const customerStampCardListPath = '/customer/api/v1/card/list'; // Done
const customerNumIssuedCardsPath = '/customer/api/v1/card/numIssues'; // Done
const customerBlueprintPath = '/customer/api/v1/blueprint'; // Done
const customerBlueprintListPath = '/customer/api/v1/blueprint/list'; // Done
const customerStoreListPath = '/customer/api/v1/store/list'; // Done
const customerRedeemRequestPath = '/customer/api/v1/redeemRequest'; // Done
const customerRedeemRequestExistsPath =
    '/customer/api/v1/redeemRequest/exists'; // Done
const customerRedeemExistsPath = '/customer/api/v1/redeem/exists'; // Done
const customerRedeemRuleListPath = '/customer/api/v1/redeemRule/list'; // Done

// Owner service
const ownerBlueprintPath = '/owner/api/v1/blueprint'; // Done
const ownerBlueprintListPath = '/owner/api/v1/blueprint/list'; // Done
const ownerStorePath = '/owner/api/v1/store'; // Done
const ownerStoreListPath = '/owner/api/v1/store/list'; // Done
const ownerStampGrantPath = '/owner/api/v1/stampGrant'; // Done
const ownerStampCardPath = '/owner/api/v1/card'; // Done
const ownerRedeemPath = '/owner/api/v1/redeem/list';
const ownerRedeemRuleListPath = '/owner/api/v1/redeemRule/list'; // Done
const ownerRedeemRequestListPath = '/owner/api/v1/redeemRequest/list'; // Done

// Location
const backendHostname = 'http://localhost:8080';
// TODO: Split customer and owner
const stampCardLocationPrefix =
    '/customer/api/v1/card/'; // 'http://localhost:8080/customer/api/v1/stampCard/{uuid}'
final stampCardLocationPattern =
    RegExp('(?<=$backendHostname$stampCardLocationPrefix).+');
const stampGrantLocationPrefix =
    '/api/v1/stampGrant/'; // 'http://localhost:8080/customer/api/v1/stampGrant/{uuid}'
final stampGrantLocationPattern =
    RegExp('(?<=$backendHostname$stampGrantLocationPrefix).+');
const redeemRequestLocationPrefix =
    '/api/v1/redeemRequest/'; // '/api/v1/redeemRequest/{uuid}'
final redeemRequestLocationPattern =
    RegExp('^($redeemRequestLocationPrefix).+');
