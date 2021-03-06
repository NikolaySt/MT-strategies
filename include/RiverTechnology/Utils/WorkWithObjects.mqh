
int DeleteObjects(){ 
   string name1, name2, name3, name4, name5, name6 = "";  
   name1 = "NRT_MCount";
   name2 = "pricelevel";
   name3 = "biaslevel";
   name4 = "ml_move";
   name5 = "wave";
   Delete_Obj_Text(name1, name2, name3, name4, name5, name6);   
}

int Delete_Obj_Text(string name1 = "", string name2 = "", string name3 = "", 
   string name4 = "", string name5 = "", string name6 = ""){   

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



bool DrawLine(string name, string text, int shift1, int shift2, 
   double price1, double price2, color linecolor, int width, int style = STYLE_SOLID){
   
   if(ObjectFind(name)<0) ObjectCreate(name, OBJ_TREND, 0, 0, 0);   
   
   ObjectSet(name, OBJPROP_TIME1, Time[shift1]);
   ObjectSet(name, OBJPROP_TIME2, Time[shift2]);

   ObjectSet(name, OBJPROP_PRICE1, price1);
   ObjectSet(name, OBJPROP_PRICE2, price2);   
      
   ObjectSet(name, OBJPROP_RAY, false);
   ObjectSet(name, OBJPROP_COLOR, linecolor);
   ObjectSet(name, OBJPROP_WIDTH, width); 
   ObjectSet(name, OBJPROP_STYLE, style);

   ObjectSetText(name, text, 12, "Arial", Blue);       
   
   
   return(0);
   
}