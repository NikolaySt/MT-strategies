#include <MonoWave\CalculationRules\Designations\UtilsRules.mqh>
#include <MonoWave\CalculationRules\Designations\UtilsDesignations.mqh>
#include <MonoWave\CalculationRules\Designations\UtilsNotes.mqh>

//Правило 1------------------------------------------------------------
#include <MonoWave\CalculationRules\Designations\Rule_1\rule_1_a.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_1\rule_1_b.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_1\rule_1_c.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_1\rule_1_d.mqh>

//Правило 2------------------------------------------------------------
#include <MonoWave\CalculationRules\Designations\Rule_2\rule_2_a.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_2\rule_2_b.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_2\rule_2_c.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_2\rule_2_d.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_2\rule_2_e.mqh>

//Правило 3------------------------------------------------------------

//Правило 4------------------------------------------------------------
           //4-a-------------------------------------------------------
#include <MonoWave\CalculationRules\Designations\Rule_4\4_a\rule_4_a_i.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_4\4_a\rule_4_a_ii.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_4\4_a\rule_4_a_iii.mqh>
           //4-b-------------------------------------------------------
#include <MonoWave\CalculationRules\Designations\Rule_4\4_b\rule_4_b_i.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_4\4_b\rule_4_b_ii.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_4\4_b\rule_4_b_iii.mqh>
           //4-c-------------------------------------------------------
#include <MonoWave\CalculationRules\Designations\Rule_4\4_c\rule_4_c_i.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_4\4_c\rule_4_c_ii.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_4\4_c\rule_4_c_iii.mqh>
           //4-d-------------------------------------------------------
#include <MonoWave\CalculationRules\Designations\Rule_4\4_d\rule_4_d_i_ii.mqh>                             
#include <MonoWave\CalculationRules\Designations\Rule_4\4_d\rule_4_d_iii.mqh>
           //4-e-------------------------------------------------------
#include <MonoWave\CalculationRules\Designations\Rule_4\4_e\rule_4_e_i_ii.mqh>                                        
#include <MonoWave\CalculationRules\Designations\Rule_4\4_e\rule_4_e_iii.mqh> 

//Правило 5------------------------------------------------------------
#include <MonoWave\CalculationRules\Designations\Rule_5\rule_5_a.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_5\rule_5_b.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_5\rule_5_c.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_5\rule_5_d.mqh>

//Правило 6------------------------------------------------------------
#include <MonoWave\CalculationRules\Designations\Rule_6\rule_6_a.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_6\rule_6_b.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_6\rule_6_c.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_6\rule_6_d.mqh>

//Правило 7------------------------------------------------------------
#include <MonoWave\CalculationRules\Designations\Rule_7\rule_7_a.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_7\rule_7_b.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_7\rule_7_c.mqh>
#include <MonoWave\CalculationRules\Designations\Rule_7\rule_7_d.mqh>

void CalcDesignation(int index_wave, int rule, string condition, string category = ""){
   int win_desig = -1;
   win_desig = WindowFind( "Designations" );
   if ( win_desig < 0 ) { return(-1); }
      
   InitializeDesignation();
   InitializeNotes();
      
   string designation ="";   
   switch (rule){
      case 1: 
         if (condition == "a") Rule_1_a();
         if (condition == "b") Rule_1_b();
         if (condition == "c") Rule_1_c();
         if (condition == "d") Rule_1_d();
         break;    
      case 2: 
         if (condition == "a") Rule_2_a();
         if (condition == "b") Rule_2_b();
         if (condition == "c") Rule_2_c();
         if (condition == "d") Rule_2_d();
         if (condition == "e") Rule_2_e();
         break;
      case 4: 
         if (condition == "a") {
            if (category == "i") Rule_4_a_i(); 
            if (category == "ii") Rule_4_a_ii();
            if (category == "iii") Rule_4_a_iii();
         }
         if (condition == "b") {
            if (category == "i") Rule_4_b_i(); 
            if (category == "ii") Rule_4_b_ii(); 
            if (category == "iii") Rule_4_b_iii(); 
         }   
         if (condition == "c") {
            if (category == "i") Rule_4_c_i(); 
            if (category == "ii") Rule_4_c_ii(); 
            if (category == "iii") Rule_4_c_iii();             
         }       
         if (condition == "d") {
            if (category == "i,ii") Rule_4_d_i_ii();            
            if (category == "iii") Rule_4_d_iii(); 
         }        
         if (condition == "e") {
            if (category == "i,ii") Rule_4_e_i_ii();            
            if (category == "iii") Rule_4_e_iii(); 
         }                            
         break;  
                            
      case 5: 
         if (condition == "a") Rule_5_a();
         if (condition == "b") Rule_5_b();
         if (condition == "c") Rule_5_c();
         if (condition == "d") Rule_5_d();
         break;    

      case 6: 
         if (condition == "a") Rule_6_a();
         if (condition == "b") Rule_6_b();
         if (condition == "c") Rule_6_c();
         if (condition == "d") Rule_6_d();
         break;    
                                          
      case 7: 
         if (condition == "a") Rule_7_a();         
         if (condition == "b") Rule_7_b();
         if (condition == "c") Rule_7_c();
         if (condition == "d") Rule_7_d();
         break;            
   }                      
    
   AddDesignationToChart(win_desig, index_wave); 
   //AddNotesToChart(win_desig, index_wave);
}     

int AddDesignationToChart(int win, int index_wave){
   color textcolor;  
   double level;
   double begin_level = 200;
   double Price_Level = begin_level;
   string desig, info, paragraph;
   int count = CountArrayDesignations();
   int shift_position = 0;
   int direct;
   bool check_PriceLevel;
/*
//----------------DEBUG - Vremenno-----------------
  int handle;
  handle=FileOpen("myrules.txt", FILE_CSV|FILE_READ|FILE_WRITE,",");
  if(handle<1)
    {
     Print("File my_rules.txt not found, the last error is ", GetLastError());
     return(false);
    }     
    FileSeek(handle, FileSize(handle) , SEEK_SET);     
//-----------------------------------------
*/
   for (int i = 0; i < count; i++ ){
      Designation_Get(i, desig, info, paragraph);      
      textcolor = ColorDesgination(desig);                                                  
      
      //-----------------------------------
        // FileWrite(handle, desig);
         
      //-----------------------------------
      check_PriceLevel = true; 
      
      shift_position = DirectionEndShift(1);   
      
      if (info == "-1") {shift_position = DirectionEndShift(-1); check_PriceLevel = false;}
      if (info == "-2") {shift_position = DirectionEndShift(-2); check_PriceLevel = false;}      
      if (info == "-3") {shift_position = DirectionEndShift(-3); check_PriceLevel = false;}
      
      if (info == "0") {shift_position = DirectionEndShift(0); check_PriceLevel = false;} 
      if (info == "2") {shift_position = DirectionEndShift(2); check_PriceLevel = false;}      
      if (info == "3") {shift_position = DirectionEndShift(3); check_PriceLevel = false;}   
      
      if (info == "()") desig = "(" + desig + ")";         
      if (info == "[]") desig = "[" + desig + "]";         
               
      // обозначение което се нуждае от допълнително потвърждения
      //пример 4.а-i - абзац 3 обозна4ение L5 - двоетапно потвърждение.
      //Глава 6 от книгата MEW 2.0
      if (info == "!") desig = desig + "!";   
      
      //Поставя пропаднала вълна на направлението когато е повече от 3 моновълни [или група]
      // на дадените моновълни след номера на направлението
      if (info == "31") {shift_position = MonoWaveShiftInDirection(/*направление*/3, /*монвълна от напр.*/1); check_PriceLevel = false;}
      if (info == "33") {shift_position = MonoWaveShiftInDirection(/*направление*/3, /*монвълна от напр.*/3); check_PriceLevel = false;}

      
      if (desig == desig_fall) {
         direct = StrToInteger(info);
         shift_position = DirectionEndShift(direct) + (DirectionBeginShift(direct) - DirectionEndShift(direct))/2;         
         textcolor = Red;
      }
      if (desig == desig_note){
         textcolor = Red;   
      }
      
      if (!check_PriceLevel){
         level = begin_level - 25*5;
      }else{
         level = Price_Level;  
      }
      
      if (ViewOnly_L){
         if (StringFind(desig, desig_L5, 0) != -1 || StringFind(desig, desig_L3, 0) != -1  || StringFind(desig, desig_all, 0) != -1 ){ 
           //(desig == desig_L5 || desig == desig_L3){
            SetDesignationInChart(
               win, shift_position, desig, level, 
               RuleSizeText, textcolor, "Desig", DoubleToStr(i,0), paragraph); 
               
            if (check_PriceLevel){   
               Price_Level = Price_Level - 25;            
            }                
         }          
      }else{           
         SetDesignationInChart(
            win, shift_position, desig, level, 
            RuleSizeText, textcolor, "Desig", DoubleToStr(i,0), paragraph); 
         if (check_PriceLevel){   
            Price_Level = Price_Level - 25;            
         }            
      }         
               

   }
/*
//----------------Vremenno-----------------  
  if(handle>1)
    {
     
     FileClose(handle);
    }
   
//-----------------------------------------
*/
   return(0);
}   


int SetDesignationInChart(int win, int shift, string rules_str, double price, 
   int RuleSizeText, color RuleColor, string base_name, string index_name = "", string paragraph = ""){
   
   if (price == 0 || shift >= Bars){
      return(0);
   }
   string name_wave = base_name + "(" + paragraph + ")-"+ index_name + "^" + DoubleToStr(shift, 0) ;
   if(ObjectFind(name_wave)<0)
      ObjectCreate(name_wave, OBJ_TEXT, win, 0, 0);   

   ObjectMove(name_wave, 0, Time[shift], price);      
   ObjectSetText(name_wave, rules_str, RuleSizeText, "Arial Narrow", RuleColor);   
   return(0);
}



color ColorDesgination(string desig){
   if (desig == desig_L5) return(Red);
   if (desig == desig_L3) return(Red);
   if (desig == desig_5) return(Blue);
   if (desig == desig_s5) return(Blue);
   if (desig == desig_c3) return(Green); 
   if (desig == desig_F3) return(Green); 
   
   if (desig == desig_many_model) return(Red); 
   return(Black);
}   

int AddNotesToChart(int win, int index_wave){
   int count = CountArrayNotes();
   int shift_position = DirectionEndShift(1);
   int Price_Level = 50;
   for (int i = 0; i < count; i++ ){
      
      SetNoteInChart(win, shift_position, Notes_Get(i), Price_Level, DodgerBlue, "Note_", DoubleToStr(i,0));   
         
      Price_Level = Price_Level - 25;         
   }   
}

int SetNoteInChart(int win, int shift, string note, double price, 
   color Color, string base_name, string other_name = ""){
   
   if (price == 0 || shift >= Bars){
      return(0);
   }
   string name_wave = base_name + DoubleToStr(shift, 0) +"_"+ other_name;
   if(ObjectFind(name_wave)<0)
      ObjectCreate(name_wave, OBJ_ARROW, win, 0, 0);   
   
   ObjectSet(name_wave, OBJPROP_ARROWCODE, 50);
   ObjectSet(name_wave, OBJPROP_COLOR, Color);   
   ObjectMove(name_wave, 0, Time[shift], price);      
   ObjectSetText(name_wave, note, 10);   
   
   return(0);
}