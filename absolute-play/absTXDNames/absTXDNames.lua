script_name("absTXDNames")
script_author("1NS")
script_url("https://github.com/ins1x/moonloader-scripts")
script_dependencies('samp-events')
script_description("Adds names for objects and textures in the map editor on Absolute Play")
-- script_moonloader(16) moonloader v.0.26
-- tested on sa-mp client version: 0.3.7 R1
-- activation: auto
local sampev = require 'lib.samp.events'
local encoding = require 'encoding'
encoding.default = 'CP1251'

local absTxdNames = {
   "invalid", "vent_64", "alleydoor3", "sw_wallbrick_01", "sw_door11",
   "newall4-4", "rest_wall4", "crencouwall1", "mp_snow", "mottled_grey_64HV",
   "marblekb_256128", "Marble2", "Marble", "DinerFloor", "concretebig3_256",
   "Bow_Abattoir_Conc2", "barbersflr1_LA", "ws_green_wall1", "ws_stationfloor",
   "Slabs", "Road_blank256HV", "gun_ceiling3", "dts_elevator_carpet2",
   "cj_white_wall2", "cj_sheetmetal2", "CJ_RUBBER", "CJ_red_COUNTER", "CJ_POLISHED",
   "cj_juank_1", "CJ_G_CHROME", "cj_chromepipe", "CJ_CHROME2", "CJ_CHIP_M2",
   "CJ_BLACK_RUB2", "ceiling_256", "bigbrick", "airportmetalwall256", "CJ_BANDEDMETAL",
   "sky33_64hv", "plainwoodoor2", "notice01_128", "newall15128", "KeepOut_64",
   "HospitalCarPark_64", "hospitalboard_128a", "fire_exit128", "dustyconcrete128",
   "cutscenebank128", "concretenew256", "banding9_64HV", "AmbulanceParking_64",
   "Alumox64", "tenwhite128", "tarmac_64HV", "sandytar_64HV", "LO1road_128",
   "indsmallwall64", "Grass_128HV", "firewall", "rack", "metal6", "metal5",
   "metal2", "metal1", "Grass", "dinerfloor01_128", "concretebig3_256",
   "wallmix64HV", "Road_yellowline256HV", "newallktenb1128", "newallkb1128",
   "newall9-1", "newall10_seamless", "forestfloor3", "bricksoftgrey128",
   "tenbeigebrick64", "tenbeige128", "indtena128", "artgal_128", "alleypave_64V",
   "taxi_256128", "walldirtynewa256128", "wallbrown02_64HV", "TENterr2_128",
   "TENdbrown5_128", "TENdblue2_128", "tenabrick64", "indtena128", "indten2btm128",
   "chipboardgrating64HV", "waterclear256", "sw_grass01", "newgrnd1brntrk_128",
   "grassdeep1blnd", "grassdeep1", "desertstones256grass", "cuntbrnclifftop",
   "cuntbrncliffbtmbmp", "planks01", "Gen_Scaffold_Wood_Under", "crate128",
   "cj_crates", "newall2_16c128", "ws_oldwall1", "telepole128", "sw_shedwindow1",
   "steel128", "skyclouds", "rocktb128", "plaintarmac1", "newall9b_16c128",
   "LoadingDoorClean", "metaldoor01_256", "des_sherrifwall1", "corrRoof_64HV",
   "concretenewb256", "chevron_red_64HVa", "Bow_stained_wall", "beigehotel_128",
   "warnsigns2", "BLOCK", "sw_sand", "sandnew_law", "rocktq128_dirt", "rocktbrn128",
   "des_dirt1", "desertstones256", "cw2_mounttrailblank", "bonyrd_skin2", "sam_camo",
   "a51_intdoor", "a51_blastdoor", "washapartwall1_256", "ws_carparkwall2", "girder2_grey_64HV",
   "jumptop1_64", "ammotrn92crate64", "nopark128", "iron", "ADDWOOD", "tatty_wood_1",
   "nf_blackbrd", "brk_ball1", "brk_Ball2", "cargo_gir3", "cargo_pipes", "cargo_ceil2",
   "cargo_top1", "cargo_floor2", "cargo_floor1", "cargo_gir2", "ws_carrierdeckbase",
   "ab_wood1", "wall1", "motel_wall4", "mp_diner_ceilingdirt", "mp_burn_wall1",
   "frate64_yellow", "frate_doors64yellow", "frate64_red", "frate_doors128red",
   "frate_doors64", "frate64_blue", "ct_stall1", "liftdoorsac128", "Metalox64",
   "redmetal", "snpedtest1", "banding8_64", "skip_rubble1", "metpat64",
   "walldirtynewa256", "skipY", "vendredmetal", "hazardtile13-128x128", "metalox64",
   "cj_lightwood", "metalalumox1", "wood1", "rockbrown1", "foil1-128x128", "foil2-128x128",
   "foil3-128x128", "foil4-128x128", "foil5-128x128", "mp_bobbie_pompom", "mp_bobbie_pompom1",
   "mp_bobbie_pompom2", "goldplated1", "gen_log", "stonefloortile13", "dts_elevator_door",
   "dts_elevator_woodpanel", "dts_elevator_carpet2", "dt_officflr2", "conc_wall2_128H",
   "sl_stapldoor1", "ws_gayflag1", "brick008", "yello007", "metal013", "knot_wood128",
   "stonewalltile1-5", "stonewalltile1-3", "stonewall4", "metallamppost4", "DanceFloor1",
   "hazardtile19-2", "concreteoldpainted1", "hazardtile15-3", "sampeasteregg",
   "stonewalltile1-2", "silk5-128x128", "silk6-128x128", "silk8-128x128", "silk9-128x128",
   "silk7-128x128", "wrappingpaper4-2", "wrappingpaper1", "wrappingpaper16", "wrappingpaper20",
   "wrappingpaper28", "CJ-COUCHL1", "metaldrumold1", "metalplate23-3", "gtasavectormap1",
   "gtasamapbit1", "gtasamapbit2", "gtasamapbit3", "gtasamapbit4", "rustyboltpanel",
   "planks01", "wallgarage", "floormetal1", "WoodPanel1", "redrailing", "roadguides",
   "cardboard4", "cardboard4-16", "cardboard4-2", "cardboard4-12", "cardboard4-21",
   "knot_woodpaint128", "knot_wood128", "telepole2128", "hazardwall2", "bboardblank_law",
   "ab_sheetSteel", "scratchedmetal", "ws_wetdryblendsand2", "multi086", "wood020",
   "metal1_128", "bluefoil", "truchettiling3-4", "beetles1", "lava1", "garbagepile1",
   "concrete12", "samppicture1", "samppicture2", "samppicture3", "samppicture4", "rocktb128",
   "lavalake", "easter_egg01", "easter_egg02", "easter_egg03", "easter_egg04", "easter_egg05",
   "711_walltemp", "ab_clubloungewall", "ab_corwallupr", "cj_lightwood", "cj_white_wall2",
   "cl_of_wltemp", "copbtm_brown", "gym_floor5", "kb_kit_wal1", "la_carp3",
   "motel_wall3", "mp_carter_bwall", "mp_carter_wall", "mp_diner_woodwall",
   "mp_motel_bluew", "mp_motel_pinkw", "mp_motel_whitewall", "mp_shop_floor2",
   "stormdrain3_nt", "des_dirt1", "desgreengrass", "des_ranchwall1", "des_wigwam",
   "des_wigwamdoor", "des_dustconc", "sanruf", "des_redslats", "duskyred_64",
   "des_ghotwood1", "Tablecloth", "StainedGlass", "Panel", "bistro_alpha"
}

local AbsParticleNames = {
   [18643] = "Красный лазер",
   [18647] = "Красный неон",
   [18648] = "Синий неон",
   [18649] = "Зеленый неон",
   [18650] = "Желтый неон",
   [18651] = "Розовый неон",
   [18652] = "Белый неон",
   [18653] = "Красный прожектор",
   [18654] = "Зеленый прожектор",
   [18655] = "Синий прожектор",
   [18668] = "Кровь",
   [18669] = "Брызги воды",
   [18670] = "Вспышка камеры",
   [18671] = "Дым белый густой",
   [18672] = "Льющийся цемент",
   [18673] = "Дым от сигаретты",
   [18674] = "Летящие облака",
   [18675] = "Вспышка дыма",
   [18676] = "Струя воды",
   [18677] = "Небольшой дым исчезающий",
   [18678] = "Ломающаяся коробка ",
   [18679] = "Ломающаяся коробка2",
   [18680] = "Выстрел",
   [18681] = "Взрыв тип1 маленький",
   [18682] = "Взрыв тип2 огромный",
   [18683] = "Взрыв тип3 огромный",
   [18684] = "Взрыв тип4 огромный",
   [18685] = "Взрыв тип5 огромный",
   [18686] = "Взрыв тип7 маленький",
   [18687] = "Пена огнетушителя",
   [18688] = "Огонь1 маленький",
   [18689] = "Огонь2 с дымом маленький",
   [18690] = "Огонь3 с дымом средний",
   [18691] = "Огонь4 средний",
   [18692] = "Огонь5 маленький",
   [18693] = "Огонь6 очень маленький",
   [18694] = "Огонь из огнемета",
   [18695] = "Эфект выстрела одиночный",
   [18696] = "Дым от выстрела одиночный",
   [18697] = "Пыль из под вертолета",
   [18698] = "Спавнер мух",
   [18699] = "Огонь от джетпака",
   [18700] = "Нитро",
   [18701] = "Огонь свечи",
   [18702] = "Большое нитро",
   [18703] = "Дым маленький",
   [18704] = "Дым маленький с искрами",
   [18705] = "Струя мочи",
   [18706] = "Белый фонтан крови",
   [18707] = "Водопад",
   [18708] = "Пузырьки воздуха при плавании",
   [18709] = "Ломающееся стекло",
   [18710] = "Густой дым постоянный",
   [18711] = "Ломающееся стекло 2",
   [18712] = "Гильзы при стрельбе",
   [18713] = "Дым большой белый",
   [18714] = "Дым2 большой белый",
   [18715] = "Дым большой серый",
   [18716] = "Дым маленький серый",
   [18717] = "Искры при стрельбе",
   [18718] = "Искры при стрельбе 2",
   [18719] = "След на воде",
   [18720] = "Падающие капли воды",
   [18721] = "Высокий водопад",
   [18722] = "Рвота",
   [18723] = "Дым большой черный клубящийся",
   [18724] = "Взрыв со стеклами",
   [18725] = "Дым маленький переменный",
   [18726] = "Дым маленький черный",
   [18727] = "Дым средний переменный",
   [18728] = "Свет сигнальной ракеты",
   [18729] = "Краска из баллончика",
   [18730] = "Выстрел танка",
   [18731] = "Дымовая шашка1",
   [18732] = "Дымовая шашка2",
   [18733] = "Падающие листья ",
   [18734] = "Падающие листья2",
   [18735] = "Дым маленький серый",
   [18736] = "Дым 2 маленький серый",
   [18737] = "Большие клубы пыли",
   [18738] = "Фонтан с паузой",
   [18739] = "Фонтан постоянный",
   [18740] = "Сбитый пожарный гидрант",
   [18741] = "Круги на воде",
   [18742] = "Большие брызги",
   [18743] = "Средний всплеск воды",
   [18744] = "Большой всплеск воды",
   [18745] = "Маленький всплеск воды1",
   [18746] = "Маленький всплеск воды2",
   [18747] = "Брызги водопада",
   [18748] = "Дым от заводской трубы",
   [18828] = "Спиральная труба",
   [18863] = "Маленький снег",
   [18864] = "Большой снег",
   [18881] = "Скайдайв2",
   [18888] = "Прозрачный блок2",
   [18889] = "Прозрачный блок3",
   [19080] = "Синий лазер",
   [19081] = "Розовый лазер",
   [19082] = "Оранжевый лазер",
   [19083] = "Зеленый лазер",
   [19084] = "Желтый лазер",
   [19121] = "Белый светящийся столб",
   [19122] = "Синий светящийся столб",
   [19123] = "Зеленый светящийся столб",
   [19124] = "Красный светящийся столб",
   [19125] = "Желтый светящийся столб",
   [19143] = "Белый прожектор",
   [19144] = "Красный прожектор",
   [19145] = "Зеленый прожектор",
   [19146] = "Синий прожектор",
   [19147] = "Желтый прожектор",
   [19148] = "Розовый прожектор",
   [19149] = "Голубой прожектор",
   [19150] = "Белый мигающий прожектор",
   [19151] = "Карсный мигающий прожектор",
   [19152] = "Зеленый мигающий прожектор",
   [19153] = "Синий мигающий прожектор",
   [19154] = "Желтый мигающий прожектор",
   [19155] = "Розовый мигающий прожектор",
   [19156] = "Голубой мигающий прожектор",
   [19281] = "Белый шар",
   [19282] = "Красный шар",
   [19283] = "Зеленый шар",
   [19284] = "Синий шар",
   [19285] = "Белый быстро моргающий шар",
   [19286] = "Красный быстро моргающий шар",
   [19287] = "Зеленый быстро моргающий шар",
   [19288] = "Синий быстро моргающий шар",
   [19289] = "Белый медленно моргающий шар",
   [19290] = "Красный медленно моргающий шар",
   [19291] = "Зеленый медленно моргающий шар",
   [19292] = "Синий медленно моргающий шар",
   [19293] = "Фиолетовый медленно моргающий шар",
   [19294] = "Желтый медленно моргающий шар",
   [19295] = "Белый большой шар",
   [19296] = "Красный большой шар",
   [19297] = "Зеленый большой шар",
   [19298] = "Синий большой шар",
   [19299] = "Луна",
   [19300] = "blankmodel",
   [19349] = "Монокль",
   [19350] = "Усы",
   [19351] = "Усы2",
   [19374] = "Невидимая стена",
   [19382] = "Невидимая стена",
   [19475] = "Небольшая поверхность для текста",
   [19476] = "Небольшая поверхность для текста",
   [19477] = "Средняя поверхность для текста",
   [19478] = "Поверхность для текста",
   [19479] = "Большая поверхность для текста",
   [19480] = "Маленькая поверхность для текста",
   [19481] = "Большая поверхность для текста",
   [19483] = "Средняя поверхность для текста",
   [19482] = "Средняя поверхность для текста",
   [19803] = "Мигалки эвакуатора",
   [19895] = "Аварийка"
}

local dialoghook = {
   textureslist = false,
   sampobjectslist = false
}

local lastClickedTextdrawId = 0
local isAbsolutePlay = false
 
function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   -- Change default activation command here
   while true do
   wait(0)
      -- sampGetCurrentServerName() returns a value with a long delay
      -- unlike receiving the IP and port. Therefore, for correct operation, the code is placed here      
      local servername = sampGetCurrentServerName()
      if servername:find("Absolute") then
         isAbsolutePlay = true
      end
      if servername:find("Абсолют") then
         isAbsolutePlay = true
      end
      -- Open vehicles menu on K key
      if isKeyJustPressed(0x4B) and not sampIsChatInputActive() and not sampIsDialogActive()
      and not isPauseMenuActive() and not isSampfuncsConsoleActive() then 
         dialoghook.textureslist = false
      end
      
      -- Select texture on F key
      if isKeyJustPressed(0x66) and dialoghook.textureslist and not sampIsChatInputActive() and not sampIsDialogActive()
      and not isPauseMenuActive() and not isSampfuncsConsoleActive() then 
         if lastClickedTextdrawId == 2099 then
            sampSendClickTextdraw(37)
            lastClickedTextdrawId = 2053
         else
            sampSendClickTextdraw(lastClickedTextdrawId)
            lastClickedTextdrawId = lastClickedTextdrawId + 2
         end
      end
      
      if isAbsolutePlay then
         -- Switching textdraws with arrow buttons, mouse buttons, pgup-pgdown keys
         if isKeyJustPressed(0x25) or isKeyJustPressed(0x05) 
         or isKeyJustPressed(0x21) and sampIsCursorActive() 
         and not sampIsChatInputActive() and not sampIsDialogActive() 
         and not isPauseMenuActive() and not isSampfuncsConsoleActive() then
            sampSendClickTextdraw(36)
         end
         
         if isKeyJustPressed(0x27) or isKeyJustPressed(0x06) 
         or isKeyJustPressed(0x22) and sampIsCursorActive()
         and not sampIsChatInputActive() and not sampIsDialogActive()
         and not isPauseMenuActive() and not isSampfuncsConsoleActive() then 
            sampSendClickTextdraw(37)
         end
      end
   end
end

function sampev.onShowTextDraw(id, data)
   if isAbsolutePlay and dialoghook.textureslist then
      if id >= 2053 and id <= 2100 then
         local index = tonumber(data.text)
         if index ~= nil then
            local txdlabel = data.text.."~n~~n~"..tostring(absTxdNames[index+1])
            data.text = txdlabel
            data.letterWidth = 0.12
            data.letterHeight = 0.7
            return{id, data}    
         end
      end
   end
   
   if isAbsolutePlay and dialoghook.sampobjectslist then
      if id >= 2053 and id <= 2100 then
         local modelid = tonumber(string.sub(data.text, 0, 5))
         if modelid ~= nil then
            local particlename = tostring(AbsParticleNames[modelid])
            local particlename = string.gsub(particlename, " ", "~n~")
            local txdlabel = modelid.."~n~~n~"..cyrillic(particlename)
            if string.len(txdlabel) > 14 then data.text = txdlabel end
            data.letterWidth = 0.18
            data.letterHeight = 0.9
            return{id, data}    
         end
      end
   end
end

function sampev.onSendClickTextDraw(textdrawId)
   lastClickedTextdrawId = textdrawId
end

function sampev.onSendDialogResponse(dialogId, button, listboxId, input)
   if isAbsolutePlay then
      dialoghook.textureslist = false
   end
   
   if dialogId == 1400 and listboxId == 4 and button == 1 then
      dialoghook.textureslist = true
   end
   if dialogId == 1403 and listboxId == 2 and button == 1 then
      dialoghook.textureslist = true
   end
   
   if dialogId == 1409 and listboxId == 2 and button == 1 and input:find("MP объекты") then
      dialoghook.sampobjectslist = true
   end
end

function sampev.onSendCommand(command)
    -- tips for those who are used to using Texture Studio syntax
   if isAbsolutePlay then
      if command:find("/vfibye2") or command:find("/машину2") then 
         dialoghook.textureslist = false
      end
   end
end
    
function cyrillic(text)
   local convtbl = {[230]=155,[231]=159,[247]=164,[234]=107,[250]=144,
      [251]=168,[254]=171,[253]=170,[255]=172,[224]=97,[240]=112,[241]=99,
      [226]=162,[228]=154,[225]=151,[227]=153,[248]=165,[243]=121,[184]=101,
      [235]=158,[238]=111,[245]=120,[233]=157,[242]=166,[239]=163,[244]=63,
      [237]=174,[229]=101,[246]=36,[236]=175,[232]=156,[249]=161,[252]=169,
      [215]=141,[202]=75,[204]=77,[220]=146,[221]=147,[222]=148,[192]=65,
      [193]=128,[209]=67,[194]=139,[195]=130,[197]=69,[206]=79,[213]=88,
      [168]=69,[223]=149,[207]=140,[203]=135,[201]=133,[199]=136,[196]=131,
      [208]=80,[200]=133,[198]=132,[210]=143,[211]=89,[216]=142,[212]=129,
      [214]=137,[205]=72,[217]=138,[218]=167,[219]=145}
   local result = {}
   for i = 1, #text do
      local c = text:byte(i)
      result[i] = string.char(convtbl[c] or c)
   end
   return table.concat(result)
end