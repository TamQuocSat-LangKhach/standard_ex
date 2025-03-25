Fk:loadTranslationTable{
  ["ex__qingjian"] = "清俭",
  [":ex__qingjian"] = "每回合限一次，当你于摸牌阶段外获得牌后，你可以展示任意张牌并交给一名其他角色。当前回合角色本回合手牌上限+X（X为你"..
  "展示牌的类别数）。",

  ["#ex__qingjian-invoke"] = "是否发动 清俭，将任意张牌交给一名其他角色，并令当前回合角色手牌上限增加给出的类别数",

  ["$ex__qingjian1"] = "福生于清俭，德生于卑退。",
  ["$ex__qingjian2"] = "钱财，乃身外之物。",
}

local skill = fk.CreateSkill{
  name = "ex__qingjian",
}

skill:addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skill.name) and player:usedSkillTimes(skill.name, Player.HistoryTurn) == 0 and
    not player:isNude() and player.phase ~= Player.Draw then
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Player.Hand then
          return true
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos, cards = room:askToChooseCardsAndPlayers(player, { min_card_num = 1, max_card_num = #player:getCardIds("he"),
    targets = room:getOtherPlayers(player, false), min_num = 1, max_num = 1, pattern = ".",
    prompt = "#ex__qingjian-invoke", skill_name = skill.name, cancelable = true, no_indicate = true })
    if #tos > 0 and #cards > 0 then
      self.cost_data = {tos = tos, cards = cards}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local types = {}
    for _, id in ipairs(self.cost_data.cards) do
      table.insertIfNeed(types, Fk:getCardById(id).type)
    end
    room:moveCardTo(self.cost_data.cards, Player.Hand, self.cost_data.tos[1], fk.ReasonGive,
    skill.name, nil, true, player)
    if not room.current.dead then
      room:addPlayerMark(room.current, MarkEnum.AddMaxCardsInTurn, #types)
    end
  end,
}):addTest(function(room, me)
  local comp2 = room.players[2] ---@type ServerPlayer, ServerPlayer
  FkTest.runInRoom(function() room:handleAddLoseSkills(me, skill.name) end)
end)

return skill
