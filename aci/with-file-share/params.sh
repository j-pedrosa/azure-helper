#Global
NAME="repo1"
RESOURCE_GROUP="aci-with-fileshare-$NAME-rg"
REGION="westeurope"


#ACI
ACI_NAME="aci-with-fileshare-$NAME"
ACR_SKU="Premium" # Allowed values: {Basic, Classic, Premium, Standard}

#File Share
ACI_PERS_STORAGE_ACCOUNT_NAME=mystorageaccount$NAME
ACI_PERS_SHARE_NAME=acishare$NAME