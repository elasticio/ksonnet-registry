// @apiVersion 0.0.1
// @name elastic.io.iron-bank
// @param name string name
// @optionalParam iron_bank_enabled string null is iron-bank service enabled

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local ironBankEnabled = import 'param://iron_bank_enabled';

local ironBank = if ironBankEnabled != 'true' then [] else platform.parts.ironBank();

ironBank
