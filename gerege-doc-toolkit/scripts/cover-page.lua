-- gerege-doc-toolkit/scripts/cover-page.lua
--
-- Pandoc Lua filter — Gerege Document Blue Template-д зориулсан
-- автоматжуулсан нүүр хуудас + Гарчиг хуудас үүсгэх.
--
-- Үндсэн зорилго:
--   1. Frontmatter (YAML metadata)-аас title, version, owner, ... унших
--   2. Нүүр хуудас барих:
--        - Top spacing (vertical centering эффект)
--        - Title (Word "Title" style — template-ийн өнгөтэй)
--        - Subtitle ("Гэрэгэ Системс ХХК")
--        - Document info (хувилбар, эзэн, огноо, ...)
--        - Footer line
--   3. Page break: cover → TOC хуудас
--   4. "Гарчиг" heading + Word-ийн auto-updating TOC field
--   5. Page break: TOC → үндсэн агуулга
--
-- Pandoc-ийн `--toc` flag хэрэглэхгүй — Lua filter өөрөө TOC field барина.

local utils = pandoc.utils

-- ─────────────────────────────────────────────────────────────────────────
-- Helper functions
-- ─────────────────────────────────────────────────────────────────────────

local function xml_escape(s)
  if s == nil then return "" end
  s = tostring(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function meta_str(v)
  if v == nil then return nil end
  return utils.stringify(v)
end

local function raw_ooxml(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function page_break()
  return raw_ooxml('<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

local function empty_para()
  return raw_ooxml('<w:p/>')
end

-- Word-ийн өгөгдсөн paragraph style ашиглан нэг мөр текст үүсгэх
local function styled_para(style, text)
  return raw_ooxml(table.concat({
    '<w:p><w:pPr><w:pStyle w:val="', style, '"/></w:pPr>',
    '<w:r><w:t xml:space="preserve">', xml_escape(text), '</w:t></w:r>',
    '</w:p>',
  }))
end

-- Auto-updating Table of Contents field. Word нээгдсэний дараа эсвэл
-- хэрэглэгч right-click → "Update Field" дарсны дараа гарчгийн агуулга
-- бөглөгдөнө.
local function toc_field(placeholder_text)
  local placeholder = placeholder_text or
    'Гарчиг бөглөхийн тулд: Word дотор гарчиг дээр right-click → Update Field.'
  return raw_ooxml(table.concat({
    '<w:p>',
      '<w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>',
      '<w:r><w:instrText xml:space="preserve">TOC \\o "1-3" \\h \\z \\u</w:instrText></w:r>',
      '<w:r><w:fldChar w:fldCharType="separate"/></w:r>',
      '<w:r><w:rPr><w:i/><w:color w:val="808080"/></w:rPr>',
      '<w:t xml:space="preserve">', xml_escape(placeholder), '</w:t></w:r>',
      '<w:r><w:fldChar w:fldCharType="end"/></w:r>',
    '</w:p>',
  }))
end

-- ─────────────────────────────────────────────────────────────────────────
-- Main filter
-- ─────────────────────────────────────────────────────────────────────────

function Pandoc(doc)
  local meta = doc.meta
  local title = meta_str(meta.title) or "Документ"
  local subtitle = meta_str(meta.subtitle) or "Гэрэгэ Системс ХХК"
  local toc_heading = meta_str(meta["toc-title"]) or "Гарчиг"

  local cover = {}

  -- ─── Cover page ────────────────────────────────────────────────────────

  -- Top vertical spacing (~1/3 of page from top)
  for i = 1, 6 do
    table.insert(cover, empty_para())
  end

  -- Title (Word "Title" style)
  table.insert(cover, styled_para("Title", title))

  -- Subtitle (Word "Subtitle" style)
  table.insert(cover, styled_para("Subtitle", subtitle))

  -- Spacing
  for i = 1, 3 do
    table.insert(cover, empty_para())
  end

  -- Document info fields. Frontmatter-ээс автоматаар цуглуулна.
  -- Шинэ field нэмэх бол энд мөр нэмнэ.
  local fields = {
    {"Хувилбар",                       meta_str(meta.version)},
    {"Төлөв",                          meta_str(meta.status)},
    {"Тэргүүлэх ач холбогдол",          meta_str(meta.priority)},
    {"Нууцлал",                        meta_str(meta.classification)},
    {"Эзэн",                           meta_str(meta.owner)},
    {"Хүчин төгөлдөр болсон огноо",    meta_str(meta.effective_date)},
    {"Сүүлд шинэчилсэн огноо",         meta_str(meta.last_reviewed)},
    {"Дараагийн review",               meta_str(meta.next_review)},
    {"OID",                            meta_str(meta.oid)},
    {"Public URL",                     meta_str(meta.public_url)},
  }

  for _, f in ipairs(fields) do
    if f[2] and f[2] ~= "" then
      table.insert(cover, pandoc.Para({
        pandoc.Strong({pandoc.Str(f[1])}),
        pandoc.Str(":  "),
        pandoc.Str(f[2]),
      }))
    end
  end

  -- Bottom spacing
  for i = 1, 4 do
    table.insert(cover, empty_para())
  end

  -- Cover footer (italic small line)
  local footer = meta_str(meta.cover_footer)
  if footer and footer ~= "" then
    table.insert(cover, pandoc.Para({
      pandoc.Emph({pandoc.Str(footer)})
    }))
  end

  -- ─── Page break: Cover → TOC ───────────────────────────────────────────
  table.insert(cover, page_break())

  -- ─── TOC page ──────────────────────────────────────────────────────────
  table.insert(cover, styled_para("Heading1", toc_heading))
  table.insert(cover, toc_field())

  -- ─── Page break: TOC → Body ────────────────────────────────────────────
  table.insert(cover, page_break())

  -- Үндсэн body-ийн өмнө prepend
  for i = #cover, 1, -1 do
    table.insert(doc.blocks, 1, cover[i])
  end

  -- Pandoc-ын автомат title рендерлэхгүй (давхар title гарахгүй)
  meta.title = nil

  return pandoc.Pandoc(doc.blocks, meta)
end
