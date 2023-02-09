local function MainScreen(initialSettings, initialTracker, initialProgram)
    local HoverEventListener = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/HoverEventListener.lua")
    local MouseClickEventListener = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/MouseClickEventListener.lua")
    local JoypadEventListener = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/JoypadEventListener.lua")
    local FrameCounter = dofile(Paths.FOLDERS.DATA_FOLDER .. "/FrameCounter.lua")
    local MainScreenUIInitializer = dofile(Paths.FOLDERS.UI_FOLDER .. "/MainScreenUIInitializer.lua")

    local settings = initialSettings
    local tracker = initialTracker
    local program = initialProgram
    local justChangedHiddenPower = false
    local moveEffectivenessEnabled = true
    local currentPokemon = nil
    local opposingPokemon = nil
    local inTrackedView = false
    local inPastRunView = false
    local inLockedView = false
    local defeatedLance = false
    local mainScreenUIInitializer
    local statCycleIndex = -1
    local stats = {"HP", "ATK", "DEF", "SPA", "SPD", "SPE"}
    local eventListeners = {
        abilityHoverListener = nil
    }
    local constants = Graphics.MAIN_SCREEN_CONSTANTS
    local frameCounters = {}
    local hoverListeners = {}
    local moveEventListeners = {}
    local statPredictionEventListeners = {}
    local ui = {}
    local self = {}
    local activeHoverFrame = nil
    local extraThingsToDraw = {
        moveEffectiveness = {},
        nature = {},
        statStages = {},
        status = {}
    }
    local browsOptions = {
		[1]={direction=0, brows={{x=1,y=1,file="Brows25Left"},{x=3,y=2,file="Brows25Right"},}},
		[2]={direction=0, brows={{x=-1,y=4,file="Brows25Right"},{x=1,y=7,file="Brows15Left"},}},
		[3]={direction=0, brows={{x=1,y=7,file="Brows25Left"},{x=4,y=7,file="Brows25Right"},}},
		[4]={direction=0, brows={{x=9,y=3,file="Brows20Right"},{x=5,y=3,file="Brows20Left"},}},
		[5]={direction=0, brows={{x=1,y=6,file="Brows25Right"},}},
		[6]={direction=0, brows={{x=-1,y=-4,file="Brows25Right"},}},
		[7]={direction=0, brows={{x=-1,y=1,file="Brows25Right"},{x=2,y=4,file="Brows15Left"},}},
		[8]={direction=0, brows={{x=0,y=6,file="Brows25Right"},{x=0,y=8,file="Brows20Left"},}},
		[9]={direction=0, brows={{x=-3,y=-2,file="Brows25Right"},}},
		[10]={direction=0, brows={{x=3,y=-4,file="Brows30Right"},}},
		[11]={direction=0, brows={{x=10,y=0,file="Brows25Left"},}},
		[12]={direction=0, brows={{x=-3,y=-2,file="Brows30Right"},{x=-2,y=2,file="Brows30LeftFlat"},}},
		[13]={direction=1, brows={{x=7,y=2,file="Brows15Left"},{x=16,y=7,file="Brows15Left"},}},
		[14]={direction=0, brows={{x=-3,y=3,file="Brows25Right"},{x=1,y=6,file="Brows15Left"},}},
		[15]={direction=0, brows={{x=-6,y=-1,file="Brows30Right"},{x=3,y=5,file="Brows15Left"},}},
		[16]={direction=0, brows={{x=-3,y=5,file="Brows25Right"},}},
		[17]={direction=0, brows={{x=-5,y=5,file="Brows25Right"},}},
		[18]={direction=0, brows={{x=-5,y=3,file="Brows25Right"},}},
		[19]={direction=0, brows={{x=-3,y=3,file="Brows25Right"},}},
		[20]={direction=0, brows={{x=-3,y=0,file="Brows25Right"},}},
		[21]={direction=0, brows={{x=-2,y=0,file="Brows25Right"},}},
		[22]={direction=0, brows={{x=0,y=3,file="Brows25Right"},}},
		[23]={direction=0, brows={{x=1,y=-2,file="Brows25Right"},}},
		[24]={direction=0, brows={{x=-2,y=3,file="Brows25Right"},}},
		[25]={direction=0, brows={{x=0,y=2,file="Brows25Right"},{x=-1,y=3,file="Brows25Left"},}},
		[26]={direction=0, brows={{x=3,y=0,file="Brows25"},}},
		[27]={direction=0, brows={{x=4,y=4,file="Brows25Right"},{x=3,y=8,file="Brows15Left"},}},
		[28]={direction=0, brows={{x=-1,y=5,file="Brows25Right"},{x=-2,y=6,file="Brows25Left"},}},
		[29]={direction=0, brows={{x=-1,y=-2,file="Brows25Right"},}},
		[30]={direction=0, brows={{x=1,y=10,file="Brows25Right"},{x=3,y=12,file="Brows15Left"},}},
		[31]={direction=0, brows={{x=-1,y=-1,file="Brows25Right"},}},
		[32]={direction=0, brows={{x=-2,y=3,file="Brows30Right"},}},
		[33]={direction=0, brows={{x=5,y=8,file="Brows25RightTall"},}},
		[34]={direction=0, brows={{x=2,y=5,file="Brows25Right"},}},
		[35]={direction=0, brows={{x=8,y=8,file="Brows20"},}},
		[36]={direction=0, brows={{x=11,y=7,file="Brows20Left"},{x=9,y=9,file="Brows20RightFlat"},}},
		[37]={direction=0, brows={{x=-4,y=7,file="Brows25Right"},}},
		[38]={direction=0, brows={{x=-6,y=5,file="Brows25Right"},}},
		[39]={direction=1, brows={{x=4,y=1,file="Brows30Left"},{x=4,y=6,file="Brows30RightFlat"},}},
		[40]={direction=0, brows={{x=-2,y=3,file="Brows30Right"},{x=2,y=3,file="Brows30Left"},}},
		[41]={direction=2, brows={{x=-3,y=7,file="Brows20Right"},{x=3,y=4,file="Brows20Right"},}},
		[42]={direction=0, brows={{x=3,y=1,file="Brows20Right"},{x=6,y=2,file="Brows15Left"},}},
		[43]={direction=0, brows={{x=1,y=7,file="Brows25LeftTall"},{x=1,y=9,file="Brows25RightFlat"},}},
		[44]={direction=0, brows={{x=3,y=5,file="Brows25"},}},
		[45]={direction=0, brows={{x=8,y=12,file="Brows15Right"},}},
		[46]={direction=0, brows={{x=0,y=10,file="Brows25RightFlat"},{x=0,y=6,file="Brows25Left"},}},
		[47]={direction=0, brows={{x=7,y=8,file="Brows20Right"},{x=9,y=8,file="Brows20Left"},}},
		[48]={direction=0, brows={{x=3,y=1,file="Brows25LeftTall"},{x=-1,y=3,file="Brows25RightFlat"},}},
		[49]={direction=0, brows={{x=0,y=4,file="Brows25Right"},{x=4,y=6,file="Brows25LeftFlat"},}},
		[50]={direction=0, brows={{x=2,y=2,file="Brows25Left"},{x=0,y=2,file="Brows25Right"},}},
		[51]={direction=0, brows={{x=2,y=9,file="Brows15"},{x=13,y=-3,file="Brows15"},{x=19,y=14,file="Brows15"},}},
		[52]={direction=0, brows={{x=5,y=4,file="Brows25Left"},{x=6,y=7,file="Brows25RightFlat"},}},
		[53]={direction=0, brows={{x=1,y=7,file="Brows25LeftTall"},{x=3,y=7,file="Brows25RightTall"},}},
		[54]={direction=0, brows={{x=6,y=-1,file="Brows25Left"},{x=4,y=2,file="Brows25RightFlat"},}},
		[55]={direction=0, brows={{x=-2,y=1,file="Brows25Right"},}},
		[56]={direction=0, brows={{x=5,y=10,file="Brows25LeftTall"},{x=3,y=9,file="Brows25Right"},}},
		[57]={direction=2, brows={{x=-9,y=8,file="Brows25Right"},{x=-1,y=3,file="Brows25Right"},}},
		[58]={direction=0, brows={{x=-4,y=5,file="Brows25Right"},}},
		[59]={direction=0, brows={{x=8,y=6,file="Brows20Left"},{x=6,y=6,file="Brows20Right"},}},
		[60]={direction=0, brows={{x=5,y=-4,file="Brows25Left"},{x=4,y=-4,file="Brows25Right"},}},
		[61]={direction=0, brows={{x=7,y=-5,file="Brows25Left"},{x=8,y=-4,file="Brows25Right"},}},
		[62]={direction=0, brows={{x=5,y=-5,file="Brows25Right"},{x=4,y=-5,file="Brows25Left"},}},
		[63]={direction=0, brows={{x=5,y=10,file="Brows20Left"},{x=4,y=10,file="Brows20Right"},}},
		[64]={direction=0, brows={{x=-6,y=1,file="Brows25Right"},}},
		[65]={direction=0, brows={{x=7,y=8,file="Brows20Left"},{x=5,y=10,file="Brows20RightFlat"},}},
		[66]={direction=0, brows={{x=3,y=2,file="Brows25RightTall"},{x=4,y=7,file="Brows20LeftFlat"},}},
		[67]={direction=0, brows={{x=-2,y=-1,file="Brows25Right"},}},
		[68]={direction=0, brows={{x=1,y=8,file="Brows20Right"},{x=5,y=10,file="Brows15Left"},}},
		[69]={direction=0, brows={{x=6,y=3,file="Brows15Right"},}},
		[70]={direction=0, brows={{x=5,y=-1,file="Brows20Right"},{x=7,y=-1,file="Brows20Left"},}},
		[71]={direction=0, brows={{x=6,y=11,file="Brows25LeftFlat"},{x=3,y=7,file="Brows25Right"},}},
		[72]={direction=0, brows={{x=-4,y=8,file="Brows25Right"},}},
		[73]={direction=0, brows={{x=3,y=7,file="Brows25Left"},{x=2,y=7,file="Brows25Right"},}},
		[74]={direction=0, brows={{x=5,y=8,file="Brows25LeftFlat"},{x=2,y=5,file="Brows25Right"},}},
		[75]={direction=0, brows={{x=3,y=6,file="Brows25Right"},{x=7,y=9,file="Brows25LeftFlat"},}},
		[76]={direction=0, brows={{x=-4,y=1,file="Brows25Right"},}},
		[77]={direction=0, brows={{x=-3,y=8,file="Brows25Right"},}},
		[78]={direction=0, brows={{x=-3,y=6,file="Brows25Right"},}},
		[79]={direction=0, brows={{x=3,y=-2,file="Brows25Left"},{x=2,y=-1,file="Brows25Right"},}},
		[80]={direction=0, brows={{x=3,y=-1,file="Brows25Left"},{x=2,y=-1,file="Brows25Right"},}},
		[81]={direction=0, brows={{x=1,y=1,file="Unibrow30"},}},
		[82]={direction=0, brows={{x=7,y=4,file="Unibrow20"},{x=-7,y=18,file="Unibrow20"},{x=18,y=19,file="Unibrow20"},}},
		[83]={direction=0, brows={{x=3,y=4,file="Brows25"},}},
		[84]={direction=0, brows={{x=-3,y=3,file="Brows15Right"},{x=20,y=-1,file="Brows15Left"},}},
		[85]={direction=0, brows={{x=-10,y=10,file="Brows20Right"},{x=6,y=-2,file="Brows20Right"},}},
		[86]={direction=0, brows={{x=1,y=4,file="Brows25"},}},
		[87]={direction=0, brows={{x=6,y=1,file="Brows20Left"},{x=6,y=6,file="Brows20RightFlat"},}},
		[88]={direction=0, brows={{x=6,y=-2,file="Brows20Left"},{x=5,y=-1,file="Brows20Right"},}},
		[89]={direction=0, brows={{x=-1,y=-2,file="Brows25Right"},}},
		[90]={direction=0, brows={{x=-1,y=0,file="Brows30"},}},
		[91]={direction=0, brows={{x=7,y=8,file="Brows25Left"},{x=4,y=7,file="Brows25Right"},}},
		[92]={direction=0, brows={{x=-4,y=2,file="Brows30Right"},{x=-1,y=4,file="Brows30LeftTall"},}},
		[93]={direction=0, brows={{x=2,y=4,file="Brows25LeftTall"},{x=1,y=4,file="Brows25Right"},}},
		[94]={direction=0, brows={{x=5,y=6,file="Brows25LeftTall"},{x=6,y=6,file="Brows25RightTall"},}},
		[95]={direction=0, brows={{x=0,y=0,file="Brows25Left"},{x=-2,y=1,file="Brows25Right"},}},
		[96]={direction=0, brows={{x=3,y=0,file="Brows25RightFlat"},}},
		[97]={direction=0, brows={{x=2,y=6,file="Brows25Right"},{x=6,y=7,file="Brows15Left"},}},
		[98]={direction=0, brows={{x=5,y=4,file="Brows25Left"},{x=2,y=4,file="Brows25Right"},}},
		[99]={direction=0, brows={{x=0,y=4,file="Brows25Right"},{x=2,y=4,file="Brows25Left"},}},
		[100]={direction=0, brows={{x=-8,y=2,file="Brows30Right"},{x=1,y=10,file="Brows15Left"},}},
		[101]={direction=0, brows={{x=1,y=-3,file="Brows30"},}},
		[102]={direction=0, brows={{x=-2,y=12,file="Brows15"},{x=16,y=0,file="Brows15"},{x=23,y=16,file="Brows15"},}},
		[103]={direction=0, brows={{x=7,y=7,file="Brows15"},{x=-5,y=2,file="Brows15Right"},{x=26,y=5,file="Brows15Left"},}},
		[104]={direction=0, brows={{x=0,y=5,file="Brows25Right"},}},
		[105]={direction=0, brows={{x=-1,y=5,file="Brows25Right"},}},
		[106]={direction=0, brows={{x=-2,y=2,file="Brows25Right"},}},
		[107]={direction=0, brows={{x=6,y=4,file="Brows25LeftTall"},{x=4,y=4,file="Brows25Right"},}},
		[108]={direction=0, brows={{x=5,y=-1,file="Brows20Left"},{x=7,y=-1,file="Brows20Right"},}},
		[109]={direction=0, brows={{x=5,y=-1,file="Brows25"},}},
		[110]={direction=0, brows={{x=-2,y=0,file="Brows25Right"},{x=-2,y=4,file="Brows25LeftFlat"},}},
		[111]={direction=0, brows={{x=3,y=8,file="Brows20Left"},{x=9,y=8,file="Brows20Right"},}},
		[112]={direction=0, brows={{x=0,y=1,file="Brows25Right"},}},
		[113]={direction=0, brows={{x=9,y=-1,file="Brows20Left"},{x=6,y=-1,file="Brows20Right"},}},
		[114]={direction=0, brows={{x=8,y=2,file="Brows25"},}},
		[115]={direction=0, brows={{x=-1,y=-5,file="Brows25Right"},}},
		[116]={direction=0, brows={{x=-2,y=-1,file="Brows25Right"},}},
		[117]={direction=0, brows={{x=-3,y=4,file="Brows25Right"},}},
		[118]={direction=0, brows={{x=-4,y=5,file="Brows25Right"},}},
		[119]={direction=0, brows={{x=-2,y=5,file="Brows25Right"},}},
		[120]={direction=0, brows={{x=7,y=11,file="Unibrow20"},}},
		[121]={direction=0, brows={{x=4,y=6,file="Unibrow30"},}},
		[122]={direction=0, brows={{x=14,y=3,file="Brows20Left"},{x=11,y=3,file="Brows20Right"},}},
		[123]={direction=0, brows={{x=7,y=8,file="Brows20Left"},{x=5,y=11,file="Brows20RightFlat"},}},
		[124]={direction=0, brows={{x=7,y=0,file="Brows25Left"},{x=3,y=0,file="Brows25Right"},}},
		[125]={direction=0, brows={{x=8,y=9,file="Brows15Left"},{x=6,y=9,file="Brows15Right"},}},
		[126]={direction=0, brows={{x=7,y=7,file="Brows20"},}},
		[127]={direction=0, brows={{x=5,y=5,file="Brows25LeftFlat"},{x=3,y=2,file="Brows25RightTall"},}},
		[128]={direction=0, brows={{x=-1,y=9,file="Brows20Right"},}},
		[129]={direction=0, brows={{x=-2,y=-2,file="Brows25Right"},}},
		[130]={direction=0, brows={{x=-5,y=-1,file="Brows25Right"},}},
		[131]={direction=0, brows={{x=-1,y=5,file="Brows25Right"},}},
		[132]={direction=0, brows={{x=11,y=4,file="Brows20Left"},{x=11,y=7,file="Brows20RightFlat"},}},
		[133]={direction=0, brows={{x=4,y=5,file="Brows25Left"},{x=3,y=8,file="Brows25RightFlat"},}},
		[134]={direction=0, brows={{x=4,y=3,file="Brows25LeftTall"},{x=3,y=5,file="Brows25RightFlat"},}},
		[135]={direction=0, brows={{x=-7,y=2,file="Brows25RightFlat"},}},
		[136]={direction=0, brows={{x=-4,y=6,file="Brows25Right"},}},
		[137]={direction=0, brows={{x=-1,y=-2,file="Brows30Right"},}},
		[138]={direction=0, brows={{x=6,y=5,file="Brows25Left"},{x=3,y=5,file="Brows25Right"},}},
		[139]={direction=0, brows={{x=6,y=2,file="Brows25"},}},
		[140]={direction=0, brows={{x=5,y=5,file="Brows25"},}},
		[141]={direction=0, brows={{x=-1,y=8,file="Brows25Right"},}},
		[142]={direction=0, brows={{x=3,y=-4,file="Brows20Right"},}},
		[143]={direction=0, brows={{x=5,y=6,file="Brows25"},}},
		[144]={direction=0, brows={{x=4,y=4,file="Brows25Right"},}},
		[145]={direction=0, brows={{x=11,y=7,file="Brows15Left"},{x=9,y=7,file="Brows15Right"},}},
		[146]={direction=0, brows={{x=-3,y=12,file="Brows20Right"},}},
		[147]={direction=0, brows={{x=-1,y=4,file="Brows25RightFlat"},}},
		[148]={direction=0, brows={{x=3,y=0,file="Brows25Right"},}},
		[149]={direction=0, brows={{x=2,y=3,file="Brows25RightTall"},}},
		[150]={direction=0, brows={{x=-2,y=8,file="Brows25Right"},}},
		[151]={direction=0, brows={{x=4,y=5,file="Brows25"},}},
		[152]={direction=0, brows={{x=1,y=5,file="Brows25"},}},
		[153]={direction=0, brows={{x=1,y=1,file="Brows25Right"},}},
		[154]={direction=0, brows={{x=-2,y=-1,file="Brows25Right"},}},
		[155]={direction=0, brows={{x=3,y=2,file="Brows25Right"},}},
		[156]={direction=0, brows={{x=-4,y=6,file="Brows25RightTall"},}},
		[157]={direction=0, brows={{x=-1,y=-1,file="Brows20RightFlat"},}},
		[158]={direction=0, brows={{x=5,y=4,file="Brows20RightFlat"},}},
		[159]={direction=0, brows={{x=0,y=-2,file="Brows25RightTall"},}},
		[160]={direction=0, brows={{x=-2,y=2,file="Brows25Right"},}},
		[161]={direction=0, brows={{x=10,y=2,file="Brows15Left"},{x=8,y=2,file="Brows15Right"},}},
		[162]={direction=0, brows={{x=-4,y=2,file="Brows25Right"},{x=-2,y=1,file="Brows25Left"},}},
		[163]={direction=0, brows={{x=4,y=-4,file="Brows30Left"},{x=0,y=-4,file="Brows30Right"},}},
		[164]={direction=0, brows={{x=6,y=6,file="Brows25Left"},{x=4,y=9,file="Brows25RightFlat"},}},
		[165]={direction=0, brows={{x=4,y=-2,file="Brows25"},}},
		[166]={direction=0, brows={{x=-10,y=-1,file="Brows30Right"},}},
		[167]={direction=0, brows={{x=3,y=6,file="Brows25Right"},{x=4,y=5,file="Brows25Left"},}},
		[168]={direction=0, brows={{x=-2,y=9,file="Brows25Right"},}},
		[169]={direction=0, brows={{x=-1,y=-1,file="Brows25RightTall"},{x=5,y=5,file="Brows15Left"},}},
		[170]={direction=0, brows={{x=-2,y=6,file="Brows25LeftTall"},{x=-2,y=7,file="Brows25Right"},}},
		[171]={direction=0, brows={{x=-5,y=2,file="Brows25Right"},}},
		[172]={direction=0, brows={{x=4,y=2,file="Brows25Left"},{x=6,y=5,file="Brows25Right"},}},
		[173]={direction=0, brows={{x=8,y=9,file="Brows15"},}},
		[174]={direction=0, brows={{x=3,y=5,file="Brows25"},}},
		[175]={direction=0, brows={{x=13,y=7,file="Brows15Left"},{x=12,y=7,file="Brows15Right"},}},
		[176]={direction=0, brows={{x=-2,y=7,file="Brows20Right"},{x=-1,y=12,file="Brows20LeftFlat"},}},
		[177]={direction=0, brows={{x=1,y=3,file="Brows30RightFlat"},}},
		[178]={direction=0, brows={{x=-1,y=0,file="Brows30RightFlat"},}},
		[179]={direction=0, brows={{x=2,y=3,file="Brows25"},}},
		[180]={direction=0, brows={{x=1,y=6,file="Brows25"},}},
		[181]={direction=0, brows={{x=-3,y=5,file="Brows25Right"},}},
		[182]={direction=0, brows={{x=1,y=3,file="Brows25"},}},
		[183]={direction=0, brows={{x=5,y=7,file="Brows20"},}},
		[184]={direction=0, brows={{x=5,y=0,file="Brows25Left"},{x=4,y=4,file="Brows25RightFlat"},}},
		[185]={direction=0, brows={{x=12,y=3,file="Brows20Left"},{x=10,y=3,file="Brows20Right"},}},
		[186]={direction=0, brows={{x=6,y=0,file="Brows25Right"},}},
		[187]={direction=0, brows={{x=2,y=6,file="Brows25"},}},
		[188]={direction=0, brows={{x=6,y=7,file="Brows20Left"},{x=8,y=12,file="Brows20RightFlat"},}},
		[189]={direction=0, brows={{x=4,y=6,file="Brows15Right"},{x=2,y=6,file="Brows15Left"},}},
		[190]={direction=0, brows={{x=2,y=7,file="Brows25Left"},{x=5,y=8,file="Brows25Right"},}},
		[191]={direction=0, brows={{x=2,y=2,file="Brows30Left"},{x=0,y=1,file="Brows30Right"},}},
		[192]={direction=0, brows={{x=7,y=0,file="Brows20Left"},{x=5,y=2,file="Brows20RightFlat"},}},
		[193]={direction=0, brows={{x=1,y=5,file="Brows25Right"},}},
		[194]={direction=0, brows={{x=6,y=3,file="Brows20Left"},{x=11,y=3,file="Brows20Right"},}},
		[195]={direction=0, brows={{x=0,y=3,file="Brows15Left"},{x=12,y=0,file="Brows15Right"},}},
		[196]={direction=0, brows={{x=0,y=10,file="Brows25RightFlat"},{x=-2,y=5,file="Brows25LeftTall"},}},
		[197]={direction=0, brows={{x=-8,y=5,file="Brows30Right"},}},
		[198]={direction=0, brows={{x=3,y=7,file="Brows25Right"},{x=9,y=10,file="Brows15Left"},}},
		[199]={direction=0, brows={{x=3,y=3,file="Brows25Left"},{x=0,y=5,file="Brows25Right"},}},
		[200]={direction=2, brows={{x=-8,y=6,file="Brows25RightTall"},{x=1,y=-1,file="Brows25RightFlat"},}},
		[201]={direction=0, brows={{x=1,y=2,file="Unibrow30"},}},
		[202]={direction=1, brows={{x=8,y=5,file="Brows25Left"},{x=19,y=1,file="Brows25Left"},}},
		[203]={direction=0, brows={{x=0,y=3,file="Brows25Right"},}},
		[204]={direction=0, brows={{x=5,y=1,file="Brows25Left"},{x=3,y=1,file="Brows25Right"},}},
		[205]={direction=0, brows={{x=9,y=5,file="Brows25Left"},{x=6,y=5,file="Brows25Right"},}},
		[206]={direction=0, brows={{x=-6,y=1,file="Brows30Right"},}},
		[207]={direction=0, brows={{x=4,y=1,file="Brows25LeftTall"},{x=6,y=2,file="Brows25Right"},}},
		[208]={direction=0, brows={{x=-6,y=-4,file="Brows30Right"},}},
		[209]={direction=0, brows={{x=7,y=6,file="Brows20Left"},{x=10,y=9,file="Brows20RightFlat"},}},
		[210]={direction=0, brows={{x=10,y=1,file="Brows15Left"},{x=8,y=2,file="Brows15Right"},}},
		[211]={direction=0, brows={{x=0,y=4,file="Brows25LeftFlat"},{x=1,y=0,file="Brows25Right"},}},
		[212]={direction=0, brows={{x=5,y=11,file="Brows25LeftTall"},{x=7,y=10,file="Brows25RightTall"},}},
		[213]={direction=0, brows={{x=-3,y=2,file="Brows25LeftTall"},{x=-4,y=4,file="Brows25RightFlat"},}},
		[214]={direction=0, brows={{x=2,y=6,file="Brows25"},}},
		[215]={direction=0, brows={{x=-1,y=9,file="Brows25LeftTall"},{x=0,y=9,file="Brows25Right"},}},
		[216]={direction=0, brows={{x=5,y=7,file="Brows20Left"},{x=6,y=8,file="Brows20Right"},}},
		[217]={direction=0, brows={{x=-1,y=-2,file="Brows25Right"},}},
		[218]={direction=0, brows={{x=0,y=-5,file="Brows30Left"},{x=-2,y=-5,file="Brows30Right"},}},
		[219]={direction=0, brows={{x=4,y=-8,file="Brows30Left"},{x=2,y=-7,file="Brows30Right"},}},
		[220]={direction=0, brows={{x=0,y=8,file="Brows20LeftFlat"},{x=0,y=6,file="Brows20Right"},}},
		[221]={direction=0, brows={{x=3,y=0,file="Brows25"},}},
		[222]={direction=0, brows={{x=12,y=10,file="Brows15"},}},
		[223]={direction=0, brows={{x=0,y=4,file="Brows25"},}},
		[224]={direction=0, brows={{x=-3,y=-4,file="Brows30Right"},}},
		[225]={direction=0, brows={{x=6,y=1,file="Brows25Left"},{x=2,y=1,file="Brows25Right"},}},
		[226]={direction=0, brows={{x=3,y=-1,file="Brows25RightTall"},}},
		[227]={direction=0, brows={{x=3,y=7,file="Brows20Right"},}},
		[228]={direction=0, brows={{x=-1,y=4,file="Brows20Right"},}},
		[229]={direction=0, brows={{x=0,y=0,file="Brows25Right"},}},
		[230]={direction=0, brows={{x=3,y=3,file="Brows25RightFlat"},}},
		[231]={direction=0, brows={{x=11,y=5,file="Brows20Right"},}},
		[232]={direction=0, brows={{x=9,y=3,file="Brows20Right"},}},
		[233]={direction=0, brows={{x=2,y=-2,file="Brows30Right"},}},
		[234]={direction=0, brows={{x=5,y=5,file="Brows20Left"},{x=6,y=6,file="Brows20Right"},}},
		[235]={direction=0, brows={{x=-2,y=1,file="Brows30Right"},}},
		[236]={direction=0, brows={{x=-4,y=4,file="Brows25Right"},{x=2,y=8,file="Brows15Left"},}},
		[237]={direction=0, brows={{x=4,y=12,file="ReverseBrows25"},}},
		[238]={direction=0, brows={{x=4,y=2,file="Brows30Left"},{x=2,y=1,file="Brows30Right"},}},
		[239]={direction=0, brows={{x=3,y=7,file="Brows25LeftTall"},{x=2,y=6,file="Brows25Right"},}},
		[240]={direction=0, brows={{x=4,y=7,file="Brows20Left"},{x=3,y=10,file="Brows20RightFlat"},}},
		[241]={direction=0, brows={{x=1,y=1,file="Brows25Right"},}},
		[242]={direction=0, brows={{x=15,y=3,file="Brows15Left"},{x=13,y=3,file="Brows15Right"},}},
		[243]={direction=0, brows={{x=-2,y=-2,file="Brows25Right"},}},
		[244]={direction=0, brows={{x=-4,y=-2,file="Brows25Right"},}},
		[245]={direction=0, brows={{x=-5,y=1,file="Brows25Right"},}},
		[246]={direction=0, brows={{x=-1,y=8,file="Brows25RightTall"},}},
		[247]={direction=0, brows={{x=-6,y=1,file="Brows30Right"},}},
		[248]={direction=0, brows={{x=-5,y=-4,file="Brows25RightFlat"},}},
		[249]={direction=0, brows={{x=-8,y=0,file="Brows25Right"},}},
		[250]={direction=0, brows={{x=3,y=4,file="Brows25RightFlat"},}},
		[251]={direction=0, brows={{x=1,y=8,file="Brows30RightTall"},{x=-6,y=7,file="Brows30LeftTall"},}},
		[252]={direction=0, brows={{x=-2,y=-1,file="Brows30Right"},}},
		[253]={direction=0, brows={{x=-2,y=-1,file="Brows25RightFlat"},}},
		[254]={direction=0, brows={{x=-5,y=4,file="Brows30RightFlat"},}},
		[255]={direction=0, brows={{x=-2,y=6,file="Brows25"},}},
		[256]={direction=0, brows={{x=-3,y=1,file="Brows25Right"},}},
		[257]={direction=0, brows={{x=-7,y=3,file="Brows25Right"},}},
		[258]={direction=0, brows={{x=5,y=6,file="Brows20Left"},{x=4,y=6,file="Brows20Right"},}},
		[259]={direction=0, brows={{x=3,y=2,file="Brows20Left"},{x=5,y=1,file="Brows20Right"},}},
		[260]={direction=0, brows={{x=1,y=5,file="Brows20Left"},{x=-2,y=5,file="Brows20Right"},}},
		[261]={direction=0, brows={{x=-3,y=5,file="Brows25Right"},}},
		[262]={direction=0, brows={{x=-5,y=5,file="Brows25Right"},}},
		[263]={direction=0, brows={{x=-6,y=3,file="Brows25Right"},}},
		[264]={direction=0, brows={{x=-5,y=4,file="Brows25Right"},}},
		[265]={direction=0, brows={{x=6,y=3,file="Brows25Right"},}},
		[266]={direction=0, brows={{x=-2,y=3,file="Brows30Right"},}},
		[267]={direction=0, brows={{x=-2,y=2,file="Brows25Right"},}},
		[268]={direction=0, brows={{x=-5,y=5,file="Brows30Right"},}},
		[269]={direction=0, brows={{x=0,y=6,file="Brows25Right"},{x=1,y=6,file="Brows25LeftTall"},}},
		[270]={direction=0, brows={{x=9,y=13,file="Brows20Right"},}},
		[271]={direction=0, brows={{x=0,y=3,file="Brows25Right"},}},
		[272]={direction=0, brows={{x=11,y=-1,file="Brows20Left"},{x=8,y=2,file="Brows20RightFlat"},}},
		[273]={direction=0, brows={{x=0,y=-2,file="Brows30Left"},{x=-1,y=3,file="Brows30RightFlat"},}},
		[274]={direction=0, brows={{x=0,y=0,file="Brows25"},}},
		[275]={direction=0, brows={{x=0,y=6,file="Brows20Right"},}},
		[276]={direction=0, brows={{x=5,y=3,file="Brows15Left"},{x=-4,y=-1,file="Brows30Right"},}},
		[277]={direction=0, brows={{x=-3,y=-1,file="Brows25Right"},}},
		[278]={direction=0, brows={{x=9,y=7,file="Brows20RightFlat"},}},
		[279]={direction=0, brows={{x=11,y=0,file="Brows20Right"},}},
		[280]={direction=0, brows={{x=3,y=2,file="Brows25"},}},
		[281]={direction=0, brows={{x=-1,y=6,file="Brows25Right"},}},
		[282]={direction=0, brows={{x=-3,y=6,file="Brows25Right"},}},
		[283]={direction=0, brows={{x=7,y=10,file="Brows20Left"},{x=9,y=11,file="Brows20RightFlat"},}},
		[284]={direction=0, brows={{x=6,y=8,file="Brows20Left"},{x=7,y=9,file="Brows20Right"},}},
		[285]={direction=0, brows={{x=5,y=7,file="Unibrow20"},{x=12,y=7,file="Unibrow20"},}},
		[286]={direction=0, brows={{x=1,y=6,file="Brows20Right"},}},
		[287]={direction=0, brows={{x=3,y=5,file="Brows25Left"},{x=2,y=9,file="Brows25RightFlat"},}},
		[288]={direction=0, brows={{x=-6,y=1,file="Brows25Right"},}},
		[289]={direction=1, brows={{x=7,y=3,file="Brows20Left"},{x=13,y=9,file="Brows20Left"},}},
		[290]={direction=0, brows={{x=2,y=4,file="Brows25Right"},}},
		[291]={direction=0, brows={{x=2,y=4,file="Brows20Left"},{x=9,y=5,file="Brows20Right"},}},
		[292]={direction=0, brows={{x=3,y=-1,file="Brows30Right"},}},
		[293]={direction=0, brows={{x=8,y=6,file="Brows20Left"},{x=9,y=7,file="Brows20Right"},}},
		[294]={direction=0, brows={{x=6,y=1,file="Brows20LeftFlat"},{x=5,y=-1,file="Brows20Right"},}},
		[295]={direction=0, brows={{x=-4,y=-1,file="Brows25Right"},}},
		[296]={direction=0, brows={{x=9,y=5,file="Brows20Left"},{x=7,y=8,file="Brows20RightFlat"},}},
		[297]={direction=0, brows={{x=3,y=6,file="Brows25Right"},}},
		[298]={direction=0, brows={{x=4,y=1,file="Brows20"},}},
		[299]={direction=0, brows={{x=4,y=2,file="Brows25RightFlat"},}},
		[300]={direction=0, brows={{x=4,y=9,file="Brows20"},}},
		[301]={direction=0, brows={{x=6,y=6,file="Brows25Left"},{x=4,y=7,file="Brows25Right"},}},
		[302]={direction=0, brows={{x=4,y=0,file="Brows25Left"},{x=1,y=4,file="Brows25RightFlat"},}},
		[303]={direction=0, brows={{x=22,y=5,file="Brows20Left"},}},
		[304]={direction=0, brows={{x=-10,y=-1,file="Brows30Right"},}},
		[305]={direction=0, brows={{x=3,y=7,file="Brows25RightTall"},}},
		[306]={direction=0, brows={{x=1,y=5,file="Brows25Right"},}},
		[307]={direction=0, brows={{x=6,y=8,file="Brows25Left"},{x=4,y=7,file="Brows25Right"},}},
		[308]={direction=0, brows={{x=6,y=6,file="Brows25Left"},{x=5,y=7,file="Brows25Right"},}},
		[309]={direction=0, brows={{x=-3,y=2,file="Brows25Right"},}},
		[310]={direction=0, brows={{x=-4,y=4,file="Brows25Right"},}},
		[311]={direction=0, brows={{x=1,y=7,file="Brows20LeftFlat"},{x=3,y=3,file="Brows20Right"},}},
		[312]={direction=0, brows={{x=5,y=6,file="Brows20Left"},{x=8,y=7,file="Brows20Right"},}},
		[313]={direction=1, brows={{x=6,y=3,file="Brows20Left"},{x=16,y=7,file="Brows20Left"},}},
		[314]={direction=0, brows={{x=5,y=5,file="Brows25LeftTall"},{x=6,y=5,file="Brows25RightTall"},}},
		[315]={direction=0, brows={{x=8,y=5,file="Brows20Left"},{x=6,y=5,file="Brows20Left"},}},
		[316]={direction=0, brows={{x=7,y=3,file="Brows15Left"},{x=12,y=4,file="Brows15Right"},}},
		[317]={direction=0, brows={{x=9,y=-1,file="Brows20Right"},}},
		[318]={direction=0, brows={{x=-4,y=1,file="Brows30Right"},}},
		[319]={direction=0, brows={{x=0,y=0,file="Brows25Right"},}},
		[320]={direction=0, brows={{x=3,y=2,file="Brows15Left"},{x=9,y=1,file="Brows15Right"},}},
		[321]={direction=0, brows={{x=10,y=4,file="Brows15Right"},}},
		[322]={direction=0, brows={{x=2,y=1,file="Brows25Right"},}},
		[323]={direction=0, brows={{x=3,y=4,file="Brows25Right"},}},
		[324]={direction=0, brows={{x=1,y=-4,file="Brows30Right"},}},
		[325]={direction=1, brows={{x=10,y=5,file="Brows20Left"},{x=9,y=8,file="Brows20RightFlat"},}},
		[326]={direction=0, brows={{x=0,y=-1,file="Brows25Right"},{x=0,y=-1,file="Brows25Right"},}},
		[327]={direction=1, brows={{x=7,y=3,file="Brows25Left"},{x=19,y=8,file="Brows25LeftFlat"},}},
		[328]={direction=0, brows={{x=17,y=8,file="Brows15Right"},}},
		[329]={direction=0, brows={{x=-1,y=5,file="Brows30Right"},}},
		[330]={direction=0, brows={{x=0,y=-2,file="Brows30"},}},
		[331]={direction=0, brows={{x=6,y=-1,file="Brows25Left"},{x=5,y=-1,file="Brows25Right"},}},
		[332]={direction=0, brows={{x=1,y=4,file="Brows25Right"},}},
		[333]={direction=0, brows={{x=6,y=2,file="Brows20Left"},{x=6,y=6,file="Brows20RightFlat"},}},
		[334]={direction=0, brows={{x=3,y=5,file="Brows20Left"},{x=5,y=5,file="Brows20Right"},}},
		[335]={direction=0, brows={{x=2,y=5,file="Brows25Left"},{x=0,y=7,file="Brows25RightFlat"},}},
		[336]={direction=0, brows={{x=-1,y=0,file="Brows25Right"},}},
		[337]={direction=0, brows={{x=0,y=0,file="Brows30Right"},}},
		[338]={direction=0, brows={{x=3,y=3,file="Brows25Left"},{x=3,y=5,file="Brows25Right"},}},
		[339]={direction=0, brows={{x=9,y=6,file="Brows15Right"},}},
		[340]={direction=0, brows={{x=7,y=6,file="Brows25Right"},}},
		[341]={direction=0, brows={{x=3,y=0,file="Brows25Right"},{x=8,y=4,file="Brows15Left"},}},
		[342]={direction=0, brows={{x=1,y=1,file="Brows25Right"},}},
		[343]={direction=0, brows={{x=-5,y=4,file="Brows30Right"},{x=2,y=2,file="Brows30Left"},}},
		[344]={direction=0, brows={{x=8,y=6,file="Unibrow20"},{x=-1,y=5,file="Unibrow20"},{x=19,y=8,file="Unibrow20"},}},
		[345]={direction=0, brows={{x=9,y=-1,file="Brows25"},}},
		[346]={direction=0, brows={{x=8,y=7,file="Brows25Right"},}},
		[347]={direction=1, brows={{x=2,y=1,file="Brows20Left"},{x=23,y=11,file="Brows20Left"},}},
		[348]={direction=0, brows={{x=-2,y=-4,file="Brows25Left"},{x=8,y=-3,file="Brows25Right"},}},
		[349]={direction=0, brows={{x=-1,y=-2,file="Brows30Right"},}},
		[350]={direction=0, brows={{x=-1,y=6,file="Brows25RightTall"},}},
		[351]={direction=0, brows={{x=-1,y=5,file="Brows25Right"},{x=3,y=7,file="Brows15Left"},}},
		[352]={direction=0, brows={{x=6,y=9,file="Brows20Right"},}},
		[353]={direction=0, brows={{x=3,y=5,file="Brows30Left"},{x=2,y=6,file="Brows30RightTall"},}},
		[354]={direction=0, brows={{x=2,y=5,file="Brows25Left"},{x=5,y=5,file="Brows25Right"},}},
		[355]={direction=0, brows={{x=-9,y=-1,file="Brows30Right"},}},
		[356]={direction=0, brows={{x=9,y=3,file="Unibrow20"},}},
		[357]={direction=0, brows={{x=-4,y=7,file="Brows20Right"},}},
		[358]={direction=0, brows={{x=0,y=4,file="Brows25LeftFlat"},{x=1,y=1,file="Brows25RightTall"},}},
		[359]={direction=0, brows={{x=6,y=9,file="Brows20Left"},{x=4,y=10,file="Brows20Right"},}},
		[360]={direction=0, brows={{x=1,y=1,file="Brows25Left"},{x=0,y=-1,file="Brows25Right"},}},
		[361]={direction=0, brows={{x=6,y=3,file="Brows20Left"},{x=8,y=3,file="Brows20Right"},}},
		[362]={direction=0, brows={{x=3,y=0,file="Brows30Left"},{x=-1,y=0,file="Brows30Right"},}},
		[363]={direction=0, brows={{x=5,y=1,file="Brows20Left"},{x=5,y=4,file="Brows20RightFlat"},}},
		[364]={direction=0, brows={{x=5,y=0,file="Brows25"},}},
		[365]={direction=0, brows={{x=7,y=-2,file="Brows20Right"},}},
		[366]={direction=0, brows={{x=10,y=1,file="Brows20"},}},
		[367]={direction=0, brows={{x=7,y=1,file="Brows20Right"},}},
		[368]={direction=0, brows={{x=1,y=4,file="Brows25Right"},}},
		[369]={direction=0, brows={{x=-4,y=-2,file="Brows25Right"},}},
		[370]={direction=0, brows={{x=4,y=4,file="Brows20Right"},}},
		[371]={direction=0, brows={{x=0,y=5,file="Brows25Right"},}},
		[372]={direction=0, brows={{x=7,y=8,file="Brows20Left"},{x=4,y=10,file="Brows20RightFlat"},}},
		[373]={direction=0, brows={{x=1,y=4,file="Brows20Right"},}},
		[374]={direction=0, brows={{x=-4,y=8,file="Unibrow20"},}},
		[375]={direction=0, brows={{x=2,y=-3,file="Brows25Right"},}},
		[376]={direction=0, brows={{x=5,y=4,file="Brows25Left"},{x=7,y=5,file="Brows25Right"},}},
		[377]={direction=0, brows={{x=4,y=2,file="Unibrow30"},}},
		[378]={direction=0, brows={{x=-1,y=7,file="Unibrow30"},}},
		[379]={direction=0, brows={{x=4,y=4,file="Unibrow30"},}},
		[380]={direction=0, brows={{x=-7,y=8,file="Brows25RightFlat"},}},
		[381]={direction=0, brows={{x=-5,y=17,file="Brows20RightFlat"},}},
		[382]={direction=0, brows={{x=2,y=11,file="Brows20Right"},}},
		[383]={direction=0, brows={{x=-1,y=7,file="Brows25RightTall"},}},
		[384]={direction=0, brows={{x=-4,y=3,file="Brows25Right"},}},
		[385]={direction=0, brows={{x=4,y=6,file="Brows25"},}},
		[386]={direction=0, brows={{x=1,y=8,file="Brows25LeftTall"},{x=3,y=8,file="Brows25RightTall"},}},
		[387]={direction=0, brows={{x=-2,y=3,file="Brows25Right"},}},
		[388]={direction=0, brows={{x=0,y=10,file="Brows20Right"},}},
		[389]={direction=0, brows={{x=2,y=5,file="Brows25RightFlat"},}},
		[390]={direction=0, brows={{x=-1,y=5,file="Brows25Right"},{x=-2,y=5,file="Brows25Left"},}},
		[391]={direction=0, brows={{x=2,y=9,file="Brows20Right"},{x=1,y=10,file="Brows20Left"},}},
		[392]={direction=0, brows={{x=1,y=6,file="Brows25"},}},
		[393]={direction=0, brows={{x=-4,y=5,file="Brows25Right"},}},
		[394]={direction=0, brows={{x=2,y=5,file="Brows25Left"},{x=-1,y=6,file="Brows25Right"},}},
		[395]={direction=0, brows={{x=3,y=8,file="Brows20Left"},{x=2,y=8,file="Brows20Right"},}},
		[396]={direction=0, brows={{x=-1,y=6,file="Brows25Right"},}},
		[397]={direction=0, brows={{x=4,y=4,file="Brows20Right"},}},
		[398]={direction=0, brows={{x=1,y=6,file="Brows20Right"},}},
		[399]={direction=0, brows={{x=5,y=2,file="Brows20Left"},{x=9,y=3,file="Brows20Right"},}},
		[400]={direction=0, brows={{x=5,y=-3,file="Brows25Left"},{x=2,y=-3,file="Brows25Right"},}},
		[401]={direction=0, brows={{x=3,y=5,file="Brows20Left"},{x=4,y=6,file="Brows20Right"},}},
		[402]={direction=0, brows={{x=6,y=1,file="Brows20Left"},{x=11,y=2,file="Brows20Right"},}},
		[403]={direction=0, brows={{x=1,y=0,file="Brows25Left"},{x=5,y=4,file="Brows25RightFlat"},}},
		[404]={direction=0, brows={{x=2,y=7,file="Brows25LeftTall"},{x=8,y=7,file="Brows25RightTall"},}},
		[405]={direction=0, brows={{x=-1,y=10,file="Brows25LeftTall"},}},
		[406]={direction=0, brows={{x=8,y=7,file="Brows20Left"},{x=11,y=7,file="Brows20Right"},}},
		[407]={direction=0, brows={{x=5,y=3,file="Brows25LeftFlat"},{x=2,y=0,file="Brows25Right"},}},
		[408]={direction=0, brows={{x=4,y=10,file="Brows25RightTall"},}},
		[409]={direction=0, brows={{x=0,y=11,file="Brows25RightTall"},}},
		[410]={direction=0, brows={{x=-1,y=5,file="Brows25LeftTall"},{x=2,y=7,file="Brows25RightFlat"},}},
		[411]={direction=0, brows={{x=2,y=2,file="Brows30"},}},
		[412]={direction=0, brows={{x=3,y=0,file="Brows25"},}},
		[413]={direction=0, brows={{x=9,y=4,file="Brows20"},}},
		[414]={direction=0, brows={{x=6,y=5,file="Brows20"},}},
		[415]={direction=0, brows={{x=3,y=0,file="Brows15"},{x=17,y=2,file="Brows15"},{x=8,y=14,file="Brows15"},}},
		[416]={direction=0, brows={{x=10,y=7,file="Brows20"},}},
		[417]={direction=0, brows={{x=1,y=4,file="Brows25"},}},
		[418]={direction=0, brows={{x=-2,y=4,file="Brows25Right"},}},
		[419]={direction=0, brows={{x=-2,y=1,file="Brows25Right"},}},
		[420]={direction=0, brows={{x=3,y=7,file="Brows25"},}},
		[421]={direction=0, brows={{x=9,y=11,file="Brows25"},}},
		[422]={direction=0, brows={{x=-5,y=0,file="Brows30Right"},}},
		[423]={direction=0, brows={{x=7,y=6,file="Brows15Left"},{x=11,y=1,file="Brows15Right"},{x=6,y=2,file="Unibrow20"},}},
		[424]={direction=0, brows={{x=6,y=7,file="Brows25"},}},
		[425]={direction=0, brows={{x=3,y=4,file="Brows25"},}},
		[426]={direction=0, brows={{x=0,y=-2,file="Brows30"},}},
		[427]={direction=0, brows={{x=-2,y=5,file="Brows25"},}},
		[428]={direction=0, brows={{x=4,y=5,file="Brows25Right"},}},
		[429]={direction=0, brows={{x=2,y=0,file="Brows25"},}},
		[430]={direction=0, brows={{x=6,y=2,file="Brows25Right"},}},
		[431]={direction=0, brows={{x=-2,y=-2,file="Brows30Right"},}},
		[432]={direction=0, brows={{x=3,y=2,file="Brows30"},}},
		[433]={direction=0, brows={{x=3,y=4,file="Brows25Left"},{x=4,y=7,file="Brows25Right"},}},
		[434]={direction=0, brows={{x=8,y=3,file="Brows15"},}},
		[435]={direction=0, brows={{x=-3,y=3,file="Brows25Right"},}},
		[436]={direction=0, brows={{x=7,y=2,file="Brows25"},}},
		[437]={direction=0, brows={{x=6,y=3,file="Brows25"},}},
		[438]={direction=0, brows={{x=4,y=3,file="Brows25"},}},
		[439]={direction=0, brows={{x=5,y=4,file="Brows25"},}},
		[440]={direction=0, brows={{x=7,y=3,file="Brows20"},}},
		[441]={direction=0, brows={{x=-1,y=5,file="Brows25Right"},}},
		[442]={direction=0, brows={{x=10,y=4,file="Brows20"},}},
		[443]={direction=0, brows={{x=-4,y=-2,file="Brows25Right"},}},
		[444]={direction=0, brows={{x=-4,y=5,file="Brows25Right"},}},
		[445]={direction=0, brows={{x=-1,y=-2,file="Brows25Right"},}},
		[446]={direction=0, brows={{x=2,y=1,file="Brows25"},}},
		[447]={direction=0, brows={{x=2,y=1,file="Brows25"},}},
		[448]={direction=0, brows={{x=-6,y=3,file="Brows30Right"},}},
		[449]={direction=0, brows={{x=18,y=-3,file="Brows15"},}},
		[450]={direction=0, brows={{x=9,y=1,file="Brows25Right"},}},
		[451]={direction=0, brows={{x=2,y=-4,file="Brows30"},}},
		[452]={direction=0, brows={{x=-1,y=-4,file="Brows30"},}},
		[453]={direction=0, brows={{x=-2,y=-4,file="Brows30"},}},
		[454]={direction=0, brows={{x=0,y=3,file="Brows30"},}},
		[455]={direction=0, brows={{x=0,y=-3,file="Brows30"},}},
		[456]={direction=0, brows={{x=-3,y=6,file="Brows25Right"},}},
		[457]={direction=0, brows={{x=-2,y=-1,file="Brows25Right"},}},
		[458]={direction=0, brows={{x=-2,y=1,file="Brows25"},}},
		[459]={direction=0, brows={{x=4,y=-2,file="Brows25"},}},
		[460]={direction=0, brows={{x=10,y=0,file="Brows15"},}},
		[461]={direction=0, brows={{x=5,y=7,file="Brows25"},}},
		[462]={direction=0, brows={{x=5,y=3,file="Unibrow30"},{x=-5,y=10,file="Unibrow20"},}},
		[463]={direction=0, brows={{x=5,y=-2,file="Brows25"},}},
		[464]={direction=0, brows={{x=-1,y=4,file="Brows25Right"},}},
		[465]={direction=0, brows={{x=11,y=7,file="Brows15"},}},
		[466]={direction=0, brows={{x=5,y=5,file="Brows25"},}},
		[467]={direction=0, brows={{x=4,y=6,file="Brows25"},}},
		[468]={direction=0, brows={{x=-7,y=4,file="Brows25Right"},}},
		[469]={direction=0, brows={{x=0,y=3,file="Brows30"},}},
		[470]={direction=0, brows={{x=1,y=7,file="Brows25"},}},
		[471]={direction=0, brows={{x=-1,y=5,file="Brows25"},}},
		[472]={direction=0, brows={{x=5,y=1,file="Brows25"},}},
		[473]={direction=0, brows={{x=4,y=-2,file="Brows25"},}},
		[474]={direction=0, brows={{x=1,y=0,file="Brows30Right"},}},
		[475]={direction=0, brows={{x=-5,y=5,file="Brows30Right"},}},
		[476]={direction=0, brows={{x=4,y=-4,file="Brows25Right"},}},
		[477]={direction=0, brows={{x=4,y=9,file="Unibrow30"},}},
		[478]={direction=0, brows={{x=-4,y=4,file="Brows25Right"},}},
		[479]={direction=0, brows={{x=2,y=0,file="Brows25Left"},{x=1,y=1,file="Brows25Right"},}},
		[480]={direction=0, brows={{x=0,y=6,file="Brows25"},}},
		[481]={direction=0, brows={{x=3,y=0,file="Brows30"},}},
		[482]={direction=0, brows={{x=-1,y=3,file="Brows30"},}},
		[483]={direction=0, brows={{x=-9,y=0,file="Brows30Right"},}},
		[484]={direction=0, brows={{x=-5,y=-1,file="Brows30Right"},}},
		[485]={direction=0, brows={{x=0,y=-3,file="Brows30"},}},
		[486]={direction=0, brows={{x=1,y=-1,file="Unibrow30"},}},
		[487]={direction=0, brows={{x=-3,y=-1,file="Brows30Right"},}},
		[488]={direction=0, brows={{x=-2,y=6,file="Brows25Right"},}},
		[489]={direction=0, brows={{x=0,y=1,file="Brows25Left"},{x=6,y=7,file="Brows25Right"},}},
		[490]={direction=0, brows={{x=-1,y=1,file="Brows30Left"},{x=3,y=4,file="Brows30Right"},}},
		[491]={direction=0, brows={{x=-6,y=4,file="Brows30Right"},}},
		[492]={direction=0, brows={{x=-7,y=4,file="Brows25Right"},}},
		[493]={direction=0, brows={{x=-6,y=7,file="Brows25Right"},}},
		[494]={direction=0, brows={{x=-3,y=-2,file="Brows30"},}},
		[495]={direction=0, brows={{x=0,y=-5,file="Brows30Right"},}},
		[496]={direction=0, brows={{x=-7,y=-1,file="Brows30Right"},}},
		[497]={direction=0, brows={{x=-1,y=-7,file="Brows30Right"},}},
		[498]={direction=0, brows={{x=-4,y=-3,file="Brows30Right"},}},
		[499]={direction=0, brows={{x=4,y=0,file="Brows25"},}},
		[500]={direction=0, brows={{x=5,y=4,file="Brows25"},}},
		[501]={direction=0, brows={{x=3,y=0,file="Brows30"},}},
		[502]={direction=0, brows={{x=3,y=7,file="Brows25"},}},
		[503]={direction=0, brows={{x=-3,y=0,file="Brows25Right"},}},
		[504]={direction=0, brows={{x=0,y=-4,file="Brows30"},}},
		[505]={direction=0, brows={{x=0,y=-6,file="Brows30"},}},
		[506]={direction=0, brows={{x=4,y=2,file="Brows25"},}},
		[507]={direction=0, brows={{x=3,y=1,file="Brows25"},}},
		[508]={direction=0, brows={{x=2,y=0,file="Brows25"},}},
		[509]={direction=0, brows={{x=3,y=9,file="Brows25"},}},
		[510]={direction=0, brows={{x=-7,y=4,file="Brows30Right"},}},
		[511]={direction=0, brows={{x=6,y=2,file="Brows25"},}},
		[512]={direction=0, brows={{x=5,y=6,file="Brows25"},}},
		[513]={direction=0, brows={{x=2,y=5,file="Brows25"},}},
		[514]={direction=0, brows={{x=4,y=7,file="Brows25"},}},
		[515]={direction=0, brows={{x=3,y=1,file="Brows25"},}},
		[516]={direction=0, brows={{x=7,y=5,file="Brows25"},}},
		[517]={direction=0, brows={{x=2,y=3,file="Brows25Right"},}},
		[518]={direction=0, brows={{x=-1,y=0,file="Brows25Right"},}},
		[519]={direction=0, brows={{x=-1,y=-2,file="Brows30Right"},}},
		[520]={direction=0, brows={{x=0,y=3,file="Brows25Right"},}},
		[521]={direction=0, brows={{x=-2,y=1,file="Brows30Right"},}},
		[522]={direction=0, brows={{x=-4,y=2,file="Brows30Right"},}},
		[523]={direction=0, brows={{x=-4,y=2,file="Brows30Right"},}},
		[524]={direction=0, brows={{x=0,y=10,file="Unibrow30"},}},
		[525]={direction=0, brows={{x=7,y=4,file="Brows25"},}},
		[526]={direction=0, brows={{x=-3,y=3,file="Brows30"},}},
		[527]={direction=0, brows={{x=4,y=6,file="Brows20Left"},{x=14,y=6,file="Brows20Right"},}},
		[528]={direction=0, brows={{x=1,y=9,file="Brows15Left"},{x=3,y=2,file="Brows25Right"},}},
		[529]={direction=0, brows={{x=7,y=1,file="Brows25Right"},}},
		[530]={direction=0, brows={{x=0,y=1,file="Brows25Right"},}},
		[531]={direction=0, brows={{x=9,y=0,file=" Brows25"},}},
		[532]={direction=0, brows={{x=1,y=10,file="Brows15Left"},{x=-4,y=1,file="Brows25Right"},}},
		[533]={direction=0, brows={{x=-1,y=1,file="Brows25Right"},{x=-1,y=1,file="Brows15Left"},}},
		[534]={direction=0, brows={{x=1,y=-1,file="Brows25Right"},}},
		[535]={direction=0, brows={{x=6,y=-1,file="Brows25Left"},{x=6,y=2,file="Brows25Right"},}},
		[536]={direction=0, brows={{x=6,y=4,file="Brows25"},}},
		[537]={direction=0, brows={{x=5,y=3,file="Brows25"},}},
		[538]={direction=0, brows={{x=1,y=5,file="Brows25"},}},
		[539]={direction=0, brows={{x=4,y=4,file="Brows25"},}},
		[540]={direction=0, brows={{x=1,y=5,file="Brows25"},}},
		[541]={direction=0, brows={{x=1,y=5,file="Brows25"},}},
		[542]={direction=0, brows={{x=3,y=4,file="Brows25Left"},{x=6,y=6,file="Brows25Right"},}},
		[543]={direction=0, brows={{x=-2,y=2,file="Brows30"},}},
		[544]={direction=0, brows={{x=-3,y=6,file="Unibrow30"},}},
		[545]={direction=0, brows={{x=-8,y=1,file="Brows30Right"},}},
		[546]={direction=0, brows={{x=4,y=2,file="Brows25"},}},
		[547]={direction=0, brows={{x=6,y=5,file="Brows20"},}},
		[548]={direction=0, brows={{x=4,y=6,file="Brows25"},}},
		[549]={direction=0, brows={{x=3,y=3,file="Brows25"},}},
		[550]={direction=0, brows={{x=-4,y=-2,file="Brows30Right"},}},
		[551]={direction=0, brows={{x=7,y=-7,file="Brows25Left"},{x=7,y=-5,file="Brows25Right"},}},
		[552]={direction=0, brows={{x=6,y=0,file="Brows25"},}},
		[553]={direction=0, brows={{x=8,y=5,file="Brows15"},}},
		[554]={direction=0, brows={{x=3,y=0,file="Brows25"},}},
		[555]={direction=0, brows={{x=1,y=-1,file="Brows25Left"},{x=0,y=0,file="Brows25Right"},}},
		[556]={direction=0, brows={{x=0,y=6,file="Brows25Left"},{x=0,y=3,file="Brows25Right"},}},
		[557]={direction=0, brows={{x=3,y=-6,file="Brows25"},}},
		[558]={direction=0, brows={{x=2,y=1,file="Brows25"},}},
		[559]={direction=0, brows={{x=-1,y=1,file="Brows25Left"},{x=8,y=1,file="Brows25Right"},}},
		[560]={direction=0, brows={{x=2,y=3,file="Brows15Left"},{x=7,y=2,file="Brows25Right"},}},
		[561]={direction=0, brows={{x=-2,y=4,file="Unibrow30"},}},
		[562]={direction=0, brows={{x=-7,y=-2,file="Brows30Right"},}},
		[563]={direction=0, brows={{x=5,y=2,file="Brows20"},}},
		[564]={direction=0, brows={{x=2,y=5,file="Brows25Right"},}},
		[565]={direction=0, brows={{x=-7,y=2,file="Brows30Right"},}},
		[566]={direction=0, brows={{x=0,y=-4,file="Brows30Right"},}},
		[567]={direction=0, brows={{x=-7,y=-3,file="Brows30Right"},}},
		[568]={direction=0, brows={{x=0,y=2,file="Brows25Left"},{x=8,y=4,file="Brows25Right"},}},
		[569]={direction=0, brows={{x=2,y=2,file="Brows25Left"},{x=7,y=3,file="Brows25Right"},}},
		[570]={direction=0, brows={{x=0,y=3,file="Brows30"},}},
		[571]={direction=0, brows={{x=-8,y=7,file="Brows30Right"},}},
		[572]={direction=0, brows={{x=2,y=1,file="Brows30"},}},
		[573]={direction=0, brows={{x=2,y=5,file="Brows25"},}},
		[574]={direction=0, brows={{x=0,y=-1,file="Brows30"},}},
		[575]={direction=0, brows={{x=-2,y=2,file="Brows30Left"},{x=-5,y=-1,file="Brows30Right"},}},
		[576]={direction=0, brows={{x=-2,y=1,file="Brows30Left"},{x=-4,y=2,file="Brows30Right"},}},
		[577]={direction=0, brows={{x=1,y=1,file="Brows25Left"},{x=5,y=3,file="Brows25Right"},}},
		[578]={direction=0, brows={{x=0,y=0,file="Brows25"},}},
		[579]={direction=0, brows={{x=0,y=8,file="Brows15Left"},{x=6,y=7,file="Brows25Right"},}},
		[580]={direction=0, brows={{x=5,y=-1,file="Brows25"},}},
		[581]={direction=0, brows={{x=0,y=6,file="Brows25Right"},}},
		[582]={direction=0, brows={{x=3,y=3,file="Brows25"},}},
		[583]={direction=0, brows={{x=10,y=2,file="Brows15"},}},
		[584]={direction=0, brows={{x=1,y=1,file="Brows15"},{x=20,y=8,file="Brows15"},}},
		[585]={direction=0, brows={{x=5,y=5,file="Brows25Right"},}},
		[586]={direction=0, brows={{x=-2,y=8,file="Brows25Right"},}},
		[587]={direction=0, brows={{x=0,y=4,file="Brows25Left"},{x=2,y=2,file="Brows25Right"},}},
		[588]={direction=0, brows={{x=3,y=-3,file="Brows30Left"},{x=1,y=-1,file="Brows30Right"},}},
		[589]={direction=0, brows={{x=-3,y=2,file="Brows25Left"},}},
		[590]={direction=0, brows={{x=5,y=4,file="Brows25"},}},
		[591]={direction=0, brows={{x=4,y=7,file="Brows25"},}},
		[592]={direction=0, brows={{x=0,y=2,file="Brows25"},}},
		[593]={direction=0, brows={{x=3,y=0,file="Brows25"},}},
		[594]={direction=0, brows={{x=-3,y=0,file="Brows25Right"},}},
		[595]={direction=0, brows={{x=3,y=5,file="Brows25"},}},
		[596]={direction=0, brows={{x=-3,y=5,file="Brows25Left"},{x=4,y=6,file="Brows25Right"},}},
		[597]={direction=0, brows={{x=2,y=3,file="Brows25"},}},
		[598]={direction=0, brows={{x=1,y=-3,file="Brows30"},}},
		[599]={direction=0, brows={{x=2,y=-3,file="Brows15Left"},{x=18,y=16,file="Brows15Left"},}},
		[600]={direction=0, brows={{x=5,y=1,file="Brows15Left"},}},
		[601]={direction=0, brows={{x=7,y=-2,file="Brows15Left"},}},
		[602]={direction=0, brows={{x=-3,y=2,file="Brows25Right"},}},
		[603]={direction=0, brows={{x=2,y=2,file="Brows25Right"},}},
		[604]={direction=0, brows={{x=-4,y=2,file="Brows25Right"},}},
		[605]={direction=0, brows={{x=0,y=10,file="Brows25"},}},
		[606]={direction=0, brows={{x=1,y=8,file="Brows25"},}},
		[607]={direction=0, brows={{x=8,y=12,file="Brows20Right"},}},
		[608]={direction=0, brows={{x=5,y=2,file="Brows25Right"},{x=1,y=8,file="Brows25Left"},}},
		[609]={direction=0, brows={{x=-1,y=4,file="Brows25Left"},{x=4,y=2,file="Brows25Right"},}},
		[610]={direction=0, brows={{x=-3,y=2,file="Brows30Right"},}},
		[611]={direction=0, brows={{x=-3,y=-2,file="Brows25Right"},}},
		[612]={direction=0, brows={{x=-5,y=2,file="Brows25Right"},}},
		[613]={direction=0, brows={{x=2,y=5,file="Brows25Right"},}},
		[614]={direction=0, brows={{x=0,y=-3,file="Brows25Right"},}},
		[615]={direction=0, brows={{x=2,y=1,file="Brows25Right"},{x=1,y=3,file="Brows25Left"},}},
		[616]={direction=0, brows={{x=0,y=5,file="Brows30Right"},}},
		[617]={direction=0, brows={{x=-1,y=8,file="Brows25Right"},}},
		[618]={direction=0, brows={{x=3,y=4,file="Brows25Left"},{x=6,y=6,file="Brows25Right"},}},
		[619]={direction=0, brows={{x=-6,y=9,file="Brows25Right"},{x=0,y=10,file="Brows15Left"},}},
		[620]={direction=0, brows={{x=10,y=3,file="Brows25Left"},}},
		[621]={direction=0, brows={{x=-2,y=1,file="Brows25Right"},}},
		[622]={direction=0, brows={{x=5,y=0,file="Brows25"},}},
		[623]={direction=0, brows={{x=8,y=2,file="Brows15"},}},
		[624]={direction=0, brows={{x=-1,y=7,file="Brows30Right"},}},
		[625]={direction=0, brows={{x=1,y=9,file="Brows25Right"},}},
		[626]={direction=0, brows={{x=1,y=2,file="Brows25Right"},}},
		[627]={direction=0, brows={{x=4,y=3,file="Brows25Left"},}},
		[628]={direction=0, brows={{x=-6,y=6,file="Brows25Left"},{x=1,y=5,file="Brows25Right"},}},
		[629]={direction=0, brows={{x=4,y=0,file="Brows25"},}},
		[630]={direction=0, brows={{x=-3,y=0,file="Brows30Right"},}},
		[631]={direction=0, brows={{x=-4,y=-2,file="Brows30Right"},}},
		[632]={direction=0, brows={{x=0,y=4,file="Brows25"},}},
		[633]={direction=0, brows={{x=-2,y=2,file="Brows25"},}},
		[634]={direction=0, brows={{x=-3,y=4,file="Brows20"},{x=16,y=5,file="Brows20"},}},
		[635]={direction=0, brows={{x=-7,y=-1,file="Brows30Right"},}},
		[636]={direction=0, brows={{x=3,y=2,file="Brows25Right"},}},
		[637]={direction=0, brows={{x=6,y=7,file=" Brows20"},}},
		[638]={direction=0, brows={{x=-3,y=1,file="Brows25Right"},}},
		[639]={direction=0, brows={{x=0,y=0,file="Brows25Right"},}},
		[640]={direction=0, brows={{x=-7,y=0,file="Brows30Right"},}},
		[641]={direction=0, brows={{x=1,y=4,file="Brows20Left"},{x=-1,y=2,file="Brows20Left"},}},
		[642]={direction=0, brows={{x=2,y=0,file="Brows25"},}},
		[643]={direction=0, brows={{x=2,y=0,file="Brows25Right"},}},
		[644]={direction=0, brows={{x=-6,y=0,file="Brows25Right"},}},
		[645]={direction=0, brows={{x=7,y=4,file="Brows20"},}},
		[646]={direction=0, brows={{x=-5,y=4,file="Brows25Right"},}},
		[647]={direction=0, brows={{x=-6,y=2,file="Brows30Right"},}},
		[648]={direction=0, brows={{x=0,y=4,file="Brows25Left"},{x=-2,y=2,file="Brows25Right"},}},
		[649]={direction=0, brows={{x=-4,y=4,file="Brows30Right"},}},
		["Arceus-1"]={direction=0, brows={{x=-6,y=7,file="Brows25Right"},}},
		["Arceus-2"]={direction=0, brows={{x=-6,y=7,file="Brows25Right"},}},
		["Arceus-3"]={direction=0, brows={{x=-6,y=7,file="Brows25Right"},}},
		["Arceus-4"]={direction=0, brows={{x=-6,y=7,file="Brows25Right"},}},
		["Arceus-5"]={direction=0, brows={{x=-6,y=7,file="Brows25Right"},}},
		["Arceus-6"]={direction=0, brows={{x=-6,y=7,file="Brows25Right"},}},
		["Arceus-7"]={direction=0, brows={{x=-6,y=7,file="Brows25Right"},}},
		["Arceus-8"]={direction=0, brows={{x=-6,y=7,file="Brows25Right"},}},
		["Arceus-9"]={direction=0, brows={{x=-6,y=7,file="Brows25Right"},}},
		["Arceus-10"]={direction=0, brows={{x=-6,y=7,file="Brows25Right"},}},
		["Arceus-11"]={direction=0, brows={{x=-6,y=7,file="Brows25Right"},}},
		["Arceus-12"]={direction=0, brows={{x=-6,y=7,file="Brows25Right"},}},
		["Arceus-13"]={direction=0, brows={{x=-6,y=7,file="Brows25Right"},}},
		["Arceus-14"]={direction=0, brows={{x=-6,y=7,file="Brows25Right"},}},
		["Arceus-15"]={direction=0, brows={{x=-6,y=7,file="Brows25Right"},}},
		["Arceus-16"]={direction=0, brows={{x=-6,y=7,file="Brows25Right"},}},
		["Basculin R-1"]={direction=0, brows={{x=-11,y=-3,file="Brows30Right"},}},
		["Burmy P-1"]={direction=0, brows={{x=6,y=1,file="Brows20"},}},
		["Burmy P-2"]={direction=0, brows={{x=6,y=0,file="Brows20"},}},
		["Castform-1"]={direction=0, brows={{x=7,y=2,file="Brows25Left"},{x=7,y=5,file="Brows25Right"},}},
		["Castform-2"]={direction=0, brows={{x=5,y=4,file="Brows25"},}},
		["Castform-3"]={direction=0, brows={{x=3,y=6,file="Brows25"},}},
		["Cherrim O-1"]={direction=0, brows={{x=6,y=3,file="Brows25"},}},
		["Darmanitan-1"]={direction=0, brows={{x=-1,y=-1,file="Brows30"},}},
		["Deerling-1"]={direction=0, brows={{x=5,y=5,file="Brows25Right"},}},
		["Deerling-2"]={direction=0, brows={{x=5,y=5,file="Brows25Right"},}},
		["Deerling-3"]={direction=0, brows={{x=5,y=5,file="Brows25Right"},}},
		["Deoxys-1"]={direction=0, brows={{x=-5,y=7,file="Brows25Right"},}},
		["Deoxys-2"]={direction=0, brows={{x=-2,y=5,file="Brows25Right"},}},
		["Deoxys-3"]={direction=0, brows={{x=-7,y=9,file="Brows25Right"},}},
		["Frillish M-1"]={direction=0, brows={{x=1,y=6,file="Brows25"},}},
		["Gastrodon W-1"]={direction=0, brows={{x=5,y=6,file="Brows15Left"},{x=2,y=3,file="Brows25Right"},{x=6,y=3,file="Unibrow20"},}},
		["Giratina A-1"]={direction=0, brows={{x=-3,y=5,file="Brows25Right"},}},
		["Jellicent M-1"]={direction=0, brows={{x=1,y=-3,file="Brows25"},}},
		["Keldeo-1"]={direction=0, brows={{x=1,y=3,file="Brows25Right"},}},
		["Kyurem-1"]={direction=0, brows={{x=-5,y=7,file="Brows25Right"},}},
		["Kyurem-2"]={direction=0, brows={{x=-8,y=7,file="Brows25Right"},}},
		["Landorus-1"]={direction=0, brows={{x=4,y=5,file="Brows20"},}},
		["Meloetta A-1"]={direction=0, brows={{x=-1,y=8,file="Brows25"},}},
		["Rotom-1"]={direction=0, brows={{x=4,y=1,file="Brows25"},}},
		["Rotom-2"]={direction=0, brows={{x=3,y=-4,file="Brows25"},}},
		["Rotom-3"]={direction=0, brows={{x=5,y=-1,file="Brows25"},}},
		["Rotom-4"]={direction=0, brows={{x=2,y=5,file="Brows25"},}},
		["Rotom-5"]={direction=0, brows={{x=4,y=4,file="Brows25Right"},{x=5,y=1,file="Brows25Left"},}},
		["Sawsbuck-1"]={direction=0, brows={{x=-2,y=8,file="Brows25Right"},}},
		["Sawsbuck-2"]={direction=0, brows={{x=-2,y=8,file="Brows25Right"},}},
		["Sawsbuck-3"]={direction=0, brows={{x=-2,y=8,file="Brows25Right"},}},
		["Shaymin L-1"]={direction=0, brows={{x=-2,y=3,file="Brows25Right"},}},
		["Shellos W-1"]={direction=0, brows={{x=-8,y=4,file="Brows25Right"},}},
		["Thundurus-1"]={direction=0, brows={{x=-3,y=0,file="Brows25Right"},}},
		["Tornadus-1"]={direction=0, brows={{x=-9,y=4,file="Brows25Right"},}},
		["Unfezant M-1"]={direction=0, brows={{x=-2,y=1,file="Brows30Right"},}},
		["Wormadam P-1"]={direction=0, brows={{x=12,y=3,file="Brows15"},}},
		["Wormadam P-2"]={direction=0, brows={{x=12,y=4,file="Brows15"},}},
    }
    local function toggleBrows()
		ui.browsVisible = not ui.controls.brows1.isVisible()
		ui.controls.brows1.setVisibility(ui.browsVisible)
		ui.controls.brows2.setVisibility(ui.browsVisible)
		ui.controls.brows3.setVisibility(ui.browsVisible)
		program.drawCurrentScreens()
	end
    local function onHoverInfoEnd()
        activeHoverFrame = nil
        program.drawCurrentScreens()
    end

    local function setStatPredictionToControl(control, newPrediction, newColor)
        if newPrediction == "_" then
            control.setTextOffset({x = 0, y = -5})
        elseif newPrediction == "=" then
            control.setTextOffset({x = 0, y = -2})
        else
            control.setTextOffset({x = 0, y = -1})
        end
        control.setText(newPrediction)
        control.setTextColorKey(newColor)
    end

    local function onStatPredictionClick(params)
        local pokemonID = params.pokemonID
        local stat = params.stat
        if pokemonID ~= nil and pokemonID ~= 0 then
            local pokemonStatPredictions = tracker.getStatPredictions(pokemonID)
            local states = constants.STAT_PREDICTION_STATES
            local currentState = pokemonStatPredictions[stat]
            local nextState = (currentState % 4) + 1
            pokemonStatPredictions[stat] = nextState
            tracker.setStatPredictions(pokemonID, pokemonStatPredictions)
            setStatPredictionToControl(
                ui.controls[stat .. "StatPrediction"],
                states[nextState].text,
                states[nextState].color
            )
            program.drawCurrentScreens()
        end
    end

    local function onSurvivalHealClick(add)
        if add then
            tracker.increasePokecenterCount()
        else
            tracker.decreasePokecenterCount()
        end
        program.drawCurrentScreens()
    end

    local function resetStatPredictionColor()
        if statCycleIndex ~= -1 then
            local oldStat = stats[statCycleIndex]
            ui.controls[oldStat .. "StatPrediction"].setBackgroundColorKey("Top box background color")
            ui.controls[oldStat .. "StatPrediction"].setTextColorKey("Top box text color")
        end
    end

    local function increaseCycleStatIndex()
        if statCycleIndex == -1 then
            statCycleIndex = 1
        else
            resetStatPredictionColor()
            statCycleIndex = (statCycleIndex % 6) + 1
        end
        local newStat = stats[statCycleIndex]
        ui.controls[newStat .. "StatPrediction"].setBackgroundColorKey("Top box border color")
        program.drawCurrentScreens()
    end

    local function increaseStatPrediction()
        if currentPokemon ~= nil and currentPokemon.owner ~= program.SELECTED_PLAYERS.PLAYER then
            if statCycleIndex ~= -1 then
                local stat = stats[statCycleIndex]
                local params = {
                    pokemonID = currentPokemon.pokemonID,
                    ["stat"] = stat
                }
                onStatPredictionClick(params)
            end
        end
    end

    local function readStatPredictions(pokemonID)
        local pokemonStatPredictions = tracker.getStatPredictions(pokemonID)
        local states = constants.STAT_PREDICTION_STATES
        for stat, predictionState in pairs(pokemonStatPredictions) do
            setStatPredictionToControl(
                ui.controls[stat .. "StatPrediction"],
                states[predictionState].text,
                states[predictionState].color
            )
        end
    end

    local function createNote(params)
        local pokemonID = params.pokemon
        local isEnemy = params.isEnemy
        if pokemonID ~= 0 and isEnemy then
            FormsUtils.createMainScreenNote(
                pokemonID,
                tracker.getNote(pokemonID),
                tracker.setNote,
                program.drawCurrentScreens
            )
        end
    end

    local function onPokemonImageHover(params)
        activeHoverFrame = UIUtils.createAndDrawTypeResistancesFrame(params, program.drawCurrentScreens, ui.frames.mainFrame)
    end

    local function onEncounterHoverEnd()
        activeHoverFrame = nil
        eventListeners.encounterFrameClick.setOnClickParams(true)
        program.drawCurrentScreens()
    end

    local function onEncounterFrameClick(useTrackedData)
        if activeHoverFrame ~= nil then
            activeHoverFrame = nil
            useTrackedData = not useTrackedData
            local encounterData = tracker.getEncounterData()
            local vanillaData = program.getGameInfo().LOCATION_DATA.encounters[encounterData.areaName]
            if useTrackedData then
                activeHoverFrame =
                    UIUtils.createAndDrawTrackedEncounterData(
                    vanillaData,
                    encounterData,
                    program.drawCurrentScreens,
                    ui.frames.mainFrame
                )
            else
                activeHoverFrame =
                    UIUtils.createAndDrawVanillaEncounterData(
                    encounterData.areaName,
                    vanillaData,
                    program.drawCurrentScreens,
                    ui.frames.mainFrame
                )
            end
            eventListeners.encounterFrameClick.setOnClickParams(useTrackedData)
        end
    end

    local function onEncounterDataHover()
        local encounterData = tracker.getEncounterData()
        if encounterData == nil then
            return
        end
        local vanillaData = program.getGameInfo().LOCATION_DATA.encounters[encounterData.areaName]
        activeHoverFrame =
            UIUtils.createAndDrawTrackedEncounterData(
            vanillaData,
            tracker.getEncounterData(),
            program.drawCurrentScreens,
            ui.frames.mainFrame
        )
    end

    local function onMoveHeaderHover(params)
        if params.pokemon == nil then
            return
        end
        local movelvls = params.pokemon.movelvls
        local moveHeaderHoverFrame
        if #movelvls == 0 then
            moveHeaderHoverFrame =
                HoverFrameFactory.createHoverTextFrame(
                "Bottom box background color",
                "Bottom box border color",
                "This Pok" .. Chars.accentedE .. "mon does not learn any moves.",
                "Bottom box text color",
                126
            )
            UIUtils.moveHoverFrameToMouse(
                moveHeaderHoverFrame,
                Graphics.HOVER_ALIGNMENT_TYPE.ALIGN_ABOVE,
                ui.frames.mainFrame
            )
        else
            moveHeaderHoverFrame = HoverFrameFactory.createMoveLevelsHoverFrame(params.pokemon, params.mainFrame)
            UIUtils.moveHoverFrameToMouse(
                moveHeaderHoverFrame,
                Graphics.HOVER_ALIGNMENT_TYPE.ALIGN_ABOVE,
                ui.frames.mainFrame
            )
        end
        activeHoverFrame = moveHeaderHoverFrame
        program.drawCurrentScreens()
        activeHoverFrame.show()
    end

    local function onHoverInfo(hoverParams)
        if hoverParams.text ~= "" then
            activeHoverFrame = UIUtils.createAndDrawHoverFrame(hoverParams, program.drawCurrentScreens, ui.frames.mainFrame)
        end
    end

    local function onItemBagInfoHover(params)
        if ui.frames.healFrame.isVisible() then
            local items = params.items
            local itemType = params.itemType
            if items == nil or next(items) == nil then
                local infoHoverParams = {
                    BGColorKey = "Top box background color",
                    BGColorFillKey = "Top box border color",
                    text = "You currently do not have any " .. itemType:lower() .. " items.",
                    textColorKey = "Top box text color",
                    width = 114,
                    alignment = Graphics.HOVER_ALIGNMENT_TYPE.ALIGN_ABOVE
                }
                onHoverInfo(infoHoverParams)
            else
                activeHoverFrame =
                    UIUtils.createAndDrawItemHoverFrame(items, itemType, ui.frames.mainFrame, program.drawCurrentScreens)
            end
        end
    end

	function self.getInnerFramePosition()
        return ui.frames.mainInnerFrame.getPosition()
    end

    local function onHiddenPowerFrameCounter()
        frameCounters["hiddenPowerCounter"] = nil
        justChangedHiddenPower = false
        program.drawCurrentScreens()
    end

    local function onChangeHiddenPower(direction)
        if direction == "forward" then
            tracker.increaseHiddenPowerType()
        else
            tracker.decreaseHiddenPowerType()
        end
        local baseWait = 90
        local clientFrameRate = client.get_approx_framerate()
        if clientFrameRate ~= nil and clientFrameRate > 60 then
            baseWait = math.floor(baseWait * (clientFrameRate / 60))
        end
        frameCounters["hiddenPowerCounter"] = FrameCounter(baseWait, onHiddenPowerFrameCounter)
        justChangedHiddenPower = true
        program.drawCurrentScreens()
    end

	local function perPokemonBrows()
		local imageID = currentPokemon.pokemonID
        if currentPokemon.baseFormData ~= nil then
            imageID = currentPokemon.baseFormData.baseFormName .. "-" .. currentPokemon.baseFormData.alternateFormIndex
        end
		if browsOptions[imageID] ~= nil then return browsOptions[imageID] else return {direction=0, brows={x=0,y=0, file="Brows25"}} end
	end

	local function updateBrows()
        ui.browsUp = not ui.browsUp
		local browsData = perPokemonBrows()
		local offsetAdjust = browsData.brows
		local direction = browsData.direction

		for i = 1, 3, 1 do
			local controlID = "brows" .. i
			local offset = {x=0,y=-56}
			if ui.browsUp then
                if direction == 0 then
                    offset.y = -59
                elseif direction == 1 then
    				offset.x = 2
				    offset.y = -58
                elseif direction == 2 then
    				offset.x = -2
				    offset.y = -58
			    end
            end
			local filepath = ""
			if offsetAdjust[i] ~= nil then
				offset.x = offset.x + offsetAdjust[i].x
				offset.y = offset.y + offsetAdjust[i].y - ((i-1) * 30)
				filepath = "ironmon_tracker/images/brows/" ..  offsetAdjust[i].file .. ".png"
				ui.controls[controlID].setOffset(offset)
			end
			ui.controls[controlID].setPath(filepath)
		end
        program.drawCurrentScreens()
    end

    local function initUI()
        ui.controls = {}
        ui.frames = {}
        ui.mainFrame = nil
		ui.browsVisible = true
		ui.browsUp = false
        mainScreenUIInitializer = MainScreenUIInitializer(ui, program.getGameInfo())
        mainScreenUIInitializer.initUI()
		frameCounters["browCheck"] = FrameCounter(8, updateBrows, nil, true)
    end

    local function setUpStatStages(isEnemy)
        local showAccEva = settings.appearance.SHOW_ACCURACY_AND_EVASION and program.isInBattle() and not isEnemy
        extraThingsToDraw.statStages = {}
        if currentPokemon.statStages ~= nil then
            for statName, statStage in pairs(currentPokemon.statStages) do
                local namePosition
                local chevronPosition
                if statName ~= "ACC" and statName ~= "EVA" then
                    namePosition = ui.controls[statName .. "StatName"].getPosition()
                elseif statName == "ACC" and showAccEva then
                    namePosition = ui.controls.accuracyLabel.getPosition()
                    namePosition.x = namePosition.x - 2
                elseif statName == "EVA" and showAccEva then
                    namePosition = ui.controls.evasionLabel.getPosition()
                    namePosition.x = namePosition.x - 2
                end
                if namePosition ~= nil then
                    chevronPosition = {x = namePosition.x + 20, y = namePosition.y + 5}
                    extraThingsToDraw.statStages[statName] = {stage = statStage, position = chevronPosition}
                end
            end
        end
    end

    local function setUpMoveEffectiveness(moveIDs)
        extraThingsToDraw.moveEffectiveness = {}
        if settings.battle.SHOW_MOVE_EFFECTIVENESS and moveEffectivenessEnabled then
            for i, moveID in pairs(moveIDs) do
                local moveFrame = ui.moveInfoFrames[i]
                local PPLabelPosition = moveFrame.PPLabel.getPosition()
                local chevronPosition = {x = PPLabelPosition.x + 14, y = PPLabelPosition.y + 3}
                local moveData = MoveData.MOVES[moveID + 1]
                local moveEffectiveness =
                    MoveUtils.netEffectiveness(
                    moveData,
                    opposingPokemon,
                    opposingPokemon == program.SELECTED_PLAYERS.ENEMY,
                    tracker.getCurrentHiddenPowerType()
                )
                table.insert(
                    extraThingsToDraw.moveEffectiveness,
                    {position = chevronPosition, effectiveness = moveEffectiveness}
                )
            end
        end
    end

    local function getImageForStatus(status)
        local imgName = ""
        if program.getGameInfo().GEN == 4 then
            local statusTable = {
                [0] = "",
                [16] = "BRN",
                [32] = "FRZ",
                [64] = "PAR",
                [128] = "PSN"
            }
            if statusTable[status] then
                imgName = statusTable[status]
            elseif status < 8 then
                imgName = "SLP"
            else
                return ""
            end
        elseif program.getGameInfo().GEN == 5 then
            imgName = MiscData.STATUS_TO_IMG_NAME[status]
            if imgName == nil then
                return ""
            end
        end
        local statusPath = "ironmon_tracker/images/status/" .. imgName .. ".png"
        return statusPath
    end

    local function setUpStatusIcon()
        local imagePath = getImageForStatus(currentPokemon.status)
        local iconPosition = ui.controls.pokemonImageLabel.getPosition()
        extraThingsToDraw.status = {
            position = {x = iconPosition.x + 15, y = iconPosition.y + 1},
            statusImagePath = imagePath
        }
    end

    local function checkForVariableMoves(isEnemy, moveIDs, movePPs)
        if not settings.battle.CALCULATE_VARIABLE_DAMAGE then
            return
        end
        for index, moveID in pairs(moveIDs) do
            local name = MoveData.MOVES[moveID + 1].name
            local moveFrame = ui.moveInfoFrames[index]
            local damage =
                MoveUtils.calculateVariableDamage(
                name,
                movePPs,
                index,
                currentPokemon,
                opposingPokemon,
                isEnemy,
                program.isInBattle()
            )
            if damage ~= nil then
                moveFrame.powLabel.setText(damage)
            end
        end
    end

    local function readMovesIntoUI(moveIDs, movePPs, isEnemy)
        for i, moveID in pairs(moveIDs) do
            local moveData = MoveData.MOVES[moveID + 1]
            local moveFrame = ui.moveInfoFrames[i]
            local movePP = movePPs[i]

            moveFrame.categoryIcon.setIconName(moveData.category)
            if settings.colorSettings["Color move names by type"] and moveID ~= 0 then
                moveFrame.moveNameLabel.setTextColorKey(moveData.type)
                if moveData.name == "Hidden Power" and not isEnemy and not currentPokemon.fromTeamInfoView then
                    moveFrame.moveNameLabel.setTextColorKey(tracker.getCurrentHiddenPowerType())
                end
            else
                moveFrame.moveNameLabel.setTextColorKey("Bottom box text color")
            end

            local moveType = moveData.type
            if moveData.name == "Hidden Power" and not isEnemy then
                moveType = tracker.getCurrentHiddenPowerType()
            end

            moveFrame.moveTypeIcon.setIconName(moveType)
            moveFrame.moveTypeIcon.setVisibility(settings.colorSettings["Draw move type icons"])

            moveFrame.categoryIcon.setVisibility(settings.colorSettings["Show phys/spec move icons"])
            local moveNameText = moveData.name

            if justChangedHiddenPower and moveData.name == "Hidden Power" and not isEnemy then
                local hiddenPowerType = tracker:getCurrentHiddenPowerType()
                moveNameText = hiddenPowerType:sub(1, 1) .. hiddenPowerType:sub(2):lower()
            end

            if isEnemy then
                local stars = MoveUtils.getStars(currentPokemon)
                moveNameText = moveNameText .. stars[i]
            end

            moveFrame.moveNameLabel.setText(moveNameText)
            moveFrame.moveNameLabel.resize({width = 70, height = 8})

            if moveData.name == "Hidden Power" and not isEnemy then
                moveFrame.moveNameLabel.resize({width = 53, height = 8})
                local frame = ui.frames["move" .. i .. "NameIconFrame"]
                ui.frames.hiddenPowerArrowsFrame.changeParentFrame(frame, 4)
                ui.frames.hiddenPowerArrowsFrame.setVisibility(true)
            end

            moveFrame.PPLabel.setText(movePP)
            moveFrame.powLabel.setTextColorKey("Bottom box text color")
            if MoveUtils.isSTAB(moveData, currentPokemon) and program.isInBattle() then
                moveFrame.powLabel.setTextColorKey("Positive text color")
            end
            moveFrame.powLabel.setText(moveData.power)
            moveFrame.accLabel.setText(moveData.accuracy)

            if moveData.name == "Return" and not isEnemy then
                local basePower = math.max(currentPokemon.friendship / 2.5, 1)
                basePower = math.floor(basePower)
                if basePower >= 100 then
                    moveFrame.powLabel.setText(tostring(basePower))
                end
            end

            local listener = moveEventListeners[i]
            local params = listener.getOnHoverParams()
            params.text = moveData.description
        end
    end

    local function setUpMoves(isEnemy)
        local movesHeader = MoveUtils.getMoveHeader(currentPokemon)
        ui.controls.moveHeaderLearnedText.setText(movesHeader)
        ui.frames.hiddenPowerArrowsFrame.setVisibility(false)
        local moveIDs = currentPokemon.moveIDs
        local movePPs = {}
        if isEnemy then
            local info =
                MoveUtils.calculateEnemyPPs(
                currentPokemon,
                tracker.getMoves(currentPokemon.pokemonID),
                settings.battle.SHOW_ACTUAL_ENEMY_PP
            )
            moveIDs, movePPs = info.moveIDs, info.movePPs
        else
            for i, moveID in pairs(moveIDs) do
                if moveID == 0 then
                    movePPs[i] = Graphics.TEXT.NO_PP
                else
                    movePPs[i] = currentPokemon.movePPs[i]
                end
            end
        end
        if opposingPokemon ~= nil then
            setUpMoveEffectiveness(moveIDs)
        end
        readMovesIntoUI(moveIDs, movePPs, isEnemy)
        checkForVariableMoves(isEnemy, moveIDs, movePPs)
    end

    local function readTrackedEncountersIntoLabel()
        if inTrackedView or not program.isWildBattle() or inPastRunView then
            ui.frames.encounterDataFrame.setVisibility(false)
            return
        end
        local encounterData = tracker.getEncounterData()
        if encounterData ~= nil then
            local vanillaData = program.getGameInfo().LOCATION_DATA.encounters[encounterData.areaName]
            ui.frames.encounterDataFrame.setVisibility(vanillaData ~= nil)
            if vanillaData ~= nil then
                ui.controls.encountersSeen.setText(encounterData.uniqueSeen .. "/" .. vanillaData.totalPokemon)
            end
        end
    end

    local function setEnemySpecificControls()
        ui.controls.lockIcon.setVisibility(
            not (inTrackedView or inLockedView or inPastRunView) and settings.battle.ENABLE_ENEMY_LOCKING
        )
        local lockIcon = "LOCKED"
        if not program.isLocked() then
            lockIcon = "UNLOCKED"
        end
        ui.controls.lockIcon.setIconName(lockIcon)
        local abilityHoverParams = hoverListeners.abilityHoverListener.getOnHoverParams()
        local itemHoverParams = hoverListeners.heldItemHoverListener.getOnHoverParams()
        readStatPredictions(currentPokemon.pokemonID)
        ui.controls.pokemonHP.setText("HP: ?/?")
        abilityHoverParams.text = ""
        itemHoverParams.text = ""
        local note = tracker.getNote(currentPokemon.pokemonID)
        local lines = DrawingUtils.textToWrappedArray(note, 70)
        ui.controls.mainNoteLabel.setText(lines[1])
        ui.controls.mainNoteLabel.setVisibility(#lines == 1)
        for i = 1, 2, 1 do
            ui.controls.noteLabels[i].setVisibility(#lines > 1)
            if #lines > 1 and DrawingUtils.calculateWordPixelLength(lines[i]) <= 80 then
                ui.controls.noteLabels[i].setText(lines[i])
            end
        end
        ui.controls.heldItem.setText("Total seen: " .. tracker.getAmountSeen(currentPokemon.pokemonID))
        ui.controls.abilityDetails.setText("Last level: " .. tracker.getLastLevelSeen(currentPokemon.pokemonID))
        ui.controls.healsLabel.setText("")
        ui.controls.statusItemsLabel.setText("")
        readTrackedEncountersIntoLabel()
    end

    local function setUpStats(isEnemy)
        ui.controls.BSTNumber.setText(currentPokemon.bst)
        extraThingsToDraw.nature = {}
        for statName, stat in pairs(currentPokemon.stats) do
            ui.controls[statName .. "StatName"].setTextColorKey("Top box text color")
            ui.controls[statName .. "StatNumber"].setVisibility(not isEnemy)
            ui.controls[statName .. "StatPrediction"].setVisibility(isEnemy)
            if isEnemy then
                ui.controls[statName .. "StatName"].resize({width = 30, height = 10})
                statPredictionEventListeners[statName].setOnClickParams(
                    {["stat"] = statName, pokemonID = currentPokemon.pokemonID}
                )
            else
                ui.controls[statName .. "StatName"].resize({width = 25, height = 10})
                ui.controls[statName .. "StatNumber"].setText(stat)
                if statName ~= "HP" and settings.appearance.BLIND_MODE then
                    ui.controls[statName .. "StatNumber"].setText("?")
                end
                local color = DrawingUtils.getNatureColor(statName, currentPokemon.nature)
                local namePosition = ui.controls[statName .. "StatName"].getPosition()
                local naturePosition = {
                    x = namePosition.x + 16,
                    y = namePosition.y - 4
                }
                local colorMapping = {
                    ["Positive text color"] = "plus",
                    ["Negative text color"] = "minus"
                }
                if colorMapping[color] then
                    table.insert(
                        extraThingsToDraw.nature,
                        {
                            position = naturePosition,
                            effect = colorMapping[color]
                        }
                    )
                end
                ui.controls[statName .. "StatName"].setTextColorKey(
                    DrawingUtils.getNatureColor(statName, currentPokemon.nature)
                )
            end
        end
    end

    local function readTeamInfoPokemonIntoUI()
        ui.controls.gearIcon.setVisibility(false)
        ui.frames.healFrame.setVisibility(false)
        ui.frames.enemyNoteFrame.setVisibility(true)
        ui.controls.noteIcon.setVisibility(false)
        ui.controls.mainNoteLabel.setVisibility(true)
        ui.frames.survivalHealFrame.setVisibility(false)
        ui.frames.accEvaFrame.setVisibility(false)
        ui.frames.hiddenPowerArrowsFrame.setVisibility(false)

        eventListeners.loadStatOverview.setOnClickParams(currentPokemon.pokemonID)

        --Repurpose notes into held item viewing.
        local itemDescription = ""
        if currentPokemon.heldItem ~= nil then
            local heldItem = ItemData.ITEMS[currentPokemon.heldItem]
            itemDescription = heldItem.description
            ui.controls.mainNoteLabel.setText("Item: " .. heldItem.name)
        else
            ui.controls.mainNoteLabel.setText("Item: None")
        end
        hoverListeners.heldItemTeamInfo.getOnHoverParams().text = itemDescription
        hoverListeners.abilityHoverListener.getOnHoverParams().text = ""
        hoverListeners.heldItemHoverListener.getOnHoverParams().text = ""

        --pokemon from a log trainer team have a list of abilities, show all 3
        local newAbilityLabels = {ui.controls.pokemonHP, ui.controls.heldItem, ui.controls.abilityDetails}
        local abilities = currentPokemon.abilities
        for index = 1, 3, 1 do
            local ability = abilities[index]
            local hoverListener = hoverListeners["abilityHoverListener" .. index]
            local abilityName = ""
            local abilityDescription = ""
            if ability ~= nil then
                local abilityData = AbilityData.ABILITIES[abilities[index] + 1]
                abilityName = abilityData.name
                abilityDescription = abilityData.description
            end
            newAbilityLabels[index].setText(abilityName)
            hoverListener.getOnHoverParams().text = abilityDescription
        end
    end

    function self.formatForTeamInfoView(pokemonLoadingFunction)
        ui.frames.mainFrame.setBackgroundColorKey("")
        inLockedView = true
        eventListeners.loadStatOverview =
            MouseClickEventListener(ui.controls.pokemonImageLabel, pokemonLoadingFunction, currentPokemon.pokemonID)
        local newAbilityLabels = {ui.controls.pokemonHP, ui.controls.heldItem, ui.controls.abilityDetails}
        for index, newAbilityLabel in pairs(newAbilityLabels) do
            hoverListeners["abilityHoverListener" .. index] =
                HoverEventListener(
                newAbilityLabel,
                onHoverInfo,
                {
                    BGColorKey = "Top box background color",
                    BGColorFillKey = "Top box border color",
                    text = "",
                    textColorKey = "Top box text color",
                    width = 120,
                    alignment = Graphics.HOVER_ALIGNMENT_TYPE.ALIGN_ABOVE
                },
                onHoverInfoEnd
            )
            newAbilityLabel.setTextColorKey("Intermediate text color")
        end
        hoverListeners.heldItemTeamInfo =
            HoverEventListener(
            ui.controls.mainNoteLabel,
            onHoverInfo,
            {
                BGColorKey = "Top box background color",
                BGColorFillKey = "Top box border color",
                text = "",
                textColorKey = "Top box text color",
                width = 120,
                alignment = Graphics.HOVER_ALIGNMENT_TYPE.ALIGN_ABOVE
            },
            onHoverInfoEnd
        )
        local moveHeaderLabels = {"moveHeaderLearnedText", "moveHeaderAcc", "moveHeaderPP", "moveHeaderPow"}
        for _, labelName in pairs(moveHeaderLabels) do
            ui.controls[labelName].setTextColorKey("Top box text color")
            ui.controls[labelName].setShadowColorKey("Top box background color")
        end
    end

    function self.undoTeamInfoView()
        ui.controls.pokemonHP.setTextColorKey("Top box text color")
        ui.frames.mainFrame.setBackgroundColorKey("Main background color")
        inLockedView = false
        eventListeners.loadStatOverview = nil
        for i = 1, 3, 1 do
            hoverListeners["abilityHoverListener" .. i] = nil
        end
        hoverListeners.heldItemTeamInfo = nil
        ui.controls.gearIcon.setVisibility(true)
        local moveHeaderLabels = {"moveHeaderLearnedText", "moveHeaderAcc", "moveHeaderPP", "moveHeaderPow"}
        for _, labelName in pairs(moveHeaderLabels) do
            ui.controls[labelName].setTextColorKey("Move header text color")
            ui.controls[labelName].setShadowColorKey("Main background color")
        end
    end

    function self.undoPastRunView()
        inPastRunView = false
        ui.controls.noteLabels[1].setVisibility(false)
        ui.controls.noteLabels[2].setVisibility(false)
        ui.controls.pastRunLocationIcon.setVisibility(false)
    end

    local function setUpMiscInfo(isEnemy)
        local pokecenters = tracker.getPokecenterCount()
        if pokecenters < 10 then
            pokecenters = " " .. pokecenters
        end
        ui.controls.survivalHealAmountLabel.setText(pokecenters)
        local showAccEva =
            settings.appearance.SHOW_ACCURACY_AND_EVASION and program.isInBattle() and not isEnemy and not inLockedView and
            not inPastRunView
        local showPokecenterHeals =
            not isEnemy and settings.appearance.SHOW_POKECENTER_HEALS and not showAccEva and not inPastRunView
        ui.frames.accEvaFrame.setVisibility(showAccEva)
        ui.frames.survivalHealFrame.setVisibility(showPokecenterHeals)
        local healingTotals = program.getHealingTotals()
        local statusTotals = program.getStatusTotals()
        if healingTotals == nil then
            healingTotals = {healing = 0, numHeals = 0}
        end
        hoverListeners.statusItemsHoverListener.setOnHoverParams({items = program.getStatusItems(), itemType = "Status"})
        hoverListeners.healingItemsHoverListener.setOnHoverParams({items = program.getHealingItems(), itemType = "Healing"})
        ui.controls.healsLabel.setText("Heals: " .. healingTotals.healing .. "% (" .. healingTotals.numHeals .. ")")
        ui.controls.statusItemsLabel.setText("Status items: " .. statusTotals)
        ui.frames.enemyNoteFrame.setVisibility(isEnemy or inPastRunView)
        ui.controls.noteIcon.setVisibility(not inPastRunView)
        ui.frames.healFrame.setVisibility(not isEnemy and not inPastRunView)
        ui.frames.infoBottomFrame.setVisibility(isEnemy)
        ui.frames.encounterDataFrame.setVisibility(false)
        ui.controls.gearIcon.setVisibility(not inTrackedView and not inPastRunView)
    end

    local function readNatureSpecificBerry(heldItemName, heldItemDescription)
        local badNatures = ItemData.NATURE_SPECIFIC_BERRIES[heldItemName]
        local natureName = MiscData.NATURES[currentPokemon.nature + 1]
        if badNatures[natureName] then
            heldItemDescription = heldItemDescription .. " Your Pok" .. Chars.accentedE .. "mon will dislike this."
        else
            heldItemDescription = heldItemDescription .. " Yum!"
        end
    end

    local function setUpMainPokemonInfo(isEnemy)
        local heldItemInfo = ItemData.GEN_5_ITEMS[currentPokemon.heldItem]
        if heldItemInfo == nil then
            heldItemInfo = {
                name = "",
                description = ""
            }
        end
        local name = currentPokemon.name
        ui.controls.pokemonNameLabel.setText(name)
        ui.controls.pokemonHP.setVisibility(not isEnemy)
        local currentIconSet = IconSets.SETS[settings.appearance.ICON_SET_INDEX]
        local imageID = currentPokemon.pokemonID
        if currentPokemon.alternateFormID ~= nil then
            imageID = currentPokemon.alternateFormID
        end
        eventListeners.noteIconListener.setOnClickParams({pokemon = currentPokemon.pokemonID, ["isEnemy"] = isEnemy})
        DrawingUtils.readPokemonIDIntoImageLabel(
            currentIconSet,
            imageID,
            ui.controls.pokemonImageLabel,
            currentIconSet.IMAGE_OFFSET
        )
        local pokemonHoverParams = hoverListeners.pokemonHoverListener.getOnHoverParams()
        pokemonHoverParams.pokemon = currentPokemon
        local evo = currentPokemon.evolution
        --male/female difference evos
        if type(evo) == "table" then
            if not currentPokemon.isFemale then
                currentPokemon.isFemale = 0
            end
            evo = evo[currentPokemon.isFemale + 1]
        end
        if evo == PokemonData.EVOLUTION_TYPES.FRIEND and not isEnemy and currentPokemon.friendship >= 220 then
            evo = "SOON"
        end
        ui.controls.pokemonLevelAndEvo.setText("Lv. " .. currentPokemon.level .. " (" .. evo .. ")")
        ui.controls.pokemonHP.setText("HP: " .. currentPokemon.curHP .. "/" .. currentPokemon.stats.HP)
        local abilityName = AbilityData.ABILITIES[currentPokemon.ability + 1].name
        if settings.appearance.BLIND_MODE then
            abilityName = "?"
        end
        ui.controls.abilityDetails.setText(abilityName)
        ui.controls.heldItem.setText(heldItemInfo.name)
        for i, type in pairs(currentPokemon.type) do
            ui.controls["pokemonType" .. i].setPath(Paths.FOLDERS.TYPE_IMAGES_FOLDER .. "/" .. type .. ".png")
        end
        local abilityHoverParams = hoverListeners.abilityHoverListener.getOnHoverParams()
        local description = AbilityData.ABILITIES[currentPokemon.ability + 1].description
        if settings.appearance.BLIND_MODE then
            description = ""
        end
        if type(description) == "table" then
            description = description[program.getGameInfo().GEN - 3]
        end
        abilityHoverParams.text = description
        local itemHoverParams = hoverListeners.heldItemHoverListener.getOnHoverParams()
        local heldItemDescription = heldItemInfo.description
        if ItemData.NATURE_SPECIFIC_BERRIES[heldItemInfo.name] ~= nil then
            readNatureSpecificBerry(heldItemInfo.name, heldItemDescription)
        end
        itemHoverParams.text = heldItemDescription
    end

    local function readPokemonIntoUI()
        ui.controls.lockIcon.setVisibility(false)
        if not program.isInBattle() and not program.isLocked() then
            resetStatPredictionColor()
            statCycleIndex = -1
        end
        ui.frames.mainFrame.recalculateChildPositions()
        local pokemon = currentPokemon
        local isEnemy = pokemon.owner == program.SELECTED_PLAYERS.ENEMY

        setUpMainPokemonInfo(isEnemy)
        setUpMiscInfo(isEnemy)

        hoverListeners.moveHeaderHoverListener.setOnHoverParams({["pokemon"] = pokemon, mainFrame = ui.frames.mainFrame})

        setUpStats(isEnemy)
        if isEnemy then
            setEnemySpecificControls()
        end
        setUpMoves(isEnemy)
        setUpStatStages(isEnemy)
        setUpStatusIcon()
        if pokemon.fromTeamInfoView then
            readTeamInfoPokemonIntoUI()
        end
    end

    local function openOptionsScreen()
        ui.frames.mainFrame.setVisibility(false)
        client.SetGameExtraPadding(0, 0, Graphics.SIZES.MAIN_SCREEN_PADDING, 0)
        program.setCurrentScreens({program.UI_SCREENS.MAIN_OPTIONS_SCREEN})
        program.drawCurrentScreens()
        ui.frames.mainFrame.setVisibility(true)
    end

    function self.setPokemonToDraw(pokemon, otherPokemon)
        currentPokemon = pokemon
        opposingPokemon = otherPokemon
    end

    function self.addEventListener(eventListener)
        table.insert(eventListeners, eventListener)
    end

    function self.runEventListeners()
        local listenerGroups = {eventListeners, hoverListeners, statPredictionEventListeners, moveEventListeners}
        for _, listenerGroup in pairs(listenerGroups) do
            for _, eventListener in pairs(listenerGroup) do
                eventListener.listen()
            end
        end
        self.runFrameCounters()
    end

    function self.runFrameCounters()
        for _, counter in pairs(frameCounters) do
            counter.decrement()
        end
    end

    function self.resetEventListeners()
        local listenerGroups = {eventListeners, moveEventListeners, statPredictionEventListeners}
        for _, listenerGroup in pairs(listenerGroups) do
            for _, eventListener in pairs(listenerGroup) do
                if eventListener.reset then
                    eventListener.reset()
                end
            end
        end
    end

    function self.resetHoverFrame()
        activeHoverFrame = nil
        self.resetEventListeners()
    end

    function self.show()
        self.updateBadgeLayout()
        readPokemonIntoUI()
        ui.frames.mainFrame.show()
        if not program.isInBattle() or inPastRunView then
            extraThingsToDraw.moveEffectiveness = {}
            extraThingsToDraw.statStages = {}
        end
        if not currentPokemon.fromTeamInfoView then
            DrawingUtils.drawExtraMainScreenStuff(extraThingsToDraw)
        end
        if activeHoverFrame ~= nil then
            activeHoverFrame.show()
        end
    end

    local function initMoveListeners()
        for i = 1, 4, 1 do
            local moveFrame = ui.moveInfoFrames[i]
            moveEventListeners[i] =
                HoverEventListener(
                moveFrame.moveNameLabel,
                onHoverInfo,
                {
                    BGColorKey = "Bottom box background color",
                    BGColorFillKey = "Bottom box border color",
                    text = "",
                    textColorKey = "Bottom box text color",
                    width = 120,
                    alignment = Graphics.HOVER_ALIGNMENT_TYPE.ALIGN_ABOVE
                },
                onHoverInfoEnd
            )
        end
    end

    function self.setNotesAsPastRun(pastRun)
        local location = pastRun.getLocation()
        ui.controls.pastRunLocationIcon.setVisibility(true)
        local validRun = (location ~= "")
        ui.controls.noteLabels[1].setVisibility(validRun)
        ui.controls.noteLabels[2].setVisibility(validRun)
        ui.controls.mainNoteLabel.setVisibility(not validRun)
        if validRun then
            ui.controls.noteLabels[1].setText(pastRun.getDate())
            ui.controls.noteLabels[2].setText(pastRun.getLocation())
        else
            ui.controls.mainNoteLabel.setText("No data was found.")
        end
        if pastRun.getProgress() == PlaythroughConstants.PROGRESS.WON then
            ui.controls.pastRunLocationIcon.setVisibility(false)
            ui.controls.noteLabels[2].setText("You won!")
        end
    end

    local function initStatListeners()
        for _, stat in pairs(stats) do
            local predictionLabel = stat .. "StatPrediction"
            statPredictionEventListeners[stat] =
                MouseClickEventListener(ui.controls[predictionLabel], onStatPredictionClick, {stat = stat, pokemonID = nil})
        end
    end

    local function initEventListeners()
        initMoveListeners()
        hoverListeners.abilityHoverListener =
            HoverEventListener(
            ui.controls.abilityDetails,
            onHoverInfo,
            {
                BGColorKey = "Top box background color",
                BGColorFillKey = "Top box border color",
                text = "",
                textColorKey = "Top box text color",
                width = 120,
                alignment = Graphics.HOVER_ALIGNMENT_TYPE.ALIGN_BELOW
            },
            onHoverInfoEnd
        )
        hoverListeners.heldItemHoverListener =
            HoverEventListener(
            ui.controls.heldItem,
            onHoverInfo,
            {
                BGColorKey = "Top box background color",
                BGColorFillKey = "Top box border color",
                text = "",
                textColorKey = "Top box text color",
                width = 120,
                alignment = Graphics.HOVER_ALIGNMENT_TYPE.ALIGN_BELOW
            },
            onHoverInfoEnd
        )
        hoverListeners.pokemonHoverListener =
            HoverEventListener(
            ui.controls.pokemonImageLabel,
            onPokemonImageHover,
            {pokemon = nil, mainFrame = ui.frames.mainFrame},
            onHoverInfoEnd
        )
        hoverListeners.moveHeaderHoverListener =
            HoverEventListener(ui.controls.moveHeaderLearnedText, onMoveHeaderHover, {pokemon = nil}, onHoverInfoEnd)
        eventListeners.optionsIconListener = MouseClickEventListener(ui.controls.gearIcon, openOptionsScreen, nil)
        eventListeners.noteIconListener = MouseClickEventListener(ui.controls.noteIcon, createNote, nil)
        hoverListeners.healingItemsHoverListener =
            HoverEventListener(ui.controls.healsLabel, onItemBagInfoHover, nil, onHoverInfoEnd)
        hoverListeners.statusItemsHoverListener =
            HoverEventListener(ui.controls.statusItemsLabel, onItemBagInfoHover, nil, onHoverInfoEnd)
        eventListeners.cycleStatListener = JoypadEventListener(settings.controls, "CYCLE_STAT", increaseCycleStatIndex)
        eventListeners.cyclePredictionListener =
            JoypadEventListener(settings.controls, "CYCLE_PREDICTION", increaseStatPrediction)
        eventListeners.increaseSurvivalHealsListener =
            MouseClickEventListener(ui.controls.increaseHealsIcon, onSurvivalHealClick, true)
        eventListeners.decreaseSurvivalHealsListener =
            MouseClickEventListener(ui.controls.decreaseHealsIcon, onSurvivalHealClick, false)
        table.insert(
            eventListeners,
            HoverEventListener(ui.frames.encounterDataFrame, onEncounterDataHover, nil, onEncounterHoverEnd)
        )
        eventListeners.encounterFrameClick =
            MouseClickEventListener(ui.frames.encounterDataFrame, onEncounterFrameClick, true)
        initStatListeners()
        table.insert(
            eventListeners,
            MouseClickEventListener(ui.controls.leftHiddenPowerLabel, onChangeHiddenPower, "backward")
        )
        table.insert(
            eventListeners,
            MouseClickEventListener(ui.controls.rightHiddenPowerLabel, onChangeHiddenPower, "forward")
        )
        eventListeners.browsListener = MouseClickEventListener(ui.controls.pokemonImageLabel, toggleBrows, nil)
    end

    function self.getMainFrameSize()
        return ui.frames.mainFrame.getSize()
    end

    local function recalculateMainFrameSize(orientation)
        local baseSize = {
            width = Graphics.SIZES.MAIN_SCREEN_WIDTH,
            height = Graphics.SIZES.MAIN_SCREEN_HEIGHT
        }
        local spacing = 0
        if settings.badgesAppearance.SPACER then
            spacing = 5
        end
        ui.frames.mainFrame.setLayoutSpacing(spacing)
        local add = {width = 0, height = 0}
        local gameInfo = program.getGameInfo()
        local numBadges = 0
        if ui.frames.badgeFrame1.isVisible() then
            numBadges = numBadges + 1
        end
        if ui.frames.badgeFrame2.isVisible() then
            numBadges = numBadges + 1
        end
        if orientation == "VERTICAL" then
            add.width = numBadges * constants.BADGE_VERTICAL_WIDTH + spacing * numBadges
        else
            add.height = numBadges * constants.BOTTOM_BOX_HEIGHT + spacing * numBadges
        end
        ui.frames.mainFrame.resize({width = baseSize.width + add.width, height = baseSize.height + add.height})
    end

    function self.HGSS_setBadgesToKanto()
        local badgeControls = ui.badgeControlsSet1
        for _, control in pairs(badgeControls) do
            control.setPath(control.getPath():gsub("HGSS", "HGSS_K"))
        end
    end

    function self.updateBadges(newBadges)
        local badgeSets = {
            {badges = newBadges.firstSet, controls = ui.badgeControlsSet1},
            {badges = newBadges.secondSet, controls = ui.badgeControlsSet2}
        }
        for i, badgeSet in pairs(badgeSets) do
            for badgeIndex, control in pairs(badgeSet.controls) do
                local prefix = program.getGameInfo().BADGE_PREFIX
                local badgeValue = badgeSet.badges[badgeIndex]
                local off = ""
                if badgeValue == 0 then
                    off = "_OFF"
                end
                if badgeSet.badges == newBadges.secondSet then
                    prefix = prefix .. "_K"
                end
                control.setPath("ironmon_tracker/images/icons/" .. prefix .. "_badge" .. badgeIndex .. off .. ".png")
            end
        end
    end

    function self.setLanceDefeated(newValue)
        defeatedLance = newValue
    end

    function self.setUpForTrackedPokemonView()
        inTrackedView = true
    end

    function self.setUpForPastRunView()
        inPastRunView = true
    end

    function self.resetToDefault()
        ui.frames.mainFrame.move({x = Graphics.SIZES.SCREEN_WIDTH, y = 0})
        inTrackedView = false
        inLockedView = false
    end

    function self.moveMainScreen(newPosition)
        ui.frames.mainFrame.move(newPosition)
    end

    local function setUpPrimarySecondaryBadgeFrames(primaryBadgeFrame, secondaryBadgeFrame, showBoth)
        if showBoth then
            if settings.badgesAppearance.PRIMARY_BADGE_SET == "KANTO" then
                local temp = primaryBadgeFrame
                primaryBadgeFrame = secondaryBadgeFrame
                secondaryBadgeFrame = temp
            end
        elseif defeatedLance then
            local temp = primaryBadgeFrame
            primaryBadgeFrame = secondaryBadgeFrame
            secondaryBadgeFrame = temp
        end
        primaryBadgeFrame.setVisibility(true)
    end

    local function setBadgeAlignmentAndSize(badgeFrame, newOrientation, showBoth)
        local newSize = {width = 0, height = 0}
        if showBoth then
            badgeFrame.setVisibility(true)
        end
        if newOrientation == "VERTICAL" then
            badgeFrame.setLayoutAlignment(Graphics.ALIGNMENT_TYPE.VERTICAL)
            badgeFrame.setLayoutSpacing(0)
            newSize.width = constants.BADGE_VERTICAL_WIDTH
            newSize.height = constants.BADGE_VERTICAL_HEIGHT
        else
            badgeFrame.setLayoutAlignment(Graphics.ALIGNMENT_TYPE.HORIZONTAL)
            badgeFrame.setLayoutSpacing(1)
            newSize.width = constants.BADGE_HORIZONTAL_WIDTH
            newSize.height = constants.BOTTOM_BOX_HEIGHT
        end
        badgeFrame.resize(newSize)
    end

    local function setUpBadgeParentFrames(primaryBadgeFrame, secondaryBadgeFrame, alignment, showBoth)
        local MAIN_FRAME_INDICES = Graphics.MAIN_FRAME_BADGE_INDICES
        if showBoth then
            local indices = MAIN_FRAME_INDICES[alignment]
            primaryBadgeFrame.changeParentFrame(ui.frames.mainFrame, indices[1])
            secondaryBadgeFrame.changeParentFrame(ui.frames.mainFrame, indices[2])
        else
            secondaryBadgeFrame.setVisibility(false)
            local index = MAIN_FRAME_INDICES[alignment]
            primaryBadgeFrame.changeParentFrame(ui.frames.mainFrame, index)
        end
    end

    function self.updateBadgeLayout()
        if inTrackedView or inLockedView then
            ui.frames.badgeFrame1.setVisibility(false)
            ui.frames.badgeFrame2.setVisibility(false)
            recalculateMainFrameSize("VERTICAL")
            return
        end
        local gameInfo = program.getGameInfo()
        local showBoth =
            settings.badgesAppearance.SHOW_BOTH_BADGES and
            (gameInfo.NAME == "Pokemon HeartGold" or gameInfo.NAME == "Pokemon SoulSilver")

        local primaryBadgeFrame = ui.frames.badgeFrame1
        local secondaryBadgeFrame = ui.frames.badgeFrame2

        setUpPrimarySecondaryBadgeFrames(primaryBadgeFrame, secondaryBadgeFrame, showBoth)

        local alignment = Graphics.BADGE_ALIGNMENT_TYPE[settings.badgesAppearance.SINGLE_BADGE_ALIGNMENT]
        if showBoth then
            alignment = Graphics.BADGE_ALIGNMENT_TYPE[settings.badgesAppearance.DOUBLE_BADGE_ALIGNMENT]
        end

        local newOrientation = Graphics.BADGE_ORIENTATION[alignment]

        local badgeFrames = {primaryBadgeFrame, secondaryBadgeFrame}

        ui.frames.mainFrame.setLayoutAlignment(Graphics.ALIGNMENT_TYPE.VERTICAL)
        if newOrientation == "VERTICAL" then
            ui.frames.mainFrame.setLayoutAlignment(Graphics.ALIGNMENT_TYPE.HORIZONTAL)
        end

        for _, badgeFrame in pairs(badgeFrames) do
            setBadgeAlignmentAndSize(badgeFrame, newOrientation, showBoth)
        end

        setUpBadgeParentFrames(primaryBadgeFrame, secondaryBadgeFrame, alignment, showBoth)
        recalculateMainFrameSize(newOrientation)
    end

    function self.setMoveEffectiveness(newValue)
        moveEffectivenessEnabled = newValue
    end

    initUI()
    initEventListeners()

    return self
end

return MainScreen
