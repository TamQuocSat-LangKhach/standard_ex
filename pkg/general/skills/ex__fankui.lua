Fk:loadTranslationTable{
  ["ex__fankui"] = "反馈",
  [":ex__fankui"] = "当你受到1点伤害后，你可以获得来源的一张牌。",

  ["#ex__fankui-invoke"] = "是否对%dest发动 反馈，获得其一张牌",

  ["$ex__fankui1"] = "哼，自作孽不可活！",
  ["$ex__fankui2"] = "哼，正中下怀！",
}

local skill = fk.CreateSkill{
  name = "ex__fankui",
}

skill:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and data.from and not data.from.dead and not data.from:isNude()
  end,
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      if i > 1 and (self.cancel_cost or data.from.dead or data.from:isNude() or not player:hasSkill(skill.name)) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, { skill_name = skill.name, prompt = "#ex__fankui-invoke::"..data.from.id }) then
      room:doIndicate(player.id, {data.from.id})
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToChooseCard(player, { target = data.from, flag = "he", skill_name = skill.name })
    room:obtainCard(player, card, false, fk.ReasonPrey)
  end
})

return skill
