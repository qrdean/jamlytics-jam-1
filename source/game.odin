/*
This file is the starting point of your game.

Some important procedures are:
- game_init_window: Opens the window
- game_init: Sets up the game state
- game_update: Run once per frame
- game_should_close: For stopping your game when close button is pressed
- game_shutdown: Shuts down game and frees memory
- game_shutdown_window: Closes window

The procs above are used regardless if you compile using the `build_release`
script or the `build_hot_reload` script. However, in the hot reload case, the
contents of this file is compiled as part of `build/hot_reload/game.dll` (or
.dylib/.so on mac/linux). In the hot reload cases some other procedures are
also used in order to facilitate the hot reload functionality:

- game_memory: Run just before a hot reload. That way game_hot_reload.exe has a
	pointer to the game's memory that it can hand to the new game DLL.
- game_hot_reloaded: Run after a hot reload so that the `g` global
	variable can be set to whatever pointer it was in the old DLL.

NOTE: When compiled as part of `build_release`, `build_debug` or `build_web`
then this whole package is just treated as a normal Odin package. No DLL is
created.
*/

package game

import "core:fmt"
import "core:math/linalg"
import "core:strings"
import rl "vendor:raylib"

ATLAS_DATA :: #load("../assets/atlas.png")
PIXEL_WINDOW_HEIGHT :: 180
CELL_SIZE :: 16
GRID_SIZE :: 20

Rect :: rl.Rectangle
Vec2 :: rl.Vector2

Game_State :: enum {
	MAIN,
	DIALOGUE,
	INVENTORY,
}

Game_Scene :: enum {
	SCENE_1,
	SCENE_2,
	SCENE_3,
	TITLE,
	CUTSCENE,
	ENDING,
}

ItemType :: enum {
	NONE,
	SCREWDRIVER,
	HAMMER,
	MOVED_BRUSH,
	KEYS,
	SCUFFED_MOSS,
	FOOTPRINTS,
	CAR,
	CAMPFIRE,
	CLIMBING_GEAR,
	BEAR_MACE,
	STURDY_SPLINT,
	MEDICAL_TAPE,
	PHONE,
	STURDY_TREE_LIMBS,
	ROCKS,
	PARACORD,
	BLANKET,
}

NpcType :: enum {
	ITEM,
	OBJECTIVE,
	YOU,
	AMANDA,
	STEVE,
	MAGGIE,
	CLAIRE,
	GEORGE,
	SARAH,
	BRIAN,
	IDA,
}

Item :: struct {
	pos:                   Vec2,
	rect:                  Rect,
	description:           string,
	texture_name:          Texture_Name,
	in_range:              bool,
	collected:             bool,
	note_book_description: string,
}

Npc :: struct {
	id:           NpcType,
	pos:          Vec2,
	rect:         Rect,
	name:         string,
	texture_name: Texture_Name,
	item_needed:  ItemType,
	in_range:     bool,
	item_given:   bool,
}

DIALOG_SIZE_HEIGHT :: 32
DIALOG_SIZE_WIDTH :: 720

Dialog :: struct {
	id:          int,
	npc:         NpcType,
	npc_texture: Texture_Name,
	npc_name:    string,
	dialog_text: [dynamic]string,
	dialog_enum: DialogMapEnum,
}

DialogChainNode :: struct {
	npc:             NpcType,
	dialog_enum:     DialogMapEnum,
	next_chain_node: ^DialogChainNode,
}

Objective :: struct {
	complete:          bool,
	dialog_completion: DialogMapEnum,
}

Game_Memory :: struct {
	debug_mode:                bool,
	game_state:                Game_State,
	game_scene:                Game_Scene,
	run:                       bool,
	atlas:                     rl.Texture,
	font:                      rl.Font,
	some_number:               int,
	player_pos:                rl.Vector2,
	player_texture:            Texture_Name,
	maggie_pos:                Vec2,
	maggie_texture:            Texture_Name,
	test_anim:                 Animation,
	current_dialog:            Dialog,
	current_dialog_chain:      ^DialogChainNode,
	current_dialog_step:       int,
	current_dialog_frame:      int,
	current_objective:         Objective,
	objective_necessary_items: [dynamic]ItemType,
	cutscene_texture_name:     Texture_Name,
	story_flag_1:              bool, // investigate campsite
	story_flag_2:              bool, // fix dads leg
	story_flag_3:              bool, // make lean two

	// Refactor into array
	screwdriver:               Item,
	hammer:                    Item,
	moved_brush:               Item,
	keys:                      Item,
	scuffed_moss:              Item,
	foot_prints_tracks:        Item,
	car:                       Item,
	campfire:                  Item,
	climbing_gear:             Item,
	bear_mace:                 Item,
	sturdy_splint:             Item,
	medical_tape:              Item,
	phone:                     Item,
	sturdy_tree_limbs:         Item,
	rocks:                     Item,
	paracord:                  Item,
	blanket:                   Item,
	lean_two:                  Item,

	// Refactor into array
	amanda:                    Npc,
	steve:                     Npc,
	claire:                    Npc,
	george:                    Npc,
	sarah:                     Npc,
	brian:                     Npc,
	ida:                       Npc,
}


g: ^Game_Memory

DialogMapEnum :: enum {
	OPENING_1,
	AMANDA_OPEN,
	AMANDA_1,
	AMANDA_END_1,
	AMANDA_2,
	YOU_RADIO_CUTSCENE_1,
	AMANDA_CUTSCENE_1,
	INDISTINGUISH,
	YOU_FIND_CUTSCENE_1,
	MAGGIE_FIND_CUTSCENE_1,
	YOU_FIND_CUTSCENE_2,
	STEVE_1,
	STEVE_2,
	STEVE_3,
	STEVE_4_CUTSCENE,
	MAGGIE_1_CUTSCENE,
	STEVE_5_CUTSCENE,
	MAGGIE_2_CUTSCENE,
	STEVE_6_CUTSCENE,
	MAGGIE_3_CUTSCENE,
	STEVE_7_CUTSCENE,
	MAGGIE_4_CUTSCENE,
	STEVE_8_CUTSCENE,
	MAGGIE_5_CUTSCENE,
	CLAIRE_1,
	GEORGE_1,
	SARAH_1,
	BRIAN_1,
	IDA_1,
	ENDING_1,
	ENDING_CUTSCENE_AMANDA_1,
	ENDING_CUTSCENE_YOU_1,
	ENDING_CUTSCENE_AMANDA_2,
	ENDING_CUTSCENE_YOU_2,
	ENDING_CUTSCENE_AMANDA_3,
	ENDING_CUTSCENE_YOU_3,
	OBJECTIVE_1_COMPLETE,
	OBJECTIVE_2_COMPLETE,
	OBJECTIVE_3_COMPLETE,
	OBJECTIVE_4_COMPLETE,
	OBJECTIVE_5_COMPLETE,

	// Items & Clues 
	SCREWDRIVER_ITEM,
	MOVED_BRUSH_CLUE,
	KEYS_CLUE,
	SCUFFED_MOSS_CLUE,
	FOOT_PRINTS_CLUE,
	CAR_CLUE,
	CAMPFIRE_CLUE,
	CLIMBING_GEAR_CLUE,
	BEAR_MACE_CLUE,
	STURDY_SPLINT_ITEM,
	MEDICAL_TAPE_ITEM,
	PHONE_ITEM,
	STURDY_TREE_LIMB_CLUE,
	ROCKS_CLUE,
	PARACORD_ITEM,
	BLANKET_ITEM,
	LEAN_TWO_ITEM,
}

all_dialog: [DialogMapEnum][]string = {
	.OPENING_1                = []string {
		"Becoming a Park Ranger has been one of the most fulfilling jobs I've ever had.",
		"I've gotten to connect with people and nature like never before in my life.",
		"Yeah, cleaning the restrooms and picking up garbase sucks...",
		"But it brings me joy when people say how clean",
		"our restrooms are and how beautiful the land is.",
		"Helping people experience nature is so much more fulfilling than the Software Job I had.",
		"Wonder what adventure we'll have today?",
	},
	.AMANDA_OPEN              = []string {
		"Hey nooby! Got a big one for you.",
		"I just met with a mother who says her husband and daughter didn't",
		"come back from their hike yesterday.",
		"I want you to come check it out with me.",
		"I've been tasked with being the incident commander.",
		"We have a volunteer Search & Rescue teams coming to help,",
		"But it'll take a bit for them to get here.",
		"Luckily we have the trail head they were supposed to take.",
		"Let's go check it out.",
	},
	.AMANDA_1                 = []string {
		"Hey there my name is Amanda",
		"Are you ready to get started?",
		"Great job, you are doing great!",
	},
	.AMANDA_END_1             = []string {
		"Are you ready to wait?",
		"Press 'f' to progress or 'x' to continue exploring",
	},
	.AMANDA_2                 = []string {
		"Alright, based on our findings so far, we have a pretty distinct path to see where they went.",
		"The SAR will fan out, I want you to go East and see what you can find. If you find anything don't hestitate to radio.",
	},
	.YOU_RADIO_CUTSCENE_1     = []string {
		"Looks like they might be back here. Come this way, I'll keep going",
	},
	.AMANDA_CUTSCENE_1        = []string{"Alright, I'll be on your tail shortly."},
	.INDISTINGUISH            = []string{"* indistiguishable chatter *"},
	.YOU_FIND_CUTSCENE_1      = []string{"HELLO?!"},
	.MAGGIE_FIND_CUTSCENE_1   = []string {
		"HELLO? IS SOMEONE THERE???",
		"PLEASE HELP MY DAD IS BADLY HURT. HIS LEG IS BUSTED AND NEEDS ASSITANCE!",
	},
	.YOU_FIND_CUTSCENE_2      = []string{"YES, WE'RE ON OUR WAY"},
	.STEVE_1                  = []string {
		"Arggh!",
		"My legs broken...",
		"There is medical tape in the backpack.",
		"Find a sturdy branch to splint it.",
	},
	.STEVE_2                  = []string{"Thank you...", "Just need to rest now."},
	.STEVE_3                  = []string{"See if you can get some shelter built"},
	.STEVE_4_CUTSCENE         = []string{"Maggie, I'm grateful for you. Proud you're my daughter"},
	.MAGGIE_1_CUTSCENE        = []string{"I know dad"},
	.STEVE_5_CUTSCENE         = []string {
		"Look...",
		"I'm sorry your mom hasn't been who you want her to be lately...",
		"People are complicated",
	},
	.MAGGIE_2_CUTSCENE        = []string {
		"Dad! Don't defend her, she voted for this! You see what's hap-",
	},
	.STEVE_6_CUTSCENE         = []string{"Arg!"},
	.MAGGIE_3_CUTSCENE        = []string {
		"Sorry, you're in pain. Look, Mom and I aren't on good terms right now.",
		"I know you love her... I love her too. But, I just can't get past this.",
		"It just feels like a betrayal of who she is.",
		"Who y'all have taught me to be.",
	},
	.STEVE_7_CUTSCENE         = []string {
		"I know... I'm sorry...",
		"Let's get some rest.",
		"If we don't hear anything tomorrow, you might need to leave and go get help.",
	},
	.MAGGIE_4_CUTSCENE        = []string{"I'm not gonna just leave you-"},
	.STEVE_8_CUTSCENE         = []string{"Maggie...Please..."},
	.MAGGIE_5_CUTSCENE        = []string{"Let's just... Get some sleep.", "You need rest."},
	.CLAIRE_1                 = []string{"im claire"},
	.GEORGE_1                 = []string{"im george"},
	.SARAH_1                  = []string{"im sarah"},
	.BRIAN_1                  = []string{"im brian"},
	.IDA_1                    = []string{"im ida"},
	.ENDING_1                 = []string{"Fin."},
	.ENDING_CUTSCENE_AMANDA_1 = []string {
		"Great job keeping your cool out there.",
		"That was pretty scary. I'm just happy we found them!",
		"How are you feeling?",
	},
	.ENDING_CUTSCENE_YOU_1    = []string {
		"Alright I guess...",
		"It was really nice seeing a father/daughter together bonding, even in trauma.",
		"They're there for each other you know?",
		"Gives me hope.",
	},
	.ENDING_CUTSCENE_AMANDA_2 = []string{"Yeah? Your family been... On the koolaid too?"},
	.ENDING_CUTSCENE_YOU_2    = []string{"Yeah..."},
	.ENDING_CUTSCENE_AMANDA_3 = []string {
		"I'm sorry. Well, we're your family too. We look out for each other",
	},
	.ENDING_CUTSCENE_YOU_3    = []string {
		"Thanks. I know. This has been the right place at the right time.",
	},
	.OBJECTIVE_1_COMPLETE     = []string {
		"You've found enough clues for now.",
		"Let's wait for the Search & Rescue team to arrive",
		"Talk to Amanda to Progress the Story.",
	},
	.OBJECTIVE_2_COMPLETE     = []string{"Go treat your dad's leg."},
	.OBJECTIVE_3_COMPLETE     = []string {
		"You've got the materials to build a lean two.",
		"Build it?",
		"Press 'f' to progress or 'x' to continue exploring",
	},
	.OBJECTIVE_4_COMPLETE     = []string{"Lean Two is built. Should go check it out."},
	.OBJECTIVE_5_COMPLETE     = []string{"Go check out the trails"},

	// Items & Clues
	.SCREWDRIVER_ITEM         = []string{"This is a Screwdriver"},
	.MOVED_BRUSH_CLUE         = []string{"Looks like some broken brush."},
	.KEYS_CLUE                = []string{"A pair of car keys belonging to that truck"},
	.SCUFFED_MOSS_CLUE        = []string{"The moss on this log has been moved."},
	.FOOT_PRINTS_CLUE         = []string{"2 sets of foot prints."},
	.CAR_CLUE                 = []string{"This truck matches the description Claire gave"},
	.CAMPFIRE_CLUE            = []string{"It's been out for days..."},
	.CLIMBING_GEAR_CLUE       = []string{"Looks like they were avid climbers"},
	.BEAR_MACE_CLUE           = []string{"An empty can of bear mace."},
	.STURDY_SPLINT_ITEM       = []string {
		"Sturdy piece of relatively wood.",
		"Could use it to help dad.",
	},
	.MEDICAL_TAPE_ITEM        = []string{"Medical tape. Can use it to help dad."},
	.PHONE_ITEM               = []string {
		"It's dead. Wouldn't do much good anyway without signal though.",
		"Hope someone is looking for us.",
		"Mom...",
	},
	.STURDY_TREE_LIMB_CLUE    = []string {
		"Sturdy Tree Limb",
		"Could use these to build a lean two.",
	},
	.ROCKS_CLUE               = []string {
		"Sturdy rocks.",
		"Could use these to weigh down the blanket for the lean two.",
	},
	.PARACORD_ITEM            = []string {
		"Nice strong paracord. Lucky this was in the bag",
		"Could use this cord to tie the blanket to the trees.",
	},
	.BLANKET_ITEM             = []string{"A good warm covering"},
	.LEAN_TWO_ITEM            = []string {
		"Sleep?",
		"Press 'f' to progress or 'x' to continue exploring",
	},
}

dc_intro_1: DialogChainNode = {
	npc             = .YOU,
	dialog_enum     = .OPENING_1,
	next_chain_node = &dc_intro_2,
}
dc_intro_2: DialogChainNode = {
	npc             = .AMANDA,
	dialog_enum     = .AMANDA_OPEN,
	next_chain_node = nil,
}


dc_steve_maggie_1: DialogChainNode = {
	npc             = .STEVE,
	dialog_enum     = .STEVE_4_CUTSCENE,
	next_chain_node = &dc_steve_maggie_2,
}
dc_steve_maggie_2: DialogChainNode = {
	npc             = .MAGGIE,
	dialog_enum     = .MAGGIE_1_CUTSCENE,
	next_chain_node = &dc_steve_maggie_3,
}
dc_steve_maggie_3: DialogChainNode = {
	npc             = .STEVE,
	dialog_enum     = .STEVE_5_CUTSCENE,
	next_chain_node = &dc_steve_maggie_4,
}
dc_steve_maggie_4: DialogChainNode = {
	npc             = .MAGGIE,
	dialog_enum     = .MAGGIE_2_CUTSCENE,
	next_chain_node = &dc_steve_maggie_5,
}
dc_steve_maggie_5: DialogChainNode = {
	npc             = .STEVE,
	dialog_enum     = .STEVE_6_CUTSCENE,
	next_chain_node = &dc_steve_maggie_6,
}
dc_steve_maggie_6: DialogChainNode = {
	npc             = .MAGGIE,
	dialog_enum     = .MAGGIE_3_CUTSCENE,
	next_chain_node = &dc_steve_maggie_7,
}
dc_steve_maggie_7: DialogChainNode = {
	npc             = .STEVE,
	dialog_enum     = .STEVE_7_CUTSCENE,
	next_chain_node = &dc_steve_maggie_8,
}
dc_steve_maggie_8: DialogChainNode = {
	npc             = .MAGGIE,
	dialog_enum     = .MAGGIE_4_CUTSCENE,
	next_chain_node = &dc_steve_maggie_9,
}
dc_steve_maggie_9: DialogChainNode = {
	npc             = .STEVE,
	dialog_enum     = .STEVE_8_CUTSCENE,
	next_chain_node = &dc_steve_maggie_10,
}
dc_steve_maggie_10: DialogChainNode = {
	npc             = .MAGGIE,
	dialog_enum     = .MAGGIE_5_CUTSCENE,
	next_chain_node = nil,
}

dc_find_1: DialogChainNode = {
	npc             = .YOU,
	dialog_enum     = .YOU_FIND_CUTSCENE_1,
	next_chain_node = &dc_find_2,
}
dc_find_2: DialogChainNode = {
	npc             = .MAGGIE,
	dialog_enum     = .MAGGIE_FIND_CUTSCENE_1,
	next_chain_node = &dc_find_3,
}
dc_find_3: DialogChainNode = {
	npc             = .YOU,
	dialog_enum     = .YOU_FIND_CUTSCENE_2,
	next_chain_node = nil,
}

dc_ending_1: DialogChainNode = {
	npc             = .AMANDA,
	dialog_enum     = .ENDING_CUTSCENE_AMANDA_1,
	next_chain_node = &dc_ending_2,
}
dc_ending_2: DialogChainNode = {
	npc             = .YOU,
	dialog_enum     = .ENDING_CUTSCENE_YOU_1,
	next_chain_node = &dc_ending_3,
}
dc_ending_3: DialogChainNode = {
	npc             = .AMANDA,
	dialog_enum     = .ENDING_CUTSCENE_AMANDA_2,
	next_chain_node = &dc_ending_4,
}
dc_ending_4: DialogChainNode = {
	npc             = .YOU,
	dialog_enum     = .ENDING_CUTSCENE_YOU_2,
	next_chain_node = &dc_ending_5,
}
dc_ending_5: DialogChainNode = {
	npc             = .AMANDA,
	dialog_enum     = .ENDING_CUTSCENE_AMANDA_3,
	next_chain_node = &dc_ending_6,
}
dc_ending_6: DialogChainNode = {
	npc             = .YOU,
	dialog_enum     = .ENDING_CUTSCENE_YOU_3,
	next_chain_node = nil,
}


load_dialog :: proc(npc_type: DialogMapEnum) -> [dynamic]string {
	dialog_text := make([dynamic]string, context.allocator)
	dialog_slices := all_dialog[npc_type]
	for dialog_slice in dialog_slices {
		append(&dialog_text, dialog_slice)
	}
	return dialog_text
}

Tasks :: enum {
	NONE,
	TASK_1,
	TASK_2,
	TASK_3,
	TASK_5,
}

item_collection_tasks: [Tasks][]ItemType = {
	.NONE   = []ItemType{},
	.TASK_1 = []ItemType{ItemType.SCREWDRIVER, ItemType.HAMMER},
	.TASK_2 = []ItemType{ItemType.STURDY_SPLINT, ItemType.MEDICAL_TAPE},
	.TASK_3 = []ItemType {
		ItemType.STURDY_TREE_LIMBS,
		ItemType.ROCKS,
		ItemType.PARACORD,
		ItemType.BLANKET,
	},
	.TASK_5 = []ItemType{ItemType.BEAR_MACE},
}

game_camera :: proc(target_pos: Vec2) -> rl.Camera2D {
	w := f32(rl.GetScreenWidth())
	h := f32(rl.GetScreenHeight())

	return {zoom = h / PIXEL_WINDOW_HEIGHT, target = target_pos, offset = {w / 2, h / 2}}
}

cutscene_camera :: proc() -> rl.Camera2D {
	h := f32(rl.GetScreenHeight())
	return {zoom = h / (PIXEL_WINDOW_HEIGHT)}
}

ui_camera :: proc() -> rl.Camera2D {
	return {zoom = f32(rl.GetScreenHeight()) / PIXEL_WINDOW_HEIGHT}
}

load_task :: proc(task: Tasks) -> [dynamic]ItemType {
	delete(g.objective_necessary_items)
	task_items := make([dynamic]ItemType, context.allocator)
	task_slices := item_collection_tasks[task]
	for task_slice in task_slices {
		append(&task_items, task_slice)
	}
	return task_items
}

// pulled from https://github.com/ChrisPHP/odin-tilemap-collision/blob/main/collision.odin
naive_collision :: proc(x, y: f32, moveDirection: [2]f32) -> bool {
	new_x := x
	new_y := y

	collision_rect := rl.Rectangle {
		x      = new_x,
		y      = new_y,
		width  = 16.,
		height = 16.,
	}

	//check neighbouring tiles
	directions := [][2]int{{-1, 0}, {0, -1}, {1, 0}, {0, 1}, {-1, -1}, {-1, 1}, {1, -1}, {1, 1}}

	collided := false

	half_size: f32 = CELL_SIZE / 2

	for pos in directions {
		//get tilemap coordinates
		pos_x := pos[0] + int((new_x + half_size) / CELL_SIZE)
		pos_y := pos[1] + int((new_y + half_size) / CELL_SIZE)
		cur_grid := grid
		if g.game_scene == .SCENE_2 {
			cur_grid = grid_two
		}
		if pos_x != -1 &&
		   pos_y != -1 &&
		   pos_x < GRID_SIZE &&
		   pos_y < GRID_SIZE &&
		   (cur_grid[pos_y][pos_x] == .TWL || cur_grid[pos_y][pos_x] == .WLN) {
			wall := rl.Rectangle {
				x      = f32(pos_x) * CELL_SIZE,
				y      = f32(pos_y) * CELL_SIZE,
				width  = CELL_SIZE,
				height = CELL_SIZE,
			}
			//Check rectangle collision
			if rl.CheckCollisionRecs(collision_rect, wall) {
				collided = true
				break
			}
		}
	}

	return collided
}

player_update :: proc(dt: f32, player_pos: ^Vec2) {
	input: rl.Vector2

	if rl.IsKeyDown(.UP) || rl.IsKeyDown(.W) {
		input.y -= 1
	}
	if rl.IsKeyDown(.DOWN) || rl.IsKeyDown(.S) {
		input.y += 1
	}
	if rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.A) {
		input.x -= 1
	}
	if rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.D) {
		input.x += 1
	}

	new_x := player_pos.x + input.x * 50.0 * dt
	new_y := player_pos.y + input.y * 50.0 * dt

	// run collision detection
	// If return true set new x and y to player position
	colliding := naive_collision(new_x, new_y, input)
	if !colliding {
		player_pos.x = new_x
		player_pos.y = new_y
	}
}

handle_item_interaction :: proc(item: ^Item, c: proc()) {
	item.in_range = (collide_with_item(item^, g.player_pos) && !item.collected)
	if item.in_range {
		if rl.IsKeyPressed(.E) {
			c()
		}
	}
}

// This is messy but it works. Could pass in a pointer or something, but it's already
// a pointer to g so wtf is the point
handle_item_interactions :: proc() {
	switch g.game_scene {
	case .SCENE_1:
		handle_item_interaction(
			&g.screwdriver,
			proc() {g.screwdriver.collected = true;handle_dialog(.ITEM, .SCREWDRIVER_ITEM)},
		)
		handle_item_interaction(&g.hammer, proc() {g.hammer.collected = true})
		handle_item_interaction(
			&g.moved_brush,
			proc() {g.moved_brush.collected = true;handle_dialog(.ITEM, .MOVED_BRUSH_CLUE)},
		)
		handle_item_interaction(
			&g.keys,
			proc() {g.keys.collected = true;handle_dialog(.ITEM, .KEYS_CLUE)},
		)
		handle_item_interaction(
			&g.car,
			proc() {g.car.collected = true;handle_dialog(.ITEM, .CAR_CLUE)},
		)
		handle_item_interaction(
			&g.campfire,
			proc() {g.campfire.collected = true;handle_dialog(.ITEM, .CAMPFIRE_CLUE)},
		)
		handle_item_interaction(
			&g.climbing_gear,
			proc() {g.climbing_gear.collected = true;handle_dialog(.ITEM, .CLIMBING_GEAR_CLUE)},
		)
	case .SCENE_2:
		handle_item_interaction(
			&g.sturdy_splint,
			proc() {g.sturdy_splint.collected = true;handle_dialog(.ITEM, .STURDY_SPLINT_ITEM)},
		)
		handle_item_interaction(
			&g.medical_tape,
			proc() {g.medical_tape.collected = true;handle_dialog(.ITEM, .MEDICAL_TAPE_ITEM)},
		)
		handle_item_interaction(
			&g.phone,
			proc() {g.phone.collected = true;handle_dialog(.ITEM, .PHONE_ITEM)},
		)
		handle_item_interaction(&g.sturdy_tree_limbs, proc() {g.sturdy_tree_limbs.collected = true
			handle_dialog(.ITEM, .STURDY_TREE_LIMB_CLUE)})
		handle_item_interaction(
			&g.rocks,
			proc() {g.rocks.collected = true;handle_dialog(.ITEM, .ROCKS_CLUE)},
		)
		handle_item_interaction(
			&g.paracord,
			proc() {g.paracord.collected = true;handle_dialog(.ITEM, .PARACORD_ITEM)},
		)
		handle_item_interaction(
			&g.blanket,
			proc() {g.blanket.collected = true;handle_dialog(.ITEM, .BLANKET_ITEM)},
		)
		handle_item_interaction(&g.lean_two, proc() {handle_dialog(.ITEM, .LEAN_TWO_ITEM)})
	case .SCENE_3:
		handle_item_interaction(
			&g.bear_mace,
			proc() {g.bear_mace.collected = true;handle_dialog(.ITEM, .BEAR_MACE_CLUE)},
		)
		handle_item_interaction(
			&g.scuffed_moss,
			proc() {g.scuffed_moss.collected = true;handle_dialog(.ITEM, .SCUFFED_MOSS_CLUE)},
		)
		handle_item_interaction(
			&g.foot_prints_tracks,
			proc() {g.foot_prints_tracks.collected = true;handle_dialog(.ITEM, .FOOT_PRINTS_CLUE)},
		)
	case .CUTSCENE:
	case .ENDING:
	case .TITLE:
	}
}

handle_dialog :: proc(npc_type: NpcType, dialog_enum: DialogMapEnum) {
	dialog: Dialog
	switch npc_type {
	case .AMANDA:
		dialog = Dialog{1, .AMANDA, .Amanda, "Amanda", load_dialog(dialog_enum), dialog_enum}
	case .CLAIRE:
		dialog = Dialog{4, .CLAIRE, .Claire, "Claire", load_dialog(dialog_enum), dialog_enum}
	case .STEVE:
		dialog = Dialog{5, .STEVE, .Steve, "Steve", load_dialog(dialog_enum), dialog_enum}
	case .MAGGIE:
		dialog = Dialog{10, .MAGGIE, .Maggie, "Maggie", load_dialog(dialog_enum), dialog_enum}
	case .YOU:
		dialog = Dialog{11, .YOU, .Ranger_Base, "You", load_dialog(dialog_enum), dialog_enum}
	case .BRIAN:
		dialog = Dialog{6, .BRIAN, .Ranger_Sar, "Brian", load_dialog(dialog_enum), dialog_enum}
	case .GEORGE:
		dialog = Dialog{7, .GEORGE, .Ranger_Sar, "George", load_dialog(dialog_enum), dialog_enum}
	case .IDA:
		dialog = Dialog{8, .IDA, .Ranger_Sar_Fem, "Ida", load_dialog(dialog_enum), dialog_enum}
	case .SARAH:
		dialog = Dialog{9, .SARAH, .Ranger_Sar_Fem, "Sarah", load_dialog(dialog_enum), dialog_enum}
	case .ITEM:
		dialog = Dialog{2, .ITEM, .None, "Item", load_dialog(dialog_enum), dialog_enum}
	case .OBJECTIVE:
		dialog = Dialog{3, .OBJECTIVE, .None, "", load_dialog(dialog_enum), dialog_enum}
	}
	delete(g.current_dialog.dialog_text)
	g.current_dialog = dialog
	g.current_dialog_step = 0
	g.game_state = .DIALOGUE
}


handle_dialog_chain :: proc(dialog_chain: ^DialogChainNode) -> ^DialogChainNode {
	handle_dialog(dialog_chain.npc, dialog_chain.dialog_enum)
	return dialog_chain.next_chain_node
}

collide_with_item :: proc(item: Item, player_pos: Vec2) -> bool {
	interaction_rect := rl.Rectangle {
		x      = player_pos.x,
		y      = player_pos.y,
		width  = 16.,
		height = 16.,
	}

	return rl.CheckCollisionRecs(item.rect, interaction_rect)
}

handle_npc_interactions :: proc() {
	switch g.game_scene {
	case .SCENE_1:
		g.amanda.in_range = collide_with_npc(g.amanda, g.player_pos)
		if g.amanda.in_range {
			if rl.IsKeyPressed(.E) {
				if g.story_flag_1 {
					handle_dialog(.AMANDA, .AMANDA_END_1)
				} else {
					handle_dialog(.AMANDA, .AMANDA_1)
				}
			}
		}
	case .SCENE_2:
		g.steve.in_range = collide_with_npc(g.steve, g.player_pos)
		if g.steve.in_range {
			if rl.IsKeyPressed(.E) {
				if g.story_flag_2 {
					handle_dialog(.STEVE, .STEVE_3)
				} else {
					if check_items() {
						handle_dialog(.STEVE, .STEVE_2)
						g.story_flag_2 = true
						g.objective_necessary_items = load_task(.TASK_3)
						g.current_objective.complete = false
						g.current_objective.dialog_completion = .OBJECTIVE_3_COMPLETE
					} else {
						handle_dialog(.STEVE, .STEVE_1)
					}
				}
			}
		}
		g.claire.in_range = collide_with_npc(g.claire, g.player_pos)
		if g.claire.in_range {
			if rl.IsKeyPressed(.E) {
				handle_dialog(.CLAIRE, .CLAIRE_1)
			}
		}
	case .SCENE_3:
		g.amanda.in_range = collide_with_npc(g.amanda, g.player_pos)
		if g.amanda.in_range {
			if rl.IsKeyPressed(.E) {
				handle_dialog(.AMANDA, .AMANDA_2)
			}
		}
		g.george.in_range = collide_with_npc(g.george, g.player_pos)
		if g.george.in_range {
			if rl.IsKeyPressed(.E) {
				handle_dialog(.GEORGE, .GEORGE_1)
			}
		}
		g.sarah.in_range = collide_with_npc(g.sarah, g.player_pos)
		if g.sarah.in_range {
			if rl.IsKeyPressed(.E) {
				handle_dialog(.SARAH, .SARAH_1)
			}
		}
		g.brian.in_range = collide_with_npc(g.brian, g.player_pos)
		if g.brian.in_range {
			if rl.IsKeyPressed(.E) {
				handle_dialog(.BRIAN, .BRIAN_1)
			}
		}
		g.ida.in_range = collide_with_npc(g.ida, g.player_pos)
		if g.ida.in_range {
			if rl.IsKeyPressed(.E) {
				handle_dialog(.IDA, .IDA_1)
			}
		}
	case .CUTSCENE:
	case .ENDING:
	case .TITLE:
	}
}

collide_with_npc :: proc(npc: Npc, player_pos: Vec2) -> bool {
	interaction_rect := rl.Rectangle {
		x      = player_pos.x,
		y      = player_pos.y,
		width  = 16.,
		height = 16.,
	}

	return rl.CheckCollisionRecs(npc.rect, interaction_rect)
}

update :: proc(dt: f32) {
	switch g.game_state {
	case .DIALOGUE:
		size := len(g.current_dialog.dialog_text)
		if g.current_dialog.dialog_enum == .AMANDA_END_1 {
			if rl.IsKeyPressed(.F) {
				fmt.println("yes")
				g.game_scene = .SCENE_2
				g.current_objective.complete = false
				g.current_objective.dialog_completion = .OBJECTIVE_2_COMPLETE
				g.objective_necessary_items = load_task(.TASK_2)
				g.game_state = .MAIN
			}
			if rl.IsKeyPressed(.X) {
				fmt.println("no")
				g.game_state = .MAIN
			}
		}

		if g.current_dialog.dialog_enum == .OBJECTIVE_3_COMPLETE {
			if rl.IsKeyPressed(.F) {
				g.lean_two.collected = false
				g.current_objective.complete = false
				g.current_objective.dialog_completion = .OBJECTIVE_4_COMPLETE
				g.objective_necessary_items = load_task(.NONE)
				g.game_state = .MAIN
			}
			if rl.IsKeyPressed(.X) {
				g.game_state = .MAIN
			}
		}

		if g.current_dialog.dialog_enum == .LEAN_TWO_ITEM {
			if rl.IsKeyPressed(.F) {
				g.game_scene = .CUTSCENE
				g.cutscene_texture_name = .Cutscene_1
				g.current_dialog_chain = &dc_steve_maggie_1
				g.current_dialog_chain = handle_dialog_chain(g.current_dialog_chain)
			}
			if rl.IsKeyPressed(.X) {
				g.game_state = .MAIN
			}
		}

		if g.current_dialog.dialog_enum == .OBJECTIVE_5_COMPLETE {
			g.game_scene = .CUTSCENE
			g.cutscene_texture_name = .Cutscene_1
			g.current_dialog_chain = &dc_find_1
			g.current_dialog_chain = handle_dialog_chain(g.current_dialog_chain)
		}

		if g.current_dialog.dialog_enum == .YOU_FIND_CUTSCENE_2 {
			g.game_scene = .CUTSCENE
			g.cutscene_texture_name = .Cutscene_1
			g.current_dialog_chain = &dc_ending_1
			g.current_dialog_chain = handle_dialog_chain(g.current_dialog_chain)
		}

		if rl.IsKeyPressed(.E) {
			// continue dialogue
			g.current_dialog_frame = 0
			if g.current_dialog_step >= (size - 1) {
				if g.current_dialog.dialog_enum == .AMANDA_OPEN {
					g.game_scene = .SCENE_1
				}
				if g.current_dialog.dialog_enum == .MAGGIE_5_CUTSCENE {
					g.current_objective.complete = false
					g.current_objective.dialog_completion = .OBJECTIVE_5_COMPLETE
					g.objective_necessary_items = load_task(.TASK_5)
					g.game_scene = .SCENE_3
				}
				if g.current_dialog.dialog_enum == .ENDING_CUTSCENE_YOU_3 {
					g.current_objective.complete = false
					g.game_scene = .ENDING
				}
				if g.current_dialog_chain != nil {
					g.current_dialog_chain = handle_dialog_chain(g.current_dialog_chain)
				} else {
					g.game_state = .MAIN
				}
			} else {
				g.current_dialog_step += 1
			}
		}
		g.current_dialog_frame += 2
	case .INVENTORY:
		if rl.IsKeyPressed(.Q) {
			g.game_state = .MAIN
		}
	case .MAIN:
		if g.game_scene == .TITLE {
			if rl.IsKeyPressed(.ENTER) {
				g.current_dialog_chain = handle_dialog_chain(&dc_intro_1)
				g.game_scene = .CUTSCENE
				g.game_state = .DIALOGUE
			}
			return
		}
		input: rl.Vector2

		if rl.IsKeyDown(.UP) || rl.IsKeyDown(.W) {
			input.y -= 1
		}
		if rl.IsKeyDown(.DOWN) || rl.IsKeyDown(.S) {
			input.y += 1
		}
		if rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.A) {
			input.x -= 1
		}
		if rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.D) {
			input.x += 1
		}
		if rl.IsKeyDown(.I) {
			g.game_state = .INVENTORY
		}

		if g.debug_mode {
			if rl.IsKeyPressed(.O) {
				g.game_scene = .SCENE_1
			}
			if rl.IsKeyPressed(.L) {
				g.game_scene = .SCENE_2
			}
			if rl.IsKeyPressed(.K) {
				g.game_scene = .SCENE_3
			}
		}

		if rl.IsKeyPressed(.T) {
			g.current_objective.complete = check_items()
			if g.current_objective.complete {
				handle_dialog(.OBJECTIVE, g.current_objective.dialog_completion)
				#partial switch g.current_objective.dialog_completion {
				case .OBJECTIVE_1_COMPLETE:
					g.story_flag_1 = true
				}
			}
		}

		// animation_update(&g.test_anim, rl.GetFrameTime())

		input = linalg.normalize0(input)
		player_update(dt, &g.player_pos)

		handle_item_interactions()
		handle_npc_interactions()
	}

	// g.player_pos += input * rl.GetFrameTime() * 100
	g.some_number += 1

	if rl.IsKeyPressed(.ESCAPE) {
		g.run = false
	}
}

// FIXME: This is shit 
check_items :: proc() -> bool {
	check_complete := true
	for i in 0 ..< len(g.objective_necessary_items) {
		item := g.objective_necessary_items[i]
		if item == ItemType.HAMMER {
			if !g.hammer.collected {
				check_complete = false
				break
			}
		}
		if item == ItemType.MOVED_BRUSH {
			if !g.moved_brush.collected {
				check_complete = false
				break
			}
		}
		if item == ItemType.KEYS {
			if !g.keys.collected {
				check_complete = false
				break
			}
		}
		if item == ItemType.SCUFFED_MOSS {
			if !g.scuffed_moss.collected {
				check_complete = false
				break
			}
		}
		if item == ItemType.FOOTPRINTS {
			if !g.foot_prints_tracks.collected {
				check_complete = false
				break
			}
		}
		if item == ItemType.CAR {
			if !g.car.collected {
				check_complete = false
				break
			}
		}
		if item == ItemType.CAMPFIRE {
			if !g.campfire.collected {
				check_complete = false
				break
			}
		}
		if item == ItemType.CLIMBING_GEAR {
			if !g.climbing_gear.collected {
				check_complete = false
				break
			}
		}
		if item == ItemType.BEAR_MACE {
			if !g.bear_mace.collected {
				check_complete = false
				break
			}
		}
		if item == ItemType.BEAR_MACE {
			if !g.bear_mace.collected {
				check_complete = false
				break
			}
		}
		if item == ItemType.STURDY_SPLINT {
			if !g.sturdy_splint.collected {
				check_complete = false
				break
			}
		}
		if item == ItemType.MEDICAL_TAPE {
			if !g.medical_tape.collected {
				check_complete = false
				break
			}
		}
		if item == ItemType.PHONE {
			if !g.phone.collected {
				check_complete = false
				break
			}
		}
		if item == ItemType.STURDY_TREE_LIMBS {
			if !g.sturdy_tree_limbs.collected {
				check_complete = false
				break
			}
		}
		if item == ItemType.ROCKS {
			if !g.rocks.collected {
				check_complete = false
				break
			}
		}
		if item == ItemType.PARACORD {
			if !g.paracord.collected {
				check_complete = false
				break
			}
		}
		if item == ItemType.BLANKET {
			if !g.blanket.collected {
				check_complete = false
				break
			}
		}
	}
	return check_complete
}

// Draw Data
draw_item :: proc(item: Item) {
	if item.collected {
		return
	}
	if item.texture_name != .None {
		something := atlas_textures[item.texture_name]
		rl.DrawTextureRec(g.atlas, something.rect, item.pos, rl.WHITE)
	}
	debug_pos_offset := Vec2{item.pos.x, item.pos.y - 8}
	if item.in_range {
		rl.DrawTextEx(
			g.font,
			strings.clone_to_cstring(item.description, context.temp_allocator),
			debug_pos_offset,
			8,
			1,
			rl.WHITE,
		)
	}
}

draw_npc :: proc(npc: Npc) {
	if npc.texture_name != .None {
		texture := atlas_textures[npc.texture_name]
		rl.DrawTextureRec(g.atlas, texture.rect, npc.pos, rl.WHITE)
	}
	debug_pos_offset := Vec2{npc.pos.x, npc.pos.y - 8}
	if npc.in_range {
		rl.DrawTextEx(
			g.font,
			strings.clone_to_cstring("Talk", context.temp_allocator),
			debug_pos_offset,
			8,
			1,
			rl.WHITE,
		)
	}
}

draw_cutscene :: proc(cutscene_texture_name: Texture_Name) {
	cutscene_rect := atlas_textures[cutscene_texture_name].rect
	rl.DrawTextureRec(g.atlas, cutscene_rect, Vec2{0., 0.}, rl.WHITE)
}

draw_background :: proc() {
	background_rec := atlas_textures[Texture_Name.Tree_Background].rect
	rl.DrawTextureRec(g.atlas, background_rec, Vec2{-320., -192.}, rl.WHITE)
	rl.DrawTextureRec(g.atlas, background_rec, Vec2{0., 0.}, rl.WHITE)
	rl.DrawTextureRec(g.atlas, background_rec, Vec2{-320., 0.}, rl.WHITE)
	rl.DrawTextureRec(g.atlas, background_rec, Vec2{-320., 192.}, rl.WHITE)
	rl.DrawTextureRec(g.atlas, background_rec, Vec2{-320., 384.}, rl.WHITE)

	// Column 2
	rl.DrawTextureRec(g.atlas, background_rec, Vec2{0., -192.}, rl.WHITE)
	rl.DrawTextureRec(g.atlas, background_rec, Vec2{0., 0.}, rl.WHITE)
	rl.DrawTextureRec(g.atlas, background_rec, Vec2{0., 192.}, rl.WHITE)
	rl.DrawTextureRec(g.atlas, background_rec, Vec2{0., 384.}, rl.WHITE)
	// Column 3
	rl.DrawTextureRec(g.atlas, background_rec, Vec2{320., -192.}, rl.WHITE)
	rl.DrawTextureRec(g.atlas, background_rec, Vec2{320., 0.}, rl.WHITE)
	rl.DrawTextureRec(g.atlas, background_rec, Vec2{320., 192.}, rl.WHITE)
	rl.DrawTextureRec(g.atlas, background_rec, Vec2{320., 384.}, rl.WHITE)
	// Column 4
	rl.DrawTextureRec(g.atlas, background_rec, Vec2{640., -192.}, rl.WHITE)
	rl.DrawTextureRec(g.atlas, background_rec, Vec2{640., 0.}, rl.WHITE)
	rl.DrawTextureRec(g.atlas, background_rec, Vec2{640., 192.}, rl.WHITE)
	rl.DrawTextureRec(g.atlas, background_rec, Vec2{640., 384.}, rl.WHITE)
}

draw :: proc(dt: f32) {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	// test animation
	// anim_texture := animation_atlas_texture(g.test_anim)
	// test_anim_rect := anim_texture.rect
	// offset := rl.Vector2{anim_texture.offset_left, anim_texture.offset_top}
	// dest := Rect {
	// 	g.player_pos.x + offset.x,
	// 	g.player_pos.y + offset.y,
	// 	anim_texture.rect.width,
	// 	anim_texture.rect.height,
	// }
	// origin := rl.Vector2{anim_texture.document_size.x / 2, anim_texture.document_size.y / 2}

	// draw_debug_tiles()
	switch g.game_scene {
	case .SCENE_1:
		rl.BeginMode2D(game_camera(g.player_pos))
		draw_background()
		draw_tiles()
		draw_trees()
		draw_item(g.screwdriver)
		draw_item(g.hammer)
		draw_item(g.moved_brush)
		draw_item(g.keys)
		draw_item(g.car)
		draw_item(g.campfire)
		draw_item(g.climbing_gear)
		draw_npc(g.amanda)
		player_rect := atlas_textures[Texture_Name.Ranger_Base].rect
		rl.DrawTextureRec(g.atlas, player_rect, g.player_pos, rl.WHITE)
		rl.EndMode2D()
	case .SCENE_2:
		rl.BeginMode2D(game_camera(g.player_pos))
		background_rec := atlas_textures[Texture_Name.Tree_Background].rect
		rl.DrawTextureRec(g.atlas, background_rec, Vec2{0., 0.}, rl.WHITE)
		rl.DrawTextureRec(g.atlas, background_rec, Vec2{-320., -180.}, rl.WHITE)
		rl.DrawTextureRec(g.atlas, background_rec, Vec2{-320., 0.}, rl.WHITE)
		rl.DrawTextureRec(g.atlas, background_rec, Vec2{-320., 180.}, rl.WHITE)
		rl.DrawTextureRec(g.atlas, background_rec, Vec2{-320., 360.}, rl.WHITE)
		draw_tiles_two()
		draw_trees_two()
		draw_item(g.sturdy_splint)
		draw_item(g.medical_tape)
		draw_item(g.phone)
		draw_item(g.sturdy_tree_limbs)
		draw_item(g.rocks)
		draw_item(g.paracord)
		draw_item(g.blanket)
		draw_item(g.lean_two)
		draw_npc(g.steve)
		draw_npc(g.claire)
		player_rect := atlas_textures[Texture_Name.Ranger_Base].rect
		rl.DrawTextureRec(g.atlas, player_rect, g.player_pos, rl.WHITE)
		rl.EndMode2D()
	case .SCENE_3:
		rl.BeginMode2D(game_camera(g.player_pos))
		background_rec := atlas_textures[Texture_Name.Tree_Background].rect
		rl.DrawTextureRec(g.atlas, background_rec, Vec2{0., 0.}, rl.WHITE)
		rl.DrawTextureRec(g.atlas, background_rec, Vec2{-320., -180.}, rl.WHITE)
		rl.DrawTextureRec(g.atlas, background_rec, Vec2{-320., 0.}, rl.WHITE)
		rl.DrawTextureRec(g.atlas, background_rec, Vec2{-320., 180.}, rl.WHITE)
		rl.DrawTextureRec(g.atlas, background_rec, Vec2{-320., 360.}, rl.WHITE)
		draw_tiles()
		draw_trees()
		draw_item(g.scuffed_moss)
		draw_item(g.foot_prints_tracks)
		draw_item(g.bear_mace)
		draw_npc(g.amanda)
		draw_npc(g.george)
		draw_npc(g.brian)
		draw_npc(g.ida)
		player_rect := atlas_textures[Texture_Name.Ranger_Base].rect
		rl.DrawTextureRec(g.atlas, player_rect, g.player_pos, rl.WHITE)
		rl.EndMode2D()
	case .CUTSCENE:
		rl.BeginMode2D(cutscene_camera())
		draw_cutscene(g.cutscene_texture_name)
		rl.EndMode2D()
	case .ENDING:
		rl.BeginMode2D(cutscene_camera())
		txt := fmt.ctprintf("FIN")
		rl.DrawTextEx(
			g.font,
			txt,
			Vec2{PIXEL_WINDOW_HEIGHT / 2, PIXEL_WINDOW_HEIGHT / 2},
			8,
			1,
			rl.WHITE,
		)
		rl.EndMode2D()
	case .TITLE:
		rl.BeginMode2D(cutscene_camera())
		// Draw title cutscene
		draw_cutscene(g.cutscene_texture_name)
		txt := fmt.ctprintf("Press Enter to Start")
		rl.DrawTextEx(
			g.font,
			txt,
			Vec2{PIXEL_WINDOW_HEIGHT / 2, PIXEL_WINDOW_HEIGHT / 2},
			8,
			1,
			rl.WHITE,
		)
		rl.EndMode2D()
	// case .INTRO:
	// 	rl.BeginMode2D(cutscene_camera())
	// 	draw_cutscene(g.cutscene_texture_name)
	// 	rl.EndMode2D()
	}

	// rl.DrawTexturePro(g.atlas, test_anim_rect, dest, origin, 0, rl.WHITE)
	// rl.DrawTextureEx(g.player_texture, g.player_pos, 0, 1, rl.WHITE)

	// rl.DrawRectangleV(g.player_pos, Vec2{10., 10.}, rl.RAYWHITE)


	rl.BeginMode2D(ui_camera())

	// NOTE: `fmt.ctprintf` uses the temp allocator. The temp allocator is
	// cleared at the end of the frame by the main application, meaning inside
	// `main_hot_reload.odin`, `main_release.odin` or `main_web_entry.odin`.
	// rl.DrawText(
	// 	fmt.ctprintf(
	// 		"some_number: %v\nplayer_pos: %v\nscrewdriver collected: %v\nhammer collected: %v\nin dialogue%v\nobj complete:%v\n",
	// 		g.some_number,
	// 		g.player_pos,
	// 		g.screwdriver.collected,
	// 		g.hammer.collected,
	// 		g.game_state == .DIALOGUE,
	// 		g.current_objective.complete,
	// 	),
	// 	5,
	// 	5,
	// 	8,
	// 	rl.WHITE,
	// )

	if g.game_state == .DIALOGUE {
		draw_dialog(g.current_dialog, g.current_dialog_step, g.current_dialog_frame)
	}

	if g.game_state == .INVENTORY {
		draw_inventory()
	}

	rl.EndMode2D()

	rl.EndDrawing()
}

draw_dialog :: proc(current_dialog: Dialog, dialog_step: int, dialog_frame: int) {
	if len(current_dialog.dialog_text) < 1 {
		return
	}
	text := current_dialog.dialog_text[dialog_step]
	dialog_pos_y := PIXEL_WINDOW_HEIGHT - DIALOG_SIZE_HEIGHT - 2
	rl.DrawRectangle(5, i32(dialog_pos_y), DIALOG_SIZE_WIDTH, DIALOG_SIZE_HEIGHT, rl.BLACK)
	subtext := rl.TextSubtext(
		strings.clone_to_cstring(text, context.temp_allocator),
		0,
		i32(dialog_frame / 10),
	)
	texture := atlas_textures[current_dialog.npc_texture]
	rl.DrawTextureRec(g.atlas, texture.rect, Vec2{7., f32(dialog_pos_y + 2)}, rl.WHITE)
	text_pos_x := texture.rect.width + 15
	txt := fmt.ctprintf("%v: %v", current_dialog.npc_name, subtext)
	rl.DrawTextEx(g.font, txt, Vec2{text_pos_x, f32(dialog_pos_y + 2)}, 8, 1, rl.WHITE)
}

draw_inventory :: proc() {
	window_pos := [2]i32{5, 5}
	text_offset := window_pos + [2]i32{2, 2}
	pixel_window_w := i32(PIXEL_WINDOW_HEIGHT * 1.5)
	rl.DrawRectangle(
		window_pos.x,
		window_pos.y,
		pixel_window_w,
		PIXEL_WINDOW_HEIGHT - 25,
		rl.BLACK,
	)
	txt := fmt.ctprint("q - close\n")
	if g.screwdriver.collected {
		txt = fmt.ctprintf("%v%v", txt, item_description_for_inventory(g.screwdriver))
	}
	if g.hammer.collected {
		txt = fmt.ctprintf("%v%v", txt, item_description_for_inventory(g.hammer))
	}
	// txt = fmt.ctprintf("%v: %v\n%v: %v", "item", "does thing", "next item", "does another thing")
	rl.DrawTextEx(g.font, txt, Vec2{f32(text_offset.x), f32(text_offset.y)}, 6, 1, rl.WHITE)
}

item_description_for_inventory :: proc(item: Item) -> cstring {
	return fmt.ctprintf("%v: %v\n", item.description, item.note_book_description)
}

draw_tile :: proc(x: int, y: int, pos: Vec2, flip_x: bool) {
	rect := tileset_gameset[x][y]

	if flip_x {
		rect.width = -rect.width
	}

	rl.DrawTextureRec(g.atlas, rect, pos, rl.WHITE)
}

draw_tile_rect :: proc(rectangle: Rect, pos: Vec2, flip_x: bool) {
	rect := rectangle

	if flip_x {
		rect.width = -rect.width
	}

	rl.DrawTextureRec(g.atlas, rect, pos, rl.WHITE)
}

// Draw Helpers
draw_debug_tiles :: proc() {
	for i in 0 ..< GRID_SIZE {
		for j in 0 ..< GRID_SIZE {
			x := i32(i * CELL_SIZE)
			y := i32(j * CELL_SIZE)
			// Draw Debug
			if grid[i][j] == .WLN {
				// rl.DrawRectangle(x, y, CELL_SIZE, CELL_SIZE, rl.RED)
				draw_tile(6, 1, {f32(x), f32(y)}, false)
			} else if grid[i][j] == .GRS {
				// rl.DrawRectangle(x, y, CELL_SIZE, CELL_SIZE, rl.BROWN)
				draw_tile(5, 2, {f32(x), f32(y)}, false)
			}
			rl.DrawRectangleLines(x, y, CELL_SIZE, CELL_SIZE, rl.DARKGRAY)
		}
	}
}

draw_tiles :: proc() {
	for i in 0 ..< GRID_SIZE {
		for j in 0 ..< GRID_SIZE {
			x := i32(i * CELL_SIZE)
			y := i32(j * CELL_SIZE)
			tile := grid[j][i]
			tile_pos := get_tileset_pos(tile)
			draw_tile(tile_pos.x, tile_pos.y, {f32(x), f32(y)}, false)
			rl.DrawRectangleLines(x, y, CELL_SIZE, CELL_SIZE, rl.DARKGRAY)
		}
	}
}

draw_tiles_new :: proc() {
	for i in 0 ..< GRID_SIZE_NEW {
		for j in 0 ..< GRID_SIZE_NEW {
			x := i32(i * CELL_SIZE)
			y := i32(j * CELL_SIZE)
			tile := grid_copy_new[j][i]
			tile_pos := get_tileset_pos(tile)
			draw_tile(tile_pos.x, tile_pos.y, {f32(x), f32(y)}, false)
			rl.DrawRectangleLines(x, y, CELL_SIZE, CELL_SIZE, rl.DARKGRAY)
		}
	}
}
draw_trees_new :: proc() {
	for i in 0 ..< GRID_SIZE_NEW {
		for j in 0 ..< GRID_SIZE_NEW {
			x := i32(i * CELL_SIZE)
			y := i32(j * CELL_SIZE)
			tile := grid_copy_new[j][i]
			if tile == .TWL {
				tree := atlas_textures[.Tree_3]
				rl.DrawTextureRec(g.atlas, tree.rect, {f32(x), f32(y)}, rl.WHITE)
			}
		}
	}
}

draw_tiles_two :: proc() {
	for i in 0 ..< GRID_SIZE {
		for j in 0 ..< GRID_SIZE {
			x := i32(i * CELL_SIZE)
			y := i32(j * CELL_SIZE)
			tile := grid_two[j][i]
			tile_pos := get_tileset_pos(tile)
			draw_tile(tile_pos.x, tile_pos.y, {f32(x), f32(y)}, false)
			rl.DrawRectangleLines(x, y, CELL_SIZE, CELL_SIZE, rl.DARKGRAY)
		}
	}
}

draw_trees :: proc() {
	for i in 0 ..< GRID_SIZE {
		for j in 0 ..< GRID_SIZE {
			x := i32(i * CELL_SIZE)
			y := i32(j * CELL_SIZE)
			tile := grid[j][i]
			if tile == .TWL {
				tree := atlas_textures[.Tree_3]
				rl.DrawTextureRec(g.atlas, tree.rect, {f32(x), f32(y)}, rl.WHITE)
			}
		}
	}
}

draw_trees_two :: proc() {
	for i in 0 ..< GRID_SIZE {
		for j in 0 ..< GRID_SIZE {
			x := i32(i * CELL_SIZE)
			y := i32(j * CELL_SIZE)
			tile := grid_two[j][i]
			if tile == .TWL {
				tree := atlas_textures[.Tree_3]
				rl.DrawTextureRec(g.atlas, tree.rect, {f32(x), f32(y)}, rl.WHITE)
			}
		}
	}
}

place_items :: proc() {
	for i in 0 ..< GRID_SIZE {
		for j in 0 ..< GRID_SIZE {
			x := i32(i * CELL_SIZE)
			y := i32(j * CELL_SIZE)
			item_enum := item_grid[j][i]
			switch item_enum {
			case .SCR:
				move_item(&g.screwdriver, x, y)
			case .BRS:
				move_item(&g.moved_brush, x, y)
			case .HMR:
				move_item(&g.hammer, x, y)
			case .KEY:
				move_item(&g.keys, x, y)
			case .MOS:
				move_item(&g.scuffed_moss, x, y)
			case .FTP:
				move_item(&g.foot_prints_tracks, x, y)
			case .CAR:
				move_item(&g.car, x, y)
			case .FIR:
				move_item(&g.campfire, x, y)
			case .CLG:
				move_item(&g.climbing_gear, x, y)
			case .BRM:
				move_item(&g.bear_mace, x, y)
			case .MTP:
				move_item(&g.medical_tape, x, y)
			case .PHN:
				move_item(&g.phone, x, y)
			case .TRL:
				move_item(&g.sturdy_tree_limbs, x, y)
			case .ROK:
				move_item(&g.rocks, x, y)
			case .PRC:
				move_item(&g.paracord, x, y)
			case .BNK:
				move_item(&g.blanket, x, y)
			case .NON:
			}
		}
	}
}

move_item :: proc(item: ^Item, x, y: i32) {
	item.pos = Vec2{f32(x), f32(y)}
	item.rect.x = f32(x)
	item.rect.y = f32(y)
}

@(export)
game_update :: proc() {
	deltaTime := rl.GetFrameTime()
	update(deltaTime)
	draw(deltaTime)

	// Everything on tracking allocator is valid until end-of-frame.
	free_all(context.temp_allocator)
}

@(export)
game_init_window :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(1280, 720, "Odin + Raylib + Hot Reload template!")
	// rl.SetWindowPosition(200, 200)
	rl.SetTargetFPS(500)
	rl.SetExitKey(nil)
}

@(export)
game_init :: proc() {
	atlas_image := rl.LoadImageFromMemory(".png", raw_data(ATLAS_DATA), i32(len(ATLAS_DATA)))
	g = new(Game_Memory)

	g^ = Game_Memory {
		debug_mode                = true,
		game_state                = .MAIN,
		game_scene                = .TITLE,
		run                       = true,
		some_number               = 100,
		current_dialog_chain      = nil,
		cutscene_texture_name     = .Cutscene_1,
		player_pos                = rl.Vector2{100., 100.},

		// You can put textures, sounds and music in the `assets` folder. Those
		// files will be part any release or web build.
		atlas                     = rl.LoadTextureFromImage(atlas_image),
		test_anim                 = animation_create(.Test),
		current_dialog            = Dialog {
			1,
			.AMANDA,
			.Amanda,
			"amanda",
			load_dialog(.AMANDA_1),
			.AMANDA_1,
		},
		current_dialog_step       = 0,
		current_dialog_frame      = 0,
		current_objective         = Objective{false, .OBJECTIVE_1_COMPLETE},
		objective_necessary_items = load_task(.TASK_1),
		story_flag_1              = false,
		story_flag_2              = false,
		story_flag_3              = false,


		// World Items
		screwdriver               = Item {
			Vec2{10., 10.},
			Rect{10., 10., 16., 16.},
			"Screwdriver",
			.Test0,
			false,
			false,
			"screwdriver",
		},
		hammer                    = Item {
			Vec2{20., 30.},
			Rect{20., 30., 16., 16.},
			"hammer",
			.Test0,
			false,
			false,
			"hammer",
		},
		moved_brush               = Item {
			Vec2{30., 10.},
			Rect{30., 10., 16., 16.},
			"Disturbed Brush",
			.Test0,
			false,
			false,
			"Found Disturbed Brush",
		},
		keys                      = Item {
			Vec2{50., 10.},
			Rect{50., 10., 16., 16.},
			"Car Keys",
			.Key,
			false,
			false,
			"Found these keys",
		},
		scuffed_moss              = Item {
			Vec2{60., 10.},
			Rect{60., 10., 16., 16.},
			"Disturbed Moss",
			.Test0,
			false,
			false,
			"Log's moss been disturbed",
		},
		foot_prints_tracks        = Item {
			Vec2{70., 10.},
			Rect{70., 10., 16., 16.},
			"Footprints",
			.Test0,
			false,
			false,
			"Two sets of foot prints",
		},
		car                       = Item {
			Vec2{80., 10.},
			Rect{80., 10., 16., 16.},
			"Truck",
			.Test0,
			false,
			false,
			"The Truck has been here for days",
		},
		campfire                  = Item {
			Vec2{90., 10.},
			Rect{90., 10., 16., 16.},
			"Campfire",
			.Campfire,
			false,
			false,
			"A campfire has been out for days",
		},
		climbing_gear             = Item {
			Vec2{100., 10.},
			Rect{100., 10., 16., 16.},
			"Climbing Gear",
			.Backpack,
			false,
			false,
			"Climbing gear they were mountaineers",
		},
		bear_mace                 = Item {
			Vec2{10., 30.},
			Rect{10., 30., 16., 16.},
			"Bear Mace",
			.Bear_Mace,
			false,
			false,
			"Probably used to fend off an attacker",
		},
		sturdy_splint             = Item {
			Vec2{30., 30.},
			Rect{30., 30., 16., 16.},
			"Sturdy Splint",
			.Splint,
			false,
			false,
			"Can use to help dad",
		},
		medical_tape              = Item {
			Vec2{50., 30.},
			Rect{50., 30., 16., 16.},
			"Medical Tape",
			.Tape,
			false,
			false,
			"Can use to help dad",
		},
		phone                     = Item {
			Vec2{70., 30.},
			Rect{70., 30., 16., 16.},
			"Phone",
			.Phone,
			false,
			false,
			"It's dead",
		},
		sturdy_tree_limbs         = Item {
			Vec2{90., 30.},
			Rect{90., 30., 16., 16.},
			"Tree Limbs",
			.Test0,
			false,
			false,
			"Can use to make lean two",
		},
		rocks                     = Item {
			Vec2{100., 30.},
			Rect{100., 30., 16., 16.},
			"Rocks",
			.Rock,
			false,
			false,
			"Can use to make lean two",
		},
		paracord                  = Item {
			Vec2{120., 30.},
			Rect{120., 30., 16., 16.},
			"paracord",
			.Parachord,
			false,
			false,
			"Can use to make lean two",
		},
		blanket                   = Item {
			Vec2{140., 30.},
			Rect{140., 30., 16., 16.},
			"blanket",
			.Blanket,
			false,
			false,
			"Can use to make lean two",
		},
		lean_two                  = Item {
			Vec2{140., 30.},
			Rect{140., 30., 16., 16.},
			"Lean Two",
			.Test0,
			false,
			true,
			"",
		},


		// NPCs
		amanda                    = Npc {
			.AMANDA,
			Vec2{14., 100.},
			Rect{14., 100., 16., 16.},
			"amanda",
			.Amanda,
			.NONE,
			false,
			false,
		},
		steve                     = Npc {
			.STEVE,
			Vec2{34., 100.},
			Rect{34., 100., 16., 16.},
			"steve",
			.Steve,
			.NONE,
			false,
			false,
		},
		claire                    = Npc {
			.CLAIRE,
			Vec2{54., 100.},
			Rect{54., 100., 16., 16.},
			"claire",
			.Claire,
			.NONE,
			false,
			false,
		},
		george                    = Npc {
			.GEORGE,
			Vec2{74., 100.},
			Rect{74., 100., 16., 16.},
			"george",
			.Ranger_Sar,
			.NONE,
			false,
			false,
		},
		sarah                     = Npc {
			.SARAH,
			Vec2{94., 100.},
			Rect{94., 100., 16., 16.},
			"sarah",
			.Ranger_Sar_Fem,
			.NONE,
			false,
			false,
		},
		brian                     = Npc {
			.BRIAN,
			Vec2{114., 100.},
			Rect{114., 100., 16., 16.},
			"brian",
			.Ranger_Sar,
			.NONE,
			false,
			false,
		},
		ida                       = Npc {
			.IDA,
			Vec2{134., 100.},
			Rect{134., 100., 16., 16.},
			"ida",
			.Ranger_Sar_Fem,
			.NONE,
			false,
			false,
		},
	}
	place_items()
	rl.UnloadImage(atlas_image)

	game_hot_reloaded(g)
}

@(export)
game_should_run :: proc() -> bool {
	when ODIN_OS != .JS {
		// Never run this proc in browser. It contains a 16 ms sleep on web!
		if rl.WindowShouldClose() {
			return false
		}
	}

	return g.run
}

@(export)
game_shutdown :: proc() {
	rl.UnloadTexture(g.atlas)
	delete(g.current_dialog.dialog_text)
	delete(g.objective_necessary_items)
	free(g)
}

@(export)
game_shutdown_window :: proc() {
	rl.CloseWindow()
}

@(export)
game_memory :: proc() -> rawptr {
	return g
}

@(export)
game_memory_size :: proc() -> int {
	return size_of(Game_Memory)
}

@(export)
game_hot_reloaded :: proc(mem: rawptr) {
	g = (^Game_Memory)(mem)

	// Here you can also set your own global variables. A good idea is to make
	// your global variables into pointers that point to something inside `g`.
}

@(export)
game_force_reload :: proc() -> bool {
	return rl.IsKeyPressed(.F5)
}

@(export)
game_force_restart :: proc() -> bool {
	return rl.IsKeyPressed(.F6)
}

// In a web build, this is called when browser changes size. Remove the
// `rl.SetWindowSize` call if you don't want a resizable game.
game_parent_window_size_changed :: proc(w, h: int) {
	rl.SetWindowSize(i32(w), i32(h))
}
