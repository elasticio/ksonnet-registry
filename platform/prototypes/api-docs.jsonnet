// @apiVersion 0.0.1
// @name elastic.io.api-docs
// @param name string name
// @param api_docs_image string API docs image
// @optionalParam platform_name string great-moraq platform name for helm

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local apiDocsImage = import 'param://api_docs_image';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

platform.parts.apiDocs(name, apiDocsImage)
