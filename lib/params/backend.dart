// Alicia
const apigateway = '10.0.2.2:8080';

// Paths

// Customer service
const customerStampCardListPath = '/customer/api/v1/stampCard/list';
const customerBlueprintListPath = '/customer/api/v1/blueprint/list';
const customerBlueprintPath = '/customer/api/v1/blueprint';
const customerStoreListPath = '/customer/api/v1/store/list';
const customerNumIssuedCardsPath = '/customer/api/v1/stampCard/numIssues';
const customerStampCardPath = '/customer/api/v1/stampCard';
const customerRedeemRequestPath = '/customer/api/v1/redeemRequest';
const customerRedeemRequestExistsPath = '/customer/api/v1/redeemRequest/exist';
const customerRedeemExistsPath = '/customer/api/v1/redeem/exist';
const customerRedeemRuleListPath = '/owner/api/v1/redeemRule';

// Owner service
const ownerBlueprintListPath = '/owner/api/v1/blueprint/list';
const ownerBlueprintPath = '/owner/api/v1/blueprint';
const ownerRedeemRuleListPath = '/owner/api/v1/redeemRule/list';
const ownerRedeemRulePath = '/owner/api/v1/redeemRule';
const ownerStoreListPath = '/owner/api/v1/store/list';
const ownerStorePath = '/owner/api/v1/store';
const ownerStampGrantPath = '/owner/api/v1/stampGrant';
const ownerStampCardPath = '/owner/api/v1/stampCard';

// Content-Location
const stampCardLocationPrefix =
    '/api/v1/stampCard/'; // '/api/v1/stampCard/{uuid}'
final stampCardLocationPattern = RegExp('^($stampCardLocationPrefix).+');
const stampGrantLocationPrefix =
    '/api/v1/stampGrant/'; // '/api/v1/stampGrant/{uuid}'
final stampGrantLocationPattern = RegExp('^($stampCardLocationPrefix).+');
const redeemRequestLocationPrefix =
    '/api/v1/redeemRequest/'; // '/api/v1/redeemRequest/{uuid}'
final redeemRequestLocationPattern =
    RegExp('^($redeemRequestLocationPrefix).+');
