Fk:loadTranslationTable{
  ["ex__longdan"] = "龙胆",
  [":ex__longdan"] = "你可以将一张【杀】当【闪】、【闪】当【杀】、【酒】当【桃】、【桃】当【酒】使用或打出。",

  ["#ex__longdan"] = "龙胆：你可以将一张【杀】当【闪】、【闪】当【杀】、【酒】当【桃】、【桃】当【酒】使用或打出",

  ["$ex__longdan1"] = "龙威虎胆，斩敌破阵！",
  ["$ex__longdan2"] = "进退自如，游刃有余！",
}

local skill = fk.CreateSkill{
  name = "ex__longdan",
}

skill:addEffect('viewas', {
  pattern = "slash,jink,peach,analeptic",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected ~= 0 then return false end
    local _c = Fk:getCardById(to_select)
    local c
    if _c.trueName == "slash" then
      c = Fk:cloneCard("jink")
    elseif _c.name == "jink" then
      c = Fk:cloneCard("slash")
    elseif _c.name == "peach" then
      c = Fk:cloneCard("analeptic")
    elseif _c.name == "analeptic" then
      c = Fk:cloneCard("peach")
    else
      return false
    end
    return (Fk.currentResponsePattern == nil and c.skill:canUse(Self, c)) or
      (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(c))
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local _c = Fk:getCardById(cards[1])
    local c
    if _c.trueName == "slash" then
      c = Fk:cloneCard("jink")
    elseif _c.name == "jink" then
      c = Fk:cloneCard("slash")
    elseif _c.name == "peach" then
      c = Fk:cloneCard("analeptic")
    elseif _c.name == "analeptic" then
      c = Fk:cloneCard("peach")
    end
    c.skillName = skill.name
    c:addSubcard(cards[1])
    return c
  end,
})

return skill
