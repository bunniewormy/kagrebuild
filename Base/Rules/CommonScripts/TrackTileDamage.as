const int repairCooldown = 30;

class RepairTileInfo
{
	u32 index;
	u32 repair_time;
}

RepairTileInfo[] repairTileInfoArray;

void onInit(CRules@ this)
{
	this.addCommandID("sync repairtile array");
}

// onSetTile runs when a tile is damaged
void onSetTile(CMap@ this, u32 index, TileType newtile, TileType oldtile)
{
	if (getGameTime() < 30) return; // so that we don't run on map load

	printf("sus");
	
	if (!(this.isTileWood(newtile) || // wood tile
	newtile == CMap::tile_wood_back || // wood backwall
	newtile == 207 || // wood backwall damaged
	this.isTileCastle(newtile) || // castle block
	newtile == CMap::tile_castle_back || // castle backwall
	newtile == 76 || // castle backwall damaged
	newtile == 77 || // castle backwall damaged
	newtile == 78 || // castle backwall damaged
	newtile == 79 || // castle backwall damaged
	newtile == CMap::tile_castle_back_moss)) // castle mossbackwall
	{
		return;
	}

	if (isServer())
	{
		printf("mogus");
		CRules@ rules = getRules();
		CBitStream params;
		rules.SendCommand(rules.getCommandID("sync repairtile array"), params);

		for (int i = 0; i < repairTileInfoArray.size(); ++i)
		{
			RepairTileInfo current_repairtileinfo = repairTileInfoArray[i];

			if (current_repairtileinfo.index == index)
			{
				current_repairtileinfo.repair_time = getGameTime();
				return;
			}
		}

		RepairTileInfo newInfo;
		newInfo.index = index;
		newInfo.repair_time = getGameTime();

		repairTileInfoArray.push_back(newInfo);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("sync repairtile array"))
	{
		printf("d");
		// remove 
		for (int i = 0; i < repairTileInfoArray.size(); ++i)
		{
			if (getGameTime() - repairCooldown < repairTileInfoArray[i].repair_time)
			{
				repairTileInfoArray.removeAt(i);
			}
		}

		this.set("RepairTileArray", repairTileInfoArray);
	}
}
