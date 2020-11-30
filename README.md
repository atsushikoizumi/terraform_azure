ResourceManager というブランチ名にしましたが、便宜上、Terraform を使います。<br>
resource groups に対して、Azure Policy を適用するまでの手順を記載します。

# 準備
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

4. terraform init<br>
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
    続いて、provider azurerm で AD認証情報を記述します。<br>
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

# Azure Policy

1. build in policy<br>
    今回は Azure Policy built-in policy definitions のみで行います。<br>
    https://docs.microsoft.com/ja-jp/azure/governance/policy/samples/built-in-policies

2. Policy のアタッチ先
    管理グループ、サブスクリプション、リソースグループが主なアタッチ先です。

# ARM（Azure Resource Manager）
ARM は Azure オリジナルの Terraform/CloudFormation に当たります。