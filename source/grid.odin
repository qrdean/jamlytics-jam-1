package game

TILE_ENUM :: enum {
	Floor,
	Wall,
}

grid := [GRID_SIZE][GRID_SIZE]TILE_ENUM {
	{ .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor },
	{ .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor },
	{ .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor },
	{ .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor },
	{ .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor },
	{ .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor },
	{ .Floor, .Floor, .Floor, .Wall, .Wall, .Wall, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor },
	{ .Floor, .Floor, .Floor, .Wall, .Wall, .Wall, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor },
	{ .Floor, .Floor, .Floor, .Wall, .Wall, .Wall, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor },
	{ .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor },
	{ .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor },
	{ .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor },
	{ .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor },
	{ .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor },
	{ .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor },
	{ .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor },
	{ .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor },
	{ .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor },
	{ .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor },
	{ .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor },
}

TILE_ENUM_2 :: enum {
  Grass,
	Wall,
	TreeWall,
	DirtPath,
	DirtPathTop,
	DirtPathTopLeft,
	DirtPathTopRight,
	DirtPathBottom,
	DirtPathBottomLeft,
	DirtPathLeft,
	DirtPathRight,
}
