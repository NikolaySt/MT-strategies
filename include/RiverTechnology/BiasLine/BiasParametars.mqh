string BASE_NAME_BIAS = "biaslevel";    //Име на хоризонаталната линия която 
                                        //маркира нивото на цената където настъпва смяна na отклонението

//Параметри записващи текущото състояние на цената
double bias_level = 0;
int bias_shift = 0;
int bias_direction = 0; // -1 тренд надолу, +1 тренд нагоре

int bias_begin_shift = 0;
int save_fisrt_bias_shift = 0;
int break_bias_shift = 0;

//-------------МАСИВ съдържащ motion баровете-------------
int count_motion_bars = 0;
double motion_bars[2000][3];
// motion_bars[0][0] - shift
// motion_bars[0][1] - high
// motion_bars[0][2] - low
double MotionBarHigh(int index){return(motion_bars[index][1]);}
double MotionBarLow(int index){return(motion_bars[index][2]);}
int MotionBarShift(int index){return(motion_bars[index][0]);}
int MotionBarFirst(){return(count_motion_bars-1);}

void AddMotionBarToArray(int shift, double high, double low){
   motion_bars[count_motion_bars][0] = shift;
   motion_bars[count_motion_bars][1] = high;
   motion_bars[count_motion_bars][2] = low;
   count_motion_bars++;  
}


//--------------------------------------------------------------
string BiasLineName(string Ex_Name = ""){return(BASE_NAME_BIAS + "_" + MotionBarShift(bias_shift) + "_" + Ex_Name);}
//--------------------------------------------------------------

void InitBiasParametars(){
   bias_level = 0;
   bias_shift = 0;
   bias_direction = 0; // -1 тренд надолу, +1 тренд нагоре

   bias_begin_shift = 0;
   save_fisrt_bias_shift = 0;

   ArrayInitialize(motion_bars, 0);
   count_motion_bars = 0;
}