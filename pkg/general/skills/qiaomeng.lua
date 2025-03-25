Fk:loadTranslationTable{
  ["qiaomeng"] = "趫猛",
  [":qiaomeng"] = "当你使用的黑色【杀】对一名角色造成伤害后，你可以弃置其装备区里的一张牌。当此牌移至弃牌堆后，若此牌为坐骑牌，你获得此牌。",

  ["$qiaomeng1"] = "秣马厉兵，枕戈待战。",
  ["$qiaomeng2"] = "夺敌辎重，以为己用。",
}

local skill = fk.CreateSkill{
  name = "qiaomeng",
}

skill:addEffect(fk.Damage, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash" and
      not data.to.dead and #data.to:getCardIds("e") > 0 and data.card.color == Card.Black
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    local cid = room:askToChooseCard(player, { target = to, flag = "e", skill_name = skill.name })
    if table.contains({Card.SubtypeDefensiveRide, Card.SubtypeOffensiveRide}, Fk:getCardById(cid, true).sub_type) then
      local record = player:getMark("_qiaomeng") ~= 0 and player:getMark("_qiaomeng") or {}
      table.insertIfNeed(record, cid)
      room:setPlayerMark(player, "_qiaomeng", record)
    end
    room:throwCard({cid}, self.name, to, player)
  end,
}):addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:getMark("_qiaomeng") == 0 or player.dead then return false end
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(player:getMark("_qiaomeng"), info.cardId) then
            return true
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local cids = {}
    local room = player.room
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(player:getMark("_qiaomeng"), info.cardId) then
            table.insertIfNeed(cids, info.cardId)
          end
        end
      end
    end
    local record = player:getMark("_qiaomeng") ~= 0 and player:getMark("_qiaomeng") or {}
    table.forEach(cids, function(cid)
      table.removeOne(record, cid)
    end)
    if #record == 0 then record = 0 end
    room:setPlayerMark(player, "_qiaomeng", record)
    room:obtainCard(player, cids, true, fk.ReasonPrey)
  end,
}, { is_delay_effect = true })

return skill
