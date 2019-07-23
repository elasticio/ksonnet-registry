// @apiVersion 0.0.1
// @name elastic.io.gold-dragon-coin
// @param name string name
// @optionalParam gold_dragon_coin_replicas number 1 gold dragon coin replicas count

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local goldDragonCoinReplicas = import 'param://gold_dragon_coin_replicas';

platform.parts.goldDragonCoin(goldDragonCoinReplicas)
