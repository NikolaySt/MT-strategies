int index_designation_position = 0;
int index_rule_position = 0;

void Init_WorkWithObjects(){ 
   index_designation_position = 0;
   index_rule_position = 0;   
}

int DeleteObjects(){ 
   string name1, name2, name3, name4, name5, name6, name7 = "";  
   if ( RulesView ) {name1 = "Rule"; name5 = "Desig"; name6 = "Note";}
   if ( ListIndicators ) name2 = "List";
   if ( NumberWaveView ) {
      name3 = "wave";
      name4 = "chrono";      
   }
   if ( PesaventoModels ) {name7 = "triag";}
   Delete_Obj_Text(name1, name2, name3, name4, name5, name6, name7);
   
}

int Delete_Obj_Text(string name1 = "", string name2 = "", string name3 = "", 
   string name4 = "", string name5 = "", string name6 = "", string name7 = ""){   

   if (name1 == "" && name2 == "" && name3 == "" && name4 == "" && name5 =="") {
      ObjectsDeleteAll(NULL, OBJ_TEXT);
   }else{
      string DeleteObjectMasive[2000], name_save, name_obj;
      int i, cound_delete_obj = 0;
      int count_obj = ObjectsTotal();
      
      for (i = 0; i < count_obj; i++){
         name_save = ObjectName(i);      
         name_obj = StringSubstr(name_save, 0, StringLen(name1));          
         
         if (name_obj == name1){
            DeleteObjectMasive[cound_delete_obj] = name_save;   
            cound_delete_obj++;
         }else{
            name_save = ObjectName(i);      
            name_obj = StringSubstr(name_save, 0, StringLen(name2));           
            if (name_obj == name2){
               DeleteObjectMasive[cound_delete_obj] = name_save;   
               cound_delete_obj++;
            }else{
               name_save = ObjectName(i);      
               name_obj = StringSubstr(name_save, 0, StringLen(name3));           
               if (name_obj == name3){
                  DeleteObjectMasive[cound_delete_obj] = name_save;   
                  cound_delete_obj++;
               }else{
                  name_save = ObjectName(i);      
                  name_obj = StringSubstr(name_save, 0, StringLen(name4));           
                  if (name_obj == name4){
                     DeleteObjectMasive[cound_delete_obj] = name_save;   
                     cound_delete_obj++;
                  }else{
                     name_save = ObjectName(i);      
                     name_obj = StringSubstr(name_save, 0, StringLen(name5));           
                     if (name_obj == name5){
                        DeleteObjectMasive[cound_delete_obj] = name_save;   
                        cound_delete_obj++;
                     }else{
                        name_save = ObjectName(i);      
                        name_obj = StringSubstr(name_save, 0, StringLen(name6));           
                        if (name_obj == name6){
                           DeleteObjectMasive[cound_delete_obj] = name_save;   
                           cound_delete_obj++;
                        }else{                        
                           name_save = ObjectName(i);      
                           name_obj = StringSubstr(name_save, 0, StringLen(name7));           
                           if (name_obj == name7){
                              DeleteObjectMasive[cound_delete_obj] = name_save;   
                              cound_delete_obj++;
                           }                                             
                        }                     
                     }                  
                  }                
               }                       
            }
         }         
      }
      
      for (i = 0; i < cound_delete_obj; i++){
         name_save = DeleteObjectMasive[i];
         ObjectDelete(name_save);
      }
      
   }
   return(0);
}

int SetWaveRule(int shift, string rules_str, double price, 
   int RuleSizeText, color RuleColor, string base_name, string other_name = "", int up_down = 0){
   
   if (price == 0 || shift >= Bars){
      return(0);
   }
    
   string name_wave = base_name + DoubleToStr(shift, 0) + other_name;
   if(ObjectFind(name_wave)<0)
      ObjectCreate(name_wave, OBJ_TEXT, 0, 0, 0);
      
   
   double Offset = iATR(NULL, 0, 100, shift);
   if (up_down == 1){
      ObjectMove(name_wave, 0, Time[shift], price + Offset);
      
   }else{ 
      if (up_down == 2){ 
         ObjectMove(name_wave, 0, Time[shift], price);        
      }else{
         ObjectMove(name_wave, 0, Time[shift], price);
      }
   }
   
      
   ObjectSetText(name_wave, rules_str, RuleSizeText, "Arial Narrow", RuleColor);   
   return(0);
}



int SetWaveRule_indicator_down(int win, int shift, string rules_str, double price, 
   int RuleSizeText, color RuleColor, string base_name, string other_name = ""){
   
   if (price == 0 || shift >= Bars){
      return(0);
   }
   double Offset = 0;
   if (index_rule_position == 0){
      Offset = 97;  
      index_rule_position++;  
   }else{
      if (index_rule_position == 1){
         Offset = 72;  
         index_rule_position++;  
      }else{
         if (index_rule_position == 2){
            Offset = 47;  
            index_rule_position++;   
         }else{            
            if (index_rule_position == 3){
               Offset = 22;  
               index_rule_position = 0;  
            }else{            
               index_rule_position = 0; 
            } 
         }   
              
      }      
   }
    
   string name_wave = base_name + DoubleToStr(shift, 0) + other_name;
   if(ObjectFind(name_wave)<0)
      ObjectCreate(name_wave, OBJ_TEXT, win, 0, 0);
   
   ObjectMove(name_wave, 0, Time[shift], Offset);
      
   ObjectSetText(name_wave, rules_str, RuleSizeText, "Arial Narrow", RuleColor);   
   
   //string file_name = Symbol() + "_"  + ChartPeriodInfo() + "_" + name_wave + "_" + rules_str + ".gif";
   //WindowScreenShot(rules_str + "/" + file_name, 400, 400, shift + 80);
   //SaveProportionWavesDirection(file_name);
   
   return(0);
}



int SetWave_ListIndicator(int shift, string list, double price, 
   int ListSizeText, color ListIndicatorsColor, string base_name, string other_name = "", int up_down = 0){
   
   if (price == 0 || shift >= Bars){
      return(0);
   }   
   
   string name_wave = base_name + DoubleToStr(shift, 0) + other_name;
   if(ObjectFind(name_wave)<0)
      ObjectCreate(name_wave, OBJ_TEXT, 0, 0, 0);

    

   double Offset = iATR(NULL, 0, 10, shift);
   if (up_down == 1) 
      ObjectMove(name_wave, 0, Time[shift], price + Offset* 0.3);
   else 
      if (up_down == 2) 
         ObjectMove(name_wave, 0, Time[shift], price - Offset* 0.2);
      else
         ObjectMove(name_wave, 0, Time[shift], price);  
         
   
   ObjectSetText(name_wave, list, ListSizeText, "Arial Narrow", ListIndicatorsColor);   
   return(0);
}

int SetText(int shift, double price, string text,
   int SizeText, color TextColor, string base_name){
   
   if (price == 0 || shift >= Bars){
      return(0);
   }   
   
   string name_wave = base_name + DoubleToStr(shift, 0);
   if(ObjectFind(name_wave)<0)
      ObjectCreate(name_wave, OBJ_TEXT, 0, 0, 0);
    
   ObjectMove(name_wave, 0, Time[shift], price);         
   
   ObjectSetText(name_wave, text, SizeText, "Arial Narrow", TextColor);   
   return(0);
}