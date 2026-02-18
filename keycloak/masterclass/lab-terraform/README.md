# Lab Terraform

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