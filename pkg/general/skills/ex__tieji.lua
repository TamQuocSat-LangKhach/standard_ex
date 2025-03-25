Fk:loadTranslationTable{
  ["ex__tieji"] = "铁骑",
  [":ex__tieji"] = "当你使用【杀】指定目标后，你可以令其本回合内非锁定技失效，然后进行一次判定，其需弃置一张花色与判定结果花色相同的牌，"..
  "否则其无法响应此【杀】。",
  ["ex__tieji_invalidity"] = "铁骑",
  ["@@tieji-turn"] = "铁骑",
  ["#ex__tieji-invoke"] = "是否对%dest发动 铁骑，令其本回合内非锁定技失效",
  ["#ex__tieji-discard"] = "铁骑：你需弃置一张%arg牌，否则无法响应此杀。",

  ["$ex__tieji1"] = "目标敌阵，全军突击！",
  ["$ex__tieji2"] = "敌人阵型已乱，随我杀！",
}

local skill = fk.CreateSkill{
  name = "ex__tieji",
}

skill:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill) and
      data.card.trueName == "slash" and not data.to.dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, { skill_name = skill.name, prompt = "#ex__tieji-invoke::"..data.to.id }) then
      room:doIndicate(player.id, {data.to.id})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    room:addPlayerMark(to, "@@tieji-turn")
    room:addPlayerMark(to, MarkEnum.UncompulsoryInvalidity .. "-turn")
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".|.|spade,club,heart,diamond",
    }
    room:judge(judge)
    if judge.card.suit ~= nil then
        local suits = {}
        table.insert(suits, judge.card:getSuitString())
      if #room:askToDiscard(to, { max_num = 1, min_num = 1, include_equip = false, skill_name = self.name, cancelable = true, pattern = ".|.|"..table.concat(suits, ","),
        prompt = "#ex__tieji-discard:::"..judge.card:getSuitString() }) == 0 then
        data.disresponsive = true
      end
    end
  end,
})

return skill
