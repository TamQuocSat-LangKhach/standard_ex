Fk:loadTranslationTable{
  ["ex__jizhi"] = "集智",
  [":ex__jizhi"] = "当你使用锦囊牌时，你可以摸一张牌。若此牌为基本牌且此时是你的回合内，则你可以弃置之，然后令本回合手牌上限+1。",

  ["@jizhi-turn"] = "集智",
  ["#jizhi-invoke"] = "集智：是否弃置%arg，令你本回合的手牌上限+1？",

  ["$ex__jizhi1"] = "得上通，智集心。",
  ["$ex__jizhi2"] = "集万千才智，致巧趣鲜用。",
}

local jizhi = fk.CreateSkill{
  name = "ex__jizhi",
}

jizhi:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jizhi.name) and data.card.type == Card.TypeTrick and
      (not data.card:isVirtual() or #data.card.subcards == 0)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player:drawCards(1)
    if #cards == 0 then return false end
    local card = Fk:getCardById(cards[1])
    if card.type == Card.TypeBasic and not player.dead and room.current ~= player and
      table.contains(player:getCardIds("h"), card.id) and not player:prohibitDiscard(card) and
      room:askToSkillInvoke(player, {
        skill_name = jizhi.name,
        prompt = "#jizhi-invoke:::"..card:toLogString(),
      }) then
      room:addPlayerMark(player, MarkEnum.AddMaxCardsInTurn, 1)
      room:throwCard(card, jizhi.name, player, player)
    end
  end,
})

jizhi:addTest(function(room, me)
  local comp2 = room.players[2]
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, "ex__jizhi")
  end)

  local slash = Fk:getCardById(1)
  local god_salvation = room:printCard("god_salvation")

  FkTest.setNextReplies(me, { json.encode {
    card = 1,
    targets = { comp2.id }
  } })
  FkTest.setNextReplies(comp2, { "__cancel" })
  FkTest.runInRoom(function()
    room:moveCardTo({2, 3, 4, 5}, Card.DrawPile) -- 都是杀……吧？
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Play })):exec()
    -- room:useCard{
    --   from = me,
    --   tos = { comp2 },
    --   card = slash,
    -- }
  end)
  lu.assertEquals(#me:getCardIds("h"), 0)
  FkTest.setNextReplies(me, { json.encode {
    card = god_salvation.id
  }, "1", "__cancel" })
  FkTest.runInRoom(function()
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Play })):exec()
    -- room:useCard{
    --   from = me,
    --   tos = { comp2 },
    --   card = god_salvation,
    -- }
  end)
  lu.assertEquals(#me:getCardIds("h"), 1)

  FkTest.setNextReplies(me, { json.encode {
    card = god_salvation.id
  }, "1", "1" })
  FkTest.runInRoom(function()
    GameEvent.Phase:create(PhaseData:new{who = me, reason = "game_rule", phase = Player.Play}):exec()
    -- room:useCard{
    --   from = me,
    --   tos = { comp2 },
    --   card = god_salvation,
    -- }
  end)
  lu.assertEquals(#me:getCardIds("h"), 1)
  -- lu.assertEquals(me:getMaxCards(), me.hp + 1)
end)

return jizhi
