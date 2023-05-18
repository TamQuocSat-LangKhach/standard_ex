local extension = Package("standard_ex")

Fk:loadTranslationTable{
  ["standard_ex"] = "界标包",
  ["ex"] = "界",
}

local ex__caocao = General(extension, "ex__caocao", "wei", 4)
local ex__jianxiong = fk.CreateTriggerSkill{
  name = "ex__jianxiong",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    local room = target.room
    return target == player and player:hasSkill(self.name) and data.card and room:getCardArea(data.card) == Card.Processing
  end,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(player.id, data.card, true, fk.ReasonJustMove)
    player:drawCards(1, self.name)
  end,
}
ex__caocao:addSkill(ex__jianxiong)
Fk:loadTranslationTable{
  ["ex__caocao"] = "界曹操",
  ["ex__jianxiong"] = "奸雄",
  [":ex__jianxiong"] = "当你受到伤害后，你可以获得对你造成伤害的牌并摸一张牌。",
}

local ex__simayi = General(extension, "ex__simayi", "wei", 3)
local ex__guicai = fk.CreateTriggerSkill{
  name = "ex__guicai",
  anim_type = "control",
  events = {fk.AskForRetrial},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForResponse(player, self.name, ".", "#guicai-ask::" .. target.id, true)
    if card ~= nil then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:retrial(self.cost_data, player, data, self.name)
  end,
}
local ex__fankui = fk.CreateTriggerSkill{
  name = "ex__fankui",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.from and not data.from.dead and not data.from:isNude()
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
    local card = room:askForCardChosen(player, data.from, "he", self.name)
    room:obtainCard(player, card, false, fk.ReasonPrey)
  end
}
ex__simayi:addSkill(ex__guicai)
ex__simayi:addSkill(ex__fankui)
Fk:loadTranslationTable{
  ["ex__simayi"] = "界司马懿",
  ["ex__guicai"] = "鬼才",
  [":ex__guicai"] = "当判定牌生效之前，你可以打出一张牌代替之。",
  ["ex__fankui"] = "反馈",
  [":ex__fankui"] = "当你受到1点伤害后，你可以从伤害来源处获得一张牌。",
}

--夏侯惇

local ex__zhangliao = General(extension, "ex__zhangliao", "wei", 4)
local ex__tuxi = fk.CreateTriggerSkill{
  name = "ex__tuxi",
  anim_type = "control",
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.n > 0 and
      not table.every(player.room:getOtherPlayers(player), function(p) return p:isKongcheng() end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
      return not p:isKongcheng() end), function (p) return p.id end)
    local tos = room:askForChoosePlayers(player, targets, 1, data.n, "#ex__tuxi-choose:::"..data.n, self.name, true)
    if #tos > 0 then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, id in ipairs(self.cost_data) do
      local c = room:askForCardChosen(player, room:getPlayerById(id), "h", self.name)
      room:obtainCard(player, c, false, fk.ReasonPrey)
    end
    data.n = data.n - #self.cost_data
  end,
}
ex__zhangliao:addSkill(ex__tuxi)
Fk:loadTranslationTable{
  ["ex__zhangliao"] = "界张辽",
  ["ex__tuxi"] = "突袭",
  [":ex__tuxi"] = "摸牌阶段，你可以少摸任意张牌并获得等量其他角色各一张手牌。",
  ["#ex__tuxi-choose"] = "突袭：你可以少至多%arg张牌，获得等量其他角色各一张手牌",
}

--许褚
--郭嘉
local lidian = General(extension, "lidian", "wei", 3)
local xunxun = fk.CreateTriggerSkill{
  name = "xunxun",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    player.room:askForGuanxing(player, player.room:getNCards(4), {2, 2}, {2, 2})
  end,
}
local wangxi = fk.CreateTriggerSkill{
  name = "wangxi",
  anim_type = "masochism",
  events = {fk.Damage, fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.from and data.from ~= data.to and not (data.from.dead or data.to.dead)
  end,
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      if self.cancel_cost then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local prompt
    if event == fk.Damage then
      prompt = "#wangxi-invoke::"..data.to.id
    else
      prompt = "#wangxi-invoke::"..data.from.id
    end
    return player.room:askForSkillInvoke(player, self.name, nil, prompt)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
    if event == fk.Damage then
      data.to:drawCards(1, self.name)
    else
      data.from:drawCards(1, self.name)
    end
  end
}
lidian:addSkill(xunxun)
lidian:addSkill(wangxi)
Fk:loadTranslationTable{
  ["lidian"] = "李典",
  ["xunxun"] = "恂恂",
  [":xunxun"] = "摸牌阶段开始时，你可以观看牌堆顶的四张牌，将其中两张牌以任意顺序置于牌堆顶，其余以任意顺序置于牌堆底。",
  ["wangxi"] = "忘隙",
  [":wangxi"] = "当你对其他角色造成1点伤害后，或当你受到其他角色造成的1点伤害后，你可以与该角色各摸一张牌。",
  ["#wangxi-invoke"] = "忘隙：你可以与 %dest 各摸一张牌",
}

local ex__sunquan = General(extension, "ex__sunquan", "wu", 4)
local ex__zhiheng = fk.CreateActiveSkill{
  name = "ex__zhiheng",
  anim_type = "drawcard",
  min_card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0
  end,
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
    room:throwCard(effect.cards, self.name, from, from)
    room:drawCards(from, #effect.cards + (more and 1 or 0), self.name)
  end
}
ex__sunquan:addSkill(ex__zhiheng)
Fk:loadTranslationTable{
  ["ex__sunquan"] = "界孙权",
  ["ex__zhiheng"] = "制衡",
  [":ex__zhiheng"] = "出牌阶段限一次，你可以弃置任意张牌并摸等量的牌。若你以此法弃置了所有的手牌，你多摸一张牌。",
}

--甘宁
--吕蒙

local ex__huanggai = General(extension, "ex__huanggai", "wu", 4)
local ex__kurou = fk.CreateActiveSkill{
  name = "ex__kurou",
  anim_type = "negative",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, from, from)
    room:loseHp(from, 1, self.name)
  end
}
local zhaxiang_targetmod = fk.CreateTargetModSkill{
  name = "#zhaxiang_targetmod",
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and scope == Player.HistoryPhase and
      player.phase == Player.Play and player:usedSkillTimes("zhaxiang", Player.HistoryPhase) > 0 then
      return 1
    end
    return 0
  end,
  distance_limit_func =  function(self, player, skill, card)
    if skill.trueName == "slash_skill" and card.color == Card.Red and player:usedSkillTimes("zhaxiang", Player.HistoryPhase) > 0 then
      return 999
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
      player.phase  == Player.Play and player:usedSkillTimes("zhaxiang", Player.HistoryPhase) > 0
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
zhaxiang:addRelatedSkill(zhaxiang_targetmod)
zhaxiang:addRelatedSkill(zhaxiangHit)
ex__huanggai:addSkill(ex__kurou)
ex__huanggai:addSkill(zhaxiang)
Fk:loadTranslationTable{
  ["ex__huanggai"] = "界黄盖",
  ["ex__kurou"] = "苦肉",
  [":ex__kurou"] = "出牌阶段限一次，你可以弃置一张牌并失去一点体力。",
  ["zhaxiang"] = "诈降",
  [":zhaxiang"] = "锁定技，每当你失去1点体力，你摸三张牌，然后若此时是你的出牌阶段，"..
  "则此阶段你使用【杀】次数上限+1、使用红色【杀】无距离限制且不可被响应。",
  ["#zhaxiangHit"] = "诈降",
}

local ex__zhouyu = General(extension, "ex__zhouyu", "wu", 3)
local ex__yingzi = fk.CreateTriggerSkill{
  name = "ex__yingzi",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards},
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,
}
local ex__yingzi_maxcards = fk.CreateMaxCardsSkill{
  name = "#ex__yingzi_maxcards",
  fixed_func = function(self, player)
    if player:hasSkill(self.name) then
      return player.maxHp
    end
  end
}
local ex__fanjian = fk.CreateActiveSkill{
  name = "ex__fanjian",
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, _, selected)
    return #selected == 0
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    room:obtainCard(target.id, effect.cards[1], false, fk.ReasonGive)
    local choice = room:askForChoice(target, { "ex__fanjian_show", "loseHp" }, self.name)
    if choice == "loseHp" then
      room:loseHp(target, 1, self.name)
    else
      local cards = target:getCardIds(Player.Hand)
      target:showCards(cards)
      local suit = Fk:getCardById(effect.cards[1]).suit
      local discards = table.filter(target:getCardIds({ Player.Hand, Player.Equip }), function(id)
        return Fk:getCardById(id).suit == suit
      end)
      room:throwCard(discards, self.name, target, target)
    end
  end,
}
ex__yingzi:addRelatedSkill(ex__yingzi_maxcards)
ex__zhouyu:addSkill(ex__yingzi)
ex__zhouyu:addSkill(ex__fanjian)
Fk:loadTranslationTable{
  ["ex__zhouyu"] = "界周瑜",
  ["ex__yingzi"] = "英姿",
  [":ex__yingzi"] = "锁定技，摸牌阶段，你多摸一张牌；你的手牌上限等同于你的体力上限。",
  ["ex__fanjian"] = "反间",
  [":ex__fanjian"] = "出牌阶段限一次，你可以交给一名其他角色一张牌，然后其选择：1.展示所有手牌，然后弃置花色和你交给的牌的花色相同的所有牌；2.失去1点体力。",
  ["ex__fanjian_show"] = "展示手牌，然后弃置所有花色相同的牌",
}

local ex__daqiao = General(extension, "ex__daqiao", "wu", 3, 3, General.Female)
local ex__guose = fk.CreateActiveSkill{
  name = "ex__guose",
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).suit == Card.Diamond
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    if #selected == 0 and #selected_cards > 0 then
      local target = Fk:currentRoom():getPlayerById(to_select)
      local card = Fk:cloneCard("indulgence")
      card:addSubcard(selected_cards[1])
      return target:hasDelayedTrick("indulgence") or (to_select ~= Self.id and not Self:isProhibited(target, card))
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    if target:hasDelayedTrick("indulgence") then
      room:throwCard(effect.cards, self.name, player, player)
      for _, id in ipairs(target.player_cards[Player.Judge]) do
        local card = target:getVirualEquip(id)
        if not card then card = Fk:getCardById(id) end
        if card.name == "indulgence" then
          room:throwCard({id}, self.name, target, player)
        end
      end
    else
      room:useVirtualCard("indulgence", effect.cards, player, target, self.name)
    end
    player:drawCards(1, self.name)
  end,
}
ex__daqiao:addSkill(ex__guose)
ex__daqiao:addSkill("liuli")
Fk:loadTranslationTable{
  ["ex__daqiao"] = "界大乔",
  ["ex__guose"] = "国色",
  [":ex__guose"] = "出牌阶段限一次，你可以选择一项：1.将一张<font color='red'>♦</font>牌当【乐不思蜀】使用；"..
  "2.弃置一张<font color='red'>♦</font>牌并弃置场上的一张【乐不思蜀】。选择完成后，你摸一张牌。",
}
--陆逊

--华佗
local ex__huatuo = General(extension, "ex__huatuo", "qun", 3)
local chuli = fk.CreateActiveSkill{
  name = "chuli",
  anim_type = "control",
  card_num = 0,
  min_target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return to_select ~= Self.id and not target:isNude() and
      table.every(selected, function(id) return target.kingdom ~= Fk:currentRoom():getPlayerById(id).kingdom end)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    table.insert(effect.tos, 1, effect.from)
    for _, id in ipairs(effect.tos) do
      local target = room:getPlayerById(id)
      local c = room:askForCardChosen(player, target, "he", self.name)
      room:throwCard({c}, self.name, target, player)
      if Fk:getCardById(c).suit == Card.Spade then
        room:addPlayerMark(target, self.name, 1)
      end
    end
    for _, id in ipairs(effect.tos) do
      local target = room:getPlayerById(id)
      if target:getMark(self.name) > 0 then
        room:setPlayerMark(target, self.name, 0)
        target:drawCards(1, self.name)
      end
    end
  end,
}
ex__huatuo:addSkill("jijiu")
ex__huatuo:addSkill(chuli)
Fk:loadTranslationTable{
  ["ex__huatuo"] = "界华佗",
  ["chuli"] = "除疠",
  [":chuli"] = "出牌阶段限一次，你可以选择任意名势力各不相同的其他角色，然后你弃置你和这些角色的各一张牌。被弃置♠牌的角色各摸一张牌。",
}
--吕布
--貂蝉
--华雄
--袁术
--公孙瓒

return extension
