Fk:loadTranslationTable{
  ["ex__yiji"] = "遗计",
  [":ex__yiji"] = "当你受到1点伤害后，你可以摸两张牌，然后你可以将至多两张手牌交给一至两名其他角色。",

  ["#ex__yiji-give"] = "遗计：将至多%arg张手牌分配给其他角色",

  ["$ex__yiji1"] = "锦囊妙策，终定社稷。",
  ["$ex__yiji2"] = "依此计行，辽东可定。",
}

local skill = fk.CreateSkill{
  name = "ex__yiji",
}

skill:addEffect(fk.Damaged, {
  anim_type = "masochism",
  events = {fk.Damaged},
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      if i > 1 and (self.cancel_cost or not player:hasSkill(skill.name)) then return false end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(target, { skill_name = skill.name }) then return true end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(2, skill.name)
    if player.dead or player:isKongcheng() then return end
    room:askToYiji(player, { cards = player:getCardIds("h"), targets = room:getOtherPlayers(player, false), skill_name = skill.name, min_num = 0, max_num = 2 })
  end
})

return skill
