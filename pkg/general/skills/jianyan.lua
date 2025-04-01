Fk:loadTranslationTable{
  ["jianyan"] = "荐言",
  [":jianyan"] = "出牌阶段限一次，你可以选择一种牌的类别或颜色，然后连续亮出牌堆顶的牌，直到亮出符合你声明的牌为止，你将此牌交给一名男性角色。",

  ["#jianyan"] = "荐言：选择一种牌的类别或颜色，将牌堆第一张符合条件的牌交给一名男性角色",
  ["#jianyan-give"] = "荐言：你可将 %arg 交给一名角色",

  ["$jianyan1"] = "开言纳谏，社稷之福。",
  ["$jianyan2"] = "如此如此，敌军自破！",
}

local skill = fk.CreateSkill{
  name = "jianyan",
}

skill:addEffect('active', {
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  prompt = "#jianyan",
  max_phase_use_time = 1,
  card_filter = Util.FalseFunc,
  interaction = function()
    return UI.ComboBox {choices = {"black", "red", "basic", "trick", "equip"} }
  end,
  on_use = function(self, room, effect)
    local pattern = self.interaction.data
    if not pattern then pattern = "red" end -- for AI
    local player = effect.from
    local card
    local cards = {}
    local _pattern
    if pattern == "black" then
      _pattern = ".|.|spade,club"
    elseif pattern == "red" then
      _pattern = ".|.|heart,diamond"
    else
      _pattern = ".|.|.|.|.|" .. pattern
    end
    if #room:getCardsFromPileByRule(_pattern, 1, "allPiles") == 0 then return false end
    while true do
      local id = room:getNCards(1)[1]
      room:moveCardTo(id, Card.Processing, nil, fk.ReasonJustMove, self.name, nil, true, player)
      room:delay(300)
      local c = Fk:getCardById(id)
      if c:getColorString() == pattern or c:getTypeString() == pattern then
        card = c
        break
      else
        table.insert(cards, id)
      end
    end
    local targets = table.filter(room.alive_players, function(p)
      return p:isMale()
    end)
    if #targets == 0 then
      table.insert(cards, card.id)
    else
      local target = room:askToChoosePlayers(player, { targets = targets, min_num = 1, max_num = 1, prompt = "#jianyan-give:::"..card:toLogString(), skill_name = skill.name, cancelable = false })[1]
      room:moveCardTo(card.id, Player.Hand, target, fk.ReasonGive, self.name, nil, true, player.id)
    end
    cards = table.filter(cards, function(id) return room:getCardArea(id) == Card.Processing end)
    if #cards > 0 then
      room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, skill.name, nil, true, player.id)
    end
  end,
})

return skill
