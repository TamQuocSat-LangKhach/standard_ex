Fk:loadTranslationTable{
  ["ex__guose"] = "国色",
  [":ex__guose"] = "出牌阶段限一次，你可以选择一项：1.将一张<font color='red'>♦</font>牌当【乐不思蜀】使用；"..
  "2.弃置一张<font color='red'>♦</font>牌并弃置场上的一张【乐不思蜀】。选择完成后，你摸一张牌。",

  ["#ex__guose_use"] = "国色：将一张<font color='red'>♦</font>牌当【乐不思蜀】使用，然后你摸一张牌",
  ["#ex__guose_throw"] = "国色：弃置<font color='red'>♦</font>牌并弃置场上一张【乐不思蜀】，然后你摸一张牌",
  ["ex__guose_use"] = "使用乐不思蜀",
  ["ex__guose_throw"] = "弃置乐不思蜀",

  ["$ex__guose1"] = "旅途劳顿，请下马休整吧~",
  ["$ex__guose2"] = "还没到休息的时候！",
}

local skill = fk.CreateSkill{
  name = "ex__guose",
}

skill:addEffect('active', {
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  prompt = function (self)
    return "#"..self.interaction.data
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  interaction = function()
    return UI.ComboBox {choices = {"ex__guose_use" , "ex__guose_throw"}}
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 or not self.interaction.data or Fk:getCardById(to_select).suit ~= Card.Diamond then return false end
    if self.interaction.data == "ex__guose_use" then
      local card = Fk:cloneCard("indulgence")
      card:addSubcard(to_select)
      return player:canUse(card) and not player:prohibitUse(card)
    else
      return not player:prohibitDiscard(Fk:getCardById(to_select))
    end
  end,
  target_filter = function(self, player, to_select, selected, cards)
    if #cards ~= 1 or #selected > 0 or not self.interaction.data then return false end
    local target = to_select
    if self.interaction.data == "ex__guose_use" then
      local card = Fk:cloneCard("indulgence")
      card:addSubcard(cards[1])
      return to_select ~= player.id and not player:isProhibited(target, card)
    else
      return target:hasDelayedTrick("indulgence")
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    if self.interaction.data == "ex__guose_use" then
      room:useVirtualCard("indulgence", effect.cards, player, target, skill.name)
    else
      room:throwCard(effect.cards, skill.name, player, player)
      for _, id in ipairs(target.player_cards[Player.Judge]) do
        local card = target:getVirualEquip(id)
        if not card then card = Fk:getCardById(id) end
        if card.name == "indulgence" then
          room:throwCard({id}, self.name, target, player)
        end
      end
    end
    if not player.dead then
      player:drawCards(1, skill.name)
    end
  end,
})

return skill
