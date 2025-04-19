Fk:loadTranslationTable{
  ["ex__jiuyuan"] = "救援",
  [":ex__jiuyuan"] = "主公技，当体力值大于你的吴势力角色使用【桃】指定自己为目标时，若你已受伤，其可以将此【桃】转移给你，然后其摸一张牌。",

  ["#ex__jiuyuan-ask"] = "救援：你可以将【桃】转移给 %dest，然后你摸一张牌",

  ["$ex__jiuyuan1"] = "你们真是朕的得力干将。",
  ["$ex__jiuyuan2"] = "有爱卿在，朕无烦忧。",
}

local jiuyuan = fk.CreateSkill{
  name = "ex__jiuyuan",
  tags = { Skill.Lord },
}

jiuyuan:addEffect(fk.TargetSpecifying, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(jiuyuan.name) and
      data.card.name == "peach" and target.kingdom == "wu" and data.to == target and
      target.hp >= player.hp and player:isWounded()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(target, {
      skill_name = jiuyuan.name,
      prompt = "#ex__jiuyuan-ask::"..player.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    data:cancelTarget(target)
    data:addTarget(player)
    target:drawCards(1, jiuyuan.name)
  end,
})

return jiuyuan
