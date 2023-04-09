local extension = Package("standard_ex")

Fk:loadTranslationTable{
  ["standard_ex"] = "界标包",
  ["ex"] = "界",
}

local ex__jianxiong = fk.CreateTriggerSkill{
  name = "ex__jianxiong",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    local room = target.room
    return data.card ~= nil and
      target == player and
      target:hasSkill(self.name) and
      room:getCardArea(data.card) == Card.Processing and
      not target.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:obtainCard(player.id, data.card, false)
    player:drawCards(1)
  end,
}
local ex__caocao = General(extension, "ex__caocao", "wei", 4)
ex__caocao:addSkill(ex__jianxiong)
Fk:loadTranslationTable{
  ["ex__caocao"] = "界曹操",
  ["ex__jianxiong"] = "奸雄",
  [":ex__jianxiong"] = "当你受到伤害后，你可以获得对你造成伤害的牌并摸一张牌。",
}

local ex__guicai = fk.CreateTriggerSkill{
  name = "ex__guicai",
  anim_type = "control",
  events = {fk.AskForRetrial},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local prompt = "#guicai-ask::" .. target.id
    local card = room:askForResponse(player, self.name, ".", prompt, true)
    if card ~= nil then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:retrial(self.cost_data, player, data, self.name)
  end,
}
local ex__fankui = fk.CreateTriggerSkill{
  name = "ex__fankui",
  anim_type = "masochism",
  events = {fk.Damaged},
  frequency = Skill.NotFrequent,
  can_trigger = function(self, event, target, player, data)
    local room = target.room
    local from = data.from
    return from ~= nil and
      target == player and
      target:hasSkill(self.name) and
      (not from:isNude()) and
      not target.dead
  end,
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      if self.cancel_cost then break end
      if data.from:isNude() then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from
    local card = room:askForCardChosen(player, from, "he", self.name)
    room:obtainCard(player.id, card, false)
  end
}
local ex__simayi = General(extension, "ex__simayi", "wei", 3)
ex__simayi:addSkill(ex__guicai)
ex__simayi:addSkill(ex__fankui)
Fk:loadTranslationTable{
  ["ex__simayi"] = "界司马懿",
  ["ex__guicai"] = "鬼才",
  [":ex__guicai"] = "当判定牌生效之前，你可以打出一张牌代替之。",
  ["ex__fankui"] = "反馈",
  [":ex__fankui"] = "当你受到1点伤害后，你可以从伤害来源处获得一张牌。",
}

-- xiahoudun

local ex__tuxi = fk.CreateTriggerSkill{
  name = "ex__tuxi",
  anim_type = "control",
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    local ret = (target == player and player:hasSkill(self.name) and data.n > 0)
    if ret then
      local room = player.room
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if not p:isKongcheng() then
          return true
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local other = room:getOtherPlayers(player)
    local targets = {}
    for _, p in ipairs(other) do
      if not p:isKongcheng() then
        table.insert(targets, p.id)
      end
    end

    local result = room:askForChoosePlayers(player, targets, 1, data.n, "#ex-tuxi-ask", self.name)
    if #result > 0 then
      self.cost_data = result
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, id in ipairs(self.cost_data) do
      local p = room:getPlayerById(id)
      local c = room:askForCardChosen(player, p, "h", self.name)
      room:obtainCard(player.id, c, false)
    end
    data.n = data.n - #self.cost_data
  end,
}
local ex__zhangliao = General(extension, "ex__zhangliao", "wei", 4)
ex__zhangliao:addSkill(ex__tuxi)
Fk:loadTranslationTable{
  ["ex__zhangliao"] = "界张辽",
  ["ex__tuxi"] = "突袭",
  [":ex__tuxi"] = "摸牌阶段，你可以少摸任意张牌并获得等量其他角色各一张手牌。",
  ["#ex-tuxi-ask"] = "突袭：你可以少摸任意张牌，获得等量其他角色的手牌",
}

local ex__zhiheng = fk.CreateActiveSkill{
  name = "ex__zhiheng",
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0
  end,
  target_num = 0,
  min_card_num = 1,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local hand = from:getCardIds(Player.Hand)
    local more = #hand > 0
    for _, id in ipairs(hand) do
      if not table.contains(effect.cards, id) then
        more = false
        break
      end
    end

    room:throwCard(effect.cards, self.name, from)
    room:drawCards(from, #effect.cards + (more and 1 or 0), self.name)
  end
}
local ex__sunquan = General:new(extension, "ex__sunquan", "wu", 4)
ex__sunquan:addSkill(ex__zhiheng)

Fk:loadTranslationTable{
  ["ex__sunquan"] = "界孙权",
  ["ex__zhiheng"] = "制衡",
  [":ex__zhiheng"] = "出牌阶段限一次，你可以弃置任意张牌并摸等量的牌。"
    .. "若你以此法弃置了所有的手牌，你多摸一张牌。",
}

local ex__huanggai = General(extension, "ex__huanggai", "wu", 4)
local ex__kurou = fk.CreateActiveSkill{
  name = "ex__kurou",
  anim_type = "negative",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0
  end,
  target_num = 0,
  card_num = 1,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, from)
    room:loseHp(from, 1, self.name)
  end
}
ex__huanggai:addSkill(ex__kurou)
local zhaxiangBuff = fk.CreateTargetModSkill{
  name = "#zhaxiangBuff",
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and scope == Player.HistoryPhase then
      return player.phase ~= Player.NotActive and player:usedSkillTimes("zhaxiang")
    end
  end,
}
local zhaxiangHit = fk.CreateTriggerSkill{
  name = "#zhaxiangHit",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      data.card.trueName == "slash" and data.card.color == Card.Red and
      player.phase ~= Player.NotActive and player:usedSkillTimes("zhaxiang") > 0
  end,
  on_use = function(self, event, target, player, data)
    data.disresponsive = true
  end,
}
local zhaxiang = fk.CreateTriggerSkill{
  name = "zhaxiang",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.HpLost},
  on_trigger = function(self, event, target, player, data)
    for i = 1, data.num do
      self:doCost(event, target, player, data)
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(3)
  end,
}
zhaxiang:addRelatedSkill(zhaxiangBuff)
zhaxiang:addRelatedSkill(zhaxiangHit)
ex__huanggai:addSkill(zhaxiang)
Fk:loadTranslationTable{
  ["ex__huanggai"] = "界黄盖",
  ["ex__kurou"] = "苦肉",
  [":ex__kurou"] = "出牌阶段限一次，你可以弃置一张牌并失去一点体力。",
  ["zhaxiang"] = "诈降",
  [":zhaxiang"] = "锁定技，每当你失去1点体力，你摸三张牌，若这是你回合内，你可以多使用一张杀且红色的杀不可闪避。",
  ["#zhaxiangHit"] = "诈降",
}

local exYingziMaxCards = fk.CreateMaxCardsSkill{
  name = "#exYingziMaxCards",
  fixed_func = function(self, player)
    if player:hasSkill(self.name) then
      return player.maxHp
    end
  end
}
local ex__yingzi = fk.CreateTriggerSkill{
  name = "ex__yingzi",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards},
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,
}
ex__yingzi:addRelatedSkill(exYingziMaxCards)
local ex__fanjian = fk.CreateActiveSkill{
  name = "ex__fanjian",
  anim_type = "control",
  target_num = 1,
  card_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) < 1 and not player:isNude()
  end,
  card_filter = function(self, _, selected)
    return #selected == 0
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:obtainCard(target.id, effect.cards[1])

    local choice = room:askForChoice(target, { "exfj_showhandcards", "lose1hp" }, self.name)
    if choice == "lose1hp" then
      room:loseHp(target, 1, self.name)
    else
      local cards = target:getCardIds(Player.Hand)
      target:showCards(cards)
      local suit = Fk:getCardById(effect.cards[1]).suit
      local discards = table.filter(target:getCardIds({ Player.Hand, Player.Equip }), function(id)
        return Fk:getCardById(id).suit == suit
      end)
      room:throwCard(discards, self.name, target)
    end
  end,
}
local ex__zhouyu = General(extension, "ex__zhouyu", "wu", 3)
ex__zhouyu:addSkill(ex__yingzi)
ex__zhouyu:addSkill(ex__fanjian)
Fk:loadTranslationTable{
  ["ex__zhouyu"] = "界周瑜",
  ["ex__yingzi"] = "英姿",
  [":ex__yingzi"] = "锁定技，摸牌阶段，你多摸一张牌；你的手牌上限等同于你的体力上限。",
  ["ex__fanjian"] = "反间",
  [":ex__fanjian"] = "出牌阶段限一次，你可以交给一名其他角色一张牌，然后其选择：1. 展示所有手牌，然后弃置花色和你交给的牌的花色相同的所有牌； 2. 失去1点体力。",
  ["exfj_showhandcards"] = "展示手牌并弃牌",
  ["lose1hp"] = "失去1点体力",
}

return extension
