Fk:loadTranslationTable{
  ["ex__biyue"] = "闭月",
  [":ex__biyue"] = "结束阶段，你可以摸一张牌，若你没有手牌则改为两张。",

  ["$ex__biyue1"] = "梦蝶幻月，如沫虚妄。",
  ["$ex__biyue2"] = "水映月明，芙蓉照倩影。",
}

local skill = fk.CreateSkill{
  name = "ex__biyue",
}

skill:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(player:isKongcheng() and 2 or 1, skill.name)
  end,
})

skill:addTest(function(room, me)
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, "ex__biyue")
  end)

  FkTest.setNextReplies(me, { "1", "1" })
  FkTest.runInRoom(function()
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Finish })):exec()
  end)

  lu.assertEquals(#me:getCardIds("h"), 2)
  FkTest.runInRoom(function()
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Finish })):exec()
  end)

  lu.assertEquals(#me:getCardIds("h"), 3)
end)

return skill
