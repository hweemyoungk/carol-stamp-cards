import 'package:carol/models/user.dart';
import 'package:flutter/material.dart';
import 'package:pkce/pkce.dart';

class Params {
  static IconData stampIcon = Icons.star;
}

const apigateway = 'localhost:8080';
const keycloakHostname = '10.0.2.2:8180';
const redisHostname = '10.0.2.2:8180';
const realmName = 'alicia-auth-test-1';
const clientId = 'pkce-client-id';
const aliciaAuthHostname = '10.0.2.2:8080';
const redirectUri = 'cards.carol.afterme://carol-host/callback';

final tokenEndpoint = Uri.http(
  keycloakHostname,
  '/realms/$realmName/protocol/openid-connect/token',
);

String? originalState;
PkcePair? originalPkcePair;
late final User currentUser;
