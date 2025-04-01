local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["ex__rende"] = "仁德",
  [":ex__rende"] = "出牌阶段每名角色限一次，你可以将任意张手牌交给一名其他角色，每阶段你以此法给出第二张牌时，你可以视为使用一张基本牌。",
  ["#ex__rende"] = "仁德：将任意张手牌交给一名角色，若此阶段交出达到两张，你可以视为使用一张基本牌",

  ["#ex__rende-ask"] = "仁德：你可视为使用一张基本牌",

  ["$ex__rende1"] = "同心同德，救困扶危！",
  ["$ex__rende2"] = "施仁布泽，乃我大汉立国之本！",
}

local skill = fk.CreateSkill{
  name = "ex__rende",
}

skill:addEffect('active', {
  anim_type = "support",
  min_card_num = 1,
  target_num = 1,
  prompt = "#ex__rende",
  card_filter = function(self, to_select, selected)
    return table.contains(Self:getCardIds("h"), to_select)
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and to_select:getMark("_ex__rende-phase") == 0
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    local player = room:getPlayerById(effect.from)
    local cards = effect.cards
    local marks = player:getMark("_rende_cards-phase")
    room:moveCardTo(cards, Player.Hand, target, fk.ReasonGive, self.name, nil, false)
    room:addPlayerMark(player, "_rende_cards-phase", #cards)
    room:setPlayerMark(target, "_ex__rende-phase", 1)
    if marks < 2 and marks + #cards >= 2 then
      cards = U.getUniversalCards(room, "b", false)
      local use = room:askToUseRealCard(player, { pattern = cards, expand_pile = cards, skill_name = skill.name, prompt = "#ex__rende-ask",
        extra_data = {bypass_times = false, extraUse = false}, cancelable = true, skip = true })
      if use then
        use = {
          card = Fk:cloneCard(use.card.name),
          from = player.id,
          tos = use.tos,
        }
        use.card.skillName = skill.name
        room:useCard(use)
      end
    end
  end,
})

return skill
