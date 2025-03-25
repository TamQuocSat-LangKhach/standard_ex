Fk:loadTranslationTable{
  ["ex__yijue"] = "义绝",
  [":ex__yijue"] = "出牌阶段限一次，你可以弃置一张牌并令一名其他角色展示一张手牌。若此牌为黑色，则其直到回合结束不能使用或打出牌，"..
  "所有非锁定技失效，你对其使用的<font color='red'>♥</font>【杀】的伤害+1。若此牌为红色，则你获得此牌，可以令其回复1点体力。",
  ["#ex__yijue"] = "义绝：弃置一张牌，令一名角色展示一张手牌",

  ["@@yijue-turn"] = "义绝",
  ["#yijue-show"] = "义绝：请展示一张手牌",
  ["#yijue-recover"] = "义绝：是否令%dest回复1点体力？",

  ["$ex__yijue1"] = "关某，向来恩怨分明！",
  ["$ex__yijue2"] = "恩已断，义当绝！",
}

local skill = fk.CreateSkill{
  name = "ex__yijue",
}

skill:addEffect('active', {
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  prompt = "#ex__yijue",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, to_select)
    return to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local from = effect.from
    room:throwCard(effect.cards, self.name, from, from)
    local to = room:getPlayerById(effect.tos[1])

    if to:isKongcheng() then return end

    local showCard = room:askToCards(to, { min_num = 1, max_num = 1, include_equip = false, skill_name = self.name, cancelable = false, pattern = "#yijue-show::"..from.id })[1]
    to:showCards(showCard)

    showCard = Fk:getCardById(showCard)
    if showCard.color == Card.Black then
      room:addTableMark(to, "@@yijue-turn", from.id)
      room:addPlayerMark(to, MarkEnum.UncompulsoryInvalidity .. "-turn")
    else
      room:obtainCard(from, showCard, true, fk.ReasonPrey)
      if not to.dead and to:isWounded() then
        if room:askToSkillInvoke(from, { skill_name = skill.name, prompt = "#yijue-recover::"..to.id }) then
          room:recover({
            who = to,
            num = 1,
            recoverBy = from,
            skillName = self.name,
          })
        end
      end
    end
  end
}):addEffect('prohibit', {
  prohibit_use = function(self, player, card)
    return player:getMark("@@yijue-turn") ~= 0
  end,
  prohibit_response = function(self, player, card)
    return player:getMark("@@yijue-turn") ~= 0
  end,
}):addEffect(fk.DamageCaused, {
  mute = true,
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead and data.card and data.card.trueName == "slash" and data.card.suit == Card.Heart and
    table.contains(data.to:getTableMark("@@yijue-turn"), player.id) and not data.chain
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
})

return skill
