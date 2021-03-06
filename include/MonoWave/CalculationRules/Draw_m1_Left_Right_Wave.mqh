

int SetLineWavesDirection(double array[][], bool draw, bool view_m1){  
   string m0_name  = "line_m0";   
   string m_1_name = "line_m_1";   
   string m_2_name = "line_m_2";   
   string m_3_name = "line_m_3";   
   string m_4_name = "line_m_4";  
       
   string m1_name  = "line_m1";    
   string m2_name  = "line_m2";   
   string m3_name  = "line_m3";   
   string m4_name  = "line_m4";   
   string m5_name  = "line_m5";   
   //string m6_name  = "line_m6";
      
   if (!draw) {      
      if (!view_m1){         
         ObjectDelete(m0_name);
         ObjectDelete(m_1_name);
         ObjectDelete(m_2_name);
         ObjectDelete(m_3_name);
         ObjectDelete(m_4_name);
         
         ObjectDelete(m1_name);
         ObjectDelete(m2_name);
         ObjectDelete(m3_name);
         ObjectDelete(m4_name);
         ObjectDelete(m5_name);
         //ObjectDelete(m6_name);
      }
      return(0);
   }   
   
   
   //m1   
   DrawLine(array, 0, m1_name, "", Red);   
   
   
   //m0, m-1, m-2, m-3 m-4 
   DrawLine(array, 1, m0_name,  "m0", Blue);
   DrawLine(array, 2, m_1_name, "m(-1)", Blue);
   DrawLine(array, 3, m_2_name, "m(-2)", Blue);
   DrawLine(array, 4, m_3_name, "m(-3)", Blue);       
   DrawLine(array, 5, m_4_name, "m(-4)", Blue);   
   
   //m2, m3, m4, m5
   DrawLine(array, 6, m2_name, "m2", Blue); 
   DrawLine(array, 7, m3_name, "m3", Blue); 
   DrawLine(array, 8, m4_name, "m4", Blue); 
   DrawLine(array, 9, m5_name, "m5", Blue);  
   //DrawLine(array, 10, m6_name, "m6", Blue);  
   
   

   return(0);
}


bool DrawLine(double& array[][], int index, string name, string text, color linecolor, int width = 5){
   
   if(ObjectFind(name)<0) ObjectCreate(name, OBJ_TREND, 0, 0, 0);   
   
   int t1, t2;
   t1 = array[index][2];
   t2 = array[index][3];
   ObjectSet(name, OBJPROP_TIME1, Time[t1]);
   ObjectSet(name, OBJPROP_TIME2, Time[t2]);

   if (array[index][0] == 0 || array[index][1] == 0){
      ObjectSet(name, OBJPROP_PRICE1, 0);
      ObjectSet(name, OBJPROP_PRICE2, 0);
      return(0);
   }else{
      ObjectSet(name, OBJPROP_PRICE1, array[index][0]);
      ObjectSet(name, OBJPROP_PRICE2, array[index][1]);   
   }    
      
   ObjectSet(name, OBJPROP_RAY, false);
   ObjectSet(name, OBJPROP_COLOR, linecolor);
   ObjectSet(name, OBJPROP_WIDTH, width); 
   //Debug-------------
   //int index_1 = array[index][10];
   //string text_1 = DoubleToStr(MonoWave_Rule[index_1][2], 4);
   //string text_2 = DoubleToStr(array[index][7], 0);
   //  + " | " + text_1 +  " | " + text_2
   //------------------

   ObjectSetText(name, "       " + text, 12, "Arial", Blue);       
   return(0);
   
}

void SaveProportionWavesDirection(string name = ""){
   
   string str = 
      DirectionPriceLenght(1) + ":" +
      DirectionPriceLenght(0) + ":" +
      DirectionPriceLenght(-1) + ":" +
      DirectionPriceLenght(-2) + ":" +
      DirectionPriceLenght(-3) + ":" +
      DirectionPriceLenght(-4) + ":" + name;  

  
  int handle = FileOpen("Direction_Proportion.txt", FILE_CSV|FILE_READ|FILE_WRITE,",");
  if(handle < 1){
     Print("File Direction_Proportion.txt not found, the last error is ", GetLastError());
     return(false);
   }     
   FileSeek(handle, FileSize(handle) , SEEK_SET);     
   
      
   FileWrite(handle, str);

   if(handle>1) FileClose(handle);
}

