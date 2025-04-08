# Lab 2.5

## DE

1) Startet das Lab via `docker compose up`.
2) Legt (im Master Realm) einen neuen Client mit dem Namen `labclient` an. Die Einstellungen können auf Default bleiben. Achtet darauf, den Direct Access Grant zu aktivieren.
3) Legt einen neuen User `labuser` an.
4) Legt unter Realm Settings -> Tokens -> Access Token Lifespan die Zeit auf 15min fest.
5) Ruft für den Admin die Token ab (s. Code 1) und prüft dessen ID Token unter jwt.io.
6) Tauscht den Access Tokens des Admin gegen die Token des angelegen `labuser` ein (s. Code 2).
7) Prüft, ob der erhaltene ID-Token zum `labuser` gehört.

## EN

1) Starts the lab via `docker compose up`.
2) Create (in master realm) a new client with the name `labclient`. The settings can remain at default. Make sure to activate the Direct Access Grant.
3) Create a new user `labuser`.
4) Set the time to 15min under Realm Settings -> Tokens -> Access Token Lifespan.
5) Retrieve the tokens for the admin (see code 1) and check his ID token under jwt.io.
6) Exchange the admin's access token for the tokens of the created `labuser` (see code 2).
7) Check whether the ID token received belongs to the `labuser`.
 
## Code 1

```
curl \
-d "client_id=labclient" \
-d "username=admin" \
-d "password=admin" \
-d "grant_type=password" \
-d "scope=openid" \
"http://localhost:8080/realms/master/protocol/openid-connect/token"
```


## Code 2

```
curl \
-d "client_id=labclient" \
-d "requested_subject=labuser" \
-d "subject_token=<ADMIN-ACCESS-TOKEN>" \
-d "grant_type=urn:ietf:params:oauth:grant-type:token-exchange" \
-d "scope=openid" \
"http://localhost:8080/realms/master/protocol/openid-connect/token"
```


