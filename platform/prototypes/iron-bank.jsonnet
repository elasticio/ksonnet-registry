// @apiVersion 0.0.1
// @name elastic.io.iron-bank
// @param name string name
// @optionalParam iron_bank_enabled string true is iron-bank service enabled
// @optionalParam platform_name string great-moraq platform name

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local ironBankEnabled = import 'param://iron_bank_enabled';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

local ironBank = if ironBankEnabled != 'true' then [] else platform.parts.ironBank(name);

ironBank
