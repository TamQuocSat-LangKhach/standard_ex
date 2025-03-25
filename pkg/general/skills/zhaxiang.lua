Fk:loadTranslationTable{
  ["zhaxiang"] = "诈降",
  [":zhaxiang"] = "锁定技，每当你失去1点体力，你摸三张牌，然后若此时是你的出牌阶段内，"..
  "则此阶段内你使用【杀】次数上限+1、使用红色【杀】无距离限制且不可被响应。",

  ["@@zhaxiang-phase"] = "诈降",

  ["$zhaxiang1"] = "铁锁连舟而行，东吴水师可破！",
  ["$zhaxiang2"] = "两军阵前，不斩降将！",
}

local zhaxiang = fk.CreateSkill{
  name = "zhaxiang",
  tags = { Skill.Compulsory }
}

zhaxiang:addEffect(fk.HpLost, {
  on_trigger = function(self, event, target, player, data)
    for i = 1, data.num do
      if i > 1 and not player:hasSkill(self) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(3, zhaxiang.name)
    if player.phase == Player.Play then
      local room = player.room
      room:setPlayerMark(player, "@@zhaxiang-phase", 1)
      room:addPlayerMark(player, MarkEnum.SlashResidue.."-phase")
    end
  end,
}):addEffect(fk.PreCardUse, {
  can_refresh = function(self, event, target, player, data)
    return player == target and data.card.trueName == "slash" and data.card.color == Card.Red and
      player:usedSkillTimes(zhaxiang.name, Player.HistoryPhase) > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.disresponsiveList = table.map(player.room.alive_players, Util.IdMapper)
  end,
}, { is_delay_effect = true }):addEffect('targetmod', {
  bypass_distances =  function(self, player, skill, card)
    return card.trueName == "slash" and card.color == Card.Red and player:usedSkillTimes(zhaxiang.name, Player.HistoryPhase) > 0
  end,
})

zhaxiang:addTest(function(room, me)
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, "zhaxiang")
  end)
  FkTest.runInRoom(function()
    room:loseHp(me, 2)
  end)
  lu.assertEquals(#me:getCardIds("h"), 6)
end)
return zhaxiang
