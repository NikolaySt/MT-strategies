//-----------------------------------
#define desig_s5   ":s5"
#define desig_5    ":5"
#define desig_L5   ":L5"
#define desig_F3   ":F3"
#define desig_c3   ":c3"
#define desig_bc3  "b:c3"
#define desig_xc3  "x:c3"
#define desig_sL3  ":sL3"
#define desig_L3   ":L3"
//-----------------------------------
#define desig_F3_   ":F3?"
#define desig_xc3_  "x:c3?"
#define desig_5_    ":5?"
#define desig_s5_   ":s5?"
#define desig_fall  "*"
#define desig_note  "!!!"
#define desig_all   "{.}" //-{ за правило 6, 7 -> Възможно е всяко обозначение; ако нито едно от описанията не е подходящо, вижте раздела за последоваелностите а Индикаторните положения}
#define desig_many_model  "#" //завършва повече от една ценова фигура на Елиът.
//-----------------------------------


int Count_Designations_Base;
string Array_Designations_Base[10][3];
 //Масив в който се поставят обозначенията за м1
 //Array_Designations[0][0] = обозна4ение //:F3/x:c3/:c3/:sL3/:L3/:5/:s5/:L5
 //Array_Designations[0][1] = допълнителна информация за всяко обозна4ение
 //Array_Designations[0][2] = допълнителна информация за всяко обозна4ение от кое правило идва и кой параграф
 //8 са необходими но добавям допълнителни за всеки случай няколко свободни 
//---------------------------------------------------------------------------

string InfoParagraph = "";
// променлива в която се запива параграфа от който идва всяко обозначение

//------------------------Array_Designations_Base---------------------------
void InitializeDesignation(){
   Count_Designations_Base = 0;
   for (int i = 0; i < 10; i++){
      Array_Designations_Base[i][0] = "";
      Array_Designations_Base[i][1] = "";
      Array_Designations_Base[i][2] = "";
   }
   InfoParagraph = "";
}

int CountArrayDesignations(){
   return(Count_Designations_Base);   
}

int ArrayDesignation_Put(string desig = "", string info = "") {
   Array_Designations_Base[Count_Designations_Base][0] = desig;    
   Array_Designations_Base[Count_Designations_Base][1] = info;   
   Array_Designations_Base[Count_Designations_Base][2] = InfoParagraph; 
   Count_Designations_Base++;
}

void Designation_Get(int index, string& desig, string& info, string& paragraph){
   desig = Array_Designations_Base[index][0];    
   info = Array_Designations_Base[index][1];    
   paragraph = Array_Designations_Base[index][2]; 
}

string Designation_base_Get(int index){
   return(Array_Designations_Base[index][0]);    
}

string Designation_info_Get(int index){   
   return(Array_Designations_Base[index][1]);   
}

void ReplaceDesignation(int index, string desig, string info){   
   Array_Designations_Base[index][0] = desig;    
   Array_Designations_Base[index][1] = info; 
   Array_Designations_Base[index][2] = InfoParagraph;    
}
 
int AddDesignation(string desig, string info = ""){   
   if (FindDesignation(desig, info) == -1 && desig != ""){
      ArrayDesignation_Put(desig, info);    
   }   
}

int FindDesignation(string desig, string info = ""){
   int i = 0;
   bool check_find = false;
   int index_base, index_info;
   int count = CountArrayDesignations();
   while (i < count && !check_find){
      
      index_base = StringFind(Designation_base_Get(i), desig, 0); 
      
      if (info != "" && info != "()" && info != "[]" ){
         index_info = StringFind(Designation_info_Get(i), info, 0);         
         check_find = (index_base != -1) && (index_info != -1);
         
      }else{
         check_find = (index_base != -1); 
         //----Проверка когато тръсим за :с3-----------------  
         //защото x:c3 също съдържа горната абривиятура.
         if (desig == desig_c3 && check_find){
            if (!(Designation_base_Get(i) == desig_c3)){
               check_find = false;                    
            }
         }  
         //---------------------------------------       
      }

      if (!check_find) i++;
   }
   if (check_find) {
      return(i);
   }else{
      return(-1);   
   }         
}
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------








