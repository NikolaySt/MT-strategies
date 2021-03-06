//+------------------------------------------------------------------+
//|                                            Ard_CalcEquations.mq4 |
//|                                    Copyright © 2007, Ariadna Ltd |
//|                                              revision 14.02.2007 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Ariadna Ltd"
#property link      "revision 14.02.2007"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int GetWindowEquations(){
   int win = -1;
   win = 2;//WindowFind("Rules");   
   
   if ( win < 0 ) {
      Alert("Липва прозорец 'Rules' ");
   }      
   return(win); 
}   


int count_designation_full = 0;
int count_designation_3d = 0;

string Designation_full[200][3];
string Designation_full_3d[200][2][6];
/*
   Designation[100][0][0] = обозначениа ":F3/:c3/:5/:s5...."
   Designation[100][1][0] = позиция (shift)
   Designation[100][3][0] = ..
*/

//-----------------------------------------------------------------
string name_flat = "flat";
string name_flat1 = "flat";
string name_flat2 = "flat";
string equal_flat[] = {":F3", ":c3", ":L5"};
int count_flat = 3;
//string name_flat = "F3-c3-L5";

string equal_flat1[] = {":F3", ":c3", ":s5"};
//string name_flat1 = "F3-c3-s5";

string equal_flat2[] = {":F3", ":c3", ":5"};
//string name_flat2 = "F3-c3-5";
//-----------------------------------------------------------------
string name_zigzag = "zigzag";
string name_zigzag1 = "zigzag";
string name_zigzag2 = "zigzag";
string equal_zigzag[] = {":5", ":F3", ":L5"};
int count_zigzag = 3;
//string name_zigzag = "5-F3-L5";

string equal_zigzag1[] = {":5", ":F3", ":s5"};
//string name_zigzag1 = "5-F3-s5";

string equal_zigzag2[] = {":5", ":F3", ":5"};
//string name_zigzag2 = "5-F3-5";
//-----------------------------------------------------------------
string name_term_triag = "triag/term";
string name_term_triag1 = "zigzag";
string equal_term_triag[] = {":F3", ":c3",  ":c3",  ":sL3", ":L5"};
int count_term_triag = 5;
//string name_term_triag = "F3-c3-c3-sL3-L3";

string equal_term_triag1[] = {":F3", ":c3",  ":c3",  ":c3", ":L5"};
//string name_term_triag1 = "F3-c3-c3-c3-L3";
//-----------------------------------------------------------------
string name_impuls = "impuls";
string name_impuls1 = "impuls";
string equal_impuls[] = {":5", ":F3",  ":5",  ":F3", ":L5"};
int count_impuls = 5;
//string name_impuls = "5-F3-5-F3-L5";

string equal_impuls1[] = {":5", ":F3",  ":s5",  ":F3", ":L5"};
//string name_impuls1 = "5-F3-s5-F3-L5";
//-----------------------------------------------------------------
string base_list[] = {":5", ":s5", ":L5", ":c3", "x:c3", ":F3", ":sL3", ":L3"};
int base_count = 8;

int start(){
   int total = ObjectsTotal();
   double price;
   string name;
   string description;
   int shift;
   GetWindowEquations();
   //ArrayInitialize(Designation_full, "");
   //ArrayInitialize(Designation_full_3d, "");  
   string short_name;
   for (int i = 0; i < total; i++){
      name = ObjectName(i);
      if (ObjectType(name) == OBJ_TEXT){
         price = ObjectGet(name, OBJPROP_PRICE1);
         short_name = StringSubstr(name, 0, 4);                    
         if (price > 0 && price < 3 && short_name != "wave" && short_name != "Rule"){
            description = ObjectDescription(name);   
            shift = iBarShift(NULL, 0, ObjectGet(name, OBJPROP_TIME1));               
            
            Designation_full[count_designation_full][0]= description;
            Designation_full[count_designation_full][1]= DoubleToStr(shift, 0);
            count_designation_full++;         
         }
      }         
   }   
   SortArrayDesignation(Designation_full, count_designation_full);      
   Transfer_Designation_3d(Designation_full, count_designation_full, Designation_full_3d);
   
   //Alert("---------------------------------------------------------------------");
   //------------------------------------------------------------------------------
   
   string str = "";
   int base = 197;
   for (i=0; i < count_designation_3d; i++){      
      shift = StrToInteger(Designation_full_3d[i][1][0]);
      name = Designation_full_3d[i][0][0] + "_" + Designation_full_3d[i][1][0] + "_" + DoubleToStr(i, 0);
      if (Designation_full_3d[i][0][0]!=""){
         SetModel_ext(name, Designation_full_3d[i][0][0], 2, Time[shift], base);
      }
      str = str + Designation_full_3d[i][0][0] + ", ";
   }
   //Alert(str);
   str = "";
   base = base - 25;
   for (i=0; i < count_designation_3d; i++){
      
      shift = StrToInteger(Designation_full_3d[i][1][1]);
      name = Designation_full_3d[i][0][1] + "_" + Designation_full_3d[i][1][1] + "_" + DoubleToStr(i, 0);
      if (Designation_full_3d[i][0][1]!=""){
         SetModel_ext(name, Designation_full_3d[i][0][1], 2, Time[shift], base);   
      }
      str = str + Designation_full_3d[i][0][1] + ", ";
   }
   //Alert(str);   
   str = "";
         base = base - 25;
   for (i=0; i < count_designation_3d; i++){

      shift = StrToInteger(Designation_full_3d[i][1][2]);
      name = Designation_full_3d[i][0][2] + "_" + Designation_full_3d[i][1][2] + "_" + DoubleToStr(i, 0);
      if (Designation_full_3d[i][0][2]!=""){
         SetModel_ext(name, Designation_full_3d[i][0][2], 2, Time[shift], base);    
      }
      str = str + Designation_full_3d[i][0][2] + ", ";
   }
   //Alert(str);   
   str = "";
         base = base - 25;
   for (i=0; i < count_designation_3d; i++){

      shift = StrToInteger(Designation_full_3d[i][1][3]);
      name = Designation_full_3d[i][0][3] + "_" + Designation_full_3d[i][1][3] + "_" + DoubleToStr(i, 0);
      if (Designation_full_3d[i][0][3]!=""){
         SetModel_ext(name, Designation_full_3d[i][0][3], 2, Time[shift], base);     
      }
      str = str + Designation_full_3d[i][0][3] + ", ";
   }
   //Alert(str);  
   str = "";
         base = base - 25;
   for (i=0; i < count_designation_3d; i++){

      shift = StrToInteger(Designation_full_3d[i][1][4]);
      name = Designation_full_3d[i][0][4] + "_" + Designation_full_3d[i][1][4] + "_" + DoubleToStr(i, 0);
      if (Designation_full_3d[i][0][4]!=""){
         SetModel_ext(name, Designation_full_3d[i][0][4], 2, Time[shift], base);     
      }
      str = str + Designation_full_3d[i][0][4] + ", ";
   }
  // Alert(str);  
   str = "";
   base = base - 25;
   for (i=0; i < count_designation_3d; i++){
      
      shift = StrToInteger(Designation_full_3d[i][1][5]);
      name = Designation_full_3d[i][0][5] + "_" + Designation_full_3d[i][1][5] + "_" + DoubleToStr(i, 0);
      if (Designation_full_3d[i][0][5]!=""){
         SetModel_ext(name, Designation_full_3d[i][0][5], 2, Time[shift], base);     
      }
      str = str + Designation_full_3d[i][0][5] + ", ";
   }
   //Alert(str);     
   //------------------------------------------------------------------------------
   
   //Equations();     
   
   return(0);
}

void SortArrayDesignation(string& Designation[][], int Count){
   string value_1_1, value_2_1;
   int value_1_2, value_2_2; 
    
   for(int i = 0; i < Count; i++){    
      for(int n = i; n < Count; n++){      
         value_1_1 = Designation[i][0];
         value_1_2 = StrToInteger(Designation[i][1]);
         
         value_2_1 = Designation[n][0];
         value_2_2 = StrToInteger(Designation[n][1]);
         
         if (value_1_2 < value_2_2) {
            Designation[i][0] = value_2_1;
            Designation[i][1] = DoubleToStr(value_2_2, 0);
            
            Designation[n][0] = value_1_1;
            Designation[n][1] = DoubleToStr(value_1_2, 0);
            
         }
      }
   }   
   
}

void Transfer_Designation_3d(string& Designation[][], int Count, string& Designation_3d[][][]){
   int shift, level_shift, Designation_Level;
   int i, n, k = 0;
   bool check_exit, find_level;         
   int p;
   int level;
   bool check_find;
   string short_name, description;   
   
   count_designation_3d = 0;
   while (i < Count){
      shift = StrToInteger(Designation[i][1]);
      description = Designation[i][0]; 
      i++;

      for (n = 0; n < 6; n++){
         Designation_3d[count_designation_3d][0][n] = "";
         Designation_3d[count_designation_3d][1][n] = "";
      }
      
      level = 0;
      check_find = false;
      for (k = 0; k < base_count; k++){
         p = StringFind(description, base_list[k]);
         if (p != -1){     
            if (!(base_list[k] == ":c3" && StringSubstr(description, p-1, 1) == "x")){
               Designation_3d[count_designation_3d][0][level] = base_list[k];
               Designation_3d[count_designation_3d][1][level] = DoubleToStr(shift, 0);                  
               level++;
               check_find = true;      
            }                     
         }           
      } 
      if (check_find){
         count_designation_3d++;           
      }       
            
   }   
}

bool Equations(){
   int level, Postion_2, Postion_1;
   int i = count_designation_3d-1;
   int base;
   string symbol, name;
   bool find, find1;
   int win = -1;
   level = 0;
   
   win = GetWindowEquations();  
   
   while (i >= 0) {
      level = 0;
      while (level < 6){       
         //------------FLAT------------------          
         base = 180 - level*15;            
         if (CheckModel(equal_flat, count_flat, level, i, Postion_1, Postion_2)){            
            base = base - (level+1)*15;
            name = "Equal_" + Postion_1 + name_flat;         
            SetModel(name, name_flat, win, Time[Postion_1], base, Time[Postion_2], base);            
         }         
         
         if (CheckModel(equal_flat1, count_flat, level, i, Postion_1, Postion_2)){            
            base = base - (level+1)*15;
            name = "Equal_" + Postion_1 + name_flat1;         
            SetModel(name, name_flat1, win, Time[Postion_1], base, Time[Postion_2], base);
         } 
         
         if (CheckModel(equal_flat2, count_flat, level, i, Postion_1, Postion_2)){            
            base = base - (level+1)*15;
            name = "Equal_" + Postion_1 + name_flat2;         
            SetModel(name, name_flat2, win, Time[Postion_1], base, Time[Postion_2], base);            
         }                   
         //----------------------------------                
         base = 150 - level*15; 
         //------------ZIGZAG------------------         
         if (CheckModel(equal_zigzag, count_zigzag, level, i, Postion_1, Postion_2)){            
            base = base - (level+1)*15;
            name = "Equal_" + Postion_1 + name_zigzag;         
            SetModel(name, name_zigzag, win, Time[Postion_1], base, Time[Postion_2], base);            
         }     
         if (CheckModel(equal_zigzag1, count_zigzag, level, i, Postion_1, Postion_2)){            
            base = base - (level+1)*15;
            name = "Equal_" + Postion_1 + name_zigzag1;         
            SetModel(name, name_zigzag1, win, Time[Postion_1], base, Time[Postion_2], base);            
         }    
         if (CheckModel(equal_zigzag2, count_zigzag, level, i, Postion_1, Postion_2)){            
            base = base - (level+1)*15;
            name = "Equal_" + Postion_1 + name_zigzag2;         
            SetModel(name, name_zigzag2, win, Time[Postion_1], base, Time[Postion_2], base);
            
         }                      
         //----------------------------------
               
         base = 120 - level*15; 
         //------------TRIAG/Terminal------------------     
         if (CheckModel(equal_term_triag, count_term_triag, level, i, Postion_1, Postion_2)){            
            base = base - (level+1)*15;
            name = "Equal_" + Postion_1 + name_term_triag;         
            SetModel(name, name_term_triag, win, Time[Postion_1], base, Time[Postion_2], base);            
         }  

         if (CheckModel(equal_term_triag1, count_term_triag, level, i, Postion_1, Postion_2)){            
            base = base - (level+1)*15;
            name = "Equal_" + Postion_1 + name_term_triag1;         
            SetModel(name, name_term_triag1, win, Time[Postion_1], base, Time[Postion_2], base);            
         }              
         //----------------------------------    
         
         base = 90 - level*15; 
         //------------Impuls------------------     
         if (CheckModel(equal_impuls, count_impuls, level, i, Postion_1, Postion_2)){            
            base = base - (level+1)*15;
            name = "Equal_" + Postion_1 + name_impuls;         
            SetModel(name, name_impuls, win, Time[Postion_1], base, Time[Postion_2], base);
         }   
         if (CheckModel(equal_impuls1, count_impuls, level, i, Postion_1, Postion_2)){            
            base = base - (level+1)*15;
            name = "Equal_" + Postion_1 + name_impuls1;         
            SetModel(name, name_impuls1, win, Time[Postion_1], base, Time[Postion_2], base);
         }             
         //----------------------------------      
         level++;
      }
      i--;
   }

}

int SetModel(string name, string desc, int win, datetime time1, int price1, datetime time2, int price2){
   if (ObjectFind(name) == -1){
      ObjectCreate(name, OBJ_RECTANGLE, win, 0, 0);      
   }
   ObjectSetText(name, desc);
   ObjectSet(name, OBJPROP_TIME1, time1);
   ObjectSet(name, OBJPROP_TIME2, time2);
   ObjectSet(name, OBJPROP_PRICE1, price1);
   ObjectSet(name, OBJPROP_PRICE2, price2+2);
   
   ObjectSet(name, OBJPROP_BACK, false);
   //ObjectSet(name, OBJPROP_RAY, false);
   //ObjectSet(name, OBJPROP_WIDTH, 2);
   ObjectSet(name, OBJPROP_COLOR, Blue);
}

void SetModel_ext(string name, string desc, int win, datetime time1, int price1){
   if (ObjectFind(name) == -1){
      ObjectCreate(name, OBJ_TEXT, win, 0, 0);      
   }
   ObjectSetText(name, desc);   
   ObjectSet(name, OBJPROP_TIME1, time1);
   ObjectSet(name, OBJPROP_PRICE1, price1);
   ObjectSet(name, OBJPROP_COLOR, Black);
   ObjectSet(name, OBJPROP_FONTSIZE, 7);
}



bool FindDesignation(string find_designation, int position){
   string symbol;      
   int level = 0;
   while (level < 6){
      symbol = Designation_full_3d[position][0][level];
      if (symbol == find_designation){
         return(true);
      }else{
         if (symbol == ""){
            return(false);  
         }
      }   
      level++;
   }
   return(false);
}


bool CheckModel(string equal[], int count, int level, int index, int& p1, int& p2){
   int n = count - 1;
   int i = index; 
   bool error_find = false;
   bool find = false;
   p2 = StrToInteger(Designation_full_3d[i][1][0]);
               
   while (!error_find && n >= 0 && i >= 0){
      if (i == index){         
         if (equal[n] == Designation_full_3d[index][0][level]){
            find = true;
         }else{
            find = false;            
         }
      }else{
         find = FindDesignation(equal[n], i);

         p1 = StrToInteger(Designation_full_3d[i][1][0]);

      }
      if (!find){
         error_find = true;         
      }      
      i--;
      n--;
   }
   if (error_find){
      return(false);
   }else{
      if (i<0 && n>=0){
         return(false);
      }else{
         return(true);
      }
   }        
}    
  