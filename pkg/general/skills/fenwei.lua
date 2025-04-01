Fk:loadTranslationTable{
  ["fenwei"] = "奋威",
  [":fenwei"] = "限定技，当一张锦囊牌指定多个目标后，你可令此牌对其中任意个目标无效。",

  ["#fenwei-choose"] = "奋威：你可以令此%arg对任意个目标无效",

  ["$fenwei1"] = "奋勇当先，威名远扬！",
  ["$fenwei2"] = "哼！敢欺我东吴无人。",
}

local skill = fk.CreateSkill{
  name = "fenwei",
  tags = { Skill.Limited },
}

skill:addEffect(fk.TargetSpecified, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card.type == Card.TypeTrick and #data:getAllTargets() > 1 and data.firstTarget and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local tos = player.room:askToChoosePlayers(player, { targets = data.tos,
    min_num = 1, max_num = #data.tos, prompt = "#fenwei-choose:::"..data.card:toLogString(), skill_name = skill.name, cancelable = true })
    if #tos > 0 then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    table.insertTable(data.nullifiedTargets, self.cost_data)
  end,
})

return skill
