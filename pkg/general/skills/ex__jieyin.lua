Fk:loadTranslationTable{
  ["ex__jieyin"] = "结姻",
  [":ex__jieyin"] = "出牌阶段限一次，你可以弃置一张手牌并选择一名其他男性角色，或者将一张装备牌置入一名其他男性角色的装备区，"..
  "然后你与其体力值较少的角色回复1点体力，较多的角色摸一张牌。",
  ["#ex__jieyin"] = "结姻：弃一张手牌或将一张装备置入一名角色装备区，然后你与其体力值较少的角色回复1点体力，较多的角色摸一张牌",
  ["ex__jieyin_discard"] = "弃置手牌",
  ["ex__jieyin_put"] = "置入装备",

  ["$ex__jieyin1"] = "随夫嫁娶，宜室宜家。",
  ["$ex__jieyin2"] = "得遇夫君，妾身福分。",
}

local skill = fk.CreateSkill{
  name = "ex__jieyin",
}

skill:addEffect('active', {
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#ex__jieyin",
  interaction = function()
    return UI.ComboBox {choices = {"ex__jieyin_discard" , "ex__jieyin_put"}}
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 or not self.interaction.data then return false end
    if self.interaction.data == "ex__jieyin_put" then
      return Fk:getCardById(to_select).type == Card.TypeEquip
    else
      return not player:prohibitDiscard(Fk:getCardById(to_select)) and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
    end
  end,
  target_filter = function(self, player, to_select, selected, cards)
    if #cards ~= 1 or #selected > 0 or (not self.interaction.data) or to_select == player.id then return false end
    local target = to_select
    return target:isMale() and (self.interaction.data == "ex__jieyin_discard" or
      target:hasEmptyEquipSlot(Fk:getCardById(cards[1]).sub_type))
  end,
  on_use = function(self, room, effect)
    local from = effect.from
    local to = effect.tos[1]
    if self.interaction.data == "ex__jieyin_put" then
      room:moveCards({
        ids = effect.cards,
        from = effect.from,
        to = effect.tos[1],
        toArea = Card.PlayerEquip,
        moveReason = fk.ReasonPut,
      })
    else
      room:throwCard(effect.cards, skill.name, from, from)
    end
    if to.hp < from.hp then
      if to:isWounded() and not to.dead then
        room:recover({
          who = to,
          num = 1,
          recoverBy = from,
          skillName = skill.name
        })
      end
      if not from.dead then
        from:drawCards(1, self.name)
      end
    elseif to.hp > from.hp then
      if from:isWounded() and not from.dead then
        room:recover({
          who = from,
          num = 1,
          recoverBy = from,
          skillName = skill.name
        })
      end
      if not to.dead then
        to:drawCards(1, skill.name)
      end
    end
  end,
})

return skill
