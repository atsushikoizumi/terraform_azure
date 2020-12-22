Terraform を使います。<br>
resource groups に対して、Subnet, SecurityGroup を適用するまでの手順を記載します。

# 構築手順
以下の手順で実施します。

1. az cli の install<br>
    以下の URL からダウンロード & インストールします。<br>
    https://docs.microsoft.com/ja-jp/cli/azure/install-azure-cli

2. az login<br>
    Azure にログイン（AD認証）する必要があります。 

3. App registration を作成<br>
    Terraform で Azure を操作するための AD認証する必要があります。<br>
    いくつか手段がありますが、App registration と RBAC（Role Base Access Control）を利用する方法を取ります。<br>
    今回は、Contributor を割り当てます。
    ```
    [Subscription level]
    $ az account set --subscription="SUBSCRIPTION_ID"
    $ az ad sp create-for-rbac --name="koizumi-terraform" --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"
        {
        "appId": "00000000-0000-0000-0000-000000000000",
        "displayName": "koizumi-terraform",
        "name": "http://koizumi-terraform",
        "password": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
        "tenant": "00000000-0000-0000-0000-000000000000"
        }
    ```

4. backend を定義<br>
    事前に StorageAccount を作成しておきます。<br>
    backend を StorageAccount に設定します。
    ```
    backend "azurerm" {
      resource_group_name  = "atsushi.koizumi.data"
      storage_account_name = "terraform0tfstate"
      container_name       = "tfstate"
      key                  = "test01.tfstate"
    }
    ```
5. provider を定義<br>
    provider azurerm で AD認証情報を記述します。<br>
    下記の例では変数で参照する形にしています。
    ```
    provider "azurerm" {
    version = "=2.4.0"
    subscription_id = var.subscription_id
    client_id       = var.client_id
    client_secret   = var.client_secret
    tenant_id       = var.tenant_id
    features {}
    }
    ```

5. Terraform apply
    tf ファイルの内容をデプロイします。
    ```
    $ terraform init
    $ terraform apply
    ```

以上です。