Fk:loadTranslationTable{
  ["ex__luoshen"] = "洛神",
  [":ex__luoshen"] = "准备阶段开始时，你可以进行判定，当黑色判定牌生效后，你获得之并可以重复此流程。你以此法获得的牌在本回合不计入手牌上限。",

  ["@@ex__luoshen-inhand-turn"] = "洛神",

  ["$ex__luoshen1"] = "屏翳收风，川后静波。",
  ["$ex__luoshen2"] = "冯夷鸣鼓，女娲清歌。",
}

local skill = fk.CreateSkill{
  name = "ex__luoshen",
}

skill:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Start and player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    while true do
      local judge = {
        who = player,
        reason = skill.name,
        pattern = ".|.|spade,club",
      }
      room:judge(judge)
      if judge.card.color ~= Card.Black then
        break
      end
      if not room:askToSkillInvoke(player, { skill_name = skill.name }) then
        break
      end
    end
  end,
}):addEffect(fk.FinishJudge, {
  mute = true,
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.reason == skill.name and
    data.card.color == Card.Black and player.room:getCardArea(data.card.id) == Card.Processing
  end,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(player, data.card, true, nil, player.id, skill.name, "@@ex__luoshen-inhand-turn")
  end,
}):addEffect('maxcards', {
  exclude_from = function(self, player, card)
    return card:getMark("@@ex__luoshen-inhand-turn") > 0
  end,
}):addTest(function(room, me)
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, "ex__luoshen")
  end)
  local red = table.find(room.draw_pile, function(cid)
    return Fk:getCardById(cid).color == Card.Red
  end)
  local blacks = table.filter(room.draw_pile, function(cid)
    return Fk:getCardById(cid).color == Card.Black
  end)
  local rnd = 5
  FkTest.setNextReplies(me, { "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1" }) -- 除了第一个1以外后面全是潜在的“重复流程”
  -- 每次往红牌顶上塞若干个黑牌
  FkTest.runInRoom(function()
    room:throwCard(me:getCardIds("h"), nil, me, me)
    -- 控顶
    room:moveCardTo(red, Card.DrawPile)
    if rnd > 0 then room:moveCardTo(table.slice(blacks, 1, rnd + 1), Card.DrawPile) end

    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Start })):exec()
  end)
  lu.assertEquals(#me:getCardIds("h"), rnd)
  FkTest.setNextReplies(me, { "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1" }) -- 除了第一个1以外后面全是潜在的“重复流程”
  FkTest.runInRoom(function()
    room:throwCard(me:getCardIds("h"), nil, me, me)
    me.hp = 1
    -- 控顶
    room:moveCardTo(red, Card.DrawPile)
    if rnd > 0 then room:moveCardTo(table.slice(blacks, 1, rnd + 1), Card.DrawPile) end
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Start, Player.Discard })):exec()
  end)
  lu.assertEquals(#me:getCardIds("h"), rnd)
end)

return skill
