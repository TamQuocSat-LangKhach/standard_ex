Fk:loadTranslationTable{
  ["wangxi"] = "忘隙",
  [":wangxi"] = "当你对其他角色造成1点伤害后，或当你受到其他角色造成的1点伤害后，你可以与其各摸一张牌。",

  ["#wangxi-invoke"] = "忘隙：你可以与 %dest 各摸一张牌",

  ["$wangxi1"] = "大丈夫，何拘小节。",
  ["$wangxi2"] = "前尘往事，莫再提起。",
}

local skill = fk.CreateSkill{
  name = "wangxi",
}

skill:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and data.from and data.from ~= data.to and not (data.from.dead or data.to.dead)
  end,
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      if i > 1 and self.cancel_cost or not self:triggerable(event, target, player, data) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local to = data.from
    local room = player.room
    if room:askToSkillInvoke(player, { skill_name = self.name, prompt = "#wangxi-invoke::"..to.id }) then
      room:doIndicate(player.id, {to.id})
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    local tos = {player}
    table.insertIfNeed(tos, data.from)
    table.insertIfNeed(tos, data.to)
    room:sortByAction(tos)
    for _, to in ipairs(tos) do
      if not to.dead then
        room:drawCards(to, 1, self.name)
      end
    end
  end
}):addEffect(fk.Damage, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and data.from and data.from ~= data.to and not (data.from.dead or data.to.dead)
  end,
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      if i > 1 and self.cancel_cost or not self:triggerable(event, target, player, data) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local to = data.to
    local room = player.room
    if room:askToSkillInvoke(player, { skill_name = self.name, prompt = "#wangxi-invoke::"..to.id }) then
      room:doIndicate(player.id, {to.id})
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    local tos = {player}
    table.insertIfNeed(tos, data.from)
    table.insertIfNeed(tos, data.to)
    room:sortByAction(tos)
    for _, to in ipairs(tos) do
      if not to.dead then
        room:drawCards(to, 1, self.name)
      end
    end
  end
})

skill:addTest(function(room, me)
  local comp2 = room.players[2] ---@type ServerPlayer, ServerPlayer
  FkTest.runInRoom(function() room:handleAddLoseSkills(me, skill.name) end)

  local slash = Fk:getCardById(1)
  FkTest.setNextReplies(me, { "__cancel", "1" })
  FkTest.runInRoom(function()
    room:useCard{
      from = comp2,
      tos = { me },
      card = slash,
    }
  end)
  lu.assertEquals(#comp2:getCardIds("h"), 1)
  lu.assertEquals(#me:getCardIds("h"), 1)

  FkTest.setNextReplies(comp2, { "__cancel" })
  FkTest.setNextReplies(me, { "1" })
  FkTest.runInRoom(function()
    room:useCard{
      from = me,
      tos = { comp2 },
      card = slash,
    }
  end)
  lu.assertEquals(#comp2:getCardIds("h"), 2)
  lu.assertEquals(#me:getCardIds("h"), 2)
end)

return skill
