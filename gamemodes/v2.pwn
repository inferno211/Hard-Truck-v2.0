/*  projekt: HardTruck v2
	Autor: Inferno
	GG: 34773974
*/

#include <a_samp>
#include <zcmd>
#include <Double-o-Files>
#include <sscanf2>
#include <foreach>
#include <streamer>
#include <progress>
#include <colors>

#pragma unused ret_memcpy
#pragma unused strtok
#pragma tabsize 0
#define UpperToLower(%1) for ( new ToLowerChar; ToLowerChar < strlen( %1 ); ToLowerChar ++ ) if ( %1[ ToLowerChar ]> 64 && %1[ ToLowerChar ] < 91 ) %1[ ToLowerChar ] += 32

#define Sloty 34 //Iloœæ slotów na serwerze
#define WERSJA "xXx v2"//wersja mapy
#define MAPNAME "xXx v2"//nazwa w zak³adce 'map'
#define URL "xXx v2"//nazwa w zak³adce 'url'
#define POJAZDY 2000//Przybli¿ona loœæ pojazdów w mapie
#define KUPNE 300 //przybli¿ona iloœæ kupnych pojazdów frakcyjnych
#define MAX_PING 300 //maxymalny ping na serwerze
#define MAX_SPEED 400 //maxymalna prêdkoœæ na serwerze
#define LA 100 //iloœæ automatów w mapie
#define ROZMIAR_TEKSTU 256//d³ugoœæ tekstu... (kolorowanie)
#define SPAWN 200000//czas respawnu pojazdów
#define ZLA_KOMENDA "*** "C_BEZOWY"Komenda "C_ZIELONY"%s "C_BEZOWY"nie jest poprawna!. Spis komend pod "C_ZIELONY"/cmd"C_BEZOWY"." //informacja o zlej komendzie. u¿yj %s (tylko raz) by wyœwietliæ komendê jak¹ wpisa³ ;)
//Pliki
#define KONTA 			"Truck/Konta/%s.ini" 		//Lokalizacja kont u¿ytkowników
#define FRAKCJA 		"Truck/Frakcje/%d.ini" 		//Lokalizacja frakcji
#define FRAKCYJNE 		"Truck/Frakcje/Wozy/%d.ini" //Lokalizacja wozów frakcji
#define AUTOMATY_FILE 	"Truck/Automaty/%d.ini"		//Lokalizacja automatów
#define DOMY_FILE 		"Truck/Domy/%s.ini"			//Lokalizacja plików od Domów
#define VIP_FILE 		"Truck/VIP/%s.ini"			//Lokalizacja vip'ow

new dKasa[Sloty];

main()
{
	print("");
}

enum AutomatEnum
{
	aAktywny,
	Float: aX,
	Float: aY,
	Float: aZ,
	Float: aAng
}
new AutomatInfo[LA][AutomatEnum];
new Automat[LA];

enum PlayerInfoEnum
{
	pHaslo[64],
	pLider,
	pFrakcja,
	pAdmin,
	pKasa,
	pScore,
	pAresztowany,
	pMute,
	pTag[128],
	pWarn,
	pPunkty,
	pPierwszy,
	pPremium,
	pKredyt,
	pPrawko,
	pBlok,
	pDJ,
	//system wozów
	Float: pX,
	Float: pY,
	Float: pZ,
	Float: pAng,
	pModel,
	pColor,
	//Osi¹gniêcia Towary
	pDowiozl,
	pPotrzeba,
	pPoziom,
	//Osi¹gniêcia Mandaty
	pMandaty,
	pMandatyPotrzeba,
	pMandatyPoziom,
	//Osi¹gniêcia Aresztowania
	pAresztowan,
	pAresztowanPotrzeba,
	pAresztowanPoziom
}
new PlayerInfo[Sloty][PlayerInfoEnum];
new Zalogowany[Sloty];
new Float:CarHealth[Sloty];
new Laduje[Sloty];
new LadowaniePaseczka[Sloty];
new NazwaTowaru[16];
new NapisUzywany=0;
new Text:Napis;
new NapisTimer;
new Zaladowany[Sloty];
new Frakcja[Sloty];
new Znalazl[Sloty];
new zespawnowany;
new TimerSchowaj[Sloty];
new PrivateCar[Sloty];
new PrivateCarSpawned[Sloty];
new Text3D: PrivateCarText[Sloty];
new cd;
new makogut[POJAZDY];
new kogut[POJAZDY];
new an = 0;
new ogloszenietim;
new odliczanko = 1;
new ostatnia[Sloty];
new przelew[Sloty];
new kupuje[Sloty];
new forma[80];
/*new bramart;
new sbramart;
new bramapoli;
new sbramapoli;
new sbramapd;*/
new PrivNrg[Sloty];
new Text:Textdraw0[Sloty];
new Text:Textdraw1[Sloty];
new Text:Textdraw2[Sloty];
new Text:Textdraw3[Sloty];
new Text:Textdraw4[Sloty];
new Text:Textdraw5[Sloty];
new Text:Textdraw6[Sloty];
new Text:Textdraw7[Sloty];
new Text:Textdraw8[Sloty];
new Text:Textdraw9[Sloty];
new Text:Textdraw10[Sloty];
new engine,lights,alarm,doors,bonnet,boot,objective;
//
new dstring[256];

//GUI
#define GUI_BRAK 				0
#define GUI_LOGIN 				1
#define GUI_REGISTER 			2
#define GUI_ZALADUNEK 			3
#define GUI_POJAZD 				4
#define GUI_LIDER 				5
#define GUI_GPS 				6
#define LIDER_SKLEP 			7
#define LIDER_SKLEP_WOZY_POLI 	8
#define GUI_POJAZD_PRYWATNY 	9
#define GUI_POJAZD_COLOR 		10
#define TUT 					11
#define LIDER_SKLEP_WOZY_PD 	12
#define DIALOG_ODP 				13
#define GUI_STACJA 				14
#define GUI_SALON 				15
#define GUI_SALON2              16
#define LIDER_SKLEP_WOZY_FIRMA  17
#define PANEL_DJ                18
#define GUI_ZARZ¥DZANIE         19

//GUI wysokie
#define GUI_BANK 300
#define PREMIUM 200

forward ZapiszKonto(playerid);
forward GivePlayerScore(playerid, ilosc);

//text drawy / progressbary


new Bar: WagaTowaru[Sloty];
new Bar: LadowanieBar[Sloty];
new Bar: Czas[Sloty];

new Text: Pojazd[Sloty];
new Text: Tlo[Sloty];
new Text: PojazdNapisy[Sloty];
new Text: napisspeed[Sloty];
new Text: napispaliwo[Sloty];
new Text: napishp[Sloty];
new Text: nazwawozu[Sloty];
new Text: Wybierz;
new Text: Skala;
new Text: Info;
new Text: NapisPrzyLadowaniu[Sloty];
new Text: BarkPaliwa;
new Text: Naczepa;
new Text: NaczepaTlo;
new Text: NaczepaNazwa[Sloty];
new Text: TowarWagaCzas;
new Text: NazwaWaga[Sloty];
new Text: Osiagniecia1;
new Text: Osiagniecia2;
new Text: OsiagnieciaNapis;
new Text: OsiagnieciaTresc[Sloty];
new Text: AdminNews1;
new Text: AdminNews2;
new Text: AdminNews3;

//pojazdy
enum CarInfoEnum
{
	cNaczepa,
	cPaliwo,
	cZaladowany,
	cTowar[34],
	cWaga,
	cWyladuj
}
new CarInfo[POJAZDY][CarInfoEnum];

new nazwypojazdow[212][32]=
{
	"Landstalker","Bravura","Buffalo","Linerunner","Pereniel","Sentinel","Dumper","Firetruck","Trashmaster","Stretch","Manana",
	"Infernus","Voodoo","Pony","Mule","Cheetah","Ambulance","Leviathan","Moonbeam","Esperanto","Taxi","Washington","Bobcat",
	"Mr Whoopee","BF Injection","Hunter","Premier","Enforcer","Securicar","Banshee","Predator","Bus","Rhino","Barracks",
	"Hotknife","Trailer","Previon","Coach","Cabbie","Stallion","Rumpo","RC Bandit","Romero","Packer","Monster","Admiral",
	"Squalo","Seasparrow","Pizzaboy","Tram","Trailer","Turismo","Speeder","Reefer","Tropic","Flatbed","Yankee","Caddy",
	"Solair","Berkley's RC Van","Skimmer","PCJ-600","Faggio","Harley","RC Baron","RC Raider","Glendale","Oceanic",
	"Sanchez","Sparrow","Patriot","Quad","Coastguard","Dinghy","Hermes","Sabre","Rustler","ZR3 50","Walton","Regina",
	"Comet","BMX","Burrito","Camper","Marquis","Baggage","Dozer","Maverick","News Chopper","Rancher","FBI Rancher",
	"Virgo","Greenwood","Jetmax","Hotring","Sandking","Blista Compact","Police Maverick","Boxville","Benson","Mesa",
	"RC Goblin","Hotring Racer","Hotring Racer","Bloodring Banger","Rancher","Super GT","Elegant","Journey","Bike",
	"Mountain Bike","Beagle","Cropdust","Stunt","Tanker","RoadTrain","Nebula","Majestic","Buccaneer","Shamal","Hydra",
	"FCR-900","Yamaha R6","HPV1000","Cement Truck","Tow Truck","Fortune","Cadrona","FBI Truck","Willard","Forklift","Traktor",
	"Combine","Feltzer","Remington","Slamvan","Blade","Freight","Streak","Vortex","Vincent","Bullet","Clover","Sadler",
	"Firetruck","Hustler","Intruder","Primo","Cargobob","Tampa","Sunrise","Merit","Utility","Nevada","Yosemite","Windsor",
	"Monster","Monster","Uranus","Jester","Sultan","Stratum","Elegy","Raindance","RC Tiger","Flash","Tahoma","Savanna",
	"Bandito","Freight","Trailer","Kart","Mower","Duneride","Sweeper","Broadway","Tornado","AT-400","DFT-30","Huntley",
	"Stafford","Yamaha YZF-R6","Newsvan","Tug","Trailer","Emperor","Wayfarer","Euros","Hotdog","Club","Trailer","Trailer",
	"Andromeda","Dodo","RC Cam","Launch","LS Police-Car","SF Police-Car","LV Police-Car","Police Rancher","Picador","SWAT Van",
	"Alpha","Phoenix","Glendale","Sadler","Luggage Trailer","Luggage Trailer","Stair Trailer","Boxville","Farm Plow","Utility Trailer"
};

#define ILOSC_ZALADUNKOW 19
new Float:Zaladunki[ILOSC_ZALADUNKOW][4] =
{
	{-213.915954, -265.289215, 1.150952, 5.0000},// RedCountry
	{637.903503, 846.892761, -43.233852, 5.0000},// kopalnia
	{1642.9485,1537.9347,10.8813, 5.0000},// lvlot
	{1276.860717, -1259.400146, 13.522587, 5.0000},// BudowaLS
	{321.116333, -1809.005615, 4.212907, 5.0000},// molols
	{-21.193063, -2498.478027, 36.375522, 5.0000},// flintcountry
	{-2793.666748, -302.550659, 6.914572, 5.0000},// avispacountryclub
	{-2332.995849, -128.333862, 35.039566, 5.0000},// garcia
	{-2458.478271, 735.511657, 34.742717, 5.0000},// supermarketsf
	{-1037.070556, -1161.568603, 128.944335, 5.0000},// Firma RiCo
	{-2616.406982, 2263.172119, 7.922909, 5.0000},// bayside
	{-1209.348876, 1820.748046, 41.445835, 5.0000},// tierrarobada
	{-913.816650, 2011.614624, 60.641147, 5.0000},// tama
	{-334.393737, 1782.647949, 42.486537, 5.0000},// regular tom
	{-90.691802, 1215.514038, 19.469274, 5.0000},// fort carson
	{1474.012573, 2843.924316, 10.547344, 5.0000},// yoellow bell golf course
	{2312.4590,592.6227,12.1531, 5.0000},//  Xoomer
	{773.0019,565.3229,12.9944, 5.0000},//  Truck stop Papier koppalnia  T.I.R
	{852.2562,654.9159,12.8941, 5.0000}// Truck stop Papier koppalnia  DOSTAWCAK
	

};

#define ILOSC_STACJI 40
new Float:stacja[ILOSC_STACJI][6] =
{
	{-608.3016,585.5062,16.3699,  	 4.99}, /////truck stop jak sie jedyie na sf od lv
	{-603.4999,592.3832,16.3615,  	 4.99}, /////truck stop jak sie jedyie na sf od lv
	{-601.7045,600.6387,16.3726,  	 4.99}, /////truck stop jak sie jedyie na sf od lv
	{1609.9637,192.3468,34.3260,  	 4.99}, ////za rondem i granica na ls
	{1649.2439,166.4865,35.2056,  	 4.99}, /////za rondem i granica na ls
	{1568.3087,1626.9720,10.5651,  	 5.99}, /////lv lot
	{1558.2496,1626.9457,10.5633,  	 5.99}, /////lv lot
	{1008.4910,-939.2007,43.2439,  	 4.99}, /////LS niedfaleko vinewood_!_
	{2117.6216,918.1204,10.8203,  	 6.99}, /////Pryz bayie vipa
	{2117.5137,907.7133,10.5611,  	 6.99}, /////pryz bayie vipa
	{2188.3926,603.5776,10.6387,  	 3.99}, ////obok xoomer
	{2188.6011,595.2422,10.6371,  	 3.99}, /////obbok xoomer
	{2189.0198,585.0323,10.6406,  	 3.99}, /////obok xoomer
	{-91.0920,-1169.1783,3.4708,  	 3.99}, /////zadupie ls
	{1938.6899,-1769.9293,14.4395,   3.99}, ////ls niedaleko lotniska
	{-91.0920,-1169.1783,3.4708,  	 4.99}, /////zadupie ls
	{2193.7876,2473.9771,10.5655,  	 4.99}, ////poli lv
	{2202.1602,2475.5347,10.5688,  	 4.99}, /////poli lv
	{2211.3669,2473.5977,10.5657,    4.99}, ///polilv
	{1594.2289,2189.2664,10.6017,  	 3.99}, ////obok stadionu
	{1596.1151,2198.7861,10.5635,  	 3.99}, /////obok stadionu
	{1595.2377,2209.8835,10.5614,    3.99}, ///obok stadionu
	{-1609.7119,-2718.4131,49.5960,  	 4.99}, ////bagna
	{-1605.6085,-2714.3481,49.5970,    4.99}, ///bagna
	{-1602.8495,-2709.4214,49.5937,    4.99}, ///bagna
	{2146.5837,2756.5940,10.5617,  	 3.99}, ////gora prawo lv
	{2147.6868,2747.7307,10.5658,  	 3.99}, /////gora prawo lv
	{2146.6677,2738.8484,10.5644,    3.99}, ///gora prawo lv
	{626.2897,1675.6917,6.7331,  	 3.99}, ////area
	{623.0495,1680.6071,6.7328,    3.99}, ///area
	{619.6532,1685.0613,6.7389,  	 3.99}, ////area
	{615.3979,1689.7284,6.7308,    3.99}, ///area
	{612.2051,1695.2076,6.7333,    3.99}, ///bagna
	{608.6496,1699.8217,6.7365,  	 3.99}, ////area
	{605.6508,1705.1821,6.7372,  	 3.99}, /////area
	{602.2210,1710.1323,6.7360,    3.99}, ///area
	{2639.5566,1097.0853,10.3943,  	 4.00}, /////truck papier obok kopalni
	{605.6508,1705.1821,6.7372,  	 3.99}, /////gdzies obok budowy w lv
	{2638.9753,1105.1556,10.3992,    3.99}, ///gdzies obok budowy w lv
	{2638.6077,1115.4622,10.3928,  	 4.00} /////gdzies obok budowy w lv
};

#define ILOSC_KOLOROW 8
new ZmienKolor[ILOSC_KOLOROW][1] =
{
	{0},
	{1},
	{3},
	{125},
	{100},
	{174},
	{252},
	{126}
};

#define ILOSC_ODLICZEN 11
new odliczanie[ILOSC_ODLICZEN][256] =
{
	{"~r~RESPAWN"},
	{"~r~1"},
	{"~y~2"},
	{"~g~3"},
	{"~g~4"},
	{"~g~5"},
	{"~g~6"},
	{"~g~7"},
	{"~g~8"},
	{"~g~9"},
	{"~g~10"}
};

#define ILOSC_TOWAROW 23
new ListaTowarow1[ILOSC_TOWAROW][64] =
{
	{"Zboze\n"},
	{"Dokumenty\n"},
	{"Lampy\n"},
	{"Ubrania\n"},
	{"Zabawki\n"},
	{"Kabury\n"},
	{"Wojskowe mundury\n"},
	{"Amunicja\n"},
	{"Broniee\n"},
	{"Amfetamina\n"},
	{"Marihuana\n"},
	{"Porcelana\n"},
	{"Artyku³y spo¿ywcze\n"},
	{"Cukier\n"},
	{"Paliwo\n"},
	{"Komputery\n"},
	{"Piasek\n"},
	{"Kurtki\n"},
	{"Drukarki\n"},
	{"Odpady\n"},
	{"Kamery\n"},
	{"Papier\n"},
	{"Fura Gnoju"}
};
new ListaTowarow2[ILOSC_TOWAROW][64] =
{
	{"Zboze"},
	{"Dokumenty"},
	{"Lampy"},
	{"Ubrania"},
	{"Zabawki"},
	{"Kabury"},
	{"Wojskowe mundury"},
	{"Amunicja"},
	{"Broniee"},
	{"Amfetamina"},
	{"Marihuana"},
	{"Porcelana"},
	{"Artyku³y spo¿ywcze"},
	{"Cukier"},
	{"Paliwo"},
	{"Komputery"},
	{"Piasek"},
	{"Kurtki"},
	{"Drukarki"},
	{"Odpady"},
	{"Kamery"},
	{"Papier"},
	{"Fura Gnoju"}
};
//towary firma
#define ILOSC_TOWAROW_FIRMA 4
new ListaTowarowFirma1[ILOSC_TOWAROW_FIRMA][64] =
{
	{"Diesel\n"},
	{"Benzyna98xo\n"},
	{"Benzyna95\n"},
	{"LPG"}
};
new ListaTowarowFirma2[ILOSC_TOWAROW_FIRMA][64] =
{
	{"Diesel"},
	{"Benzyna98xo"},
	{"Benzyna95"},
	{"LPG"}
};
#define ILOSC_BANKOW 2
new Float: Banki[ILOSC_BANKOW][4] =
{
	{0.0000, 0.0000, 0.0000, 0.0000},
	{0.0000, 0.0000, 0.0000, 0.0000}
};

#define ILOSC_SALONOW 3
new Float: Salon[ILOSC_SALONOW][7] =
{
//   X /salon        Y /salon       Z /salon    X spawn         Y spawn         Z spawn
	{-1649.2557,	1208.9857,		7.2500,		-1634.4812,		1203.1306,		6.9068,		43.4787},
	{2131.7266,		-1150.7349,		24.1237,	2135.0430,		-1127.3119,		25.2800,	82.8443},
	{-1957.8857,	304.9976,		35.4688,	-1988.7461,		275.5777,		34.9027,	268.0300}
};

#define ILOSC_WOZOW 10
new WozyID[ILOSC_WOZOW][2] =
{
	{401, 3000000},
	{412, 3000000},
	{424, 2000000},
	{426, 3500000},
	{429, 4000000},
	{451, 4500000},
	{506, 4500000},
	{559, 4000000},
	{560, 4500000},
	{562, 4500000}
};

new WozyNazwa[ILOSC_WOZOW][128] =
{
	{"Bravura"},
	{"Voodoo"},
	{"BF Injection"},
	{"Premier"},
	{"Banshee"},
	{"Turismo"},
	{"Super GT"},
	{"Jester"},
	{"Sultan"},
	{"Elegy"}
};

new Glosy[ILOSC_ZALADUNKOW][256] =
{
	{"hhttp://hard-truck.pl/glosy/redcountry.mp3"},
	{"hhttp://hard-truck.pl/glosy/kopalnia.mp3"},
	{"hhttp://hard-truck.pl/glosy/lvlot.mp3"},
	{"hhttp://hard-truck.pl/glosy/budowals.mp3"},
	{"hhttp://hard-truck.pl/glosy/molols.mp3"},
	{"hhttp://hard-truck.pl/glosy/flintcountry.mp3"},
	{"hhttp://hard-truck.pl/glosy/avispacountryclub.mp3"},
	{"hhttp://hard-truck.pl/glosy/garcia.mp3"},
	{"hhttp://hard-truck.pl/glosy/supermarketsf.mp3"},
	{"hhttp://hard-truck.pl/glosy/firmarico.mp3"},
	{"hhttp://hard-truck.pl/glosy/bayside.mp3"},
	{"hhttp://hard-truck.pl/glosy/tierrarobada.mp3"},
	{"hhttp://hard-truck.pl/glosy/tama.mp3"},
	{"hhttp://hard-truck.pl/glosy/regulartom.mp3"},
	{"hhttp://hard-truck.pl/glosy/fortcarson.mp3"},
	{"hhttp://hard-truck.pl/glosy/yellowbellgolfcourse.mp3"},
	{"hhttp://hard-truck.pl/glosy/yellowbellgolfcourse.mp3"},
	{"hhttp://hard-truck.pl/glosy/yellowbellgolfcourse.mp3"},
	{"hhttp://hard-truck.pl/glosy/yellowbellgolfcourse.mp3"}
};

public OnGameModeInit()
{
	//podstawowe ustw.
    new str[30];
	format(str,sizeof(str),"%s",WERSJA);
    SetGameModeText(str);//zmienia nazwe gamemode
    format(str,sizeof(str),"mapname %s",MAPNAME);
    SendRconCommand(str);//zmienia nazwe mapname
	format(str,sizeof(str),"weburl %s",URL);
	SendRconCommand(str);//zmienia weburl

	//truckerzy ID: 0
    AddPlayerClass(0, 	-1379.386352, 1488.210449, 21.156248,87.8978, 0, 0, 0, 0, 0, 0);//0
    AddPlayerClass(1, 	-1379.386352, 1488.210449, 21.156248,87.8978, 0, 0, 0, 0, 0, 0);//1
    AddPlayerClass(2, 	-1379.386352, 1488.210449, 21.156248,87.8978, 0, 0, 0, 0, 0, 0);//2
    AddPlayerClass(6, 	-1379.386352, 1488.210449, 21.156248,87.8978, 0, 0, 0, 0, 0, 0);//3
    AddPlayerClass(7, 	-1379.386352, 1488.210449, 21.156248,87.8978, 0, 0, 0, 0, 0, 0);//4
    AddPlayerClass(14, 	-1379.386352, 1488.210449, 21.156248,87.8978, 0, 0, 0, 0, 0, 0);//5
    AddPlayerClass(15, 	-1379.386352, 1488.210449, 21.156248,87.8978, 0, 0, 0, 0, 0, 0);//6
    AddPlayerClass(23, 	-1379.386352, 1488.210449, 21.156248,87.8978, 0, 0, 0, 0, 0, 0);//7
    AddPlayerClass(28, 	-1379.386352, 1488.210449, 21.156248,87.8978, 0, 0, 0, 0, 0, 0);//8
    AddPlayerClass(30, 	-1379.386352, 1488.210449, 21.156248,87.8978, 0, 0, 0, 0, 0, 0);//9
    AddPlayerClass(233, -1379.386352, 1488.210449, 21.156248,87.8978, 0, 0, 0, 0, 0, 0);//10
    AddPlayerClass(93, 	-1379.386352, 1488.210449, 21.156248,87.8978, 0, 0, 0, 0, 0, 0);//11
	//policja ID: 1
	AddPlayerClass(280, -127.77,	1040.24,	19.52,	315.3905, 0, 0, 0, 0, 0, 0);//12
	AddPlayerClass(282, -127.77,	1040.24,	19.52,	315.3905, 0, 0, 0, 0, 0, 0);//13
	AddPlayerClass(283, -127.77,	1040.24,	19.52,	315.3905, 0, 0, 0, 0, 0, 0);//14
	AddPlayerClass(265, -127.77,	1040.24,	19.52,	315.3905, 0, 0, 0, 0, 0, 0);//15
	AddPlayerClass(266, -127.77,	1040.24,	19.52,	315.3905, 0, 0, 0, 0, 0, 0);//16
	AddPlayerClass(284, -127.77,	1040.24,	19.52,	315.3905, 0, 0, 0, 0, 0, 0);//17
	//pomoc drogowa ID: 2
	AddPlayerClass(27, 	1427.79,	672.37,		10.46,	315.3905, 0, 0, 0, 0, 0, 0);//18
	AddPlayerClass(16, 	1427.79,	672.37,		10.46,	315.3905, 0, 0, 0, 0, 0, 0);//19
	AddPlayerClass(8, 	1427.79,	672.37,		10.46,	315.3905, 0, 0, 0, 0, 0, 0);//20
	AddPlayerClass(56, 	1427.79,	672.37,		10.46,	315.3905, 0, 0, 0, 0, 0, 0);//21
	//Speed Trans ID: 10
	AddPlayerClass(126, 1427.79,	672.37,		10.46,	315.3905, 0, 0, 0, 0, 0, 0);//22
	AddPlayerClass(128, 1427.79,	672.37,		10.46,	315.3905, 0, 0, 0, 0, 0, 0);//23
	//Euro Trans ID: 11
	AddPlayerClass(3, 1427.79,	672.37,		10.46,	315.3905, 0, 0, 0, 0, 0, 0);//24
	AddPlayerClass(20, 1427.79,	672.37,		10.46,	315.3905, 0, 0, 0, 0, 0, 0);//25
	//Rico Trans ID: 12
	AddPlayerClass(121, 1427.79,	672.37,		10.46,	315.3905, 0, 0, 0, 0, 0, 0);//26
	AddPlayerClass(152, 1427.79,	672.37,		10.46,	315.3905, 0, 0, 0, 0, 0, 0);//27

    for(new n=0; n<Sloty; n++)
    {
		napisspeed[n] = TextDrawCreate(293.000000,382.000000,"100 km/h");
	    TextDrawAlignment(napisspeed[n],0);
        TextDrawFont(napisspeed[n],2);
        TextDrawLetterSize(napisspeed[n],0.299999,1.000000);
        TextDrawColor(napisspeed[n],0xffffffff);
        TextDrawSetOutline(napisspeed[n],1);
        TextDrawSetProportional(napisspeed[n],1);
        TextDrawSetShadow(napisspeed[n],1);

		napispaliwo[n] = TextDrawCreate(288.000000,410.000000,"100l");
		TextDrawAlignment(napispaliwo[n],0);
		TextDrawBackgroundColor(napispaliwo[n],0x000000ff);
		TextDrawFont(napispaliwo[n],2);
        TextDrawLetterSize(napispaliwo[n],0.299999,1.000000);
        TextDrawColor(napispaliwo[n],0xffffffff);
        TextDrawSetOutline(napispaliwo[n],1);
        TextDrawSetProportional(napispaliwo[n],1);
        TextDrawSetShadow(napispaliwo[n],1);
		
		nazwawozu[n] = TextDrawCreate(565.000000, 375.000000, "_");
		TextDrawAlignment(nazwawozu[n], 2);
		TextDrawBackgroundColor(nazwawozu[n], 255);
		TextDrawFont(nazwawozu[n], 1);
		TextDrawLetterSize(nazwawozu[n], 0.500000, 1.000000);
		TextDrawColor(nazwawozu[n], -1);
		TextDrawSetOutline(nazwawozu[n], 0);
		TextDrawSetProportional(nazwawozu[n], 1);
		TextDrawSetShadow(nazwawozu[n], 1);
Textdraw0[n] = TextDrawCreate(282.000000,372.000000,"Predkosc:");
//Textdraw1 = TextDrawCreate(293.000000,382.000000,"0 km/h");
Textdraw2[n] = TextDrawCreate(286.000000,396.000000,"Paliwo:");
Textdraw3[n] = TextDrawCreate(288.000000,410.000000,"100/100l");
Textdraw4[n] = TextDrawCreate(363.000000,372.000000,"Stan Pojazdu:");
Textdraw5[n] = TextDrawCreate(369.000000,383.000000,"720hp");
Textdraw6[n] = TextDrawCreate(360.000000,396.000000,"Stan Ladunku:");
Textdraw7[n] = TextDrawCreate(381.000000,409.000000,"100");
Textdraw8[n] = TextDrawCreate(441.000000,372.000000,"Stan opon pojazdu:");
Textdraw9[n] = TextDrawCreate(469.000000,385.000000,"100");
Textdraw10[n] = TextDrawCreate(440.000000,396.000000,"Stan opon naczepa:");
TextDrawAlignment(Textdraw0[n],0);
//TextDrawAlignment(Textdraw1,0);
TextDrawAlignment(Textdraw2[n],0);
//TextDrawAlignment(Textdraw3,0);
TextDrawAlignment(Textdraw4[n],0);
TextDrawAlignment(Textdraw5[n],0);
TextDrawAlignment(Textdraw6[n],0);
TextDrawAlignment(Textdraw7[n],0);
TextDrawAlignment(Textdraw8[n],0);
TextDrawAlignment(Textdraw9[n],0);
TextDrawAlignment(Textdraw10[n],0);
TextDrawBackgroundColor(Textdraw0[n],0x000000ff);
//TextDrawBackgroundColor(Textdraw1,0x000000ff);
TextDrawBackgroundColor(Textdraw2[n],0x000000ff);
//TextDrawBackgroundColor(Textdraw3,0x000000ff);
TextDrawBackgroundColor(Textdraw4[n],0x000000ff);
TextDrawBackgroundColor(Textdraw5[n],0x000000ff);
TextDrawBackgroundColor(Textdraw6[n],0x000000ff);
TextDrawBackgroundColor(Textdraw7[n],0x000000ff);
TextDrawBackgroundColor(Textdraw8[n],0x000000ff);
TextDrawBackgroundColor(Textdraw9[n],0x000000ff);
TextDrawBackgroundColor(Textdraw10[n],0x000000ff);
TextDrawFont(Textdraw0[n],1);
TextDrawLetterSize(Textdraw0[n],0.399999,1.000000);
//TextDrawFont(Textdraw1,2);
//TextDrawLetterSize(Textdraw1,0.299999,1.000000);
TextDrawFont(Textdraw2[n],1);
TextDrawLetterSize(Textdraw2[n],0.499999,1.000000);
//TextDrawFont(Textdraw3,2);
//TextDrawLetterSize(Textdraw3,0.299999,1.000000);
TextDrawFont(Textdraw4[n],1);
TextDrawLetterSize(Textdraw4[n],0.299999,1.000000);
TextDrawFont(Textdraw5[n],2);
TextDrawLetterSize(Textdraw5[n],0.399999,1.000000);
TextDrawFont(Textdraw6[n],1);
TextDrawLetterSize(Textdraw6[n],0.299999,1.000000);
TextDrawFont(Textdraw7[n],2);
TextDrawLetterSize(Textdraw7[n],0.399999,1.000000);
TextDrawFont(Textdraw8[n],1);
TextDrawLetterSize(Textdraw8[n],0.299999,1.000000);
TextDrawFont(Textdraw9[n],2);
TextDrawLetterSize(Textdraw9[n],0.299999,1.000000);
TextDrawFont(Textdraw10[n],1);
TextDrawLetterSize(Textdraw10[n],0.299999,1.000000);
TextDrawColor(Textdraw0[n],0x00ff0033);
//TextDrawColor(Textdraw1,0xffffffff);
TextDrawColor(Textdraw2[n],0x00ff0033);
//TextDrawColor(Textdraw3,0xffffffff);
TextDrawColor(Textdraw4[n],0x00ff0033);
TextDrawColor(Textdraw5[n],0xffffffff);
TextDrawColor(Textdraw6[n],0x00ff0033);
TextDrawColor(Textdraw7[n],0xffffffff);
TextDrawColor(Textdraw8[n],0x00ff0033);
TextDrawColor(Textdraw9[n],0xffffffff);
TextDrawColor(Textdraw10[n],0x00ff0033);
TextDrawSetOutline(Textdraw0[n],1);
//TextDrawSetOutline(Textdraw1,1);
TextDrawSetOutline(Textdraw2[n],1);
//TextDrawSetOutline(Textdraw3,1);
TextDrawSetOutline(Textdraw4[n],1);
TextDrawSetOutline(Textdraw5[n],1);
TextDrawSetOutline(Textdraw6[n],1);
TextDrawSetOutline(Textdraw7[n],1);
TextDrawSetOutline(Textdraw8[n],1);
TextDrawSetOutline(Textdraw9[n],1);
TextDrawSetOutline(Textdraw10[n],1);
TextDrawSetProportional(Textdraw0[n],1);
//TextDrawSetProportional(Textdraw1,1);
TextDrawSetProportional(Textdraw2[n],1);
//TextDrawSetProportional(Textdraw3,1);
TextDrawSetProportional(Textdraw4[n],1);
TextDrawSetProportional(Textdraw5[n],1);
TextDrawSetProportional(Textdraw6[n],1);
TextDrawSetProportional(Textdraw7[n],1);
TextDrawSetProportional(Textdraw8[n],1);
TextDrawSetProportional(Textdraw9[n],1);
TextDrawSetProportional(Textdraw10[n],1);
TextDrawSetShadow(Textdraw0[n],1);
//TextDrawSetShadow(Textdraw1,1);
TextDrawSetShadow(Textdraw2[n],1);
//TextDrawSetShadow(Textdraw3,1);
TextDrawSetShadow(Textdraw4[n],1);
TextDrawSetShadow(Textdraw5[n],1);
TextDrawSetShadow(Textdraw6[n],1);
TextDrawSetShadow(Textdraw7[n],1);
TextDrawSetShadow(Textdraw8[n],1);
TextDrawSetShadow(Textdraw9[n],1);
TextDrawSetShadow(Textdraw10[n],1);
		

		NapisPrzyLadowaniu[n] = TextDrawCreate(233.000000, 129.000000, "Trwa ladowanie towaru, prosze czekac...");
		TextDrawBackgroundColor(NapisPrzyLadowaniu[n], 255);
		TextDrawFont(NapisPrzyLadowaniu[n], 1);
		TextDrawLetterSize(NapisPrzyLadowaniu[n], 0.250000, 1.000000);
		TextDrawColor(NapisPrzyLadowaniu[n], -1);
		TextDrawSetOutline(NapisPrzyLadowaniu[n], 1);
		TextDrawSetProportional(NapisPrzyLadowaniu[n], 1);

	

		LadowanieBar[n] = CreateProgressBar(219.00, 140.00, 205.50, 2.50, 731250687, 100.0);

	}

	Wybierz = TextDrawCreate(266.000000, 259.000000, "Wybierz wage towaru");
	TextDrawBackgroundColor(Wybierz, 255);
	TextDrawFont(Wybierz, 1);
	TextDrawLetterSize(Wybierz, 0.289999, 1.000000);
	TextDrawColor(Wybierz, -1);
	TextDrawSetOutline(Wybierz, 1);
	TextDrawSetProportional(Wybierz, 1);

	Skala = TextDrawCreate(192.000000, 271.000000, "0  4  8  12  16  20  ~y~24  ~r~28  ~r~32  ~r~36  ~r~40");
	TextDrawBackgroundColor(Skala, 255);
	TextDrawFont(Skala, 1);
	TextDrawLetterSize(Skala, 0.370000, 1.200000);
	TextDrawColor(Skala, -1);
	TextDrawSetOutline(Skala, 0);
	TextDrawSetProportional(Skala, 1);
	TextDrawSetShadow(Skala, 1);

	Info = TextDrawCreate(322.000000, 293.000000, "Uzyj ~g~Q ~w~by zmniejszyc lub ~g~E ~w~by zwiekszyc.~n~Zatwierdzasz towar przyciskiem ~g~F ~w~lub ~g~Enter~w~.~n~~r~Dopuszczalna waga to 24 tony!");
	TextDrawAlignment(Info, 2);
	TextDrawBackgroundColor(Info, 255);
	TextDrawFont(Info, 1);
	TextDrawLetterSize(Info, 0.259999, 1.000000);
	TextDrawColor(Info, -1);
	TextDrawSetOutline(Info, 1);
	TextDrawSetProportional(Info, 1);

	Napis = TextDrawCreate(38.000000,309.000000," ");
	TextDrawAlignment(Napis,0);
	TextDrawBackgroundColor(Napis,0x000000ff);
	TextDrawFont(Napis,1);
	TextDrawLetterSize(Napis,0.199999,1.000000);
	TextDrawColor(Napis,0xffffffff);
	TextDrawSetOutline(Napis,1);
	TextDrawSetProportional(Napis,1);
	TextDrawSetShadow(Napis,1);

	BarkPaliwa = TextDrawCreate(320.000000, 10.000000, "~r~UWAGA~n~~b~Brak paliwa!");
	TextDrawAlignment(BarkPaliwa, 2);
	TextDrawBackgroundColor(BarkPaliwa, 255);
	TextDrawFont(BarkPaliwa, 1);
	TextDrawLetterSize(BarkPaliwa, 0.709999, 2.000000);
	TextDrawColor(BarkPaliwa, -1);
	TextDrawSetOutline(BarkPaliwa, 1);
	TextDrawSetProportional(BarkPaliwa, 1);

	Naczepa = TextDrawCreate(360.000000, 353.000000, "~y~Naczepa");
	TextDrawBackgroundColor(Naczepa, 255);
	TextDrawFont(Naczepa, 0);
	TextDrawLetterSize(Naczepa, 0.869999, 2.100000);
	TextDrawColor(Naczepa, -1);
	TextDrawSetOutline(Naczepa, 0);
	TextDrawSetProportional(Naczepa, 1);
	TextDrawSetShadow(Naczepa, 1);

	NaczepaTlo = TextDrawCreate(324.000000, 369.000000, "                                           ");
	TextDrawBackgroundColor(NaczepaTlo, 255);
	TextDrawFont(NaczepaTlo, 1);
	TextDrawLetterSize(NaczepaTlo, 0.500000, 7.999998);
	TextDrawColor(NaczepaTlo, -1);
	TextDrawSetOutline(NaczepaTlo, 0);
	TextDrawSetProportional(NaczepaTlo, 1);
	TextDrawSetShadow(NaczepaTlo, 1);
	TextDrawUseBox(NaczepaTlo, 1);
	TextDrawBoxColor(NaczepaTlo, 68);
	TextDrawTextSize(NaczepaTlo, 484.000000, 0.000000);

	TowarWagaCzas = TextDrawCreate(326.000000, 387.000000, "~g~Towar~n~~n~Waga~n~~n~Czas");
	TextDrawBackgroundColor(TowarWagaCzas, 255);
	TextDrawFont(TowarWagaCzas, 1);
	TextDrawLetterSize(TowarWagaCzas, 0.500000, 1.000000);
	TextDrawColor(TowarWagaCzas, -1);
	TextDrawSetOutline(TowarWagaCzas, 0);
	TextDrawSetProportional(TowarWagaCzas, 1);
	TextDrawSetShadow(TowarWagaCzas, 1);

	Osiagniecia1 = TextDrawCreate(178.000000, 153.000000, "                                                           ");
	TextDrawBackgroundColor(Osiagniecia1, 255);
	TextDrawFont(Osiagniecia1, 1);
	TextDrawLetterSize(Osiagniecia1, 0.500000, 13.700001);
	TextDrawColor(Osiagniecia1, -1);
	TextDrawSetOutline(Osiagniecia1, 1);
	TextDrawSetProportional(Osiagniecia1, 1);
	TextDrawUseBox(Osiagniecia1, 1);
	TextDrawBoxColor(Osiagniecia1, 112);
	TextDrawTextSize(Osiagniecia1, 443.000000, 0.000000);

	Osiagniecia2 = TextDrawCreate(178.000000, 174.000000, "                                                          ");
	TextDrawBackgroundColor(Osiagniecia2, 255);
	TextDrawFont(Osiagniecia2, 1);
	TextDrawLetterSize(Osiagniecia2, 0.500000, -0.400000);
	TextDrawColor(Osiagniecia2, -1);
	TextDrawSetOutline(Osiagniecia2, 0);
	TextDrawSetProportional(Osiagniecia2, 1);
	TextDrawSetShadow(Osiagniecia2, 1);
	TextDrawUseBox(Osiagniecia2, 1);
	TextDrawBoxColor(Osiagniecia2, -1);
	TextDrawTextSize(Osiagniecia2, 443.000000, -13.000000);

	OsiagnieciaNapis = TextDrawCreate(311.000000, 153.000000, "Osiagniecie");
	TextDrawAlignment(OsiagnieciaNapis, 2);
	TextDrawBackgroundColor(OsiagnieciaNapis, -16776961);
	TextDrawFont(OsiagnieciaNapis, 1);
	TextDrawLetterSize(OsiagnieciaNapis, 0.559999, 1.600000);
	TextDrawColor(OsiagnieciaNapis, -1);
	TextDrawSetOutline(OsiagnieciaNapis, 1);
	TextDrawSetProportional(OsiagnieciaNapis, 1);
	
	AdminNews1 = TextDrawCreate(330.000000, 311.000000, "Admin News");
	TextDrawBackgroundColor(AdminNews1, -1);
	TextDrawFont(AdminNews1, 1);
	TextDrawLetterSize(AdminNews1, 0.500000, 1.000000);
	TextDrawColor(AdminNews1, 731250687);
	TextDrawSetOutline(AdminNews1, 1);
	TextDrawSetProportional(AdminNews1, 1);

	AdminNews2 = TextDrawCreate(324.000000, 319.000000, "                                                                          ");
	TextDrawBackgroundColor(AdminNews2, 255);
	TextDrawFont(AdminNews2, 1);
	TextDrawLetterSize(AdminNews2, 0.500000, 3.100000);
	TextDrawColor(AdminNews2, -1);
	TextDrawSetOutline(AdminNews2, 0);
	TextDrawSetProportional(AdminNews2, 1);
	TextDrawSetShadow(AdminNews2, 1);
	TextDrawUseBox(AdminNews2, 1);
	TextDrawBoxColor(AdminNews2, 68);
	TextDrawTextSize(AdminNews2, 632.000000, 0.000000);

	AdminNews3 = TextDrawCreate(332.000000, 326.000000, "_");
	TextDrawBackgroundColor(AdminNews3, 255);
	TextDrawFont(AdminNews3, 1);
	TextDrawLetterSize(AdminNews3, 0.280000, 1.399998);
	TextDrawColor(AdminNews3, -1);
	TextDrawSetOutline(AdminNews3, 0);
	TextDrawSetProportional(AdminNews3, 1);
	TextDrawSetShadow(AdminNews3, 1);

	//spawn LS
	AddStaticVehicleEx(435,1779.50000000,-1933.50000000,14.00000000,270.00000000,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,1779.69995117,-1928.80004883,14.00000000,270.00000000,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,1779.69995117,-1923.50000000,14.00000000,270.00000000,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(450,1778.80004883,-1918.80004883,14.00000000,270.00000000,-1,-1,SPAWN); //Trailer 2
	AddStaticVehicleEx(450,1779.00000000,-1913.80004883,14.00000000,270.00000000,-1,-1,SPAWN); //Trailer 2
	AddStaticVehicleEx(450,1778.69995117,-1908.69995117,14.00000000,270.00000000,-1,-1,SPAWN); //Trailer 2
	AddStaticVehicleEx(591,1779.19995117,-1904.40002441,14.00000000,268.00000000,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(591,1779.30004883,-1899.90002441,14.00000000,267.99499512,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(591,1779.40002441,-1896.09997559,14.00000000,267.99499512,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(584,1778.69995117,-1892.09997559,14.60000038,270.00000000,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(584,1778.59997559,-1888.09997559,14.60000038,270.00000000,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(584,1764.00000000,-1888.19995117,14.60000038,270.00000000,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(584,1764.09997559,-1892.30004883,14.60000038,270.00000000,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(515,1801.80004883,-1933.19995117,15.19999981,270.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1801.90002441,-1928.50000000,15.19999981,270.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1802.00000000,-1923.69995117,15.19999981,270.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(514,1802.40002441,-1919.09997559,15.19999981,270.00000000,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(514,1802.50000000,-1914.80004883,15.19999981,270.00000000,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(514,1813.09997559,-1873.59997559,14.10000038,180.00000000,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(514,1802.50000000,-1905.90002441,15.19999981,270.00000000,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(514,1802.50000000,-1901.90002441,15.19999981,270.00000000,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(515,1813.90002441,-1936.40002441,14.50000000,0.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1813.80004883,-1921.80004883,14.50000000,0.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1813.69995117,-1908.00000000,14.50000000,0.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1828.59997559,-1917.90002441,14.50000000,0.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1828.50000000,-1904.50000000,14.50000000,0.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1836.50000000,-1884.30004883,14.50000000,90.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1796.19995117,-1884.00000000,14.50000000,270.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(514,1802.39941406,-1910.39941406,15.19999981,270.00000000,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(514,1805.50000000,-1863.09997559,14.10000038,270.00000000,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(514,1791.30004883,-1862.90002441,14.10000038,270.00000000,-1,-1,SPAWN); //Tanker
	//spawn SF
	AddStaticVehicleEx(584,-1965.69995117,105.80000305,28.79999924,90.00000000,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(584,-1965.59997559,101.30000305,28.79999924,90.00000000,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(435,-1965.30004883,92.19999695,28.29999924,90.00000000,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,-1965.40002441,88.19999695,28.29999924,90.00000000,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,-1965.19995117,83.90000153,28.29999924,90.00000000,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,-1965.30004883,79.40000153,28.29999924,90.00000000,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(403,-1978.59997559,105.90000153,28.39999962,90.00000000,-1,-1,SPAWN); //Linerunner
	AddStaticVehicleEx(403,-1977.90002441,92.09999847,28.39999962,90.00000000,-1,-1,SPAWN); //Linerunner
	AddStaticVehicleEx(514,-1979.30004883,101.30000305,28.39999962,90.00000000,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(514,-1978.59997559,88.00000000,28.39999962,90.00000000,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(515,-1978.90002441,96.40000153,28.79999924,90.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,-1978.69995117,83.40000153,28.79999924,90.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,-1978.80004883,78.69999695,28.79999924,90.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(584,-1965.50000000,96.59960938,28.79999924,90.00000000,-1,-1,SPAWN); //Trailer 3
	
	//LS
	AddStaticVehicleEx(403,1658.59997559,-1080.19995117,24.60000038,270.00000000,-1,-1,SPAWN); //Linerunner
	AddStaticVehicleEx(403,1658.50000000,-1084.59997559,24.60000038,270.00000000,-1,-1,SPAWN); //Linerunner
	AddStaticVehicleEx(403,1658.50000000,-1089.19995117,24.60000038,270.00000000,-1,-1,SPAWN); //Linerunner
	AddStaticVehicleEx(403,1658.59997559,-1093.59997559,24.60000038,270.00000000,-1,-1,SPAWN); //Linerunner
	AddStaticVehicleEx(403,1658.69995117,-1098.09997559,24.60000038,270.00000000,-1,-1,SPAWN); //Linerunner
	AddStaticVehicleEx(403,1658.50000000,-1102.59997559,24.60000038,270.00000000,-1,-1,SPAWN); //Linerunner
	AddStaticVehicleEx(403,1658.59997559,-1106.90002441,24.60000038,270.00000000,-1,-1,SPAWN); //Linerunner
	AddStaticVehicleEx(403,1658.40002441,-1111.59997559,24.60000038,270.00000000,-1,-1,SPAWN); //Linerunner
	AddStaticVehicleEx(403,1649.00000000,-1111.59997559,24.60000038,89.99987793,-1,-1,SPAWN); //Linerunner
	AddStaticVehicleEx(403,1649.09997559,-1107.09997559,24.60000038,89.99450684,-1,-1,SPAWN); //Linerunner
	AddStaticVehicleEx(403,1648.90002441,-1102.59997559,24.60000038,89.99450684,-1,-1,SPAWN); //Linerunner
	AddStaticVehicleEx(403,1648.80004883,-1098.19995117,24.60000038,89.99450684,-1,-1,SPAWN); //Linerunner
	AddStaticVehicleEx(403,1648.80004883,-1093.59997559,24.60000038,89.99450684,-1,-1,SPAWN); //Linerunner
	AddStaticVehicleEx(403,1648.90002441,-1089.19995117,24.60000038,89.99450684,-1,-1,SPAWN); //Linerunner
	AddStaticVehicleEx(403,1649.09997559,-1084.69995117,24.60000038,89.99450684,-1,-1,SPAWN); //Linerunner
	AddStaticVehicleEx(403,1649.00000000,-1080.19995117,24.60000038,89.99450684,-1,-1,SPAWN); //Linerunner
	AddStaticVehicleEx(514,1681.30004883,-1034.50000000,24.60000038,2.00000000,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(514,1685.59997559,-1034.40002441,24.60000038,359.99951172,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(514,1689.69995117,-1034.30004883,24.60000038,359.99951172,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(514,1694.69995117,-1034.50000000,24.60000038,359.99951172,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(514,1698.90002441,-1034.40002441,24.60000038,359.99951172,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(514,1703.40002441,-1034.50000000,24.60000038,359.99951172,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(514,1708.00000000,-1034.50000000,24.60000038,359.99951172,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(514,1712.30004883,-1034.59997559,24.60000038,359.99951172,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(514,1680.80004883,-1045.19995117,24.60000038,179.99951172,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(514,1685.00000000,-1045.09997559,24.60000038,179.99450684,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(515,1691.19995117,-1059.40002441,25.10000038,0.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1695.69995117,-1059.30004883,25.10000038,358.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1700.19995117,-1059.30004883,25.10000038,0.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1704.80004883,-1059.30004883,25.10000038,0.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1709.19995117,-1059.30004883,25.10000038,0.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1713.50000000,-1059.30004883,25.10000038,0.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1718.19995117,-1059.40002441,25.10000038,0.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1722.69995117,-1059.30004883,25.10000038,0.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1722.69995117,-1070.69995117,25.10000038,179.99951172,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1718.00000000,-1070.59997559,25.10000038,179.99493408,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1713.69995117,-1070.69995117,25.10000038,179.99493408,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1709.00000000,-1070.69995117,25.10000038,177.99499512,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1704.59997559,-1070.80004883,25.10000038,179.99493408,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1700.19995117,-1070.69995117,25.10000038,179.99450684,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1695.80004883,-1070.69995117,25.10000038,179.99450684,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,1691.30004883,-1070.69995117,25.10000038,179.99450684,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(435,1651.80004883,-1017.00000000,24.60000038,190.00000000,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,1655.69995117,-1016.29998779,24.60000038,190.00000000,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,1660.00000000,-1015.29998779,24.60000038,191.99755859,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,1664.59997559,-1014.20001221,24.60000038,189.99755859,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,1674.30004883,-1011.50000000,24.60000038,197.99755859,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,1677.90002441,-1010.29998779,24.60000038,197.99560547,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,1682.19995117,-1009.00000000,24.60000038,197.99560547,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,1686.50000000,-1008.00000000,24.60000038,197.99560547,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,1690.30004883,-1006.59997559,24.60000038,197.99560547,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,1694.59997559,-1005.00000000,24.60000038,197.99560547,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(450,1704.30004883,-1003.29998779,24.60000038,171.99969482,-1,-1,SPAWN); //Trailer 2
	AddStaticVehicleEx(450,1727.00000000,-1007.00000000,24.60000038,167.99645996,-1,-1,SPAWN); //Trailer 2
	AddStaticVehicleEx(450,1708.50000000,-1003.70001221,24.60000038,171.99645996,-1,-1,SPAWN); //Trailer 2
	AddStaticVehicleEx(450,1712.40002441,-1004.29998779,24.60000038,171.99645996,-1,-1,SPAWN); //Trailer 2
	AddStaticVehicleEx(450,1717.30004883,-1005.40002441,24.60000038,171.99645996,-1,-1,SPAWN); //Trailer 2
	AddStaticVehicleEx(450,1721.80004883,-1005.79998779,24.60000038,169.99145508,-1,-1,SPAWN); //Trailer 2
	AddStaticVehicleEx(450,1731.30004883,-1007.90002441,24.60000038,167.99139404,-1,-1,SPAWN); //Trailer 2
	AddStaticVehicleEx(450,1735.80004883,-1008.90002441,24.60000038,167.98645020,-1,-1,SPAWN); //Trailer 2
	AddStaticVehicleEx(450,1740.50000000,-1009.79998779,24.60000038,167.98645020,-1,-1,SPAWN); //Trailer 2
	AddStaticVehicleEx(450,1744.09997559,-1010.79998779,24.60000038,167.98645020,-1,-1,SPAWN); //Trailer 2
	AddStaticVehicleEx(591,1744.09997559,-1046.30004883,24.60000038,179.99938965,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(591,1748.90002441,-1046.40002441,24.60000038,179.99493408,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(591,1753.30004883,-1046.09997559,24.60000038,179.99493408,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(591,1757.40002441,-1046.19995117,24.60000038,179.99493408,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(591,1761.80004883,-1046.19995117,24.60000038,179.99493408,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(591,1744.30004883,-1037.69995117,24.60000038,359.99414062,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(591,1748.69995117,-1037.59997559,24.60000038,359.98901367,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(591,1753.50000000,-1037.59997559,24.60000038,359.98901367,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(591,1757.69995117,-1037.59997559,24.60000038,359.98901367,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(591,1761.69995117,-1037.59997559,24.60000038,359.98901367,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(584,1735.90002441,-1086.00000000,25.10000038,0.00000000,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(584,1740.09997559,-1086.00000000,25.10000038,0.00000000,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(584,1744.50000000,-1086.09997559,25.10000038,0.00000000,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(584,1749.19995117,-1086.19995117,25.10000038,0.00000000,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(584,1753.69995117,-1086.09997559,25.10000038,0.00000000,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(584,1757.90002441,-1086.19995117,25.10000038,0.00000000,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(584,1762.50000000,-1086.09997559,25.10000038,0.00000000,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(584,1767.19995117,-1086.09997559,25.10000038,0.00000000,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(584,1771.50000000,-1086.09997559,25.10000038,0.00000000,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(584,1776.19995117,-1086.00000000,25.10000038,0.00000000,-1,-1,SPAWN); //Trailer 3
	AddStaticVehicleEx(584,1780.69995117,-1086.09997559,25.10000038,0.00000000,-1,-1,SPAWN); //Trailer 3

	//SF
	AddStaticVehicleEx(435,-1624.40002441,403.60000610,7.80000019,45.99975586,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(515,-1675.19995117,436.20001221,8.30000019,224.00000000,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,-1671.90002441,439.79998779,8.30000019,223.99475098,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,-1668.50000000,443.50000000,8.30000019,223.99475098,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,-1664.59997559,447.20001221,8.30000019,223.99475098,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,-1661.30004883,450.60000610,8.30000019,223.99475098,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(515,-1657.09997559,454.20001221,8.30000019,223.99475098,-1,-1,SPAWN); //Roadtrain
	AddStaticVehicleEx(514,-1639.50000000,440.20001221,7.90000010,46.00000000,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(514,-1656.30004883,417.29998779,7.90000010,137.99975586,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(514,-1667.59997559,405.89999390,7.90000010,135.99975586,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(514,-1678.40002441,395.00000000,7.90000010,135.99975586,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(514,-1688.09997559,385.29998779,7.90000010,135.99975586,-1,-1,SPAWN); //Tanker
	AddStaticVehicleEx(435,-1622.19995117,405.89999390,7.80000019,45.99975586,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,-1620.09997559,408.20001221,7.80000019,45.99975586,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,-1617.90002441,410.39999390,7.80000019,45.99975586,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,-1615.80004883,412.60000610,7.80000019,45.99975586,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,-1614.00000000,414.60000610,7.80000019,45.99975586,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,-1611.80004883,416.60000610,7.80000019,45.99975586,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,-1609.59997559,418.50000000,7.80000019,45.99975586,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,-1607.40002441,420.50000000,7.80000019,45.99975586,-1,-1,SPAWN); //Trailer 1
	AddStaticVehicleEx(435,-1605.40002441,422.60000610,7.80000019,45.99975586,-1,-1,SPAWN); //Trailer 1

	
/*
	bramart = CreateObject(980,-1209.19995117,-1067.80004883,130.00000000,0.00000000,0.00000000,0.00000000); //object(airportgate) (1)
	sbramart=1;
	bramapoli = CreateObject(980,-1572.00000000,661.90002441,9.00000000,0.00000000,0.00000000,90.00000000); //object(airportgate) (1)
	sbramapoli=1;
	bramapd = CreateObject(980,1059.69995117,1802.19995117,12.60000038,0.00000000,0.00000000,0.00000000); //object(airportgate) (1)
	sbramapd=1;
*/	for(new i=0; i<ILOSC_ZALADUNKOW; i++)
	{
	    CreateDynamic3DTextLabel(""C_CZERWONY"Witaj w Firmie\n\n"C_ZIELONY"Aby za³adowaæ wpisz:\n"C_ZOLTY"/zaladuj\n"C_ZIELONY"Aby roz³adowaæ wpisz:\n"C_ZOLTY"/rozladuj", 0x00FF40FF, Zaladunki[i][0], Zaladunki[i][1], Zaladunki[i][2], 30.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 100.0);
	}
	for(new i=0; i<POJAZDY; i++)
	{
	    new naczepa=GetVehicleModel(GetVehicleTrailer(i));
		if(naczepa==435||naczepa==450||naczepa==591||naczepa==584)
		{
		    CarInfo[i][cNaczepa]=1;
		    CarInfo[i][cPaliwo]=0;
		    CarInfo[i][cZaladowany]=0;
		    CarInfo[i][cWaga]=0;
		    CarInfo[i][cWyladuj]=0;
		    strmid(CarInfo[i][cTowar], "brak", 0, 34, 34);
		    SetVehicleParamsEx(i,false,false,false,false,false,false,false);
		}
		else
		{
			CarInfo[i][cNaczepa]=0;
		    CarInfo[i][cPaliwo]=100;
		    CarInfo[i][cZaladowany]=0;
		    CarInfo[i][cWaga]=0;
		    CarInfo[i][cWyladuj]=0;
		    strmid(CarInfo[i][cTowar], "brak", 0, 34, 34);
		    SetVehicleParamsEx(i,false,false,false,false,false,false,false);
		    makogut[i]=0;
		}
	}
	for(new i=0; i<KUPNE; i++)
	{
	    new Float: Pos[4],
	        idwozu;

 		new plik[45];
        format(plik,sizeof(plik), FRAKCYJNE, i);
        if(DOF_FileExists(plik))
        {
            idwozu = DOF_GetInt(plik, "Model");
            Pos[0] = DOF_GetFloat(plik, "X");
            Pos[1] = DOF_GetFloat(plik, "Y");
            Pos[2] = DOF_GetFloat(plik, "Z");
            Pos[3] = DOF_GetFloat(plik, "Rot");
            zespawnowany = CreateVehicle(idwozu, Pos[0], Pos[1], Pos[2], Pos[3], -1, -1, SPAWN);
            printf("Za³adowano frakcyjny pojazd o ID: %d", zespawnowany);

            new naczepa=GetVehicleModel(GetVehicleTrailer(zespawnowany));
			if(naczepa==435||naczepa==450||naczepa==591||naczepa==584)
			{
			    CarInfo[zespawnowany][cNaczepa]=1;
			    CarInfo[zespawnowany][cPaliwo]=0;
			    CarInfo[zespawnowany][cZaladowany]=0;
			    CarInfo[zespawnowany][cWaga]=0;
			    CarInfo[zespawnowany][cWyladuj]=0;
			    strmid(CarInfo[zespawnowany][cTowar], "brak", 0, 34, 34);
			    SetVehicleParamsEx(zespawnowany,false,false,false,false,false,false,false);
			}
			else
			{
				CarInfo[zespawnowany][cNaczepa]=0;
			    CarInfo[zespawnowany][cPaliwo]=100;
			    CarInfo[zespawnowany][cZaladowany]=0;
			    CarInfo[zespawnowany][cWaga]=0;
			    CarInfo[zespawnowany][cWyladuj]=0;
			    strmid(CarInfo[zespawnowany][cTowar], "brak", 0, 34, 34);
			    SetVehicleParamsEx(zespawnowany,false,false,false,false,false,false,false);
			}
		}
	}
	new file[64];
	for(new nr = 0; nr < LA; nr++)
	{
	    format(file,sizeof(file),AUTOMATY_FILE,nr);
	    if(DOF_FileExists(file))
	 	{
            AutomatInfo[nr][aAktywny] = 1;
            AutomatInfo[nr][aX] = DOF_GetFloat(file,"X");
            AutomatInfo[nr][aY] = DOF_GetFloat(file,"Y");
            AutomatInfo[nr][aZ] = DOF_GetFloat(file,"Z");
            AutomatInfo[nr][aAng] = DOF_GetFloat(file,"Ang");
            Automat[nr] = CreateDynamicObject(1775, AutomatInfo[nr][aX], AutomatInfo[nr][aY], AutomatInfo[nr][aZ], 0.0000, 0.0000, AutomatInfo[nr][aAng]);
            CreateDynamic3DTextLabel("U¿yj /automat\nRegeneracja HP kosztuje 40$\ni regeneruje 10HP",0x00FF40FF,AutomatInfo[nr][aX], AutomatInfo[nr][aY], AutomatInfo[nr][aZ],5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,0,0,-1,5.0);
			printf("Zaladowano automat o ID: %d", nr);
		}
		else
		{
		    AutomatInfo[nr][aAktywny] = 0;
		}
	}
	for(new i = 0; i < ILOSC_BANKOW; i++)
	{
	    CreateDynamic3DTextLabel(""C_CZERWONY"HTBank\n"C_TURKUSOWY"Wpisz "C_ZIELONY"/bank "C_TURKUSOWY"aby zarz¹dzaæ swoim kontem (przelew, kredyt lub stan konta)",0x00FF40FF,Banki[i][0], Banki[i][1], Banki[i][2],20.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,0,0,-1,20.0);
		printf("Za³adowano bank o ID: %d", i);
	}
	
	for(new i = 0; i <ILOSC_STACJI; i++)
	{
	    format(dstring, sizeof(dstring), "Stacja benzynowa\n"C_ZOLTY"/stacja\n"C_ZIELONY"%d $ / 1 litr", floatround(stacja[i][3]));
	    CreateDynamic3DTextLabel(dstring,KOLOR_POMARANCZOWY,stacja[i][0],stacja[i][1],stacja[i][2],25.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,0,0,-1,25.0);
		printf("Za³adowano StacjePaliw o ID: %d", i);
	}
	
	for(new i = 0; i <ILOSC_SALONOW; i++)
	{
	    CreateDynamic3DTextLabel(""C_CZERWONY"Salon Samochodowy\n"C_BEZOWY"Wpisz "C_ZIELONY"/salon"C_BEZOWY" by kupiæ pojazd.",KOLOR_POMARANCZOWY,Salon[i][0],Salon[i][1],Salon[i][2],25.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,0,0,-1,25.0);
	    CreateDynamic3DTextLabel(""C_NIEBIESKI"Tutaj zespawnuje siê pojazd który kupisz!",KOLOR_POMARANCZOWY,Salon[i][3],Salon[i][4],Salon[i][5],25.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,0,0,-1,25.0);
		printf("Za³adowano Salon o ID: %d", i);
	}
	


	SetTimer("CoMinute",60000,true);//co pó³ minuty
	SetTimer("OdejmijPaliwo",30000,true);//co pó³ minuty
	SetTimer("Update",1000,true);//co sekunde
	CreateDynamic3DTextLabel(""C_NIEBIESKI"Wybierz trucka i jedŸ rozwoziæ towary!\n"C_CZERWONY"W razie problemow pisz "C_ZIELONY"/cmd"C_CZERWONY".", 0x00FF40FF, 1772.545898, -1941.116333, 13.566694, 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 100.0);
	CreateDynamic3DTextLabel(""C_NIEBIESKI"Wybierz trucka i jedŸ rozwoziæ towary!\n"C_CZERWONY"W razie problemow pisz "C_ZIELONY"/cmd"C_CZERWONY".", 0x00FF40FF, -1982.395996, 103.181854, 27.687461, 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 100.0);
	return 1;
}

stock Float:GetVehicleSpeed(vehicleid)
{
	new Float:speed_x,Float:speed_y,Float:speed_z,Float:temp_speed;
	GetVehicleVelocity(vehicleid,speed_x,speed_y,speed_z);
	temp_speed = floatsqroot(((speed_x*speed_x)+(speed_y*speed_y))+(speed_z*speed_z))*136.666667;
	floatround(temp_speed,floatround_round);
	return temp_speed;
}

forward OdejmijPaliwo();
public OdejmijPaliwo()
{
    for(new i=0; i<POJAZDY; i++)
	{
	    GetVehicleParamsEx(i,engine,lights,alarm,doors,bonnet,boot,objective);
	    if(engine)
	    {
		    new naczepa=GetVehicleModel(GetVehicleTrailer(i));
			if(naczepa!=435||naczepa!=450||naczepa!=591||naczepa!=584)
			{
			    if(CarInfo[i][cPaliwo] > 0)
			    {
			        CarInfo[i][cPaliwo]--;
			    }
			    if(CarInfo[i][cPaliwo] == 0)
			    {
			        SetVehicleParamsEx(i,false,lights,alarm,doors,bonnet,boot,objective);
			        foreach(Player, d)
			        {
			            if(GetPlayerVehicleID(d) == i)
			            {
			        		TextDrawShowForPlayer(d, BarkPaliwa);
						}
					}
			    }
			}
		}
	}
	return 1;
}

forward CoMinute();
public CoMinute()
{
	for(new playerid = 0; playerid < Sloty; playerid++)
	{
	    if(PlayerInfo[playerid][pMute] > 0)
	    {
	        PlayerInfo[playerid][pMute]--;
	        if(PlayerInfo[playerid][pMute] == 0)
			{
			    SendClientMessage(playerid, KOLOR_ZIELONY, "Zosta³eœ odciszony.");
			    ZapiszKonto(playerid);
			}
		}
		if(PlayerInfo[playerid][pAresztowany] > 0)
		{
		    PlayerInfo[playerid][pAresztowany]--;
		    if(PlayerInfo[playerid][pAresztowany] == 0)
		    {
		        SetPlayerWorldBounds(playerid, 20000.0000, -20000.0000, 20000.0000, -20000.0000);
				CallLocalFunction("OnPlayerSpawn", "i",playerid);
			}
		}
	}
	return 1;
}
//NaczepaNazwa

forward Update();
public Update()
{
	for(new i = 0; i < Sloty; i++)
	{
	    if(IsPlayerInAnyVehicle(i))
	    {
	        new playerState = GetPlayerState(i);
 	    	if(playerState == PLAYER_STATE_DRIVER)
 	    	{
			    new vehicleid = GetPlayerVehicleID(i);
			    new mstring[50];
				//Paliwo
	
				format(mstring, sizeof(mstring), "%dL", floatround(CarInfo[vehicleid][cPaliwo]));
				TextDrawSetString(napispaliwo[i], mstring);
			 	//HP Wozu
				GetVehicleHealth(vehicleid, CarHealth[i]);

				//naczepa
				new naczepa = GetVehicleTrailer(vehicleid);
				format(mstring, sizeof(mstring), "~b~%s~n~~n~%d", CarInfo[naczepa][cTowar], CarInfo[naczepa][cWaga]);
				TextDrawSetString(NazwaWaga[i], mstring);

	 			format(dstring, sizeof(dstring), "~y~%s", GetVehicleName(naczepa));
	  			TextDrawSetString(NaczepaNazwa[i], dstring);

				if(CarInfo[naczepa][cWyladuj] > 0)
				{
					SetProgressBarValue(Czas[i], floatround(CarInfo[naczepa][cWyladuj]/1.8));
					UpdateProgressBar(Czas[i], i);
				}
				if(CarInfo[naczepa][cWyladuj] == 0)
				{
					SetProgressBarValue(Czas[i], 0);
					UpdateProgressBar(Czas[i], i);
				}
			}
		}
		if(GetPlayerMoney(i)!=dKasa[i])
		{
			if(!ToAdminLevel(i, 1))
			{
  				ResetPlayerMoney(i);
     			GivePlayerMoney(i,dKasa[i]);
     		}
    	}
		if(GetPlayerPing(i) > MAX_PING)
		{
		    if(Zalogowany[i] == 1)
		    {
		    	if(!ToAdminLevel(i, 1))
		    	{
		    	format(dstring, sizeof(dstring),"~r~(%d)%s zostal wyrzucony~n~~y~przez: (-1)AntyCheat~n~~w~Za: Ping %d/%d",i,Nick(i),GetPlayerPing(i),MAX_PING);
		    	NapisText(dstring);
		    	Kick(i);
				}
			}
		}
		if(GetPlayerSpeed(i) > MAX_SPEED)
		{
		    if(Zalogowany[i] == 1)
		    {
		    	if(!ToAdminLevel(i, 1))
		    	{
			    format(dstring, sizeof(dstring),"~r~(%d)%s zostal wyrzucony~n~~y~przez: (-1)AntyCheat~n~~w~Za: SpeedHack %d/%d",i,Nick(i),GetPlayerSpeed(i),MAX_SPEED);
			    NapisText(dstring);
			    Kick(i);
			    }
		    }
		}
		
	}
	for(new i=0; i<POJAZDY; i++)
	{
		new carid = GetVehicleTrailer(i);
		new naczepa = GetVehicleModel(carid);
		if(naczepa==435||naczepa==450||naczepa==591||naczepa==584)
		{
	 		if(CarInfo[carid][cWyladuj] >= 1)
	   		{
	     		CarInfo[carid][cWyladuj]--;
			}
		}
	}
	if(cd > 0)
	{
	    cd--;
	    foreach(Player, playerid)
	    {
		    GInfo(playerid, odliczanie[cd][0], 3, 1);
		    if(cd == 0)
		    {
		    	new bool:Uzywany[POJAZDY]=false,v;
				foreach(Player,i)
				{
					if(IsPlayerInAnyVehicle(i))
					{
						v=GetPlayerVehicleID(i);
						Uzywany[v]=true;
						if(IsTrailerAttachedToVehicle(v)) Uzywany[GetVehicleTrailer(v)]=true;
					}
				}
				for(new nr = 1; nr < POJAZDY; nr++)
				{
					if(Uzywany[nr]==false)
					{
						SetVehicleToRespawn(nr);
						SetVehicleParamsEx(nr,false,false,false,false,false,false,false);
					}
				}
				format(dstring, sizeof(dstring),"~r~Wszystkie pojazdy wrocily na miejsce spawnu!",playerid,Nick(playerid));
				NapisText(dstring);
		    }
		}
	}
	odliczanko++;
	
	if(odliczanko > 122)
	{
	    odliczanko=0;
	}
	return 1;
}

public OnGameModeExit()
{
    DOF_Exit();
    return 1;
}

public OnPlayerConnect(playerid)
{


	//Usuwanie obj. z mapy
	RemoveBuildingForPlayer(playerid, 3489, 1677.2969, 1671.6953, 16.4375, 0.25);
	RemoveBuildingForPlayer(playerid, 3490, 1677.2969, 1671.6953, 16.4375, 0.25);
	RemoveBuildingForPlayer(playerid, 8338, 1641.1328, 1629.4063, 13.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 8345, 1583.9844, 1516.7188, 13.3281, 0.25);
	RemoveBuildingForPlayer(playerid, 8339, 1641.1328, 1629.4063, 13.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 8042, 1720.7500, 1604.4141, 14.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 1294, 1728.3672, 1571.2891, 14.2734, 0.25);
	RemoveBuildingForPlayer(playerid, 1294, 1732.9688, 1599.3594, 14.2734, 0.25);
	RemoveBuildingForPlayer(playerid, 792, 1734.6094, 1581.6484, 9.7813, 0.25);
	RemoveBuildingForPlayer(playerid, 792, 1736.6563, 1550.7656, 9.9844, 0.25);
	RemoveBuildingForPlayer(playerid, 792, 1741.6172, 1610.1250, 8.9063, 0.25);
	RemoveBuildingForPlayer(playerid, 759, 1750.5781, 1564.6563, 9.9141, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1753.6563, 1592.1172, 17.1250, 0.25);
	/////////////

	Zalogowany[playerid] = 0;
	SetPVarInt(playerid, "Kasa", 0);
	Laduje[playerid] = 0;
	Zaladowany[playerid] = 0;
	Frakcja[playerid] = 0;
	PrivateCarSpawned[playerid] = 0;
	ostatnia[playerid] = 0;
	SetPlayerVirtualWorld(playerid,0);

    PlayerInfo[playerid][pLider] = 0;
    PlayerInfo[playerid][pFrakcja] = 0;
    PlayerInfo[playerid][pX] = 0.0000;
    PlayerInfo[playerid][pY] = 0.0000;
    PlayerInfo[playerid][pZ] = 0.0000;
    PlayerInfo[playerid][pAng] = 0.0000;
    PlayerInfo[playerid][pModel] = 0;
    PlayerInfo[playerid][pColor] = 0;
	PlayerInfo[playerid][pAdmin] = 0;
 	PlayerInfo[playerid][pKasa] = 0;
 	PlayerInfo[playerid][pScore] = 0;
	PlayerInfo[playerid][pAresztowany] = 0;
	PlayerInfo[playerid][pMute] = 0;
	PlayerInfo[playerid][pWarn] = 0;
	PlayerInfo[playerid][pPierwszy] = 1;
	PlayerInfo[playerid][pPremium] = 0;
	PlayerInfo[playerid][pKredyt] = 0;
	PlayerInfo[playerid][pPrawko] = 0;
	PlayerInfo[playerid][pBlok] = 0;
	PlayerInfo[playerid][pDJ] = 0;
	//Osi¹gniêcia Towary
	PlayerInfo[playerid][pDowiozl] = 0;
	PlayerInfo[playerid][pPotrzeba] = 0;
	PlayerInfo[playerid][pPoziom] = 1;
	//Osi¹gniêcia Mandaty
	PlayerInfo[playerid][pMandaty] = 0;
	PlayerInfo[playerid][pMandatyPotrzeba] = 0;
	PlayerInfo[playerid][pMandatyPoziom] = 1;
	//Osi¹gniêcia Aresztowania
	PlayerInfo[playerid][pAresztowan] = 0;
	PlayerInfo[playerid][pAresztowanPotrzeba] = 0;
	PlayerInfo[playerid][pAresztowanPoziom] = 1;

	format(dstring, sizeof(dstring), "%s [%d] "C_BIALY"zosta³ po³¹czony z serwerem.",Nick(playerid),playerid);
    SendClientMessageToAll(KOLOR_BEZOWY,dstring);

    new str[45];
	format(str, sizeof(str), KONTA,Nick(playerid));
	if(DOF_FileExists(str))
 	{
		ShowPlayerDialog(playerid, GUI_LOGIN, DIALOG_STYLE_PASSWORD, "xXx v2", "Wpisz poni¿ej has³o jakie poda³eœ przy rejestracji:", "Zaloguj", "WyjdŸ");
 	}
 	else
 	{
      	ShowPlayerDialog(playerid, GUI_REGISTER, DIALOG_STYLE_PASSWORD, "xXx v2", "Wybierz has³o jakiego bêdziesz u¿ywaæ podczas gry:", "Rejestruj", "WyjdŸ");
 	}
	SendClientMessage(playerid, KOLOR_BIALY, ""C_ZOLTY"===================== "C_BIALY"xXx "C_CZERWONY"v2"C_ZOLTY" =====================");
	SendClientMessage(playerid, KOLOR_BIALY, "Witaj na xXx v2.");
	SendClientMessage(playerid, KOLOR_BIALY, "Nasza mapa poœwiêcona jest pracy kierowców Truckow");
	SendClientMessage(playerid, KOLOR_BIALY, "Za zadanie masz dowozic towary do ró¿nych miejsc na mapie.");
	SendClientMessage(playerid, KOLOR_BIALY, "Mo¿esz te¿ do³¹czyæ do jakiejœ firmy lub frakcji.");
	SendClientMessage(playerid, KOLOR_BIALY, "Mamy nadziejê ¿e bêdziesz dobrze siê z nami bawi³");
	SendClientMessage(playerid, KOLOR_CZERWONY, "Administracja");
	SendClientMessage(playerid, KOLOR_BIALY, ""C_ZOLTY"=========================================================");
	for(new i=0; i<ILOSC_ZALADUNKOW; i++)
	{
	    SetPlayerMapIcon(playerid, i, Zaladunki[i][0], Zaladunki[i][1], Zaladunki[i][2], 56, 0, MAPICON_GLOBAL);
	}
 	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    SetPlayerHealth(playerid,100);
	if(classid <= 11)
	{
		SetPlayerPos(playerid, -216.843307, -180.755065, 2.259325);
		SetPlayerFacingAngle(playerid,343.4458);
		SetPlayerCameraPos(playerid, -220.073562, -178.524932, 2.257947+1);
		SetPlayerCameraLookAt(playerid, -216.843307, -180.755065, 2.259325);
		ApplyAnimation(playerid,"GANGS","leanIDLE",4.1,0,0,0,1,0);
		GInfo(playerid,"~n~~n~~n~~y~trucker", 3, 10);
	}
 	if((classid >= 12) && (classid <= 17))
 	{
		SetPlayerPos(playerid, -1605.6823, 710.9697, 13.8209);
		SetPlayerFacingAngle(playerid,0.0000);
		SetPlayerCameraPos(playerid, -1605.5577, 722.3950, 12.1212);
		SetPlayerCameraLookAt(playerid, -1605.5334, 721.3854, 12.3512);
		ApplyAnimation(playerid,"PED","Idlestance_fat",4.1,0,0,0,1,0);
		GInfo(playerid,"~n~~n~~n~~b~policja", 3, 10);
	}
	if((classid >= 18) && (classid <= 21))
 	{
		SetPlayerPos(playerid, -1904.507080, 276.990447, 41.046875);
		SetPlayerFacingAngle(playerid,180.0000);
		SetPlayerCameraPos(playerid, -1908.619140, 272.528747, 42.046875);
		SetPlayerCameraLookAt(playerid, -1904.507080, 276.990447, 41.046875);
		ApplyAnimation(playerid,"PED","endchat_03",4.1,0,0,0,0,0);
		GInfo(playerid,"~n~~n~~n~~b~Pomoc Drogowa", 3, 10);
	}
	if((classid >= 22) && (classid <= 23))
 	{
		SetPlayerPos(playerid, -216.843307, -180.755065, 2.259325);
		SetPlayerFacingAngle(playerid,343.4458);
		SetPlayerCameraPos(playerid, -220.073562, -178.524932, 2.257947+1);
		SetPlayerCameraLookAt(playerid, -216.843307, -180.755065, 2.259325);
		ApplyAnimation(playerid,"GANGS","leanIDLE",4.1,0,0,0,1,0);
		GInfo(playerid,"~n~~n~~n~~b~Speed Trans", 3, 10);
	}
	if((classid >= 24) && (classid <= 25))
 	{
		SetPlayerPos(playerid, 1244.0011, 662.3459, 5.5168);
		SetPlayerFacingAngle(playerid,358.0054);
		SetPlayerCameraPos(playerid, 1244.645507, 667.130615, 7.003112);
		SetPlayerCameraLookAt(playerid, 1244.0011, 662.3459, 5.5168);
		ApplyAnimation(playerid,"PED","endchat_02",4.1,0,0,0,0,0);
		GInfo(playerid,"~n~~n~~n~~b~Euro Trans", 3, 10);
	}
	if((classid >= 26) && (classid <= 27))
 	{
		SetPlayerPos(playerid, -216.843307, -180.755065, 2.259325);
		SetPlayerFacingAngle(playerid,343.4458);
		SetPlayerCameraPos(playerid, -220.073562, -178.524932, 2.257947+1);
		SetPlayerCameraLookAt(playerid, -216.843307, -180.755065, 2.259325);
		ApplyAnimation(playerid,"GANGS","leanIDLE",4.1,0,0,0,1,0);
		GInfo(playerid,"~n~~n~~n~~b~Xoomer", 3, 10);
	}
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	new nick[MAX_PLAYER_NAME];
	GetPlayerName(playerid, nick, sizeof(nick));
	UpperToLower(nick);

    new s=GetPlayerSkin(playerid);
    if((s==280||s==282||s==283||s==265||s==266||s==284)&&PlayerInfo[playerid][pFrakcja]!=1)
    {
        GInfo(playerid,"~r~nie jestes w policji!",3,3);
        return 0;
	}
	if((s==27||s==16||s==8||s==56)&&PlayerInfo[playerid][pFrakcja]!=2)
    {
        GInfo(playerid,"~r~nie jestes w PD!",3,3);
        return 0;
	}
	if((s==126||s==128)&&PlayerInfo[playerid][pFrakcja]!=10)
    {
        GInfo(playerid,"~r~nie jestes w Speed Trans!",3,3);
        return 0;
	}
	if((s==3||s==20)&&PlayerInfo[playerid][pFrakcja]!=11)
    {
        GInfo(playerid,"~r~nie jestes w Euro Trans!",3,3);
        return 0;
	}
	if((s==121||s==152)&&PlayerInfo[playerid][pFrakcja]!=12)
    {
        GInfo(playerid,"~r~nie jestes w Xoomer!",3,3);
        return 0;
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(Zalogowany[playerid]==0)
	{
		format(dstring, sizeof(dstring),"~r~(%d)%s zostal wyrzucony~n~~y~przez: (-1)AntyCheat~n~~w~Za: Brak zalogowania",playerid,Nick(playerid));
 		NapisText(dstring);
  		Kick(playerid);
  		return 0;
	}
	GivePlayerWeapon(playerid, 0, 0);
	SetPlayerHealth(playerid,100);
	SetPlayerArmour(playerid,0);
	SetPlayerInterior(playerid,0);
	SetPlayerVirtualWorld(playerid,0);
    ClearAnimations(playerid);
    if(Zalogowany[playerid] == 0)
        Kick(playerid);
        
	if(PlayerInfo[playerid][pAresztowany]>=1)
	{
	    ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Wiêzienie", ""C_CZERWONY"Nie odsiedzia³eœ do koñca na³o¿onej na Ciebie kary!", "Rozumiem","");
		SetPlayerPos(playerid,264.9535,77.5068,1001.0391);
  		SetPlayerInterior(playerid,6);
    	SetPlayerVirtualWorld(playerid,playerid);
	    SetPlayerWorldBounds(playerid,268.5071,261.3936,81.6285,71.8745);
	    return 1;
	}
	if(!ToPolicjant(playerid))
	{
 		if(PlayerInfo[playerid][pModel] > 0)
  		{
	        if(PrivateCarSpawned[playerid] == 0)
	        {
		        new model = PlayerInfo[playerid][pModel];
		        new Float: X = PlayerInfo[playerid][pX];
		        new Float: Y = PlayerInfo[playerid][pY];
		        new Float: Z = PlayerInfo[playerid][pZ];
		        new Float: Ang = PlayerInfo[playerid][pAng];
		        PrivateCarSpawned[playerid] = 1;
                PrivateCar[playerid] = AddStaticVehicleEx(model, X, Y, Z, Ang, PlayerInfo[playerid][pColor], PlayerInfo[playerid][pColor], SPAWN);
				SendClientMessage(playerid, KOLOR_ZIELONY, "Twój prywatny pojazd zosta³ zespawnowany!");
				format(dstring, sizeof(dstring), ""C_CZERWONY"Prywatny Pojazd\n"C_ZIELONY"Nick: "C_ZOLTY"%s\n"C_ZIELONY"ID: "C_ZOLTY"%d", Nick(playerid), playerid);
                PrivateCarText[playerid] = Create3DTextLabel(dstring,0x008080FF,30.0,40.0,50.0,40.0,0);
                Attach3DTextLabelToVehicle(PrivateCarText[playerid], PrivateCar[playerid], 0.0, 0.0, 0.0);
                SetVehicleParamsEx(PrivateCar[playerid],false,false,false,false,false,false,false);
				CarInfo[PrivateCar[playerid]][cPaliwo]=100;
			}
		}
	}
	new file[80];
	format(file,sizeof file,VIP_FILE,Nick(playerid));
	if(DOF_FileExists(file))
	{
		if(DOF_GetInt(file,"VipCzas") < gettime())
		{
			DOF_SetInt(file,"Vip",0);
			DOF_RemoveFile(file);
		}else if(GetPVarInt(playerid,"pokazywalo")==0)
		{
			PokazCzas(playerid);
			DOF_SetInt(file,"Vip",1);
			SetPVarInt(playerid,"pokazywalo",1);
		}
	}
	{
	    new s=GetPlayerSkin(playerid);
		if(s==280||s==282||s==283||s==265||s==266||s==284) // policja
		{
		    SetPlayerPos(playerid, 2239.8337,2449.3369,10.8203);
		    SetPlayerColor(playerid,KOLOR_NIEWIDZIALNY);
		    SetPlayerArmour(playerid,100);
		    return 0;
		}
		if(s==27||s==16||s==8||s==56) //Pomoc Drogowa
		{
		    SetPlayerPos(playerid, 1103.1051,1330.1458,10.8203);
		    SetPlayerColor(playerid,KOLOR_SZARY);
		    return 0;
		}
		if(s==126||s==128) //Speed Trans
	    {
	        SetPlayerPos(playerid,  1730.8868,-1951.05499,14.1187);
	        SetPlayerColor(playerid,KOLOR_CZERWONY);
	        return 0;
		}
		if(s==3||s==20) //Euro Trans
	    {
	        SetPlayerPos(playerid,  1730.8868,-1951.05499,14.1187);
	        SetPlayerColor(playerid,KOLOR_NIEBIESKI);
	        return 0;
		}
		if(s==121||s==152) //Rico Trans/// xoomer
	    {
	        SetPlayerPos(playerid,  2368.89990234,574.79998779,10.79999924);
	        SetPlayerColor(playerid,KOLOR_ZIELONY);
	        return 0;
		}
		else //trucker
		{
		    SetPlayerColor(playerid,KOLOR_TURKUSOWY);
			if(PlayerInfo[playerid][pPierwszy]==1)
			{
			    new d[1000];
			    strcat(d, "                          Witaj!\n");
			    strcat(d, "Znajdujesz siê na serwerze xXx v2 który w ca³oœci!\n");
			    strcat(d, "poœwiêcony jest ciê¿arówkom oraz rozwo¿eniu nimi towarów.\n");
			    strcat(d, "Spis najwa¿niejszych komend znajdziesz pod /cmd \n");
			    strcat(d, "\n\nWybierz miasto w którym chcesz siê zespawnowaæ:\n");

			    ShowPlayerDialog(playerid, TUT, DIALOG_STYLE_MSGBOX, "Informacja", d, "LS", "LV");
			    PlayerInfo[playerid][pPierwszy]=0;
			}
			else
			{
			    ShowPlayerDialog(playerid, TUT, DIALOG_STYLE_MSGBOX, "Spawn", "Witaj ponownie!\nW jakim mieœcie chcia³ byœ siê zespawnowaæ?", "LS", "LV");
			}
		}
	}
    return 1;
}

stock Koloruj(textx[])
{
	enum colorEnum
	{
		colorName[16],
		colorID[9],
	};
	new colorInfo[][colorEnum] = {
		{ "BLUE",           "{0049FF}" },
		{ "PINK",           "{E81CC9}" },
		{ "YELLOW",         "{DBED15}" },
		{ "LIGHTGREEN",     "{8CED15}" },
		{ "LIGHTBLUE",      "{15D4ED}" },
		{ "RED",            "{FF0000}" },
		{ "GREY",           "{BABABA}" },
		{ "WHITE",          "{FFFFFF}" },
		{ "ORANGE",         "{DB881A}" },
		{ "GREEN",          "{37DB45}" },
		{ "BROWN",          "{153510}" },
		{ "BLACK",          "{000000}" },
		{ "DARKGREEN",      "{6EF83C}" },
		{ "DARKBLUE",       "{1B1BE0}" },
		{ "CYAN",           "{00FFEE}" },
		{ "LIME",           "{B7FF00}" },
		{ "PURPLE",         "{7340DB}" }
	};
	new stringKOLORUJ[16+2];
	new znacznik,text[ROZMIAR_TEKSTU+32];

	strmid(text,textx,0,ROZMIAR_TEKSTU,sizeof(text));
	for(new x=0; x<sizeof(colorInfo); x++)
	{
		format(stringKOLORUJ,sizeof(stringKOLORUJ),"[%s]",colorInfo[x][colorName]);
		znacznik = strfind(text, stringKOLORUJ, true);
		if(znacznik > -1)
		{
			strdel(text, znacznik, znacznik + strlen(stringKOLORUJ));
			strins(text, colorInfo[x][colorID], znacznik,sizeof(colorInfo));
		}
	}
	return text;
}

public OnPlayerDisconnect(playerid, reason)
{
    KillTimer(LadowaniePaseczka[playerid]);
	ZapiszKonto(playerid);
	switch(reason)
	{
		case 0: format(dstring, sizeof(dstring), "%s [%d] "C_SZARY"opuœci³ serwer. Powód: crash",Nick(playerid),playerid);
		case 1: format(dstring, sizeof(dstring), "%s [%d] "C_SZARY"opuœci³ serwer. Powód: wyszed³",Nick(playerid),playerid);
		case 2: format(dstring, sizeof(dstring), "%s [%d] "C_SZARY"opuœci³ serwer. Powód: kick/ban",Nick(playerid),playerid);
	}
	SendClientMessageToAll(KOLOR_BEZOWY,dstring);
	KillTimer(TimerSchowaj[playerid]);
	PrivateCarSpawned[playerid] = 0;
 	DestroyVehicle(PrivateCar[playerid]);
    Delete3DTextLabel(PrivateCarText[playerid]);
	if(GetPVarInt(playerid,"vehB") != 0)
	DestroyVehicle(GetPVarInt(playerid,"vehB"));
	DestroyVehicle(PrivNrg[playerid]);
	return 1;
}

public GivePlayerScore(playerid, ilosc)
{
	SetPlayerScore(playerid, GetPlayerScore(playerid)+ilosc);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER)
	{
	    new playerState = GetPlayerState(playerid);
	    if (playerState == PLAYER_STATE_DRIVER)
	    {
		    new vehicleid = GetPlayerVehicleID(playerid);
		    format(dstring, sizeof(dstring), "~y~%s", GetVehicleName(vehicleid));
			TextDrawSetString(nazwawozu[playerid], dstring);


			TextDrawShowForPlayer(playerid, napisspeed[playerid]);
			TextDrawShowForPlayer(playerid, napispaliwo[playerid]);
            TextDrawShowForPlayer(playerid,Textdraw0[playerid]);
            TextDrawShowForPlayer(playerid,Textdraw2[playerid]);
            TextDrawShowForPlayer(playerid,Textdraw4[playerid]);
            TextDrawShowForPlayer(playerid,Textdraw5[playerid]);
            TextDrawShowForPlayer(playerid,Textdraw6[playerid]);
            TextDrawShowForPlayer(playerid,Textdraw7[playerid]);
            TextDrawShowForPlayer(playerid,Textdraw8[playerid]);
            TextDrawShowForPlayer(playerid,Textdraw9[playerid]);
            TextDrawShowForPlayer(playerid,Textdraw10[playerid]);

		
		    SendClientMessage(playerid, KOLOR_BIALY, ""C_BEZOWY"Aby zarz¹dzaæ pojazdem u¿yj "C_ZIELONY"/pojazd "C_BEZOWY"lub "C_ZIELONY"/p");
		    /*if(PlayerInfo[playerid][pPrawko]==1)
		    {
		        SendClientMessage(playerid, KOLOR_CZERWONY, ""C_CZERWONY"Stan prawa jazdy: "C_ZIELONY"zdane");
			}
			if(PlayerInfo[playerid][pPrawko]==0)
			{
			    SendClientMessage(playerid, KOLOR_CZERWONY, ""C_CZERWONY"Stan prawa jazdy: "C_ZIELONY"nie zdane");
			}*/
		    if(CarInfo[vehicleid][cPaliwo] <= 0)
		    {
		        SetVehicleParamsEx(vehicleid,false,lights,alarm,doors,bonnet,boot,objective);
		        TextDrawShowForPlayer(playerid, BarkPaliwa);
			}
			new cm = GetVehicleModel(vehicleid);
			if(cm==411 || cm==427 || cm==490 || cm==497 || cm==523 || cm==528 || cm==596 || cm==597 || cm==598 || cm==599 || cm==601)
			{
			    if(!ToPolicjant(playerid))
				{
				    SendClientMessage(playerid, KOLOR_CZERWONY, "Nie mo¿esz jeŸdziæ tym pojazdem!");
				    RemovePlayerFromVehicle(playerid);
				}
			}
			if(cm==443||cm==525||cm==574)
			{
			    if(!ToPomoc(playerid))
				{
				    SendClientMessage(playerid, KOLOR_CZERWONY, "Nie mo¿esz jeŸdziæ tym pojazdem!");
				    RemovePlayerFromVehicle(playerid);
				}
			}
			for(new i=0; i<POJAZDY; i++)
			{
   				if(vehicleid == PrivateCar[i])
				{
				    if(i != playerid)
				    {
				        RemovePlayerFromVehicle(playerid);
				    }
				}
			}
		}
	}
	if(newstate == PLAYER_STATE_ONFOOT)
	{

		TextDrawHideForPlayer(playerid, napisspeed[playerid]);
		TextDrawHideForPlayer(playerid, napispaliwo[playerid]);
		 TextDrawHideForPlayer(playerid,Textdraw0[playerid]);
            TextDrawHideForPlayer(playerid,Textdraw2[playerid]);
            TextDrawHideForPlayer(playerid,Textdraw4[playerid]);
            TextDrawHideForPlayer(playerid,Textdraw5[playerid]);
            TextDrawHideForPlayer(playerid,Textdraw6[playerid]);
            TextDrawHideForPlayer(playerid,Textdraw7[playerid]);
            TextDrawHideForPlayer(playerid,Textdraw8[playerid]);
            TextDrawHideForPlayer(playerid,Textdraw9[playerid]);
            TextDrawHideForPlayer(playerid,Textdraw10[playerid]);
	    DestroyVehicle(PrivNrg[playerid]);
	}
	return 1;
}

stock GetPlayerSpeed(playerid)// km/h by destroyer
{
	new Float:x,Float:y,Float:z,Float:predkosc;
	if(IsPlayerInAnyVehicle(playerid)) GetVehicleVelocity(GetPlayerVehicleID(playerid),x,y,z); else GetPlayerVelocity(playerid,x,y,z);
	predkosc=floatsqroot((x*x)+(y*y)+(z*z))*198;
	return floatround(predkosc);
}

public OnPlayerUpdate(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
	    new playerState = GetPlayerState(playerid);
    	if(playerState == PLAYER_STATE_DRIVER)
    	{
		    new ministring[10];
			//Predkosc
			new SpeedWozu[Sloty];
			SpeedWozu[playerid] = GetPlayerSpeed(playerid)/2;
			format(ministring, 10, "%dkm/h", SpeedWozu[playerid]*2);
			TextDrawSetString(napisspeed[playerid], ministring);
		}
	}
	return 1;
}

stock GetVehicleName(vehicleid)
{
	new tmp = GetVehicleModel(vehicleid) - 400;
	return nazwypojazdow[tmp];
}


public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys == 64)
	{
	    if(Laduje[playerid] == 1)
	    {
	        if(GetProgressBarValue(WagaTowaru[playerid]) < 100)
	        {
	        	SetProgressBarValue(WagaTowaru[playerid], GetProgressBarValue(WagaTowaru[playerid])+2);
	        	UpdateProgressBar(WagaTowaru[playerid], playerid);
			}
			else if(GetProgressBarValue(WagaTowaru[playerid]) == 100)
			{
			    GInfo(playerid, "~r~Wiecej nie zmiescisz w naczepie!", 3, 3);
			}
		}
	}
	if(newkeys == 256)
	{
	    if(Laduje[playerid] == 1)
	    {
		    if(GetProgressBarValue(WagaTowaru[playerid]) > 2)
	        {
	        	SetProgressBarValue(WagaTowaru[playerid], GetProgressBarValue(WagaTowaru[playerid])-2);
	        	UpdateProgressBar(WagaTowaru[playerid], playerid);
			}
			else if(GetProgressBarValue(WagaTowaru[playerid]) == 2)
			{
			    GInfo(playerid, "~r~Chcesz jechac z pusta naczepa?", 3, 3);
			}
		}
	}
	if(newkeys == 16)
	{
	    if(Laduje[playerid] == 1)
	    {
			new Float: wybranawartos = GetProgressBarValue(WagaTowaru[playerid]);
			HideProgressBarForPlayer(playerid, WagaTowaru[playerid]);
			TextDrawHideForPlayer(playerid, Wybierz);
			TextDrawHideForPlayer(playerid, Skala);
			TextDrawHideForPlayer(playerid, Info);
			HideProgressBarForPlayer(playerid, LadowanieBar[playerid]);
			TextDrawShowForPlayer(playerid, NapisPrzyLadowaniu[playerid]);


   			LadowaniePaseczka[playerid] = SetTimerEx("LadujPasek", 500, true, "d", playerid);
            GetPVarString(playerid, "WybranyToraw", NazwaTowaru, sizeof(NazwaTowaru));
            SetProgressBarValue(LadowanieBar[playerid], 0);

            format(dstring, sizeof(dstring), "Trwa ladowanie towaru, prosze czekac...");
            TextDrawSetString(NapisPrzyLadowaniu[playerid], dstring);

			new v=GetPlayerVehicleID(playerid);
			new naczepa = GetVehicleTrailer(v);
 			CarInfo[naczepa][cWaga]=floatround(wybranawartos*0.4);
 			CarInfo[naczepa][cZaladowany]=1;
  			strmid(CarInfo[naczepa][cTowar], NazwaTowaru, 0, 34, 34);
  			format(dstring, sizeof(dstring), "%d       %s", CarInfo[naczepa][cWaga], CarInfo[naczepa][cTowar]);
  			SendClientMessage(playerid, KOLOR_ZIELONY, dstring);
  			Laduje[playerid] = 0;
  			CarInfo[naczepa][cWyladuj]=180;
		}
	}
	return 1;
}

stock GInfo(playerid,text[],typ,czas)
{
	GameTextForPlayer(playerid,text,czas*1000,typ);
	return 1;
}

stock DoInRange(playerid, Float:x, Float:y, Float:z, Float: radi)//sprawdza odleglosc od miejsca
{
	if(IsPlayerInRangeOfPoint(playerid, radi, x, y, z)) return 1;
	return 0;
}

forward LadujPasek(playerid);
public LadujPasek(playerid)
{
    SetProgressBarValue(LadowanieBar[playerid], GetProgressBarValue(LadowanieBar[playerid])+1);
    UpdateProgressBar(LadowanieBar[playerid], playerid);
    if(GetProgressBarValue(LadowanieBar[playerid]) == 100)
    {
		KillTimer(LadowaniePaseczka[playerid]);
		TogglePlayerControllable(playerid,1);
		HideProgressBarForPlayer(playerid, LadowanieBar[playerid]);
		TextDrawHideForPlayer(playerid, NapisPrzyLadowaniu[playerid]);
		Laduje[playerid] = 0;
	}
    return 1;
}

public ZapiszKonto(playerid)
{
	new file[128];
	format(file, sizeof(file), KONTA, Nick(playerid));
	DOF_SetInt(file, "Lider", PlayerInfo[playerid][pLider]);
	DOF_SetInt(file, "Frakcja", PlayerInfo[playerid][pFrakcja]);
	DOF_SetInt(file, "Kasa", GetPlayerMoneyEx(playerid));
	DOF_SetInt(file, "Score", GetPlayerScore(playerid));
	DOF_SetInt(file, "Admin", PlayerInfo[playerid][pAdmin]);
	DOF_SetInt(file, "Mute", PlayerInfo[playerid][pMute]);
	DOF_SetInt(file, "Warn", PlayerInfo[playerid][pWarn]);
	DOF_SetInt(file, "Punkty", PlayerInfo[playerid][pPunkty]);
	DOF_SetInt(file, "Premium", PlayerInfo[playerid][pPremium]);
	DOF_SetInt(file, "Kredyt", PlayerInfo[playerid][pKredyt]);
	DOF_SetInt(file, "Prawko", PlayerInfo[playerid][pPrawko]);
	DOF_SetInt(file, "Blok", PlayerInfo[playerid][pBlok]);
	DOF_SetInt(file, "DJ", PlayerInfo[playerid][pDJ]);
	DOF_SetString(file, "Tag", PlayerInfo[playerid][pTag]);
	DOF_SetInt(file, "Dowiozl", PlayerInfo[playerid][pDowiozl]);
	DOF_SetInt(file, "Potrzeba", PlayerInfo[playerid][pPotrzeba]);
 	DOF_SetInt(file, "Poziom", PlayerInfo[playerid][pPoziom]);
	DOF_SetInt(file, "Mandaty", PlayerInfo[playerid][pMandaty]);
	DOF_SetInt(file, "MandatyPotrzeba", PlayerInfo[playerid][pMandatyPotrzeba]);
	DOF_SetInt(file, "MandatyPoziom", PlayerInfo[playerid][pMandatyPoziom]);
	
	DOF_SetInt(file, "Color", PlayerInfo[playerid][pColor]);
	DOF_SetFloat(file, "X", PlayerInfo[playerid][pX]);
	DOF_SetFloat(file, "Y", PlayerInfo[playerid][pY]);
	DOF_SetFloat(file, "Z", PlayerInfo[playerid][pZ]);
	DOF_SetFloat(file, "Ang", PlayerInfo[playerid][pAng]);
	DOF_SetFloat(file, "Model", PlayerInfo[playerid][pModel]);

	DOF_SaveFile();
	return 1;
}

IsNumeric(const numericstring[])
{
	for (new i = 0, j = strlen(numericstring); i < j; i++)
	{
		if (numericstring[i] > '9' || numericstring[i] < '0') return 0;
	}
	return 1;
}

stock Nick(playerid)//zwraca nick
{
	new nick[MAX_PLAYER_NAME];
	GetPlayerName(playerid, nick, sizeof(nick));
	return nick;
}

forward NapisText(text[]);//wyswietla napis
public NapisText(text[])
{
	if(NapisUzywany==1)
	{
		TextDrawHideForAll(Napis);
		KillTimer(NapisTimer);
	}
	NapisUzywany=1;
	TextDrawSetString(Napis,text);
	TextDrawShowForAll(Napis);
 	NapisTimer=SetTimer("NapisWylacz",20000,false);
	return 1;
}

forward NapisWylacz();//wylacza
public NapisWylacz()
{
    NapisUzywany=0;
    TextDrawHideForAll(Napis);
    KillTimer(NapisTimer);
    return 1;
}

stock JakiSalon(playerid)//sprawdza nam stacje paliw na jakiej jestesmy i zwraca jej id
{
    for(new nr = 0; nr < ILOSC_SALONOW; nr++)
	{
	    if(DoInRange(playerid, Salon[nr][0],Salon[nr][1],Salon[nr][2],16.0))
	    {
	        return nr;
	    }
	}
	return 99;
}

stock WSalonie(playerid)//sprawdza czy wogóle jestesmy w salonie
{
    if(IsPlayerConnected(playerid))
	{
		if(	DoInRange(playerid, -1649.2557,	1208.9857,	7.2500,		16.0)||
			DoInRange(playerid, 2131.7266,	-1150.7349,	24.1237,	16.0)||
			DoInRange(playerid, -1957.8857,	304.9976,	35.4688,	16.0))
		{
			return 1;
		}
 	}
	return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == PANEL_DJ && response)
	{
	    foreach(Player, i)
		{
			StopAudioStreamForPlayer(i);
			PlayAudioStreamForPlayer(i, inputtext);
		}
	}
	if(dialogid == GUI_SALON && response)
	{
	    if(GetPlayerMoney(playerid) >= WozyID[listitem][1])
	    {
	        format(dstring, sizeof(dstring), "Wybra³eœ pojazd %s który kosztuje %d.\n\nNa pewno chcesz go kupiæ?", WozyNazwa[listitem], WozyID[listitem][1]);
            ShowPlayerDialog(playerid, GUI_SALON2, DIALOG_STYLE_MSGBOX, "Pojazd - kupno", dstring, "Kupujê", "Rezygnujê");
			kupuje[playerid]=listitem;
		}
	    else
	        SendClientMessage(playerid, KOLOR_CZERWONY, "Nie staæ Ciê na ten pojazd!");
	}
	if(dialogid == GUI_SALON2 && response)
	{
		GivePlayerMoney(playerid, -WozyID[kupuje[playerid]][1]);
	    new salonek = JakiSalon(playerid);
	    PlayerInfo[playerid][pModel]=WozyID[kupuje[playerid]][0];
	    PlayerInfo[playerid][pX]=Salon[salonek][3];
	    PlayerInfo[playerid][pY]=Salon[salonek][4];
	    PlayerInfo[playerid][pZ]=Salon[salonek][5];
	    PlayerInfo[playerid][pAng]=Salon[salonek][6];
	    new losujkolor = random(ILOSC_KOLOROW);
	    PlayerInfo[playerid][pColor]=losujkolor;
	    ZapiszKonto(playerid);
	    //spawnowanie pojazdu
	    PrivateCarSpawned[playerid] = 1;
	    PrivateCar[playerid] = AddStaticVehicleEx(PlayerInfo[playerid][pModel], PlayerInfo[playerid][pX], PlayerInfo[playerid][pY], PlayerInfo[playerid][pZ], PlayerInfo[playerid][pAng], PlayerInfo[playerid][pColor], PlayerInfo[playerid][pColor], SPAWN);
        SendClientMessage(playerid, KOLOR_ZIELONY, "Twój prywatny pojazd zosta³ zespawnowany!");
        format(dstring, sizeof(dstring), ""C_CZERWONY"Prywatny Pojazd\n"C_ZIELONY"Nick: "C_ZOLTY"%s\n"C_ZIELONY"ID: "C_ZOLTY"%d", Nick(playerid), playerid);
        PrivateCarText[playerid] = Create3DTextLabel(dstring,0x008080FF,30.0,40.0,50.0,40.0,0);
        Attach3DTextLabelToVehicle(PrivateCarText[playerid], PrivateCar[playerid], 0.0, 0.0, 0.0);
        SetVehicleParamsEx(PrivateCar[playerid],false,false,false,false,false,false,false);
		CarInfo[PrivateCar[playerid]][cPaliwo]=100;
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Pojazd - kupno","Gratulujê!\nUda³o Ci siê kupiæ prywatny pojazd.\nAby nim zarz¹dzaæ wpisz /carmenu.","Rozumiem","");
	}
	if(dialogid == GUI_STACJA && response)
	{
		if(IsNumeric(inputtext))
		{
		    new v=GetPlayerVehicleID(playerid);
		    new ast=StacjaPaliw(playerid);
		    if((CarInfo[v][cPaliwo]+strval(inputtext)) > 100)
			{
			    format(dstring, sizeof(dstring), ""C_ZOLTY"Witaj na stacji benzynowej!\n"C_ZIELONY"Do pe³nego baku brakuje Tobie: %d litr/ów.\n1 litr kosztuje ??\n"C_ZOLTY"Ile litrów chcesz zatankowaæ?",100-CarInfo[v][cPaliwo],stacja[ast][3]);
				ShowPlayerDialog(playerid,GUI_STACJA,DIALOG_STYLE_INPUT,""C_POMARANCZOWY"Tankowanie",dstring,"Tankuj","Zamknij");
				return 0;
			}
			new dolano = strval(inputtext);
			CarInfo[v][cPaliwo]+=dolano;
			new zaplata = floatround(stacja[ast][3]*dolano);
			GivePlayerMoneyEx(playerid, -zaplata);
			format(dstring, sizeof(dstring), ""C_ZOLTY"Zatankowa³eœ "C_ZIELONY"%d "C_ZOLTY"litr/ów za "C_ZIELONY" %d$\n"C_ZOLTY"Poziom twojego baku wynosi: "C_ZIELONY"%d"C_ZOLTY"/"C_ZIELONY"100 "C_ZOLTY"l",dolano,zaplata,CarInfo[v][cPaliwo]);
			ShowPlayerDialog(playerid,0,DIALOG_STYLE_MSGBOX,"Stacja paliw info", dstring, "Rozumiem", "");
		}
	}
	if(dialogid == GUI_BANK)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0:
	            {
	                format(dstring, sizeof(dstring), ""C_ZOLTY"Stan twojego konta wynosi "C_ZIELONY"%d "C_ZOLTY"dolarów", GetPlayerMoneyEx(playerid));
					ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Bank - stan konta", dstring, "Rozumiem", "");
				}
				case 1:
				{
				    ShowPlayerDialog(playerid, GUI_BANK+1, DIALOG_STYLE_INPUT, "Bank - przelew (1/2)", "Podaj ID gracza któremu chcesz przelaæ pieni¹dze!", "Gotowe", "Anuluj");
				}
				case 2:
				{
				    if(PlayerInfo[playerid][pKredyt] == 0)
				    {
					    new dd[1000];
					    strcat(dd, "1. Kwota na jak¹ mo¿esz wzi¹œæ kredyt jest równa po³owie aktualnego twojego stanu konta.\n");
					    strcat(dd, "2. Pieni¹dze nale¿y sp³aciæ do wyjœcia z serwera.\n");
					    strcat(dd, "3. HTBank udziela po¿yczek o oprocentowaniu 5%.\n");
					    strcat(dd, "4. W razie braku sp³aty do wyjœcia z serwera kwota nale¿na jest pobierana automatycznie wraz z kar¹ 3000$\n");
					    strcat(dd, "5. HTBank nie ponosi odpowiedzialnoœci za crashe, kicki lub restarty wszelkiego rodzaju. Pieni¹dze nie s¹ do zwrotu\n");
					    strcat(dd, "6. Gracz mo¿e posiadaæ tylko jeden kredyt jednoczeœnie\n");
					    strcat(dd, "7. HTBank nie przyjmuje sp³at od innego gracza za kredytobiorcê\n");
					    ShowPlayerDialog(playerid, GUI_BANK+3, DIALOG_STYLE_MSGBOX, "Bank - porzyczka (zasady)", dd, "Rozumiem", "Rezygnujê");
					}
					else
					{
					    ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Bank - porzyczka (b³¹d)", "Juz masz kredyt na serwerze!", "Rozumiem", "");
					}
				}
				case 3:
				{
				    if(PlayerInfo[playerid][pKredyt] > 0)
				    {
						new splata = (PlayerInfo[playerid][pKredyt]/100)*5;
						GivePlayerMoney(playerid, -splata-PlayerInfo[playerid][pKredyt]);
					}
					else
					    ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Sp³ata kredytu", "Nie posiadasz kredytu gotówkowego w HTBank!", "Rozumiem", "");
				}
			}
		}
	}
	if(dialogid == GUI_BANK+3)
	{
	    if(response)
	    {
	        ShowPlayerDialog(playerid, GUI_BANK+4, DIALOG_STYLE_INPUT, "Bank - porzczka (kwota)", "Wpisz kwotê jak¹ chcesz porzyczyæ.\nPamiêtaj ¿e nie mo¿e byæ ona wiêksza ni¿ po³owa\nAktualnego stanu twojego konta.", "Akceptuj", "Anuluj");
		}
		if(!response)
		{
		    ShowPlayerDialog(playerid, 0, DIALOG_STYLE_INPUT, "Bank - porzczka (zasady)", "Nie zaakceptowa³eœ regulaminu wiêc nie mo¿esz po¿yczyæ kasy!", "Ok", "");
		}
	}
	
	if(dialogid == GUI_BANK+4)
	{
	    if(response)
	    {
	        if(IsNumeric(inputtext))
	        {
	            if(!isnull(inputtext))
	            {
		            if(GetPlayerMoneyEx(playerid) > strval(inputtext))
		            {
						PlayerInfo[playerid][pKredyt] = strval(inputtext);
						GivePlayerMoneyEx(playerid, PlayerInfo[playerid][pKredyt]);
						ZapiszKonto(playerid);
						format(dstring, sizeof(dstring), "Gratulujê!\nWzi¹³eœ kredyt gotówkowy w wysokoœci %d.\nMusisz sp³aciæ 105% wartoœci kredytu zanim wyjdziesz z serwera komend¹ /bank!\n\nPozdrawiamy\nHTBank");
						ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Bank - porzczka (finalizacja)", dstring, "Rozumiem", "");
					}
					else
					{
					    ShowPlayerDialog(playerid, 0, DIALOG_STYLE_INPUT, "Bank - porzczka (kwota)", "Za du¿¹ kwotê wpisa³eœ!", "Aha... super!", "");
					}
				}
				else
				{
				    ShowPlayerDialog(playerid, GUI_BANK+4, DIALOG_STYLE_INPUT, "Bank - porzczka (kwota)", "Wpisz kwotê jak¹ chcesz porzyczyæ.\nPamiêtaj ¿e nie mo¿e byæ ona wiêksza ni¿ po³owa\nAktualnego stanu twojego konta.\n\nNic nie wpisa³eœ!", "Akceptuj", "Anuluj");
				}
	        }
		}
	}
	    
	if(dialogid == GUI_BANK+1)
	{
	    if(!isnull(inputtext))
     	{
		    if(IsNumeric(inputtext))
		    {
		        new player = strval(inputtext);
		        if(IsPlayerConnected(player))
		        {
		            if(!isnull(inputtext))
		            {
			            ShowPlayerDialog(playerid, GUI_BANK+2, DIALOG_STYLE_INPUT, "Bank - przelew (2/2)", "Podaj kwotê jak¹ chcesz przelaæ graczowi!", "Przelej", "Anuluj");
			            przelew[playerid] = player;
					}
					else
					{
					    ShowPlayerDialog(playerid, GUI_BANK+1, DIALOG_STYLE_INPUT, "Bank - przelew (1/2)", "Podaj ID gracza któremu chcesz przelaæ pieni¹dze!\n\nNic nie wpisa³eœ!", "Gotowe", "Anuluj");
					}
		        }
		        else
		        {
		            ShowPlayerDialog(playerid, GUI_BANK+1, DIALOG_STYLE_INPUT, "Bank - przelew (1/2)", "Podaj ID gracza któremu chcesz przelaæ pieni¹dze!\n\nNie ma takiego gracza!", "Gotowe", "Anuluj");
				}
		    }
		    else
			{
			    ShowPlayerDialog(playerid, GUI_BANK+1, DIALOG_STYLE_INPUT, "Bank - przelew (1/2)", "Podaj ID gracza któremu chcesz przelaæ pieni¹dze!\n\nPodany tekst nie jest liczb¹!", "Gotowe", "Anuluj");
			}
        }
		else
		{
  			ShowPlayerDialog(playerid, GUI_BANK+1, DIALOG_STYLE_INPUT, "Bank - przelew (1/2)", "Podaj ID gracza któremu chcesz przelaæ pieni¹dze!\n\nNic nie wpisa³eœ!", "Gotowe", "Anuluj");
		}
	}
	if(dialogid == GUI_BANK+2)
	{
	    if(!isnull(inputtext))
	    {
		    if(IsNumeric(inputtext))
		    {
				new kwota = strlen(inputtext);
				if(GetPlayerMoneyEx(playerid) >= kwota)
				{
				    new przelanko;
				    przelanko = (kwota/100)*5;
				    kwota-=przelanko;
				    GivePlayerMoneyEx(playerid, -kwota);
				    GivePlayerMoneyEx(przelew[playerid], kwota);
				    format(dstring, sizeof(dstring), "Przela³eœ graczowi %s[%d] pieni¹dze o wartoœci %d$.\nZosta³a pobrana prowizja za us³ugi HTBank w wysokoœci 5%.\n\nDziêkujemy za skorzystanie z naszych us³ug.\nHTBank Sp. Z.o.o", Nick(przelew[playerid]), przelew[playerid], kwota+przelanko);
	                ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Bank - przelew (zakonczony)", dstring, "Rozumiem", "");
				    format(dstring, sizeof(dstring), "Gracz %s[%d] przela³ na twoje konto %d$.\nZosta³a pobrana prowizja za us³ugi HTBank w wysokoœci 5%.\n\nDziêkujemy za skorzystanie z naszych us³ug.\nHTBank Sp. Z.o.o", Nick(playerid), playerid, kwota+przelanko);
	                ShowPlayerDialog(przelew[playerid], 0, DIALOG_STYLE_MSGBOX, "Bank - przelew", dstring, "Rozumiem", "");
				}
				else
				{
				    ShowPlayerDialog(playerid, GUI_BANK+2, DIALOG_STYLE_INPUT, "Bank - przelew (2/2)", "Podaj kwotê jak¹ chcesz przelaæ graczowi!\n\nNie posiadasz tyle pieniêdzy!", "Przelej", "Anuluj");
				}
		    }
		    else
			{
	  			ShowPlayerDialog(playerid, GUI_BANK+2, DIALOG_STYLE_INPUT, "Bank - przelew (2/2)", "Podaj kwotê jak¹ chcesz przelaæ graczowi!\n\nle wpisana kwota!", "Przelej", "Anuluj");
			}
		}
		else
		{
		    ShowPlayerDialog(playerid, GUI_BANK+2, DIALOG_STYLE_INPUT, "Bank - przelew (2/2)", "Podaj kwotê jak¹ chcesz przelaæ graczowi!\n\nNic nie wpisa³eœ!", "Przelej", "Anuluj");
		}
	}
	if(dialogid == PREMIUM)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0:
	            {
	                if(GetPremium(playerid) >= 5)
	                {
	                	WezPremium(playerid, 5);
	                	new vehicleid = GetPlayerVehicleID(playerid);
						RepairVehicle(vehicleid);
						SetVehicleHealth(vehicleid,1000.0);
						SendClientMessage(playerid, KOLOR_ZIELONY, "Pojazd naprawiony!");
					}
				}
				case 1:
	            {
	                if(GetPremium(playerid) >= 7)
	                {
	                	WezPremium(playerid, 7);
	                	new vehicleid = GetPlayerVehicleID(playerid);
						CarInfo[vehicleid][cPaliwo]=100;
						SendClientMessage(playerid, KOLOR_ZIELONY, "Pojazd zatankowany!");
					}
				}
				case 2:
				{
	                if(GetPremium(playerid) >= 30)
	                {
	                	WezPremium(playerid, 30);
	                	new Float: Pos[4];
	                	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	                	GetPlayerFacingAngle(playerid, Pos[3]);
	                	AddStaticVehicleEx(522, Pos[0], Pos[1], Pos[2], Pos[3], -1, -1, SPAWN);
					}
				}
			}
		}
	}
	if(dialogid == TUT)
	{
	    if(response)
	    {
	        SetPlayerPos(playerid,  1730.8868,-1951.05499,14.1187);
		}
		else
		{
            SetPlayerPos(playerid, 1601.8958,1617.3088,10.8209);
		}
	}
	if(dialogid == GUI_POJAZD_PRYWATNY)
	{
		if(response)
		{
			switch(listitem)
			{
			    case 0:
			    {
			        new Float: Pos[4];
			        GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
			        GetPlayerFacingAngle(playerid, Pos[3]);
			        PlayerInfo[playerid][pX] = Pos[0];
			        PlayerInfo[playerid][pY] = Pos[1];
			        PlayerInfo[playerid][pZ] = Pos[2];
			        PlayerInfo[playerid][pAng] = Pos[3];
			        DestroyVehicle(PrivateCar[playerid]);
			        PrivateCar[playerid] = CreateVehicle(PlayerInfo[playerid][pModel], Pos[0], Pos[1], Pos[2], Pos[3], PlayerInfo[playerid][pColor], PlayerInfo[playerid][pColor], SPAWN);
					PutPlayerInVehicle(playerid, PrivateCar[playerid], 0);
			    }
			    case 1:
			    {
			        ShowPlayerDialog(playerid, GUI_POJAZD_COLOR, DIALOG_STYLE_LIST, ""C_ZOLTY"Zarz¹dzanie pojazdem - zmiana koloru "C_ZIELONY"500$ "C_ZOLTY"ka¿da zmiana", "Czarny\nBialy\nCzerwony\nNiebieski\nB³êkitny\nFioletowy\nZielony\nRó¿owy", "Zmien", "Anuluj");
			    }
			    case 2:
			    {
			        SetVehicleToRespawn(PrivateCar[playerid]);
				}
				case 3:
				{
				    PrivateCarSpawned[playerid] = 0;
				    DestroyVehicle(PrivateCar[playerid]);
					SendClientMessage(playerid, KOLOR_ZIELONY, "Pojazd zosta³ odes³any!");
				}
			}
		}
	}
	if(dialogid == GUI_POJAZD_COLOR)
	{
	    if(response)
	    {
	        ChangeVehicleColor(PrivateCar[playerid], ZmienKolor[listitem][0], ZmienKolor[listitem][0]);
	        PlayerInfo[playerid][pColor]=ZmienKolor[listitem][0];
		}
	}
	if(dialogid == GUI_GPS)
	{
	    if(response)
	    {
	        SetPlayerCheckpoint(playerid, Zaladunki[listitem][0],Zaladunki[listitem][1],Zaladunki[listitem][2], 5);
            PlayAudioStreamForPlayer(playerid, Glosy[listitem][1]);
		}
		if(!response)
		{
		    DisablePlayerCheckpoint(playerid);
		}
	}
	if(dialogid == GUI_LOGIN)
	{
	    if(response)
	    {
			if(!isnull(inputtext))
			{
				new file[128];
 				format(file,sizeof(file),KONTA,Nick(playerid));
				if(strcmp(DOF_GetString(file, "Haslo"),inputtext,true))
				{
			 		ShowPlayerDialog(playerid, GUI_LOGIN, DIALOG_STYLE_PASSWORD, "xXx v2", "Podane has³o jest nie prawid³owe!\n\n\nWpisz poni¿ej has³o jakie poda³eœ przy rejestracji:", "Zaloguj", "WyjdŸ");
				}
				else if(!strcmp(DOF_GetString(file, "Haslo"),inputtext,true))
				{
				    PlayerInfo[playerid][pPierwszy] = 0;
					Zalogowany[playerid] = 1;
					PlayerInfo[playerid][pHaslo] = DOF_GetString(file, "Haslo");
				    PlayerInfo[playerid][pFrakcja] = DOF_GetInt(file, "Frakcja");
				    PlayerInfo[playerid][pLider] = DOF_GetInt(file, "Lider");
				    PlayerInfo[playerid][pKasa] = DOF_GetInt(file, "Kasa");
				    PlayerInfo[playerid][pScore] = DOF_GetInt(file, "Score");
				    PlayerInfo[playerid][pAdmin] = DOF_GetInt(file, "Admin");
				    PlayerInfo[playerid][pMute] = DOF_GetInt(file, "Mute");
				    PlayerInfo[playerid][pWarn] = DOF_GetInt(file, "Warn");
				    PlayerInfo[playerid][pPunkty] = DOF_GetInt(file, "Punkty");
				    PlayerInfo[playerid][pPremium] = DOF_GetInt(file, "Premium");
				    PlayerInfo[playerid][pKredyt] = DOF_GetInt(file, "Kredyt");
				    PlayerInfo[playerid][pPrawko] = DOF_GetInt(file, "Prawko");
				    PlayerInfo[playerid][pBlok] = DOF_GetInt(file, "Blok");
				    PlayerInfo[playerid][pDJ] = DOF_GetInt(file, "DJ");
				    strmid(PlayerInfo[playerid][pTag], DOF_GetString(file, "Tag"), 0, 34, 34);
				    //Prywatny pojazd
				    PlayerInfo[playerid][pX] = DOF_GetFloat(file, "X");
				    PlayerInfo[playerid][pY] = DOF_GetFloat(file, "Y");
				    PlayerInfo[playerid][pZ] = DOF_GetFloat(file, "Z");
				    PlayerInfo[playerid][pAng] = DOF_GetFloat(file, "Ang");
				    PlayerInfo[playerid][pModel] = DOF_GetInt(file, "Model");
				    PlayerInfo[playerid][pColor] = DOF_GetInt(file, "Color");
				    //Osi¹gniêcia
			    	PlayerInfo[playerid][pDowiozl] = DOF_GetInt(file, "Dowiozl");
					PlayerInfo[playerid][pPotrzeba] = DOF_GetInt(file, "Potrzeba");
                    PlayerInfo[playerid][pPoziom] = DOF_GetInt(file, "Poziom");
                    PlayerInfo[playerid][pMandaty] = DOF_GetInt(file, "Mandaty");
                    PlayerInfo[playerid][pMandatyPotrzeba] = DOF_GetInt(file, "MandatyPotrzeba");
                    PlayerInfo[playerid][pMandatyPoziom] = DOF_GetInt(file, "MandatyPoziom");
                    
                    SetPlayerScore(playerid, PlayerInfo[playerid][pScore]);
                    GivePlayerMoneyEx(playerid, PlayerInfo[playerid][pKasa]);
                    
                    if(PlayerInfo[playerid][pBlok] > 0)
                    {
						GInfo(playerid, "~r~To konto jest zablokowane!", 3, 100);
						SendClientMessage(playerid, KOLOR_CZERWONY, "To konto zosta³o zablokowane. Wybierz inny nick!");
                        Kick(playerid);
                        return 0;
					}
                    
                    if(PlayerInfo[playerid][pKredyt] > 0)
                    {
                        new splata = ((PlayerInfo[playerid][pKredyt]/100)*5)+PlayerInfo[playerid][pKredyt];
                        GivePlayerMoneyEx(playerid, -splata+3000);
                        format(dstring, sizeof(dstring), "UWAGA!\nPodczas poprzedniej wizyty na serwerze zaci¹gn¹³eœ kredyt w wysokoœci %d$.\nNie zosta³ on sp³acony wiêc byliœmy zmuszeni sami go odebraæ!\nPobraliœmy 105% kredytu + 3000$ grzywny.\n\nPozdrawiamy\nHTBank");
                        PlayerInfo[playerid][pKredyt]=0;
					}
				}
			}
			else
			    ShowPlayerDialog(playerid, GUI_LOGIN,DIALOG_STYLE_PASSWORD, "xXx v2", "Nic nie wpisa³eœ!\n\n\nWybierz has³o jakie u¿y³eœ podczas rejestracji:", "Zaloguj", "WyjdŸ");
			return 1;
	    }
	    if(!response)
	        Kick(playerid);
	}
 	if(dialogid == GUI_REGISTER)
	{
		if(!response) return Kick(playerid);
		if(isnull(inputtext))
		{
			ShowPlayerDialog(playerid, GUI_REGISTER,DIALOG_STYLE_PASSWORD, "xXx v2 - Rejestracja", "Nic nie wpisa³eœ!\n\n\nWybierz has³o jakiego bêdziesz u¿ywaæ podczas gry:", "Rejestruj", "WyjdŸ");
			return 1;
		}
		if(strlen(inputtext)<5||strlen(inputtext)>15)
		{
			ShowPlayerDialog(playerid, GUI_REGISTER,DIALOG_STYLE_PASSWORD, "xXx v2 - Rejestracja", "Has³o jest za krótkie lub za d³ugie!\nPowino sk³adac siê od 4 do 14 znaków!\n\n\nWybierz has³o jakiego bêdziesz u¿ywaæ podczas gry:", "Rejestruj", "WyjdŸ");
			return 1;
		}
		new file[128];
	 	format(file,sizeof(file),KONTA,Nick(playerid));
	 	DOF_CreateFile(file);
	 	DOF_SetString(file, "Haslo", inputtext);
	 	DOF_SetInt(file, "Frakcja", PlayerInfo[playerid][pFrakcja]);
	 	DOF_SetInt(file, "Kasa", PlayerInfo[playerid][pKasa]);
	 	DOF_SetInt(file, "Score", PlayerInfo[playerid][pScore]);
	 	DOF_SetInt(file, "Lider", PlayerInfo[playerid][pLider]);
	 	DOF_SetInt(file, "Admin", PlayerInfo[playerid][pAdmin]);
	 	DOF_SetInt(file, "Mute", PlayerInfo[playerid][pMute]);
	 	DOF_SetInt(file, "Warn", PlayerInfo[playerid][pWarn]);
	 	DOF_SetInt(file, "Punkty", PlayerInfo[playerid][pPunkty]);
	 	DOF_SetInt(file, "Premium", PlayerInfo[playerid][pPremium]);
	 	DOF_SetInt(file, "Kredyt", PlayerInfo[playerid][pKredyt]);
	 	DOF_SetInt(file, "Prawko", PlayerInfo[playerid][pPrawko]);
	 	DOF_SetInt(file, "Blok", PlayerInfo[playerid][pBlok]);
	 	DOF_SetInt(file, "DJ", PlayerInfo[playerid][pDJ]);
        PlayerInfo[playerid][pPierwszy] = 0;
	 	DOF_SetString(file, "Tag", "[gracz]");
	 	strmid(PlayerInfo[playerid][pTag], "[gracz]", 0, 34, 34);
	 	//pojazd
   		DOF_SetFloat(file, "X", PlayerInfo[playerid][pX]);
	    DOF_SetFloat(file, "Y", PlayerInfo[playerid][pY]);
	    DOF_SetFloat(file, "Z", PlayerInfo[playerid][pZ]);
	    DOF_SetFloat(file, "Ang", PlayerInfo[playerid][pAng]);
	    DOF_SetInt(file, "Model", PlayerInfo[playerid][pModel]);
		DOF_SetInt(file, "Color", PlayerInfo[playerid][pColor]);
	    //osi¹gniêcia
	 	DOF_SetInt(file, "Dowiozl", 0);
	 	PlayerInfo[playerid][pDowiozl]=0;
		DOF_SetInt(file, "Potrzeba", 2);
		PlayerInfo[playerid][pPotrzeba]=30;
		DOF_SetInt(file, "Poziom", 1);
		PlayerInfo[playerid][pPoziom]=1;
 		DOF_SetInt(file, "Mandaty", 0);
	 	PlayerInfo[playerid][pMandaty]=0;
		DOF_SetInt(file, "MandatyPotrzeba", 10);
		PlayerInfo[playerid][pMandatyPotrzeba]=10;
		DOF_SetInt(file, "MandatyPoziom", 1);
		PlayerInfo[playerid][pMandatyPoziom]=1;
		
	 	Zalogowany[playerid] = 1;
	 	GivePlayerMoneyEx(playerid, 500);
		return 1;
	}
	if(dialogid == GUI_ZALADUNEK)
	{
	    if(response)
	    {
    		if(ToST(playerid) || ToET(playerid) || ToRT(playerid))
	        {
				Laduje[playerid] = 1;
				Zaladowany[playerid] = 0;
				ShowProgressBarForPlayer(playerid, WagaTowaru[playerid]);
				SetProgressBarValue(WagaTowaru[playerid], 50);
				UpdateProgressBar(WagaTowaru[playerid], playerid);
				TextDrawShowForPlayer(playerid, Wybierz);
				TextDrawShowForPlayer(playerid, Skala);
				TextDrawShowForPlayer(playerid, Info);
				SetPVarString(playerid, "WybranyToraw", ListaTowarowFirma2[listitem]);
				TogglePlayerControllable(playerid,0);
			}
			else
	        {
				Laduje[playerid] = 1;
				Zaladowany[playerid] = 0;
				ShowProgressBarForPlayer(playerid, WagaTowaru[playerid]);
				SetProgressBarValue(WagaTowaru[playerid], 50);
				UpdateProgressBar(WagaTowaru[playerid], playerid);
				TextDrawShowForPlayer(playerid, Wybierz);
				TextDrawShowForPlayer(playerid, Skala);
				TextDrawShowForPlayer(playerid, Info);
				SetPVarString(playerid, "WybranyToraw", ListaTowarow2[listitem]);
				TogglePlayerControllable(playerid,0);
			}
		}
	}
	if(dialogid == GUI_POJAZD)
	{
		if(!response) return 1;
		new v;
		switch(listitem)
		{
			case 0:
			{
				if(GetPlayerState(playerid)!=PLAYER_STATE_DRIVER)
				{
					SendClientMessage(playerid, KOLOR_CZERWONY,""C_CZERWONY"Nie jesteœ kierowc¹ pojazdu!");
					return 1;
				}
				v=GetPlayerVehicleID(playerid);
				GetVehicleParamsEx(v,engine,lights,alarm,doors,bonnet,boot,objective);
				if(engine)
				{
					GInfo(playerid,"~w~silnik ~r~wylaczony",3,3);
					SetVehicleParamsEx(v,false,lights,alarm,doors,bonnet,boot,objective);
				}
				else
				{
					if(CarInfo[v][cPaliwo] <= 0)
						return SendClientMessage(playerid, KOLOR_CZERWONY, "Brak paliwa!");
					SetTimerEx("SilnikUruchom",3000,false,"i",playerid);
					GInfo(playerid,"~w~uruchamianie silnika",3,3);
				}
				return 1;
			}
			case 1:
			{
				if(GetPlayerState(playerid)!=PLAYER_STATE_DRIVER)
				{
					SendClientMessage(playerid, KOLOR_CZERWONY,""C_CZERWONY"Nie jesteœ kierowc¹ pojazdu!");
					return 1;
				}
				v=GetPlayerVehicleID(playerid);
				GetVehicleParamsEx(v,engine,lights,alarm,doors,bonnet,boot,objective);
				if(lights)
				{
					GInfo(playerid,"~w~lampy ~r~wylaczone",3,3);
					SetVehicleParamsEx(v,engine,false,alarm,doors,bonnet,boot,objective);
					if(GetVehicleModel(v)==403||GetVehicleModel(v)==514||GetVehicleModel(v)==515)
					{
						if(GetVehicleTrailer(v)!=0)
						{
							SetVehicleParamsEx(GetVehicleTrailer(v),engine,false,alarm,doors,bonnet,boot,objective);
						}
					}
				}
				else
				{
					GInfo(playerid,"~w~lampy ~g~wlaczone",3,3);
					SetVehicleParamsEx(v,engine,true,alarm,doors,bonnet,boot,objective);
					if(GetVehicleModel(v)==403||GetVehicleModel(v)==514||GetVehicleModel(v)==515)
					{
						if(GetVehicleTrailer(v)!=0)
						{
							SetVehicleParamsEx(GetVehicleTrailer(v),engine,true,alarm,doors,bonnet,boot,objective);
						}
					}
				}
				return 1;
			}
			case 2:
			{
				if(GetPlayerState(playerid)!=PLAYER_STATE_DRIVER)
				{
					SendClientMessage(playerid, KOLOR_CZERWONY,""C_CZERWONY"Nie jesteœ kierowc¹ pojazdu!");
					return 1;
				}
				v=GetPlayerVehicleID(playerid);
				GetVehicleParamsEx(v,engine,lights,alarm,doors,bonnet,boot,objective);
				if(bonnet)
				{
					GInfo(playerid,"~w~maska ~r~zamknieta",3,3);
					SetVehicleParamsEx(v,engine,lights,alarm,doors,false,boot,objective);
				}
				else
				{
					GInfo(playerid,"~w~maska ~g~otwarta",3,3);
					SetVehicleParamsEx(v,engine,lights,alarm,doors,true,boot,objective);
				}
				return 1;
			}
			case 3:
			{
				if(GetPlayerState(playerid)!=PLAYER_STATE_DRIVER)
				{
					SendClientMessage(playerid, KOLOR_CZERWONY,""C_CZERWONY"Nie jesteœ kierowc¹ pojazdu!");
					return 1;
				}
				v=GetPlayerVehicleID(playerid);
				GetVehicleParamsEx(v,engine,lights,alarm,doors,bonnet,boot,objective);
				if(boot)
				{
					GInfo(playerid,"~w~bagaznik ~r~zamkniety",3,3);
					SetVehicleParamsEx(v,engine,lights,alarm,doors,bonnet,false,objective);
				}
				else
				{
					GInfo(playerid,"~w~bagaznik ~g~otwarty",3,3);
					SetVehicleParamsEx(v,engine,lights,alarm,doors,bonnet,true,objective);
				}
				return 1;
			}
			case 4:
			{
				if(GetPlayerState(playerid)!=PLAYER_STATE_DRIVER)
				{
					SendClientMessage(playerid, KOLOR_CZERWONY,""C_CZERWONY"Nie jesteœ kierowc¹ pojazdu!");
					return 1;
				}
				v=GetPlayerVehicleID(playerid);
				GetVehicleParamsEx(v,engine,lights,alarm,doors,bonnet,boot,objective);
				if(doors)
				{
					GInfo(playerid,"~w~drzwi ~g~otwarte",3,3);
					SetVehicleParamsEx(v,engine,lights,alarm,false,bonnet,boot,objective);
				}
				else
				{
					GInfo(playerid,"~w~drzwi ~r~zamkniete",3,3);
					SetVehicleParamsEx(v,engine,lights,alarm,true,bonnet,boot,objective);
				}
				return 1;
			}
		}
		return 1;
	}
	if(dialogid == GUI_LIDER)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0:
	            {
	                ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Dodawanie/Usuwanie pracownika", "Aby zatrudniæ pracownika wpisz:\n\t/lider 1 <id garcza>/nAby zwolniæ pracownika wpisz:\n\t/lider 0 <id gracza>", "Rozumiem", "");
				}
	            case 1:
	            {
	                new idfrakcji = PlayerInfo[playerid][pLider];
	                new s[1000];
					new nick[128];
	                strcat(s, "Oto lista osób bêd¹sych aktualnie na skinie twojej frakcji:\n\n");
	                foreach(Player, i)
	                {
	                    if(idfrakcji == Frakcja[i])
	                    {
							format(nick, sizeof nick, "\t"C_ZIELONY"%s"C_BIALY"["C_ZOLTY"%d"C_BIALY"]\n", Nick(i), i);
							strcat(s, nick);
						}
					}
					ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Lista aktualnych pracowników", s, "Ok", "");
				}
				case 2:
				{
				    new idfrakcji = PlayerInfo[playerid][pLider];
				    new file[45];
				    format(file,sizeof(file),FRAKCJA,idfrakcji);
					new ilosckasy = DOF_GetInt(file, "Kasa");
					format(dstring, sizeof dstring, ""C_BEZOWY"Aktualny stan frakcji o ID: "C_ZIELONY"%d"C_BEZOWY" wynosi "C_ZOLTY"%d"C_BEZOWY"", idfrakcji, ilosckasy);
					ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Stan konta firmy", dstring, "Ok", "");
				}
				case 3:
				{
				    if(PlayerInfo[playerid][pLider]==1)
				    {
				    	ShowPlayerDialog(playerid, LIDER_SKLEP_WOZY_POLI, DIALOG_STYLE_LIST, "Kupno Wozu", "Enforcer (100 000$)\nFBI Rancher (90 000$)\nPolice Maverick (200 000$)\nHPV1000 (60 000$)\nPolice Car (50 000$)", "Kup", "Anuluj");
					}
					if(PlayerInfo[playerid][pLider]==2)
					{
				    	ShowPlayerDialog(playerid, LIDER_SKLEP_WOZY_PD, DIALOG_STYLE_LIST, "Kupno Wozu", "Packer (100 000$)\nTowtruck (90 000$)\nSweeper (50 000$)", "Kup", "Anuluj");
					}
					if(PlayerInfo[playerid][pLider]==10||PlayerInfo[playerid][pLider]==11||PlayerInfo[playerid][pLider]==12)
					{
				    	ShowPlayerDialog(playerid, LIDER_SKLEP_WOZY_FIRMA, DIALOG_STYLE_LIST, "Kupno Wozu", "Article Trailer (500 000$)\nArticle Trailer 2 (500 000$\nArticle Trailer 3 (500 000$)\nPetrol Trailer (500 000$\nLinerunner (150 000$)\nTanker (100 000$)\nRoadtrain (160 000$)", "Kup", "Anuluj");
					}
				}
			}
		}
	}
	if(dialogid == LIDER_SKLEP_WOZY_FIRMA)
	{
	    if(response)
	    {
			switch(listitem)
			{
			    case 0:
			    {
			    	new Float: Pos[4];
				    GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
		   			GetPlayerFacingAngle(playerid, Pos[3]);
			        new file[45];
			        new idfrakcji = PlayerInfo[playerid][pLider];
				    format(file,sizeof(file),FRAKCJA,idfrakcji);
					new ilosckasy = DOF_GetInt(file, "Kasa");
					if(ilosckasy >= 50000)
					{
				        Znalazl[playerid] = 0;
				        ilosckasy-=50000;
				        DOF_SetInt(file, "Kasa", ilosckasy);
				        for(new nr = 0; nr < KUPNE; nr++)
				        {
				            if(Znalazl[playerid] == 0)
				            {
					            format(file,sizeof(file),FRAKCYJNE,nr);
					            if(!DOF_FileExists(file))
					            {
									Znalazl[playerid] = 1;
	                                DOF_CreateFile(file);
									DOF_SetFloat(file, "X", Pos[0]);
									DOF_SetFloat(file, "Y", Pos[1]);
									DOF_SetFloat(file, "Z", Pos[2]);
									DOF_SetFloat(file, "Rot", Pos[3]);
									DOF_SetInt(file, "Model", 427);
									CreateVehicle(435, Pos[0], Pos[1], Pos[2], Pos[3], -1, -1, SPAWN);
					            }
							}
				        }
				        return 0;
					}
					else
                        ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Kasa frakcji", "Nie posiadasz 50 000$ by kupiæ ten pojazd", "Ok", "");
				}
				case 1:
			    {
			    	new Float: Pos[4];
				    GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
		   			GetPlayerFacingAngle(playerid, Pos[3]);
			        new file[45];
			        new idfrakcji = PlayerInfo[playerid][pLider];
				    format(file,sizeof(file),FRAKCJA,idfrakcji);
					new ilosckasy = DOF_GetInt(file, "Kasa");
					if(ilosckasy >= 50000)
					{
				        Znalazl[playerid] = 0;
				        ilosckasy-=50000;
				        DOF_SetInt(file, "Kasa", ilosckasy);
				        for(new nr = 0; nr < KUPNE; nr++)
				        {
				            if(Znalazl[playerid] == 0)
				            {
					            format(file,sizeof(file),FRAKCYJNE,nr);
					            if(!DOF_FileExists(file))
					            {
									Znalazl[playerid] = 1;
	                                DOF_CreateFile(file);
									DOF_SetFloat(file, "X", Pos[0]);
									DOF_SetFloat(file, "Y", Pos[1]);
									DOF_SetFloat(file, "Z", Pos[2]);
									DOF_SetFloat(file, "Rot", Pos[3]);
									DOF_SetInt(file, "Model", 427);
									CreateVehicle(450, Pos[0], Pos[1], Pos[2], Pos[3], -1, -1, SPAWN);
					            }
							}
				        }
				        return 0;
					}
					else
                        ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Kasa frakcji", "Nie posiadasz 50 000$ by kupiæ ten pojazd", "Ok", "");
				}
				case 2:
			    {
			    	new Float: Pos[4];
				    GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
		   			GetPlayerFacingAngle(playerid, Pos[3]);
			        new file[45];
			        new idfrakcji = PlayerInfo[playerid][pLider];
				    format(file,sizeof(file),FRAKCJA,idfrakcji);
					new ilosckasy = DOF_GetInt(file, "Kasa");
					if(ilosckasy >= 50000)
					{
				        Znalazl[playerid] = 0;
				        ilosckasy-=50000;
				        DOF_SetInt(file, "Kasa", ilosckasy);
				        for(new nr = 0; nr < KUPNE; nr++)
				        {
				            if(Znalazl[playerid] == 0)
				            {
					            format(file,sizeof(file),FRAKCYJNE,nr);
					            if(!DOF_FileExists(file))
					            {
									Znalazl[playerid] = 1;
	                                DOF_CreateFile(file);
									DOF_SetFloat(file, "X", Pos[0]);
									DOF_SetFloat(file, "Y", Pos[1]);
									DOF_SetFloat(file, "Z", Pos[2]);
									DOF_SetFloat(file, "Rot", Pos[3]);
									DOF_SetInt(file, "Model", 427);
									CreateVehicle(591, Pos[0], Pos[1], Pos[2], Pos[3], -1, -1, SPAWN);
					            }
							}
				        }
				        return 0;
					}
					else
                        ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Kasa frakcji", "Nie posiadasz 50 000$ by kupiæ ten pojazd", "Ok", "");
				}
				case 3:
			    {
			    	new Float: Pos[4];
				    GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
		   			GetPlayerFacingAngle(playerid, Pos[3]);
			        new file[45];
			        new idfrakcji = PlayerInfo[playerid][pLider];
				    format(file,sizeof(file),FRAKCJA,idfrakcji);
					new ilosckasy = DOF_GetInt(file, "Kasa");
					if(ilosckasy >= 50000)
					{
				        Znalazl[playerid] = 0;
				        ilosckasy-=50000;
				        DOF_SetInt(file, "Kasa", ilosckasy);
				        for(new nr = 0; nr < KUPNE; nr++)
				        {
				            if(Znalazl[playerid] == 0)
				            {
					            format(file,sizeof(file),FRAKCYJNE,nr);
					            if(!DOF_FileExists(file))
					            {
									Znalazl[playerid] = 1;
	                                DOF_CreateFile(file);
									DOF_SetFloat(file, "X", Pos[0]);
									DOF_SetFloat(file, "Y", Pos[1]);
									DOF_SetFloat(file, "Z", Pos[2]);
									DOF_SetFloat(file, "Rot", Pos[3]);
									DOF_SetInt(file, "Model", 427);
									CreateVehicle(584, Pos[0], Pos[1], Pos[2], Pos[3], -1, -1, SPAWN);
					            }
							}
				        }
				        return 0;
					}
					else
                        ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Kasa frakcji", "Nie posiadasz 50 000$ by kupiæ ten pojazd", "Ok", "");
				}
				case 4:
			    {
			    	new Float: Pos[4];
				    GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
		   			GetPlayerFacingAngle(playerid, Pos[3]);
			        new file[45];
			        new idfrakcji = PlayerInfo[playerid][pLider];
				    format(file,sizeof(file),FRAKCJA,idfrakcji);
					new ilosckasy = DOF_GetInt(file, "Kasa");
					if(ilosckasy >= 150000)
					{
				        Znalazl[playerid] = 0;
				        ilosckasy-=150000;
				        DOF_SetInt(file, "Kasa", ilosckasy);
				        for(new nr = 0; nr < KUPNE; nr++)
				        {
				            if(Znalazl[playerid] == 0)
				            {
					            format(file,sizeof(file),FRAKCYJNE,nr);
					            if(!DOF_FileExists(file))
					            {
									Znalazl[playerid] = 1;
	                                DOF_CreateFile(file);
									DOF_SetFloat(file, "X", Pos[0]);
									DOF_SetFloat(file, "Y", Pos[1]);
									DOF_SetFloat(file, "Z", Pos[2]);
									DOF_SetFloat(file, "Rot", Pos[3]);
									DOF_SetInt(file, "Model", 427);
									CreateVehicle(403, Pos[0], Pos[1], Pos[2], Pos[3], -1, -1, SPAWN);
					            }
							}
				        }
				        return 0;
					}
					else
                        ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Kasa frakcji", "Nie posiadasz 150 000$ by kupiæ ten pojazd", "Ok", "");
				}
				case 5:
			    {
			    	new Float: Pos[4];
				    GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
		   			GetPlayerFacingAngle(playerid, Pos[3]);
			        new file[45];
			        new idfrakcji = PlayerInfo[playerid][pLider];
				    format(file,sizeof(file),FRAKCJA,idfrakcji);
					new ilosckasy = DOF_GetInt(file, "Kasa");
					if(ilosckasy >= 100000)
					{
				        Znalazl[playerid] = 0;
				        ilosckasy-=100000;
				        DOF_SetInt(file, "Kasa", ilosckasy);
				        for(new nr = 0; nr < KUPNE; nr++)
				        {
				            if(Znalazl[playerid] == 0)
				            {
					            format(file,sizeof(file),FRAKCYJNE,nr);
					            if(!DOF_FileExists(file))
					            {
									Znalazl[playerid] = 1;
	                                DOF_CreateFile(file);
									DOF_SetFloat(file, "X", Pos[0]);
									DOF_SetFloat(file, "Y", Pos[1]);
									DOF_SetFloat(file, "Z", Pos[2]);
									DOF_SetFloat(file, "Rot", Pos[3]);
									DOF_SetInt(file, "Model", 427);
									CreateVehicle(514, Pos[0], Pos[1], Pos[2], Pos[3], -1, -1, SPAWN);
					            }
							}
				        }
				        return 0;
					}
					else
                        ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Kasa frakcji", "Nie posiadasz 100 000$ by kupiæ ten pojazd", "Ok", "");
				}
				case 6:
			    {
			    	new Float: Pos[4];
				    GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
		   			GetPlayerFacingAngle(playerid, Pos[3]);
			        new file[45];
			        new idfrakcji = PlayerInfo[playerid][pLider];
				    format(file,sizeof(file),FRAKCJA,idfrakcji);
					new ilosckasy = DOF_GetInt(file, "Kasa");
					if(ilosckasy >= 160000)
					{
				        Znalazl[playerid] = 0;
				        ilosckasy-=160000;
				        DOF_SetInt(file, "Kasa", ilosckasy);
				        for(new nr = 0; nr < KUPNE; nr++)
				        {
				            if(Znalazl[playerid] == 0)
				            {
					            format(file,sizeof(file),FRAKCYJNE,nr);
					            if(!DOF_FileExists(file))
					            {
									Znalazl[playerid] = 1;
	                                DOF_CreateFile(file);
									DOF_SetFloat(file, "X", Pos[0]);
									DOF_SetFloat(file, "Y", Pos[1]);
									DOF_SetFloat(file, "Z", Pos[2]);
									DOF_SetFloat(file, "Rot", Pos[3]);
									DOF_SetInt(file, "Model", 427);
									CreateVehicle(515, Pos[0], Pos[1], Pos[2], Pos[3], -1, -1, SPAWN);
					            }
							}
				        }
				        return 0;
					}
					else
                        ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Kasa frakcji", "Nie posiadasz 160 000$ by kupiæ ten pojazd", "Ok", "");
				}
			}
		}
	}
	
	if(dialogid == LIDER_SKLEP_WOZY_PD)
	{
	    if(response)
	    {
			switch(listitem)
			{
			    case 0:
			    {
			    	new Float: Pos[4];
				    GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
		   			GetPlayerFacingAngle(playerid, Pos[3]);
			        new file[45];
			        new idfrakcji = PlayerInfo[playerid][pLider];
				    format(file,sizeof(file),FRAKCJA,idfrakcji);
					new ilosckasy = DOF_GetInt(file, "Kasa");
					if(ilosckasy >= 100000)
					{
				        Znalazl[playerid] = 0;
				        ilosckasy-=100000;
				        DOF_SetInt(file, "Kasa", ilosckasy);
				        for(new nr = 0; nr < KUPNE; nr++)
				        {
				            if(Znalazl[playerid] == 0)
				            {
					            format(file,sizeof(file),FRAKCYJNE,nr);
					            if(!DOF_FileExists(file))
					            {
									Znalazl[playerid] = 1;
	                                DOF_CreateFile(file);
									DOF_SetFloat(file, "X", Pos[0]);
									DOF_SetFloat(file, "Y", Pos[1]);
									DOF_SetFloat(file, "Z", Pos[2]);
									DOF_SetFloat(file, "Rot", Pos[3]);
									DOF_SetInt(file, "Model", 427);
									CreateVehicle(443, Pos[0], Pos[1], Pos[2], Pos[3], -1, -1, SPAWN);
					            }
							}
				        }
				        return 0;
					}
					else
                        ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Kasa frakcji", "Nie posiadasz 100 000$ by kupiæ ten pojazd", "Ok", "");
				}
				case 1:
			    {
			    	new Float: Pos[4];
				    GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
		   			GetPlayerFacingAngle(playerid, Pos[3]);
			        new file[45];
			        new idfrakcji = PlayerInfo[playerid][pLider];
				    format(file,sizeof(file),FRAKCJA,idfrakcji);
					new ilosckasy = DOF_GetInt(file, "Kasa");
					if(ilosckasy >= 90000)
					{
				        Znalazl[playerid] = 0;
				        ilosckasy-=90000;
				        DOF_SetInt(file, "Kasa", ilosckasy);
				        for(new nr = 0; nr < KUPNE; nr++)
				        {
				            if(Znalazl[playerid] == 0)
				            {
					            format(file,sizeof(file),FRAKCYJNE,nr);
					            if(!DOF_FileExists(file))
					            {
									Znalazl[playerid] = 1;
	                                DOF_CreateFile(file);
									DOF_SetFloat(file, "X", Pos[0]);
									DOF_SetFloat(file, "Y", Pos[1]);
									DOF_SetFloat(file, "Z", Pos[2]);
									DOF_SetFloat(file, "Rot", Pos[3]);
									DOF_SetInt(file, "Model", 427);
									CreateVehicle(525, Pos[0], Pos[1], Pos[2], Pos[3], -1, -1, SPAWN);
					            }
							}
				        }
				        return 0;
					}
					else
                        ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Kasa frakcji", "Nie posiadasz 90 000$ by kupiæ ten pojazd", "Ok", "");
				}
				case 2:
			    {
			    	new Float: Pos[4];
				    GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
		   			GetPlayerFacingAngle(playerid, Pos[3]);
			        new file[45];
			        new idfrakcji = PlayerInfo[playerid][pLider];
				    format(file,sizeof(file),FRAKCJA,idfrakcji);
					new ilosckasy = DOF_GetInt(file, "Kasa");
					if(ilosckasy >= 50000)
					{
				        Znalazl[playerid] = 0;
				        ilosckasy-=50000;
				        DOF_SetInt(file, "Kasa", ilosckasy);
				        for(new nr = 0; nr < KUPNE; nr++)
				        {
				            if(Znalazl[playerid] == 0)
				            {
					            format(file,sizeof(file),FRAKCYJNE,nr);
					            if(!DOF_FileExists(file))
					            {
									Znalazl[playerid] = 1;
	                                DOF_CreateFile(file);
									DOF_SetFloat(file, "X", Pos[0]);
									DOF_SetFloat(file, "Y", Pos[1]);
									DOF_SetFloat(file, "Z", Pos[2]);
									DOF_SetFloat(file, "Rot", Pos[3]);
									DOF_SetInt(file, "Model", 427);
									CreateVehicle(574, Pos[0], Pos[1], Pos[2], Pos[3], -1, -1, SPAWN);
					            }
							}
				        }
				        return 0;
					}
					else
                        ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Kasa frakcji", "Nie posiadasz 50 000$ by kupiæ ten pojazd", "Ok", "");
				}
			}
		}
	}
	
	if(dialogid == LIDER_SKLEP_WOZY_POLI)
	{
	    if(response)
	    {
			switch(listitem)
			{
			    case 0:
			    {
			    	new Float: Pos[4];
				    GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
		   			GetPlayerFacingAngle(playerid, Pos[3]);
			        new file[45];
			        new idfrakcji = PlayerInfo[playerid][pLider];
				    format(file,sizeof(file),FRAKCJA,idfrakcji);
					new ilosckasy = DOF_GetInt(file, "Kasa");
					if(ilosckasy >= 100000)
					{
				        Znalazl[playerid] = 0;
				        ilosckasy-=100000;
				        DOF_SetInt(file, "Kasa", ilosckasy);
				        for(new nr = 0; nr < KUPNE; nr++)
				        {
				            if(Znalazl[playerid] == 0)
				            {
					            format(file,sizeof(file),FRAKCYJNE,nr);
					            if(!DOF_FileExists(file))
					            {
									Znalazl[playerid] = 1;
	                                DOF_CreateFile(file);
									DOF_SetFloat(file, "X", Pos[0]);
									DOF_SetFloat(file, "Y", Pos[1]);
									DOF_SetFloat(file, "Z", Pos[2]);
									DOF_SetFloat(file, "Rot", Pos[3]);
									DOF_SetInt(file, "Model", 427);
									CreateVehicle(427, Pos[0], Pos[1], Pos[2], Pos[3], -1, -1, SPAWN);
					            }
							}
				        }
				        return 0;
					}
					else
                        ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Kasa frakcji", "Nie posiadasz 10 000$ by kupiæ ten pojazd", "Ok", "");
				}
				case 1:
			    {
			    	new Float: Pos[4];
				    GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
		   			GetPlayerFacingAngle(playerid, Pos[3]);
			        new file[45];
			        new idfrakcji = PlayerInfo[playerid][pLider];
				    format(file,sizeof(file),FRAKCJA,idfrakcji);
					new ilosckasy = DOF_GetInt(file, "Kasa");
					if(ilosckasy >= 90000)
					{
				        Znalazl[playerid] = 0;
				        ilosckasy-=90000;
				        DOF_SetInt(file, "Kasa", ilosckasy);
				        for(new nr = 0; nr < KUPNE; nr++)
				        {
				            if(Znalazl[playerid] == 0)
				            {
					            format(file,sizeof(file),FRAKCYJNE,nr);
					            if(!DOF_FileExists(file))
					            {
									Znalazl[playerid] = 1;
	                                DOF_CreateFile(file);
									DOF_SetFloat(file, "X", Pos[0]);
									DOF_SetFloat(file, "Y", Pos[1]);
									DOF_SetFloat(file, "Z", Pos[2]);
									DOF_SetFloat(file, "Rot", Pos[3]);
									DOF_SetInt(file, "Model", 427);
									CreateVehicle(409, Pos[0], Pos[1], Pos[2], Pos[3], -1, -1, SPAWN);
					            }
							}
				        }
				        return 0;
					}
					else
                        ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Kasa frakcji", "Nie posiadasz 90 000$ by kupiæ ten pojazd", "Ok", "");
				}
				case 2:
    			{
			    	new Float: Pos[4];
				    GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
		   			GetPlayerFacingAngle(playerid, Pos[3]);
			        new file[45];
			        new idfrakcji = PlayerInfo[playerid][pLider];
				    format(file,sizeof(file),FRAKCJA,idfrakcji);
					new ilosckasy = DOF_GetInt(file, "Kasa");
					if(ilosckasy >= 200000)
					{
				        Znalazl[playerid] = 0;
				        ilosckasy-=200000;
				        DOF_SetInt(file, "Kasa", ilosckasy);
				        for(new nr = 0; nr < KUPNE; nr++)
				        {
				            if(Znalazl[playerid] == 0)
				            {
					            format(file,sizeof(file),FRAKCYJNE,nr);
					            if(!DOF_FileExists(file))
					            {
									Znalazl[playerid] = 1;
	                                DOF_CreateFile(file);
									DOF_SetFloat(file, "X", Pos[0]);
									DOF_SetFloat(file, "Y", Pos[1]);
									DOF_SetFloat(file, "Z", Pos[2]);
									DOF_SetFloat(file, "Rot", Pos[3]);
									DOF_SetInt(file, "Model", 427);
									CreateVehicle(497, Pos[0], Pos[1], Pos[2], Pos[3], -1, -1, SPAWN);
					            }
							}
				        }
				        return 0;
					}
					else
                        ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Kasa frakcji", "Nie posiadasz 20 000$ by kupiæ ten pojazd", "Ok", "");
				}
				case 3:
			    {
			    	new Float: Pos[4];
				    GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
		   			GetPlayerFacingAngle(playerid, Pos[3]);
			        new file[45];
			        new idfrakcji = PlayerInfo[playerid][pLider];
				    format(file,sizeof(file),FRAKCJA,idfrakcji);
					new ilosckasy = DOF_GetInt(file, "Kasa");
					if(ilosckasy >= 60000)
					{
				        Znalazl[playerid] = 0;
				        ilosckasy-=60000;
				        DOF_SetInt(file, "Kasa", ilosckasy);
				        for(new nr = 0; nr < KUPNE; nr++)
				        {
				            if(Znalazl[playerid] == 0)
				            {
					            format(file,sizeof(file),FRAKCYJNE,nr);
					            if(!DOF_FileExists(file))
					            {
									Znalazl[playerid] = 1;
	                                DOF_CreateFile(file);
									DOF_SetFloat(file, "X", Pos[0]);
									DOF_SetFloat(file, "Y", Pos[1]);
									DOF_SetFloat(file, "Z", Pos[2]);
									DOF_SetFloat(file, "Rot", Pos[3]);
									DOF_SetInt(file, "Model", 427);
									CreateVehicle(523, Pos[0], Pos[1], Pos[2], Pos[3], -1, -1, SPAWN);
					            }
							}
				        }
				        return 0;
					}
					else
                        ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Kasa frakcji", "Nie posiadasz 60 000$ by kupiæ ten pojazd", "Ok", "");
				}
				case 4:
       			{
			    	new Float: Pos[4];
				    GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
		   			GetPlayerFacingAngle(playerid, Pos[3]);
			        new file[45];
			        new idfrakcji = PlayerInfo[playerid][pLider];
				    format(file,sizeof(file),FRAKCJA,idfrakcji);
					new ilosckasy = DOF_GetInt(file, "Kasa");
					if(ilosckasy >= 50000)
					{
				        Znalazl[playerid] = 0;
				        ilosckasy-=50000;
				        DOF_SetInt(file, "Kasa", ilosckasy);
				        for(new nr = 0; nr < KUPNE; nr++)
				        {
				            if(Znalazl[playerid] == 0)
				            {
					            format(file,sizeof(file),FRAKCYJNE,nr);
					            if(!DOF_FileExists(file))
					            {
									Znalazl[playerid] = 1;
	                                DOF_CreateFile(file);
									DOF_SetFloat(file, "X", Pos[0]);
									DOF_SetFloat(file, "Y", Pos[1]);
									DOF_SetFloat(file, "Z", Pos[2]);
									DOF_SetFloat(file, "Rot", Pos[3]);
									DOF_SetInt(file, "Model", 427);
									CreateVehicle(598, Pos[0], Pos[1], Pos[2], Pos[3], -1, -1, SPAWN);
					            }
							}
				        }
				        return 0;
					}
					else
                        ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Kasa frakcji", "Nie posiadasz 50 000$ by kupiæ ten pojazd", "Ok", "");
				}
			}
		}
	}
	return 1;
}

forward SchowajOsiagniecia(playerid);
public SchowajOsiagniecia(playerid)
{
	TextDrawHideForPlayer(playerid, Osiagniecia1);
	TextDrawHideForPlayer(playerid, Osiagniecia2);
	TextDrawHideForPlayer(playerid, OsiagnieciaNapis);
	TextDrawHideForPlayer(playerid, OsiagnieciaTresc[playerid]);
	KillTimer(TimerSchowaj[playerid]);
	return 1;
}

stock ToPolicjant(playerid)//sprawdza czy to policjant
{
    new s=GetPlayerSkin(playerid);
	if((s==280||s==282||s==283||s==265||s==266||s==284)&&PlayerInfo[playerid][pFrakcja]==1)
	{
		return 1;
	}
	return 0;
}

stock ToPomoc(playerid)//sprawdza czy to pomoc
{
    new s=GetPlayerSkin(playerid);
	if((s==27||s==16||s==8||s==56)&&PlayerInfo[playerid][pFrakcja]==2)
	{
		return 1;
	}
	return 0;
}

stock ToST(playerid)//sprawdza czy to Speed Trans
{
    new s=GetPlayerSkin(playerid);
	if((s==126||s==128)&&PlayerInfo[playerid][pFrakcja]==10)
	{
		return 1;
	}
	return 0;
}

stock ToET(playerid)//sprawdza czy to Euro Trans
{
    new s=GetPlayerSkin(playerid);
	if((s==3||s==20)&&PlayerInfo[playerid][pFrakcja]==11)
	{
		return 1;
	}
	return 0;
}

stock ToRT(playerid)//sprawdza czy to Rico Trans
{
    new s=GetPlayerSkin(playerid);
	if((s==121||s==152)&&PlayerInfo[playerid][pFrakcja]==12)
	{
		return 1;
	}
	return 0;
}

public OnVehicleSpawn(vehicleid)
{
    new naczepa=GetVehicleModel(GetVehicleTrailer(vehicleid));
	if(naczepa==435||naczepa==450||naczepa==591||naczepa==584)
	{
		CarInfo[vehicleid][cNaczepa]=1;
		CarInfo[vehicleid][cPaliwo]=0;
		CarInfo[vehicleid][cZaladowany]=0;
		CarInfo[vehicleid][cWaga]=0;
		CarInfo[vehicleid][cWyladuj]=0;
		strmid(CarInfo[vehicleid][cTowar], "brak", 0, 34, 34);
	}
	else
	{
		CarInfo[vehicleid][cNaczepa]=0;
		CarInfo[vehicleid][cPaliwo]=100;
		CarInfo[vehicleid][cZaladowany]=0;
		CarInfo[vehicleid][cWaga]=0;
		CarInfo[vehicleid][cWyladuj]=0;
		strmid(CarInfo[vehicleid][cTowar], "brak", 0, 34, 34);
	}
	if(makogut[vehicleid] == 1)
	{
    	DestroyObject(kogut[vehicleid]);
    	makogut[vehicleid] = 0;
	}
	SetVehicleParamsEx(vehicleid,false,false,false,false,false,false,false);
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if(killerid == INVALID_PLAYER_ID)
	{
        SendDeathMessage(INVALID_PLAYER_ID,playerid,reason);
        SendClientMessage(playerid, KOLOR_CZERWONY, "Pope³ni³eœ samobójstwo. Kara 200$");
	    GivePlayerMoneyEx(playerid, -200);
	}
	else
    {
   		SendDeathMessage(killerid, playerid, reason);
    }
    PrivateCarSpawned[playerid] = 0;
    DestroyVehicle(PrivateCar[playerid]);
    Delete3DTextLabel(PrivateCarText[playerid]);
    DestroyVehicle(PrivNrg[playerid]);
    return 1;
}

stock PokazCzas(playerid)
{
	new CzasPrem, Days, Hours, Minutes;
	format(forma,sizeof forma,VIP_FILE,Nick(playerid));
	CzasPrem = DOF_GetInt(forma,"VipCzas") - gettime();


	if (CzasPrem >= 86400)
	{
		Days = CzasPrem / 86400;
		CzasPrem = CzasPrem - (Days * 86400);
	}
	if (CzasPrem >= 3600)
	{
		Hours = CzasPrem / 3600;
		CzasPrem = CzasPrem - (Hours * 3600);
	}
	if (CzasPrem >= 60)
	{
		Minutes = CzasPrem / 60;
		CzasPrem = CzasPrem - (Minutes * 60);
	}

	new ff[128];
	format(ff,sizeof ff,""C_ZIELONY"Konto "C_ZOLTY"VIP "C_ZIELONY"aktywne przez: "C_ZOLTY"%i "C_ZIELONY"Dni, "C_ZOLTY"%i "C_ZIELONY"Godzin, "C_ZOLTY"%i "C_ZIELONY"Minut",Days,Hours,Minutes);
	SendClientMessage(playerid,-1,ff);
}

stock IsVip(playerid)
{
	format(forma,sizeof forma,VIP_FILE,Nick(playerid));
	if(DOF_FileExists(forma) && DOF_GetInt(forma,"Vip") == 1) return 1;
	return 0;
}

stock GivePlayerMoneyEx(playerid,kasa)
{
	dKasa[playerid]+=kasa;
	GivePlayerMoney(playerid,kasa);
	return 1;
}

stock MaKaseEx(playerid,kasa)
{
	if(dKasa[playerid]>=kasa)
	{
	    return 1;
	}
	return 0;
}

stock GetPlayerMoneyEx(playerid)
{
	return dKasa[playerid];
}

stock SetPlayerMoneyEx(playerid,kasa)
{
	dKasa[playerid]=kasa;
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid,kasa);
	return 1;
}

stock DeletePlayerMoneyEx(playerid)
{
	dKasa[playerid]=0;
	ResetPlayerMoney(playerid);
	return 1;
}

forward Wplac(id, ilosc);
public Wplac(id, ilosc)
{
    new file[45];
    format(file,sizeof(file),FRAKCJA,id);
	new ilosckasy = DOF_GetInt(file, "Kasa");
	ilosckasy+=ilosc;
	DOF_SetInt(file, "Kasa", ilosckasy);
	return 1;
}

forward Osiagniecia(playerid, typ);
public Osiagniecia(playerid, typ)
{
	if(typ == 1)
	{
	    if(PlayerInfo[playerid][pPoziom] == 1)
	    {
	    	PlayerInfo[playerid][pDowiozl]++;
	    	if(PlayerInfo[playerid][pDowiozl] < PlayerInfo[playerid][pPotrzeba])
	    	{
			    new nagroda = 1000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Dowiez towary~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Dowiez %d byle jakich towarow", PlayerInfo[playerid][pDowiozl], PlayerInfo[playerid][pPotrzeba], nagroda, PlayerInfo[playerid][pPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/1.mp3");
			    SetTimerEx("SchowajOsiagniecia", 10*1000, false, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
			if(PlayerInfo[playerid][pDowiozl] == PlayerInfo[playerid][pPotrzeba])
			{
                new nagroda = 1000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Dowiez towary~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Dowiez %d byle jakich towarow", PlayerInfo[playerid][pDowiozl], PlayerInfo[playerid][pPotrzeba], nagroda, PlayerInfo[playerid][pPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    GivePlayerMoneyEx(playerid, nagroda);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/2.mp3");
			    PlayerInfo[playerid][pPotrzeba]=100;
			    PlayerInfo[playerid][pPoziom]=2;
			    SetTimerEx("SchowajOsiagniecia", 10*1000, false, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
			return 0;
		}
		if(PlayerInfo[playerid][pPoziom] == 2)
	    {
	    	PlayerInfo[playerid][pDowiozl]++;
	    	if(PlayerInfo[playerid][pDowiozl] < PlayerInfo[playerid][pPotrzeba])
	    	{
			    new nagroda = 4000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Dowiez towary~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Dowiez %d byle jakich towarow", PlayerInfo[playerid][pDowiozl], PlayerInfo[playerid][pPotrzeba], nagroda, PlayerInfo[playerid][pPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/1.mp3");
			    SetTimerEx("SchowajOsiagniecia", 10*1000, false, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
			if(PlayerInfo[playerid][pDowiozl] == PlayerInfo[playerid][pPotrzeba])
			{
                new nagroda = 4000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Dowiez towary~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Dowiez %d byle jakich towarow", PlayerInfo[playerid][pDowiozl], PlayerInfo[playerid][pPotrzeba], nagroda, PlayerInfo[playerid][pPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    GivePlayerMoneyEx(playerid, nagroda);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/2.mp3");
			    PlayerInfo[playerid][pPotrzeba]=150;
			    PlayerInfo[playerid][pPoziom]=3;
			    TimerSchowaj[playerid] = SetTimerEx("SchowajOsiagniecia", 10000, true, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
			return 0;
		}
		if(PlayerInfo[playerid][pPoziom] == 3)
	    {
	    	PlayerInfo[playerid][pDowiozl]++;
	    	if(PlayerInfo[playerid][pDowiozl] < PlayerInfo[playerid][pPotrzeba])
	    	{
			    new nagroda = 8000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Dowiez towary~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Dowiez %d byle jakich towarow", PlayerInfo[playerid][pDowiozl], PlayerInfo[playerid][pPotrzeba], nagroda, PlayerInfo[playerid][pPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/1.mp3");
			    SetTimerEx("SchowajOsiagniecia", 10*1000, false, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
			if(PlayerInfo[playerid][pDowiozl] == PlayerInfo[playerid][pPotrzeba])
			{
                new nagroda = 8000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Dowiez towary~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Dowiez %d byle jakich towarow", PlayerInfo[playerid][pDowiozl], PlayerInfo[playerid][pPotrzeba], nagroda, PlayerInfo[playerid][pPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    GivePlayerMoneyEx(playerid, nagroda);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/2.mp3");
			    PlayerInfo[playerid][pPotrzeba]=250;
			    PlayerInfo[playerid][pPoziom]=4;
			    TimerSchowaj[playerid] = SetTimerEx("SchowajOsiagniecia", 10000, true, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
			return 0;
		}
		if(PlayerInfo[playerid][pPoziom] == 4)
	    {
	    	PlayerInfo[playerid][pDowiozl]++;
	    	if(PlayerInfo[playerid][pDowiozl] < PlayerInfo[playerid][pPotrzeba])
	    	{
			    new nagroda = 15000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Dowiez towary~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Dowiez %d byle jakich towarow", PlayerInfo[playerid][pDowiozl], PlayerInfo[playerid][pPotrzeba], nagroda, PlayerInfo[playerid][pPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/1.mp3");
			    SetTimerEx("SchowajOsiagniecia", 10*1000, false, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
			if(PlayerInfo[playerid][pDowiozl] == PlayerInfo[playerid][pPotrzeba])
			{
                new nagroda = 15000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Dowiez towary~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Dowiez %d byle jakich towarow", PlayerInfo[playerid][pDowiozl], PlayerInfo[playerid][pPotrzeba], nagroda, PlayerInfo[playerid][pPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    GivePlayerMoneyEx(playerid, nagroda);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/2.mp3");
			    PlayerInfo[playerid][pPotrzeba]=400;
			    PlayerInfo[playerid][pPoziom]=5;
			    TimerSchowaj[playerid] = SetTimerEx("SchowajOsiagniecia", 10000, true, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
			return 0;
		}
		if(PlayerInfo[playerid][pPoziom] == 5)
	    {
	    	PlayerInfo[playerid][pDowiozl]++;
	    	if(PlayerInfo[playerid][pDowiozl] < PlayerInfo[playerid][pPotrzeba])
	    	{
			    new nagroda = 24000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Dowiez towary~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Dowiez %d byle jakich towarow", PlayerInfo[playerid][pDowiozl], PlayerInfo[playerid][pPotrzeba], nagroda, PlayerInfo[playerid][pPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/1.mp3");
			    SetTimerEx("SchowajOsiagniecia", 10*1000, false, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
			if(PlayerInfo[playerid][pDowiozl] == PlayerInfo[playerid][pPotrzeba])
			{
                new nagroda = 24000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Dowiez towary~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Dowiez %d byle jakich towarow", PlayerInfo[playerid][pDowiozl], PlayerInfo[playerid][pPotrzeba], nagroda, PlayerInfo[playerid][pPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    GivePlayerMoneyEx(playerid, nagroda);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/2.mp3");
			    PlayerInfo[playerid][pPotrzeba]=700;
			    PlayerInfo[playerid][pPoziom]=6;
			    TimerSchowaj[playerid] = SetTimerEx("SchowajOsiagniecia", 10000, true, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
			return 0;
		}
	}
	if(typ == 2)
	{
        if(PlayerInfo[playerid][pMandatyPoziom] == 1)
        {
            PlayerInfo[playerid][pMandaty]++;
            if(PlayerInfo[playerid][pMandaty] < PlayerInfo[playerid][pMandatyPotrzeba])
			{
                new nagroda = 800;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Mandaty~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Mandat %d razy.", PlayerInfo[playerid][pMandaty], PlayerInfo[playerid][pMandatyPotrzeba], nagroda, PlayerInfo[playerid][pMandatyPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/1.mp3");
			    TimerSchowaj[playerid] = SetTimerEx("SchowajOsiagniecia", 10000, true, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
			if(PlayerInfo[playerid][pMandaty] == PlayerInfo[playerid][pMandatyPotrzeba])
			{
                new nagroda = 800;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Mandaty~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Mandat %d razy.", PlayerInfo[playerid][pMandaty], PlayerInfo[playerid][pMandatyPotrzeba], nagroda, PlayerInfo[playerid][pMandatyPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    GivePlayerMoneyEx(playerid, nagroda);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/2.mp3");
			    PlayerInfo[playerid][pMandatyPotrzeba]=30;
			    PlayerInfo[playerid][pMandatyPoziom]=2;
			    TimerSchowaj[playerid] = SetTimerEx("SchowajOsiagniecia", 10000, true, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
		}
		if(PlayerInfo[playerid][pMandatyPoziom] == 2)
        {
            PlayerInfo[playerid][pMandaty]++;
            if(PlayerInfo[playerid][pMandaty] < PlayerInfo[playerid][pMandatyPotrzeba])
			{
                new nagroda = 1000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Mandaty~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Mandat %d razy.", PlayerInfo[playerid][pMandaty], PlayerInfo[playerid][pMandatyPotrzeba], nagroda, PlayerInfo[playerid][pMandatyPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/1.mp3");
			    TimerSchowaj[playerid] = SetTimerEx("SchowajOsiagniecia", 10000, true, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
			if(PlayerInfo[playerid][pMandaty] == PlayerInfo[playerid][pMandatyPotrzeba])
			{
                new nagroda = 1000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Mandaty~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Mandat %d razy.", PlayerInfo[playerid][pMandaty], PlayerInfo[playerid][pMandatyPotrzeba], nagroda, PlayerInfo[playerid][pMandatyPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    GivePlayerMoneyEx(playerid, nagroda);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/2.mp3");
			    PlayerInfo[playerid][pMandatyPotrzeba]=100;
			    PlayerInfo[playerid][pMandatyPoziom]=3;
			    TimerSchowaj[playerid] = SetTimerEx("SchowajOsiagniecia", 10000, true, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
		}
		if(PlayerInfo[playerid][pMandatyPoziom] == 3)
        {
            PlayerInfo[playerid][pMandaty]++;
            if(PlayerInfo[playerid][pMandaty] < PlayerInfo[playerid][pMandatyPotrzeba])
			{
                new nagroda = 2000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Mandaty~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Mandat %d razy.", PlayerInfo[playerid][pMandaty], PlayerInfo[playerid][pMandatyPotrzeba], nagroda, PlayerInfo[playerid][pMandatyPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/1.mp3");
			    TimerSchowaj[playerid] = SetTimerEx("SchowajOsiagniecia", 10000, true, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
			if(PlayerInfo[playerid][pMandaty] == PlayerInfo[playerid][pMandatyPotrzeba])
			{
                new nagroda = 2000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Mandaty~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Mandat %d razy.", PlayerInfo[playerid][pMandaty], PlayerInfo[playerid][pMandatyPotrzeba], nagroda, PlayerInfo[playerid][pMandatyPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    GivePlayerMoneyEx(playerid, nagroda);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/2.mp3");
			    PlayerInfo[playerid][pMandatyPotrzeba]=200;
			    PlayerInfo[playerid][pMandatyPoziom]=4;
			    TimerSchowaj[playerid] = SetTimerEx("SchowajOsiagniecia", 10000, true, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
		}
		if(PlayerInfo[playerid][pMandatyPoziom] == 4)
        {
            PlayerInfo[playerid][pMandaty]++;
            if(PlayerInfo[playerid][pMandaty] < PlayerInfo[playerid][pMandatyPotrzeba])
			{
                new nagroda = 5000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Mandaty~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Mandat %d razy.", PlayerInfo[playerid][pMandaty], PlayerInfo[playerid][pMandatyPotrzeba], nagroda, PlayerInfo[playerid][pMandatyPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/1.mp3");
			    TimerSchowaj[playerid] = SetTimerEx("SchowajOsiagniecia", 10000, true, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
			if(PlayerInfo[playerid][pMandaty] == PlayerInfo[playerid][pMandatyPotrzeba])
			{
                new nagroda = 5000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Mandaty~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Mandat %d razy.", PlayerInfo[playerid][pMandaty], PlayerInfo[playerid][pMandatyPotrzeba], nagroda, PlayerInfo[playerid][pMandatyPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    GivePlayerMoneyEx(playerid, nagroda);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/2.mp3");
			    PlayerInfo[playerid][pMandatyPotrzeba]=300;
			    PlayerInfo[playerid][pMandatyPoziom]=5;
			    TimerSchowaj[playerid] = SetTimerEx("SchowajOsiagniecia", 10000, true, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
		}
	}
	if(typ == 3)
	{
        if(PlayerInfo[playerid][pAresztowanPoziom] == 1)
        {
            PlayerInfo[playerid][pAresztowan]++;
            if(PlayerInfo[playerid][pAresztowan] < PlayerInfo[playerid][pAresztowanPotrzeba])
			{
                new nagroda = 1500;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Aresztowania~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Aresztowania %d razy.", PlayerInfo[playerid][pAresztowan], PlayerInfo[playerid][pAresztowanPotrzeba], nagroda, PlayerInfo[playerid][pAresztowanPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/1.mp3");
			    TimerSchowaj[playerid] = SetTimerEx("SchowajOsiagniecia", 10000, true, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
			if(PlayerInfo[playerid][pAresztowan] == PlayerInfo[playerid][pAresztowanPotrzeba])
			{
                new nagroda = 1500;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Aresztowania~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Aresztowania %d razy.", PlayerInfo[playerid][pAresztowan], PlayerInfo[playerid][pAresztowanPotrzeba], nagroda, PlayerInfo[playerid][pAresztowanPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    GivePlayerMoneyEx(playerid, nagroda);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/2.mp3");
			    PlayerInfo[playerid][pAresztowanPotrzeba]=30;
			    PlayerInfo[playerid][pAresztowanPoziom]=2;
			    TimerSchowaj[playerid] = SetTimerEx("SchowajOsiagniecia", 10000, true, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
		}
		if(PlayerInfo[playerid][pAresztowanPoziom] == 2)
        {
            PlayerInfo[playerid][pAresztowan]++;
            if(PlayerInfo[playerid][pAresztowan] < PlayerInfo[playerid][pAresztowanPotrzeba])
			{
                new nagroda = 4000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Aresztowania~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Aresztowania %d razy.", PlayerInfo[playerid][pAresztowan], PlayerInfo[playerid][pAresztowanPotrzeba], nagroda, PlayerInfo[playerid][pAresztowanPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/1.mp3");
			    TimerSchowaj[playerid] = SetTimerEx("SchowajOsiagniecia", 10000, true, "d", playerid);
			    ZapiszKonto(playerid);
			    return 0;
			}
			if(PlayerInfo[playerid][pAresztowan] == PlayerInfo[playerid][pAresztowanPotrzeba])
			{
                new nagroda = 4000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Aresztowania~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Aresztowania %d razy.", PlayerInfo[playerid][pAresztowan], PlayerInfo[playerid][pAresztowanPotrzeba], nagroda, PlayerInfo[playerid][pAresztowanPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    GivePlayerMoneyEx(playerid, nagroda);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/2.mp3");
			    PlayerInfo[playerid][pAresztowanPotrzeba]=100;
			    PlayerInfo[playerid][pAresztowanPoziom]=3;
			    ZapiszKonto(playerid);
			    TimerSchowaj[playerid] = SetTimerEx("SchowajOsiagniecia", 10000, true, "d", playerid);
			    return 0;
			}
		}
		if(PlayerInfo[playerid][pAresztowanPoziom] == 3)
        {
            PlayerInfo[playerid][pAresztowan]++;
            if(PlayerInfo[playerid][pAresztowan] < PlayerInfo[playerid][pAresztowanPotrzeba])
			{
                new nagroda = 6000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Aresztowania~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Aresztowania %d razy.", PlayerInfo[playerid][pAresztowan], PlayerInfo[playerid][pAresztowanPotrzeba], nagroda, PlayerInfo[playerid][pAresztowanPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/1.mp3");
			    ZapiszKonto(playerid);
			    TimerSchowaj[playerid] = SetTimerEx("SchowajOsiagniecia", 10000, true, "d", playerid);
			    return 0;
			}
			if(PlayerInfo[playerid][pAresztowan] == PlayerInfo[playerid][pAresztowanPotrzeba])
			{
                new nagroda = 6000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Aresztowania~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Aresztowania %d razy.", PlayerInfo[playerid][pAresztowan], PlayerInfo[playerid][pAresztowanPotrzeba], nagroda, PlayerInfo[playerid][pAresztowanPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    GivePlayerMoneyEx(playerid, nagroda);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/2.mp3");
			    PlayerInfo[playerid][pAresztowanPotrzeba]=200;
			    PlayerInfo[playerid][pAresztowanPoziom]=4;
			    ZapiszKonto(playerid);
			    TimerSchowaj[playerid] = SetTimerEx("SchowajOsiagniecia", 10000, true, "d", playerid);
			    return 0;
			}
		}
		if(PlayerInfo[playerid][pAresztowanPoziom] == 4)
        {
            PlayerInfo[playerid][pAresztowan]++;
            if(PlayerInfo[playerid][pAresztowan] < PlayerInfo[playerid][pAresztowanPotrzeba])
			{
                new nagroda = 8000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Aresztowania~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Aresztowania %d razy.", PlayerInfo[playerid][pAresztowan], PlayerInfo[playerid][pAresztowanPotrzeba], nagroda, PlayerInfo[playerid][pAresztowanPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/1.mp3");
			    TimerSchowaj[playerid] = SetTimerEx("SchowajOsiagniecia", 10000, true, "d", playerid);
                ZapiszKonto(playerid);
			    return 0;
			}
			if(PlayerInfo[playerid][pAresztowan] == PlayerInfo[playerid][pAresztowanPotrzeba])
			{
                new nagroda = 8000;
			    TextDrawShowForPlayer(playerid, Osiagniecia1);
			    TextDrawShowForPlayer(playerid, Osiagniecia2);
			    TextDrawShowForPlayer(playerid, OsiagnieciaNapis);
			    TextDrawShowForPlayer(playerid, OsiagnieciaTresc[playerid]);
			    format(dstring, sizeof(dstring), "~r~Stan: ~w~%d/%d~n~~r~Nazwa:~w~ Aresztowania~n~~r~Nagroda: ~w~%d$~n~~r~Cel: ~w~Aresztowania %d razy.", PlayerInfo[playerid][pAresztowan], PlayerInfo[playerid][pAresztowanPotrzeba], nagroda, PlayerInfo[playerid][pAresztowanPotrzeba]);
			    TextDrawSetString(OsiagnieciaTresc[playerid], dstring);
			    GivePlayerMoneyEx(playerid, nagroda);
			    PlayAudioStreamForPlayer(playerid, "http://www.Hard-Truck.pl/glosy/2.mp3");
			    PlayerInfo[playerid][pAresztowanPotrzeba]=300;
			    PlayerInfo[playerid][pAresztowanPoziom]=5;
			    ZapiszKonto(playerid);
			    TimerSchowaj[playerid] = SetTimerEx("SchowajOsiagniecia", 10000, true, "d", playerid);
			    return 0;
			}
		}
	}
	return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
	if(!success)
	{
		format(dstring, sizeof(dstring),ZLA_KOMENDA, cmdtext);
		SendClientMessage(playerid, KOLOR_CZERWONY, dstring);
	}
	else
	{
	    printf("[CMD]%s: %s", Nick(playerid), cmdtext);
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(PlayerInfo[playerid][pWarn] >= 3)
	{
	    SendClientMessage(playerid, KOLOR_CZERWONY, "Twój poziom warnów wynosi 3/4! Nie mo¿esz pisaæ na chacie.");
	    return 0;
	}
	if(PlayerInfo[playerid][pMute] > 0)
	{
 		SendClientMessage(playerid, KOLOR_CZERWONY, "Nie mo¿esz pisaæ poniewaz jesteœ wyciszony");
 		return 0;
	}
	if(anty(text))
	{
	    format(dstring, sizeof(dstring),"~r~(%d)%s zostal wyrzucony~n~~y~przez: (-1)Serwer~n~~w~Za: Reklama",playerid,Nick(playerid));
	    NapisText(dstring);
	    Kick(playerid);
	    return 0;
	}
	if(Bluzg(text))
	{
 		format(dstring, sizeof(dstring),"~r~(%d)%s zostal wyciszony na 3 minuty~n~~y~przez: (-1)Serwer~n~~w~Za: Przeklenstwa",playerid,Nick(playerid));
	    NapisText(dstring);
		PlayerInfo[playerid][pMute]=3;
		ZapiszKonto(playerid);
		return 0;
	}
	format(dstring, sizeof(dstring), "["C_ZOLTY"%d"C_BIALY"]"C_NIEBIESKI"%s"C_BIALY" %s: %s", playerid, Nick(playerid), PlayerInfo[playerid][pTag], text);
	SendClientMessageToAll(KOLOR_BIALY, Koloruj(dstring));
	return 0;
}

stock anty(string[])
{
	if(strfind(string,"w",true)!=-1 && strfind(string,"o",true)!=-1 && strfind(string,"r",true)!=-1 && strfind(string,"l",true)!=-1 && strfind(string,"d",true)!=-1 && strfind(string,"t",true)!=-1 && strfind(string,"r",true)!=-1 && strfind(string,"u",true)!=-1 && strfind(string,"c",true)!=-1)
	return true;
	return false;
}

stock Bluzg(text[])
{
	if(strfind(text[0],"huj",false)!=-1||
	strfind(text[0],"chuj",false)!=-1||
	strfind(text[0],"kurwa",false)!=-1||
	strfind(text[0],"suka",false)!=-1||
	strfind(text[0],"szmata",false)!=-1||
	strfind(text[0],"dziwka",false)!=-1||
	strfind(text[0],"jebaæ",false)!=-1||
	strfind(text[0],"jebac",false)!=-1||
	strfind(text[0],"spierdalaj",false)!=-1||
	strfind(text[0],"pierdoliæ",false)!=-1||
	strfind(text[0],"pierdolic",false)!=-1||
	strfind(text[0],"jeb",false)!=-1||
	strfind(text[0],"ssij",false)!=-1||
	strfind(text[0],"suki",false)!=-1||
	strfind(text[0],"skurwysyn",false)!=-1||
	strfind(text[0],"pizda",false)!=-1||
	strfind(text[0],"kurwy",false)!=-1)
	{
	    return 1;
	}
    return 0;
}

forward SilnikUruchom(playerid);//odpala silnik
public SilnikUruchom(playerid)
{
    if(GetPlayerState(playerid)!=PLAYER_STATE_DRIVER) return 1;
    new v,Float:HP;
    v=GetPlayerVehicleID(playerid);
    GetVehicleHealth(v,HP);
    GetVehicleParamsEx(v,engine,lights,alarm,doors,bonnet,boot,objective);

    if(HP>700)
    {
    	GInfo(playerid,"~w~silnik ~g~uruchomiony",3,3);
    	SetVehicleParamsEx(v,true,lights,alarm,doors,bonnet,boot,objective);
    	return 1;
	}
	else
	{
	    new los = random(4);
	    if(los!=3)
	    {
	        GInfo(playerid,"~w~silnik ~g~uruchomiony",3,3);
    		SetVehicleParamsEx(v,true,lights,alarm,doors,bonnet,boot,objective);
    		return 1;
	    }
	    else
	    {
	        GInfo(playerid,"~w~silnik ~r~nieuruchomiony",3,3);
	    }
	}
    return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	if(makogut[vehicleid] == 1)
	{
    	DestroyObject(kogut[vehicleid]);
	}
    return 1;
}

forward ZapiszAutomat(nr);
public ZapiszAutomat(nr)
{
	new file[25];
	format(file,sizeof(file),AUTOMATY_FILE,nr);
	if(!DOF_FileExists(file))
	{
	    DOF_CreateFile(file);
	}
	DOF_SetFloat(file,"X", AutomatInfo[nr][aX]);
	DOF_SetFloat(file,"Y", AutomatInfo[nr][aY]);
	DOF_SetFloat(file,"Z", AutomatInfo[nr][aZ]);
	DOF_SetFloat(file,"Ang", AutomatInfo[nr][aAng]);
	DOF_SaveFile();
	return 1;
}

forward SchowajOgloszenie();
public SchowajOgloszenie()
{
	TextDrawHideForAll(AdminNews1);
	TextDrawHideForAll(AdminNews2);
	TextDrawHideForAll(AdminNews3);
	KillTimer(ogloszenietim);
	an = 0;
	return 1;
}

forward WezPremium(playerid, ilosc);
public WezPremium(playerid, ilosc)
{
    PlayerInfo[playerid][pPremium]-=ilosc;
    return 1;
}

forward DajPremium(playerid, ilosc);
public DajPremium(playerid, ilosc)
{
    PlayerInfo[playerid][pPremium]+=ilosc;
    return 1;
}

forward GetPremium(playerid);
public GetPremium(playerid)
{
    new punkciki = PlayerInfo[playerid][pPremium];
    return punkciki;
}

stock EgzaminPraktyczny(playerid)
{
    SetPlayerVirtualWorld(playerid,playerid+1);
	SetPVarInt(playerid,"ZdajeEgzamin",1);
	RemovePlayerFromVehicle(playerid);
	SetPVarInt(playerid,"vehB",CreateVehicle(421,CheckPointB[0][0],CheckPointB[0][1],CheckPointB[0][2],358.9628,3,3,999999));
    SetVehicleParamsEx(GetPVarInt(playerid, "vehB"),false,false,false,false,false,false,false);
	CarInfo[GetPVarInt(playerid, "vehB")][cPaliwo]=100;
	SetVehicleVirtualWorld(GetPVarInt(playerid,"vehB"),playerid+1);
	PutPlayerInVehicle(playerid,GetPVarInt(playerid,"vehB"),0);
	SetPlayerCheckpoint(playerid,CheckPointB[1][0],CheckPointB[1][1],CheckPointB[1][2],5.0);
	SetPVarInt(playerid,"PrawkoB",0);
	SetCheckPointNumer(playerid);
	TogglePlayerControllable(playerid,false);
	SetTimerEx("Freeze",8000,false,"d",playerid);
	PlayAudioStreamForPlayer(playerid, "http://xqz.ugu.pl/prawo_jazdy/jestem_xqz.mp3");
	for(new i=1; i<11; i++) { SendClientMessage(playerid,-1," "); }
	ShowPlayerDialog(playerid,1234,DIALOG_STYLE_MSGBOX,"Prawo jazdy - egzamin","Witaj! Zaraz rozpoczniesz praktyczn¹ czêœæ egzaminu na prawo jazdy\nJedz ostroznie, oraz nie przekraczaj dozwolonej predkosci!\n{FFFFFF}Powodzenia!\n\n{AA3333}Aby slyszec egzaminatora, wejdz w: \nMenu gry >> Options >> Audio setup >> podglosnij radio na maximum","Rozumiem","");
	return 1;
}

forward Freeze(playerid);
public Freeze(playerid)
{
    PlayAudioStreamForPlayer(playerid, "http://xqz.ugu.pl/prawo_jazdy/max_p.mp3");
    for(new i=1; i<11; i++) { SendClientMessage(playerid,-1," "); }
    SetTimerEx("Freeze2",10000,false,"d",playerid);
	return 1;
}
forward Freeze2(playerid);
public Freeze2(playerid)
{
    TogglePlayerControllable(playerid,true);
	return 1;
}
stock NaStacjiPaliw(playerid)//sprawdza czy wogóle jestesmy na stacji paliw
{
    if(IsPlayerConnected(playerid))
	{


	if( DoInRange (playerid, -608.3016,585.5062,16.3699,  	 8.00)|| /////truck stop jak sie jedyie na sf od lv
	DoInRange (playerid, -603.4999,592.3832,16.3615,  	 8.00)|| /////truck stop jak sie jedyie na sf od lv
	DoInRange (playerid, -601.7045,600.6387,16.3726,  	 8.00)|| /////truck stop jak sie jedyie na sf od lv
	DoInRange (playerid, 1609.9637,192.3468,34.3260,  	 8.00)|| ////za rondem i granica na ls
	DoInRange (playerid, 1649.2439,166.4865,35.2056,  	 8.00)|| /////za rondem i granica na ls
	DoInRange (playerid, 1568.3087,1626.9720,10.5651,  	 8.00)|| /////lv lot
	DoInRange (playerid, 1558.2496,1626.9457,10.5633,  	 8.00)|| /////lv lot
	DoInRange (playerid, 1008.4910,-939.2007,43.2439,  	 8.00)|| /////LS niedfaleko vinewood_!_
	DoInRange (playerid, 2117.6216,918.1204,10.8203,  	 8.00)|| /////Pryz bayie vipa
	DoInRange (playerid, 2117.5137,907.7133,10.5611,  	 8.00)|| /////pryz bayie vipa
	DoInRange (playerid, 2188.3926,603.5776,10.6387,  	 8.00)|| ////obok xoomer
	DoInRange (playerid, 2188.6011,595.2422,10.6371,  	 8.00)|| /////obbok xoomer
	DoInRange (playerid, 2189.0198,585.0323,10.6406,  	 8.00)|| /////obok xoomer
	DoInRange (playerid, -91.0920,-1169.1783,3.4708,  	 8.00)|| /////zadupie ls
	DoInRange (playerid, 1938.6899,-1769.9293,14.4395,   8.00)|| ////ls niedaleko lotniska
	DoInRange (playerid, -91.0920,-1169.1783,3.4708,  	 8.00)|| /////zadupie ls
	DoInRange (playerid, 2193.7876,2473.9771,10.5655,  	 8.00)|| ////poli lv
	DoInRange (playerid, 2202.1602,2475.5347,10.5688,  	 8.00)|| /////poli lv
	DoInRange (playerid, 2211.3669,2473.5977,10.5657,    8.00)|| ///polilv
	DoInRange (playerid, 1594.2289,2189.2664,10.6017,  	 8.00)|| ////obok stadionu
	DoInRange (playerid, 1596.1151,2198.7861,10.5635,  	 8.00)|| /////obok stadionu
	DoInRange (playerid, 1595.2377,2209.8835,10.5614,    8.00)|| ///obok stadionu
	DoInRange (playerid, -1609.7119,-2718.4131,49.5960,  	 8.00)|| ////bagna
	DoInRange (playerid, -1605.6085,-2714.3481,49.5970,    8.00)|| ///bagna
	DoInRange (playerid, -1602.8495,-2709.4214,49.5937,    8.00)|| ///bagna
	DoInRange (playerid, 2146.5837,2756.5940,10.5617,  	 8.00)|| ////gora prawo lv
	DoInRange (playerid, 2147.6868,2747.7307,10.5658,  	 8.00)|| /////gora prawo lv
	DoInRange (playerid, 2146.6677,2738.8484,10.5644,    8.00)|| ///gora prawo lv
	DoInRange (playerid, 626.2897,1675.6917,6.7331,  	 8.00)|| ////area
	DoInRange (playerid, 623.0495,1680.6071,6.7328,    8.00)|| ///area
	DoInRange (playerid, 619.6532,1685.0613,6.7389,  	 8.00)|| ////area
	DoInRange (playerid, 615.3979,1689.7284,6.7308,    8.00)|| ///area
	DoInRange (playerid, 612.2051,1695.2076,6.7333,    8.00)|| ///bagna
	DoInRange (playerid, 608.6496,1699.8217,6.7365,  	 8.00)|| ////area
	DoInRange (playerid, 605.6508,1705.1821,6.7372,  	 8.00)|| /////area
	DoInRange (playerid, 602.2210,1710.1323,6.7360,    8.00)|| ///area
	DoInRange (playerid, 783.1072,504.2372,11.9791,  	 8.00)|| /////truck papier obok kopalni
	DoInRange (playerid, 605.6508,1705.1821,6.7372,  	 8.0)|| /////gdzies obok budowy w lv
	DoInRange (playerid, 2638.9753,1105.1556,10.3992,    8.0)||///gdzies obok budowy w lv
	DoInRange (playerid, 2638.6077,1115.4622,10.3928,  	 8.00)) /////gdzies obok budowy w lv
			///////
		{
			return 1;
		}
 	}
	return 0;
}
stock StacjaPaliw(playerid)//sprawdza nam stacje paliw na jakiej jestesmy i zwraca jej id
{
    for(new nr = 0; nr < ILOSC_STACJI; nr++)
	{
	    if(DoInRange(playerid, stacja[nr][0],stacja[nr][1],stacja[nr][2],16.0))
	    {
	        return nr;
	    }
	}
	return 99;
}
stock ToAdminLevel(playerid, level)
{
	if(PlayerInfo[playerid][pAdmin] >= level || IsPlayerAdmin(playerid))
	{
	    return true;
	}
	return false;
}
/*=================================================================================================================
===================================================================================================================
===================================================================================================================
===================================================================================================================
===================================================================================================================
=================================================================================================================*/

CMD:dajpremium(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla HeadAdmina!");

	new id, ilosc;
	if(sscanf(params, "dd", id, ilosc))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "U¿yj: /dajpremium <id> <ilosc>");
	    
	DajPremium(id, ilosc);
	format(dstring, sizeof(dstring), "Da³eœ %d punktów premium graczowi %s[%d]", ilosc, Nick(id), id);
	SendClientMessage(playerid, KOLOR_ZIELONY, dstring);
	format(dstring, sizeof(dstring), "Dosta³eœ %d punktów premium! Twój stan wynosi %d", ilosc, GetPremium(id));
	SendClientMessage(id, KOLOR_ZIELONY, dstring);
	return 1;
}

CMD:sklep(playerid, params[])
{
	new dd[1000];
	strcat(dd, ""C_BEZOWY"Napraw pojazd - "C_ZIELONY"5punktów\n");
	strcat(dd, ""C_BEZOWY"Tankuj pojazd - "C_ZIELONY"8punktów\n");
	strcat(dd, ""C_BEZOWY"Spawn nrg500 - "C_ZIELONY"30punktów\n");
	format(dstring, sizeof(dstring), "sklepik za punkty premiu\nTwój stan konta premium wynosi: %d", GetPremium(playerid));
    ShowPlayerDialog(playerid, PREMIUM, DIALOG_STYLE_LIST, dstring, dd, "Kup", "Anuluj");
    return 1;
}

CMD:napraw(playerid, cmdtext[])
{
    if(!ToPomoc(playerid))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla Pomocy Drogowej!");
	if(!IsPlayerInAnyVehicle(playerid))
	{
		SendClientMessage(playerid, KOLOR_CZERWONY, ""C_CZERWONY"Nie jesteœ kierowc¹ ¿adnego pojazdu!");
		return 1;
	}
	if(GetPlayerSpeed(playerid)>1)
	{
		SendClientMessage(playerid, KOLOR_CZERWONY, ""C_CZERWONY"Musisz siê zatrzymaæ, aby u¿yæ tej komendy!");
		return 1;
	}
	new Float:HP;
	new vehicleid = GetPlayerVehicleID(playerid);
	GetVehicleHealth(vehicleid,HP);
	if(HP>=999.0)
	{
		SendClientMessage(playerid, KOLOR_CZERWONY, ""C_CZERWONY"Ten pojazd jest w perfekcyjnym stanie!");
		return 1;
	}
 	new koszt;
	koszt=floatround(1000.0-HP);
	RepairVehicle(vehicleid);
	SetVehicleHealth(vehicleid,1000.0);
	format(dstring,sizeof(dstring),""C_ZOLTY"Pojazd naprawiony!\nNa konto firmy wp³ynê³o: %d$",koszt);
	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Naprawa pojazdu!", dstring, "Rozumiem", "Ok");
	Wplac(PlayerInfo[playerid][pFrakcja], koszt);
	return 1;
}

CMD:naprawall(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla moderatora!");
	for(new nr = 1; nr < POJAZDY; nr++)
	{
	    RepairVehicle(nr);
		SetVehicleHealth(nr,1000.0);
	}
	format(dstring, sizeof(dstring),"~r~(%d)%s ~w~naprawi³ wszystkie pojazdy!",playerid,Nick(playerid));
	NapisText(dstring);
	return 1;
}

CMD:tankuj(playerid, cmdtext[])
{
    if(!ToPomoc(playerid))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla Pomocy Drogowej!");
	if(!IsPlayerInAnyVehicle(playerid))
	{
		SendClientMessage(playerid, KOLOR_CZERWONY, ""C_CZERWONY"Nie jesteœ kierowc¹ ¿adnego pojazdu!");
		return 1;
	}
	if(GetPlayerSpeed(playerid)>1)
	{
		SendClientMessage(playerid, KOLOR_CZERWONY, ""C_CZERWONY"Musisz siê zatrzymaæ, aby u¿yæ tej komendy!");
		return 1;
	}
	new vehicleid = GetPlayerVehicleID(playerid);
	if(CarInfo[vehicleid][cPaliwo]>=100)
	{
		SendClientMessage(playerid, KOLOR_CZERWONY, ""C_CZERWONY"Ten pojazd jest w pe³ni zatankowany!");
		return 1;
	}
 	new koszt;
	koszt=(100-CarInfo[vehicleid][cPaliwo])*3;
	CarInfo[vehicleid][cPaliwo]=100;
	format(dstring,sizeof(dstring),""C_ZOLTY"Pojazd zatankowany!\nNa konto firmy wp³ynê³o: %d$",koszt);
	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Tankowanie pojazdu!", dstring, "Rozumiem", "Ok");
	Wplac(PlayerInfo[playerid][pFrakcja], koszt);
	return 1;
}

CMD:settime(playerid, params[])
{
	if(!ToAdminLevel(playerid, 1))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla Moderatora!");
	new czas;
	if(sscanf(params, "d", czas))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "U¿yj: /settime <godzina>");

	SetWorldTime(czas);
	format(dstring,sizeof(dstring),""C_NIEBIESKI"Admin [%d]%s "C_ZOLTY"ustawi³ godzinê serwera na "C_ZOLTY"%d:00",playerid,Nick(playerid),czas);
	SendClientMessageToAll(KOLOR_BIALY, dstring);
	return 1;
}

CMD:v(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
		return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla HeadAdmina");
		
	new carid,
	    carid2;
	if(sscanf(params, "d", carid))
	    return 1;
	new Float:Pos[3];
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	carid2 = CreateVehicle(carid, Pos[0], Pos[1], Pos[2], 0, 0, 1, 9999999);
	SetVehicleHealth(carid2, 1000.0);
	PutPlayerInVehicle(playerid, carid2, 0);
	CarInfo[carid2][cZaladowany]=0;
	CarInfo[carid2][cPaliwo]=100;
	return 1;
}

CMD:gps(playerid, params[])
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		new s[1000];
		strcat(s, "Red Country\n");
		strcat(s, "Kopalnia ko³o Las Venturas\n");
		strcat(s, "Lotnisko w Las Venturas\n");
		strcat(s, "Budowa w Los Santos\n");
		strcat(s, "Molo w Los Santos\n");
		strcat(s, "Flint Country\n");
		strcat(s, "Avispa Country Club w San Fierro\n");
		strcat(s, "Garcia\n");
		strcat(s, "Super Market w San Fierro\n");
		strcat(s, "Firma RiCo\n");
		strcat(s, "Bayside\n");
		strcat(s, "Tierra robada\n");
		strcat(s, "Tama\n");
		strcat(s, "Regular Tom\n");
		strcat(s, "Fort Carson\n");
		strcat(s, "Yellow Bell Golf Course");
		ShowPlayerDialog(playerid, GUI_GPS, DIALOG_STYLE_LIST, "GPS", s, "Wybierz", "Anuluj");
		PlayAudioStreamForPlayer(playerid, "http://www.hard-truck.pl/glosy/czesc.mp3");
	}
	else if(!IsPlayerInAnyVehicle(playerid))
	    SendClientMessage(playerid, KOLOR_CZERWONY, "Nie jesteœ w pojeŸdzie!");
	return 1;
}

CMD:zaladuj(playerid, params[])
{
	new znaleziono=0;
    new v=GetPlayerVehicleID(playerid);
	if(IsPlayerInAnyVehicle(playerid))
 	{
 	    new playerState = GetPlayerState(playerid);
 	    if(playerState == PLAYER_STATE_DRIVER)
 	    {
		    if(GetVehicleModel(v)==403||GetVehicleModel(v)==514||GetVehicleModel(v)==515)//ciê¿arowe
		    {
		        new naczepa = GetVehicleModel(GetVehicleTrailer(v));
			    if(naczepa==435||naczepa==450||naczepa==591||naczepa==584)
			    {
			        for(new i=0; i<ILOSC_ZALADUNKOW; i++)
			        {
						if(DoInRange(playerid, Zaladunki[i][0], Zaladunki[i][1], Zaladunki[i][2], Zaladunki[i][3]))
						{
						    if(ToST(playerid) || ToET(playerid) || ToRT(playerid))
						    {
								new idnaczepy = GetVehicleTrailer(GetPlayerVehicleID(playerid));
								if(CarInfo[idnaczepy][cZaladowany] == 0)
								{
								    new dd[1000];
								    for(new d=0; d<ILOSC_TOWAROW_FIRMA; d++)
								    {
								    	strcat(dd, ListaTowarowFirma1[d]);
									}
									ShowPlayerDialog(playerid, GUI_ZALADUNEK, DIALOG_STYLE_LIST, "Witaj w Firmie", dd, "Wybierz", "Anuluj");
	                                znaleziono=1;
								}
								else
								{
								    SendClientMessage(playerid, KOLOR_CZERWONY, "Ta naczepa jest ju¿ za³adowana!");
								}
							}
							else
						    {
								new idnaczepy = GetVehicleTrailer(GetPlayerVehicleID(playerid));
								if(CarInfo[idnaczepy][cZaladowany] == 0)
								{
								    new dd[1000];
								    for(new d=0; d<ILOSC_TOWAROW; d++)
								    {
								    	strcat(dd, ListaTowarow1[d]);
									}
									ShowPlayerDialog(playerid, GUI_ZALADUNEK, DIALOG_STYLE_LIST, "Witaj w Firmie", dd, "Wybierz", "Anuluj");
	                                znaleziono=1;
								}
								else
								{
								    SendClientMessage(playerid, KOLOR_CZERWONY, "Ta naczepa jest ju¿ za³adowana!");
								}
							}
						}
					}
					if(znaleziono==0)
					{
					    SendClientMessage(playerid, KOLOR_CZERWONY, "Nie jesteœ w za³adunku!");
					}
				}
				else
				    SendClientMessage(playerid, KOLOR_CZERWONY, "Nie masz podczepionej naczepy odpowiedniej do rozworzenia towarów!");
			}
			else
				SendClientMessage(playerid, KOLOR_CZERWONY, "Ten pojazd nie jest zdolny do rozwo¿enia towarów!");
		}
		else
	    	SendClientMessage(playerid, KOLOR_CZERWONY, "Nie jesteœ kierowc¹ tego pojazdu!");
	}
	else
	    SendClientMessage(playerid, KOLOR_CZERWONY, "Nie jesteœ w ¿adnym pojeŸdzie!");
	return 1;
}

CMD:rozladuj(playerid, params[])
{
	new znaleziono=0;
    new v=GetPlayerVehicleID(playerid);
	if(IsPlayerInAnyVehicle(playerid))
 	{
 	    new playerState = GetPlayerState(playerid);
 	    if(playerState == PLAYER_STATE_DRIVER)
 	    {
		    if(GetVehicleModel(v)==403||GetVehicleModel(v)==514||GetVehicleModel(v)==515)//ciê¿arowe
		    {
		        new naczepa = GetVehicleModel(GetVehicleTrailer(v));
			    if(naczepa==435||naczepa==450||naczepa==591||naczepa==584)
			    {
			        for(new i=0; i<ILOSC_ZALADUNKOW; i++)
			        {
						if(DoInRange(playerid, Zaladunki[i][0], Zaladunki[i][1], Zaladunki[i][2], Zaladunki[i][3]))
						{
							new idnaczepy = GetVehicleTrailer(GetPlayerVehicleID(playerid));
							znaleziono=1;
							if(CarInfo[idnaczepy][cZaladowany] == 1)
							{
							    if(CarInfo[idnaczepy][cWyladuj] == 0)
							    {
								    new NazwaTowaru2[6];
									TextDrawShowForPlayer(playerid, NapisPrzyLadowaniu[playerid]);
						   			LadowaniePaseczka[playerid] = SetTimerEx("LadujPasek", 500, true, "d", playerid);
									SetPVarString(playerid, "WybranyToraw", "Brak");
						            SetProgressBarValue(LadowanieBar[playerid], 0);
		                			format(dstring, sizeof(dstring), "Trwa wyladowanie towaru, prosze czekac...");
		            				TextDrawSetString(NapisPrzyLadowaniu[playerid], dstring);
						 			CarInfo[idnaczepy][cWaga]=0;
						 			CarInfo[idnaczepy][cZaladowany]=0;
						 			GetPVarString(playerid, "WybranyToraw", NazwaTowaru2, 6);
						  			strmid(CarInfo[idnaczepy][cTowar], NazwaTowaru2, 0, 34, 34);
						  			TogglePlayerControllable(playerid,0);
						  			Osiagniecia(playerid, 1);
									if(ToST(playerid) || ToET(playerid) || ToRT(playerid))//w firmie
                                      {
                                        SetPlayerScore(playerid, GetPlayerScore(playerid)+2);
                                        GivePlayerMoney(playerid,5100);
                                    }
                                    else //nie w firmie
                                    {
                                        SetPlayerScore(playerid, GetPlayerScore(playerid)+1);
                                        GivePlayerMoney(playerid,2100);
                                    }
								}
								else
								    SendClientMessage(playerid, KOLOR_CZERWONY, "Nie min¹³ twój czas do roz³adunku!");
							}
							else
							    SendClientMessage(playerid, KOLOR_CZERWONY, "Ta naczepa nie jest za³adowana!");
						}
					}
					if(znaleziono == 0)
					{
					    SendClientMessage(playerid, KOLOR_CZERWONY, "Nie jesteœ w roz³adunku!");
					}
				}
				else
				    SendClientMessage(playerid, KOLOR_CZERWONY, "Nie masz podczepionej naczepy odpowiedniej do rozworzenia towarów!");
			}
			else
			    SendClientMessage(playerid, KOLOR_CZERWONY, "Ten typ pojazdu nie jest zdolny do rozwozenia towaru!");
		}
		else
			SendClientMessage(playerid, KOLOR_CZERWONY, "Nie jesteœ kierowc¹ tego pojazdu!");
	}
	else
	    SendClientMessage(playerid, KOLOR_CZERWONY, "Nie jesteœ w ¿adnym pojeŸdzie!");
	return 1;
}

//////////////////
CMD:news(playerid, params[])
{
	if(!ToAdminLevel(playerid, 2))
    	return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla admina!");

	new tresc[64];
	if(sscanf(params, "s[64]", tresc))
	    return 1;

	if(an != 0)
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Aktualnie jest ju¿ jakieœ og³oszenie!");

	format(dstring, sizeof(dstring), "~r~%s:~w~ %s", Nick(playerid), tresc);
	TextDrawSetString(AdminNews3, dstring);
	TextDrawShowForAll(AdminNews1);
	TextDrawShowForAll(AdminNews2);
	TextDrawShowForAll(AdminNews3);
	an = 1;
	ogloszenietim = SetTimer("SchowajOgloszenie", 10000, true);
	return 1;
}

CMD:cautomat(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla HeadAdmina!");

    new TworzenieAutomatu = 1;
    for(new nr = 0; nr < LA; nr++)
    {
        if(TworzenieAutomatu == 1)
        {
            new file[25];
			format(file,sizeof(file),AUTOMATY_FILE,nr);
            if(!DOF_FileExists(file))
			{
                TworzenieAutomatu = 0;
				new Float: Pos[4];
				GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
				GetPlayerFacingAngle(playerid, Pos[3]);
				AutomatInfo[nr][aX]=Pos[0];
				AutomatInfo[nr][aY]=Pos[1];
				AutomatInfo[nr][aZ]=Pos[2];
				AutomatInfo[nr][aAng]=Pos[3]+180;
			    Automat[nr] = CreateDynamicObject(1775, Pos[0], Pos[1], Pos[2], 0.0000, 0.0000, Pos[3]+180);
			    CreateDynamic3DTextLabel("U¿yj /automat\nJedna puszka kosztuje 10$\ni regeneruje 10HP",0x00FF40FF,Pos[0], Pos[1], Pos[2],5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,0,0,-1,5.0);
			    ZapiszAutomat(nr);
			    SetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]+2);
			}
		}
	}
    return 1;
}

CMD:automat(playerid, params[])
{
    new playerState = GetPlayerState(playerid);
    new Float: zycie;
    GetPlayerHealth(playerid, zycie);

    if(playerState != PLAYER_STATE_ONFOOT)
        return SendClientMessage(playerid, 0xFF2F2FFF, "Musisz byæ pieszo!");

	if(zycie == 100.0)
	    return SendClientMessage(playerid, 0xFF2F2FFF, "Jesteœ w pe³ni zdrowy!");

    for(new nr = 0; nr < LA; nr++)
    {
		if(DoInRange(4, playerid, AutomatInfo[nr][aX], AutomatInfo[nr][aY], AutomatInfo[nr][aZ]))
		{
		    if(zycie == 100.0)
		    {
		        SendClientMessage(playerid, KOLOR_ZIELONY, "Jesteœ w pe³ni zdrowy!");
			}
		    if(zycie < 100.0)
		    {
	            SetPlayerHealth(playerid,100.0);
	            GivePlayerMoneyEx(playerid,-40);
	            SendClientMessage(playerid, KOLOR_ZIELONY, "Uzdrowi³eœ siê!");
			}
		}
	}
	return 1;
}

CMD:rsp(playerid, params[])
{
	if(!ToAdminLevel(playerid, 1))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla moderatora!");
	new bool:Uzywany[POJAZDY]=false,v;
	foreach(Player,i)
	{
		if(IsPlayerInAnyVehicle(i))
		{
			v=GetPlayerVehicleID(i);
			Uzywany[v]=true;
			if(IsTrailerAttachedToVehicle(v)) Uzywany[GetVehicleTrailer(v)]=true;
		}
	}
	for(new nr = 1; nr < POJAZDY; nr++)
	{
		if(Uzywany[nr]==false)
		{
			SetVehicleToRespawn(nr);
			SetVehicleParamsEx(nr,false,false,false,false,false,false,false);
		}
	}
	format(dstring, sizeof(dstring),"~r~(%d)%s ~w~zrespawnowal wszystkie nieuzywane pojazdy!",playerid,Nick(playerid));
	NapisText(dstring);
	return 1;
}

CMD:rspall(playerid, params[])
{
	if(!ToAdminLevel(playerid, 1))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla moderatora!");
	for(new nr = 1; nr < POJAZDY; nr++)
	{
		SetVehicleToRespawn(nr);
		SetVehicleParamsEx(nr,false,false,false,false,false,false,false);
	}
	format(dstring, sizeof(dstring),"~r~(%d)%s ~w~zrespawnowal wszystkie pojazdy!",playerid,Nick(playerid));
	NapisText(dstring);
	return 1;
}

CMD:tankujall(playerid, params[])
{
	if(!ToAdminLevel(playerid, 1))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla Moderatora!");
	for(new nr = 1; nr < POJAZDY; nr++)
	{
	    CarInfo[nr][cPaliwo]=100;
	}
	format(dstring, sizeof(dstring),"~r~(%d)%s ~w~zatankowal wszystkie pojazdy!",playerid,Nick(playerid));
	NapisText(dstring);
	return 1;
}

CMD:rspodlicz(playerid, params[])
{
	if(!ToAdminLevel(playerid, 1))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla Moderatora!");
	OnPlayerText(playerid, "Respawn za 10 sekund!");
	cd = 11;
	return 1;
}

CMD:fake(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla HeadAdmina!");
	new tekst[128], id;

	if(sscanf(params, "ds[128]", id, tekst))
	    return 1;

	OnPlayerText(id, tekst);
	return 1;
}

CMD:tajniak(playerid, params[])
{
	if(!ToPolicjant(playerid))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla policjanta!");
	new carid = GetPlayerVehicleID(playerid);
	if(makogut[carid] == 0)
	{
	    makogut[carid] = 1;
	    kogut[carid] = CreateObject(18646, 0.0,0.0,0.0,0.0,0.0,0.0, 250.0);
	    AttachObjectToVehicle(kogut[carid], carid, -0.5, -0.3, 0.75, 0.0, 0.0, 1.5);
	    return 1;
	}
	if(makogut[carid] == 1)
	{
	    makogut[carid] = 0;
	    DestroyObject(kogut[carid]);
	    return 1;
	}
	return 1;
}

CMD:settag(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Nie jesteœ HeadAdminem!");

	new player, tag[64];

	if(sscanf(params, "ds[64]", player, tag))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "U¿yj: /settag <id> <tag>");

    strmid(PlayerInfo[player][pTag], tag, 0, 64, 34);
    format(dstring, sizeof(dstring), "Admin zmieni³ Ci tag na chacie.");
    SendClientMessage(player, KOLOR_ZIELONY, dstring);
    format(dstring, sizeof(dstring), "Zmieni³eœ tag graczowi.");
    SendClientMessage(playerid, KOLOR_ZIELONY, dstring);
    return 1;
}

CMD:mute(playerid, params[])
{
	if(!ToAdminLevel(playerid, 2))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko da admina!");
	new player, czas, powod[64];
	if(sscanf(params, "dds[64]", player, czas, powod))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "U¿yj: /mute <id> <czas w minutach> <powód>");

	if(czas < 0 || czas > 10)
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Czas jest jest nie prawid³owy");

	if(!IsPlayerConnected(player))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Taki gracz nie jest pod³¹czony");

	if(player == playerid)
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Nie mo¿esz mutowaæ sam siebie");

	PlayerInfo[player][pMute]=czas;
	format(dstring, sizeof(dstring), "Administrator %s wyciszy³ Ciê na %d minut za %s.", Nick(playerid), PlayerInfo[player][pMute], powod);
	SendClientMessage(player, KOLOR_ZIELONY, dstring);
	format(dstring, sizeof(dstring), "Wyciszy³eœ %s na %d minut za %s.", Nick(player), PlayerInfo[player][pMute], powod);
	SendClientMessage(playerid, KOLOR_ZIELONY, dstring);
	return 1;
}

CMD:unmute(playerid, params[])
{
	if(!ToAdminLevel(playerid, 2))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko da admina!");
	new player;
	if(sscanf(params, "d", player))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "U¿yj: /unmute <id>");

	if(!IsPlayerConnected(player))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Taki gracz nie jest pod³¹czony!");

	if(player == playerid)
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Nie mo¿esz mutowaæ sam siebie!");

	if(PlayerInfo[player][pMute] == 0)
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Ten gracz nie jest wyciszony!");

	PlayerInfo[player][pMute]=0;
	format(dstring, sizeof(dstring), "Administrator %s odciszy³ Ciê.", Nick(playerid), PlayerInfo[player][pMute]);
	SendClientMessage(player, KOLOR_ZIELONY, dstring);
	format(dstring, sizeof(dstring), "Odciszy³eœ %s.", Nick(player), PlayerInfo[player][pMute]);
	SendClientMessage(playerid, KOLOR_ZIELONY, dstring);
	return 1;
}

CMD:aresztuj(playerid, params[])
{
	if(!ToPolicjant(playerid))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla policji!");
	new player, czas;
	if(sscanf(params, "dd", player, czas))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "U¿yj: /aresztuj <id> <czas>");

	if(!IsPlayerConnected(player))
		return SendClientMessage(playerid, KOLOR_CZERWONY, "Ten gracz nie jest pod³aczony!");

	if(player == playerid)
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Nie mo¿esz arestowaæ sam siebie!");
	    
	new Float: Pos[3];
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	if(!DoInRange(player, Pos[0], Pos[1], Pos[2], 3))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Musisz byc w odleg³oœci 3 metry od gracza!");

	if(PlayerInfo[player][pAresztowany] > 0)
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Ten gracz jest ju¿ aresztowany!");

	PlayerInfo[player][pAresztowany] = czas;
	SetPlayerHealth(player, 100);

	SetPlayerPos(player,264.9535,77.5068,1001.0391);
 	SetPlayerInterior(player,6);
  	SetPlayerVirtualWorld(player,player);
  	SetPlayerWorldBounds(player,268.5071,261.3936,81.6285,71.8745);

   	format(dstring,sizeof(dstring),"Policjant [%d]%s aresztowa³ ciebie na %d minut/y.",playerid,Nick(playerid),czas);
 	SendClientMessage(player,KOLOR_NIEBIESKI,dstring);
 	format(dstring,sizeof(dstring),"Aresztowa³eœ [%d]%s na %d minut/y.",player,Nick(player),czas);
 	SendClientMessage(playerid,KOLOR_NIEBIESKI,dstring);
 	format(dstring,sizeof(dstring),"Policjant [%d]%s "C_ZOLTY"aresztowa³ "C_NIEBIESKI"[%d]%s na "C_ZOLTY"%d minut/y.",playerid,Nick(playerid),player,Nick(player),czas);
 	SendClientMessageToAll(KOLOR_BIALY,dstring);
 	Osiagniecia(player, 3);
 	Wplac(PlayerInfo[playerid][pFrakcja], czas*10);
 	return 1;
}

CMD:mandat(playerid, params[])
{
	if(!ToPolicjant(playerid))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla policjanta");

	new player,
	    kwota,
		pkt;

	if(sscanf(params, "ddd", player, kwota, pkt))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "U¿yj: /mandat <id> <kwota> <punkty karne>");

	if(!IsPlayerConnected(player))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Taki gracz nie jest pod³¹czony");
	    
	new Float: Pos[3];
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	if(!DoInRange(player, Pos[0], Pos[1], Pos[2], 3))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Musisz byc w odleg³oœci 3 metry od gracza!");

	if(playerid == player)
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Nie mo¿esz wystawiæ mandatu samemu sobie");

	if(kwota > 5000 || kwota < 1)
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Nie poprawna kwota");

	if(pkt > 24 || pkt < 1)
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Nie poprawna iloœæ punktów karnych");

	GivePlayerMoneyEx(player, -kwota);
	format(dstring, sizeof(dstring), "Policjant %s da³ Ci mandat na kwotê %d$", Nick(playerid), kwota);
    SendClientMessage(player, KOLOR_CZERWONY, dstring);
    format(dstring, sizeof(dstring), "Wystawi³eœ mandat graczowi %s na kwotê %d$", Nick(player), kwota);
    SendClientMessage(playerid, KOLOR_CZERWONY, dstring);
    PlayerInfo[player][pPunkty]+=pkt;
    Osiagniecia(player, 2);
    Wplac(PlayerInfo[playerid][pFrakcja], (kwota/4)*3);
    return 1;
}

CMD:carmenu(playerid, cmdtext[])
{
	if(PlayerInfo[playerid][pModel] == 0)
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Nie masz kupionego pojazdu!");

	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Musisz byæ kierowc¹ pojazdu!");

    for(new i=0; i<POJAZDY; i++)
	{
	    new vehicleid = GetPlayerVehicleID(playerid);
		if(vehicleid == PrivateCar[i])
		{
		 	if(i == playerid)
		 	{
		  		ShowPlayerDialog(playerid, GUI_POJAZD_PRYWATNY, DIALOG_STYLE_LIST, ""C_ZOLTY"Zarz¹dzanie pojazdem", ""C_ZIELONY"Parkuj pojazd "C_BEZOWY"- funkcja ustawia pojazd gdzie ma siê spawnowaæ.\n"C_ZIELONY"Zmieñ kolor "C_BEZOWY"- ta opcja zmienia kolor pojazdu (na sta³e).\n"C_ZIELONY"Respawn"C_BEZOWY" - wysy³asz pojazd na jego miejsce spawnu\n"C_ZIELONY"Usun "C_BEZOWY"- usówasz swój prywatny pojazd z mapy.", "Wybierz", "Anuluj");
		   	}
		}
	}
	return 1;
}

CMD:skin(playerid, cmdtext[])
{
	ForceClassSelection(playerid);
	SetPlayerHealth(playerid,0);
	return 1;
}

CMD:savepos(playerid, params[])
{
	if(!ToAdminLevel(playerid, 2))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko da admina!");
	new tekst[64];
	if(sscanf(params, "s[64]", tekst))
	return SendClientMessage(playerid, KOLOR_CZERWONY, "U¿yj: /savepos <nazwa pozycji>");

	new Float: X, Float: Y, Float: Z;
	GetPlayerPos(playerid, X, Y, Z);
	format(dstring, sizeof(dstring),""C_BEZOWY"Pozycja "C_ZIELONY"'%f, %f, %f'"C_BEZOWY" zosta³a zapisana w logach serwera pod nazw¹ %s!", X, Y, Z, tekst);
	SendClientMessage(playerid, KOLOR_ZIELONY, dstring);
	printf("[SavePos]%s - %f, %f, %f. Nazwa: %s", Nick(playerid), X, Y, Z, tekst);
	return 1;
}

CMD:lider(playerid, params[])
{
	if(PlayerInfo[playerid][pLider] == 0)
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Musiz byæ na skinie frakcyjnym oraz mieæ lidera danej frakcji!");
	new akcja, player;
	if(sscanf(params, "dd", akcja, player))
		return ShowPlayerDialog(playerid, GUI_LIDER, DIALOG_STYLE_LIST, "Menu lidera frakcji", "Dodaj/Usuñ pracownika\nAktualni pracownicy na serwerze\nStan konta frakcji\nSklepik", "Wybierz", "Anuluj");

	if(akcja != 0 && akcja != 1)
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Z³a akcja... musi ona wynosiæ 1 gdy zatrudniasz lub 0 gdy zwalniasz!");
	    
	if(!IsPlayerConnected(player))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Nie ma takiego gracza!");
	    
	if(playerid == player)
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Nie mo¿esz u¿ywaæ tej komendy na samym sobie!");
	    
	if(akcja == 1)
	{
	    if(PlayerInfo[player][pFrakcja]==0)
	    {
	    	PlayerInfo[player][pFrakcja]=PlayerInfo[playerid][pLider];
	    	SendClientMessage(playerid, KOLOR_CZERWONY, "Zatrudni³eœ gracza do swojej frakcji!");
	    	SendClientMessage(player, KOLOR_CZERWONY, "Zosta³eœ zatrudniony do frakcji :)");
		}
		else
		{
		    SendClientMessage(playerid, KOLOR_CZERWONY, "Ten gracz zatrudniony jest w innej frakcji!");
		    SendClientMessage(playerid, KOLOR_CZERWONY, "Zwolni³eœ gracza z swojej frakcji!");
	    	SendClientMessage(player, KOLOR_CZERWONY, "Zosta³eœ zwolniony z frakcji. Pewnie coœ przeskroba³eœ.");
		}
	}
	if(akcja == 0)
	{
	    if(PlayerInfo[player][pFrakcja]==PlayerInfo[playerid][pLider])
	    {
	    	PlayerInfo[player][pFrakcja]=0;
		}
		else
		{
		    SendClientMessage(playerid, KOLOR_CZERWONY, "Ten gracz nie jest w twojej frakcji!");
		}
	}
	return 1;
}

CMD:pm(playerid, params[])
{
	new player, tekst[256];
	if(sscanf(params, "ds[256]", player, tekst))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "U¿yj: /pm <id> <tekst>");

	format(dstring, sizeof(dstring), ""C_ZOLTY"Prywatna wiadomoœæ do "C_ZIELONY"%s"C_BIALY"["C_ZIELONY"%d"C_BIALY"] "C_ZOLTY" zosta³a wys³ana poprwanie!", Nick(player), player);
	SendClientMessage(playerid, KOLOR_ZOLTY, dstring);
	ostatnia[player] = playerid;
	SendClientMessage(player, KOLOR_ZOLTY, ""C_ZOLTY"========================== "C_BIALY"Prywatan Wiadomoœæ "C_ZOLTY"==========================");
	format(dstring, sizeof(dstring), ""C_TURKUSOWY"Nadawca: "C_ZIELONY"%s"C_BIALY"["C_ZIELONY"%d"C_BIALY"]",Nick(playerid), playerid);
	SendClientMessage(player, KOLOR_ZOLTY, dstring);
	format(dstring, sizeof(dstring), ""C_TURKUSOWY"Odbiorca: "C_ZIELONY"%s"C_BIALY"["C_ZIELONY"%d"C_BIALY"]",Nick(player), player);
	SendClientMessage(player, KOLOR_ZOLTY, dstring);
	format(dstring, sizeof(dstring), ""C_TURKUSOWY"Tresc: "C_POMARANCZOWY"%s", tekst);
	SendClientMessage(player, KOLOR_ZOLTY, dstring);
	SendClientMessage(player, KOLOR_CZERWONY, ""C_CZERWONY"Wpisz "C_ZIELONY"/re <tresc> "C_CZERWONY"by odpowiedzieæ na ostatni¹ wiadomoœæ!");
	SendClientMessage(player, KOLOR_ZOLTY, ""C_ZOLTY"=========================================================================");
	return 1;
}

CMD:re(playerid, params[])
{
	format(dstring, sizeof(dstring), ""C_ZOLTY"Prywatna wiadomoœæ do "C_ZIELONY"%s"C_BIALY"["C_ZIELONY"%d"C_BIALY"] "C_ZOLTY" zosta³a wys³ana poprwanie!", Nick(ostatnia[playerid]), ostatnia[playerid]);
	SendClientMessage(playerid, KOLOR_ZOLTY, dstring);
	ostatnia[ostatnia[playerid]] = playerid;
	SendClientMessage(ostatnia[playerid], KOLOR_ZOLTY, ""C_ZOLTY"========================== "C_BIALY"Prywatan Wiadomoœæ "C_ZOLTY"==========================");
	format(dstring, sizeof(dstring), ""C_TURKUSOWY"Nadawca: "C_ZIELONY"%s"C_BIALY"["C_ZIELONY"%d"C_BIALY"]",Nick(playerid), playerid);
	SendClientMessage(ostatnia[playerid], KOLOR_ZOLTY, dstring);
	format(dstring, sizeof(dstring), ""C_TURKUSOWY"Odbiorca: "C_ZIELONY"%s"C_BIALY"["C_ZIELONY"%d"C_BIALY"]",Nick(ostatnia[playerid]), ostatnia[playerid]);
	SendClientMessage(ostatnia[playerid], KOLOR_ZOLTY, dstring);
	format(dstring, sizeof(dstring), ""C_TURKUSOWY"Tresc: "C_POMARANCZOWY"%s", params);
	SendClientMessage(ostatnia[playerid], KOLOR_ZOLTY, dstring);
	SendClientMessage(ostatnia[playerid], KOLOR_CZERWONY, ""C_CZERWONY"Wpisz "C_ZIELONY"/re <tresc> "C_CZERWONY"by odpowiedzieæ na ostatni¹ wiadomoœæ!");
	SendClientMessage(ostatnia[playerid], KOLOR_ZOLTY, ""C_ZOLTY"=========================================================================");
	return 1;
}

CMD:cmd(playerid, params[])
{
	new dd[1000];
	strcat(dd, ""C_ZIELONY""C_ZIELONY"/pm <id> <tresc> "C_BEZOWY"- wysy³asz prywatn¹ wiadomoœæ do gracza\n");
	strcat(dd, ""C_ZIELONY"/skin "C_BEZOWY"- zmieniasz skin\n");
	strcat(dd, ""C_ZIELONY"/carmenu "C_BEZOWY"- menu zarz¹dzania prywatnym pojazdem\n");
	strcat(dd, ""C_ZIELONY"/pojazd "C_BEZOWY"- menu zarz¹dzania samochodem\n");
	strcat(dd, ""C_ZIELONY"/automat "C_BEZOWY"- kupujesz co nieco w automacie\n");
	strcat(dd, ""C_ZIELONY"/zaladuj "C_BEZOWY"- ³adujesz towar na naczepê\n");
	strcat(dd, ""C_ZIELONY"/rozladuj "C_BEZOWY"- roz³adowujesz pojazd z naczepy\n");
	strcat(dd, ""C_ZIELONY"/gps "C_BEZOWY"- w³¹czasz GPS\n");
	strcat(dd, ""C_ZIELONY"/sklep "C_BEZOWY"- sklepik punktów premium (pp)\n");
	strcat(dd, ""C_ZIELONY"/flip "C_BEZOWY"- stawiasz pojazd na 4 ko³a\n");
	strcat(dd, ""C_ZIELONY"/admini "C_BEZOWY"- lista aktualnych Administratorów na serwerze\n");
	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Komendy zwyk³ego gracza", dd, "Rozumiem", "");
	return 1;
}
CMD:cmds(playerid, params[])
{
	if(ToPolicjant(playerid))
	{
	    new dd[1000];
		strcat(dd, ""C_ZIELONY"/lider "C_BEZOWY"- menu wszystkiego dla lidera\n");
		strcat(dd, ""C_ZIELONY"/mandat <id> <ilosc> <punkty> "C_BEZOWY"- dajesz graczowi mandat\n");
		strcat(dd, ""C_ZIELONY"/aresztuj <id> <dlugosc> "C_BEZOWY"- aresztujesz gracza\n");
		strcat(dd, ""C_ZIELONY"/tajniak "C_BEZOWY"- montujesz kogut w infernusie\n");
		strcat(dd, ""C_ZIELONY"/sprawdz "C_BEZOWY"- kontrolujesz gracza\n");
		strcat(dd, ""C_ZIELONY"/suszarka "C_BEZOWY"- namierzasz graczy w odleg³oœci 90 metrow\n");
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Komendy frakcyjne", dd, "Rozumiem", "");
	}
	if(ToPomoc(playerid))
	{
	    new dd[1000];
	    strcat(dd, ""C_ZIELONY"/lider "C_BEZOWY"- menu wszystkiego dla lidera\n");
		strcat(dd, ""C_ZIELONY"/tankuj "C_BEZOWY"- tankujesz pojazd\n");
		strcat(dd, ""C_ZIELONY"/napraw "C_BEZOWY"- naprawiasz pojazd\n");
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Komendy frakcyjne", dd, "Rozumiem", "");
	}
	return 1;
}

CMD:acmd(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
	    new dd[1000];
		strcat(dd, ""C_ZIELONY"/savepos "C_BEZOWY"- zapisujesz pozycjê w logach serwera\n");
		strcat(dd, ""C_ZIELONY"/mute "C_BEZOWY"- wyciszasz gracza\n");
		strcat(dd, ""C_ZIELONY"/unmute "C_BEZOWY"- dajesz graczowi spowrotem moc g³osu\n");
		strcat(dd, ""C_ZIELONY"/warn "C_BEZOWY"- warnujesz gracza\n");
		strcat(dd, ""C_ZIELONY"/settag "C_BEZOWY"- ustawiasz graczowi tag\n");
		strcat(dd, ""C_ZIELONY"/fake "C_BEZOWY"- fake xD\n");
		strcat(dd, ""C_ZIELONY"/rspodlicz "C_BEZOWY"- odliczenie do respawnu nie u¿ywanych pojazdów\n");
		strcat(dd, ""C_ZIELONY"/rsp "C_BEZOWY"- respawnujesz nie u¿ywane pojazdy\n");
		strcat(dd, ""C_ZIELONY"/rspall "C_BEZOWY"- respawnujesz wszystkie pojazdy\n");
		strcat(dd, ""C_ZIELONY"/tankujall "C_BEZOWY"- tankujesz wszystkie pojazdy\n");
		strcat(dd, ""C_ZIELONY"/cautomat "C_BEZOWY"- tworzysz automat\n");
		strcat(dd, ""C_ZIELONY"/news "C_BEZOWY"- og³oszenie administratora\n");
		strcat(dd, ""C_ZIELONY"/v "C_BEZOWY"- spawnujesz pojazd\n");
		strcat(dd, ""C_ZIELONY"/settime "C_BEZOWY"- ustawiasz czas serwera\n");
		strcat(dd, ""C_ZIELONY"/dajpremium "C_BEZOWY"- dajesz graczowi punkty premium\n");
		strcat(dd, ""C_ZIELONY"/ban "C_BEZOWY"- banujesz gracza\n");
		strcat(dd, ""C_ZIELONY"/kick "C_BEZOWY"- wyrzucasz gracza\n");
		strcat(dd, ""C_ZIELONY"/blok "C_BEZOWY"- blokujesz konto gracza\n");
		strcat(dd, ""C_ZIELONY"/dajlider "C_BEZOWY"- dajesz graczowi lidera danej frakcji\n");
		strcat(dd, ""C_ZIELONY"/dajadmin "C_BEZOWY"- dajesz graczowi admina\n");
		strcat(dd, ""C_ZIELONY"/dajdj "C_BEZOWY"- dajesz komuœ DJ'a HT\n");
		strcat(dd, ""C_ZIELONY"/tpto "C_BEZOWY"- teleportujesz siê do gracza\n");
		strcat(dd, ""C_ZIELONY"/tphere "C_BEZOWY"- teleportujesz gracza do siebie\n");
		strcat(dd, ""C_ZIELONY"/naprawall "C_BEZOWY"- naprawiasz wszystkie wozy\n");
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Komendy HeadAdmina", dd, "Rozumiem", "");
	}
	else if(ToAdminLevel(playerid, 2))
	{
	    new dd[1000];
		strcat(dd, ""C_ZIELONY"/savepos "C_BEZOWY"- zapisujesz pozycjê w logach serwera\n");
		strcat(dd, ""C_ZIELONY"/mute "C_BEZOWY"- wyciszasz gracza\n");
		strcat(dd, ""C_ZIELONY"/unmute "C_BEZOWY"- dajesz graczowi spowrotem moc g³osu\n");
		strcat(dd, ""C_ZIELONY"/warn "C_BEZOWY"- warnujesz gracza\n");
		strcat(dd, ""C_ZIELONY"/rspodlicz "C_BEZOWY"- odliczenie do respawnu nie u¿ywanych pojazdów\n");
		strcat(dd, ""C_ZIELONY"/rsp "C_BEZOWY"- respawnujesz nie u¿ywane pojazdy\n");
		strcat(dd, ""C_ZIELONY"/rspall "C_BEZOWY"- respawnujesz wszystkie pojazdy\n");
		strcat(dd, ""C_ZIELONY"/tankujall "C_BEZOWY"- tankujesz wszystkie pojazdy\n");
		strcat(dd, ""C_ZIELONY"/news "C_BEZOWY"- og³oszenie administratora\n");
		strcat(dd, ""C_ZIELONY"/settime "C_BEZOWY"- ustawiasz czas serwera\n");
		strcat(dd, ""C_ZIELONY"/ban "C_BEZOWY"- banujesz gracza\n");
		strcat(dd, ""C_ZIELONY"/kick "C_BEZOWY"- wyrzucasz gracza\n");
		strcat(dd, ""C_ZIELONY"/blok "C_BEZOWY"- blokujesz konto gracza\n");
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Komendy HeadAdmina", dd, "Rozumiem", "");
	}
	else if(ToAdminLevel(playerid, 1))
	{
	    new dd[1000];
		strcat(dd, ""C_ZIELONY"/rspodlicz "C_BEZOWY"- odliczenie do respawnu nie u¿ywanych pojazdów\n");
		strcat(dd, ""C_ZIELONY"/rsp "C_BEZOWY"- respawnujesz nie u¿ywane pojazdy\n");
		strcat(dd, ""C_ZIELONY"/rspall "C_BEZOWY"- respawnujesz wszystkie pojazdy\n");
		strcat(dd, ""C_ZIELONY"/tankujall "C_BEZOWY"- tankujesz wszystkie pojazdy\n");
		strcat(dd, ""C_ZIELONY"/settime "C_BEZOWY"- ustawiasz czas serwera\n");
		strcat(dd, ""C_ZIELONY"/kick "C_BEZOWY"- wyrzucasz gracza\n");
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Komendy HeadAdmina", dd, "Rozumiem", "");
	}
	return 1;
}

CMD:bank(playerid, params[])
{
    for(new i=0; i<ILOSC_BANKOW; i++)
    {
		if(DoInRange(playerid, Banki[i][0], Banki[i][1], Banki[i][2], 4))
		{
            ShowPlayerDialog(playerid, GUI_BANK, DIALOG_STYLE_LIST, "Menu banku", "Stan konta\nPrzelej pieni¹dze\nWeŸ kredyt gotówkowy\nSp³aæ kredyt", "Wybierz", "Anuluj");
		}
	}
	return 1;
}

CMD:sprawdz(playerid, params[])
{
	if(!ToPolicjant(playerid))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla policji!");
	    
	new player;
	if(sscanf(params, "d", player))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "U¿yj: /sprawdz <id>");
	    
	if(!IsPlayerConnected(player))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Nie ma takiego gracza!");
	    
	new Float: Pos[3];
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	if(!DoInRange(player, Pos[0], Pos[1], Pos[2], 3))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Musisz byc w odleg³oœci 3 metry od gracza!");
	    
	if(!IsPlayerInAnyVehicle(player))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Ten gracz nie jest w pojeŸdzie!");
	    
	new vehicle = GetPlayerVehicleID(player);
	GetVehicleParamsEx(vehicle,engine,lights,alarm,doors,bonnet,boot,objective);
	
 	if(engine)
 	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Pojazd tego gracza ma zapalony silnik!");
 	    
	if(GetPlayerSpeed(playerid) > 1)
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Ten gracz jest w ruchu!");
	    
	new naczepa = GetVehicleTrailer(vehicle);
	
	new naczepamodel = GetVehicleModel(naczepa);
	if(naczepamodel == 0)
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Ten gracz nie ma naczepy!");

    new dd[1000];
    format(dstring, sizeof(dstring),""C_BEZOWY"Gracz: "C_ZIELONY"%s\n", Nick(player));
	strcat(dd,dstring);
	format(dstring, sizeof(dstring),""C_BEZOWY"ID: "C_ZIELONY"%d\n", player);
	strcat(dd,dstring);
	format(dstring, sizeof(dstring),""C_BEZOWY"Pojazd: "C_ZIELONY"%d\n", GetVehicleName(vehicle));
	strcat(dd,dstring);
	format(dstring, sizeof(dstring),""C_BEZOWY"Przeworzony towar: "C_ZIELONY"%s\n", CarInfo[naczepa][cTowar]);
	strcat(dd,dstring);
	format(dstring, sizeof(dstring),""C_BEZOWY"Waga towaru: "C_ZIELONY"%d\n", CarInfo[naczepa][cWaga]);
	strcat(dd,dstring);
	if(PlayerInfo[player][pPrawko] == 1) strcat(dd,""C_BEZOWY"Prawo jazdy: "C_ZIELONY"zdane\n");
    if(PlayerInfo[player][pPrawko] == 0) strcat(dd,""C_BEZOWY"Prawo jazdy: "C_CZERWONY"niezdane\n");
    format(dstring, sizeof(dstring),""C_BEZOWY"Punkty karne: "C_ZIELONY"%d\n", PlayerInfo[player][pPunkty]);
	strcat(dd,dstring);
  	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Informacje o graczu.", dd, "Rozumiem", "");
	return 1;
}

CMD:vip(playerid,params[])
{
	if(!IsVip(playerid)) return SendClientMessage(playerid,-1,"Nie masz VIP'a !");
	PokazCzas(playerid);
	return 1;
}

CMD:dajvip(playerid,params[])
{
	new userid, Days, Hours, timeVip, Msg[128];

	if (!IsPlayerAdmin(playerid))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla HeadAdmina!");
	if (sscanf(params, "uii", userid, Days, Hours)) return SendClientMessage(playerid, 0xFF0000AA, "Uzyj: /dajvip [ID gracza] [Dni] [Godziny]"),1;
	if (IsPlayerConnected(userid))
	{
  		format(forma,sizeof forma,VIP_FILE,Nick(userid));
		DOF_CreateFile(forma);
		timeVip = (Days * 86400) + (Hours * 3600) + gettime();
		DOF_SetInt(forma,"VipCzas",timeVip);


		format(Msg, 128, ""C_ZIELONY"Dosta³eœ "C_ZOLTY"VIP'a "C_ZIELONY"na "C_ZOLTY"%i "C_ZIELONY"Dni i "C_ZOLTY"%i "C_ZIELONY"Godzin ! Komendy: "C_BEZOWY"/cmdvip", Days, Hours);
		SendClientMessage(playerid, -1, Msg);
		DOF_SetInt(forma,"Vip",1);
		DOF_SaveFile();
	}
	return 1;
}

CMD:stacja(playerid, params[])
{
	if(!NaStacjiPaliw(playerid))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Nie jesteœ na stacji paliw Xoomer!");
	if(!IsPlayerInAnyVehicle(playerid))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Nie jesteœ w ¿adnym pojeŸdzie!");
    new v=GetPlayerVehicleID(playerid);
    if(CarInfo[v][cPaliwo] > 98)
        return SendClientMessage(playerid, KOLOR_CZERWONY, "Ten pojazd nie potrzebuje paliwa!");
	new ast=StacjaPaliw(playerid);
    format(dstring, sizeof(dstring), ""C_ZOLTY"Witaj na stacji benzynowej!\n"C_ZIELONY"Do pe³nego baku brakuje Tobie: %d litr/ów.\n1 litr kosztuje ??\n"C_ZOLTY"Ile litrów chcesz zatankowaæ?",100-CarInfo[v][cPaliwo],stacja[ast][3]);
	ShowPlayerDialog(playerid,GUI_STACJA,DIALOG_STYLE_INPUT,""C_POMARANCZOWY"Tankowanie",dstring,"Tankuj","Zamknij");
	return 1;
}

CMD:salon(playerid, params[])
{
	if(!WSalonie(playerid))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Nie jesteœ w salonie!");

	if(IsPlayerInAnyVehicle(playerid))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Musisz byæ pieszo!");
	new dd[1000];
    for(new nr = 0; nr < ILOSC_WOZOW; nr++)
    {
        format(dstring, sizeof(dstring), ""C_ZOLTY"%s "C_BIALY"("C_ZOLTY"Koszt:"C_ZIELONY" %d"C_BIALY")\n", WozyNazwa[nr], WozyID[nr][1]);
        strcat(dd, dstring);
    }
    ShowPlayerDialog(playerid, GUI_SALON, DIALOG_STYLE_LIST, "Wybierz pojazd jaki chcesz kupiæ:", dd, "Kupujê", "Anuluj");

	return 1;
}

CMD:ban(playerid, params[])
{
	new player, tekst[128];
	if(!ToAdminLevel(playerid, 2))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko da admina!");
		
	if(sscanf(params, "ds[128]",player,tekst))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "U¿yj: /ban <id> <powód>");
	
	format(dstring, sizeof(dstring),"~r~(%d)%s zostal zbanowany~n~~y~przez: (%d)%s~n~~w~Za: %s",player,Nick(player),playerid,Nick(playerid),tekst);
	NapisText(dstring);
	BanEx(player, tekst);
	return 1;
}

CMD:kick(playerid, params[])
{
	new player, tekst[128];
	if(!ToAdminLevel(playerid, 1))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko da moderatora!");

	if(sscanf(params, "ds[128]",player,tekst))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "U¿yj: /kick <id> <powód>");

	format(dstring, sizeof(dstring),"~r~(%d)%s zostal wyrzucony~n~~y~przez: (%d)%s~n~~w~Za: %s",player,Nick(player),playerid,Nick(playerid),tekst);
	NapisText(dstring);
	Kick(player);
	return 1;
}

CMD:warn(playerid, params[])
{
	new player, tekst[128];
	if(!ToAdminLevel(playerid, 2))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko da admina!");

	if(sscanf(params, "ds[128]",player,tekst))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "U¿yj: /warn <id> <powód>");
    PlayerInfo[player][pWarn]++;
    if(PlayerInfo[player][pWarn]<4)
    {
		format(dstring, sizeof(dstring),"~r~(%d)%s dostal warna~n~~y~od: (%d)%s~n~~w~Za: %s",player,Nick(player),playerid,Nick(playerid),tekst);
		NapisText(dstring);
		ZapiszKonto(playerid);
	}
	if(PlayerInfo[player][pWarn]==4)
	{
		format(dstring, sizeof(dstring),"~r~(%d)%s dostal 4 warna (BAN)~n~~y~od: (%d)%s~n~~w~Za: %s",player,Nick(player),playerid,Nick(playerid),tekst);
		NapisText(dstring);
		BanEx(player, "4Warn");
		ZapiszKonto(playerid);
	}
	return 1;
}

CMD:blok(playerid, params[])
{
	new player, tekst[128];
	if(!ToAdminLevel(playerid, 2))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko da admina!");

	if(sscanf(params, "ds[128]",player,tekst))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "U¿yj: /blok <id> <powód>");
    PlayerInfo[player][pBlok]=1;
	ZapiszKonto(playerid);
	format(dstring, sizeof(dstring),"~r~(%d)%s zostal zablokowany~n~~y~przez: (%d)%s~n~~w~Za: %s",player,Nick(player),playerid,Nick(playerid),tekst);
	NapisText(dstring);

	return 1;
}

//Speed Trans ID: 10
//Euro Trans ID: 11
//Rico Trans ID: 12

CMD:dajlider(playerid, params[])
{
	new player, id;
	if(!IsPlayerAdmin(playerid))
		return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla HeadAdmina!");

	if(sscanf(params, "dd",player,id))
	    return ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Info", "U¿yj: /dajlider <id> <id frakcji>\n\nID Frakcji:\n\tPolicja - 1\n\tPomoc Drogowa - 2\n\tSpeed Trans - 10\n\tEuro Trans - 11\n\tXoomer - 12", "Rozumiem", "");
	    
	PlayerInfo[player][pFrakcja]=id;
	PlayerInfo[player][pLider]=id;
	ZapiszKonto(player);
	format(dstring, sizeof(dstring), "Admin %s doda³ Ciê jako lidera frakcji.", Nick(playerid));
	ShowPlayerDialog(player, 0, DIALOG_STYLE_MSGBOX, "Info", dstring, "Rozumiem", "");
	format(dstring, sizeof(dstring), "Doda³eœ %s jako lidera frakcji o ID:%d.", Nick(player),id);
	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Info", dstring, "Rozumiem", "");
	return 1;
}
//CreateObject(980,1059.69995117,1802.19995117,12.60000038,0.00000000,0.00000000,0.00000000);
/*CMD:brama(playerid, params[])
{
	if(ToRT(playerid))
	{
	    if(sbramart==1)
	    {
	        MoveObject(bramart,-1209.19995117,-1067.80004883,120.00000000,3);
	        sbramart=0;
		}
		if(sbramart==0)
	    {
	        MoveObject(bramart,-1209.19995117,-1067.80004883,130.00000000,3);
	        sbramart=1;
		}
	}
	if(ToPolicjant(playerid))
	{
	    if(sbramapoli==1)
	    {
			MoveObject(bramapoli, -1572.00000000,661.90002441,0.00000000, 3);
			sbramapoli=0;
		}
		if(sbramapoli==0)
	    {
			MoveObject(bramapoli, -1572.00000000,661.90002441,9.00000000, 3);
			sbramapoli=1;
		}
	}
	if(ToPomoc(playerid))
	{
	    if(sbramapd==1)
	    {
			MoveObject(bramapd, 1059.69995117,1802.19995117,0.60000038, 3);
			sbramapd=0;
		}
		if(sbramapd==0)
	    {
			MoveObject(bramapd, 1059.69995117,1802.19995117,12.60000038, 3);
			sbramapd=1;
		}
	}
    return 1;
}*/
CMD:flip(playerid, cmdtext[])
{
	if(GetPlayerState(playerid)!=PLAYER_STATE_DRIVER)
	{
		SendClientMessage(playerid,KOLOR_CZERWONY,""C_CZERWONY"Nie jesteœ kierowc¹ ¿adnego pojazdu!");
		return 1;
	}
	new Float:Pos[4],v=GetPlayerVehicleID(playerid);
	GetVehiclePos(v,Pos[0],Pos[1],Pos[2]);
	GetVehicleZAngle(v,Pos[3]);
	SetVehiclePos(v,Pos[0],Pos[1],Pos[2]);
	SetVehicleZAngle(v,Pos[3]);
	return 1;
}
CMD:dajadmin(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla HeadAdmina");

	new player, id;
	if(sscanf(params, "dd", player, id))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "U¿yj: /dajadmin <id> <poziom>");
	    
	PlayerInfo[player][pAdmin]=id;
	ZapiszKonto(player);
	format(dstring, sizeof(dstring), "Admin %s da³ Ci admina poziom %d.", Nick(playerid), id);
	ShowPlayerDialog(player, 0, DIALOG_STYLE_MSGBOX, "Info", dstring, "Rozumiem", "");
	format(dstring, sizeof(dstring), "Da³eœ %s admina poziom %d.", Nick(player),id);
	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Info", dstring, "Rozumiem", "");
	return 1;
}

CMD:dj(playerid, params[])
{
	if(PlayerInfo[playerid][pDJ]!=1)
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla DJ'a");
	    
	new url[128];
	if(sscanf(params, "s[128]", url))
	    return ShowPlayerDialog(playerid, PANEL_DJ, DIALOG_STYLE_INPUT, "Panel DJ'a", "Wpisz adres url nutki.\n\n"C_CZERWONY"Przyk³ad:\nhttp://www.htmuza.xaa.pl/1.mp3\n\nMo¿esz tak¿e odtwarzaæ z komendy /dj <url>\n"C_CZERWONY"Przyk³ad:\n/dj http://www.htmuza.xaa.pl/1.mp3\n\nPoni¿ej wpisz adres nutki:", "Play", "Anuluj");

    foreach(Player, i)
	{
		StopAudioStreamForPlayer(i);
		PlayAudioStreamForPlayer(i, url);
	}
	return 1;
}

CMD:admini(playerid, params[])
{
	new ss[1000];
    strcat(ss, "Oto lista aktualnych administratorów online na serwerze:");
	foreach(Player, i)
	{
	    if(IsPlayerAdmin(playerid))
	    {
	        format(dstring, sizeof(dstring), "\t"C_ZIELONY"%s "C_BIALY"["C_ZOLTY"%d"C_BIALY"] - "C_CZERWONY"HeadAdmin\n", Nick(i), i);
	        strcat(ss, dstring);
		}
	}
	foreach(Player, i)
	{
	    if(PlayerInfo[i][pAdmin]==2)
	    {
	        format(dstring, sizeof(dstring), "\t"C_ZIELONY"%s "C_BIALY"["C_ZOLTY"%d"C_BIALY"] - "C_NIEBIESKI"Admin\n", Nick(i), i);
	        strcat(ss, dstring);
		}
	}
	foreach(Player, i)
	{
	    if(PlayerInfo[i][pAdmin]==1)
	    {
	        format(dstring, sizeof(dstring), "\t"C_ZIELONY"%s "C_BIALY"["C_ZOLTY"%d"C_BIALY"] - "C_ZIELONY"Moderator\n", Nick(i), i);
	        strcat(ss, dstring);
		}
	}
	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Aktualni administratorzy", ss, "Gotowe", "");
	return 1;
}
/*CMD vipa*/
CMD:vnrg(playerid, params[])
{
	if(!IsVip(playerid))
	    return SendClientMessage(playerid, KOLOR_ZOLTY, "Komenda tylko dla VIP'a");
	    
	new Float: Pos[4];
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	GetPlayerFacingAngle(playerid, Pos[3]);
	PrivNrg[playerid] = AddStaticVehicleEx(522,Pos[0],Pos[1],Pos[2],Pos[3],-1,-1,SPAWN);
	PutPlayerInVehicle(playerid, PrivNrg[playerid], 0);
	return 1;
}

CMD:vnapraw(playerid, cmdtext[])
{
	if(!IsVip(playerid))
	    return SendClientMessage(playerid, KOLOR_ZOLTY, "Komenda tylko dla VIP'a");
	if(!IsPlayerInAnyVehicle(playerid))
	{
		SendClientMessage(playerid, KOLOR_CZERWONY, ""C_CZERWONY"Nie jesteœ kierowc¹ ¿adnego pojazdu!");
		return 1;
	}
	if(GetPlayerSpeed(playerid)>1)
	{
		SendClientMessage(playerid, KOLOR_CZERWONY, ""C_CZERWONY"Musisz siê zatrzymaæ, aby u¿yæ tej komendy!");
		return 1;
	}
	new Float:HP;
	new vehicleid = GetPlayerVehicleID(playerid);
	GetVehicleHealth(vehicleid,HP);
	if(HP>=999.0)
	{
		SendClientMessage(playerid, KOLOR_CZERWONY, ""C_CZERWONY"Ten pojazd jest w perfekcyjnym stanie!");
		return 1;
	}
	RepairVehicle(vehicleid);
	SetVehicleHealth(vehicleid,1000.0);
	format(dstring,sizeof(dstring),""C_ZOLTY"Pojazd naprawiony!");
	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Naprawa pojazdu!", dstring, "Rozumiem", "Ok");
	return 1;
}

CMD:vtankuj(playerid, cmdtext[])
{
	if(!IsVip(playerid))
	    return SendClientMessage(playerid, KOLOR_ZOLTY, "Komenda tylko dla VIP'a");
	if(!IsPlayerInAnyVehicle(playerid))
	{
		SendClientMessage(playerid, KOLOR_CZERWONY, ""C_CZERWONY"Nie jesteœ kierowc¹ ¿adnego pojazdu!");
		return 1;
	}
	if(GetPlayerSpeed(playerid)>1)
	{
		SendClientMessage(playerid, KOLOR_CZERWONY, ""C_CZERWONY"Musisz siê zatrzymaæ, aby u¿yæ tej komendy!");
		return 1;
	}
	new vehicleid = GetPlayerVehicleID(playerid);
	if(CarInfo[vehicleid][cPaliwo]>=100)
	{
		SendClientMessage(playerid, KOLOR_CZERWONY, ""C_CZERWONY"Ten pojazd jest w pe³ni zatankowany!");
		return 1;
	}
	CarInfo[vehicleid][cPaliwo]=100;
	format(dstring,sizeof(dstring),""C_ZOLTY"Pojazd zatankowany!");
	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Tankowanie pojazdu!", dstring, "Rozumiem", "Ok");
	return 1;
}
COMMAND:p(playerid,cmdtext[])
{
	return cmd_pojazd(playerid,cmdtext);
}
CMD:pojazd(playerid, cmdtext[])
{
	if(GetPlayerState(playerid)!=PLAYER_STATE_DRIVER)
	{
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Zarz¹dzanie pojazdem!", ""C_CZERWONY"Nie jesteœ kierowc¹ pojazdu!", "Rozumiem", "");
		return 1;
	}
	ShowPlayerDialog(playerid,GUI_POJAZD,DIALOG_STYLE_LIST,""C_ZOLTY"Zarz¹dzanie pojazdem",""C_ZIELONY"W³¹cz"C_BIALY" / "C_CZERWONY"Wy³¹cz "C_ZOLTY"silnik\n"C_ZIELONY"W³¹cz"C_BIALY" / "C_CZERWONY"Wy³¹cz "C_ZOLTY"lampy\n"C_ZIELONY"Otwórz"C_BIALY" / "C_CZERWONY"Zamknij "C_ZOLTY"maskê\n"C_ZIELONY"Otwórz"C_BIALY" / "C_CZERWONY"Zamknij "C_ZOLTY"baga¿nik\n"C_ZIELONY"Otwórz"C_BIALY"  / "C_CZERWONY"Zamknij "C_ZOLTY"drzwi","Wybierz","Zamknij");
	return 1;
}

CMD:dajdj(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla HeadAdmina");
	new player;
	if(sscanf(params, "d", player))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "U¿yj: /dajdj <id>");
	    
    if(!IsPlayerConnected(player))
        return SendClientMessage(playerid, KOLOR_CZERWONY, "niepoprawne ID");
	if(PlayerInfo[player][pDJ] == 0)
	{
		PlayerInfo[player][pDJ]=1;
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "DJ menu!","Zosta³eœ mianowany DJ'em HT!\nKomenda dj'a to /dj", "Rozumiem", "");
        SendClientMessage(playerid, KOLOR_CZERWONY, "DJ przyznany");
		return 0;
	}
	if(PlayerInfo[player][pDJ] == 1)
	{
	    PlayerInfo[player][pDJ]=0;
	    ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "DJ menu!","Zabrano Ci dj'a", "Rozumiem", "");
	    SendClientMessage(playerid, KOLOR_CZERWONY, "DJ odebrany");
	    return 0;
	}
	return 1;
}

CMD:tphere(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla HeadAdmina");
	new player;
	if(sscanf(params, "d", player))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "U¿yj: /tpto <id>");
    if(!IsPlayerConnected(player))
        return SendClientMessage(playerid, KOLOR_CZERWONY, "niepoprawne ID");

	new Float: Pos[3];
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	SetPlayerPos(player, Pos[0], Pos[1], Pos[2]);
	return 1;
}
CMD:tpto(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "Komenda tylko dla HeadAdmina");
	new player;
	if(sscanf(params, "d", player))
	    return SendClientMessage(playerid, KOLOR_CZERWONY, "U¿yj: /tphere <id>");
    if(!IsPlayerConnected(player))
        return SendClientMessage(playerid, KOLOR_CZERWONY, "niepoprawne ID");

	new Float: Pos[3];
	GetPlayerPos(player, Pos[0], Pos[1], Pos[2]);
	SetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	return 1;
}

CMD:suszarka(playerid, cmdtext[])
{
	if(!ToPolicjant(playerid))
	{
		SendClientMessage(playerid, KOLOR_CZERWONY,""C_CZERWONY"Nie jesteœ w mundurze lub nie pracujesz w policji!");
		return 1;
	}
	if(GetPlayerInterior(playerid)!=0)
	{
		SendClientMessage(playerid, KOLOR_CZERWONY,""C_CZERWONY"Nie mo¿esz u¿ywaæ tej komendy w interiorze!");
		return 1;
	}
	new Float:Pos[3];
	GetPlayerPos(playerid,Pos[0],Pos[1],Pos[2]);
	SendClientMessage(playerid,KOLOR_BIALY,"Pojazdy namierzone suszark¹:");
	foreach(Player,i)
	{
		if(GetPlayerState(i)==PLAYER_STATE_DRIVER&&GetPlayerSpeed(i)>5&&DoInRange(i,Pos[0],Pos[1],Pos[2],90.0)&&i!=playerid)
		{
			new w=GetPlayerSpeed(i);
			format(dstring,sizeof(dstring),"Policjant [%d]%s namierzy³ twój pojazd 'suszark¹',wskaza³o: "C_ZOLTY"%d km/h",playerid,Nick(playerid),w);
			SendClientMessage(i,KOLOR_NIEBIESKI,dstring);
			format(dstring,sizeof(dstring),"Pojazd %s,kierowca: [%d]%s, prêdkoœæ: "C_ZOLTY"%d km/h",GetVehicleName(GetPlayerVehicleID(i)),i,Nick(i),w);
			SendClientMessage(playerid,KOLOR_NIEBIESKI,dstring);
		}
	}
	return 1;
}

CMD:autor(playerid, params[])
{
    ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Autor mapy", ""C_CZERWONY"Autorem mapy jest Inferno\n"C_CZERWONY"GG: 34773974  /n  Mapê przerobi³ na potrzeby serwera: Cpuidek", "Rozumiem", "");
    return 1;
}
