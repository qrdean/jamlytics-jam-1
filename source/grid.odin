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

grid_copy := [GRID_SIZE][GRID_SIZE]TILE_ENUM {
	{ .TWL, .GRS, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .DPL, .DPN, .DPR, .TWL },
	{ .GRS, .TWL, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .DPL, .DPN, .DPR, .TWL },
	{ .TWL, .WLN, .WLN, .GRS, .GRS, .GRS, .GRS, .DTL, .DPT, .DPT, .DPT, .DPT, .DPT, .DPT, .DPT, .DPT, .GRS, .DPN, .DPR, .TWL },
	{ .GRS, .TWL, .WLN, .GRS, .GRS, .GRS, .GRS, .DTL, .DPT, .DPT, .DPT, .DPT, .DPT, .DPT, .DPT, .DPT, .GBR, .DPN, .DPR, .TWL },
	{ .TWL, .GRS, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .GTL, .DPB, .DPB, .DPB, .DPB, .DPB, .DPB, .DPB, .DPB, .DBR, .TWL },
	{ .GRS, .TWL, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .TWL, .GRS, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .TWL, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .TWL, .GRS, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .TWL, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .TWL, .GRS, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .TWL, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .TWL, .GRS, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .TWL, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .TWL, .GRS, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .TWL, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .TWL, .GRS, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .TWL, .TWL, .TWL, .TWL, .TWL, .GRS, .DPL, .DPN, .DPR, .GRS, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL },
	{ .TWL, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .DBL, .DPB, .DBR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .TWL, .TWL, .TWL, .TWL, .TWL, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL },
}

grid := [GRID_SIZE][GRID_SIZE]TILE_ENUM {
	{ .TWL, .GRS, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .WLN, .WLN, .WLN, .TWL },
	{ .GRS, .TWL, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .TWL },
	{ .TWL, .WLN, .WLN, .GRS, .GRS, .GRS, .GRS, .DTL, .DPT, .DPT, .DPT, .DPT, .DPT, .DPT, .DPT, .DPT, .GRS, .DPL, .DPR, .TWL },
	{ .GRS, .TWL, .WLN, .GRS, .GRS, .GRS, .GRS, .DTL, .DPT, .DPT, .DPT, .DPT, .DPT, .DPT, .DPT, .GRS, .GRS, .DPL, .DPR, .TWL },
	{ .GRS, .TWL, .WLN, .GRS, .GRS, .GRS, .GRS, .DTL, .DPT, .DPT, .DPT, .DPT, .DPT, .DPT, .DPT, .DPT, .DPT, .GBR, .DPR, .TWL },
	{ .TWL, .GRS, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .GTL, .DPB, .DPB, .DPB, .DPB, .DPB, .DPB, .DPB, .DPB, .DBR, .TWL },
	{ .GRS, .TWL, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .TWL, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .TWL, .GRS, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .TWL, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .TWL, .GRS, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .TWL, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .TWL, .GRS, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .TWL, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .TWL, .GRS, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .TWL, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .TWL, .GRS, .WLN, .GRS, .GRS, .GRS, .GRS, .DPL, .DPN, .DPR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .TWL, .TWL, .TWL, .TWL, .TWL, .GRS, .DPL, .DPN, .DPR, .GRS, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .DBL, .DPB, .DBR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .WLN, .WLN, .WLN, .WLN, .WLN, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
}

grid_two := [GRID_SIZE][GRID_SIZE]TILE_ENUM {
	{ .TWL, .GRS, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .WLN, .WLN, .WLN, .TWL },
	{ .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .TWL },
	{ .TWL, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GBR, .GRS, .GRS, .TWL },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .TWL, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .TWL, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .TWL, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .TWL, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .TWL, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .TWL, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .TWL },
	{ .GRS, .TWL, .TWL, .TWL, .TWL, .TWL, .GRS, .DPL, .DPN, .DPR, .GRS, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL, .TWL },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .WLN, .GRS, .GRS, .GRS, .GRS, .GRS, .WLN, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .WLN, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
}

GRID_SIZE_CUT :: 10

grid_cutscene := [GRID_SIZE_CUT][GRID_SIZE_CUT]TILE_ENUM {
	{ .GRS, .GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS, },
	{ .GRS, .GRS,.DTL,.DPT,.DPT,.DPT,.DPT,.DTR,.GRS,.GRS, },
	{ .GRS, .GRS,.DPL,.DPN,.DPN,.DPN,.DPN,.DPR,.GRS,.GRS, },
	{ .GRS, .GRS,.DBL,.DPB,.DPB,.DPB,.DPB,.DBR,.GRS,.GRS, },
	{ .GRS, .GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS, },
	{ .GRS, .GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS, },
	{ .GRS, .GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS, },
	{ .GRS, .GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS, },
	{ .GRS, .GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS, },
	{ .GRS, .GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS,.GRS, },
}

grid_place := [GRID_SIZE_CUT][GRID_SIZE_CUT]NpcType {
	{ .ITEM, .ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM, },
	{ .ITEM, .ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM, },
	{ .ITEM, .ITEM,.ITEM,.YOU,.ITEM,.ITEM,.AMANDA,.ITEM,.ITEM,.ITEM, },
	{ .ITEM, .ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM, },
	{ .ITEM, .ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM, },
	{ .ITEM, .ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM, },
	{ .ITEM, .ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM, },
	{ .ITEM, .ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM, },
	{ .ITEM, .ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM, },
	{ .ITEM, .ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM,.ITEM, },
}

grid_base := [GRID_SIZE][GRID_SIZE]TILE_ENUM {
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GBR, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .DBR, .GRS },
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
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
	{ .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .DBR, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS, .GRS },
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

GRID_ITEM_ENUM :: enum {
	NON,
	SCR,
	BRS,
	HMR,
	KEY,
	MOS,
	FTP,
	CAR,
	FIR,
	CLG,
	BRM,
	MTP,
	PHN,
	TRL,
	ROK,
	PRC,
	BNK,
	SPL,
	LTW,
}

item_grid := [GRID_SIZE][GRID_SIZE]GRID_ITEM_ENUM {
	{ .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON },
	{ .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON },
	{ .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON },
	{ .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON },
	{ .NON, .NON, .NON, .NON, .BNK, .PHN, .CLG, .MTP, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON },
	{ .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .ROK, .NON, .NON, .NON, .NON, .NON, .NON, .BRS, .NON, .NON },
	{ .NON, .NON, .NON, .NON, .NON, .NON, .TRL, .NON, .LTW, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON },
	{ .NON, .NON, .NON, .NON, .NON, .FIR, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .MOS, .FTP, .NON, .NON },
	{ .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON },
	{ .NON, .NON, .NON, .NON, .KEY, .NON, .NON, .NON, .NON, .NON, .SPL, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON },
	{ .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .BRM, .NON, .NON, .NON, .NON, .NON },
	{ .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON },
	{ .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .PRC, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON },
	{ .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON },
	{ .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON },
	{ .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .CAR, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON },
	{ .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON },
	{ .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON },
	{ .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON },
	{ .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON, .NON },
}

npc_grid := [GRID_SIZE][GRID_SIZE]NpcType{
	{ .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM },
	{ .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM },
	{ .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM },
	{ .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM },
	{ .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM },
	{ .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM },
	{ .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM },
	{ .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM },
	{ .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM },
	{ .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .STEVE, .MAGGIE, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM },
	{ .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM },
	{ .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM },
	{ .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM },
	{ .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM },
	{ .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM },
	{ .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM },
	{ .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM },
	{ .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM },
	{ .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .YOU, .AMANDA, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM },
	{ .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM, .ITEM },
}
