#define SERVER_ONLY

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
    if (victim is null || victim.getBlob() is null || this.getCurrentState() != GAME) return;

    CInventory@ inv = victim.getBlob().getInventory();
    
    if(inv is null || victim.lastBlobConfig != "builder") return;

    u16 woodcount = inv.getCount("mat_wood");
    u16 stonecount = inv.getCount("mat_stone");

    woodcount = Maths::Floor(woodcount * (1.0f / 3.0f));
    stonecount = Maths::Floor(stonecount * (1.0f / 3.0f));

    inv.server_RemoveItems("mat_wood", woodcount);
    inv.server_RemoveItems("mat_stone", stonecount);

    victim.set_u16("respawn_woodcount", woodcount);
    victim.set_u16("respawn_stonecount", stonecount);

    victim.Tag("respawn with mats");
}