Fk:loadTranslationTable{
  ["ex__jiuyuan"] = "救援",
  [":ex__jiuyuan"] = "主公技，其他吴势力角色于其回合内回复体力时，若其体力值大于等于你，则其可以改为令你回复1点体力，然后其摸一张牌。",

  ["#ex__jiuyuan-ask"] = "救援：你可以改为令 %dest 回复1点体力，然后你摸一张牌",

  ["$ex__jiuyuan1"] = "你们真是朕的得力干将。",
  ["$ex__jiuyuan2"] = "有爱卿在，朕无烦忧。",
}

local skill = fk.CreateSkill{
  name = "ex__jiuyuan$",
}

skill:addEffect(fk.PreHpRecover, {
  anim_type = "support",
  events = {fk.PreHpRecover},
  can_trigger = function(self, event, target, player, data)
    return
      target ~= player and
      player:hasSkill(self) and
      target.kingdom == "wu" and
      target.phase ~= Player.NotActive and
      target.hp >= player.hp and
      player:isWounded()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(target, { skill_name = self.name, prompt = "#ex__jiuyuan-ask::"..player.id })
  end,
  on_use = function(self, event, target, player, data)
    player.room:recover{
      who = player,
      num = 1,
      skillName = self.name,
      recoverBy = target,
    }
    target:drawCards(1, self.name)
    return true
  end,
})

return skill
