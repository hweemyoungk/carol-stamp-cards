const keycloakHostname = '10.0.2.2:8180';
// (localk8s) In your host machine: ncat -k -p 8180 -l -c "ncat 192.168.49.2 30000"
const realmName = 'alicia-auth-test-1';
const clientId = 'pkce-client-id';
const redirectUri = 'cards.carol.scheme://carol.cards/auth/callback';

const accountPath = '/realms/$realmName/account';

const expMarginSeconds = 30;
