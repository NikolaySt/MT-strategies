double WavesDirection[20][11];

/*       
   Wave_Direction[0][0] = цена от която започва вълната           
   Wave_Direction[0][1] = цена на която завършва вълната 
   Wave_Direction[0][2] = shift - начало!
   Wave_Direction[0][3] = shift - край!         
   Wave_Direction[0][4] = Index - /местоположение на дадената точка в array_ChartPoints/ - края на вълната            
   
   //позицията на вълната в array_ChartPoints която пробива екстремумите на предишната вълна от Wave_Direction 
   Wave_Direction[0][5] = Index - /местоположение на дадената точка в array_ChartPoints/ - пробив на МАКСИМУМ/МИНИМУМ
   според посоката на вълната, ако е равно на 0 вълната не е пробила нито един екстремум
   
   Wave_Direction[0][6] = брой вълни в даденото направление.
   
   Wave_Direction[0][7] = направление на вълната 
      // (1) - нагоре
      // (-1) - надолу
      
   Екстремуми на вълната      
   Wave_Direction[0][8] = максимум - МАКС.
   Wave_Direction[0][9] = минимум - МИН.
   
   Wave_Direction[0][10] = Index - /местоположение на дадената точка в MonoWave_Rule/ - края на вълната 
      
M1 - Wave_Direction[0];
M2 - Wave_Direction[6];
M3 - Wave_Direction[7];
M4 - Wave_Direction[8];
M5 - Wave_Direction[9];

M(0) - Wave_Direction[1];
M(-1) - Wave_Direction[2];
M(-2) - Wave_Direction[3];
M(-3) - Wave_Direction[4];
M(-4) - Wave_Direction[5];
      
*/

int TimeDirection(int direction){
   int time = 0;
   switch (direction){
      case 1: time = MathAbs(WavesDirection[0][4] - WavesDirection[1][4]); break;
      case 2: time = MathAbs(WavesDirection[6][4] - WavesDirection[0][4]); break;
      case 3: time = MathAbs(WavesDirection[7][4] - WavesDirection[6][4]); break;
      case 4: time = MathAbs(WavesDirection[8][4] - WavesDirection[7][4]); break;
      case 5: time = MathAbs(WavesDirection[9][4] - WavesDirection[8][4]); break;
      
      case  0: time = MathAbs(WavesDirection[2][4] - WavesDirection[1][4]); break;
      case -1: time = MathAbs(WavesDirection[3][4] - WavesDirection[2][4]); break;
      case -2: time = MathAbs(WavesDirection[4][4] - WavesDirection[3][4]); break;
      case -3: time = MathAbs(WavesDirection[5][4] - WavesDirection[4][4]); break;
      case -4: time = 0; break;
   }
   return(time);
}

int TimeBreakDirection(int direction){
   int time = 0;
   switch (direction){      
      case 0: 
         time = MathAbs(WavesDirection[0][5] - WavesDirection[1][4]); 
         if (WavesDirection[0][5] == 0) time = 0;
         break;
      case 1: 
         time = MathAbs(WavesDirection[6][5] - WavesDirection[0][4]); 
         if (WavesDirection[6][5] == 0) time = 0;
         break;
      case 2: 
         time = MathAbs(WavesDirection[7][5] - WavesDirection[6][4]);
         if (WavesDirection[7][5] == 0) time = 0;
         break;         
      case 3: 
         time = MathAbs(WavesDirection[8][5] - WavesDirection[7][4]); 
         if (WavesDirection[8][5] == 0) time = 0;
         break;                   
      case 4: 
         time = MathAbs(WavesDirection[9][5] - WavesDirection[8][4]); 
         if (WavesDirection[9][5] == 0) time = 0;         
         break;
   }
   return(time);
}



double DirectionPriceLenght(int direction){
   double Lenght = 0;
   switch (direction){
      case 1: Lenght = (WavesDirection[0][1] - WavesDirection[0][0]); break; 
      case 2: Lenght = (WavesDirection[6][1] - WavesDirection[6][0]); break; 
      case 3: Lenght = (WavesDirection[7][1] - WavesDirection[7][0]); break;
      case 4: Lenght = (WavesDirection[8][1] - WavesDirection[8][0]); break; 
      case 5: Lenght = (WavesDirection[9][1] - WavesDirection[9][0]); break;
      
      case  0: Lenght = (WavesDirection[1][1] - WavesDirection[1][0]); break; 
      case -1: Lenght = (WavesDirection[2][1] - WavesDirection[2][0]); break; 
      case -2: Lenght = (WavesDirection[3][1] - WavesDirection[3][0]); break;
      case -3: Lenght = (WavesDirection[4][1] - WavesDirection[4][0]); break;
      case -4: Lenght = (WavesDirection[5][1] - WavesDirection[5][0]); break;
   }
   Lenght = MathAbs(Lenght);
   return(Lenght);
}

int CheckDirection(int direction){
   switch (direction){
      case 1: return(WavesDirection[0][7]); 
      case 2: return(WavesDirection[6][7]); 
      case 3: return(WavesDirection[7][7]); 
      case 4: return(WavesDirection[8][7]); 
      case 5: return(WavesDirection[9][7]);
      
      case  0: return(WavesDirection[1][7]); 
      case -1: return(WavesDirection[2][7]); 
      case -2: return(WavesDirection[3][7]);
      case -3: return(WavesDirection[4][7]);
      case -4: return(WavesDirection[5][7]);
   }
}

double DirectionEndPrice(int direction){
   switch (direction){
      case 1: return(WavesDirection[0][1]); 
      case 2: return(WavesDirection[6][1]); 
      case 3: return(WavesDirection[7][1]); 
      case 4: return(WavesDirection[8][1]); 
      case 5: return(WavesDirection[9][1]);
      
      case  0: return(WavesDirection[1][1]); 
      case -1: return(WavesDirection[2][1]); 
      case -2: return(WavesDirection[3][1]);
      case -3: return(WavesDirection[4][1]);
      case -4: return(WavesDirection[5][1]);
   }
}

double DirectionBeginPrice(int direction){
   switch (direction){
      case 1: return(WavesDirection[0][0]); 
      case 2: return(WavesDirection[6][0]); 
      case 3: return(WavesDirection[7][0]); 
      case 4: return(WavesDirection[8][0]); 
      case 5: return(WavesDirection[9][0]);
      
      case  0: return(WavesDirection[1][0]); 
      case -1: return(WavesDirection[2][0]); 
      case -2: return(WavesDirection[3][0]);
      case -3: return(WavesDirection[4][0]);
      case -4: return(WavesDirection[5][0]);
   }
}

int DirectionEndShift(int direction){
   switch (direction){
      case 1: return(WavesDirection[0][3]); 
      case 2: return(WavesDirection[6][3]); 
      case 3: return(WavesDirection[7][3]); 
      case 4: return(WavesDirection[8][3]); 
      case 5: return(WavesDirection[9][3]);
      
      case  0: return(WavesDirection[1][3]); 
      case -1: return(WavesDirection[2][3]); 
      case -2: return(WavesDirection[3][3]);
      case -3: return(WavesDirection[4][3]);
      case -4: return(WavesDirection[5][3]);
   }
}

int DirectionBeginShift(int direction){
   switch (direction){
      case 1: return(WavesDirection[0][2]); 
      case 2: return(WavesDirection[6][2]); 
      case 3: return(WavesDirection[7][2]); 
      case 4: return(WavesDirection[8][2]); 
      case 5: return(WavesDirection[9][2]);
      
      case  0: return(WavesDirection[1][2]); 
      case -1: return(WavesDirection[2][2]); 
      case -2: return(WavesDirection[3][2]);
      case -3: return(WavesDirection[4][2]);
      case -4: return(WavesDirection[5][2]);
   }
}

int Direction(int direction){
   switch (direction){
      case 1: return(WavesDirection[0][7]); 
      case 2: return(WavesDirection[6][7]); 
      case 3: return(WavesDirection[7][7]); 
      case 4: return(WavesDirection[8][7]); 
      case 5: return(WavesDirection[9][7]);
      
      case  0: return(WavesDirection[1][7]); 
      case -1: return(WavesDirection[2][7]); 
      case -2: return(WavesDirection[3][7]);
      case -3: return(WavesDirection[4][7]);
      case -4: return(WavesDirection[5][7]);
   }
}

double DirectionMaxLevel(int direction){
   switch (direction){
      case 1: return(WavesDirection[0][8]); 
      case 2: return(WavesDirection[6][8]); 
      case 3: return(WavesDirection[7][8]); 
      case 4: return(WavesDirection[8][8]); 
      case 5: return(WavesDirection[9][8]);
      
      case  0: return(WavesDirection[1][8]); 
      case -1: return(WavesDirection[2][8]); 
      case -2: return(WavesDirection[3][8]);
      case -3: return(WavesDirection[4][8]);
      case -4: return(WavesDirection[5][8]);
   }
}

double DirectionMinLevel(int direction){
   switch (direction){
      case 1: return(WavesDirection[0][9]); 
      case 2: return(WavesDirection[6][9]); 
      case 3: return(WavesDirection[7][9]); 
      case 4: return(WavesDirection[8][9]); 
      case 5: return(WavesDirection[9][9]);
      
      case  0: return(WavesDirection[1][9]); 
      case -1: return(WavesDirection[2][9]); 
      case -2: return(WavesDirection[3][9]);
      case -3: return(WavesDirection[4][9]);
      case -4: return(WavesDirection[5][9]);
   }
}

int DirectionWaveInPointArray(int direction){
   switch (direction){
      case 1: return(WavesDirection[0][4]); 
      case 2: return(WavesDirection[6][4]); 
      case 3: return(WavesDirection[7][4]); 
      case 4: return(WavesDirection[8][4]); 
      case 5: return(WavesDirection[9][4]);
      
      case  0: return(WavesDirection[1][4]); 
      case -1: return(WavesDirection[2][4]); 
      case -2: return(WavesDirection[3][4]);
      case -3: return(WavesDirection[4][4]);
      case -4: return(WavesDirection[5][4]);
   }
}

int WavesCountInDirection(int direction){
   switch (direction){
      case 1: return(WavesDirection[0][6]); 
      case 2: return(WavesDirection[6][6]); 
      case 3: return(WavesDirection[7][6]); 
      case 4: return(WavesDirection[8][6]); 
      case 5: return(WavesDirection[9][6]);
      
      case  0: return(WavesDirection[1][6]); 
      case -1: return(WavesDirection[2][6]); 
      case -2: return(WavesDirection[3][6]);
      case -3: return(WavesDirection[4][6]);
      case -4: return(WavesDirection[5][6]);
   }
}

int DirectionIndexInMonoWaveRule(int direction){
   switch (direction){
      case 1: return(WavesDirection[0][10]); 
      case 2: return(WavesDirection[6][10]); 
      case 3: return(WavesDirection[7][10]); 
      case 4: return(WavesDirection[8][10]); 
      case 5: return(WavesDirection[9][10]);
      
      case  0: return(WavesDirection[1][10]); 
      case -1: return(WavesDirection[2][10]); 
      case -2: return(WavesDirection[3][10]);
      case -3: return(WavesDirection[4][10]);
      case -4: return(WavesDirection[5][10]);
   }
}

