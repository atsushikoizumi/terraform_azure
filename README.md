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
    デフォルトで、Contributor ロールが割り当てられます。<br>
    Azure Policy のアタッチには User Access Administrator の権限も必要ですので、追加で割り当てます。
    ```
    [Subscription level]
    $ az account set --subscription="SUBSCRIPTION_ID"
    $ az ad sp create-for-rbac --name="koizumi-terraform" --scopes="/subscriptions/SUBSCRIPTION_ID"
        {
        "appId": "00000000-0000-0000-0000-000000000000",
        "displayName": "koizumi-terraform",
        "name": "http://koizumi-terraform",
        "password": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
        "tenant": "00000000-0000-0000-0000-000000000000"
        }
    $ az role assignment create `
      --assignee="00000000-0000-0000-0000-000000000000" `
      --role="User Access Administrator" `
      --scope="/subscriptions/00000000-0000-0000-0000-000000000000"
        {
        "canDelegate": null,
        "condition": null,
        "conditionVersion": null,
        "description": null,
        "id": "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleAssignments/00000000-0000-0000-0000-000000000000",
        "name": "00000000-0000-0000-0000-000000000000",
        "principalId": "00000000-0000-0000-0000-000000000000",
        "principalName": "http://terraform-principal",
        "principalType": "ServicePrincipal",
        "roleDefinitionId": "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/00000000-0000-0000-0000-000000000000",
        "roleDefinitionName": "User Access Administrator",
        "scope": "/subscriptions/00000000-0000-0000-0000-000000000000",
        "type": "Microsoft.Authorization/roleAssignments"
        }
    ```

4. backend 設定<br>
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

5. provider 設定<br>
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

2. Policy のアタッチ [azurerm_policy_assignment]
    管理グループ、サブスクリプション、リソースグループが主なアタッチ先です。<br>
    tf 記述方法は以下をさんほうください。<br>
    https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_assignment

# Terraform apply

以下の手順で実行します。<br>
    ```
    $ terraform init
    $ terraform plan
    $ terraform apply `
      -target azurerm_resource_group.test01 `
      -target azurerm_policy_assignment.Allowed_locations `
      -target azurerm_policy_assignment.inherit_tag_from_rg
    $ terraform apply
    ```

そのまま Tearrform apply してしまうと、Azure policy のアタッチに1分程度の時間が掛かってしまい、先に Virtual Network が作成されてしまいます。<br>
それでは、Resource group に設定した Azure Policy がリソースに適用されません。<br>
以上です。