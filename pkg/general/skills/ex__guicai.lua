Fk:loadTranslationTable{
  ["ex__guicai"] = "鬼才",
  [":ex__guicai"] = "当判定结果确定前，你可打出一张牌代替之。",

  ["#ex__guicai-ask"] = "是否发动 鬼才，打出一张牌代替 %dest 的 %arg 判定",

  ["$ex__guicai1"] = "天命难违？哈哈哈哈哈……",
  ["$ex__guicai2"] = "才通天地，逆天改命！",
}

local skill = fk.CreateSkill{
  name = "ex__guicai",
}

skill:addEffect(fk.AskForRetrial, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skill.name) and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToCards(player, { min_num = 1, max_num = 1, include_equip = true,
    skill_name = self.name, cancelable = true, pattern = ".|.|.|hand,equip",
    prompt = "#ex__guicai-ask::" .. target.id .. ":" .. data.reason})
    if #card > 0 then
      room:doIndicate(player.id, {target.id})
      self.cost_data = card[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:retrial(Fk:getCardById(self.cost_data), player, data, skill.name)
  end,
}):addTest(function(room, me)
  FkTest.runInRoom(function() room:handleAddLoseSkills(me, skill.name) end)
end)

return skill
