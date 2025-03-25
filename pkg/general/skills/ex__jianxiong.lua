local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["ex__jianxiong"] = "奸雄",
  [":ex__jianxiong"] = "当你受到伤害后，你可以获得对你造成伤害的牌并摸一张牌。",

  ["$ex__jianxiong1"] = "燕雀，安知鸿鹄之志！",
  ["$ex__jianxiong2"] = "夫英雄者，胸怀大志，腹有良谋！",
}

local skill = fk.CreateSkill{
  name = "ex__jianxiong",
}

skill:addEffect(fk.Damaged, {
  anim_type = "masochism",
  on_use = function(self, event, target, player, data)
    if data.card and U.hasFullRealCard(player.room, data.card) then
      player.room:obtainCard(player.id, data.card, true, fk.ReasonJustMove)
    end
    player:drawCards(1, skill.name)
  end,
})

skill:addTest(function(room, me)
  local comp2 = room.players[2] ---@type ServerPlayer, ServerPlayer
  FkTest.runInRoom(function() room:handleAddLoseSkills(me, skill.name) end)

  local slash = Fk:getCardById(1)
  FkTest.setNextReplies(me, { "__cancel", "1" })
  FkTest.runInRoom(function()
    room:useCard{
      from = comp2,
      tos = { me },
      card = slash,
    }
  end)
  -- p(me:toJsonObject())
  lu.assertEquals(me:getCardIds("h")[1], 1)
  lu.assertEquals(#me:getCardIds("h"), 2)
end)

return skill
