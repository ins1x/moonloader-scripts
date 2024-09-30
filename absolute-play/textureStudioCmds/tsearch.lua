script_name("tsearch")
script_author("1NS")
script_url("https://github.com/ins1x/moonloader-scripts")
script_dependencies('samp-events')
script_description("Adds /tsearch command for the map editor on Absolute Play")
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
   end
end


function sampev.onSendCommand(command)
   if command:find("/tsearch") and isAbsolutePlay then
      if command:find('(.+) (.+)') then
         local cmd, arg = command:match('(.+) (.+)')
         local searchtxd = tostring(arg)
         if string.len(searchtxd) < 2 then
            sampAddChatMessage("Минимальное кол-во символов для поиска текстуры = 2", -1)
            return false
         end
         
         local findedtxd = 0
         if searchtxd and searchtxd ~= nil then 
            for k, txdname in pairs(absTxdNames) do
               if txdname:find(searchtxd) then
                  findedtxd = findedtxd + 1
                  sampAddChatMessage(string.format("{696969}%d. {FFFFFF}%s", k-1, txdname), -1)
                  if findedtxd >= 50 then
                     break
                  end
               end
            end
            
            if findedtxd > 0 then
               sampAddChatMessage("Найдено совпадений: "..findedtxd, -1)
            else
               sampAddChatMessage("Совпадений не найдено.", -1)
            end
            return false
         end
      else 
         sampAddChatMessage("Введите название текстуры для поиска", -1)
         sampAddChatMessage("Например: /tsearch wood", -1)
         return false
      end
   end
end
    
