local skill = fk.CreateSkill {
  name = "role__wooden_ox_skill",
  attached_equip = "role__wooden_ox",
}

skill:addEffect('active', {
  prompt = "#role__wooden_ox-prompt",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and #player:getPile("$role_carriage") < 5
  end,
  card_num = 1,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and table.contains(Self.player_cards[Player.Hand], to_select)
  end,
  target_num = 0,
  on_use = function(self, room, effect)
    local player = effect.from
    player:addToPile("$role_carriage", effect.cards[1], false, self.name)
    if player.dead then return end
    local ox = table.find(player:getCardIds("e"), function (id) return Fk:getCardById(id).name == "role__wooden_ox" end)
    if ox then
      local targets = table.filter(room.alive_players, function(p)
        return p ~= player and p:hasEmptyEquipSlot(Card.SubtypeTreasure) end)
      if #targets > 0 then
        local tos = room:askToChoosePlayers(player, { targets = targets, min_num = 1, max_num = 1, prompt = "#role__wooden_ox-move", skill_name = self.name, cancelable = true })
        if #tos > 0 then
          room:moveCardTo(ox, Card.PlayerEquip, tos[1], fk.ReasonPut, self.name, nil, true, player.id, nil)
        end
      end
    end
  end,
}):addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if player:getPile("$role_carriage") == 0 then return false end
    for _, move in ipairs(data) do
      for _, info in ipairs(move.moveInfo) do
        if Fk:getCardById(info.cardId).name == "role__wooden_ox" then
          --多个木马同时移动的情况取其中之一即可，不再做冗余判断
          if info.fromArea == Card.Processing then
            local room = player.room
            --注意到一次交换事件的过程中的两次移动事件都是在一个parent事件里进行的，因此查询到parent事件为止即可
            local move_event = room.logic:getCurrentEvent():findParent(GameEvent.MoveCards, true)
            if not move_event then return end
            local parent_event = move_event.parent
            local move_events = room.logic:getEventsByRule(GameEvent.MoveCards, 1, function (e)
              if e.id >= move_event.id or e.parent ~= parent_event then return false end
              for _, last_move in ipairs(e.data) do
                if last_move.moveReason == fk.ReasonExchange and last_move.toArea == Card.Processing then
                  return true
                end
              end
            end, parent_event.id)
            if #move_events > 0 then
              for _, last_move in ipairs(move_events[1].data) do
                if last_move.moveReason == fk.ReasonExchange then
                  for _, last_info in ipairs(last_move.moveInfo) do
                    if Fk:getCardById(last_info.cardId).name == "role__wooden_ox" then
                      if last_move.from == player.id and last_info.fromArea == Card.PlayerEquip then
                        if move.toArea == Card.PlayerEquip then
                          if move.to ~= player.id then
                            self.cost_data = move.to
                            return true
                          end
                        else
                          self.cost_data = nil
                          return true
                        end
                      end
                    end
                  end
                end
              end
            end
          elseif move.moveReason == fk.ReasonExchange then
            if move.from == player.id and info.fromArea == Card.PlayerEquip and move.toArea ~= Card.Processing then
              --适用于被修改了移动区域的情况，如销毁，虽然说原则上移至处理区是不应销毁的
              self.cost_data = nil
              return true
            end
          elseif move.from == player.id and info.fromArea == Card.PlayerEquip then
            if move.toArea == Card.PlayerEquip then
              if move.to ~= player.id then
                self.cost_data = move.to
                return true
              end
            else
              self.cost_data = nil
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, _, player, data)
    local room = player.room
    local cards = player:getPile("$role_carriage")
    local to = self.cost_data
    if to then
      room:getPlayerById(to):addToPile("$role_carriage", cards, false, "role__wooden_ox_skill", nil, {player.id, to})
    else
      room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, "role__wooden_ox_skill", nil, true)
    end
  end
}):addEffect('filter', {
  handly_cards = function (self, player)
    if player:hasSkill("role__wooden_ox_skill") then
      return player:getPile("$role_carriage")
    end
  end,
})

return skill
