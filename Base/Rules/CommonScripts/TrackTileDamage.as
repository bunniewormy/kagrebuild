const int repair_cd = 45;

shared class RepairTileInfo
{
	u32 index;
	u32 repair_time;
}

RepairTileInfo[] recentlyDamagedTiles;
RepairTileInfo[] recentlyDamagedTilesClient;

void onInit(CRules@ this)
{
	this.addCommandID("sync repairtile array");
	this.addCommandID("send repairtiles to client");
	this.addCommandID("clear client repairtiles");

	CMap@ map = getMap();
	if (!map.hasScript("TrackTileDamage.as")) map.AddScript("TrackTileDamage.as"); // adding map scripts from CRules is much more convenient than adding it to every map in mapcycle.cfg
}

void onRestart(CRules@ this)
{
	CMap@ map = getMap();
	if (!map.hasScript("TrackTileDamage.as")) map.AddScript("TrackTileDamage.as");
}

// onSetTile runs when a tile is damaged
void onSetTile(CMap@ this, u32 index, TileType newtile, TileType oldtile)
{
	if (getGameTime() < 30) return; // so that we don't run on map load

	bool set_repair_time = true;

	if (!(this.isTileWood(newtile) || // wood tile
	this.isTileCastle(newtile))) // castle block
	{
		set_repair_time = false;
	}

	bool found_tile = false;

	if (isServer())
	{
		CRules@ rules = getRules();
		CBitStream params;

		for (int i = 0; i < recentlyDamagedTiles.size(); ++i)
		{
			RepairTileInfo@ current_repairtileinfo = recentlyDamagedTiles[i];

			if (current_repairtileinfo.index == index)
			{
				//printf("hi");
				if(set_repair_time && current_repairtileinfo.repair_time < getGameTime())
				{
					current_repairtileinfo.repair_time = (getGameTime() + repair_cd);
					found_tile = true;
				}
				else
				{
					recentlyDamagedTiles.removeAt(i);
				}
			}
		}

		if(!found_tile)
		{
			RepairTileInfo newInfo;
			if(set_repair_time)
			{
				newInfo.index = index;
				newInfo.repair_time = (getGameTime() + repair_cd);
				recentlyDamagedTiles.push_back(newInfo);
			}
		}

		rules.SendCommand(rules.getCommandID("sync repairtile array"), params);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("sync repairtile array") && isServer())
	{
		this.SendCommand(this.getCommandID("clear client repairtiles"), params);

		// remove blocks from array that werent damaged recently
		for (int i = 0; i < recentlyDamagedTiles.size(); ++i)
		{
			if (getGameTime() > recentlyDamagedTiles[i].repair_time)
			{
				recentlyDamagedTiles.removeAt(i);
			}
		}

		// syncing because you cant sync arrays
		for (int i = 0; i < recentlyDamagedTiles.size(); ++i)
		{
			CBitStream bparams;

			bparams.write_u32(recentlyDamagedTiles[i].index);
			bparams.write_u32(recentlyDamagedTiles[i].repair_time);

			this.SendCommand(this.getCommandID("send repairtiles to client"), bparams);
		}
	}

	if (cmd == this.getCommandID("send repairtiles to client") && isClient())
	{
		u32 index;
		if (!params.saferead_u32(index)) return;
		u32 repair_time;
		if (!params.saferead_u32(repair_time)) return;

		RepairTileInfo newInfo;
		newInfo.index = index;
		newInfo.repair_time = repair_time;

		recentlyDamagedTilesClient.push_back(newInfo);

		this.set("RecentlyDamagedTiles", recentlyDamagedTilesClient);
	}

	if (cmd == this.getCommandID("clear client repairtiles") && isClient())
	{
		recentlyDamagedTilesClient.clear();

		this.set("RecentlyDamagedTiles", recentlyDamagedTilesClient);
	}
}
