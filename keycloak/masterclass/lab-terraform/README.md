# Lab Terraform

## DE

Ziel: Wir nehmen via Terraform eine Keycloak Konfiguration vor und spielen diese Konfiguration in Keycloak ein.

1) Starten Sie die Umgebung mit `docker compose up`.
2) Öffnen Sie die Entwicklungsumgebung im Browser unter `http://localhost:3000`.
3) Öffnen Sie in der Entwicklungsumgebung den Ordner `workspace`.
4) Öffnen Sie die Datei `config.tf` und schauen Sie sich den Inhalt an.
5) Geben Sie auf der VSCode Console im Ordner workspace nacheinander die Befehle `terraform init` und `terraform apply` ein. Letzteren Bestätigen Sie noch mit `yes`.
6) Prüfen Sie in Keycloak unter `http://localhost:8080` ob die Änderungen umgesetzt wurden.
7) Ergänzen Sie die `config.tf` so, das auch ein confidential Client im Realm angelegt wird.
   - Schauen Sie dazu in die Dokumentation: https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/openid_client
   - Wenn Sie nicht alleine weiterkommen, schauen Sie in die `solution.tf`.
8) Führend Sie danach erneut `terraform apply` aus um prüfen Sie, ob die Änderungen umgesetzt wurden.

---

## EN

Goal: We will configure Keycloak using Terraform and apply this configuration to Keycloak.

1) Start the environment with `docker compose up`.
2) Open the development environment in your browser at `http://localhost:3000`.
3) Open the `workspace` folder in the development environment.
4) Open the `config.tf` file and examine its contents.
5) In the VSCode console, navigate to the workspace folder and execute the commands `terraform init` and `terraform apply` in sequence. Confirm the latter with `yes`.
6) Check in Keycloak at `http://localhost:8080` whether the changes have been applied.
7) Extend the `config.tf` so that a confidential client is also created in the realm.
   - Refer to the documentation: https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/openid_client
   - If you get stuck, check the `solution.tf` file.
8) Then run `terraform apply` again and verify that the changes have been applied.
