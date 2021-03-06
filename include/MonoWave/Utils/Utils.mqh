

bool WorkTime(string DefaultTime){
   if (DefaultTime == "all"){
      return(true);
   }
   int period = Period();
   switch (period){
      case PERIOD_M5:  if (DefaultTime == "60") return(true); else return(false);
      case PERIOD_M15: if (DefaultTime == "288") return(true); else return(false);
      case PERIOD_H1:  if (DefaultTime == "daily") return(true); else return(false);
      case PERIOD_H4:  if (DefaultTime == "weekly") return(true); else return(false);
      case PERIOD_D1:  if (DefaultTime == "monthly") return(true); else return(false);      
      case PERIOD_W1:  if (DefaultTime == "twofold") return(true); else return(false);
      case PERIOD_MN1: if (DefaultTime == "sixfold") return(true); else return(false);      
   }
}

string ChartPeriodInfo(){
   string DefaultTime;
   switch (Period()){
      case PERIOD_M5:  DefaultTime = "60"; break;
      case PERIOD_M15: DefaultTime = "288"; break;
      case PERIOD_H1:  DefaultTime = "daily"; break;
      case PERIOD_H4:  DefaultTime = "weekly"; break;
      case PERIOD_D1:  DefaultTime = "monthly"; break;
      case PERIOD_W1:  DefaultTime = "twofold"; break;
      case PERIOD_MN1: DefaultTime = "sixfold"; break; 
   default:
      DefaultTime = "";      
   }
   return(DefaultTime);
}



