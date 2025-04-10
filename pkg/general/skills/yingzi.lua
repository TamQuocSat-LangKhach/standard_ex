Fk:loadTranslationTable{
  ["ex__yingzi"] = "英姿",
  [":ex__yingzi"] = "锁定技，摸牌阶段，你多摸一张牌；你的手牌上限等同于你的体力上限。",

  ["$ex__yingzi1"] = "哈哈哈哈哈哈哈哈！",
  ["$ex__yingzi2"] = "伯符，且看我这一手！",
}

local skill = fk.CreateSkill{
  name = "ex__yingzi",
  tags = { Skill.Compulsory }
}

skill:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,
}):addEffect('maxcards', {
  fixed_func = function(self, player)
    if player:hasShownSkill(skill.name) then
      return player.maxHp
    end
  end
})

skill:addTest(function(room, me)
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, "ex__yingzi")
  end)
  FkTest.runInRoom(function()
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Draw })):exec()
  end)
  lu.assertEquals(#me:getCardIds("h"), 3)
  FkTest.runInRoom(function()
    me.hp = 1
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Draw, Player.Discard })):exec()
  end)
  lu.assertEquals(#me:getCardIds("h"), me.maxHp)
end)

return skill
