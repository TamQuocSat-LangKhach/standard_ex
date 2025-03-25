Fk:loadTranslationTable{
  ["ex__tishen"] = "替身",
  [":ex__tishen"] = "限定技，准备阶段，若你已受伤，则你可以将体力值回复至上限，然后摸回复数值张牌。",

  ["#tishen-invoke"] = "替身: 你可以回复%arg点体力并摸%arg张牌",

  ["$ex__tishen1"] = "欺我无谋，定要尔等血偿！",
  ["$ex__tishen2"] = "谁，还敢过来一战！？",
}

local skill = fk.CreateSkill{
  name = "ex__tishen",
  tag = { Skill.Limited }
}

skill:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and player.phase == Player.Start and player:isWounded() and
      player:usedSkillTimes(skill.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local maxHp = player:getLostHp()
    return player.room:askToSkillInvoke(player, { skill_name = skill.name, prompt = "#tishen-invoke:::"..maxHp })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player:getLostHp()
    room:recover({
      who = player,
      num = n,
      recoverBy = player,
      skillName = skill.name
    })
    if not player.dead then
      player:drawCards(n, skill.name)
    end
  end,
})

skill:addTest(function(room, me)
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, "ex__tishen")
  end)
  FkTest.setNextReplies(me, { "1" })
  local add = math.random(1, 10)
  FkTest.runInRoom(function()
    room:changeMaxHp(me, add)
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Start })):exec()
  end)
  lu.assertEquals(me.hp, me.maxHp)
  lu.assertEquals(#me:getCardIds("h"), add)
end)

return skill
