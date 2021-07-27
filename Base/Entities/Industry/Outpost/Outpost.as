// Vehicle Workshop

#include "GenericButtonCommon.as"
#include "StandardRespawnCommand.as"
#include "StandardControlsCommon.as"

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background

	this.CreateRespawnPoint("outpost", Vec2f(0.0f, -4.0f));
	this.Tag("respawn");
	this.Tag("change class drop inventory");
	this.Tag("travel tunnel");
	this.set_Vec2f("travel button pos", Vec2f(-6, 6));
	InitClasses(this);

	this.inventoryButtonPos = Vec2f(12, -12);

	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ flag = sprite.addSpriteLayer("flag layer", "Outpost.png", 32, 32);
	if (flag !is null)
	{
		flag.addAnimation("default", 5, true);
		int[] frames = { 9, 10, 11 };
		flag.animation.AddFrames(frames);
		flag.SetRelativeZ(0.8f);
		flag.SetOffset(Vec2f(10.5f, -12.0f));
	}
	//this.getShape().SetRotationsAllowed( false );
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	if (canChangeClass(this, caller) && caller.getTeamNum() == this.getTeamNum())
	{
		caller.CreateGenericButton("$change_class$", Vec2f(6, 6), this, buildSpawnMenu, getTranslatedString("Swap Class"));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	onRespawnCommand(this, cmd, params);
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this) && canSeeButtons(this, forBlob));
}
