Fk:loadTranslationTable{
  ["yaowu"] = "耀武",
  [":yaowu"] = "锁定技，当你受到【杀】造成的伤害时，若此【杀】为红色，伤害来源回复1点体力或摸一张牌；若此【杀】不为红色，你摸一张牌。",

  ["$yaowu1"] = "大人有大量，不和你计较！",
  ["$yaowu2"] = "哼，先让你尝点甜头！",
}

local skill = fk.CreateSkill{
  name = "yaowu",
  tags = { Skill.Compulsory }
}

skill:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and data.card and data.card.trueName == "slash"
    and (data.card.color ~= Card.Red or (data.from and not data.from.dead))
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.card.color ~= Card.Red then
      room:notifySkillInvoked(player, skill.name, "masochism")
      player:broadcastSkillInvoke(skill.name, 1)
      player:drawCards(1, skill.name)
    else
      room:notifySkillInvoked(player, skill.name, "negative")
      player:broadcastSkillInvoke(skill.name, 2)
      local from = data.from
      if not from then return end
      local choices = {"draw1"}
      if from:isWounded() then
        table.insert(choices, "recover")
      end
      local choice = room:askToChoice(from, { choices = choices, skill_name = skill.name })
      if choice == "recover" then
        room:recover({
          who = from,
          num = 1,
          recoverBy = from,
          skillName = self.name,
        })
      else
        from:drawCards(1, self.name)
      end
    end
  end
})

return skill
