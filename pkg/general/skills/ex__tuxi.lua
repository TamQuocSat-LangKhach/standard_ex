Fk:loadTranslationTable{
  ["ex__tuxi"] = "突袭",
  [":ex__tuxi"] = "摸牌阶段，你可以少摸任意张牌并获得等量其他角色各一张手牌。",

  ["#ex__tuxi-choose"] = "突袭：你可以少摸至多%arg张牌，获得等量其他角色各一张手牌",

  ["$ex__tuxi1"] = "快马突袭，占尽先机！",
  ["$ex__tuxi2"] = "马似飞影，枪如霹雳！",
}

local skill = fk.CreateSkill{
  name = "ex__tuxi",
}

skill:addEffect(fk.DrawNCards, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill) and data.n > 0 and
      table.find(player.room:getOtherPlayers(player, false), function(p) return not p:isKongcheng() end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room:getOtherPlayers(player, false), function(p)
      return not p:isKongcheng() end), Util.IdMapper)
    local tos = room:askToChoosePlayers(player, { targets = targets, min_num = 1, max_num = data.n, prompt = "#ex__tuxi-choose:::"..data.n, skill_name = skill.name, cancelable = true })
    if #tos > 0 then
        room:sortByAction(tos)
      self.cost_data = {tos = tos}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = table.simpleClone(self.cost_data.tos)
    for _, id in ipairs(tos) do
      local to = room:getPlayerById(id)
      if not (to.dead or to:isKongcheng()) then
        local c = room:askToChooseCard(player, { target = to, flag = "h", skill_name = skill.name })
        room:obtainCard(player, c, false, fk.ReasonPrey, player, skill.name)
        if player.dead then break end
      end
    end
    data.n = data.n - #tos
  end,
})

return skill
