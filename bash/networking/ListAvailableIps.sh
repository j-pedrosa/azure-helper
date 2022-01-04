#!/usr/bin/bash

vnet_rg=$1
vnet_name=$2
subnet_name=$3
netmask=$4

max_ip=$((2 ** (32-$netmask)-5))

used_ip=`az network vnet subnet show -g $vnet_rg -n $subnet_name --vnet-name $vnet_name -o json | jq  ".ipConfigurations[].id" | wc -l`

available_ip=$(($max_ip - $used_ip))

echo "There are $available_ip IPs available"
