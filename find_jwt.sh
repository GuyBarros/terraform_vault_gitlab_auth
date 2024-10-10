#!/bin/bash

# Vault address and token
VAULT_ADDR="https://do-not-delete-ever-v2-public-vault-cf6a1d76.5773df81.z1.hashicorp.cloud:8200"
VAULT_TOKEN=""


# List all namespaces
namespaces=$(vault namespace list  -format=json | jq -r '.[]'  | sed 's/\///g')

namespaces=admin
# Loop through namespaces
for namespace in $namespaces; do
    echo "Namespace: $namespace"

   
    # List all OIDC/JWT auth methods
    auth_methods=$(vault auth  list -namespace=$namespace | grep "oidc" | awk '{print $1}' | sed 's/\///g')

    # Loop through auth methods
    for auth_method in $auth_methods; do
        echo "Auth Method: $auth_method"

        # Get the roles for the auth method
        roles=$(vault list -format=json auth/$auth_method/role  | jq -r '.[]')

        # Loop through roles
        for role in $roles; do
            echo "  Role: $role"
            
            # Get and print the value of "bound_issuer"

           #  bound_claims=$(vault read -field=bound_claims -format=json  auth/$auth_method/role/$role )
            existing_bound_claims=$(vault read -format=json auth/$auth_method/role/$role | jq -r '.data.bound_claims')
            updated_bound_claims=$(echo "$existing_bound_claims" | jq '.iss = ["coolbeans.com","https://coolbeans.com"]')
            echo $existing_bound_claims
            echo $updated_bound_claims
        done
    done
done
