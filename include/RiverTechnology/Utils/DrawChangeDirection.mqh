
void DrawDirection(string name,int shift_begin, int shift_end, color linecolor, int index = 1){
   int win;

        
   win = WindowFind( "Rules" );
   if ( win < 0 ) { return(-1); }
   
   
   if(ObjectFind(name)<0) ObjectCreate(name, OBJ_RECTANGLE, win, 0, 0);   
   
   ObjectSet(name, OBJPROP_TIME1, Time[shift_begin]);
   ObjectSet(name, OBJPROP_TIME2, Time[shift_end]);

   if (index == 1){
      ObjectSet(name, OBJPROP_PRICE1, 75);
      ObjectSet(name, OBJPROP_PRICE2, 100);   
   }      

   if (index == 2){
      ObjectSet(name, OBJPROP_PRICE1, 50);
      ObjectSet(name, OBJPROP_PRICE2, 70);   
   }
   
   if (index == 3){
      ObjectSet(name, OBJPROP_PRICE1, 25);
      ObjectSet(name, OBJPROP_PRICE2, 50);   
   }   

      
   ObjectSet(name, OBJPROP_BACK, true);
   ObjectSet(name, OBJPROP_COLOR, linecolor);
   ObjectSet(name, OBJPROP_WIDTH, 1); 
   ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
   
   return(0);
   
}

