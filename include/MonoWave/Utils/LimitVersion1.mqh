//--------------------------------
//опция за изключване на някой възможности на индикатора
//при демо верисята
bool TruncationVersion1 = true;
bool TruncationVersion2 = true;
//--------------------------------

double Tolerance = 0.04;
bool HighTimeWaveView = false;
bool NumberWaveView = false;
string DefaultTime = "all";

//-----------Опции които се изключват за демо версията---------------
bool  RulesView = false;
bool  ViewDesignations = false;
bool  ViewRuleInChart = false;

bool  RulesAltView = false;
color RuleColor = MidnightBlue;
int   RuleSizeText = 8;

bool  ListIndicators = false;
color ListIndicatorsColor = MidnightBlue;
int   ListSizeText = 6;
bool PesaventoModels = false;
//-------------------------------------------------------------------
bool MonoWavesAlternation = true;
bool PointWaveView = true;
bool ChartCompression = false;
bool PrintView = false;

//---- buffers
double Wave[];
double Point_Wave[];
double up_time_wave[];
double MonoAlternation[];

double VerticalLine1[];
double VerticalLine2[];

double GroupPoints[];

double Grid_Upper_Level;

#define const_wavecount 900

#include <MonoWave\Utils\Security.mqh>
#include <MonoWave\Utils\Information.mqh>

#include <MonoWave\Utils\WorkWithObjects.mqh>
#include <MonoWave\Utils\Utils.mqh>
#include <MonoWave\Utils\Get_Object_with_Work.mqh>  
#include <MonoWave\Utils\NumberWaves.mqh>

#include <MonoWave\CreationWaves\MonoWaves.mqh>
#include <MonoWave\CreationWaves\ActivityTypeWaves.mqh>
#include <MonoWave\CreationWaves\PointsWaves.mqh>