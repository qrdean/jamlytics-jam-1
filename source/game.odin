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
GRID_SIZE :: 10

Rect :: rl.Rectangle
Vec2 :: rl.Vector2

TILE_ENUM :: enum {
	Floor,
	Wall,
}

grid := [GRID_SIZE][GRID_SIZE]TILE_ENUM {
	{.Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor},
	{.Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor},
	{.Floor, .Floor, .Floor, .Wall, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor},
	{.Floor, .Floor, .Wall, .Wall, .Wall, .Floor, .Wall, .Floor, .Floor, .Floor},
	{.Floor, .Floor, .Wall, .Wall, .Wall, .Floor, .Wall, .Floor, .Floor, .Floor},
	{.Floor, .Floor, .Floor, .Wall, .Wall, .Floor, .Wall, .Floor, .Floor, .Floor},
	{.Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Wall, .Floor, .Floor, .Floor},
	{.Floor, .Floor, .Wall, .Wall, .Wall, .Wall, .Floor, .Floor, .Floor, .Floor},
	{.Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor},
	{.Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor},
}

Game_State :: enum {
	MAIN,
	DIALOGUE,
}

// EntityType :: enum {
// 	NONE,
// 	PLAYER,
// }
//
// Entity :: struct {
// 	pos:  rl.Vector2,
// 	type: EntityType,
// }

ItemType :: enum {
	NONE,
	SCREWDRIVER,
	HAMMER,
}

NpcType :: enum {
	AMANDA,
}

Item :: struct {
	pos:          Vec2,
	rect:         Rect,
	description:  string,
	texture_name: Texture_Name,
	in_range:     bool,
	collected:    bool,
	type:         ItemType,
}

NPC :: struct {
	id:           NpcType,
	pos:          Vec2,
	rect:         Rect,
	name:         string,
	texture_name: Texture_Name,
	item_needed:  ItemType,
	in_range:     bool,
	item_given:   bool,
}

Game_Memory :: struct {
	game_state:     Game_State,
	run:            bool,
	player_pos:     rl.Vector2,
	test_anim:      Animation,
	player_texture: rl.Texture,
	some_number:    int,
	atlas:          rl.Texture,
	font:           rl.Font,
	screwdriver:    Item,
	hammer:         Item,
	amanda:         NPC,
}

g: ^Game_Memory

game_camera :: proc() -> rl.Camera2D {
	w := f32(rl.GetScreenWidth())
	h := f32(rl.GetScreenHeight())

	return {zoom = h / PIXEL_WINDOW_HEIGHT, target = g.player_pos, offset = {w / 2, h / 2}}
}

ui_camera :: proc() -> rl.Camera2D {
	return {zoom = f32(rl.GetScreenHeight()) / PIXEL_WINDOW_HEIGHT}
}

// pulled from https://github.com/ChrisPHP/odin-tilemap-collision/blob/main/collision.odin
naive_collision :: proc(x, y: f32, moveDirection: [2]f32) -> bool {
	new_x := x
	new_y := y

	collision_rect := rl.Rectangle {
		x      = new_x,
		y      = new_y,
		width  = 10.,
		height = 10.,
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
		   grid[pos_x][pos_y] == .Wall {
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

// This is messy but it works. Could pass in a pointer or something, but it's already
// a pointer to g so wtf is the point
handle_item_interactions :: proc() {
	g.screwdriver.in_range =
		(collide_with_item(g.screwdriver, g.player_pos) && !g.screwdriver.collected)
	if g.screwdriver.in_range {
		if rl.IsKeyPressed(.E) {
			g.screwdriver.collected = true
		}
	}

	g.hammer.in_range = (collide_with_item(g.hammer, g.player_pos) && !g.hammer.collected)
	if g.hammer.in_range {
		if rl.IsKeyPressed(.E) {
			g.hammer.collected = true
		}
	}
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
			g.game_state = .DIALOGUE
			// trigger dialogue
		}
	}
}

collide_with_npc :: proc(npc: NPC, player_pos: Vec2) -> bool {
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
		if rl.IsKeyPressed(.Q) {
			// quit dialogue early
			g.game_state = .MAIN
		}
		if rl.IsKeyPressed(.E) {
			// continue dialogue
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

draw_npc :: proc(npc: NPC) {
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

	rl.BeginMode2D(game_camera())
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

	// Static Map
	// map_rect := atlas_textures[Texture_Name.Map].rect
	// rl.DrawTextureRec(g.atlas, map_rect, Vec2{0.,0.}, rl.WHITE)

	draw_debug_tiles()

	// rl.DrawTexturePro(g.atlas, test_anim_rect, dest, origin, 0, rl.WHITE)
	// rl.DrawTextureEx(g.player_texture, g.player_pos, 0, 1, rl.WHITE)
	rl.DrawRectangleV(g.player_pos, Vec2{10., 10.}, rl.RAYWHITE)
	draw_item(g.screwdriver)
	draw_item(g.hammer)
	draw_npc(g.amanda)
	rl.EndMode2D()

	rl.BeginMode2D(ui_camera())

	// NOTE: `fmt.ctprintf` uses the temp allocator. The temp allocator is
	// cleared at the end of the frame by the main application, meaning inside
	// `main_hot_reload.odin`, `main_release.odin` or `main_web_entry.odin`.
	rl.DrawText(
		fmt.ctprintf(
			"some_number: %v\nplayer_pos: %v\nscrewdriver collected: %v\nhammer collected: %v\nin dialogue",
			g.some_number,
			g.player_pos,
			g.screwdriver.collected,
			g.hammer.collected,
			g.game_state == .DIALOGUE,
		),
		5,
		5,
		8,
		rl.WHITE,
	)

	rl.EndMode2D()

	rl.EndDrawing()
}

// Draw Helpers
draw_debug_tiles :: proc() {
	for i in 0 ..< GRID_SIZE {
		for j in 0 ..< GRID_SIZE {
			x := i32(i * CELL_SIZE)
			y := i32(j * CELL_SIZE)

			// Draw Debug
			if grid[i][j] == .Wall {
				rl.DrawRectangle(x, y, 16, 16, rl.RED)
			} else if grid[i][j] == .Floor {
				rl.DrawRectangle(x, y, 16, 16, rl.BROWN)
			}
			rl.DrawRectangleLines(x, y, CELL_SIZE, CELL_SIZE, rl.DARKGRAY)
		}
	}
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

	g^ = Game_Memory {
		game_state     = .MAIN,
		run            = true,
		some_number    = 100,

		// You can put textures, sounds and music in the `assets` folder. Those
		// files will be part any release or web build.
		player_texture = rl.LoadTexture("assets/round_cat.png"),
		atlas          = rl.LoadTextureFromImage(atlas_image),
		test_anim      = animation_create(.Test),

		// World Items
		screwdriver    = Item {
			Vec2{10., 10.},
			Rect{10., 10., 16., 16.},
			"Screwdriver",
			.Test0,
			false,
			false,
			.SCREWDRIVER,
		},
		hammer         = Item {
			Vec2{20., 30.},
			Rect{20., 30., 16., 16.},
			"hammer",
			.Test0,
			false,
			false,
			.HAMMER,
		},
		amanda         = NPC {
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
