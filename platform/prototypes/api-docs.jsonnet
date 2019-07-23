// @apiVersion 0.0.1
// @name elastic.io.api-docs
// @param name string name
// @param api_docs_image string API docs image

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local apiDocsImage = import 'param://api_docs_image';

platform.parts.apiDocs(apiDocsImage)
