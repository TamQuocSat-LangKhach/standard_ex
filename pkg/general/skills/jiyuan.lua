Fk:loadTranslationTable{
  ["jiyuan"] = "急援",
  [":jiyuan"] = "当一名角色进入濒死时或当你交给一名其他角色牌后，你可令其摸一张牌。",

  ["#jiyuan-trigger"] = "急援：你可令 %dest 摸一张牌",

  ["$jiyuan1"] = "公若辞，必遭蔡瑁之害矣。",
  ["$jiyuan2"] = "形势危急，还请速行。",
}

local skill = fk.CreateSkill{
  name = "jiyuan",
}

skill:addEffect(fk.EnterDying, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skill.name)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = skill.name, prompt = "#jiyuan-trigger::" .. target.id })
  end,
  on_use = function(self, event, target, player, data)
    player.room:doIndicate(player.id, {target.id})
    target:drawCards(1, skill.name)
  end,
}):addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  events = {fk.EnterDying, fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skill.name) then return false end
    for _, move in ipairs(data) do
      local to = move.to
      if to and to ~= player and move.proposer == player and move.moveReason == fk.ReasonGive then
        return true
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local targets = {}
    local room = player.room
    for _, move in ipairs(data) do
      local to = move.to
      if to and to ~= player and (move.from == player or (move.skillName and player:hasSkill(move.skillName))) and (move.toArea == Card.PlayerHand or move.toArea == Card.PlayerEquip) and move.moveReason == fk.ReasonGive then
        table.insertIfNeed(targets, move.to)
      end
    end
    room:sortByAction(targets)
    for _, target_id in ipairs(targets) do
      if not player:hasSkill(skill.name) then break end
      local skill_target = room:getPlayerById(target_id)
      self:doCost(event, skill_target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = skill.name, prompt = "#jiyuan-trigger::" .. target.id })
  end,
  on_use = function(self, event, target, player, data)
    player.room:doIndicate(player.id, {target.id})
    target:drawCards(1, skill.name)
  end,
})

return skill
