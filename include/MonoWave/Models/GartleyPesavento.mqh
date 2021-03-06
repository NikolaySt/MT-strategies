

double ratio_OA_AB(){
   if (DirectionPriceLenght(-2) == 0) return(0);
   return(DirectionPriceLenght(-1) / DirectionPriceLenght(-2));
}

double ratio_AB_BC(){
   if (DirectionPriceLenght(-1) == 0) return(0);
   return(DirectionPriceLenght(0)/DirectionPriceLenght(-1) );
}

double ratio_CD_BC(){
if (DirectionPriceLenght(0) == 0) return(0);
   return(DirectionPriceLenght(1) / DirectionPriceLenght(0));
}

double ratio_AD_OA(){
   if (DirectionPriceLenght(-2) == 0) return(0);
   return( 
      MathAbs(DirectionEndPrice(-2) - DirectionEndPrice(1)) 
      / DirectionPriceLenght(-2)
   );
}

double ratio_CD_DE(){
   if (DirectionPriceLenght(1) == 0) return(0);
   return(DirectionEndPrice(2) / DirectionPriceLenght(1)
   );
}

double ratio_m_1_m0(){
   if (DirectionPriceLenght(0) == 0) return(0);
   return(DirectionPriceLenght(-1) / DirectionPriceLenght(0));
}

bool DrawTriagalnic1(string name, color linecolor){
   
   if(ObjectFind(name)<0) ObjectCreate(name, OBJ_TRIANGLE, 0, 0, 0);   
   
   ObjectSet(name, OBJPROP_TIME1, Time[DirectionBeginShift(-2)]);
   ObjectSet(name, OBJPROP_TIME2, Time[DirectionBeginShift(-1)]);
   ObjectSet(name, OBJPROP_TIME3, Time[DirectionBeginShift(0)]);

   ObjectSet(name, OBJPROP_PRICE1, DirectionBeginPrice(-2));
   ObjectSet(name, OBJPROP_PRICE2, DirectionBeginPrice(-1));   
   ObjectSet(name, OBJPROP_PRICE3, DirectionBeginPrice(0));   
   
      
   ObjectSet(name, OBJPROP_BACK, true);
   ObjectSet(name, OBJPROP_COLOR, linecolor);
   ObjectSet(name, OBJPROP_WIDTH, 1); 
    
   return(0);   
}


bool DrawTriagalnic2(string name, color linecolor){
   
   if(ObjectFind(name)<0) ObjectCreate(name, OBJ_TRIANGLE, 0, 0, 0);   
   
   ObjectSet(name, OBJPROP_TIME1, Time[DirectionBeginShift(0)]);
   ObjectSet(name, OBJPROP_TIME2, Time[DirectionBeginShift(1)]);
   ObjectSet(name, OBJPROP_TIME3, Time[DirectionEndShift(1)]);

   ObjectSet(name, OBJPROP_PRICE1, DirectionBeginPrice(0));
   ObjectSet(name, OBJPROP_PRICE2, DirectionBeginPrice(1));   
   ObjectSet(name, OBJPROP_PRICE3, DirectionEndPrice(1));   
   
      
   ObjectSet(name, OBJPROP_BACK, true);
   ObjectSet(name, OBJPROP_COLOR, linecolor);
   ObjectSet(name, OBJPROP_WIDTH, 1); 
    
   return(0);   
}


bool Searching_models(){
/*
   Print(
      "OA/AB=", ratio_OA_AB(), 
      ", AB/BC=" , ratio_AB_BC(), 
      ", CD/BC=" , ratio_CD_BC(),
      ", AD/AO=" , ratio_AD_OA()
   );
  */     
  //return(0);
   if (
      ( Equal_061(ratio_OA_AB()) ) &&
      ( Equal_088(ratio_AB_BC()) ) &&
      ( Equal_038(ratio_CD_BC()) || Equal_061(ratio_CD_BC()) || Equal_161(ratio_CD_BC()) || Equal_261(ratio_CD_BC()) || Equal_100(ratio_CD_BC()) || Equal_088(ratio_CD_BC()) ) &&
      ( Equal_038(ratio_AD_OA()) || Equal_061(ratio_AD_OA()) ) 
      ){
      Print("find: ", "search", " AD_AO = ", ratio_AD_OA());
      DrawTriagalnic1("triag_search1:"+DirectionBeginShift(-2), Red);
      DrawTriagalnic2("triag_search2:"+DirectionBeginShift(-2), Red);
      return(true);      
      
   }else{
      return(false);
   }
}

bool Searching_models_2(){
/*
   Print(
      "OA/AB=", ratio_OA_AB(), 
      ", AB/BC=" , ratio_AB_BC(), 
      ", CD/BC=" , ratio_CD_BC(),
      ", AD/AO=" , ratio_AD_OA()
   );
  */     
  //return(0);
   if (
      ( Equal_161(ratio_OA_AB())  ) &&
      //( Equal_088(ratio_AB_BC()) )// &&
      ( ratio_CD_BC() > 2.50 && ratio_CD_BC() < 2.88) //&&
      //( Equal_127(ratio_AD_OA()) || Equal_161(ratio_AD_OA()) ) 
      ){
      Print("find: ", "search", " CD_BC = ", ratio_CD_BC());
      DrawTriagalnic1("triag_search1:"+DirectionBeginShift(-2), Red);
      DrawTriagalnic2("triag_search2:"+DirectionBeginShift(-2), Red);
      return(true);      
      
   }else{
      return(false);
   }
}

bool Searching_models_3(){
/*
   Print(
      "OA/AB=", ratio_OA_AB(), 
      ", AB/BC=" , ratio_AB_BC(), 
      ", CD/BC=" , ratio_CD_BC(),
      ", AD/AO=" , ratio_AD_OA()
   );
  */     
  //return(0);
  
   if (
      (DirectionPriceLenght(0) > DirectionPriceLenght(1)) &&
      Equal_038(ratio_m_1_m0()) &&
      (DirectionPriceLenght(-2) > DirectionPriceLenght(-1)) &&
      (DirectionPriceLenght(-3) > DirectionPriceLenght(-2)) 
      ){

      Print("find: ", "search = ");
      DrawTriagalnic1("triag_search1:"+DirectionBeginShift(-2), Red);
      DrawTriagalnic2("triag_search2:"+DirectionBeginShift(-2), Red);
      return(true);      
      
   }else{
      return(false);
   }
}


bool Butterfly_models(){
/*
  OA/AB = 0.618 - 0.786
  AB/BC = 0.382 - 0.886
  CD/BC = 1.618 - 2.618
  AD/AO = 1.27 - 1.618

   Print(
      "OA/AB=", ratio_OA_AB(), 
      ", AB/BC=" , ratio_AB_BC(), 
      ", CD/BC=" , ratio_CD_BC(),
      ", AD/AO=" , ratio_AD_OA()
   );
  */     
  //return(0);
   if (
      ( Equal_061(ratio_OA_AB()) || Equal_078(ratio_OA_AB()) ) &&
      ( Equal_038(ratio_AB_BC()) || Equal_088(ratio_AB_BC()) ) &&
      ( Equal_161(ratio_CD_BC()) || Equal_261(ratio_CD_BC()) ) //&&
      //( Equal_127(ratio_AD_OA()) || Equal_161(ratio_AD_OA()) ) 
      ){
      Print("find: ", "Butterfly");
      DrawTriagalnic1("triag_b1:"+DirectionBeginShift(-2), Red);
      DrawTriagalnic2("triag_b2:"+DirectionBeginShift(-2), Red);
      return(true);      
      
   }else{
      return(false);
   }
}

bool Gartley_models(){

   if (
      ( Equal_061(ratio_OA_AB()) ) &&
      ( Equal_038(ratio_AB_BC()) || Equal_088(ratio_AB_BC()) ) &&
      ( Equal_127(ratio_CD_BC()) || Equal_161(ratio_CD_BC()) ) //&&
      //( Equal_078(ratio_AD_OA()) ) 
      ){
      Print("find: ", "Gartley");
      DrawTriagalnic1("triag_g1:"+DirectionBeginShift(-2), Green);
      DrawTriagalnic2("triag_g2:"+DirectionBeginShift(-2), Green);
      return(true);      
      
   }else{
      return(false);
   }
}

bool Crab_models(){

   if (
      ( Equal_038(ratio_OA_AB()) || Equal_061(ratio_OA_AB())) &&
      ( Equal_038(ratio_AB_BC()) || Equal_088(ratio_AB_BC()) ) &&
      ( Equal_224(ratio_CD_BC()) || Equal_361(ratio_CD_BC()) ) //&&
      //( Equal_127(ratio_AD_OA()) || Equal_161(ratio_AD_OA()) ) 
      ){
      Print("find: ", "Crab");
      DrawTriagalnic1("triag_cr1:"+DirectionBeginShift(-2), Black);
      DrawTriagalnic2("triag_cr2:"+DirectionBeginShift(-2), Black);
      return(true);      
      
   }else{
      return(false);
   }
}

bool Chiroptera_models(){
   if (
      ( Equal_038(ratio_OA_AB()) || Equal_050(ratio_OA_AB())) &&
      ( Equal_038(ratio_AB_BC()) || Equal_088(ratio_AB_BC()) ) &&
      ( Equal_161(ratio_CD_BC()) || Equal_261(ratio_CD_BC()) ) //&&
      //( Equal_886(ratio_AD_OA()) ) 
      ){
      Print("find: ", "Chiroptera");
      DrawTriagalnic1("triag_ch1:"+DirectionBeginShift(-2), Gold);
      DrawTriagalnic2("triag_ch2:"+DirectionBeginShift(-2), Gold);
      return(true);      
      
   }else{
      return(false);
   }
}

bool Pattern_5_0_models(){
   if (
      ( Equal_050(ratio_OA_AB()) || Equal_061(ratio_OA_AB()) || Equal_038(ratio_OA_AB()) ) &&
      ( ratio_AB_BC() > 1.13 && ratio_AB_BC() < 1.63)//  &&
      //( ratio_CD_BC() > 1.5 && ratio_CD_BC() < 2.24 ) //&&
      //( Equal_50(ratio_CD_DE()) ) 
      ){
      Print("find: ", "Pattern 5-0", ": CD/DC=",ratio_CD_BC());
      DrawTriagalnic1("triag_pat5_1:"+DirectionBeginShift(-2), Gold);
      DrawTriagalnic2("triag_pat5_2:"+DirectionBeginShift(-2), Gold);
      return(true);      
      
   }else{
      return(false);
   }
}



