-- SPDX-License-Identifier: AGPL-3.0-or-later
-- Keeps working notes in the Markdown only: drops GitHub alerts (`> [!NOTE]` …) and a section whose heading starts
-- with "Open points" (with everything up to the next heading of the same level and a rule right before it).

local alerts = { note = true, tip = true, important = true, warning = true, caution = true }

function Div(el)
  for _, class in ipairs(el.classes) do
    if alerts[class] then return {} end
  end
end

function Pandoc(doc)
  local blocks, skip = {}, nil
  for _, block in ipairs(doc.blocks) do
    if block.t == "Header" then
      if skip and block.level <= skip then skip = nil end
      if not skip and pandoc.utils.stringify(block):match("^Open points") then
        skip = block.level
        if #blocks > 0 and blocks[#blocks].t == "HorizontalRule" then table.remove(blocks) end
      end
    end
    if not skip then table.insert(blocks, block) end
  end
  doc.blocks = blocks
  return doc
end
