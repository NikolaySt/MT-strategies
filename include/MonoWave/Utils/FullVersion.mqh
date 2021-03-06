double Tolerance = 0.04;
bool HighTimeWaveView = false;

extern bool NumberWaveView = true;
extern string DefaultTime = "all";

extern bool  RulesView = true;
extern bool  ViewDesignations = true;
extern bool  ViewOnly_L = false;
extern bool  ViewRuleInChart = false;

bool  RulesAltView = true;
color RuleColor = MidnightBlue;
int   RuleSizeText = 8;


bool  ListIndicators = false;
color ListIndicatorsColor = MidnightBlue;
int   ListSizeText = 6;

extern bool PesaventoModels = false;


extern bool MonoWavesAlternation = true;
extern bool PointWaveView = true;
extern bool ChartCompression = false;
extern bool PrintView = false;

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

#include <MonoWave\Utils\DllUtils.mqh>
#include <MonoWave\Utils\Information.mqh>

#include <MonoWave\Utils\WorkWithObjects.mqh>
#include <MonoWave\Utils\Utils.mqh>
#include <MonoWave\Utils\Get_Object_with_Work.mqh>  
#include <MonoWave\Utils\NumberWaves.mqh>

#include <MonoWave\CreationWaves\MonoWaves.mqh>
#include <MonoWave\CreationWaves\ActivityTypeWaves.mqh>
#include <MonoWave\CreationWaves\PointsWaves.mqh>

#include <MonoWave\CalculationRules\CalculationRules.mqh>  


