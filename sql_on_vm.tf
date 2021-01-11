# Create SQLServer on VirtualMachine
resource "azurerm_mssql_virtual_machine" "sqlserver02" {
  virtual_machine_id = azurerm_windows_virtual_machine.vm02.id
  sql_license_type   = "PAYG"
  sql_connectivity_port = 1433
  sql_connectivity_type = "PRIVATE"
  sql_connectivity_update_username = "koizumi"
  sql_connectivity_update_password = "P@$$w0rd1234!"

  storage_configuration {
    disk_type = "NEW"
    storage_workload_type = "GENERAL"
    temp_db_settings {
      default_file_path = "E:"
      luns = ["2"]
    }
    log_settings {
      default_file_path = "F:"
      luns = ["3"]
    }
    data_settings {
      default_file_path = "G:"
      luns = ["4"]
    }
  }

  auto_patching {
    day_of_week = "Sunday"
    maintenance_window_starting_hour = 2
    maintenance_window_duration_in_minutes = 60
  }
}