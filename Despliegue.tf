provider "azurerm" {
  version = "~>2.0"
  features {}
}

resource "azurerm_resource_group" "landing" {
  name     = "landing"
  location = "West US"
}


resource "azurerm_app_service_plan" "appserviceplan" {
  name                = "appserviceplan"
  location            = azurerm_resource_group.landing.location
  resource_group_name = azurerm_resource_group.landing.name

  sku {
    tier = "Basic"
    size = "B1"
  }
}


resource "azurerm_app_service" "applanding" {
  name                = "applanding"
  location            = azurerm_resource_group.landing.location
  resource_group_name = azurerm_resource_group.landing.name
  app_service_plan_id = azurerm_app_service_plan.appserviceplan.id

  site_config {
    php_version              = "7.3"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
    "WEBSITE_DNS_SERVER": "168.63.129.16",
    "WEBSITE_VNET_ROUTE_ALL": "1"
	"SPRING_DATASOURCE_URL"      = "jdbc:mysql://azurerm_mysql_server.bdatoslanding.fqdn:3306/azurerm_mysql_database.landingdb.name?useUnicode=true&characterEncoding=utf8&useSSL=false&useLegacyDatetimeCode=false&serverTimezone=UTC"
    "SPRING_DATASOURCE_USERNAME" = "azurerm_mysql_server.bdatoslanding.administrator_login@azurerm_mysql_server.bdatoslanding.name"
    "SPRING_DATASOURCE_PASSWORD" = "H@Sh1CoR3!"

  }

}

resource "azurerm_mysql_server" "bdatoslanding" {
  name                = "bdatoslanding"
  location            = azurerm_resource_group.landing.location
  resource_group_name = azurerm_resource_group.landing.name

  administrator_login          = "mysqladminun"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "B_Gen5_2"
  storage_mb = 5120
  version    = "5.7"

  ssl_enforcement_enabled           = false
}

resource "azurerm_mysql_database" "landingdb" {
  name                = "landingdb"
  resource_group_name = azurerm_resource_group.landing.name
  server_name         = azurerm_mysql_server.bdatoslanding.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}


resource "azurerm_mysql_firewall_rule" "mysql-rule" {
  name                = "mysql-rule"
  resource_group_name = azurerm_resource_group.landing.name
  server_name         = azurerm_mysql_server.bdatoslanding.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

