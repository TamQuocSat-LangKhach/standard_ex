local extension = Package("standard_ex")

Fk:loadTranslationTable{
  ["standard_ex"] = "界标包",
  ["ex"] = "界",
   ["bz"] = "标",
}

local caocao = General(extension, "ex__caocao", "wei", 4)
local ex__jianxiong = fk.CreateTriggerSkill{
  name = "ex__jianxiong",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) 
  end,
  on_use = function(self, event, target, player, data)
    if data.card and target.room:getCardArea(data.card) == Card.Processing then
      player.room:obtainCard(player.id, data.card, true, fk.ReasonJustMove)
    end
     player:drawCards(1, self.name)
  end,
}
caocao:addSkill(ex__jianxiong)
caocao:addSkill("hujia")
Fk:loadTranslationTable{
  ["ex__caocao"] = "界曹操",
  ["ex__jianxiong"] = "奸雄",
  [":ex__jianxiong"] = "当你受到伤害后，你可以获得对你造成伤害的牌并摸一张牌。",
  ["$ex__jianxiong1"] = "燕雀，安知鸿鹄之志!",
  ["$ex__jianxiong2"] = "夫英雄者，胸怀大志，腹有良谋!",
  ["~ex__caocao"] = "华佗何在?.....",
}

local simayi = General(extension, "ex__simayi", "wei", 3)
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
simayi:addSkill(ex__guicai)
simayi:addSkill(ex__fankui)
Fk:loadTranslationTable{
  ["ex__simayi"] = "界司马懿",
  ["ex__guicai"] = "鬼才",
  [":ex__guicai"] = "当判定牌生效之前，你可以打出一张牌代替之。",
  ["ex__fankui"] = "反馈",
  [":ex__fankui"] = "当你受到1点伤害后，你可以从伤害来源处获得一张牌。",
}

--夏侯惇

local zhangliao = General(extension, "ex__zhangliao", "wei", 4)
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
zhangliao:addSkill(ex__tuxi)
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

local sunquan = General(extension, "ex__sunquan", "wu", 4)
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
sunquan:addSkill(ex__zhiheng)
sunquan:addSkill("jiuyuan")
Fk:loadTranslationTable{
  ["ex__sunquan"] = "界孙权",
  ["ex__zhiheng"] = "制衡",
  [":ex__zhiheng"] = "出牌阶段限一次，你可以弃置任意张牌并摸等量的牌。若你以此法弃置了所有的手牌，你多摸一张牌。",
  ["$ex__zhiheng1"] = "不急不躁，稳谋应对!",
  ["$ex__zhiheng2"] = "制衡互牵，大局可安!",
  ["~ex__sunquan"] = "锦绣江东，岂能失于我手.....",
}

local ganning = General(extension, "ex__ganning", "wu", 4)
local fenwei = fk.CreateTriggerSkill{
  name = "fenwei",
  anim_type = "defensive",
  frequency = Skill.Limited,
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and data.card.type == Card.TypeTrick and #AimGroup:getAllTargets(data.tos) > 1 and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local tos = player.room:askForChoosePlayers(player, AimGroup:getAllTargets(data.tos),
      1, 10, "#fenwei-choose:::"..data.card:toLogString(), self.name, true)
    if #tos > 0 then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    table.insertTable(data.nullifiedTargets, self.cost_data)
  end,
}
ganning:addSkill("qixi")
ganning:addSkill(fenwei)
Fk:loadTranslationTable{
  ["ex__ganning"] = "界甘宁",
  ["fenwei"] = "奋威",
  [":fenwei"] = "限定技，当一张锦囊牌指定多个目标后，你可令此牌对其中任意个目标无效。",
  ["#fenwei-choose"] = "奋威：你可以令此%arg对任意个目标无效",
}

local lvmeng = General(extension, "ex__lvmeng", "wu", 4)
local qinxue = fk.CreateTriggerSkill{
  name = "qinxue",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player.phase == Player.Start and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return (#player.player_cards[Player.Hand] - player.hp > 2) or
      (#player.room:getAllPlayers() > 7 and #player.player_cards[Player.Hand] - player.hp > 1)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    room:handleAddLoseSkills(player, "gongxin", nil)
  end,
}
lvmeng:addSkill("keji")
lvmeng:addSkill(qinxue)
lvmeng:addRelatedSkill("gongxin")
Fk:loadTranslationTable{
  ["ex__lvmeng"] = "界吕蒙",
  ["qinxue"] = "勤学",
  [":qinxue"] = "觉醒技，准备阶段，若你的手牌数比体力值多3或更多（游戏人数大于7则改为2），你减1点体力上限，然后获得技能〖攻心〗。",
}

local huanggai = General(extension, "ex__huanggai", "wu", 4)
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
      return player:usedSkillTimes("zhaxiang", Player.HistoryPhase)
    end
    return 0
  end,
  distance_limit_func =  function(self, player, skill, card)
    if skill.trueName == "slash_skill" and card.color == Card.Red and player:usedSkillTimes("zhaxiang", Player.HistoryPhase) > 0 then
      return 999
    end
  end,
}
local zhaxiang_trigger = fk.CreateTriggerSkill{
  name = "#zhaxiang_trigger",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      data.card.trueName == "slash" and data.card.color == Card.Red and player:usedSkillTimes("zhaxiang", Player.HistoryPhase) > 0
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
zhaxiang:addRelatedSkill(zhaxiang_trigger)
huanggai:addSkill(ex__kurou)
huanggai:addSkill(zhaxiang)
Fk:loadTranslationTable{
  ["ex__huanggai"] = "界黄盖",
  ["ex__kurou"] = "苦肉",
  [":ex__kurou"] = "出牌阶段限一次，你可以弃置一张牌并失去一点体力。",
  ["zhaxiang"] = "诈降",
  [":zhaxiang"] = "锁定技，每当你失去1点体力，你摸三张牌，然后若此时是你的出牌阶段，"..
  "则此阶段你使用【杀】次数上限+1、使用红色【杀】无距离限制且不可被响应。",
  ["#zhaxiangHit"] = "诈降",
  ["$ex__kurou1"] = "我这把老骨头，不算什么!",
  ["$ex__kurou2"] = "未成大业，死不足惜!",
  ["$ex__zhaxiang1"] = "铁锁连舟而行，东吴水师可破!",
  ["$ex__zhaxiang2"] = "两军阵前，不斩降将!",
  ["~ex__huanggai"] = "盖，有负公瑾重托.....",
}

local zhouyu = General(extension, "ex__zhouyu", "wu", 3)
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
zhouyu:addSkill(ex__yingzi)
zhouyu:addSkill(ex__fanjian)
Fk:loadTranslationTable{
  ["ex__zhouyu"] = "界周瑜",
  ["ex__yingzi"] = "英姿",
  [":ex__yingzi"] = "锁定技，摸牌阶段，你多摸一张牌；你的手牌上限等同于你的体力上限。",
  ["ex__fanjian"] = "反间",
  [":ex__fanjian"] = "出牌阶段限一次，你可以交给一名其他角色一张牌，然后其选择：1.展示所有手牌，然后弃置花色和你交给的牌的花色相同的所有牌；2.失去1点体力。",
  ["ex__fanjian_show"] = "展示手牌，然后弃置所有花色相同的牌",
  ["$ex__yingzi1"] = "哈哈哈哈...!",
  ["$ex__yingzi2"] = "伯符，且看我这一手!",
  ["$ex__fanjian1"] = "与我为敌，就当这般生不如死!",
  ["$ex__fanjian2"] = "抉择吧! 在苦与痛的地狱中!",
  ["~ex__zhouyu"] = "既生瑜，何生亮!..既生瑜，何生亮..!",
}
local sunshangxiang = General(extension, "ex__sunshangxiang", "wu", 3, 3, General.Female)
local ex__jieyin = fk.CreateActiveSkill{
  name = "ex__jieyin",
  anim_type = "support",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected ==0
  end,
  target_filter = function(self, to_select, selected, cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
     if #cards == 1 and Fk:getCardById(cards[1]).type ~= Card.TypeEquip then
       return target.gender == General.Male and #selected == 0
     else 
       return #selected == 0 and #cards == 1 and Fk:currentRoom():getPlayerById(to_select):getEquipment(Fk:getCardById(cards[1]).sub_type) == nil and target.gender == General.Male
     end
  end,
  target_num = 1,
  card_num = 1,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local tos = room:getPlayerById(effect.tos[1])
    if Fk:getCardById(effect.cards[1]).type == Card.TypeEquip then
      room:moveCards({
        ids = effect.cards,
       from = effect.from,
       to = effect.tos[1],
        toArea = Card.PlayerEquip,
       moveReason = fk.ReasonPut,
      })
    else  
      room:throwCard(effect.cards, self.name, from)
    end
    if tos.hp < from.hp then
      if tos:isWounded() then
         room:recover({
           who = tos,
           num = 1,
           recoverBy = tos,
           skillName = self.name
         })  
      end
     from:drawCards(1, self.name)    
    else
      if from:isWounded() then
        room:recover({
          who = from,
         num = 1,
         recoverBy = from,
         skillName = self.name
        }) 
      end
      tos:drawCards(1, self.name)
    end
  end,
}
sunshangxiang:addSkill(ex__jieyin)
sunshangxiang:addSkill("xiaoji")
Fk:loadTranslationTable{
  ["ex__sunshangxiang"] = "界孙尚香",
  ["ex__jieyin"] = "结姻",
  [":ex__jieyin"] = "出牌阶段限一次，你可以弃置一张牌选择一名其他男性角色或者将一张装备牌置入一名其他男性角色的装备区，然后你与其体力值较少的角色恢复一点体力，较多的角色摸一张牌。",
  ["$ex__jieyin1"] = "随夫嫁娶，宜室宜家!",
  ["$ex__jieyin2"] = "得遇夫君，妾身福分!",
  ["~ex__sunshangxiang"] = "就这样... 结束了吗.....",
}
local daqiao = General(extension, "ex__daqiao", "wu", 3, 3, General.Female)
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
daqiao:addSkill(ex__guose)
daqiao:addSkill("liuli")
Fk:loadTranslationTable{
  ["ex__daqiao"] = "界大乔",
  ["ex__guose"] = "国色",
  [":ex__guose"] = "出牌阶段限一次，你可以选择一项：1.将一张<font color='red'>♦</font>牌当【乐不思蜀】使用；"..
  "2.弃置一张<font color='red'>♦</font>牌并弃置场上的一张【乐不思蜀】。选择完成后，你摸一张牌。",
}
--陆逊

--华佗
local huatuo = General(extension, "ex__huatuo", "qun", 3)
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
huatuo:addSkill("jijiu")
huatuo:addSkill(chuli)
Fk:loadTranslationTable{
  ["ex__huatuo"] = "界华佗",
  ["chuli"] = "除疠",
  [":chuli"] = "出牌阶段限一次，你可以选择任意名势力各不相同的其他角色，然后你弃置你和这些角色的各一张牌。被弃置♠牌的角色各摸一张牌。",
}
--吕布
--貂蝉
local ex__biyue = fk.CreateTriggerSkill{
  name = "ex__biyue",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
      and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(player:isKongcheng() and 2 or 1, self.name)
  end,
}
local diaochan = General:new(extension, "ex__diaochan", "qun", 3, 3, General.Female)
diaochan:addSkill("lijian")
diaochan:addSkill(ex__biyue)
Fk:loadTranslationTable{
  ["ex__diaochan"] = "界貂蝉",
  ["ex__biyue"] = "闭月",
  [":ex__biyue"] = "回合结束时，你可以摸一张牌，若你没有手牌则改为两张。",
}
--华雄
local yaowu = fk.CreateTriggerSkill{
  name = "yaowu",
  anim_type = "negative",
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
     if data.chain then return end
    return target == player and player:hasSkill(self.name) and data.card and data.card.trueName == "slash" and data.card.color == Card.Red and data.from ~= nil
  end,
   on_cost = function(self, event, target, player, data)
    local room = player.room
    local from = data.from
    local choices = {"draw1", "Cancel"}
    if from:isWounded() then
      table.insert(choices, 2, "recover")
    end
       self.cost_data = room:askForChoice(from, choices, self.name) return self.cost_data ~= "Cancel"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from
    if self.cost_data == "recover" then
      room:recover({
        who = from,
        num = 1,
        recoverBy = from,
        skillName = self.name
      })
    elseif self.cost_data == "draw1" then
      from:drawCards(1, self.name)
    end
  end,
  
  refresh_events = {fk.DamageInflicted},
  can_refresh = function(self, event, target, player, data)
     return target == player and player:hasSkill(self.name) and data.card.trueName == "slash" and data.card.color ~= Card.Red
  end,
  on_refresh = function(self, event, target, player, data)
    
   player:drawCards(1, self.name)
  end,
}
local huaxiong = General(extension, "bz__huaxiong", "qun", 6)
huaxiong:addSkill(yaowu)
Fk:loadTranslationTable{
  ["bz__huaxiong"] = "华雄",
  ["yaowu"] = "耀武",
  [":yaowu"] = "锁定技，当你因受到杀造成的伤害时，若此杀为红色，伤害来源可以回复一点体力或摸一张牌;不为红色，你摸一张牌。",
}
local ex__yaowu = fk.CreateTriggerSkill{
  name = "ex__yaowu",
  anim_type = "negative",
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
     return target == player and player:hasSkill(self.name) and data.card ~= nil
  end,
  on_use = function(self, event, target, player, data)
    if data.card.color ~= Card.Red or not data.card.color then
      player:drawCards(1, self.name)
    else 
      if data.from ~= nil then
         data.from:drawCards(1, self.name)
      end
    end
  end,
}
local ex__shizhan = fk.CreateActiveSkill{
  name = "ex__shizhan",
  anim_type = "support",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) < 2
  end,
  card_filter = function() return false end,
  target_filter = function(self, to_select, selected, cards)
    return #selected == 0 
  end,
  target_num = 1,
  on_use = function(self, room, use)
    local duel = Fk:cloneCard("duel")
    duel.skillName = self.name
    local new_use = {} ---@type CardUseStruct
    new_use.from = use.tos[1]
    new_use.tos = { { use.from } }
    new_use.card = duel
    room:useCard(new_use)
  end,
}
local huaxiong = General(extension, "ex__huaxiong", "qun", 6)
huaxiong:addSkill(ex__yaowu)
huaxiong:addSkill(ex__shizhan)
Fk:loadTranslationTable{
  ["ex__huaxiong"] = "界华雄",
  ["ex__yaowu"] = "耀武",
  [":ex__yaowu"] = "锁定技，当你受到伤害时，若造成伤害的牌为红色，伤害来源摸一张牌。;若不为红色，你摸一张牌。",
  ["ex__shizhan"] = "势斩",
  [":ex__shizhan"] = "出牌阶段限两次，你可以选择一名其他角色，然后其视为对你使用一张【决斗】。",
}
--袁术
--公孙瓒
--蜀国
local ex__tieji = fk.CreateTriggerSkill{
  name = "ex__tieji",
  anim_type = "offensive",
  events = {fk.TargetSpecifying},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    room:addPlayerMark(to, "@@tieji-turn")
    room:addPlayerMark(to, MarkEnum.UncompulsoryInvalidity .. "-turn")
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".|.|spade,club,heart,diamond",
    }
    room:judge(judge)
    if judge.card.suit ~= nil then
        local suits = {}
        table.insert(suits, judge.card:getSuitString())
      if #room:askForDiscard(to, 1, 1, false, self.name, true, ".|.|"..table.concat(suits, ","), "#ex__tieji-discard:::"..judge.card:getSuitString()) == 0 then
        data.disresponsive = true
      end
    end
  end,
}

local machao = General:new(extension, "ex__machao", "shu", 4)
machao.subkingdom = "god"
machao:addSkill("mashu")
machao:addSkill(ex__tieji)
Fk:loadTranslationTable{
  ["ex__machao"] = "界马超",
  ["ex__tieji"] = "铁骑",
  [":ex__tieji"] = "当你使用杀指定目标时，你可以令其本回合内非锁定技失效，然后进行一次判定，其需弃置一张花色与判定结果花色相同的牌，否则其无法响应此杀。",
  ["ex__tieji_invalidity"] = "铁骑",
  ["@@tieji-turn"] = "铁骑",
  ["#ex__tieji-discard"] = "铁骑：你需弃置一张%arg牌，否则无法响应此杀。",
  ["$ex__tieji1"] = "敌人阵型已乱，随我杀!",
  ["$ex__tieji2"] = "目标敌阵，全军突击!",
  ["~ex__machao"] = "请将我，葬在西凉.....",
}
local ex__longdan = fk.CreateViewAsSkill{
  name = "ex__longdan",
  pattern = "slash,jink,peach,analeptic",
  card_filter = function(self, to_select, selected)
    if #selected ~= 0 then return false end
    local _c = Fk:getCardById(to_select)
    local c
    if _c.trueName == "slash" then
      c = Fk:cloneCard("jink")
    elseif _c.name == "jink" then
      c = Fk:cloneCard("slash")
    elseif _c.name == "peach" then
      c = Fk:cloneCard("analeptic")
    elseif _c.name == "analeptic" then
      c = Fk:cloneCard("peach")
    else
      return false
    end
    return (Fk.currentResponsePattern == nil and c.skill:canUse(Self)) or (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(c))
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local _c = Fk:getCardById(cards[1])
    local c
    if _c.trueName == "slash" then
      c = Fk:cloneCard("jink")
    elseif _c.name == "jink" then
      c = Fk:cloneCard("slash")
    elseif _c.name == "peach" then
      c = Fk:cloneCard("analeptic")
    elseif _c.name == "analeptic" then
      c = Fk:cloneCard("peach")
    end
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
}
local yajiao = fk.CreateTriggerSkill{
  name = "yajiao",
  anim_type = "offensive",
  events = {fk.CardUseFinished, fk.CardRespondFinished},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.NotActive
  end,
  on_cost = function(self, event, target, player, data)
    local targets = {}
    local room = player.room
    local id = room:getNCards(1)[1]
    room:moveCardTo(id, Card.Processing, nil, fk.ReasonJustMove, self.name)
    local cardss = Fk:getCardById(id)
    if cardss.type == data.card.type then
       for _, p in ipairs(room:getAlivePlayers()) do
         table.insert(targets, p.id)
       end
        --煞笔技能
    else 
       for _, p in ipairs(player.room:getOtherPlayers(player)) do
         if not p:isAllNude() and Fk:currentRoom():getPlayerById(p.id):inMyAttackRange(player) then
           table.insert(targets, p.id)
         end
       end
    end
    if #targets > 0 then
      if cardss.type == data.card.type then 
         local to = player.room:askForChoosePlayers(player, targets, 1, 1, "#yajiao-card:::"..cardss:toLogString(), self.name, true)
        if #to > 0 then
          self.cost_card = cardss
          self.cost_data = to[1]
          return true
        end
      else
        local to = player.room:askForChoosePlayers(player, targets, 1, 1, "#yajiao-choose", self.name, true)
        if #to > 0 then
          self.cost_card = cardss
          self.cost_data = to[1]
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    if self.cost_card.type == data.card.type then
      room:obtainCard(to, self.cost_card, true, fk.ReasonGive)
    else
      local card = room:askForCardChosen(player, to, "hej", self.name)
      room:throwCard(card, self.name, to, player)
    end
  end,
}
local zhaoyun = General:new(extension, "ex__zhaoyun", "shu", 4)
zhaoyun:addSkill(ex__longdan)
zhaoyun:addSkill(yajiao)
Fk:loadTranslationTable{
  ["ex__zhaoyun"] = "界赵云",
  ["ex__longdan"] = "龙胆",
  [":ex__longdan"] = "你可以将一张【杀】当做【闪】、【闪】当做【杀】、【酒】当做【桃】、【桃】当做【酒】使用或打出。",
  ["yajiao"] = "涯角",
  [":yajiao"] = "当你于回合外因使用或打出而失去手牌后，你可以展示牌堆顶的一张牌。若这两张牌的类别相同，你可以将展示的牌交给一名角色；若类别不同，你可弃置攻击范围内包含你的角色区域里的一张牌。",
  ["#yajiao-choose"] = "涯角: 选择一名攻击范围内包含你的角色弃置其区域内的一张牌。",
  ["#yajiao-card"] = "涯角:将 %arg交给一名角色。",
  ["$ex__longdan1"] = "龙威虎胆，斩敌破阵!",
  ["$ex__longdan2"] = "进退自如，游刃有余!",
  ["$yajiao1"] = "遍寻天下，但求一败!",
  ["$yajiao2"] = "策马驱前，斩敌当先!",
  ["~ex__zhaoyun"] = "你们谁.. 还敢再上.....",
}
local wusheng_targetmod = fk.CreateTargetModSkill{
  name = "#wusheng_targetmod",
  anim_type = "offensive",
  distance_limit_func =  function(self, player, skill, card)
    if player:hasSkill("ex__wusheng") and skill.trueName == "slash_skill" and card.suit == Card.Diamond then
      return 999
    end
    return 0
  end,
}
local ex__wusheng = fk.CreateViewAsSkill{
  name = "ex__wusheng",
  anim_type = "offensive",
  pattern = "slash",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    return Fk:getCardById(to_select).color == Card.Red
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("slash")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
}
local ex__yijue = fk.CreateActiveSkill{
  name = "ex__yijue",
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  target_filter = function(self, to_select)
    return to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, from, from)
    local to = room:getPlayerById(effect.tos[1])
   
    if to:isKongcheng() then return end

    local showCard = room:askForCard(to, 1, 1, false, self.name, false, nil, "#yijue-show::"..from.id)[1]
    to:showCards(showCard)
 
    showCard = Fk:getCardById(showCard)
    if showCard.color == Card.Black then
      room:addPlayerMark(to, "@@yijue-turn")
      room:addPlayerMark(to, MarkEnum.UncompulsoryInvalidity .. "-turn")
    else
      room:obtainCard(from, showCard, true, fk.ReasonGive)
       if to:isWounded() then
         if room:askForSkillInvoke(from, self.name, nil, "#yijue-recover::"..to.id) then
           room:recover({
              who = to.id,
             num = 1,
             recoverBy = to.id,
              skillName = self.name
           }) 
         end
       end
    end
  end
}
local yijue_prohibit = fk.CreateProhibitSkill{
  name = "#yijue_prohibit",
  prohibit_use = function(self, player, card)
    return player:getMark("@@yijue-turn") > 0
  end,
  prohibit_response = function(self, player, card)
    return player:getMark("@@yijue-turn") > 0
  end,
}
local yijue_trigger = fk.CreateTriggerSkill{
  name = "#yijue_trigger",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  mute = true,
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card.trueName == "slash" and data.card.suit == Card.Heart and data.to:getMark("@@yijue-turn") ~= 0 and not data.chain 
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
}

local guanyu = General:new(extension, "ex__guanyu", "shu", 4)
ex__yijue:addRelatedSkill(yijue_trigger)
ex__yijue:addRelatedSkill(yijue_prohibit)
ex__wusheng:addRelatedSkill(wusheng_targetmod)
guanyu:addSkill(ex__wusheng)
guanyu:addSkill(ex__yijue)
Fk:loadTranslationTable{
  ["ex__guanyu"] = "界关羽",
  ["ex__wusheng"] = "武圣",
  [":ex__wusheng"] = "①你可以将一张红色牌当做【杀】使用或打出;②锁定技，你使用♦️【杀】无距离限制",
  ["ex__yijue"] = "义绝",
  [":ex__yijue"] = "出牌阶段限一次，你可以弃置一张牌并令一名有手牌的其他角色展示一张手牌。若此牌为黑色，则该角色不能使用或打出牌，非锁定技失效且受到来自你的红桃【杀】的伤害+1直到回合结束。若此牌为红色，则你获得此牌，并可以令其回复一点体力",
  ["@@yijue-turn"] = "义绝",
  ["#yijue-recover"] = "义绝:是否令%dest恢复一点体力？",
  ["$ex__wusheng1"] = "刀锋所向，战无不克!",
  ["$ex__wusheng2"] = "逆贼，哪里走!",
  ["$ex__yijue1"] = "关某，向来恩怨分明!",
  ["$ex__yijue2"] = "恩已断，义当绝!",
  ["~ex__guanyu"] = "桃园一拜.. 恩义常在.....",
}

local ex__paoxiaoAudio = fk.CreateTriggerSkill{
  name = "#ex__paoxiaoAudio",
  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      data.card.trueName == "slash" and
      player:usedCardTimes("slash") > 1
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:broadcastSkillInvoke("ex__paoxiao")
    player.room:doAnimate("InvokeSkill", {
      name = "ex__paoxiao",
      player = player.id,
      skill_type = "offensive",
    })
  end,
}

local ex__paoxiao = fk.CreateTargetModSkill{
  name = "ex__paoxiao",
  residue_func = function(self, player, skill, scope)
    if player:hasSkill(self.name) and skill.trueName == "slash_skill"
      and scope == Player.HistoryPhase then
      return 999
    end
  end,
}
local ex__paoxiao_trigger = fk.CreateTriggerSkill{
  name = "#ex__paoxiao_trigger",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card.trueName == "slash" and player:getMark("@paoxiao-turn") ~= 0 and not data.chain and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + player:getMark("@paoxiao-turn")
    local room = player.room
    room:setPlayerMark(player, "@paoxiao-turn",0)
  end,

  refresh_events = {fk.CardUseFinished},
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill("ex__paoxiao") and data.card.name == "jink" and data.responseToEvent.from == player.id and player.phase == Player.Play then
        return data.responseToEvent.card.trueName == "slash"
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@paoxiao-turn",1)
  end,
}
ex__paoxiao:addRelatedSkill(ex__paoxiao_trigger)
ex__paoxiao:addRelatedSkill(ex__paoxiaoAudio)
local ex__tishen = fk.CreateTriggerSkill{
  name = "ex__tishen",
  anim_type = "drawcard",
  frequency = Skill.Limited,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start and player:isWounded() and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
     local maxHp = player:getLostHp()
    return player.room:askForSkillInvoke(player, self.name, nil, "#tishen-invoke:::"..maxHp)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player:getLostHp()
     room:recover({
          who = player,
         num = n,
         recoverBy = player,
         skillName = self.name
     })
    player:drawCards(n, self.name)
  end,
}
local zhangfei = General:new(extension, "ex__zhangfei", "shu", 4)
zhangfei:addSkill(ex__paoxiao)
zhangfei:addSkill(ex__tishen)
Fk:loadTranslationTable{
  ["ex__zhangfei"] = "界张飞",
  ["ex__paoxiao"] = "咆哮",
  [":ex__paoxiao"] = "①，锁定技，你使用杀无次数限制;②，锁定技，你的回合内，你使用杀被闪避时，你获得一枚【咆】;③，当你于回合内使用杀造成伤害时，若你有【咆】，你弃置所有【咆】令此杀伤害+X(X为你弃置的【咆】数量);④，回合结束后，你失去所有【咆】。",
  ["ex__tishen"] = "替身",
  [":ex__tishen"] = "限定技，准备阶段，若你已受伤，则你可以将体力值回复至上限，然后摸回复数值张牌。",
  ["@paoxiao-turn"] = "咆",
  ["#ex__paoxiao_trigger"] = "咆哮",
  ["#tishen-invoke"] = "替身:是否发动替身?回复%arg点体力并摸等量张牌？",
  
  ["$ex__paoxiao1"] = "喝!~",
  ["$ex__paoxiao2"] = "今，必斩汝马下!",
  ["$ex__tishen1"] = "欺我无谋，定要尔等血偿!",
  ["$ex__tishen2"] = "谁?还敢过来一战!",
  ["~ex__zhangfei"] = "桃园一拜.. 此生..无憾.....",
  
}
local ex__jizhi = fk.CreateTriggerSkill{
  name = "ex__jizhi",
  anim_type = "drawcard",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card.type == Card.TypeTrick 
  end,
  on_use = function(self, event, target, player, data)
    local card = Fk:getCardById(player:drawCards(1)[1])
    if card.type == Card.TypeBasic and player.phase ~= Player.NotActive then
      if player.room:askForSkillInvoke(player, self.name, nil, "#jizhi-invoke:::"..card.name) then
        player.room:throwCard(card.id, self.name, player, player)
        player.room:addPlayerMark(player, "@jizhi-turn",1)
      end
    end
  end,
}
local ex__jizhi_maxcards = fk.CreateMaxCardsSkill{
  name = "#ex__jizhi_maxcards",
  correct_func = function(self, player)
    if player:hasSkill("ex__jizhi") then
      return player:getMark("@jizhi-turn")
    else
      return 0
    end
  end,
}
local huangyueying = General(extension, "ex__huangyueying", "shu", 3, 3, General.Female)
ex__jizhi:addRelatedSkill(ex__jizhi_maxcards)
huangyueying:addSkill(ex__jizhi)
huangyueying:addSkill("qicai")

Fk:loadTranslationTable{
  ["ex__huangyueying"] = "界黄月英",
  ["ex__jizhi"] = "集智",
  [":ex__jizhi"] = "当你使用锦囊牌时，你可以摸一张牌。若此牌为基本牌且此时是你的回合内，则你可以弃置之，然后令本回合手牌上限+1。",
  ["ex__qicai"] = "奇才",
  [":ex__qicai"] = "锁定技，①你使用锦囊牌无距离限制;②你装备区的宝物牌和防具牌不能被其他角色弃置",
  ["@jizhi-turn"] = "集智",
  ["#jizhi-invoke"] = "集智:是否弃置%arg?然后令你本回合的手牌上限+1？",
}
local ex__guanxing = fk.CreateTriggerSkill{
  name = "ex__guanxing",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) then
      if player.phase == Player.Start then 
        return true
      elseif player.phase == Player.Finish then
        return player:getMark("guanxing-turn") ~= 0
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local result = room:askForGuanxing(player, room:getNCards(#room.alive_players > 4 and 5 or 3))
    if #result.top == 0 and player.phase == Player.Start then
      room:setPlayerMark(player, "guanxing-turn",1)
    end
  end,
}
local zhugeliang = General(extension, "ex__zhugeliang", "shu", 3)

zhugeliang:addSkill(ex__guanxing)
zhugeliang:addSkill("kongcheng")

Fk:loadTranslationTable{
  ["ex__zhugeliang"] = "界诸葛亮",
  ["ex__guanxing"] = "观星",
  [":ex__guanxing"] = "准备阶段，你可以观看牌堆顶的5张牌(场上存活人数＜4时改为3张)，并以任意顺序置于牌堆顶或牌堆顶;若你以此法将所有的牌均置于牌堆底，则结束阶段你也可以发动一次【观星】。",
}
return extension
