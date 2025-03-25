Fk:loadTranslationTable{
  ["ex__ganglie"] = "刚烈",
  [":ex__ganglie"] = "当你受到1点伤害后，你可判定，若结果为：红色，你对来源造成1点伤害；黑色，你弃置来源的一张牌。",

  ["#ex__ganglie-invoke"] = "是否对%dest发动 刚烈，判红对其造成伤害，判黑弃其牌",

  ["$ex__ganglie1"] = "哪个敢动我！",
  ["$ex__ganglie2"] = "伤我者，十倍奉还！",
}

local skill = fk.CreateSkill{
  name = "ex__ganglie",
}

skill:addEffect(fk.Damaged, {
  anim_type = "masochism",
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      if i > 1 and (self.cancel_cost or not player:hasSkill(skill.name)) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if data.from and not data.from.dead then
      if room:askToSkillInvoke(player, { skill_name = skill.name, prompt = "#ex__ganglie-invoke::"..data.from.id }) then
        room:doIndicate(player.id, {data.from.id})
        return true
      end
    else
      if room:askToSkillInvoke(player, { skill_name = skill.name }) then
        return true
      end
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from
    if from and not from.dead then room:doIndicate(player.id, {from.id}) end
    local judge = {
      who = player,
      reason = skill.name,
      pattern = ".",
    }
    room:judge(judge)
    if not from or from.dead then return false end
    if judge.card.color == Card.Red then
      room:damage{
        from = player,
        to = from,
        damage = 1,
        skillName = skill.name,
      }
    elseif judge.card.color == Card.Black and not from:isNude() then
      local cid = room:askToChooseCard(player, { target = from, flag = "he", skill_name = skill.name })
      room:throwCard({cid}, skill.name, from, player)
    end
  end
})

return skill
