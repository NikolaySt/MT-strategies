

int FHandle = 0;
bool Chack_One_Save_ToFile = false;
bool OpenFile(){
   if (Chack_One_Save_ToFile) return(false);
   
   
   
   FHandle = FileOpen("RT_ChangeElements.txt", FILE_READ|FILE_WRITE);
   if(FHandle < 1){
     Print("File RT_ChangeElements.csv not found, the last error is ", GetLastError());
     return(false);
   } 


}

bool SaveToFile(int time, int price, int bias){
   if (Chack_One_Save_ToFile) return(false);
   if(FHandle < 1){
     Print("File RT_ChangeElements.csv not found, the last error is ", GetLastError());
     return(false);
   }    
   string value = DoubleToStr(time, 0) + "," + DoubleToStr(price, 0) + "," + DoubleToStr(bias, 0);
   FileWrite(FHandle, time, price, bias);
   return(true);
}

bool CloseFile(){
   if (Chack_One_Save_ToFile) return(false);
   
   if(FHandle < 1){
     Print("File RT_ChangeElements.csv not found, the last error is ", GetLastError());
     return(false);
   }    
   FileClose(FHandle); FHandle = 0;
   
   Chack_One_Save_ToFile = true;
   return(true);
}


