Fk:loadTranslationTable{
  ["ex__yijue"] = "义绝",
  [":ex__yijue"] = "出牌阶段限一次，你可以弃置一张牌并令一名其他角色展示一张手牌。若此牌为黑色，则其直到回合结束不能使用或打出牌，"..
  "所有非锁定技失效，你对其使用的<font color='red'>♥</font>【杀】的伤害+1；若此牌为红色，则你获得此牌，可以令其回复1点体力。",

  ["#ex__yijue"] = "义绝：弃置一张牌，令一名角色展示一张手牌",
  ["@@ex__yijue-turn"] = "义绝",
  ["#ex__yijue-show"] = "义绝：请展示一张手牌",
  ["#ex__yijue-recover"] = "义绝：是否令%dest回复1点体力？",

  ["$ex__yijue1"] = "关某，向来恩怨分明！",
  ["$ex__yijue2"] = "恩已断，义当绝！",
}

local yijue = fk.CreateSkill{
  name = "ex__yijue",
}

yijue:addEffect("active", {
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  prompt = "#ex__yijue",
  can_use = function(self, player)
    return player:usedEffectTimes(yijue.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and not player:prohibitDiscard(to_select)
  end,
  target_filter = function(self, player, to_select)
    return to_select ~= player and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:throwCard(effect.cards, yijue.name, player, player)
    local to = effect.tos[1]

    if to:isKongcheng() then return end

    local card = room:askToCards(to, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = yijue.name,
      prompt = "#ex__yijue-show",
      cancelable = false,
    })[1]
    to:showCards(card)
    if to.dead then return end
    if Fk:getCardById(card).color == Card.Black then
      room:addTableMark(to, "@@ex__yijue-turn", player.id)
      room:addPlayerMark(to, MarkEnum.UncompulsoryInvalidity .. "-turn")
    else
      room:obtainCard(player, card, true, fk.ReasonPrey, player, yijue.name)
      if not player.dead and not to.dead and to:isWounded() and
        room:askToSkillInvoke(player, {
          skill_name = yijue.name,
          prompt = "#yijue-recover::"..to.id,
        }) then
        room:recover{
          who = to,
          num = 1,
          recoverBy = player,
          skillName = yijue.name,
        }
      end
    end
  end
})

yijue:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return player:getMark("@@ex__yijue-turn") ~= 0
  end,
  prohibit_response = function(self, player, card)
    return player:getMark("@@ex__yijue-turn") ~= 0
  end,
})

yijue:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card and data.card.trueName == "slash" and data.card.suit == Card.Heart and
    table.contains(data.to:getTableMark("@@ex__yijue-turn"), player.id) and player.room.logic:damageByCardEffect()
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end,
})

return yijue
