//+------------------------------------------------------------------+
//|                                             FC_AccountToFile.mq4 |
//|                               Copyright © 2011, Nikolay Stoychev |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Stoychev"
#property link      ""

string exFileName = "DataAccount";

int EXP_Save_hour = -1;
int EXP_FileHandle = 0;

int init(){      
   EXP_FileHandle = FileOpen(exFileName+"_"+AccountNumber()+".txt", FILE_WRITE|FILE_READ, ';');
   if (EXP_FileHandle < 1){
      Print("ERROR:: File -> " + exFileName+"_"+AccountNumber()+".txt");
      return(0);  
   }else{      
      if (FileSize(EXP_FileHandle) == 0){
         FileWrite(EXP_FileHandle, "TIME;BALANCE;EQUITY;MARGIN;FREEMARGIN;P/L;"); 
      }else{
         FileSeek(EXP_FileHandle, 0, SEEK_END);   
      }  
   }      
   return(0);
}
  
int deinit(){
   if (EXP_FileHandle > 0) {
      FileClose(EXP_FileHandle);  
   }      
   return(0);
}

int start(){  
   int hour = TimeHour(Time[0]);   
   if (EXP_Save_hour == -1 || EXP_Save_hour != hour){
      EXP_Save_hour = hour;      
      if (EXP_FileHandle > 0){  
         //"BALANCE, EQUITY, MARGIN, FREE MARGIN, P/L" 
         string text =
            TimeToStr(Time[0]) + ";" +
            DoubleToStr(AccountBalance(),2) + ";" + 
            DoubleToStr(AccountEquity(), 2) + ";" + 
            DoubleToStr(AccountMargin(), 2) + ";" + 
            DoubleToStr(AccountFreeMargin(), 2) + ";" + 
            DoubleToStr(AccountProfit(), 2) + ";"; 
               
         FileWrite(EXP_FileHandle, text);                  
      }    
   }
   return(0);
}

