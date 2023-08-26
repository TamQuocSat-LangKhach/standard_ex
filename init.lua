local extension = Package("standard_ex")

Fk:loadTranslationTable{
  ["standard_ex"] = "界标包",
  ["ex"] = "界",
  ["std"] = "标",
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
  ["$ex__jianxiong1"] = "燕雀，安知鸿鹄之志！",
  ["$ex__jianxiong2"] = "夫英雄者，胸怀大志，腹有良谋！",
  ["~ex__caocao"] = "华佗何在？……",
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
    local card = player.room:askForResponse(player, self.name, ".|.|.|hand,equip|.|", "#guicai-ask::" .. target.id, true)
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

  ["$ex__guicai1"] = "天命难违？哈哈哈哈哈……",
  ["$ex__guicai2"] = "才通天地，逆天改命！",
  ["$ex__fankui1"] = "哼！自作孽不可活！",
  ["$ex__fankui2"] = "哼！正中下怀！",
  ["~ex__simayi"] = "我的气数就到这里了么？",
}

--夏侯惇
local ex__ganglie = fk.CreateTriggerSkill{
  name = "ex__ganglie",
  anim_type = "masochism",
  events = {fk.Damaged},
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      if self.cancel_cost then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from
    if from and not from.dead then room:doIndicate(player.id, {from.id}) end
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".",
    }
    room:judge(judge)
    if judge.card.color == Card.Red and not from.dead then
      room:damage{
        from = player,
        to = from,
        damage = 1,
        skillName = self.name,
      }
    elseif judge.card.color == Card.Black and not from:isNude() then
      local cid = room:askForCardChosen(player, from, "he", self.name)
      room:throwCard({cid}, self.name, from, player)
    end
  end
}
Fk:addSkill(ex__ganglie)

Fk:loadTranslationTable{
  ["ex__xiahoudun"] = "界夏侯惇",
  ["ex__ganglie"] = "刚烈",
  [":ex__ganglie"] = "当你受到1点伤害后，你可判定，若结果为：红色，你对来源造成1点伤害；黑色，你弃置来源的一张牌。",
  ["$ex__ganglie1"] = "哪个敢动我！",
  ["$ex__ganglie2"] = "伤我者，十倍奉还！",
}

--张辽
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

  ["$ex__tuxi1"] = "快马突袭，占尽先机！",
  ["$ex__tuxi2"] = "马似飞影，枪如霹雳！",
  ["~ex__zhangliao"] = "被敌人占了先机，呃。",
}

--许褚
local xuchu = General(extension, "ex__xuchu", "wei", 4)
local ex__luoyi = fk.CreateTriggerSkill{
  name = "ex__luoyi",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cids = room:getNCards(3)
    room:moveCardTo(cids, Card.Processing, nil, fk.ReasonJustMove, self.name)
    if room:askForChoice(player, {"ex__luoyi_get", "Cancel"}, self.name) == "ex__luoyi_get" then
      local cards = {}
      for _, id in ipairs(cids) do
        local card = Fk:getCardById(id)
        if card.type == Card.TypeBasic or card.sub_type == Card.SubtypeWeapon or card.name == "duel" then
          table.insert(cards, id)
        end
      end
      if #cards > 0 then
        local dummy = Fk:cloneCard("slash")
        dummy:addSubcards(cards)
        room:obtainCard(player, dummy, true, Fk.ReasonJustMove)
      end
      room:addPlayerMark(player, "@@ex__luoyi")
      return true
    end
  end,
}
local ex__luoyi_trigger = fk.CreateTriggerSkill{
  name = "#ex__luoyi_trigger",
  mute = true,
  events = {fk.DamageCaused},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@ex__luoyi") > 0 and
      not data.chain and data.card and (data.card.trueName == "slash" or data.card.name == "duel")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("ex__luoyi")
    room:notifySkillInvoked(player, "ex__luoyi")
    data.damage = data.damage + 1
  end,

  refresh_events = {fk.EventPhaseChanging, fk.Death},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@ex__luoyi") ~= 0 and (event == fk.Death or data.from == Player.NotActive)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@ex__luoyi", 0)
  end,
}
ex__luoyi:addRelatedSkill(ex__luoyi_trigger)
xuchu:addSkill(ex__luoyi)
Fk:loadTranslationTable{
  ["ex__xuchu"] = "界许褚",
  ["ex__luoyi"] = "裸衣",
  [":ex__luoyi"] = "摸牌阶段开始时，你亮出牌堆顶的三张牌，然后你可以获得其中的基本牌、武器牌或【决斗】。若如此做，你放弃摸牌，且直到你的下个回合开始，你为伤害来源的【杀】或【决斗】造成的伤害值+1。",

  ["ex__luoyi_get"] = "获得其中的基本牌、武器牌或【决斗】",
  ["@@ex__luoyi"] = "裸衣",
  ["ex__luoyi_trigger"] = "裸衣",

  ["$ex__luoyi1"] = "过来打一架，对，就是你！",
  ["$ex__luoyi2"] = "废话少说，放马过来吧！",
  ["~ex__xuchu"] = "丞相，末将尽力了！",
}

local ex__zhenji = General(extension, "ex__zhenji", "wei", 3, 3, General.Female)

local ex__luoshen = fk.CreateTriggerSkill{
  name = "ex__luoshen",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    while true do
      local judge = {
        who = player,
        reason = self.name,
        pattern = ".|A~K|spade,club",
      }
      room:judge(judge)
      if judge.card.color ~= Card.Black then
        break
      end

      if not room:askForSkillInvoke(player, self.name) then
        break
      end
    end
  end,
}
local ex__luoshen_obtain = fk.CreateTriggerSkill{
  name = "#ex__luoshen_obtain",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.FinishJudge},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill("ex__luoshen") and
      data.reason == "ex__luoshen" and data.card.color == Card.Black
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setCardMark(data.card, "@@ex__luoshen-turn", 1)
    room:obtainCard(player.id, data.card)
  end,
}
local ex__luoshen_max = fk.CreateMaxCardsSkill{
  name = "#ex__luoshen_max",
  exclude_from = function(self, player, card)
    return player:hasSkill("ex__luoshen") and card:getMark("@@ex__luoshen-turn") > 0
  end,
}
local ex__luoshen_maxcards_audio = fk.CreateTriggerSkill{
  name = "#ex__luoshen_maxcards_audio",
  refresh_events = {fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    return player == target and player:hasSkill("ex__luoshen") and player.phase == Player.Discard
  end,
  on_refresh = function(self, event, target, player, data)
    player:broadcastSkillInvoke("ex__luoshen")
    player.room:notifySkillInvoked(player, "ex__luoshen", "special")
  end,
}
ex__luoshen:addRelatedSkill(ex__luoshen_obtain)
ex__luoshen:addRelatedSkill(ex__luoshen_max)
ex__luoshen:addRelatedSkill(ex__luoshen_maxcards_audio)

ex__zhenji:addSkill(ex__luoshen)
ex__zhenji:addSkill("qingguo")

Fk:loadTranslationTable{
  ["ex__zhenji"] = "界甄姬",
  ["ex__luoshen"] = "洛神",
  [":ex__luoshen"] = "准备阶段开始时，你可以进行判定，当黑色判定牌生效后，你获得之并可以重复此流程。你以此法获得的牌在本回合不计入手牌上限。",

  ["@@ex__luoshen-turn"] = "洛神",

  ["$ex__luoshen1"] = "屏翳收风，川后静波。",
  ["$ex__luoshen2"] = "冯夷鸣鼓，女娲清歌。",
  ["$ex__qingguo1"] = "肩若削成，腰如约素。",
  ["$ex__qingguo2"] = "延颈秀项，皓质呈露。",
  ["~ex__zhenji"] = "出亦复何苦，入亦复何愁。",
}

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
    if player.room:askForSkillInvoke(player, self.name, nil, prompt) then
      return true
    end
    self.cancel_cost = true
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
  [":wangxi"] = "当你对其他角色造成1点伤害后，或当你受到其他角色造成的1点伤害后，你可以与其各摸一张牌。",
  ["#wangxi-invoke"] = "忘隙：你可以与 %dest 各摸一张牌",

  ["$xunxun1"] = "众将死战，非我之功。",
  ["$xunxun2"] = "爱兵如子，胜乃可全。",
  ["$wangxi1"] = "前尘往事，莫再提起。",
  ["$wangxi2"] = "大丈夫，何拘小节。",
  ["~lidian"] = "报国杀敌，虽死犹荣……",
}

local sunquan = General(extension, "ex__sunquan", "wu", 4)
local ex__zhiheng = fk.CreateActiveSkill{
  name = "ex__zhiheng",
  anim_type = "drawcard",
  min_card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
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
  ["$ex__zhiheng1"] = "不急不躁，稳谋应对。",
  ["$ex__zhiheng2"] = "制衡互牵，大局可安。",
  ["~ex__sunquan"] = "锦绣江东，岂能失于我手……",
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
  ["$ex__kurou1"] = "我这把老骨头，不算什么！",
  ["$ex__kurou2"] = "为成大业，死不足惜！",
  ["$ex__zhaxiang1"] = "铁锁连舟而行，东吴水师可破！",
  ["$ex__zhaxiang2"] = "两军阵前，不斩降将！",
  ["~ex__huanggai"] = "盖，有负公瑾重托……",
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

  refresh_events = {fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    return player == target and player:hasSkill(self.name) and player.phase == Player.Discard
  end,
  on_refresh = function(self, event, target, player, data)
    player:broadcastSkillInvoke(self.name)
    player.room:notifySkillInvoked(player, self.name, "special")
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
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Card.PlayerEquip
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    room:obtainCard(target.id, effect.cards[1], true, fk.ReasonGive)
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
  [":ex__fanjian"] = "出牌阶段限一次，你可以展示一张手牌并交给一名其他角色，然后其选择：1.展示所有手牌，然后弃置花色和你交给的牌的花色相同的所有牌；2.失去1点体力。",
  ["ex__fanjian_show"] = "展示手牌，然后弃置所有花色相同的牌",
  ["$ex__yingzi1"] = "哈哈哈哈……！",
  ["$ex__yingzi2"] = "伯符，且看我这一手！",
  ["$ex__fanjian1"] = "与我为敌，就当这般生不如死！",
  ["$ex__fanjian2"] = "抉择吧！ 在苦与痛的地狱中！",
  ["~ex__zhouyu"] = "既生瑜，何生亮！……既生瑜，何生亮……！",
}
--local ex__luxun = General(extension, "ex__luxun", "wu", 3)
local ex__qianxun = fk.CreateTriggerSkill{
  name = "ex__qianxun",
  events = {fk.CardEffecting}, --延时锦囊不过这个事件！
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and data.to == player.id and (not target or target ~= player) and (data.card.sub_type == Card.SubtypeDelayedTrick or data.card:isCommonTrick()) and #TargetGroup:getRealTargets(data.tos) == 1 and not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    player:addToPile("ex__qianxun", player:getCardIds("h"), false, self.name)
  end,
}
local ex__qianxun_delay = fk.CreateTriggerSkill{
  name = "#ex__qianxun_delay",
  mute = true,
  events = {fk.EventPhaseChanging},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return data.to == Player.NotActive and #player:getPile("ex__qianxun") > 0
  end,
  on_use = function(self, event, target, player, data)
    local dummy = Fk:cloneCard("zixing")
    dummy:addSubcards(player:getPile("ex__qianxun"))
    local room = player.room
    room:obtainCard(player.id, dummy, false)
  end,
}
ex__qianxun:addRelatedSkill(ex__qianxun_delay)

Fk:addSkill(ex__qianxun)
--ex__luxun:addSkill(ex__qianxun)

Fk:loadTranslationTable{
  ["ex__luxun"] = "界陆逊",
  ["ex__qianxun"] = "谦逊",
  [":ex__qianxun"] = "当一张延时锦囊牌或其他角色使用的普通锦囊牌对你生效时，若你是此牌唯一目标，则你可以将所有手牌扣置于武将牌上，然后此回合结束时，你获得这些牌。",
  ["ex__lianying"] = "连营",
  [":ex__lianying"] = "当你失去手牌后，若你没有手牌，则你可以令至多X名角色各摸一张牌（X为你此次失去的手牌数）。",

  ["#ex__qianxun_delay"] = "谦逊",

  ["$ex__qianxun1"] = "谦谦君子，温润如玉。",
  ["$ex__qianxun2"] = "满招损，谦受益。",
  ["$ex__lianying1"] = "生生不息，源源不绝。",
  ["$ex__lianying2"] = "失之淡然，得之坦然。",
  ["~ex__luxun"] = "我的未竟之业……",
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
  ["$ex__jieyin1"] = "随夫嫁娶，宜室宜家。",
  ["$ex__jieyin2"] = "得遇夫君，妾身福分。",
  ["~ex__sunshangxiang"] = "就这样……结束了吗……",
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
local lvbu = General(extension, "ex__lvbu", "qun", 5)

local liyu = fk.CreateTriggerSkill{
  name = "liyu",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card and data.card.trueName == "slash" and not data.to.dead and not data.to:isAllNude()
  end,
  on_cost = function(self, event, target, player, data)
    return target.room:askForSkillInvoke(player, self.name, data, "#liyu-invoke::" .. data.to.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    local id = room:askForCardChosen(player, to, "hej", self.name)
    room:obtainCard(player, id, true, fk.ReasonPrey)
    if Fk:getCardById(id).type ~= Card.TypeEquip then
      to:drawCards(1, self.name)
    else
      local card = Fk:cloneCard("duel")
      if player:prohibitUse(card) then return false end
      local targets = table.map(
        table.filter(room.alive_players, function(p)
          return not player:isProhibited(p, card) and p ~= player and p ~= to
        end),
        function(p)
          return p.id
        end
      )
      if #targets == 0 then return false end
      local target = room:askForChoosePlayers(to, targets, 1, 1, "#liyu-ask:" .. player.id, self.name, false)[1]
      room:useVirtualCard("duel", nil, player, room:getPlayerById(target), self.name)
    end
  end,
}

lvbu:addSkill(liyu)
lvbu:addSkill("wushuang")

Fk:loadTranslationTable{
  ["ex__lvbu"] = "界吕布",
  ["liyu"] = "利驭",
  [":liyu"] = "当你使用【杀】对一名其他角色造成伤害后，你可获得其区域里的一张牌。然后若获得的牌不是装备牌，其摸一张牌；若获得的牌是装备牌，则视为你对由其指定的另一名其他角色使用一张【决斗】。",

  ["#liyu-invoke"] = "利驭：你可获得 %dest 区域里的一张牌",
  ["#liyu-ask"] = "利驭：选择一名角色，视为 %src 对其使用【决斗】",

  ["$liyu1"] = "人不为己，天诛地灭。",
  ["$liyu2"] = "大丈夫，相时而动。",
  ["~ex__lvbu"] = "我竟然输了……不可能！",
}

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
local huaxiong = General(extension, "std__huaxiong", "qun", 6)
huaxiong:addSkill(yaowu)
Fk:loadTranslationTable{
  ["std__huaxiong"] = "华雄",
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
local std__yuanshu = General(extension, "std__yuanshu", "qun", 4)
local wangzun = fk.CreateTriggerSkill{
  name = "wangzun",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target.phase == Player.Start and player:hasSkill(self.name) and target.role == "lord"
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
    player.room:addPlayerMark(target, MarkEnum.MinusMaxCardsInTurn)
  end,
}
local tongji = fk.CreateProhibitSkill{
  name = "tongji",
  is_prohibited = function(self, from, to, card)
    local targets = table.filter(Fk:currentRoom().alive_players, function(p)
      return p:hasSkill(self.name) and p:getHandcardNum() > p.hp and from:inMyAttackRange(p)
    end)
    if #targets > 0 then
      return card.trueName == "slash" and not table.contains(targets, to)
    end
  end,
}
local tongjiAudio = fk.CreateTriggerSkill{
  name = "#tongjiAudio",
  refresh_events = {fk.TargetConfirmed},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(tongji.name) and player:getHandcardNum() > player.hp and data.card and data.card.trueName == "slash"
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, tongji.name, "negative")
    player:broadcastSkillInvoke(tongji.name)
  end,
}
tongji:addRelatedSkill(tongjiAudio)

std__yuanshu:addSkill(wangzun)
std__yuanshu:addSkill(tongji)

Fk:loadTranslationTable{
  ["std__yuanshu"] = "袁术",
  ["wangzun"] = "妄尊",
  [":wangzun"] = "主公的准备阶段，你可以摸一张牌，然后其本回合手牌上限-1。",
  ["tongji"] = "同疾",
  [":tongji"] = "锁定技，若你的手牌数大于体力值，攻击范围含有你的角色使用【杀】只能以你为目标。",

  ["$wangzun1"] = "真命天子，八方拜服。",
  ["$wangzun2"] = "归顺于我，封爵赏地。",
  ["$tongji1"] = "弑君之罪，当诛九族！",
  ["$tongji2"] = "你，你这是反啦！",
  ["~std__yuanshu"] = "把玉玺，还给我。",
}
--公孙瓒
local gongsunzan = General(extension, "std__gongsunzan", "qun", 4)
local qiaomeng = fk.CreateTriggerSkill{
  name = "qiaomeng",
  events = {fk.Damage},
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card and data.card.trueName == "slash" and not data.to.dead and #data.to:getCardIds("e") > 0 and data.card.color == Card.Black
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    local cid = room:askForCardChosen(player, to, "e", self.name)
    if table.contains({Card.SubtypeDefensiveRide, Card.SubtypeOffensiveRide}, Fk:getCardById(cid, true).sub_type) then
      local record = player:getMark("_qiaomeng") ~= 0 and player:getMark("_qiaomeng") or {}
      table.insertIfNeed(record, cid)
      room:setPlayerMark(player, "_qiaomeng", record)
    end
    room:throwCard({cid}, self.name, to, player)
  end,
}
local qiaomeng_get = fk.CreateTriggerSkill{
  name = "#qiaomeng_get",
  events = {fk.AfterCardsMove},
  frequency = Skill.Compulsory,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:getMark("_qiaomeng") == 0 or player.dead then return false end
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(player:getMark("_qiaomeng"), info.cardId) then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local cids = {}
    local room = player.room
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(player:getMark("_qiaomeng"), info.cardId) then
            table.insertIfNeed(cids, info.cardId)
          end
        end
      end
    end
    local dummy = Fk:cloneCard("dilu")
    dummy:addSubcards(cids)
    local record = player:getMark("_qiaomeng") ~= 0 and player:getMark("_qiaomeng") or {}
    table.forEach(cids, function(cid)
      table.removeOne(record, cid)
    end)
    if #record == 0 then record = 0 end
    room:setPlayerMark(player, "_qiaomeng", record)
    room:obtainCard(player, dummy, true, fk.ReasonPrey)
  end,
}
qiaomeng:addRelatedSkill(qiaomeng_get)
gongsunzan:addSkill(qiaomeng)
gongsunzan:addSkill("yicong")
Fk:loadTranslationTable{
  ["std__gongsunzan"] = "公孙瓒",
  ["qiaomeng"] = "趫猛",
  [":qiaomeng"] = "当你使用的黑色【杀】对一名角色造成伤害后，你可以弃置其装备区里的一张牌。当此牌移至弃牌堆后，若此牌为坐骑牌，你获得此牌。",

  ["#qiaomeng_get"] = "趫猛",

  ["$qiaomeng1"] = "秣马厉兵，枕戈待战。",
  ["$qiaomeng2"] = "夺敌辎重，以为己用。",
  ["~std__gongsunzan"] = "皇图霸业梦，付之，一炬中……",	
}

local panfeng = General(extension, "std__panfeng", "qun", 4)
local std__kuangfu = fk.CreateTriggerSkill{
  name = "std__kuangfu",
  events = {fk.Damage},
  frequency = Skill.Compulsory,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card and data.card.trueName == "slash" and player.phase == Player.Play and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not data.to.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if data.to.hp < player.hp then
      room:notifySkillInvoked(player, self.name, "drawcard")
      player:drawCards(2, self.name)
    else
      room:notifySkillInvoked(player, self.name, "negative")
      player.room:loseHp(player, 1, self.name)
    end
  end,
}
panfeng:addSkill(std__kuangfu)
Fk:loadTranslationTable{
  ["std__panfeng"] = "潘凤",
  ["std__kuangfu"] = "狂斧",
  [":std__kuangfu"] = "锁定技，当你使用【杀】对其他角色造成伤害后，若此时为你的出牌阶段且你与此阶段未发动过此技能，若其体力值小于/不小于你，你摸两张牌/失去1点体力。",

  ["$std__kuangfu1"] = "吾乃上将潘凤，可斩华雄！",
  ["$std__kuangfu2"] = "这家伙还是给我用吧！",
  ["~std__panfeng"] = "潘凤又被华雄斩了……",	
}
--蜀国

local ex__liubei = General(extension, "ex__liubei", "shu", 4)
local ex__rende = fk.CreateActiveSkill{
  name = "ex__rende",
  anim_type = "support",
  card_filter = function(self, to_select, selected)
    return Fk:currentRoom():getCardArea(to_select) ~= Card.PlayerEquip
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and Fk:currentRoom():getPlayerById(to_select):getMark("_ex__rende-phase") == 0
  end,
  target_num = 1,
  min_card_num = 1,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    local player = room:getPlayerById(effect.from)
    local cards = effect.cards
    local marks = player:getMark("_rende_cards-phase")
    room:moveCardTo(cards, Player.Hand, target, fk.ReasonGive, self.name, nil, false)
    room:addPlayerMark(player, "_rende_cards-phase", #cards)
    room:addPlayerMark(target, "_ex__rende-phase", 1)
    if marks < 2 and marks + #cards >= 2 then
      local success, dat = room:askForUseViewAsSkill(player, "#ex__rende_vs", "#ex__rende-ask", true)
      if success then
        local card = Fk.skills["#ex__rende_vs"]:viewAs(dat.cards)
        local use = {
          from = player.id,
          tos = table.map(dat.targets, function(e) return {e} end),
          card = card,
        }
        room:useCard(use)
      end
    end
  end,
}
local ex__rende_vs = fk.CreateViewAsSkill{
  name = "#ex__rende_vs",
  card_num = 0,
  card_filter = function(self, to_select, selected)
    return false
  end,
  pattern = "^nullification|.|.|.|.|basic",
  interaction = function(self)
    local allCardNames, cardNames = {}, {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      local name = card.name
      if not table.contains(allCardNames, name) and card.type == Card.TypeBasic and not card.is_derived then
        table.insert(allCardNames, name)
        local card = Fk:cloneCard(name)
        if Self:canUse(card) and not Self:prohibitUse(card) then
          table.insert(cardNames, name)
        end
      end
    end
    return UI.ComboBox { choices = cardNames , all_choices = allCardNames}
  end,
  view_as = function(self, cards)
    local choice = self.interaction.data
    if not choice then return end
    local c = Fk:cloneCard(choice)
    c:addSubcards(cards)
    c.skillName = self.name
    return c
  end,
  enabled_at_play = function(self, player)
    return false
  end,
  enabled_at_response = function(self, player)
    return false
  end,
}
ex__rende:addRelatedSkill(ex__rende_vs)

ex__liubei:addSkill(ex__rende)
ex__liubei:addSkill("jijiang")

Fk:loadTranslationTable{
  ["ex__liubei"] = "界刘备",
  ["ex__rende"] = "仁德",
  [":ex__rende"] = "出牌阶段每名角色限一次，你可以将任意张手牌交给一名其他角色，每阶段你以此法给出第二张牌时，你可以视为使用一张基本牌。",
  
  ["#ex__rende-ask"] = "仁德：你可视为使用一张基本牌",
  ["#ex__rende-vs"] = "仁德：视为使用【%arg】",
  ["#ex__rende_vs"] = "仁德",

  ["$ex__rende1"] = "同心同德，救困扶危！",
  ["$ex__rende2"] = "施仁布泽，乃我大汉立国之本！",
  ["~ex__liubei"] = "汉室未兴，祖宗未耀，朕实不忍此时西去……",
}

local ex__tieji = fk.CreateTriggerSkill{
  name = "ex__tieji",
  anim_type = "offensive",
  events = {fk.TargetSpecified},
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
  [":ex__tieji"] = "当你使用【杀】指定目标后，你可以令其本回合内非锁定技失效，然后进行一次判定，其需弃置一张花色与判定结果花色相同的牌，否则其无法响应此【杀】。",
  ["ex__tieji_invalidity"] = "铁骑",
  ["@@tieji-turn"] = "铁骑",
  ["#ex__tieji-discard"] = "铁骑：你需弃置一张%arg牌，否则无法响应此杀。",
  ["$ex__tieji1"] = "敌人阵型已乱，随我杀！",
  ["$ex__tieji2"] = "目标敌阵，全军突击！",
  ["~ex__machao"] = "请将我，葬在西凉……",
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
    return (Fk.currentResponsePattern == nil and c.skill:canUse(Self, c)) or (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(c))
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
  ["$ex__longdan1"] = "龙威虎胆，斩敌破阵！",
  ["$ex__longdan2"] = "进退自如，游刃有余！",
  ["$yajiao1"] = "遍寻天下，但求一败！",
  ["$yajiao2"] = "策马驱前，斩敌当先！",
  ["~ex__zhaoyun"] = "你们谁…还敢再上……",
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
            who = to,
            num = 1,
            recoverBy = from,
            skillName = self.name,
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
    return target == player and player:hasSkill(self.name) and data.card and data.card.trueName == "slash" and data.card.suit == Card.Heart and data.to:getMark("@@yijue-turn") ~= 0 and not data.chain 
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
  [":ex__wusheng"] = "①你可以将一张红色牌当做【杀】使用或打出。②你使用<font color='red'>♦</font>【杀】无距离限制",
  ["ex__yijue"] = "义绝",
  [":ex__yijue"] = "出牌阶段限一次，你可以弃置一张牌并令一名其他角色展示一张手牌。若此牌为黑色，则其直到回合结束不能使用或打出牌，所有非锁定技失效，你对其使用的<font color='red'>♥</font>【杀】的伤害+1。若此牌为红色，则你获得此牌，可以令其回复1点体力。",
  ["@@yijue-turn"] = "义绝",
  ["#yijue-recover"] = "义绝：是否令%dest回复1点体力？",
  ["$ex__wusheng1"] = "刀锋所向，战无不克！",
  ["$ex__wusheng2"] = "逆贼，哪里走！",
  ["$ex__yijue1"] = "关某，向来恩怨分明！",
  ["$ex__yijue2"] = "恩已断，义当绝！",
  ["~ex__guanyu"] = "桃园一拜，恩义常在……",
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
    player:broadcastSkillInvoke("ex__paoxiao")
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
    return target == player and player:hasSkill(self.name) and data.card and data.card.trueName == "slash" and player:getMark("@paoxiao-turn") ~= 0 and not data.chain and player.phase == Player.Play
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
  [":ex__paoxiao"] = "锁定技①你使用杀无次数限制；②你的回合内，你使用【杀】被闪避时，你获得一枚“咆”；③当你于回合内使用【杀】造成伤害时，若你有“咆”，你弃置所有“咆”令此【杀】伤害+X(X为你弃置的“咆”数量)；④回合结束后，你失去所有“咆”。",
  ["ex__tishen"] = "替身",
  [":ex__tishen"] = "限定技，准备阶段，若你已受伤，则你可以将体力值回复至上限，然后摸回复数值张牌。",
  ["@paoxiao-turn"] = "咆",
  ["#ex__paoxiao_trigger"] = "咆哮",
  ["#tishen-invoke"] = "替身:是否发动替身?回复%arg点体力并摸等量张牌？",

  ["$ex__paoxiao1"] = "喝！~",
  ["$ex__paoxiao2"] = "今，必斩汝马下！",
  ["$ex__tishen1"] = "欺我无谋，定要尔等血偿！",
  ["$ex__tishen2"] = "谁?还敢过来一战！",
  ["~ex__zhangfei"] = "桃园一拜，此生…无憾……",
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
local ex__qicai = fk.CreateTargetModSkill{
  name = "ex__qicai",
  frequency = Skill.Compulsory,
  bypass_distances = function(self, player, skill, card)
    return player:hasSkill(self.name) and card and card.type == Card.TypeTrick
  end,
}
local ex__qicai_move = fk.CreateTriggerSkill{
  name = "#ex__qicai_move",
  events = {fk.BeforeCardsMove},
  frequency = Skill.Compulsory,
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) or not (player:getEquipment(Card.SubtypeArmor) or player:getEquipment(Card.SubtypeTreasure)) then return false end
    for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip and table.contains({Card.SubtypeArmor, Card.SubtypeTreasure}, Fk:getCardById(info.cardId).sub_type) then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local ids = {}
    for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonDiscard then
        local move_info = {}
        for _, info in ipairs(move.moveInfo) do
          local id = info.cardId
          if info.fromArea == Card.PlayerEquip and table.contains({Card.SubtypeArmor, Card.SubtypeTreasure}, Fk:getCardById(id).sub_type) then
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
        arg = self.name,
      }
    end
  end,
}
ex__qicai:addRelatedSkill(ex__qicai_move)
local huangyueying = General(extension, "ex__huangyueying", "shu", 3, 3, General.Female)
ex__jizhi:addRelatedSkill(ex__jizhi_maxcards)
huangyueying:addSkill(ex__jizhi)
huangyueying:addSkill(ex__qicai)

Fk:loadTranslationTable{
  ["ex__huangyueying"] = "界黄月英",
  ["ex__jizhi"] = "集智",
  [":ex__jizhi"] = "当你使用锦囊牌时，你可以摸一张牌。若此牌为基本牌且此时是你的回合内，则你可以弃置之，然后令本回合手牌上限+1。",
  ["ex__qicai"] = "奇才",
  [":ex__qicai"] = "锁定技，①你使用锦囊牌无距离限制；②你装备区的宝物牌和防具牌不能被其他角色弃置。",
  ["@jizhi-turn"] = "集智",

  ["#ex__qicai_move"] = "奇才",
  ["#cancelDismantle"] = "由于“%arg”的效果，%card 的弃置被取消",
  ["#jizhi-invoke"] = "集智：是否弃置%arg，令你本回合的手牌上限+1？",

  ["$ex__jizhi1"] = "得上通，智集心。",
  ["$ex__jizhi2"] = "集万千才智，致巧趣鲜用。",
  ["~ex__huangyueying"] = "我的面容，有吓到你吗？",
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
  [":ex__guanxing"] = "准备阶段，你可以观看牌堆顶的5张牌(场上存活人数＜4时改为3张)，并以任意顺序置于牌堆顶或牌堆顶。若你将这些牌均放至牌堆底，则结束阶段你可以发动〖观星〗。",
}

local std__xushu = General(extension, "std__xushu", "shu", 4)

local zhuhai = fk.CreateTriggerSkill{
  name = "zhuhai",
  events = {fk.EventPhaseStart},
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and player ~= target and target.phase == Player.Finish and #player.room.logic:getEventsOfScope(GameEvent.ChangeHp, 1, function (e)
      local damage = e.data[5]
      if damage and target == damage.from and target ~= damage.to then
        return true
      end
    end, Player.HistoryTurn) == 1 then
      local card = Fk:cloneCard("slash")
      return not player:prohibitUse(card) and not player:isProhibited(target, card)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local use = player.room:askForUseCard(player, "slash", nil, "#zhuhai-ask:" .. target.id, true, {must_targets = {target.id}, bypass_distances = true }) --ex
    if use then
      self.cost_data = use
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:useCard(self.cost_data)
  end,
}

local qianxin = fk.CreateTriggerSkill{
  name = "qianxin",
  events = {fk.Damage},
  frequency = Skill.Wake,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and not player.dead
  end,
  can_wake = function(self, event, target, player, data)
    return player.hp < player.maxHp
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    room:handleAddLoseSkills(player, "jianyan", nil)
  end,
}

local jianyan = fk.CreateActiveSkill{
  name = "jianyan",
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  interaction = function()
    return UI.ComboBox {choices = {"black", "red", "basic", "trick", "equip"} }
  end,
  on_use = function(self, room, effect)
    local pattern = self.interaction.data
    local player = room:getPlayerById(effect.from)
    local card
    local cards = {}
    local _pattern
    if pattern == "black" then
      _pattern = ".|.|spade,club"
    elseif pattern == "red" then
      _pattern = ".|.|heart,diamond"
    else
      _pattern = ".|.|.|.|.|" .. pattern
    end
    if #room:getCardsFromPileByRule(_pattern, 1, "allPiles") == 0 then return false end
    while true do
      local id = room:getNCards(1)[1]
      room:moveCardTo(id, Card.Processing, nil, fk.ReasonJustMove, self.name)
      room:delay(300)
      local c = Fk:getCardById(id)
      if c:getColorString() == pattern or c:getTypeString() == pattern then
        card = c
        break
      else
        table.insert(cards, id)
      end
    end
    local availableTargets = table.map(table.filter(room.alive_players, function(p) return p.gender == General.Male end), function(p) return p.id end)
    if #availableTargets == 0 then
      table.insert(cards, card.id)
    else
      local target = room:askForChoosePlayers(player, availableTargets, 1, 1, "#jianyan-give:::" .. card:toLogString(), self.name, false)[1]
      room:moveCardTo(card.id, Player.Hand, room:getPlayerById(target), fk.ReasonGive, self.name, nil, true, player.id)
    end
    cards = table.filter(cards, function(id) return room:getCardArea(id) == Card.Processing end)
    room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, nil, true, player.id)
  end,
}

std__xushu:addSkill(zhuhai)
std__xushu:addSkill(qianxin)
std__xushu:addRelatedSkill(jianyan)

Fk:loadTranslationTable{
  ["std__xushu"] = "徐庶",
  ["zhuhai"] = "诛害",
  [":zhuhai"] = "其他角色的结束阶段，若该角色本回合造成过伤害，则你可以对其使用【杀】（无距离限制）。",
  ["qianxin"] = "潜心",
  [":qianxin"] = "觉醒技，当你造成伤害后，若你已受伤，你减1点体力上限，并获得〖荐言〗。",
  ["jianyan"] = "荐言",
  [":jianyan"] = "出牌阶段限一次，你可以选择一种牌的类别或颜色，然后连续亮出牌堆顶的牌，直到亮出符合你声明的牌为止，你令一名男性角色获得此牌。",

  ["#zhuhai-ask"] = "诛害：你可对 %src 使用【杀】",
  ["#jianyan-give"] = "荐言：你可将 %arg 交给一名角色",

  ["$zhuhai1"] = "善恶有报，天道轮回！",
  ["$zhuhai2"] = "早知今日，何必当初！",
  ["$qianxin1"] = "既遇明主，天下可图！",
  ["$qianxin2"] = "弃武从文，安邦卫国！",
  ["$jianyan1"] = "开言纳谏，社稷之福。",
  ["$jianyan2"] = "如此如此，敌军自破！",
  ["~std__xushu"] = "母亲……孩儿……尽孝来了。",
}

local yijik = General(extension, "yijik", "shu", 3)

local jijie = fk.CreateActiveSkill{
  name = "jijie",
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cids = room:getNCards(1, "bottom")
    room:fillAG(player, cids)
    room:delay(2000)
    room:closeAG(player)
    local target = room:askForChoosePlayers(player, table.map(room.alive_players, function(p) return p.id end), 1, 1, "#jijie-give:::" .. Fk:getCardById(cids[1]):toLogString(), self.name, false)[1]
    room:moveCardTo(cids, Player.Hand, room:getPlayerById(target), fk.ReasonGive, self.name, nil, false, player.id)
  end,
}

local jiyuan = fk.CreateTriggerSkill{
  name = "jiyuan",
  anim_type = "support",
  events = {fk.EnterDying, fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return false end
    if event == fk.EnterDying then
      return true
    else
      for _, move in ipairs(data) do
        local to = move.to and player.room:getPlayerById(move.to) or nil 
        if to and to ~= player and move.proposer == player.id and move.moveReason == fk.ReasonGive then
          return true
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    if event == fk.EnterDying then
      self:doCost(event, target, player, data)
    else
      local targets = {}
      local room = player.room
      for _, move in ipairs(data) do
        local to = move.to and room:getPlayerById(move.to) or nil
        if to and to ~= player and (move.from == player.id or (move.skillName and player:hasSkill(move.skillName))) and (move.toArea == Card.PlayerHand or move.toArea == Card.PlayerEquip) and move.moveReason == fk.ReasonGive then
          table.insertIfNeed(targets, move.to)
        end
      end
      room:sortPlayersByAction(targets)
      for _, target_id in ipairs(targets) do
        if not player:hasSkill(self.name) then break end
        local skill_target = room:getPlayerById(target_id)
        self:doCost(event, skill_target, player, data)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#jiyuan-trigger::" .. target.id)
  end,
  on_use = function(self, event, target, player, data)
    player.room:doIndicate(player.id, {target.id})
    target:drawCards(1, self.name)
  end,
}

yijik:addSkill(jijie)
yijik:addSkill(jiyuan)

Fk:loadTranslationTable{
  ["yijik"] = "伊籍",
  ["jijie"] = "机捷",
  [":jijie"] = "出牌阶段限一次，你可以观看牌堆底的一张牌，将此牌交给一名角色。",
  ["jiyuan"] = "急援",
  [":jiyuan"] = "当一名角色进入濒死时或当你交给一名其他角色牌后，你可令其摸一张牌。",

  ["#jijie-give"] = "机捷：你可将 %arg 交给一名角色",
  ["#jiyuan-trigger"] = "急援：你可令 %dest 摸一张牌",

  ["$jijie1"] = "一拜一起，未足为劳。",
  ["$jijie2"] = "识言观行，方能雍容风议。",
  ["$jiyuan1"] = "公若辞，必遭蔡瑁之害矣。",
  ["$jiyuan2"] = "形势危急，还请速行。",
  ["~yijik"] = "未能，救得刘公脱险……",
}

return extension
