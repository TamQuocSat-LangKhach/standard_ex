Fk:loadTranslationTable{
  ["ex__wusheng"] = "武圣",
  [":ex__wusheng"] = "①你可以将一张红色牌当做【杀】使用或打出。②你使用<font color='red'>♦</font>【杀】无距离限制",
  ["#ex__wusheng"] = "武圣：你可以将红色牌当【杀】使用或打出",

  ["$ex__wusheng1"] = "刀锋所向，战无不克！",
  ["$ex__wusheng2"] = "逆贼，哪里走！",
}

local ex_skill = fk.CreateSkill{
  name = "ex__wusheng",
}

ex_skill:addEffect('viewas', {
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#ex__wusheng",
  handly_pile = true,
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    return Fk:getCardById(to_select).color == Card.Red
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return nil end
    local c = Fk:cloneCard("slash")
    c.skillName = ex_skill.name
    c:addSubcard(cards[1])
    return c
  end,
}):addEffect('targetmod', {
  anim_type = "offensive",
  bypass_distances = function (self, player, skill, card)
    return player:hasSkill(ex_skill.name) and card and card.trueName == "slash_skill" and card.suit == Card.Diamond
  end
})

return ex_skill
