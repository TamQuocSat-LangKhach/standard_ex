Fk:loadTranslationTable{
  ["tongji"] = "同疾",
  [":tongji"] = "锁定技，若你的手牌数大于体力值，攻击范围含有你的角色使用【杀】只能以你为目标。",

  ["$tongji1"] = "弑君之罪，当诛九族！",
  ["$tongji2"] = "你，你这是反啦！",
}

local skill = fk.CreateSkill{
  name = "tongji",
  tags = { Skill.Compulsory }
}

skill:addEffect('prohibit', {
  is_prohibited = function(self, from, to, card)
    local targets = table.filter(Fk:currentRoom().alive_players, function(p)
      return p:hasSkill(skill.name) and p:getHandcardNum() > p.hp and from:inMyAttackRange(p)
    end)
    if #targets > 0 then
      return card.trueName == "slash" and not table.contains(targets, to)
    end
  end,
}):addEffect(fk.TargetConfirmed, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and player:getHandcardNum() > player.hp and
      data.card and data.card.trueName == "slash"
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, skill.name, "negative")
    player:broadcastSkillInvoke(skill.name)
  end,
})

return skill
