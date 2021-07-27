#define SERVER_ONLY

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player is null) return;

	if (!player.hasTag("respawn with mats")) return;
	else
	{
		u16 woodcount = player.get_u16("respawn_woodcount");
		u16 stonecount = player.get_u16("respawn_stonecount");

		CBlob@ wood = server_CreateBlobNoInit("mat_wood");
		CBlob@ stone = server_CreateBlobNoInit("mat_stone");

		if (wood !is null)
		{
			wood.Tag('custom quantity');
			wood.Init();

			wood.server_SetQuantity(woodcount);

			if (not this.server_PutInInventory(wood))
			{
				wood.setPosition(this.getPosition());
			}
		}

		if (stone !is null)
		{
			stone.Tag('custom quantity');
			stone.Init();

			stone.server_SetQuantity(stonecount);

			if (not this.server_PutInInventory(stone))
			{
				stone.setPosition(this.getPosition());
			}
		}

		player.set_u16("respawn_woodcount", 0);
		player.set_u16("respawn_stonecount", 0);
		player.Untag("respawn with mats");
	}
}