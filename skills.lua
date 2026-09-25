-- Fenced-div helpers for the Typst resume templates (resume.typst,
-- fangpath.typst), so markdown stays free of raw Typst.
--
-- ::: skills
-- - Item one
-- :::
--   → single 3-column bulleted block
--
-- ::: skills
-- - **Category**: Item one, Item two
-- :::
--   → bold full-width category label, then a 3-column bulleted block per
--     category
--
-- ::: skills-table
-- - **Category**: Item one, Item two
-- :::
--   → the FAANGPath SKILLS layout instead: bold category label left, the
--     full comma-separated list as one line right, no bullets (needs
--     fangpath.typst's `skills-table` helper)
--
-- ::: {.job title="..." date="..." company="..." location="..."}
-- - bullet
-- :::
--   → a role entry: title/date on one line (right-aligned), optional
--     company/location on the next (right-aligned), then a bullet list.
--     `company`/`location` are optional (omit both for a role with no
--     separate employer line, e.g. when the employer is already an H2
--     heading). Needs fangpath.typst's `resume-subsection` helper.

-- pandoc's writer soft-wraps long output lines with a literal newline
-- (readability formatting, not semantic content), which would otherwise
-- break a bullet's continuation in the generated Typst markup.
local function render_inline(doc)
  return (pandoc.write(doc, "typst"):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Renders a plain string (e.g. a div attribute value) as Markdown inlines
-- through the Typst writer, so it picks up the same escaping as regular
-- body text.
local function render_attr(s)
  if not s or s == "" then return "" end
  local doc = pandoc.read(s, "markdown")
  local inlines = {}
  if doc.blocks[1] then
    for _, inline in ipairs(doc.blocks[1].content) do table.insert(inlines, inline) end
  end
  return render_inline(pandoc.Pandoc({pandoc.Plain(inlines)}))
end

-- Escapes a string for embedding inside a Typst "..." string-literal
-- argument, on top of whatever escaping render_attr/render_inline already
-- applied.
--
-- Pandoc's Typst writer emits en/em dashes as literal "--"/"---", relying
-- on Typst's own markup-mode smart-dash conversion to turn them back into
-- – / — at compile time. That conversion only fires for text typed
-- directly as markup content, not for quoted string-literal arguments
-- (which is how every value here gets embedded), so it has to be finished
-- by hand here.
local function escape_str_literal(s)
  s = s:gsub("%-%-%-", "—"):gsub("%-%-", "–")
  return (s:gsub("\\", "\\\\"):gsub('"', '\\"'))
end

local function parse_items(div)
  local items = {}
  local has_categories = false

  for _, block in ipairs(div.content) do
    if block.t == "BulletList" then
      for _, item in ipairs(block.content) do
        local inlines = item[1].content
        local category = nil
        local rest_inlines = {}

        if #inlines > 0 and inlines[1].t == "Strong" then
          has_categories = true
          category = render_inline(pandoc.Pandoc({pandoc.Plain(inlines[1].content)})):gsub(":$", "")
          local i = 2
          if inlines[i] and inlines[i].t == "Str" and inlines[i].text == ":" then i = i + 1 end
          if inlines[i] and inlines[i].t == "Space" then i = i + 1 end
          for j = i, #inlines do table.insert(rest_inlines, inlines[j]) end
        else
          rest_inlines = inlines
        end

        local text = render_inline(pandoc.Pandoc({pandoc.Plain(rest_inlines)}))
        table.insert(items, {category = category, text = text})
      end
    end
  end

  return items, has_categories
end

-- Splits on commas, but not commas nested inside parentheses, so
-- "Microsoft Sentinel (Log Analytics, KQL)" stays one skill.
local function split_skills(text)
  local skills = {}
  local depth = 0
  local current = {}

  local function flush()
    local skill = table.concat(current):match("^%s*(.-)%s*$")
    if skill ~= "" then table.insert(skills, skill) end
    current = {}
  end

  for ch in text:gmatch(".") do
    if ch == "(" then
      depth = depth + 1
      table.insert(current, ch)
    elseif ch == ")" then
      depth = math.max(0, depth - 1)
      table.insert(current, ch)
    elseif ch == "," and depth == 0 then
      flush()
    else
      table.insert(current, ch)
    end
  end
  flush()

  return skills
end

local function typst_block(items, has_categories)
  local function columns(list_items)
    return table.concat({
      "#columns(3, gutter: 1em)[",
      "  #set list(spacing: 0.35em, indent: 0pt, body-indent: 0.7em)",
      table.concat(list_items, "\n"),
      "]",
    }, "\n")
  end

  if not has_categories then
    local list_items = {}
    for _, item in ipairs(items) do
      table.insert(list_items, "- " .. item.text)
    end
    return columns(list_items)
  end

  local blocks = {}
  for i, item in ipairs(items) do
    local list_items = {}
    for _, skill in ipairs(split_skills(item.text)) do
      table.insert(list_items, "- " .. skill)
    end

    local sep = (i > 1) and "#v(4pt)\n" or ""
    table.insert(blocks, sep .. "*" .. (item.category or "") .. "*\n" .. columns(list_items))
  end

  return table.concat(blocks, "\n")
end

local function job_typst(div)
  local a = div.attributes
  local title = escape_str_literal(render_attr(a.title))
  local date = escape_str_literal(render_attr(a.date))
  local body = pandoc.write(pandoc.Pandoc(div.content), "typst"):gsub("\n$", "")

  local args = string.format('"%s", "%s"', title, date)
  if a.company then
    local company = escape_str_literal(render_attr(a.company))
    local location = escape_str_literal(render_attr(a.location))
    args = args .. string.format(', subtitle: "%s", location: "%s"', company, location)
  end

  return "#resume-subsection(" .. args .. ")[\n" .. body .. "\n]"
end

local function skills_table_typst(items)
  local rows = {}
  for _, item in ipairs(items) do
    table.insert(rows, string.format(
      '  ("%s", "%s"),',
      escape_str_literal(item.category or ""),
      escape_str_literal(item.text)
    ))
  end
  return "#skills-table((\n" .. table.concat(rows, "\n") .. "\n))"
end

function Div(div)
  if FORMAT ~= "typst" then return nil end

  if div.classes:includes("skills") then
    local items, has_categories = parse_items(div)
    return pandoc.RawBlock("typst", typst_block(items, has_categories))
  end

  if div.classes:includes("skills-table") then
    local items = parse_items(div)
    return pandoc.RawBlock("typst", skills_table_typst(items))
  end

  if div.classes:includes("job") then
    return pandoc.RawBlock("typst", job_typst(div))
  end

  return nil
end
