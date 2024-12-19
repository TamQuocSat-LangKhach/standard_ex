local extension = Package("standard_ex")

Fk:loadTranslationTable{
  ["standard_ex"] = "界限突破·标准包",
  ["ex"] = "界",
  ["std"] = "标",
  ["standard_ex_cards"] = "界限突破卡牌",
}

local U = require "packages/utility/utility"

local caocao = General(extension, "ex__caocao", "wei", 4)
local ex__jianxiong = fk.CreateTriggerSkill{
  name = "ex__jianxiong",
  anim_type = "masochism",
  events = {fk.Damaged},
  on_use = function(self, event, target, player, data)
    if data.card and U.hasFullRealCard(player.room, data.card) then
      player.room:obtainCard(player.id, data.card, true, fk.ReasonJustMove)
    end
    player:drawCards(1, self.name)
  end,
}
caocao:addSkill(ex__jianxiong)
caocao:addSkill("hujia")
Fk:loadTranslationTable{
  ["ex__caocao"] = "界曹操",
  ["#ex__caocao"] = "魏武帝",
  ["designer:ex__caocao"] = "韩旭",
  ["illustrator:ex__caocao"] = "青骑士",
  ["ex__jianxiong"] = "奸雄",
  [":ex__jianxiong"] = "当你受到伤害后，你可以获得对你造成伤害的牌并摸一张牌。",
  ["$ex__jianxiong1"] = "燕雀，安知鸿鹄之志！",
  ["$ex__jianxiong2"] = "夫英雄者，胸怀大志，腹有良谋！",
  ["$hujia_ex__caocao1"] = "大胆逆贼，谁可擒之！",
  ["$hujia_ex__caocao2"] = "护卫何在！",
  ["~ex__caocao"] = "华佗何在？……",
}

local simayi = General(extension, "ex__simayi", "wei", 3)
local ex__fankui = fk.CreateTriggerSkill{
  name = "ex__fankui",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from and not data.from.dead and not data.from:isNude()
  end,
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      if i > 1 and (self.cancel_cost or data.from.dead or data.from:isNude() or not player:hasSkill(self)) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askForSkillInvoke(player, self.name, data, "#ex__fankui-invoke::"..data.from.id) then
      room:doIndicate(player.id, {data.from.id})
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:askForCardChosen(player, data.from, "he", self.name)
    room:obtainCard(player, card, false, fk.ReasonPrey)
  end
}
local ex__guicai = fk.CreateTriggerSkill{
  name = "ex__guicai",
  anim_type = "control",
  events = {fk.AskForRetrial},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askForCard(player, 1, 1, true, self.name, true, ".|.|.|hand,equip",
    "#ex__guicai-ask::" .. target.id .. ":" .. data.reason)
    if #card > 0 then
      room:doIndicate(player.id, {target.id})
      self.cost_data = card[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:retrial(Fk:getCardById(self.cost_data), player, data, self.name)
  end,
}
simayi:addSkill(ex__fankui)
simayi:addSkill(ex__guicai)
Fk:loadTranslationTable{
  ["ex__simayi"] = "界司马懿",
  ["#ex__simayi"] = "狼顾之鬼",
  ["designer:ex__simayi"] = "韩旭",
  ["illustrator:ex__simayi"] = "木美人",
  ["ex__fankui"] = "反馈",
  [":ex__fankui"] = "当你受到1点伤害后，你可以获得来源的一张牌。",
  ["ex__guicai"] = "鬼才",
  [":ex__guicai"] = "当判定结果确定前，你可打出一张牌代替之。",

  ["#ex__fankui-invoke"] = "是否对%dest发动 反馈，获得其一张牌",
  ["#ex__guicai-ask"] = "是否发动 鬼才，打出一张牌代替 %dest 的 %arg 判定",

  ["$ex__guicai1"] = "天命难违？哈哈哈哈哈……",
  ["$ex__guicai2"] = "才通天地，逆天改命！",
  ["$ex__fankui1"] = "哼，自作孽不可活！",
  ["$ex__fankui2"] = "哼，正中下怀！",
  ["~ex__simayi"] = "我的气数，就到这里了么？",
}

local xiahoudun = General(extension, "ex__xiahoudun", "wei", 4)
local ex__ganglie = fk.CreateTriggerSkill{
  name = "ex__ganglie",
  anim_type = "masochism",
  events = {fk.Damaged},
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      if i > 1 and (self.cancel_cost or not player:hasSkill(self)) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if data.from and not data.from.dead then
      if room:askForSkillInvoke(player, self.name, data, "#ex__ganglie-invoke::"..data.from.id) then
        room:doIndicate(player.id, {data.from.id})
        return true
      end
    else
      if room:askForSkillInvoke(player, self.name, data) then
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
      reason = self.name,
      pattern = ".",
    }
    room:judge(judge)
    if not from or from.dead then return false end
    if judge.card.color == Card.Red then
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
local ex__qingjian = fk.CreateTriggerSkill{
  name = "ex__qingjian",
  anim_type = "support",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and
    not player:isNude() and player.phase ~= Player.Draw then
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Player.Hand then
          return true
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos, cards = room:askForChooseCardsAndPlayers(player, 1, 999,
    table.map(room:getOtherPlayers(player, false), Util.IdMapper), 1, 1, ".",
    "#ex__qingjian-invoke", self.name, true, true)
    if #tos > 0 and #cards > 0 then
      self.cost_data = {tos = tos, cards = cards}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local types = {}
    for _, id in ipairs(self.cost_data.cards) do
      table.insertIfNeed(types, Fk:getCardById(id).type)
    end
    room:moveCardTo(self.cost_data.cards, Player.Hand, room:getPlayerById(self.cost_data.tos[1]), fk.ReasonGive,
    self.name, nil, true, player.id)
    if not room.current.dead then
      room:addPlayerMark(room.current, MarkEnum.AddMaxCardsInTurn, #types)
    end
  end,
}
xiahoudun:addSkill(ex__ganglie)
xiahoudun:addSkill(ex__qingjian)
Fk:loadTranslationTable{
  ["ex__xiahoudun"] = "界夏侯惇",
  ["#ex__xiahoudun"] = "独眼的罗刹",
  ["illustrator:ex__xiahoudun"] = "DH",
  ["ex__ganglie"] = "刚烈",
  [":ex__ganglie"] = "当你受到1点伤害后，你可判定，若结果为：红色，你对来源造成1点伤害；黑色，你弃置来源的一张牌。",
  ["ex__qingjian"] = "清俭",
  [":ex__qingjian"] = "每回合限一次，当你于摸牌阶段外获得牌后，你可以展示任意张牌并交给一名其他角色。当前回合角色本回合手牌上限+X（X为你"..
  "展示牌的类别数）。",

  ["#ex__ganglie-invoke"] = "是否对%dest发动 刚烈，判红对其造成伤害，判黑弃其牌",
  ["#ex__qingjian-invoke"] = "是否发动 清俭，将任意张牌交给一名其他角色，并令当前回合角色手牌上限增加给出的类别数",

  ["$ex__ganglie1"] = "哪个敢动我！",
  ["$ex__ganglie2"] = "伤我者，十倍奉还！",
  ["$ex__qingjian1"] = "福生于清俭，德生于卑退。",
  ["$ex__qingjian2"] = "钱财，乃身外之物。",
  ["~ex__xiahoudun"] = "诸多败绩，有负丞相重托。",
}

local zhangliao = General(extension, "ex__zhangliao", "wei", 4)
local ex__tuxi = fk.CreateTriggerSkill{
  name = "ex__tuxi",
  anim_type = "control",
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.n > 0 and
      table.find(player.room:getOtherPlayers(player, false), function(p) return not p:isKongcheng() end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room:getOtherPlayers(player, false), function(p)
      return not p:isKongcheng() end), Util.IdMapper)
    local tos = room:askForChoosePlayers(player, targets, 1, data.n, "#ex__tuxi-choose:::"..data.n, self.name, true)
    if #tos > 0 then
       room:sortPlayersByAction(tos)
      self.cost_data = {tos = tos}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = table.simpleClone(self.cost_data.tos)
    for _, id in ipairs(tos) do
      local to = room:getPlayerById(id)
      if not (to.dead or to:isKongcheng()) then
        local c = room:askForCardChosen(player, to, "h", self.name)
        room:obtainCard(player, c, false, fk.ReasonPrey)
        if player.dead then break end
      end
    end
    data.n = data.n - #tos
  end,
}
zhangliao:addSkill(ex__tuxi)
Fk:loadTranslationTable{
  ["ex__zhangliao"] = "界张辽",
  ["#ex__zhangliao"] = "前将军",
  ["cv:ex__zhangliao"] = "金垚",
  ["illustrator:ex__zhangliao"] = "张帅",
  ["designer:ex__zhangliao"] = "韩旭",
  ["ex__tuxi"] = "突袭",
  [":ex__tuxi"] = "摸牌阶段，你可以少摸任意张牌并获得等量其他角色各一张手牌。",
  ["#ex__tuxi-choose"] = "突袭：你可以少摸至多%arg张牌，获得等量其他角色各一张手牌",

  ["$ex__tuxi1"] = "快马突袭，占尽先机！",
  ["$ex__tuxi2"] = "马似飞影，枪如霹雳！",
  ["~ex__zhangliao"] = "被敌人占了先机，呃。",
}

local xuchu = General(extension, "ex__xuchu", "wei", 4)
local ex__luoyi = fk.CreateTriggerSkill{
  name = "ex__luoyi",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Draw
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cids = room:getNCards(3)
    room:moveCardTo(cids, Card.Processing, nil, fk.ReasonJustMove, self.name, nil, true, player.id)
    local function clearRemain(ids)
      ids = table.filter(ids, function(id) return room:getCardArea(id) == Card.Processing end)
      room:moveCardTo(ids, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, nil, true, player.id)
    end
    local cards = {}
    for _, id in ipairs(cids) do
      local card = Fk:getCardById(id)
      if card.type == Card.TypeBasic or card.sub_type == Card.SubtypeWeapon or card.name == "duel" then
        table.insert(cards, id)
      end
    end
    if #cards > 0 and
      U.askforViewCardsAndChoice(player, cids, {"ex__luoyi_get", "Cancel"}, self.name, "#ex__luoyi-ask") == "ex__luoyi_get" then
      room:obtainCard(player, cards, true, fk.ReasonJustMove, player.id)
      if not player.dead then room:addPlayerMark(player, "@@ex__luoyi") end
      clearRemain(cids)
      return true
    end
    clearRemain(cids)
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@ex__luoyi") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@ex__luoyi", 0)
  end,
}
local ex__luoyi_delay = fk.CreateTriggerSkill{
  name = "#ex__luoyi_delay",
  mute = true,
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@ex__luoyi") > 0 and
      data.card and (data.card.trueName == "slash" or data.card.name == "duel") and
      player.room.logic:damageByCardEffect()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
}
ex__luoyi:addRelatedSkill(ex__luoyi_delay)
xuchu:addSkill(ex__luoyi)
Fk:loadTranslationTable{
  ["ex__xuchu"] = "界许褚",
  ["#ex__xuchu"] = "虎痴",
  ["illustrator:ex__xuchu"] = "巴萨小马",
  ["ex__luoyi"] = "裸衣",
  [":ex__luoyi"] = "摸牌阶段开始时，你亮出牌堆顶的三张牌，然后你可以获得其中的基本牌、武器牌和【决斗】。若如此做，你放弃摸牌，且直到你"..
  "下回合开始，你使用【杀】或【决斗】造成伤害+1。",

  ["ex__luoyi_get"] = "获得其中的基本牌、武器牌或【决斗】",
  ["@@ex__luoyi"] = "裸衣",
  ["#ex__luoyi_delay"] = "裸衣",
  ["#ex__luoyi-ask"] = "裸衣：请选择一项",

  ["$ex__luoyi1"] = "过来打一架，对，就是你！",
  ["$ex__luoyi2"] = "废话少说，放马过来吧！",
  ["~ex__xuchu"] = "丞相，末将尽力了！",
}

local ex__guojia = General(extension, "ex__guojia", "wei", 3)
ex__guojia:addSkill("tiandu")
local ex__yiji = fk.CreateTriggerSkill{
  name = "ex__yiji",
  anim_type = "masochism",
  events = {fk.Damaged},
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      if i > 1 and (self.cancel_cost or not player:hasSkill(self)) then return false end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(target, self.name, data) then return true end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(2, self.name)
    if player.dead or player:isKongcheng() then return end
    room:askForYiji(player, player:getCardIds("h"), room:getOtherPlayers(player, false), self.name, 0, 2)
  end
}
ex__guojia:addSkill(ex__yiji)
Fk:loadTranslationTable{
  ["ex__guojia"] = "界郭嘉",
  ["#ex__guojia"] = "早终的先知",
  ["illustrator:ex__guojia"] = "木美人",
  ["ex__yiji"] = "遗计",
  [":ex__yiji"] = "当你受到1点伤害后，你可以摸两张牌，然后你可以将至多两张手牌交给一至两名其他角色。",
  ["#ex__yiji-give"] = "遗计：将至多%arg张手牌分配给其他角色",
  ["$tiandu_ex__guojia1"] = "那，就这样吧。",
  ["$tiandu_ex__guojia2"] = "天意如此。",
  ["$ex__yiji1"] = "锦囊妙策，终定社稷。",
  ["$ex__yiji2"] = "依此计行，辽东可定。",
  ["~ex__guojia"] = "咳，咳咳咳。",
}

local ex__zhenji = General(extension, "ex__zhenji", "wei", 3, 3, General.Female)
local ex__luoshen = fk.CreateTriggerSkill{
  name = "ex__luoshen",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Start and player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    while true do
      local judge = {
        who = player,
        reason = self.name,
        pattern = ".|.|spade,club",
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
    return target == player and data.reason == "ex__luoshen" and
    data.card.color == Card.Black and player.room:getCardArea(data.card.id) == Card.Processing
  end,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(player, data.card, true, nil, player.id, "ex__luoshen", "@@ex__luoshen-inhand-turn")
  end,
}
local ex__luoshen_max = fk.CreateMaxCardsSkill{
  name = "#ex__luoshen_max",
  exclude_from = function(self, player, card)
    return card:getMark("@@ex__luoshen-inhand-turn") > 0
  end,
}
ex__luoshen:addRelatedSkill(ex__luoshen_obtain)
ex__luoshen:addRelatedSkill(ex__luoshen_max)
ex__zhenji:addSkill(ex__luoshen)
ex__zhenji:addSkill("qingguo")
Fk:loadTranslationTable{
  ["ex__zhenji"] = "界甄姬",
  ["#ex__zhenji"] = "薄幸的美人",
  ["illustrator:ex__zhenji"] = "Town",
  ["ex__luoshen"] = "洛神",
  [":ex__luoshen"] = "准备阶段开始时，你可以进行判定，当黑色判定牌生效后，你获得之并可以重复此流程。你以此法获得的牌在本回合不计入手牌上限。",

  ["@@ex__luoshen-inhand-turn"] = "洛神",

  ["$ex__luoshen1"] = "屏翳收风，川后静波。",
  ["$ex__luoshen2"] = "冯夷鸣鼓，女娲清歌。",
  ["$qingguo_ex__zhenji1"] = "肩若削成，腰如约素。",
  ["$qingguo_ex__zhenji2"] = "延颈秀项，皓质呈露。",
  ["~ex__zhenji"] = "出亦复何苦，入亦复何愁。",
}

local lidian = General(extension, "lidian", "wei", 3)
local xunxun = fk.CreateTriggerSkill{
  name = "xunxun",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ret = room:askForArrangeCards(player, self.name, {room:getNCards(4), "Bottom", "Top"}, "#xunxun", true, 0, {4, 2}, {0, 2})
    local top, bottom = ret[2], ret[1]
    for i = #top, 1, -1 do
      table.removeOne(room.draw_pile, top[i])
      table.insert(room.draw_pile, 1, top[i])
    end
    for i = 1, #bottom, 1 do
      table.removeOne(room.draw_pile, bottom[i])
      table.insert(room.draw_pile, bottom[i])
    end
    room:sendLog{
      type = "#GuanxingResult",
      from = player.id,
      arg = #top,
      arg2 = #bottom,
    }
  end,
}
local wangxi = fk.CreateTriggerSkill{
  name = "wangxi",
  events = {fk.Damage, fk.Damaged},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from and data.from ~= data.to and not (data.from.dead or data.to.dead)
  end,
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      if i > 1 and self.cancel_cost or not self:triggerable(event, target, player, data) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local to = event == fk.Damage and data.to or data.from
    local room = player.room
    if room:askForSkillInvoke(player, self.name, nil, "#wangxi-invoke::"..to.id) then
      room:doIndicate(player.id, {to.id})
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    room:notifySkillInvoked(player, self.name, event == fk.Damaged and "masochism" or "drawcard")
    local tos = {player.id}
    table.insertIfNeed(tos, data.from.id)
    table.insertIfNeed(tos, data.to.id)
    room:sortPlayersByAction(tos)
    for _, pid in ipairs(tos) do
      local to = room:getPlayerById(pid)
      if not to.dead then
        room:drawCards(to, 1, self.name)
      end
    end
  end
}
lidian:addSkill(xunxun)
lidian:addSkill(wangxi)
Fk:loadTranslationTable{
  ["lidian"] = "李典",
  ["#lidian"] = "深明大义",
  ["illustrator:lidian"] = "张帅",
  ["xunxun"] = "恂恂",
  [":xunxun"] = "摸牌阶段开始时，你可以观看牌堆顶的四张牌，将其中两张牌以任意顺序置于牌堆顶，其余以任意顺序置于牌堆底。",
  ["wangxi"] = "忘隙",
  [":wangxi"] = "当你对其他角色造成1点伤害后，或当你受到其他角色造成的1点伤害后，你可以与其各摸一张牌。",
  ["#xunxun"] = "恂恂：选择两张卡牌置于牌堆顶",
  ["#wangxi-invoke"] = "忘隙：你可以与 %dest 各摸一张牌",

  ["$xunxun1"] = "众将死战，非我之功。",
  ["$xunxun2"] = "爱兵如子，胜乃可全。",
  ["$wangxi1"] = "大丈夫，何拘小节。",
  ["$wangxi2"] = "前尘往事，莫再提起。",
  ["~lidian"] = "报国杀敌，虽死犹荣……",
}

local ex__liubei = General(extension, "ex__liubei", "shu", 4)
local ex__rende = fk.CreateActiveSkill{
  name = "ex__rende",
  anim_type = "support",
  min_card_num = 1,
  target_num = 1,
  prompt = "#ex__rende",
  card_filter = function(self, to_select, selected)
    return table.contains(Self:getCardIds("h"), to_select)
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and Fk:currentRoom():getPlayerById(to_select):getMark("_ex__rende-phase") == 0
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    local player = room:getPlayerById(effect.from)
    local cards = effect.cards
    local marks = player:getMark("_rende_cards-phase")
    room:moveCardTo(cards, Player.Hand, target, fk.ReasonGive, self.name, nil, false)
    room:addPlayerMark(player, "_rende_cards-phase", #cards)
    room:setPlayerMark(target, "_ex__rende-phase", 1)
    if marks < 2 and marks + #cards >= 2 then
      cards = U.getUniversalCards(room, "b", false)
      local use = U.askForUseRealCard(room, player, cards, nil, self.name, "#ex__rende-ask",
        {expand_pile = cards, bypass_times = false, extraUse = false}, true, true)
      if use then
        use = {
          card = Fk:cloneCard(use.card.name),
          from = player.id,
          tos = use.tos,
        }
        use.card.skillName = self.name
        room:useCard(use)
      end
    end
  end,
}
ex__liubei:addSkill(ex__rende)
ex__liubei:addSkill("jijiang")

Fk:loadTranslationTable{
  ["ex__liubei"] = "界刘备",
  ["#ex__liubei"] = "乱世的枭雄",
  ["illustrator:ex__liubei"] = "木美人",
  ["ex__rende"] = "仁德",
  [":ex__rende"] = "出牌阶段每名角色限一次，你可以将任意张手牌交给一名其他角色，每阶段你以此法给出第二张牌时，你可以视为使用一张基本牌。",
  ["#ex__rende"] = "仁德：将任意张手牌交给一名角色，若此阶段交出达到两张，你可以视为使用一张基本牌",
  ["#ex__rende-ask"] = "仁德：你可视为使用一张基本牌",

  ["$ex__rende1"] = "同心同德，救困扶危！",
  ["$ex__rende2"] = "施仁布泽，乃我大汉立国之本！",
  ["$jijiang_ex__liubei1"] = "哪位将军，替我拿下此贼！",
  ["$jijiang_ex__liubei2"] = "欺我军无人乎！",
  ["~ex__liubei"] = "汉室未兴，祖宗未耀，朕实不忍此时西去……",
}

local guanyu = General:new(extension, "ex__guanyu", "shu", 4)
local ex__wusheng = fk.CreateViewAsSkill{
  name = "ex__wusheng",
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#ex__wusheng",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    return Fk:getCardById(to_select).color == Card.Red
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return nil end
    local c = Fk:cloneCard("slash")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
}
local wusheng_targetmod = fk.CreateTargetModSkill{
  name = "#wusheng_targetmod",
  anim_type = "offensive",
  bypass_distances = function (self, player, skill, card)
    return player:hasSkill(ex__wusheng) and skill.trueName == "slash_skill" and card.suit == Card.Diamond
  end
}
local ex__yijue = fk.CreateActiveSkill{
  name = "ex__yijue",
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  prompt = "#ex__yijue",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, to_select)
    return to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
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
      room:addTableMark(to, "@@yijue-turn", from.id)
      room:addPlayerMark(to, MarkEnum.UncompulsoryInvalidity .. "-turn")
    else
      room:obtainCard(from, showCard, true, fk.ReasonPrey)
      if not to.dead and to:isWounded() then
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
    return player:getMark("@@yijue-turn") ~= 0
  end,
  prohibit_response = function(self, player, card)
    return player:getMark("@@yijue-turn") ~= 0
  end,
}
local yijue_trigger = fk.CreateTriggerSkill{
  name = "#yijue_trigger",
  mute = true,
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead and data.card and data.card.trueName == "slash" and data.card.suit == Card.Heart and
    table.contains(data.to:getTableMark("@@yijue-turn"), player.id) and not data.chain
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
}
ex__yijue:addRelatedSkill(yijue_trigger)
ex__yijue:addRelatedSkill(yijue_prohibit)
ex__wusheng:addRelatedSkill(wusheng_targetmod)
guanyu:addSkill(ex__wusheng)
guanyu:addSkill(ex__yijue)
Fk:loadTranslationTable{
  ["ex__guanyu"] = "界关羽",
  ["#ex__guanyu"] = "美髯公",
  ["cv:ex__guanyu"] = "扬羽Miro",-- 丁翔威
  ["illustrator:ex__guanyu"] = "俊西JUNC",

  ["ex__wusheng"] = "武圣",
  [":ex__wusheng"] = "①你可以将一张红色牌当做【杀】使用或打出。②你使用<font color='red'>♦</font>【杀】无距离限制",
  ["ex__yijue"] = "义绝",
  [":ex__yijue"] = "出牌阶段限一次，你可以弃置一张牌并令一名其他角色展示一张手牌。若此牌为黑色，则其直到回合结束不能使用或打出牌，"..
  "所有非锁定技失效，你对其使用的<font color='red'>♥</font>【杀】的伤害+1。若此牌为红色，则你获得此牌，可以令其回复1点体力。",
  ["#ex__wusheng"] = "武圣：你可以将红色牌当【杀】使用或打出",
  ["#ex__yijue"] = "义绝：弃置一张牌，令一名角色展示一张手牌",

  ["@@yijue-turn"] = "义绝",
  ["#yijue-show"] = "义绝：请展示一张手牌",
  ["#yijue-recover"] = "义绝：是否令%dest回复1点体力？",
  ["$ex__wusheng1"] = "刀锋所向，战无不克！",
  ["$ex__wusheng2"] = "逆贼，哪里走！",
  ["$ex__yijue1"] = "关某，向来恩怨分明！",
  ["$ex__yijue2"] = "恩已断，义当绝！",
  ["~ex__guanyu"] = "桃园一拜，恩义常在……",
}

local ex__paoxiao = fk.CreateTriggerSkill{
  name = "ex__paoxiao",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageCaused, fk.CardEffectCancelledOut},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if event == fk.CardEffectCancelledOut then
      return player == target and data.card.trueName == "slash" and player:hasSkill(self)
    elseif event == fk.DamageCaused then
      return player == target and data.card and data.card.trueName == "slash" and player.room.logic:damageByCardEffect() and
      player:getMark("@paoxiao-turn") > 0 and player:hasSkill(self)
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.CardEffectCancelledOut then
      player.room:addPlayerMark(player, "@paoxiao-turn")
    elseif event == fk.DamageCaused then
      data.damage = data.damage + player:getMark("@paoxiao-turn")
      player.room:setPlayerMark(player, "@paoxiao-turn", 0)
    end
  end,

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      data.card.trueName == "slash" and player:usedCardTimes("slash") > 1
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

local ex__paoxiao_target = fk.CreateTargetModSkill{
  name = "#ex__paoxiao_target",
  bypass_times = function(self, player, skill, scope)
    return player:hasSkill(ex__paoxiao) and skill.trueName == "slash_skill" and scope == Player.HistoryPhase
  end,
}
ex__paoxiao:addRelatedSkill(ex__paoxiao_target)
local ex__tishen = fk.CreateTriggerSkill{
  name = "ex__tishen",
  anim_type = "drawcard",
  frequency = Skill.Limited,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and player:isWounded() and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
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
    if not player.dead then
      player:drawCards(n, self.name)
    end
  end,
}
local zhangfei = General:new(extension, "ex__zhangfei", "shu", 4)
zhangfei:addSkill(ex__paoxiao)
zhangfei:addSkill(ex__tishen)
Fk:loadTranslationTable{
  ["ex__zhangfei"] = "界张飞",
  ["#ex__zhangfei"] = "万夫不当",
  ["cv:ex__zhangfei"] = "冷泉月夜",
  ["illustrator:ex__zhangfei"] = "SONGQIJIN",
  ["ex__paoxiao"] = "咆哮",
  [":ex__paoxiao"] = "锁定技，你使用【杀】无次数限制；当你使用的【杀】被抵消后，你本回合下次【杀】造成的伤害+1。",
  ["ex__tishen"] = "替身",
  [":ex__tishen"] = "限定技，准备阶段，若你已受伤，则你可以将体力值回复至上限，然后摸回复数值张牌。",
  ["@paoxiao-turn"] = "咆哮",
  ["#tishen-invoke"] = "替身: 你可以回复%arg点体力并摸%arg张牌",

  ["$ex__paoxiao1"] = "喝啊！",
  ["$ex__paoxiao2"] = "今，必斩汝马下！",
  ["$ex__tishen1"] = "欺我无谋，定要尔等血偿！",
  ["$ex__tishen2"] = "谁，还敢过来一战！？",
  ["~ex__zhangfei"] = "桃园一拜，此生…无憾……",
}

local ex__guanxing = fk.CreateTriggerSkill{
  name = "ex__guanxing",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
    (player.phase == Player.Start or (player.phase == Player.Finish and player:getMark("guanxing-turn") > 0))
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local result = room:askForGuanxing(player, room:getNCards(#room.alive_players < 4 and 3 or 5))
    if #result.top == 0 and player.phase == Player.Start then
      room:setPlayerMark(player, "guanxing-turn", 1)
    end
  end,
}
local zhugeliang = General(extension, "ex__zhugeliang", "shu", 3)
zhugeliang:addSkill(ex__guanxing)
zhugeliang:addSkill("kongcheng")

Fk:loadTranslationTable{
  ["ex__zhugeliang"] = "界诸葛亮",
  ["#ex__zhugeliang"] = "迟暮的丞相",
	["illustrator:ex__zhugeliang"] = "黑桃J&Thinking",

  ["ex__guanxing"] = "观星",
  [":ex__guanxing"] = "准备阶段，你可以观看牌堆顶5张牌（场上存活角色数小于4时改为3张），并以任意顺序置于牌堆顶或牌堆顶。若你将这些牌均放至"..
  "牌堆底，则结束阶段你可以发动〖观星〗。",

  ["$ex__guanxing1"] = "天星之变，吾窥探一二。",
  ["$ex__guanxing2"] = "星途莫测，细细推敲。",
  ["$kongcheng_ex__zhugeliang1"] = "淡然相对，转危为安。",
  ["$kongcheng_ex__zhugeliang2"] = "绝处逢生，此招慎用。",
  ["~ex__zhugeliang"] = "穷尽毕生，有憾无悔。",
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
    return (Fk.currentResponsePattern == nil and c.skill:canUse(Self, c)) or
      (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(c))
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
  anim_type = "control",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player.phase == Player.NotActive then
      for _, move in ipairs(data) do
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand and table.contains({fk.ReasonUse, fk.ReasonResonpse}, move.moveReason) then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:getCardById(room:getNCards(1)[1])
    local eType
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand and table.contains({fk.ReasonUse, fk.ReasonResonpse}, move.moveReason) then
            eType = move.moveReason == fk.ReasonUse and GameEvent.UseCard or GameEvent.RespondCard
            break
          end
        end
      end
    end
    local e = room.logic:getCurrentEvent():findParent(eType)
    if not e then return end
    local lost = e.data[1].card
    room:moveCardTo(card, Card.Processing, nil, fk.ReasonJustMove, self.name, nil, true, player.id)
    if card.type == lost.type then
      local to = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper), 1, 1,
        "#yajiao-card:::"..card:toLogString(), self.name, true)
      if #to > 0 then
        room:obtainCard(to[1], card, true, fk.ReasonGive, player.id, self.name)
      end
    else
      local targets = {}
      for _, p in ipairs(room.alive_players) do
        if not p:isAllNude() and p:inMyAttackRange(player) then
          table.insert(targets, p.id)
        end
      end
      if #targets > 0 then
        local to = room:askForChoosePlayers(player, targets, 1, 1, "#yajiao-choose", self.name, true)
        if #to > 0 then
          local throw = room:askForCardChosen(player, room:getPlayerById(to[1]), "hej", self.name)
          room:throwCard(throw, self.name, room:getPlayerById(to[1]), player)
        end
      end
    end
    if room:getCardArea(card) == Card.Processing then
      room:moveCardTo(card, Card.DrawPile, nil, fk.ReasonPutIntoDiscardPile, self.name, nil, true, player.id)
    end
  end,
}
local zhaoyun = General:new(extension, "ex__zhaoyun", "shu", 4)
zhaoyun:addSkill(ex__longdan)
zhaoyun:addSkill(yajiao)
Fk:loadTranslationTable{
  ["ex__zhaoyun"] = "界赵云",
  ["#ex__zhaoyun"] = "虎威将军",
	["illustrator:ex__zhaoyun"] = "DH",

  ["ex__longdan"] = "龙胆",
  [":ex__longdan"] = "你可以将一张【杀】当【闪】、【闪】当【杀】、【酒】当【桃】、【桃】当【酒】使用或打出。",
  ["yajiao"] = "涯角",
  [":yajiao"] = "当你于回合外因使用或打出而失去手牌后，你可以展示牌堆顶的一张牌。若这两张牌的类别相同，你可以将展示的牌交给一名角色；"..
  "若类别不同，你可弃置攻击范围内包含你的角色区域里的一张牌。",
  ["#yajiao-choose"] = "涯角: 选择一名攻击范围内包含你的角色弃置其区域内的一张牌",
  ["#yajiao-card"] = "涯角: 你可以将%arg交给一名角色",

  ["$ex__longdan1"] = "龙威虎胆，斩敌破阵！",
  ["$ex__longdan2"] = "进退自如，游刃有余！",
  ["$yajiao1"] = "遍寻天下，但求一败！",
  ["$yajiao2"] = "策马驱前，斩敌当先！",
  ["~ex__zhaoyun"] = "你们谁…还敢再上……",
}

local ex__tieji = fk.CreateTriggerSkill{
  name = "ex__tieji",
  anim_type = "offensive",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      data.card.trueName == "slash" and not player.room:getPlayerById(data.to).dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askForSkillInvoke(player, self.name, nil, "#ex__tieji-invoke::"..data.to) then
      room:doIndicate(player.id, {data.to})
      return true
    end
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
      if #room:askForDiscard(to, 1, 1, false, self.name, true, ".|.|"..table.concat(suits, ","),
        "#ex__tieji-discard:::"..judge.card:getSuitString()) == 0 then
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
  ["#ex__machao"] = "一骑当千",
	["illustrator:ex__machao"] = "木美人&张帅&KayaK",
  ["ex__tieji"] = "铁骑",
  [":ex__tieji"] = "当你使用【杀】指定目标后，你可以令其本回合内非锁定技失效，然后进行一次判定，其需弃置一张花色与判定结果花色相同的牌，"..
  "否则其无法响应此【杀】。",
  ["ex__tieji_invalidity"] = "铁骑",
  ["@@tieji-turn"] = "铁骑",
  ["#ex__tieji-invoke"] = "是否对%dest发动 铁骑，令其本回合内非锁定技失效",
  ["#ex__tieji-discard"] = "铁骑：你需弃置一张%arg牌，否则无法响应此杀。",

  ["$ex__tieji1"] = "目标敌阵，全军突击！",
  ["$ex__tieji2"] = "敌人阵型已乱，随我杀！",
  ["~ex__machao"] = "请将我，葬在西凉……",
}

local ex__jizhi = fk.CreateTriggerSkill{
  name = "ex__jizhi",
  anim_type = "drawcard",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.type == Card.TypeTrick and
    (not data.card:isVirtual() or #data.card.subcards == 0)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player:drawCards(1)
    if #cards == 0 then return false end
    local card = Fk:getCardById(cards[1])
    if card.type == Card.TypeBasic and not player.dead and player.phase ~= Player.NotActive and
    table.contains(player:getCardIds("h"), card.id) and not player:prohibitDiscard(card) and
    room:askForSkillInvoke(player, self.name, nil, "#jizhi-invoke:::"..card:toLogString()) then
      room:throwCard(card.id, self.name, player, player)
      room:addPlayerMark(player, MarkEnum.AddMaxCardsInTurn)
    end
  end,
}
local ex__qicai = fk.CreateTriggerSkill{
  name = "ex__qicai",
  events = {fk.BeforeCardsMove},
  frequency = Skill.Compulsory,
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) or
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
        arg = self.name,
      }
    end
  end,
}
local ex__qicai_target = fk.CreateTargetModSkill{
  name = "#ex__qicai_target",
  bypass_distances = function(self, player, skill, card)
    return player:hasSkill(ex__qicai) and card and card.type == Card.TypeTrick
  end,
}
ex__qicai:addRelatedSkill(ex__qicai_target)
local huangyueying = General(extension, "ex__huangyueying", "shu", 3, 3, General.Female)
huangyueying:addSkill(ex__jizhi)
huangyueying:addSkill(ex__qicai)

Fk:loadTranslationTable{
  ["ex__huangyueying"] = "界黄月英",
  ["#ex__huangyueying"] = "归隐的杰女",
  ["cv:ex__huangyueying"] = "水原", -- 卓思源
  ["illustrator:ex__huangyueying"] = "ASK",
  ["ex__jizhi"] = "集智",
  [":ex__jizhi"] = "当你使用锦囊牌时，你可以摸一张牌。若此牌为基本牌且此时是你的回合内，则你可以弃置之，然后令本回合手牌上限+1。",
  ["ex__qicai"] = "奇才",
  [":ex__qicai"] = "锁定技，你使用锦囊牌无距离限制；你装备区的宝物牌和防具牌不能被其他角色弃置。",
  ["@jizhi-turn"] = "集智",

  ["#jizhi-invoke"] = "集智：是否弃置%arg，令你本回合的手牌上限+1？",
  ["#cancelDismantle"] = "由于 %arg 的效果，%card 的弃置被取消",

  ["$ex__jizhi1"] = "得上通，智集心。",
  ["$ex__jizhi2"] = "集万千才智，致巧趣鲜用。",
  ["~ex__huangyueying"] = "我的面容，有吓到你吗？",
}

local std__xushu = General(extension, "std__xushu", "shu", 4)

local zhuhai = fk.CreateTriggerSkill{
  name = "zhuhai",
  events = {fk.EventPhaseStart},
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player ~= target and target.phase == Player.Finish and not target.dead and
    #player.room.logic:getActualDamageEvents(1, function(e)
      return e.data[1].from == target
    end, Player.HistoryTurn) > 0
  end,
  on_cost = function (self, event, target, player, data)
    local use = player.room:askForUseCard(player, self.name, "slash", "#zhuhai-ask::"..target.id, true,
      {bypass_times = true, bypass_distances = true, extraUse = true, must_targets = {target.id}})
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
    return target == player and player:hasSkill(self) and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player:isWounded()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    if not player.dead then
      room:handleAddLoseSkills(player, "jianyan", nil)
    end
  end,
}

local jianyan = fk.CreateActiveSkill{
  name = "jianyan",
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  prompt = "#jianyan",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  interaction = function()
    return UI.ComboBox {choices = {"black", "red", "basic", "trick", "equip"} }
  end,
  on_use = function(self, room, effect)
    local pattern = self.interaction.data
    if not pattern then pattern = "red" end -- for AI
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
      room:moveCardTo(id, Card.Processing, nil, fk.ReasonJustMove, self.name, nil, true, player.id)
      room:delay(300)
      local c = Fk:getCardById(id)
      if c:getColorString() == pattern or c:getTypeString() == pattern then
        card = c
        break
      else
        table.insert(cards, id)
      end
    end
    local targets = table.map(table.filter(room.alive_players, function(p)
      return p:isMale()
    end), Util.IdMapper)
    if #targets == 0 then
      table.insert(cards, card.id)
    else
      local target = room:askForChoosePlayers(player, targets, 1, 1, "#jianyan-give:::"..card:toLogString(), self.name, false)[1]
      room:moveCardTo(card.id, Player.Hand, room:getPlayerById(target), fk.ReasonGive, self.name, nil, true, player.id)
    end
    cards = table.filter(cards, function(id) return room:getCardArea(id) == Card.Processing end)
    if #cards > 0 then
      room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, nil, true, player.id)
    end
  end,
}

std__xushu:addSkill(zhuhai)
std__xushu:addSkill(qianxin)
std__xushu:addRelatedSkill(jianyan)

Fk:loadTranslationTable{
  ["std__xushu"] = "徐庶",
  ["#std__xushu"] = "化剑为犁",
	["illustrator:std__xushu"] = "Zero",

  ["zhuhai"] = "诛害",
  [":zhuhai"] = "其他角色结束阶段，若其本回合造成过伤害，你可以对其使用一张无距离限制的【杀】。",
  ["qianxin"] = "潜心",
  [":qianxin"] = "觉醒技，当你造成伤害后，若你已受伤，你减1点体力上限，并获得〖荐言〗。",
  ["jianyan"] = "荐言",
  [":jianyan"] = "出牌阶段限一次，你可以选择一种牌的类别或颜色，然后连续亮出牌堆顶的牌，直到亮出符合你声明的牌为止，你将此牌交给一名男性角色。",

  ["#zhuhai-ask"] = "诛害：你可以对 %dest 使用【杀】",
  ["#jianyan"] = "荐言：选择一种牌的类别或颜色，将牌堆第一张符合条件的牌交给一名男性角色",
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
  prompt = "#jijie",
  card_filter = Util.FalseFunc,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cids = room:getNCards(1, "bottom")
    room:askForYiji(player, cids, room.alive_players, self.name, 1, 1,
    "#jijie-give:::" .. Fk:getCardById(cids[1]):toLogString(), cids, false)
  end,
}
local jiyuan = fk.CreateTriggerSkill{
  name = "jiyuan",
  anim_type = "support",
  events = {fk.EnterDying, fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
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
        if not player:hasSkill(self) then break end
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
  ["#yijik"] = "礼仁同渡",
	["illustrator:yijik"] = "alien",

  ["jijie"] = "机捷",
  [":jijie"] = "出牌阶段限一次，你可以观看牌堆底的一张牌，将此牌交给一名角色。",
  ["jiyuan"] = "急援",
  [":jiyuan"] = "当一名角色进入濒死时或当你交给一名其他角色牌后，你可令其摸一张牌。",
  ["#jijie"] = "机捷：你可以观看牌堆底的一张牌，将之交给一名角色",
  ["#jijie-give"] = "机捷：将 %arg 交给一名角色",
  ["#jiyuan-trigger"] = "急援：你可令 %dest 摸一张牌",

  ["$jijie1"] = "一拜一起，未足为劳。",
  ["$jijie2"] = "识言观行，方能雍容风议。",
  ["$jiyuan1"] = "公若辞，必遭蔡瑁之害矣。",
  ["$jiyuan2"] = "形势危急，还请速行。",
  ["~yijik"] = "未能，救得刘公脱险……",
}

local sunquan = General(extension, "ex__sunquan", "wu", 4)
local ex__zhiheng = fk.CreateActiveSkill{
  name = "ex__zhiheng",
  anim_type = "drawcard",
  min_card_num = 1,
  target_num = 0,
  prompt = "#ex__zhiheng",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local hand = player:getCardIds(Player.Hand)
    local more = #hand > 0
    for _, id in ipairs(hand) do
      if not table.contains(effect.cards, id) then
        more = false
        break
      end
    end
    room:throwCard(effect.cards, self.name, player, player)
    if not player.dead then
      room:drawCards(player, #effect.cards + (more and 1 or 0), self.name)
    end
  end
}
local ex__jiuyuan = fk.CreateTriggerSkill{
  name = "ex__jiuyuan$",
  anim_type = "support",
  events = {fk.PreHpRecover},
  can_trigger = function(self, event, target, player, data)
    return
      target ~= player and
      player:hasSkill(self) and
      target.kingdom == "wu" and
      target.phase ~= Player.NotActive and
      target.hp >= player.hp and
      player:isWounded()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(target, self.name, nil, "#ex__jiuyuan-ask::"..player.id)
  end,
  on_use = function(self, event, target, player, data)
    player.room:recover{
      who = player,
      num = 1,
      skillName = self.name,
      recoverBy = target,
    }
    target:drawCards(1, self.name)
    return true
  end,
}
sunquan:addSkill(ex__zhiheng)
sunquan:addSkill(ex__jiuyuan)
Fk:loadTranslationTable{
  ["ex__sunquan"] = "界孙权",
  ["#ex__sunquan"] = "年轻的贤君",
	["illustrator:ex__sunquan"] = "凝聚永恒",
  ["ex__zhiheng"] = "制衡",
  [":ex__zhiheng"] = "出牌阶段限一次，你可以弃置任意张牌并摸等量的牌。若你以此法弃置了所有的手牌，你多摸一张牌。",
  ["ex__jiuyuan"] = "救援",
  [":ex__jiuyuan"] = "主公技，其他吴势力角色于其回合内回复体力时，若其体力值大于等于你，则其可以改为令你回复1点体力，然后其摸一张牌。",
  ["#ex__zhiheng"] = "制衡：你可以弃置任意张牌并摸等量的牌，若弃置了所有的手牌，多摸一张牌",
  ["#ex__jiuyuan-ask"] = "救援：你可以改为令 %dest 回复1点体力，然后你摸一张牌",
  ["$ex__zhiheng1"] = "不急不躁，稳谋应对。",
  ["$ex__zhiheng2"] = "制衡互牵，大局可安。",
  ["$ex__jiuyuan1"] = "你们真是朕的得力干将。",
  ["$ex__jiuyuan2"] = "有爱卿在，朕无烦忧。",
  ["~ex__sunquan"] = "锦绣江东，岂能失于我手……",
}

local ganning = General(extension, "ex__ganning", "wu", 4)
local fenwei = fk.CreateTriggerSkill{
  name = "fenwei",
  anim_type = "defensive",
  frequency = Skill.Limited,
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card.type == Card.TypeTrick and #AimGroup:getAllTargets(data.tos) > 1 and data.firstTarget and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local tos = player.room:askForChoosePlayers(player, AimGroup:getAllTargets(data.tos),
      1, #AimGroup:getAllTargets(data.tos), "#fenwei-choose:::"..data.card:toLogString(), self.name, true)
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
  ["#ex__ganning"] = "锦帆游侠",
	["illustrator:ex__ganning"] = "巴萨小马",
  ["fenwei"] = "奋威",
  [":fenwei"] = "限定技，当一张锦囊牌指定多个目标后，你可令此牌对其中任意个目标无效。",
  ["#fenwei-choose"] = "奋威：你可以令此%arg对任意个目标无效",
  ["$qixi_ex__ganning1"] = "弟兄们，准备动手！",
  ["$qixi_ex__ganning2"] = "你用不了这么多了！",
  ["$fenwei1"] = "奋勇当先，威名远扬！",
  ["$fenwei2"] = "哼！敢欺我东吴无人。",
  ["~ex__ganning"] = "别管我，继续上！",
}

local lvmeng = General(extension, "ex__lvmeng", "wu", 4)
local qinxue = fk.CreateTriggerSkill{
  name = "qinxue",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player.phase == Player.Start and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return (player:getHandcardNum() - player.hp > 2) or
      (#player.room.players > 7 and player:getHandcardNum() - player.hp > 1)
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
  ["#ex__lvmeng"] = "士别三日",
	["illustrator:ex__lvmeng"] = "樱花闪乱",
  ["qinxue"] = "勤学",
  [":qinxue"] = "觉醒技，准备阶段，若你的手牌数比体力值多3或更多（游戏人数大于7则改为2），你减1点体力上限，然后获得技能〖攻心〗。",

  ["$keji_ex__lvmeng1"] = "蓄力待时，不争首功。",
  ["$keji_ex__lvmeng2"] = "最好的机会，还在等着我。",
  ["$qinxue1"] = "兵书熟读，了然于胸。",
  ["$qinxue2"] = "勤以修身，学以报国。",
  ["$gongxin_ex__lvmeng1"] = "洞若观火，运筹帷幄。",
  ["$gongxin_ex__lvmeng2"] = "哼，早知如此。",
  ["~ex__lvmeng"] = "你，给我等着！",
}

local huanggai = General(extension, "ex__huanggai", "wu", 4)
local ex__kurou = fk.CreateActiveSkill{
  name = "ex__kurou",
  anim_type = "negative",
  card_num = 1,
  target_num = 0,
  prompt = "#ex__kurou",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, from, from)
    if not from.dead then
      room:loseHp(from, 1, self.name)
    end
  end,
}
local zhaxiang = fk.CreateTriggerSkill{
  name = "zhaxiang",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.HpLost},
  on_trigger = function(self, event, target, player, data)
    for i = 1, data.num do
      if i > 1 and not player:hasSkill(self) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(3, self.name)
    if player.phase == Player.Play then
      local room = player.room
      room:setPlayerMark(player, "@@zhaxiang-phase", 1)
      room:addPlayerMark(player, MarkEnum.SlashResidue.."-phase")
    end
  end,
}
local zhaxiang_delay = fk.CreateTriggerSkill{
  name = "#zhaxiang_delay",

  refresh_events = {fk.PreCardUse},
  can_refresh = function(self, event, target, player, data)
    return player == target and data.card.trueName == "slash" and data.card.color == Card.Red and
      player:usedSkillTimes("zhaxiang", Player.HistoryPhase) > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.disresponsiveList = table.map(player.room.alive_players, Util.IdMapper)
  end,
}
local zhaxiang_targetmod = fk.CreateTargetModSkill{
  name = "#zhaxiang_targetmod",
  bypass_distances =  function(self, player, skill, card)
    return card.trueName == "slash" and card.color == Card.Red and player:usedSkillTimes("zhaxiang", Player.HistoryPhase) > 0
  end,
}
zhaxiang:addRelatedSkill(zhaxiang_targetmod)
zhaxiang:addRelatedSkill(zhaxiang_delay)
huanggai:addSkill(ex__kurou)
huanggai:addSkill(zhaxiang)
Fk:loadTranslationTable{
  ["ex__huanggai"] = "界黄盖",
  ["#ex__huanggai"] = "轻身为国",
	["illustrator:ex__huanggai"] = "G.G.G.",
  ["ex__kurou"] = "苦肉",
  [":ex__kurou"] = "出牌阶段限一次，你可以弃置一张牌并失去1点体力。",
  ["zhaxiang"] = "诈降",
  [":zhaxiang"] = "锁定技，每当你失去1点体力，你摸三张牌，然后若此时是你的出牌阶段内，"..
  "则此阶段内你使用【杀】次数上限+1、使用红色【杀】无距离限制且不可被响应。",
  ["#ex__kurou"] = "苦肉：你可以弃置一张牌并失去1点体力",
  ["@@zhaxiang-phase"] = "诈降",

  ["$ex__kurou1"] = "我这把老骨头，不算什么！",
  ["$ex__kurou2"] = "为成大业，死不足惜！",
  ["$zhaxiang1"] = "铁锁连舟而行，东吴水师可破！",
  ["$zhaxiang2"] = "两军阵前，不斩降将！",
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
}
local ex__yingzi_maxcards = fk.CreateMaxCardsSkill{
  name = "#ex__yingzi_maxcards",
  main_skill = ex__yingzi,
  fixed_func = function(self, player)
    if player:hasShownSkill(ex__yingzi) then
      return player.maxHp
    end
  end
}
local ex__fanjian = fk.CreateActiveSkill{
  name = "ex__fanjian",
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  prompt = "#ex__fanjian",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) == Card.PlayerHand
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local cid = effect.cards[1]
    local player = room:getPlayerById(effect.from)
    player:showCards(cid)
    if player.dead then return end
    local suit = Fk:getCardById(cid).suit
    local suitString = Fk:getCardById(cid):getSuitString(true)
    local target = room:getPlayerById(effect.tos[1])
    room:obtainCard(target.id, cid, true, fk.ReasonGive)
    if target.dead then return end
    local choices = { "ex__fanjian_show:::" .. suitString, "loseHp" }
    if target.hp <= 0 then table.remove(choices) end
    if (target:isKongcheng() and table.every(target:getCardIds(Player.Equip), function (id)
      return Fk:getCardById(id).suit ~= suit
    end)) or suit == Card.NoSuit then table.remove(choices, 1) end
    if #choices == 0 then return end
    local choice = room:askForChoice(target, choices, self.name)
    if choice == "loseHp" then
      room:loseHp(target, 1, self.name)
    else
      local cards = target:getCardIds(Player.Hand)
      target:showCards(cards)
      room:delay(500)
      if target.dead then return end
      local discards = table.filter(target:getCardIds{ Player.Hand, Player.Equip }, function(id)
        return Fk:getCardById(id).suit == suit and not target:prohibitDiscard(Fk:getCardById(id))
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
  ["#ex__zhouyu"] = "大都督",
	["illustrator:ex__zhouyu"] = "KayaK",
  ["ex__yingzi"] = "英姿",
  [":ex__yingzi"] = "锁定技，摸牌阶段，你多摸一张牌；你的手牌上限等同于你的体力上限。",
  ["ex__fanjian"] = "反间",
  [":ex__fanjian"] = "出牌阶段限一次，你可以展示一张手牌并交给一名其他角色，然后其选择：1.展示所有手牌，弃置所有与你以展示的牌花色相同的牌；"..
  "2.失去1点体力。",
  ["#ex__fanjian"] = "反间：展示一张手牌并交给一名角色，其选择弃置所有此花色牌或失去1点体力",
  ["ex__fanjian_show"] = "展示手牌，弃置你所有的%arg牌",

  ["$ex__yingzi1"] = "哈哈哈哈哈哈哈哈！",
  ["$ex__yingzi2"] = "伯符，且看我这一手！",
  ["$ex__fanjian1"] = "与我为敌，就当这般生不如死！",
  ["$ex__fanjian2"] = "抉择吧！在苦与痛的地狱中！",
  ["~ex__zhouyu"] = "既生瑜，何生亮！……既生瑜，何生亮……！",
}

local daqiao = General(extension, "ex__daqiao", "wu", 3, 3, General.Female)
local ex__guose = fk.CreateActiveSkill{
  name = "ex__guose",
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  prompt = function (self)
    return "#"..self.interaction.data
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  interaction = function()
    return UI.ComboBox {choices = {"ex__guose_use" , "ex__guose_throw"}}
  end,
  card_filter = function(self, to_select, selected)
    if #selected > 0 or not self.interaction.data or Fk:getCardById(to_select).suit ~= Card.Diamond then return false end
    if self.interaction.data == "ex__guose_use" then
      local card = Fk:cloneCard("indulgence")
      card:addSubcard(to_select)
      return Self:canUse(card) and not Self:prohibitUse(card)
    else
      return not Self:prohibitDiscard(Fk:getCardById(to_select))
    end
  end,
  target_filter = function(self, to_select, selected, cards)
    if #cards ~= 1 or #selected > 0 or not self.interaction.data then return false end
    local target = Fk:currentRoom():getPlayerById(to_select)
    if self.interaction.data == "ex__guose_use" then
      local card = Fk:cloneCard("indulgence")
      card:addSubcard(cards[1])
      return to_select ~= Self.id and not Self:isProhibited(target, card)
    else
      return target:hasDelayedTrick("indulgence")
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    if self.interaction.data == "ex__guose_use" then
      room:useVirtualCard("indulgence", effect.cards, player, target, self.name)
    else
      room:throwCard(effect.cards, self.name, player, player)
      for _, id in ipairs(target.player_cards[Player.Judge]) do
        local card = target:getVirualEquip(id)
        if not card then card = Fk:getCardById(id) end
        if card.name == "indulgence" then
          room:throwCard({id}, self.name, target, player)
        end
      end
    end
    if not player.dead then
      player:drawCards(1, self.name)
    end
  end,
}
daqiao:addSkill(ex__guose)
daqiao:addSkill("liuli")
Fk:loadTranslationTable{
  ["ex__daqiao"] = "界大乔",
  ["#ex__daqiao"] = "矜持之花",
  ["designer:ex__daqiao"] = "韩旭",
	["illustrator:ex__daqiao"] = "DH",
  ["ex__guose"] = "国色",
  [":ex__guose"] = "出牌阶段限一次，你可以选择一项：1.将一张<font color='red'>♦</font>牌当【乐不思蜀】使用；"..
  "2.弃置一张<font color='red'>♦</font>牌并弃置场上的一张【乐不思蜀】。选择完成后，你摸一张牌。",
  ["#ex__guose_use"] = "国色：将一张<font color='red'>♦</font>牌当【乐不思蜀】使用，然后你摸一张牌",
  ["#ex__guose_throw"] = "国色：弃置<font color='red'>♦</font>牌并弃置场上一张【乐不思蜀】，然后你摸一张牌",
  ["ex__guose_use"] = "使用乐不思蜀",
  ["ex__guose_throw"] = "弃置乐不思蜀",

  ["$ex__guose1"] = "旅途劳顿，请下马休整吧~",
  ["$ex__guose2"] = "还没到休息的时候！",
  ["$liuli_ex__daqiao1"] = "帮帮人家嘛~",
  ["$liuli_ex__daqiao2"] = "伯符不在身边，我要自己保重！",
  ["~ex__daqiao"] = "伯符，再也没人能欺负我了……",
}

local ex__luxun = General(extension, "ex__luxun", "wu", 3)
local ex__qianxun = fk.CreateTriggerSkill{
  name = "ex__qianxun",
  events = {fk.CardEffecting},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and data.from ~= player.id and data.card.type == Card.TypeTrick and
    U.isOnlyTarget(player, data, event) and not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    player:addToPile("$ex__qianxun", player:getCardIds("h"), false, self.name)
  end,
}
local ex__qianxun_delay = fk.CreateTriggerSkill{
  name = "#ex__qianxun_delay",
  mute = true,
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return #player:getPile("$ex__qianxun") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(player.id, player:getPile("$ex__qianxun"), false)
  end,
}
local ex__lianying = fk.CreateTriggerSkill{
  name = "ex__lianying",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(self) and player:isKongcheng()) then return false end
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            return true
          end
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local n = 0
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            n = n + 1
          end
        end
      end
    end
    local players = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper), 1, n,
      "#ex__lianying-invoke:::"..n, self.name)
    if #players > 0 then
      room:sortPlayersByAction(players)
      self.cost_data = {tos = players}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, pid in ipairs(self.cost_data.tos) do
      local p = room:getPlayerById(pid)
      if not p.dead then p:drawCards(1, self.name) end
    end
  end,
}
ex__qianxun:addRelatedSkill(ex__qianxun_delay)
ex__luxun:addSkill(ex__qianxun)
ex__luxun:addSkill(ex__lianying)

Fk:loadTranslationTable{
  ["ex__luxun"] = "界陆逊",
  ["#ex__luxun"] = "儒生雄才",
  ["designer:ex__luxun"] = "韩旭",
	["illustrator:ex__luxun"] = "depp",
  ["ex__qianxun"] = "谦逊",
  [":ex__qianxun"] = "当一张延时锦囊牌或其他角色使用的普通锦囊牌对你生效时，若你是此牌唯一目标，则你可以将所有手牌扣置于武将牌上，然后此回合结束时，你获得这些牌。",
  ["ex__lianying"] = "连营",
  [":ex__lianying"] = "当你失去手牌后，若你没有手牌，则你可以令至多X名角色各摸一张牌（X为你此次失去的手牌数）。",
  ["#ex__lianying-invoke"] = "连营：你可令至多%arg名角色摸一张牌",
  ["$ex__qianxun"] = "谦逊",
  ["#ex__qianxun_delay"] = "谦逊",

  ["$ex__qianxun1"] = "满招损，谦受益。",
  ["$ex__qianxun2"] = "谦谦君子，温润如玉。",
  ["$ex__lianying1"] = "生生不息，源源不绝。",
  ["$ex__lianying2"] = "失之淡然，得之坦然。",
  ["~ex__luxun"] = "我的未竟之业……",
}

local sunshangxiang = General(extension, "ex__sunshangxiang", "wu", 3, 3, General.Female)
local ex__jieyin = fk.CreateActiveSkill{
  name = "ex__jieyin",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#ex__jieyin",
  interaction = function()
    return UI.ComboBox {choices = {"ex__jieyin_discard" , "ex__jieyin_put"}}
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    if #selected > 0 or not self.interaction.data then return false end
    if self.interaction.data == "ex__jieyin_put" then
      return Fk:getCardById(to_select).type == Card.TypeEquip
    else
      return not Self:prohibitDiscard(Fk:getCardById(to_select)) and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
    end
  end,
  target_filter = function(self, to_select, selected, cards)
    if #cards ~= 1 or #selected > 0 or (not self.interaction.data) or to_select == Self.id then return false end
    local target = Fk:currentRoom():getPlayerById(to_select)
    return target:isMale() and (self.interaction.data == "ex__jieyin_discard" or
      target:hasEmptyEquipSlot(Fk:getCardById(cards[1]).sub_type))
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    if self.interaction.data == "ex__jieyin_put" then
      room:moveCards({
        ids = effect.cards,
        from = effect.from,
        to = effect.tos[1],
        toArea = Card.PlayerEquip,
        moveReason = fk.ReasonPut,
      })
    else
      room:throwCard(effect.cards, self.name, from, from)
    end
    if to.hp < from.hp then
      if to:isWounded() and not to.dead then
        room:recover({
          who = to,
          num = 1,
          recoverBy = from,
          skillName = self.name
        })
      end
      if not from.dead then
        from:drawCards(1, self.name)
      end
    elseif to.hp > from.hp then
      if from:isWounded() and not from.dead then
        room:recover({
          who = from,
          num = 1,
          recoverBy = from,
          skillName = self.name
        })
      end
      if not to.dead then
        to:drawCards(1, self.name)
      end
    end
  end,
}
sunshangxiang:addSkill(ex__jieyin)
sunshangxiang:addSkill("xiaoji")
Fk:loadTranslationTable{
  ["ex__sunshangxiang"] = "界孙尚香",
  ["#ex__sunshangxiang"] = "弓腰姬",
  ["cv:ex__sunshangxiang"] = "虫虫", -- 张甄妮
  ["illustrator:ex__sunshangxiang"] = "Thinking",

  ["ex__jieyin"] = "结姻",
  [":ex__jieyin"] = "出牌阶段限一次，你可以弃置一张手牌并选择一名其他男性角色，或者将一张装备牌置入一名其他男性角色的装备区，"..
  "然后你与其体力值较少的角色回复1点体力，较多的角色摸一张牌。",
  ["#ex__jieyin"] = "结姻：弃一张手牌或将一张装备置入一名角色装备区，然后你与其体力值较少的角色回复1点体力，较多的角色摸一张牌",
  ["ex__jieyin_discard"] = "弃置手牌",
  ["ex__jieyin_put"] = "置入装备",

  ["$ex__jieyin1"] = "随夫嫁娶，宜室宜家。",
  ["$ex__jieyin2"] = "得遇夫君，妾身福分。",
  ["$xiaoji_ex__sunshangxiang1"] = "剑利弓急，你可打不过我的。",
  ["$xiaoji_ex__sunshangxiang2"] = "我会的武器，可多着呢。",
  ["~ex__sunshangxiang"] = "哎呀，这次弓箭射歪了。",
}

local huatuo = General(extension, "ex__huatuo", "qun", 3)
local ex__chuli = fk.CreateActiveSkill{
  name = "ex__chuli",
  anim_type = "control",
  card_num = 0,
  min_target_num = 1,
  prompt = "#ex__chuli",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return to_select ~= Self.id and not target:isNude() and
      table.every(selected, function(id) return target.kingdom ~= Fk:currentRoom():getPlayerById(id).kingdom end)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:sortPlayersByAction(effect.tos)
    table.insert(effect.tos, 1, effect.from)
    local draw = {}
    for _, id in ipairs(effect.tos) do
      if player.dead then break end
      local target = room:getPlayerById(id)
      if not target:isNude() then
        local cards = (target == player) and room:askForDiscard(player, 1, 1, true, self.name, false, ".", nil, true) or
        {room:askForCardChosen(player, target, "he", self.name, "#ex__chuli-discard::"..target.id)}
        if #cards > 0 then
          room:throwCard(cards, self.name, target, player)
          if Fk:getCardById(cards[1]).suit == Card.Spade then
            table.insert(draw, target)
          end
        end
      end
    end
    for _, p in ipairs(draw) do
      if not p.dead then
        p:drawCards(1, self.name)
      end
    end
  end,
}
huatuo:addSkill("jijiu")
huatuo:addSkill(ex__chuli)
Fk:loadTranslationTable{
  ["ex__huatuo"] = "界华佗",
  ["designer:ex__huatuo"] = "韩旭",
  ["#ex__huatuo"] = "神医",
  ["illustrator:ex__huatuo"] = "琛·美第奇",
  ["ex__chuli"] = "除疠",
  [":ex__chuli"] = "出牌阶段限一次，你可以选择任意名势力各不相同的其他角色，然后你弃置你和这些角色的各一张牌。被弃置♠牌的角色各摸一张牌。",
  ["#ex__chuli"] = "除疠：选择任意名势力不同的角色，弃置你和这些角色各一张牌，被弃置♠牌的角色摸一张牌",
  ["#ex__chuli-discard"] = "除疠：弃置 %dest 一张牌",

  ["$jijiu_ex__huatuo1"] = "救死扶伤，悬壶济世。",
  ["$jijiu_ex__huatuo2"] = "妙手仁心，药到病除。",
  ["$ex__chuli1"] = "病去，如抽丝。",
  ["$ex__chuli2"] = "病入膏肓，需下猛药。",
  ["~ex__huatuo"] = "生老病死，命不可违。",
}

local lvbu = General(extension, "ex__lvbu", "qun", 5)

local liyu = fk.CreateTriggerSkill{
  name = "liyu",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash"
    and data.to ~= player and not data.to.dead and not data.to:isAllNude()
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
      if not to.dead then
        to:drawCards(1, self.name)
      end
    else
      local card = Fk:cloneCard("duel")
      if player:prohibitUse(card) then return false end
      local targets = table.filter(room.alive_players, function(p)
        return not player:isProhibited(p, card) and p ~= player and p ~= to
      end)
      if #targets == 0 then return false end
      local victim = room:askForChoosePlayers(to, table.map(targets, Util.IdMapper), 1, 1,
        "#liyu-ask:" .. player.id, self.name, false)[1]
      room:useVirtualCard("duel", nil, player, room:getPlayerById(victim), self.name)
    end
  end,
}
lvbu:addSkill(liyu)
lvbu:addSkill("wushuang")
Fk:loadTranslationTable{
  ["ex__lvbu"] = "界吕布",
  ["#ex__lvbu"] = "武的化身",
  ["cv:ex__lvbu"] = "金垚",
  ["illustrator:ex__lvbu"] = "张帅",
  ["liyu"] = "利驭",
  [":liyu"] = "当你使用【杀】对一名其他角色造成伤害后，你可获得其区域里的一张牌。然后若获得的牌不是装备牌，其摸一张牌；若获得的牌是装备牌，"..
  "则视为你对由其指定的另一名其他角色使用一张【决斗】。",

  ["#liyu-invoke"] = "利驭：你可获得 %dest 区域里的一张牌",
  ["#liyu-ask"] = "利驭：选择一名角色，视为 %src 对其使用【决斗】",

  ["$wushuang_ex__lvbu1"] = "还有哪个敢挑战我！？",
  ["$wushuang_ex__lvbu2"] = "三个齐上，也不是我的对手！",
  ["$liyu1"] = "人不为己，天诛地灭。",
  ["$liyu2"] = "大丈夫，相时而动。",
  ["~ex__lvbu"] = "我竟然输了……不可能！",
}

local ex__biyue = fk.CreateTriggerSkill{
  name = "ex__biyue",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
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
  ["#ex__diaochan"] = "绝世的舞姬",
  ["cv:ex__diaochan"] = "虫虫",
  ["illustrator:ex__diaochan"] = "木美人",
  ["ex__biyue"] = "闭月",
  [":ex__biyue"] = "结束阶段，你可以摸一张牌，若你没有手牌则改为两张。",

  ["$lijian_ex__diaochan1"] = "赢家，才能得到我~",
  ["$lijian_ex__diaochan2"] = "这场比赛，将军可要赢哦~",
  ["$ex__biyue1"] = "梦蝶幻月，如沫虚妄。",
  ["$ex__biyue2"] = "水映月明，芙蓉照倩影。",
  ["~ex__diaochan"] = "我的任务，终于完成了……",
}

local huaxiong = General(extension, "std__huaxiong", "qun", 6)
local yaowu = fk.CreateTriggerSkill{
  name = "yaowu",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash"
    and (data.card.color ~= Card.Red or (data.from and not data.from.dead))
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.card.color ~= Card.Red then
      room:notifySkillInvoked(player, self.name, "masochism")
      player:broadcastSkillInvoke(self.name, 1)
      player:drawCards(1, self.name)
    else
      room:notifySkillInvoked(player, self.name, "negative")
      player:broadcastSkillInvoke(self.name, 2)
      local from = data.from
      local choices = {"draw1"}
      if from:isWounded() then
        table.insert(choices, "recover")
      end
      local choice = room:askForChoice(from, choices, self.name)
      if choice == "recover" then
        room:recover({
          who = from,
          num = 1,
          recoverBy = from,
          skillName = self.name,
        })
      else
        from:drawCards(1, self.name)
      end
    end
  end
}
huaxiong:addSkill(yaowu)
Fk:loadTranslationTable{
  ["std__huaxiong"] = "华雄",
  ["#std__huaxiong"] = "飞扬跋扈",
  ["illustrator:std__huaxiong"] = "地狱许",

  ["yaowu"] = "耀武",
  [":yaowu"] = "锁定技，当你受到【杀】造成的伤害时，若此【杀】为红色，伤害来源回复1点体力或摸一张牌；若此【杀】不为红色，你摸一张牌。",

  ["$yaowu1"] = "大人有大量，不和你计较！",
  ["$yaowu2"] = "哼，先让你尝点甜头！",
  ["~std__huaxiong"] = "这，怎么可能……",
}

local std__yuanshu = General(extension, "std__yuanshu", "qun", 4)
local wangzun = fk.CreateTriggerSkill{
  name = "wangzun",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target.phase == Player.Start and player:hasSkill(self) and target.role == "lord"
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
    if not target.dead and target:getMaxCards() > 0 then
      player.room:addPlayerMark(target, MarkEnum.MinusMaxCardsInTurn)
    end
  end,
}
local tongji = fk.CreateProhibitSkill{
  name = "tongji",
  is_prohibited = function(self, from, to, card)
    local targets = table.filter(Fk:currentRoom().alive_players, function(p)
      return p:hasSkill(self) and p:getHandcardNum() > p.hp and from:inMyAttackRange(p)
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
    return target == player and player:hasSkill(tongji) and player:getHandcardNum() > player.hp and
      data.card and data.card.trueName == "slash"
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
  ["#std__yuanshu"] = "野心渐增",
  ["illustrator:std__yuanshu"] = "LiuHeng",

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

local gongsunzan = General(extension, "std__gongsunzan", "qun", 4)
local qiaomeng = fk.CreateTriggerSkill{
  name = "qiaomeng",
  events = {fk.Damage},
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash" and
      not data.to.dead and #data.to:getCardIds("e") > 0 and data.card.color == Card.Black
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
    local record = player:getMark("_qiaomeng") ~= 0 and player:getMark("_qiaomeng") or {}
    table.forEach(cids, function(cid)
      table.removeOne(record, cid)
    end)
    if #record == 0 then record = 0 end
    room:setPlayerMark(player, "_qiaomeng", record)
    room:obtainCard(player, cids, true, fk.ReasonPrey)
  end,
}
qiaomeng:addRelatedSkill(qiaomeng_get)
gongsunzan:addSkill(qiaomeng)
gongsunzan:addSkill("yicong")
Fk:loadTranslationTable{
  ["std__gongsunzan"] = "公孙瓒",
  ["#std__gongsunzan"] = "白马将军",
  ["illustrator:std__gongsunzan"] = "Vincent",

  ["qiaomeng"] = "趫猛",
  [":qiaomeng"] = "当你使用的黑色【杀】对一名角色造成伤害后，你可以弃置其装备区里的一张牌。当此牌移至弃牌堆后，若此牌为坐骑牌，你获得此牌。",
  ["#qiaomeng_get"] = "趫猛",

  ["$qiaomeng1"] = "秣马厉兵，枕戈待战。",
  ["$qiaomeng2"] = "夺敌辎重，以为己用。",
  ["$yicong_std__gongsunzan1"] = "列阵锋矢，直取要害。",
  ["$yicong_std__gongsunzan2"] = "变阵冲轭，以守代攻。",
  ["~std__gongsunzan"] = "皇图霸业梦，付之，一炬中……",	
}

local panfeng = General(extension, "std__panfeng", "qun", 4)
local std__kuangfu = fk.CreateTriggerSkill{
  name = "std__kuangfu",
  events = {fk.Damage},
  frequency = Skill.Compulsory,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash" and
      player.phase == Player.Play and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not data.to.dead
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
  ["#std__panfeng"] = "联军上将",
  ["std__kuangfu"] = "狂斧",
  [":std__kuangfu"] = "锁定技，每阶段限一次，当你于出牌阶段使用【杀】对其他角色造成伤害后，若其体力值：小于你，你摸两张牌；"..
  "不小于你，你失去1点体力。",

  ["$std__kuangfu1"] = "吾乃上将潘凤，可斩华雄！",
  ["$std__kuangfu2"] = "这家伙还是给我用吧！",
  ["~std__panfeng"] = "潘凤又被华雄斩了……",
}

local extension_card = Package("standard_ex_cards", Package.CardPack)
extension_card.extensionName = "standard_ex"
local role__wooden_ox_trigger = fk.CreateTriggerSkill{
  name = "#role__wooden_ox_trigger",
  global = true,
  mute = true,
  refresh_events = {fk.AfterCardsMove},
  can_refresh = function (self, event, target, player, data)
    return player == player.room.players[1]
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local moveInfos = {}
    for _, move in ipairs(data) do
      for _, info in ipairs(move.moveInfo) do
        if Fk:getCardById(info.cardId).name == "role__wooden_ox" then
          local from = move.from and room:getPlayerById(move.from)
          local to = move.to and room:getPlayerById(move.to)
          -- 处理木牛移出装备区
          if info.fromArea == Card.PlayerEquip and from and #from:getPile("$role_carriage&") > 0 then
            local ids = from:getPile("$role_carriage&")
            if move.toArea == Card.PlayerEquip and to and not to.dead then
              -- 若木马进入装备区，“辎”移动到他的私人牌堆
              table.insert(moveInfos, {
                -- 新建move需要写ids不需要写moveInfo，插入move需要写moveInfo不需要写ids
                ids = ids,
                moveInfo = table.map(ids, function(id)
                  return {cardId = id,fromArea = Card.PlayerSpecial,fromSpecialName = "$role_carriage&"}
                end),
                from = move.from,
                toArea = Card.PlayerSpecial,
                to = move.to,
                moveReason = fk.ReasonPut,
                skillName = self.name,
                specialName = "$role_carriage&",
                moveVisible = false,
                visiblePlayers = {from.id, to.id},
              })
            elseif move.toArea == Card.Processing then
              -- 如果木马进入处理区，先把“辎”移动到处理区
              table.insert(moveInfos, {
                ids = ids,
                moveInfo = table.map(ids, function(id)
                  return {cardId = id,fromArea = Card.PlayerSpecial,fromSpecialName = "$role_carriage&"}
                end),
                from = move.from,
                toArea = Card.Processing,
                moveReason = fk.ReasonPut,
                skillName = self.name,
                moveVisible = false,
                visiblePlayers = {from.id},
              })
              room:setCardMark(Fk:getCardById(info.cardId), "role__wooden_ox_processing", {
                from = from.id, ids = ids
              })
            else
              -- 其他情况下，“辎”牌置入弃牌堆
              table.insert(moveInfos, {
                ids = ids,
                moveInfo = table.map(ids, function(id)
                  return {cardId = id,fromArea = Card.PlayerSpecial,fromSpecialName = "$role_carriage&"}
                end),
                from = move.from,
                toArea = Card.DiscardPile,
                moveReason = fk.ReasonPutIntoDiscardPile,
                skillName = self.name,
                moveVisible = true,
              })
            end
          end
          -- 处理木牛移出处理区
          local mark = Fk:getCardById(info.cardId):getMark("role__wooden_ox_processing")
          if info.fromArea == Card.Processing and type(mark) == "table" then
            local ids = table.filter(mark.ids, function (id)
              return room:getCardArea(id) == Card.Processing
            end)
            room:setCardMark(Fk:getCardById(info.cardId), "role__wooden_ox_processing", 0)
            if #ids > 0 then
              if move.toArea == Card.PlayerEquip and to and not to.dead then
                -- 若木马进入装备区，“辎”移动到他的私人牌堆
                table.insert(moveInfos, {
                  ids = ids,
                  moveInfo = table.map(ids, function(id)
                    return {cardId = id, fromArea = Card.Processing}
                  end),
                  toArea = Card.PlayerSpecial,
                  to = move.to,
                  moveReason = fk.ReasonPut,
                  skillName = self.name,
                  specialName = "$role_carriage&",
                  moveVisible = false,
                  visiblePlayers = {mark.from, to.id},
                })
              else
                -- 其他情况下，“辎”牌置入弃牌堆
                table.insert(moveInfos, {
                  ids = ids,
                  moveInfo = table.map(ids, function(id)
                    return {cardId = id, fromArea = Card.Processing}
                  end),
                  toArea = Card.DiscardPile,
                  moveReason = fk.ReasonPutIntoDiscardPile,
                  skillName = self.name,
                  moveVisible = true,
                })
              end
            end
          end
        end
      end
    end
    if #moveInfos > 0 then
      local e = room.logic:getCurrentEvent():findParent(GameEvent.MoveCards, true)
      if e then
        -- 不要在refresh里执行移动操作，改为延时进行
        -- addExitFunc会被shutdown中断，addCleaner不会
        e:addExitFunc(function()
          room:moveCards(table.unpack(moveInfos))
        end)
      end
    end
  end,
}
Fk:addSkill(role__wooden_ox_trigger)

local role__wooden_ox_skill = fk.CreateActiveSkill{
  name = "role__wooden_ox_skill",
  attached_equip = "role__wooden_ox",
  prompt = "#role__wooden_ox-prompt",
  can_use = function(self, player, card)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng() and #player:getPile("$role_carriage&") < 5
  end,
  card_num = 1,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and table.contains(Self.player_cards[Player.Hand], to_select)
  end,
  target_num = 0,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:addToPile("$role_carriage&", effect.cards[1], false, self.name)
    if player.dead then return end
    local targets = table.filter(room:getOtherPlayers(player), function(p) return p:hasEmptyEquipSlot(Card.SubtypeTreasure) end)
    local ox = table.find(player:getCardIds("e"), function (id) return Fk:getCardById(id).name == "role__wooden_ox" end)
    if ox and #targets > 0 then
      local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, "#role__wooden_ox-move", self.name, true)
      if #tos > 0 then
        local to = room:getPlayerById(tos[1])
        room:moveCardTo(ox, Card.PlayerEquip, to, fk.ReasonPut, self.name, nil, true, player.id, nil)
      end
    end
  end,
}
Fk:addSkill(role__wooden_ox_skill)
local role__wooden_ox = fk.CreateTreasure{
  name = "role__wooden_ox",
  suit = Card.Diamond,
  number = 5,
  equip_skill = role__wooden_ox_skill,
}
extension_card:addCard(role__wooden_ox)
Fk:loadTranslationTable{
  ["role__wooden_ox"] = "木牛流马",
  [":role__wooden_ox"] = "装备牌·宝物<br/><b>宝物技能</b>：<br/>" ..
  "1. 出牌阶段限一次，你可将一张手牌置入仓廪（称为“辎”，“辎”数至多为5），然后你可将装备区里的【木牛流马】置入一名其他角色的装备区。<br/>" ..
  "2. 你可如手牌般使用或打出“辎”。<br/>" ..
  "3. 当你并非因交换而失去装备区里的【木牛流马】前，若目标区域不为其他角色的装备区，当你失去此牌后，你将所有“辎”置入弃牌堆。"..
  "<br><b>目前“辎”无法被转化使用</b>",
  ["role__wooden_ox_skill"] = "木牛",
  [":role__wooden_ox_skill"] = "出牌阶段限一次，你可将一张手牌置入仓廪（称为“辎”，“辎”至多有5张），然后你可将装备区里的【木牛流马】置入一名"..
  "其他角色的装备区。你可如手牌般使用或打出“辎”。",
  ["#role__wooden_ox-move"] = "你可以将【木牛流马】移动至一名其他角色的装备区",
  ["$role_carriage&"] = "辎",
  ["new_role_cards"] = "新身份模式卡牌",
  ["#role__wooden_ox_trigger"] = "木牛流马",
  ["#role__wooden_ox-prompt"] = "你可以将一张手牌扣置于【木牛流马】下",
}

Fk:loadTranslationTable(require 'packages/standard_ex/i18n/en_US', 'en_US')

return {extension, extension_card}
