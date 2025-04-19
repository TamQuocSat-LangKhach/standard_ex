Fk:loadTranslationTable{
  ["jiyuan"] = "急援",
  [":jiyuan"] = "当一名角色进入濒死时或当你交给一名其他角色牌后，你可令其摸一张牌。",

  ["#jiyuan-trigger"] = "急援：是否令 %dest 摸一张牌？",

  ["$jiyuan1"] = "公若辞，必遭蔡瑁之害矣。",
  ["$jiyuan2"] = "形势危急，还请速行。",
}

local jiyuan = fk.CreateSkill{
  name = "jiyuan",
}

jiyuan:addEffect(fk.EnterDying, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jiyuan.name)
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = jiyuan.name,
      prompt = "#jiyuan-trigger::" .. target.id,
    }) then
      event:setCostData(self, {tos = {target}})
    end
  end,
  on_use = function(self, event, target, player, data)
    target:drawCards(1, jiyuan.name)
  end,
})

jiyuan:addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(jiyuan.name) then
      for _, move in ipairs(data) do
        if move.to and move.to ~= player and not move.to.dead and
          move.proposer == player and move.moveReason == fk.ReasonGive then
          return true
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local targets = {}
    local room = player.room
    for _, move in ipairs(data) do
      if move.to and move.to ~= player and not move.to.dead and
        move.proposer == player and move.moveReason == fk.ReasonGive then
        table.insert(targets, move.to)
      end
    end
    room:sortByAction(targets)
    for _, p in ipairs(targets) do
      if not player:hasSkill(jiyuan.name) then break end
      event:setCostData(self, {tos = {p}})
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jiyuan.name,
      prompt = "#jiyuan-trigger::" .. event:getCostData(self).tos[1].id
    })
  end,
  on_use = function(self, event, target, player, data)
    event:getCostData(self).tos[1]:drawCards(1, jiyuan.name)
  end,
})

return jiyuan
