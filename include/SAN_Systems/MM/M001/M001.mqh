#define M001_FP_TYPE  1000
#define M001_FF_TYPE  2000

// ���������� ����� �� ������� �� ��������� �� �������� ����� ���� �������� �� ���������
double M001_Comment_Risk = 0;
double M001_Comment_Level = 0;
double M001_Comment_Limit1 = 0;
double M001_Comment_Limit21 = 0;
double M001_Comment_Limit22 = 0;
double M001_Comment_Limit3 = 0;
double M001_Comment_VB = 0;
double M001_Comment_DD = 0;
double M001_Comment_DD_Percent = 0;
double M001_Comment_Withdrawal = 0;
//----------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------
//������� �� ���. ��������������� �����
int M001_FP_Limit1  = 2;   //���� 1   - � ������� �� ��� ���� �� �����
int M001_FP_Limit21 = 4;   //���� 2.1 - 4 -�� ���� ������� ��������� ��������
double M001_FP_Limit22 = 30;  //���� 2.2 - 30% �� ���� 2.1 ��� �� ���������� �� ����������� �������� ������ ������� ������
double M001_FP_Limit31 = 50;  //���� 3   - �� 6-�� ���� � 50% �� �������� ������� ���� 6-�� ���� � 
int M001_FP_Limit32 = 6;   //���� 3   6-�� ���� � 6 ���� ����� ��� �� ��������� ����3 �� ����� ������������ ����������
//----------------------------------------------------------------------------------------------
//������� �� ���. ����������� �����
double M001_FF_Limit1  = 7;  //7%  �������� ����������� �� ������� ������� �� ����. ������������ ����
double M001_FF_Limit21 = 22; //22% �������� ����������� �� ������� ������� �� ����. ������������ ����
double M001_FF_Limit22 = 30;  //30%  �� ����2.1
double M001_FF_Limit3  = 33;  //33%  �� ����������� ��������� ������                               
//-----------------------------------------------------------------------------------------------

int M001_Tickets[];

bool M001_MM_Trace = false;
void M001_MM_SetTrace(bool value){
   M001_MM_Trace = value;
   if (M001_MM_Trace){   
      if (IsTesting()) FileDelete("MM_trace.csv");
      int file = FileOpen("MM_trace.csv", FILE_WRITE|FILE_READ, ",");                 
      if (!IsTesting()) FileSeek(file, 0, SEEK_END);
      FileWrite(file, "TIME,TYPE,MAXBalance,Profit,Balance,Virtual,Limit1,Limit21,Limit22,Limit3,Lots,FPlevel,FFlevel,FPRisk,MaxLevel,Withdrawal");
      FileClose(file);      
   }   
}

void M001_MM_Init(int settID)
{
   if (M001_FP_AvailableBalance == 0) M001_FP_AvailableBalance = M001_FP_BeginBalance;
   
   if (!IsTesting()) {//��� �������������� � ����� �� ������ ������      
      //����� ���� ���������� �� �� ������� ������������       
      //����� �� ������� �� ��������� �� �������� ����� ���� �������� �� ���������
      //�� ���� ����� � ������� �� ������� �� �������� ������ ����� �� �� ������ �� ������� ������.      
      M001_MM_Get(settID);
      if (M001_MM_Trace) 
         Print("[M001_MM_Init] M001_Comment: "
            ,"M001_Comment_Risk = ", M001_Comment_Risk
            ,"M001_Comment_Level = ", M001_Comment_Level
            ,"M001_Comment_Limit1 = ", M001_Comment_Limit1
            ,"M001_Comment_Limit21 = ", M001_Comment_Limit21
            ,"M001_Comment_Limit22 = ", M001_Comment_Limit22
            ,"M001_Comment_Limit3 = ", M001_Comment_Limit3
            ,"M001_Comment_VB = ", M001_Comment_VB
            ,"M001_Comment_DD = ", M001_Comment_DD
            ,"M001_Comment_DD_Percent = ", M001_Comment_DD_Percent
            ,"M001_Comment_Withdrawal = ", M001_Comment_Withdrawal);
   }
}

//---����������� �� ��������� �������������� ����� ��� ��������� ���������� ����� -----
double M001_MM_Get(int settID){   
   string mm_type_trace = "";
   double virtual_balance;
   bool check_virtual = false;

   double Limit1 = 0, Limit21 = 0, Limit22 = 0,  Limit3 = 0;      
   double Lots = MM_LotStep;                   

   double Withdrawal[1]; //13.04.2011 �������� �� ������� �� ���� ��� �� �� �������� ��  
   Withdrawal[0] = 0;
   ///�����: 23.12.2010 ������ �� �� �������� �� �� ���� ��� �� ������ ���� ���� �� �� ����� �� ������������ �� ��������     
   // ���� ������ �� �� ������� �� ��� ������ ������ ��� ������� � �� ����������.
   
   double max_balance = 0;
   if (IsTesting()){
      //�� ����� �� ���� �������� �� ��������� ����� �� ���������. ��� ����� �� � ���������� �� �� 
      //����� �������� ���������.
      max_balance = MM_History_MaxBalance(M001_FP_BeginBalance, M001_FP_AvailableBalance, MM_TimeStart, Withdrawal);          
   }else{        
      //�����: ������ � � ����� �� ������ ������ �������� �� ��������� �� ������ �� ������� ��� �������� �� ��� ����� �� ���������
      //��� ����� ���������� ���������� �������� � �����
      //������ � ���������� �� �� ������� ��������� ����� ����� �������� � MM_History_MaxBalance_SortByCT �
      //����� ����� � �������� �� ������ ������ � ��������� �� OP_BUY � OP_SELL ��������� �� ����� �� ���������
      //M001_Tickets ������ �� ��� �������� VirtBalance
      max_balance = MM_History_MaxBalance_SortByCT(M001_FP_BeginBalance, M001_FP_AvailableBalance, MM_TimeStart, M001_Tickets, Withdrawal);      
   }        
   double balance = AccountBalance() + MathAbs(Withdrawal[0]);  
   M001_Comment_Withdrawal = Withdrawal[0];
      
   //�������  
   //�������� ����� ���� ���. �������������� ����� �� �� ������� ������������ ��� "��������� ����������"      
   //���������� ���������� ����������� ������ �� �� ���������� ����� ����
   //������ ������ ���� ���������� �� �� ������ �� �� ������� �� ��             
   //�������������� ����� �� ����� ����� �� �������   
   double max_level = MM_FP_Level(max_balance - M001_FP_BeginBalance, M001_FP_Delta);
   double fp_risk = (max_level*M001_FP_MaxDD)/max_balance; 
   M001_Comment_Risk = fp_risk;
   
   M001_Comment_DD = max_balance - balance;
   M001_Comment_DD_Percent = M001_Comment_DD/max_balance;
   /*
   if (M001_Comment_DD > 0) {
      M001_Comment_DD = 0;
      M001_Comment_DD_Percent = 0;
   }      
   */
                  
   if (M001_FF_PersentDD < fp_risk*100){                                                  
      if (M001_MM_Trace) mm_type_trace = "FP";
      
      M001_FP_Limits(settID, max_balance, M001_FP_BeginBalance, M001_FP_Delta, M001_FP_MaxDD, Limit1, Limit21, Limit22, Limit3);
      
      double profit = balance - M001_FP_BeginBalance;
      
      //�������� ���� 1-----------------------------------------------------------------------------------------     
      if (Limit1 > 0){
         if (balance > Limit1) profit = max_balance - M001_FP_BeginBalance;                        
      }         
      //-----------------------------------------------------------------------------------------------                                                              
      
      double fp_level = MM_FP_Level(profit, M001_FP_Delta);      
      Lots = MM_LotStep * fp_level;              
      M001_Comment_Level = fp_level;
                       
      //�������� ���� 2-----------------------------------------------------------------------------------------------                
      if (Limit21  > 0 && Limit22 > 0){
         virtual_balance = M001_Get_VirtBalance(settID, M001_FP_TYPE, M001_FP_BeginBalance, MM_LotStep, check_virtual);                                                           
         if (virtual_balance < Limit21 || (virtual_balance < Limit22 && check_virtual)){
            //��� ����������� � �� ����� �� ��������� �� ������ � �������� ������/
            //������ � ������ �����21 �� ������� ���� �� ���� ���� ������� � ��� ����
            //�� � �� ����� �� 30% ����������. ����������� ���� � ��������� �����22 ��� � ����
            //�� �������� �� ��� �������� ������ � 0.01 ������������ ������������ �� ������ � 0.01
            //����� � �������� �� ������ ����� �� �������� �� ������                
            Lots = MarketInfo(Symbol(), MODE_MINLOT);                                                                                
         }                                   
      }
      //-----------------------------------------------------------------------------------------------     
                               
      //�������� ���� 3-----------------------------------------------------------------------------------------         
      if (Limit3 > 0){
         //������� 1 - do 6-�� ���� 50% �� �������� �������
         //������� 2 - ������ ��� ���������� ���� ��-������ �� 6, ��������� � 6 ���� �� ����� 
         if (balance < Limit3 || (virtual_balance > 0 && virtual_balance < Limit3)) Lots = 0;          
      }
      //-----------------------------------------------------------------------------------------------                         
   }else{      
      if (M001_MM_Trace) mm_type_trace = "FF";
      M001_Comment_Risk = M001_FF_PersentDD;
      
      M001_FF_Limits(settID, max_balance, M001_FP_MaxDD, M001_FF_PersentDD, Limit1, Limit21, Limit22, Limit3);
      
      //��������� ���������� ����� �� ���������� �� ��������                  
      double ff_begin_balance = M001_FP_MaxDD/(M001_FF_PersentDD/100);                                       
      double ff_level = MM_FF_Level(max_balance, ff_begin_balance);                 
      //-----------------------------------------------------------------------------------------------
               
      //�������� ���� 1-----------------------------------------------------------------------------------------
      if  (Limit1 > 0){
         if (balance < Limit1) ff_level = MM_FF_Level(balance, ff_begin_balance); 
      }
      //-----------------------------------------------------------------------------------------------
      
      Lots = MM_LotStep * ff_level;                       
      M001_Comment_Level = ff_level;
               
      //�������� ���� 2-----------------------------------------------------------------------------------------
      if (Limit21 > 0 && Limit22 > 0){
         virtual_balance = M001_Get_VirtBalance(settID, M001_FF_TYPE, M001_FP_BeginBalance/*ff_begin_balance*/, MM_LotStep, check_virtual);           
         if (virtual_balance < Limit21 || (virtual_balance < Limit22 && check_virtual))  Lots = MarketInfo(Symbol(), MODE_MINLOT); // minimalen lot za da registrira pora4kata
      }     
                              
      //�������� ���� 3-----------------------------------------------------------------------------------------
      if (Limit3 > 0){
         if (balance < Limit3 || (virtual_balance > 0 && virtual_balance < Limit3)) Lots = 0;
      }         
      //-----------------------------------------------------------------------------------------------                                       
   } 
   
   M001_Comment_Limit1 = Limit1;
   M001_Comment_Limit21 = Limit21;
   M001_Comment_Limit22 = Limit22;
   M001_Comment_Limit3 = Limit3;
   M001_Comment_VB = virtual_balance;   
                        
   if (M001_MM_Trace){    
      int file = FileOpen("MM_trace.csv", FILE_WRITE|FILE_READ, ";");     
      if (file > 0){
         FileSeek(file, 0, SEEK_END);  
         FileWrite(file, 
            TimeToStr(TimeCurrent())+","+
            mm_type_trace+"," +             
            DoubleToStr(max_balance, 2)+","+
            DoubleToStr(profit, 2)+","+
            DoubleToStr(balance, 2)+","+
            DoubleToStr(virtual_balance, 2)+","+
            DoubleToStr(Limit1, 2)+","+
            DoubleToStr(Limit21, 2)+","+
            DoubleToStr(Limit22, 2)+","+
            DoubleToStr(Limit3, 2)+","+
            DoubleToStr(Lots, 2)+","+
            DoubleToStr(fp_level, 0)+","+
            DoubleToStr(ff_level, 0)+","+
            DoubleToStr(fp_risk*100, 0)+","+
            DoubleToStr(max_level, 0)+","+
            DoubleToStr(Withdrawal[0], 0)
            
         );
         FileClose(file);               
      }
   }
       
   if (Lots > 0){
      Lots = NormalizeDouble(Lots, MM_Lots_RoundDig(MarketInfo(Symbol(), MODE_LOTSTEP)));                  
      return(MM_Lots_LimitBroker(Lots));
   }else{
      return(0);
   }
}


void M001_FP_Limits(int settID, double MaxBalance, double BeginBalance, double Delta, double MaxDD, 
   double& Limit1, double& Limit21, double& Limit22, double& Limit3){
   // �� ���� ������� 
   
   //��������� �������������� �����   
   int max_level = MM_FP_Level(MaxBalance - BeginBalance, Delta);   
   double down_limit_level = MM_FP_Level_DownLimit(max_level, BeginBalance, Delta);                                      
   double offset;
   
   
   if (max_level <= 8){    
      Limit1 = 0;      
   }else{
      if (M001_FP_Limit1 > 0 ){         
         //���� 1 �� ���������� � ������� �� 2 ���� �� �����   
         double l_up =   MM_FP_Level_DownLimit(max_level - M001_FP_Limit1 + 1, BeginBalance, Delta);
         double l_down = MM_FP_Level_DownLimit(max_level - M001_FP_Limit1, BeginBalance, Delta);                   
               
         Limit1 = l_down + (l_up - l_down)/2;        
      }        
   }
   
   if (max_level <= 6){  
      //�� 6-�� ���� ���� 1, 2 � ��������                    
      Limit21 = 0;
      Limit22 = 0;
   }else{  
      if (M001_FP_Limit21 > 0 ) {
         Limit21 = MM_FP_Level_DownLimit(max_level - M001_FP_Limit21, BeginBalance, Delta);       
         Limit22 = Limit21 + (MaxBalance - Limit21)*(M001_FP_Limit22/100); 
      }         
   }   
               
   if (max_level <= 6){  
      //�� 6-�� ������� �� ������������� �������                
      if (M001_FP_Limit31 > 0 ) Limit3 = BeginBalance*(M001_FP_Limit31/100);
   }else{                  
      if (M001_FP_Limit32 > 0){
         Limit3 = MM_FP_Level_DownLimit(max_level - M001_FP_Limit32, BeginBalance, Delta);
      }
   } 
} 

void M001_FF_Limits(int settID, double MaxBalance, double MaxDD, double PercentDD, 
   double& Limit1, double& Limit21, double& Limit22, double& Limit3){                   
   //�������� ��������� �� ���. ����. ����� ������ ��� � �������� �������
   
   //��������� ���������� �����                 
   double FPBeginBalance = MaxDD/(PercentDD/100);               
   double max_level = MM_FF_Level(MaxBalance, FPBeginBalance);
   double down_limit_level = MM_FF_Level_DownLimit(max_level, FPBeginBalance);                  
   double offset;
   
   //------------------------------------------------------------------------                                       
   if (M001_FF_Limit1 > 0){
      Limit1 = MM_FF_Level_DownLimit(
                     MM_FF_Level(
                           down_limit_level - down_limit_level*(M001_FF_Limit1/100), 
                           FPBeginBalance), 
                     FPBeginBalance);                                                        
   }
   
   if (M001_FF_Limit21 > 0){
      Limit21 = MM_FF_Level_DownLimit(
                     MM_FF_Level(
                           down_limit_level - down_limit_level*(M001_FF_Limit21/100), 
                           FPBeginBalance), 
                     FPBeginBalance);  
      Limit22 = Limit21 + (MaxBalance - Limit21)*(M001_FF_Limit22/100);                
   }         
   
   if (M001_FF_Limit3 > 0){
      Limit3 = MM_FF_Level_DownLimit(
                     MM_FF_Level(
                           down_limit_level - down_limit_level*(M001_FF_Limit3/100), 
                           FPBeginBalance), 
                     FPBeginBalance);
   }         
   //------------------------------------------------------------------------
}  

double M001_Get_VirtBalance(int settID, int FP_FF_Type, 
   double BeginBalance, double ContractStep, bool& ch_virtual_trade){
   
   double MinLots = MarketInfo(Symbol(), MODE_MINLOT);   
   
   double balance = MathMax(BeginBalance, M001_FP_AvailableBalance);      
   BeginBalance = MathMax(BeginBalance, M001_FP_AvailableBalance);
      
   double max_balance = MathMax(balance, AccountBalance());      
   double virt_balance = BeginBalance;//max_balance;      
   ch_virtual_trade = false;   
   
   double order_result = 0, level; 
   double Delta = M001_FP_Delta;
   int ID;   
      
   if (M001_MM_Trace){
      string filename = "";
      if (FP_FF_Type == M001_FP_TYPE) filename = "MM_FP_trace_virtual.csv";
      if (FP_FF_Type == M001_FF_TYPE) filename = "MM_FF_trace_virtual.csv";
         
      if (IsTesting()) FileDelete(filename);
      int file = FileOpen(filename, FILE_WRITE|FILE_READ, ",");                 
      if (!IsTesting()) FileSeek(file, 0, SEEK_END);
      FileWrite(file, "Time,Virtual,VirtualProfit,Virtuallevel");
   }         
   
   int hstTotal = 0;
   if (IsTesting()){
      hstTotal = OrdersHistoryTotal();
   }else{      
      hstTotal = ArraySize(M001_Tickets);
   }      
   for(int i = 0; i < hstTotal; i++){
      if (IsTesting()){
         if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      }else{
         if (!OrderSelect(M001_Tickets[i], SELECT_BY_TICKET, MODE_HISTORY)) continue;
      }
      if ((OrderType() == OP_BUY) || (OrderType() == OP_SELL)&&(MM_TimeStart == 0 || OrderOpenTime() >= MM_TimeStart)){                                   
         order_result = OrderProfit() + OrderSwap() + OrderCommission();                        
         balance = balance + order_result;                           
         if (NormalizeDouble(max_balance, 2) <= NormalizeDouble(balance, 2)){
            max_balance = balance;
            virt_balance = balance; 
            ch_virtual_trade = false;
         }else{                           
            if (OrderLots() == MinLots && ContractStep != MinLots){                                     
               ch_virtual_trade = true;
               
               //��������� �������������� �����                                   
               if (FP_FF_Type == M001_FP_TYPE) level = MM_FP_Level(virt_balance - BeginBalance, Delta);                  
               //��������� ���������� ����� 
               if (FP_FF_Type == M001_FF_TYPE) level = MM_FF_Level(virt_balance, M001_FP_MaxDD/(M001_FF_PersentDD/100) /*BeginBalance*/);                                                                 
                                             
               if (level == 0) {
                  Print("[M001_Get_VirtBalance] level = 0, ����������� �������� �� ��������� �������� ������");
                  Alert("[M001_Get_VirtBalance] level = 0, ����������� �������� �� ��������� �������� ������");
                  level = 1; //��� ��� ������                     
               }                     
               
               virt_balance = virt_balance + order_result*((level * 0.1)/0.01);                                                                                                                                                                
               
               if (M001_MM_Trace){                         
                  if (file > 0){
                     FileSeek(file, 0, SEEK_END);  
                     FileWrite(file, TimeToStr(TimeCurrent())+","+ID+"," +DoubleToStr(virt_balance, 2)+","+DoubleToStr(virt_balance - BeginBalance, 2)+","+DoubleToStr(level, 0));                        
                  }
               } 
                                                                     
            }else{                  
               virt_balance = virt_balance + order_result;
            }     
                                     
         }                       
      }                           
   }            
   if (M001_MM_Trace) {
      if (file > 0) FileClose(file);       
   }      
   return(virt_balance);
}