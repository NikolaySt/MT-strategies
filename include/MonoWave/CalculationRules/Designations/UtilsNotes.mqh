
int Count_Notes;
string Array_Notes[10][2];
 //Array_Notes[0][0] = бележка
 //Array_Notes[0][1] = за друго
//---------------------------------------------------------------------------

//------------------------Array_Designations_Base---------------------------
void InitializeNotes(){
   Count_Notes = 0;
   for (int i = 0; i < 10; i++){
      Array_Notes[i][0] = "";
      Array_Notes[i][1] = "";
   }
}

int CountArrayNotes(){
   return(Count_Notes);   
}

int ArrayNotes_Put(string note = "", string other = "") {
   Array_Notes[Count_Notes][0] = note;    
   Array_Notes[Count_Notes][1] = other;   
   Count_Notes++;
}

string Notes_Get(int index){
   return(Array_Notes[index][0]);
}


void ReplaceNotes(int index, string note, string other){   
   Array_Notes[index][0] = note;    
   Array_Notes[index][1] = other;    
}
 
int AddNote(string note, string other = ""){   
   ArrayNotes_Put(note, other);    
}










