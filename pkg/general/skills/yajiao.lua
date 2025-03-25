Fk:loadTranslationTable{
  ["yajiao"] = "涯角",
  [":yajiao"] = "当你于回合外因使用或打出而失去手牌后，你可以展示牌堆顶的一张牌。若这两张牌的类别相同，你可以将展示的牌交给一名角色；"..
  "若类别不同，你可弃置攻击范围内包含你的角色区域里的一张牌。",

  ["#yajiao-choose"] = "涯角: 选择一名攻击范围内包含你的角色弃置其区域内的一张牌",
  ["#yajiao-card"] = "涯角: 你可以将%arg交给一名角色",

  ["$yajiao1"] = "遍寻天下，但求一败！",
  ["$yajiao2"] = "策马驱前，斩敌当先！",
}

local skill = fk.CreateSkill{
  name = "yajiao",
}

skill:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player.phase == Player.NotActive then
      for _, move in ipairs(data) do
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand and table.contains({fk.ReasonUse, fk.ReasonResonpse}, move.moveReason) then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:getCardById(room:getNCards(1)[1])
    local eType
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand and table.contains({fk.ReasonUse, fk.ReasonResonpse}, move.moveReason) then
            eType = move.moveReason == fk.ReasonUse and GameEvent.UseCard or GameEvent.RespondCard
            break
          end
        end
      end
    end
    local e = room.logic:getCurrentEvent():findParent(eType)
    if not e then return end
    local lost = e.data.card
    room:moveCardTo(card, Card.Processing, nil, fk.ReasonJustMove, skill.name, nil, true, player)
    if card.type == lost.type then
      local to = room:askToChoosePlayers(player, { targets = room.alive_players, max_num = 1, min_num = 1,
        prompt = "#yajiao-card:::"..card:toLogString(), skill_name = skill.name, cancelable = true })
      if #to > 0 then
        room:obtainCard(to[1], card, true, fk.ReasonGive, player, skill.name)
      end
    else
      local targets = {}
      for _, p in ipairs(room.alive_players) do
        if not p:isAllNude() and p:inMyAttackRange(player) then
          table.insert(targets, p)
        end
      end
      if #targets > 0 then
        local to = room:askToChoosePlayers(player, { targets = targets, max_num = 1, min_num = 1, prompt = "#yajiao-choose", skill_name = skill.name, cancelable = true })
        if #to > 0 then
          local throw = room:askToChooseCard(player, { target = to[1], flag = "hej", skill_name = skill.name })
          room:throwCard(throw, skill.name, room:getPlayerById(to[1]), player)
        end
      end
    end
    if room:getCardArea(card) == Card.Processing then
      room:moveCardTo(card, Card.DrawPile, nil, fk.ReasonPutIntoDiscardPile, skill.name, nil, true, player)
    end
  end,
})

return skill
