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

ItemType :: enum {
	NONE,
	SCREWDRIVER,
	HAMMER,
}

NpcType :: enum {
	ITEM,
	AMANDA,
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

DIALOG_SIZE_HEIGHT :: 64
DIALOG_SIZE_WIDTH :: 720

Dialog :: struct {
	id:          int,
	npc:         NpcType,
	npc_texture: Texture_Name,
	npc_name:    string,
	dialog_text: [dynamic]string,
}

Objective :: struct {
	necessary_items: [dynamic]ItemType,
	complete:        bool,
}

DialogMapEnum :: enum {
	AMANDA_1,

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
}

Game_Memory :: struct {
	game_state:           Game_State,
	run:                  bool,
	player_pos:           rl.Vector2,
	player_texture:       Texture_Name,
	test_anim:            Animation,
	some_number:          int,
	atlas:                rl.Texture,
	font:                 rl.Font,
	current_dialog:       Dialog,
	current_dialog_step:  int,
	current_dialog_frame: int,
	current_objective:    Objective,

	// Refactor into array
	screwdriver:          Item,
	hammer:               Item,
	moved_brush:          Item,
	keys:                 Item,
	scuffed_moss:         Item,
	foot_prints_tracks:   Item,
	car:                  Item,
	campfire:             Item,
	climbing_gear:        Item,
	bear_mace:            Item,
	sturdy_splint:        Item,
	medical_tape:         Item,
	phone:                Item,
	sturdy_tree_limbs:    Item,
	rocks:                Item,
	paracord:             Item,
	blanket:              Item,

	// Refactor into array
	amanda:               Npc,
}

g: ^Game_Memory

all_dialog: [DialogMapEnum][]string = {
	.AMANDA_1              = []string {
		"Hey there my name is Amanda",
		"Are you ready to get started?",
		"Great job, you are doing great!",
	},

	// Items & Clues
	.SCREWDRIVER_ITEM      = []string{"This is a Screwdriver"},
	.MOVED_BRUSH_CLUE      = []string{"Looks like some broken brush."},
	.KEYS_CLUE             = []string{"A pair of car keys belonging to that truck"},
	.SCUFFED_MOSS_CLUE     = []string{"The moss on this log has been moved."},
	.FOOT_PRINTS_CLUE      = []string{"2 sets of foot prints."},
	.CAR_CLUE              = []string{"This truck matches the description Claire gave"},
	.CAMPFIRE_CLUE         = []string{"It's been out for days..."},
	.CLIMBING_GEAR_CLUE    = []string{"Looks like they were avid climbers"},
	.BEAR_MACE_CLUE        = []string{"An empty can of bear mace."},
	.STURDY_SPLINT_ITEM    = []string {
		"Sturdy piece of relatively wood.",
		"Could use it to help dad.",
	},
	.MEDICAL_TAPE_ITEM     = []string{"Medical tape. Can use it to help dad."},
	.PHONE_ITEM            = []string {
		"It's dead. Wouldn't do much good anyway without signal though.",
		"Hope someone is looking for us.",
		"Mom...",
	},
	.STURDY_TREE_LIMB_CLUE = []string{"Sturdy Tree Limb", "Could use these to build a lean two."},
	.ROCKS_CLUE            = []string {
		"Sturdy rocks.",
		"Could use these to weigh down the blanket for the lean two.",
	},
	.PARACORD_ITEM         = []string {
		"Nice strong paracord. Lucky this was in the bag",
		"Could use this cord to tie the blanket to the trees.",
	},
	.BLANKET_ITEM          = []string{"A good warm covering"},
}

game_camera :: proc(target_pos: Vec2) -> rl.Camera2D {
	w := f32(rl.GetScreenWidth())
	h := f32(rl.GetScreenHeight())

	return {zoom = h / PIXEL_WINDOW_HEIGHT, target = target_pos, offset = {w / 2, h / 2}}
}

ui_camera :: proc() -> rl.Camera2D {
	return {zoom = f32(rl.GetScreenHeight()) / PIXEL_WINDOW_HEIGHT}
}

load_dialog :: proc(npc_type: DialogMapEnum) -> [dynamic]string {
	dialog_text := make([dynamic]string, context.allocator)
	dialog_slices := all_dialog[npc_type]
	for dialog_slice in dialog_slices {
		append(&dialog_text, dialog_slice)
	}
	return dialog_text
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
		if pos_x != -1 &&
		   pos_y != -1 &&
		   pos_x < GRID_SIZE &&
		   pos_y < GRID_SIZE &&
		   (grid[pos_y][pos_x] == .TWL || grid[pos_y][pos_x] == .WLN) {
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
		&g.scuffed_moss,
		proc() {g.scuffed_moss.collected = true;handle_dialog(.ITEM, .SCUFFED_MOSS_CLUE)},
	)
	handle_item_interaction(
		&g.foot_prints_tracks,
		proc() {g.foot_prints_tracks.collected = true;handle_dialog(.ITEM, .FOOT_PRINTS_CLUE)},
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
	handle_item_interaction(
		&g.bear_mace,
		proc() {g.bear_mace.collected = true;handle_dialog(.ITEM, .BEAR_MACE_CLUE)},
	)
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
	handle_item_interaction(
		&g.sturdy_tree_limbs,
		proc() {g.sturdy_tree_limbs.collected = true;handle_dialog(.ITEM, .STURDY_TREE_LIMB_CLUE)},
	)
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
}

handle_dialog :: proc(npc_type: NpcType, dialog_enum: DialogMapEnum) {
	dialog: Dialog
	switch npc_type {
	case .AMANDA:
		dialog = Dialog{1, .AMANDA, .Amanda, "Amanda", load_dialog(dialog_enum)}
	case .ITEM:
		dialog = Dialog{2, .ITEM, .None, "Item", load_dialog(dialog_enum)}
	}
	delete(g.current_dialog.dialog_text)
	g.current_dialog = dialog
	g.current_dialog_step = 0
	g.game_state = .DIALOGUE
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
	g.amanda.in_range = collide_with_npc(g.amanda, g.player_pos)
	if g.amanda.in_range {
		if rl.IsKeyPressed(.E) {
			delete(g.current_dialog.dialog_text)
			g.current_dialog = Dialog{1, .AMANDA, .Amanda, "amanda", load_dialog(.AMANDA_1)}
			g.current_dialog_step = 0
			g.game_state = .DIALOGUE
		}
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
		if rl.IsKeyPressed(.Q) {
			// quit dialogue early
			g.game_state = .MAIN
		}
		if rl.IsKeyPressed(.E) {
			// continue dialogue
			g.current_dialog_frame = 0
			if g.current_dialog_step >= (size - 1) {
				g.game_state = .MAIN
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

		if rl.IsKeyPressed(.T) {
			check_complete := true
			for i in 0 ..< len(g.current_objective.necessary_items) {
				item := g.current_objective.necessary_items[i]
				if item == ItemType.HAMMER {
					if !g.hammer.collected {
						check_complete = false
						break
					}
				}
			}
			g.current_objective.complete = check_complete
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

draw :: proc(dt: f32) {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLUE)

	rl.BeginMode2D(game_camera(g.player_pos))
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
	draw_tiles()
	draw_trees()

	// rl.DrawTexturePro(g.atlas, test_anim_rect, dest, origin, 0, rl.WHITE)
	player_rect := atlas_textures[Texture_Name.Ranger_Base].rect
	rl.DrawTextureRec(g.atlas, player_rect, g.player_pos, rl.WHITE)
	// rl.DrawTextureEx(g.player_texture, g.player_pos, 0, 1, rl.WHITE)

	// rl.DrawRectangleV(g.player_pos, Vec2{10., 10.}, rl.RAYWHITE)
	draw_item(g.screwdriver)
	draw_item(g.hammer)
	draw_item(g.moved_brush)
	draw_item(g.keys)
	draw_item(g.scuffed_moss)
	draw_item(g.foot_prints_tracks)
	draw_item(g.car)
	draw_item(g.campfire)
	draw_item(g.climbing_gear)
	draw_item(g.bear_mace)
	draw_item(g.sturdy_splint)
	draw_item(g.medical_tape)
	draw_item(g.phone)
	draw_item(g.sturdy_tree_limbs)
	draw_item(g.rocks)
	draw_item(g.paracord)
	draw_item(g.blanket)

	draw_npc(g.amanda)
	rl.EndMode2D()

	rl.BeginMode2D(ui_camera())

	// NOTE: `fmt.ctprintf` uses the temp allocator. The temp allocator is
	// cleared at the end of the frame by the main application, meaning inside
	// `main_hot_reload.odin`, `main_release.odin` or `main_web_entry.odin`.
	rl.DrawText(
		fmt.ctprintf(
			"some_number: %v\nplayer_pos: %v\nscrewdriver collected: %v\nhammer collected: %v\nin dialogue%v\nobj complete:%v\n",
			g.some_number,
			g.player_pos,
			g.screwdriver.collected,
			g.hammer.collected,
			g.game_state == .DIALOGUE,
			g.current_objective.complete,
		),
		5,
		5,
		8,
		rl.WHITE,
	)

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

draw_trees :: proc() {
	for i in 0 ..< GRID_SIZE {
		for j in 0 ..< GRID_SIZE {
			x := i32(i * CELL_SIZE)
			y := i32(j * CELL_SIZE)
			tile := grid[j][i]
			if tile == .TWL {
				tree := atlas_textures[.Tree_1]
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
	rl.SetWindowPosition(200, 200)
	rl.SetTargetFPS(500)
	rl.SetExitKey(nil)
}

@(export)
game_init :: proc() {
	atlas_image := rl.LoadImageFromMemory(".png", raw_data(ATLAS_DATA), i32(len(ATLAS_DATA)))
	g = new(Game_Memory)

	listOfItems := make([dynamic]ItemType, context.allocator)
	append(&listOfItems, ItemType.HAMMER)
	g^ = Game_Memory {
		game_state           = .MAIN,
		run                  = true,
		some_number          = 100,

		// You can put textures, sounds and music in the `assets` folder. Those
		// files will be part any release or web build.
		atlas                = rl.LoadTextureFromImage(atlas_image),
		test_anim            = animation_create(.Test),
		current_dialog       = Dialog{1, .AMANDA, .Amanda, "amanda", load_dialog(.AMANDA_1)},
		current_dialog_step  = 0,
		current_dialog_frame = 0,
		current_objective    = Objective{listOfItems, false},

		// World Items
		screwdriver          = Item {
			Vec2{10., 10.},
			Rect{10., 10., 16., 16.},
			"Screwdriver",
			.Test0,
			false,
			false,
			"screwdriver",
		},
		hammer               = Item {
			Vec2{20., 30.},
			Rect{20., 30., 16., 16.},
			"hammer",
			.Test0,
			false,
			false,
			"hammer",
		},
		moved_brush          = Item {
			Vec2{30., 10.},
			Rect{30., 10., 16., 16.},
			"Disturbed Brush",
			.Test0,
			false,
			false,
			"Found Disturbed Brush",
		},
		keys                 = Item {
			Vec2{50., 10.},
			Rect{50., 10., 16., 16.},
			"Car Keys",
			.Key,
			false,
			false,
			"Found these keys",
		},
		scuffed_moss         = Item {
			Vec2{60., 10.},
			Rect{60., 10., 16., 16.},
			"Disturbed Moss",
			.Test0,
			false,
			false,
			"Log's moss been disturbed",
		},
		foot_prints_tracks   = Item {
			Vec2{70., 10.},
			Rect{70., 10., 16., 16.},
			"Footprints",
			.Test0,
			false,
			false,
			"Two sets of foot prints",
		},
		car                  = Item {
			Vec2{80., 10.},
			Rect{80., 10., 16., 16.},
			"Truck",
			.Test0,
			false,
			false,
			"The Truck has been here for days",
		},
		campfire             = Item {
			Vec2{90., 10.},
			Rect{90., 10., 16., 16.},
			"Campfire",
			.Campfire,
			false,
			false,
			"A campfire has been out for days",
		},
		climbing_gear        = Item {
			Vec2{100., 10.},
			Rect{100., 10., 16., 16.},
			"Climbing Gear",
			.Backpack,
			false,
			false,
			"Climbing gear they were mountaineers",
		},
		bear_mace            = Item {
			Vec2{10., 30.},
			Rect{10., 30., 16., 16.},
			"Bear Mace",
			.Bear_Mace,
			false,
			false,
			"Probably used to fend off an attacker",
		},
		sturdy_splint        = Item {
			Vec2{30., 30.},
			Rect{30., 30., 16., 16.},
			"Sturdy Splint",
			.Splint,
			false,
			false,
			"Can use to help dad",
		},
		medical_tape         = Item {
			Vec2{50., 30.},
			Rect{50., 30., 16., 16.},
			"Medical Tape",
			.Tape,
			false,
			false,
			"Can use to help dad",
		},
		phone                = Item {
			Vec2{70., 30.},
			Rect{70., 30., 16., 16.},
			"Phone",
			.Phone,
			false,
			false,
			"It's dead",
		},
		sturdy_tree_limbs    = Item {
			Vec2{90., 30.},
			Rect{90., 30., 16., 16.},
			"Tree Limbs",
			.Test0,
			false,
			false,
			"Can use to make lean two",
		},
		rocks                = Item {
			Vec2{100., 30.},
			Rect{100., 30., 16., 16.},
			"Rocks",
			.Rock,
			false,
			false,
			"Can use to make lean two",
		},
		paracord             = Item {
			Vec2{120., 30.},
			Rect{120., 30., 16., 16.},
			"paracord",
			.Parachord,
			false,
			false,
			"Can use to make lean two",
		},
		blanket              = Item {
			Vec2{140., 30.},
			Rect{140., 30., 16., 16.},
			"blanket",
			.Blanket,
			false,
			false,
			"Can use to make lean two",
		},


		// NPCs
		amanda               = Npc {
			.AMANDA,
			Vec2{14., 100.},
			Rect{14., 100., 16., 16.},
			"amanda",
			.Amanda,
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
	delete(g.current_objective.necessary_items)
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
