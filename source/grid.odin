package game

TILE_ENUM :: enum {
  GRS,
	WLN, // Grass
	TWL, // Grass
	DPN,
	DPT,
	DTL,
	DTR,
	DPB,
	DBL,
	DBR,
	DPL,
	DPR,
	GTL,
	GTR,
	GBL,
	GBR,
}

grid := [GRID_SIZE][GRID_SIZE]TILE_ENUM {
	{ .GRS, .DPT, .GRS, .DTL, .DTR, .GTL, .GTR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .DPL, .DPN, .DPR, .DBL, .DBR, .GBL, .GBR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .DPB, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .WLN, .WLN, .WLN, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .WLN, .WLN, .WLN, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .WLN, .WLN, .WLN, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
}

get_tileset_pos :: proc(tile_enum: TILE_ENUM) -> [2]int {
	switch tile_enum {
	case .GRS:
		return {4,0} // GRS
	case .WLN:
		return {4,0} // GRS
	case .TWL:
		return {4,0} // GRS
	case .DPN:
		return {5,1} // DPN
	case .DPT:
		return {5,0} // DPT
	case .DTL:
		return {0,0} // DTL
	case .DTR:
		return {1,0} // DTR
	case .DPB:
		return {5,2} // DPB
	case .DBL:
		return {0,1} // DBL
	case .DBR:
		return {1,1} // DBR
	case .DPL:
		return {4,1} // DPL
	case .DPR:
		return {6,1} // DPR
	case .GTL:
		return {2,0} // GTL
	case .GTR:
		return {3,0} // GTR
	case .GBL:
		return {2,1} // GBL
	case .GBR:
		return {3,1} // GBR
	}
	return {4,0} // GRS
}
