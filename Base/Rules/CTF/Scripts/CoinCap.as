// hacky
#define SERVER_ONLY

const int coin_cap = 600;

void onTick(CRules@ this)
{
	if(this.hasTag("remove coincap")) return;

    for(int a = 0; a < getPlayerCount(); a++)
    {
        CPlayer@ p = getPlayer(a);
        if(p is null) continue;
        if(p.getCoins() > coin_cap) p.server_setCoins(coin_cap);
    }
}  

void onInit(CRules@ this)
{
	onRestart(this);
}

// remove coin cap for end and start of year
void onRestart(CRules@ this)
{
	u16 server_year = Time_Year();
	s16 server_date = Time_YearDate();
	u8 server_leap = ((server_year % 4 == 0 && server_year % 100 != 0) || server_year % 400 == 0)? 1 : 0;

	s16 temporary_coincap_removal_date = 364 + server_leap; // 30 december: remove coin cap
	s16 add_back_coincap_date = 2; // add back on 2nd january

	if(server_date >= temporary_coincap_removal_date || server_date < add_back_coincap_date)
	{
		this.Tag("remove coincap");
	}
	else
	{
		if(this.hasTag("remove coincap"))
		this.Untag("remove coincap");
	}
}