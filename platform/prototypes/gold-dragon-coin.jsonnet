// @apiVersion 0.0.1
// @name elastic.io.gold-dragon-coin
// @param name string name
// @optionalParam gold_dragon_coin_replicas number 1 gold dragon coin replicas count
// @optionalParam platform_name string great-moraq platform name for helm

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local goldDragonCoinReplicas = import 'param://gold_dragon_coin_replicas';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

platform.parts.goldDragonCoin(name, goldDragonCoinReplicas)
