Fk:loadTranslationTable{
  ["ex__qicai"] = "奇才",
  [":ex__qicai"] = "锁定技，你使用锦囊牌无距离限制；你装备区的宝物牌和防具牌不能被其他角色弃置。",

  ["#cancelDismantle"] = "由于 %arg 的效果，%card 的弃置被取消",
}

local ex__qicai = fk.CreateSkill{
  name = "ex__qicai",
  tag = { Skill.Compulsory },
}

ex__qicai:addEffect('targetmod', {
  bypass_distances = function(self, player, skill, card)
    return player:hasSkill(ex__qicai.name) and card and card.type == Card.TypeTrick
  end,
}):addEffect(fk.BeforeCardsMove, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(ex__qicai.name) or
      (#player:getEquipments(Card.SubtypeArmor) == 0 and #player:getEquipments(Card.SubtypeTreasure) == 0) then return false end
    for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonDiscard and move.proposer ~= player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip and
            table.contains({Card.SubtypeArmor, Card.SubtypeTreasure}, Fk:getCardById(info.cardId).sub_type) then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local ids = {}
    for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonDiscard and move.proposer ~= player.id then
        local move_info = {}
        for _, info in ipairs(move.moveInfo) do
          local id = info.cardId
          if info.fromArea == Card.PlayerEquip and
            table.contains({Card.SubtypeArmor, Card.SubtypeTreasure}, Fk:getCardById(id).sub_type) then
            table.insert(ids, id)
          else
            table.insert(move_info, info)
          end
        end
        if #ids > 0 then
          move.moveInfo = move_info
        end
      end
    end
    if #ids > 0 then
      player.room:sendLog{
        type = "#cancelDismantle",
        card = ids,
        arg = ex__qicai.name,
      }
    end
  end,
})

return ex__qicai
