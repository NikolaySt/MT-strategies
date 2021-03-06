extern string About   = "Copyright © 2007 Nikolay Stoychev";
extern string eMail   = "n_stoichev@yahoo.com";

extern string Version = "4.0";
extern string Revision= "03.01.2009";
string Expiration= "31.12.2050";
string Info = "";

int SetInfo(string Others_info = "", string Others_info_2 = ""){
   
   string set_text = Decoding();
   if (Others_info != ""){
      set_text = //set_text + "\n" + 
         Symbol() + " - "+ Others_info + " - "+ Day() + "."+ Month()+"."+ Year();
   }
   if (Others_info_2 != ""){
      set_text = set_text + "\n" + 
      "-------------------" + "\n"+ 
      Others_info_2;
   }   
   Comment(set_text);  
}

/*
string Coding(){
   //string info = "Copyright © 2007, Ariadna Ltd \nBulgaria, Plovdiv - tel. ++35932683557";
   //string info = "Copyright © 2007, Ariadna Ltd"+"\n"+"e-mail: ariadna_ltd@yahoo.com"+"\n"+Version+" - "+Revision;
   string info = "Copyright © 2007";
   int code;
   string codestring;
   Print("----- begin ----- Coding Text ------------------");
   for (int i = 0; i < StringLen(info); i++){
      code = StringGetChar(info, i);
      if (MathMod(i, 10) == 0){
         Print(codestring);
         codestring = "";
      }
      codestring = codestring + "info = info + CharToStr("+code + "); ";
   }
   Print(codestring);  
   Print("----- end ----- Coding Text ------------------");    
}
*/
string Decoding(){
   string info = "";
  

//info = info + CharToStr(67); info = info + CharToStr(111); info = info + CharToStr(112); info = info + CharToStr(121); info = info + CharToStr(114); info = info + CharToStr(105); info = info + CharToStr(103); info = info + CharToStr(104); info = info + CharToStr(116); info = info + CharToStr(32); 
//info = info + CharToStr(169); info = info + CharToStr(32); info = info + CharToStr(50); info = info + CharToStr(48); info = info + CharToStr(48); info = info + CharToStr(55); 

  
   return(info);
}

