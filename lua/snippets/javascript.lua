local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node

return {
  s("log", { t("console.log("), i(1), t(");") }),
}
