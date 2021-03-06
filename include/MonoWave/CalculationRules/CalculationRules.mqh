#include <MonoWave\CalculationRules\WavesDirection.mqh>
#include <MonoWave\CalculationRules\RulesWaves.mqh>
#include <MonoWave\CalculationRules\Calc_m1_Left_Right_Wave_v2.mqh>
#include <MonoWave\CalculationRules\Draw_m1_Left_Right_Wave.mqh>
#include <MonoWave\CalculationRules\Designations\ViewDesignations.mqh>
#include <MonoWave\Models\GartleyPesavento.mqh>

void CheckRulesWave(int calcwave = 0){
   double max_point_wave, min_point_wave;   
   double check_m1;

   //DEBUG
   //Print("Begin calc");
      
   int limit = 0;
   if (calcwave == 0){
      limit = wave_count_in_rule;
   }else{
      limit = calcwave;
   }
   //for (int i = limit-1; i >= 0; i--){
   for (int i = 1; i < limit; i++){
      Initialize_Wave_m();
      // параметри на М1 ---------------------------------------------------------------
      max_point_wave = MonoWave_Rule[i][3]; //май-високата точка         
      min_point_wave = MonoWave_Rule[i][4]; //най-ниската точка        
     
      m1_length = MathAbs(MonoWave_Rule[i+1][2] - MonoWave_Rule[i][2]);
      
      if (m1_length > 0){
         
         m1_index_count = 0;
         ArrayInitialize(WavesDirection, 0);
         
         check_m1 = false;
      
         WavesDirection[m1_index_count][0] = MonoWave_Rule[i+1][2];
         WavesDirection[m1_index_count][1] = MonoWave_Rule[i][2];
         WavesDirection[m1_index_count][2] = MonoWave_Rule[i+1][1];
         WavesDirection[m1_index_count][3] = MonoWave_Rule[i][1];  
         WavesDirection[m1_index_count][4] = MonoWave_Rule[i][0];  
               
         WavesDirection[m1_index_count][8] = MonoWave_Rule[i][3]; //MAX - Максимално ниво на вълната
         WavesDirection[m1_index_count][9] = MonoWave_Rule[i][4]; //MIN - Минимално ниво на вълната   
         
         WavesDirection[m1_index_count][10] = i; //Index 
   
         if (WavesDirection[m1_index_count][0] < WavesDirection[m1_index_count][1]){
            WavesDirection[m1_index_count][7] = 1;
         }else{
            WavesDirection[m1_index_count][7] = -1;
         }
         
         m1_index_count++;    
      
         if (MonoWave_Rule[i+1][1] > m1_mark && MonoWave_Rule[i][1] <= m1_mark) {
            check_m1 = true;
         }else{
            check_m1 = false;
         }
         
         //DEBUG
         //check_m1 = true;
         //----------------------
         
         //за пресмятане отлявао на м1 = м0, м(-1), м(-2), м(-3) .....
         Calc_Wave_Left_m1(MonoWave_Rule, wave_count_in_rule, i, WavesDirection, max_point_wave, min_point_wave, true /*check_m1*/);      
         //за пресмятане отдясно на м1 = м2, м3, м4, м5 .....
         Calc_Wave_Right_m1(MonoWave_Rule, wave_count_in_rule, i, WavesDirection, max_point_wave, min_point_wave, true/*check_m1*/);              
         //пресмята времемто за което м1 пробива екстремумите на м0
         Calc_break_m1_m0(WavesDirection);
                          
         SetLineWavesDirection(WavesDirection, check_m1, m1_mark > 0);            
         
         CalcRules(i, m1_length, m2_length, m0_length, check_m1);      
         
         
         
         if (PesaventoModels) {
//            Searching_models_3();
            //Butterfly_models();
            //Gartley_models();
            //Crab_models();
            //Chiroptera_models();
            //Pattern_5_0_models();
         }            
      }         
   }
   //DEBUG
   //Print("END calc");
}   


int CalcRules(int index_wave, double m1_length, double m2_length, double m0_length, bool check_m1 = false){

   if (!(m1_length != 0 && m2_length != 0 && m0_length != 0)) return(0);   	       	   

   int rule_type;  
   string rules_types, condition_type, category;
      
   rules_types = Rules_Base(m1_length, m2_length); 
               
   int len = StringLen(rules_types);
   
   string rule_str, rule_alt = "";
   string rule_print, save_rules, save_rules_alt = "";   

   //--Правилото което отговаря точно----------
   rule_type = StrToInteger(rules_types);         
   condition_type = "";
   category = "";
   switch (rule_type){
      case 1: condition_type = Condition_1(m0_length, m1_length); break;
      case 2: condition_type = Condition_2(m0_length, m1_length); break;
      case 3: condition_type = Condition_3(m0_length, m1_length); break;
      case 4: condition_type = Condition_4(m0_length, m1_length, m2_length, m3_length, category); break;                       
      default: condition_type = Condition_567(m0_length, m1_length); break;
   }
   if (rule_type == 4){
      save_rules = rules_types + "-" + condition_type + "-" + category;   
   }else{
      save_rules = rules_types + "-" + condition_type;  
   }
   
   //if (!(rule_type >= 5))// && condition_type == "b" && check_m1))
   //{
   //   return(0);
   //}  
   
   //DEBUG
   //Searching_models_3();
   //---------------------
   
   
   if (check_m1){
      int index_category = 0;
      if (category == "i") index_category = 1;
      if (category == "ii") index_category = 2;
      if (category == "iii") index_category = 3;
      if (category == "i,ii") index_category = 1;     
   
      string info = Symbol() + ": "+ DoubleToStr(Period(),0);
      if(IsDllsAllowed()){
         ViewTestRules(rule_type, condition_type, index_category, Symbol(), DoubleToStr(Period(),0));
      }            
      //Sleep(50);
      //double temp[10];              
      //ArrayInitialize(temp, 1000);
      //temp[0] = 10;
      //Print(DataTransfer(array_ChartPoints, 900*3), " - test");
   }
   
   
   if (ViewDesignations) {      
      CalcDesignation(index_wave, rule_type, condition_type, category);
   }
   
   int win = -1;
   if (!ViewRuleInChart) {      
      win = WindowFind( "Rules" );
      if ( win < 0 ) { return(-1); }
   }   
         
   if (RulesAltView){
      //--Алтернативни правила в рамките на 4% отклонение-----------
      rules_types = Rules_Alt(0, m1_length, m2_length);
      len = StringLen(rules_types);
      
      for (int k = 0; k < len; k++){
         rule_str = StringSubstr(rules_types, k, 1);
         rule_type = StrToInteger( rule_str );
         condition_type = ""; 
         
         switch (rule_type){
            case 1: condition_type = Condition_1_Alt(m0_length, m1_length); break;
            case 2: condition_type = Condition_2_Alt(m0_length, m1_length); break;
            case 3: condition_type = Condition_3_Alt(m0_length, m1_length); break;
            case 4: condition_type = Condition_4_Alt(m0_length, m1_length, m2_length, m3_length); break;                       
            default: condition_type = Condition_567_Alt(m0_length, m1_length); break;
         }            
         
         rule_alt = rule_str + "-" + condition_type; 

         if (rule_alt != save_rules){
            save_rules_alt = save_rules_alt + rule_str + "-" + condition_type + "/";                   
         }            
      }
   }                                        
   
   if (save_rules_alt == ""){
      rule_print = save_rules;
   }else{
      save_rules_alt = StringSubstr(save_rules_alt, 0, StringLen(save_rules_alt)-1);
      rule_print = save_rules + " ("+save_rules_alt+")";
   }
   
   int up_down_wave = 0;
   if (MonoWave_Rule[index_wave+1][2] < MonoWave_Rule[index_wave][2]){ 
      //нарастваща вълна        
      up_down_wave = 1;         
   }else{
      //намалаваща вълна        
      up_down_wave = 2;
   }                
      
   
   if (ViewRuleInChart){
      SetWaveRule(MonoWave_Rule[index_wave][1], rule_print, MonoWave_Rule[index_wave][2], 
         RuleSizeText, RuleColor, "Rule_", "", up_down_wave);
   }else{         
      SetWaveRule_indicator_down(win, MonoWave_Rule[index_wave][1], rule_print, MonoWave_Rule[index_wave][2], 
         RuleSizeText, RuleColor, "Rule_", "");         
   }              
}

