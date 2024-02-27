import 'package:carol/params/backend.dart';

// (localk8s) In your host machine: ncat -k -p 8180 -l -c "ncat 192.168.49.2 30000"
// const keycloakHostname = '10.0.2.2:8180';
// const realmName = 'alicia-auth-test-1';
// const accountPath = '/realms/$realmName/account';
// const authPath = '/realms/$realmName/protocol/openid-connect/auth';
// const tokenPath = '/realms/$realmName/protocol/openid-connect/token';

// (dev)
const keycloakHostname = appGateway;
const realmName = 'athena';
const authPath = '/auth/realms/$realmName/protocol/openid-connect/auth';
const accountPath = '/auth/realms/$realmName/account';
const tokenPath = '/auth/realms/$realmName/protocol/openid-connect/token';

const clientId = 'pkce-client-id';
const redirectUri = 'cards.carol.scheme://carol.cards/auth/callback';

const expMarginSeconds = 30;
