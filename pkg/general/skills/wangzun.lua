Fk:loadTranslationTable{
  ["wangzun"] = "妄尊",
  [":wangzun"] = "主公的准备阶段，你可以摸一张牌，然后其本回合手牌上限-1。",

  ["$wangzun1"] = "真命天子，八方拜服。",
  ["$wangzun2"] = "归顺于我，封爵赏地。",
}

local skill = fk.CreateSkill{
  name = "wangzun",
}

skill:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target.phase == Player.Start and player:hasSkill(skill.name) and target.role == "lord"
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, skill.name)
    if not target.dead and target:getMaxCards() > 0 then
      player.room:addPlayerMark(target, MarkEnum.MinusMaxCardsInTurn)
    end
  end,
})

skill:addTest(function(room, me)
  local comp2 = room.players[2]
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, "wangzun")
  end)
  FkTest.setNextReplies(me, { "1" })
  FkTest.runInRoom(function()
    comp2.role = "lord"
    comp2.hp = 1
    GameEvent.Turn:create(TurnData:new(comp2, "game_rule", { Player.Start, Player.Draw, Player.Discard })):exec()
  end)
  lu.assertEquals(#me:getCardIds("h"), 1)
  lu.assertEquals(#comp2:getCardIds("h"), 0)
end)

return skill
