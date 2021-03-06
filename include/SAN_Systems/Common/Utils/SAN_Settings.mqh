//+------------------------------------------------------------------+
//|                                               SAV_Settings.mqh   |
//|                       #include <SAV_Framework/SAV_Settings.mqh>  |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2010, Andrey Kunchev"
#property link      "http://www.metaquotes.net"

//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
//internal defines
#define SAV_SETTINGS_MAXSIZE  300
#define SAV_SETTINGS_PARAMSMAXSIZE 400
//-------------------------------------------------------------------------------------

//settings variables
//-------------------------------------------------------------------------------------

string SAV_SETTINGS_NAME_MAPPINGS[SAV_SETTINGS_PARAMSMAXSIZE];
int   SAV_MAPPINGS_Size =1;
string SAV_SETTINGS_STORAGE_NAMES[SAV_SETTINGS_MAXSIZE,SAV_SETTINGS_PARAMSMAXSIZE];
string SAV_SETTINGS_STORAGE_VALUES[SAV_SETTINGS_MAXSIZE,SAV_SETTINGS_PARAMSMAXSIZE];
int SAV_SETTINGS_STORAGE_VALUESINT[SAV_SETTINGS_MAXSIZE,SAV_SETTINGS_PARAMSMAXSIZE];
bool SAV_SETTINGS_STORAGE_VALUESBOOL[SAV_SETTINGS_MAXSIZE,SAV_SETTINGS_PARAMSMAXSIZE];
double SAV_SETTINGS_STORAGE_VALUESDBL[SAV_SETTINGS_MAXSIZE,SAV_SETTINGS_PARAMSMAXSIZE];

static int SAV_SETTINGS_TotalCount=0;
static bool SAV_SETTINGS_Trace = false;
//-------------------------------------------------------------------------------------

void SAV_Settings_Init(){
   //----------------------------------------------------------------
   //МНОГО ВАЖНО!!!
   //инициализира масивите трябва винаги да се вика в init() на експерта или портфейла
   //защото когато един експерт се пусне реално да работи и примерно по някаква причина се сменят 
   //часовите нива или се се смени инструмента то в масивите остават записи които после водят до съществени 
   //отклонения които наблюдавахме в началото когато пуснахме портфейла и бяхме превключвали между нивата на H4, H1, Daily.
   //и експерта спря да работи като даваше грешка SignalBaseName = "" SignalIndex = 
   //защото масивите са пълни със данни които не се изчистват
   //Това се получава защото експерта не се презарежда в буквалния смисъл а само се инициализира и пълните стойности и масиви
   //си остават.
   //нужно е само да се инициализира SAV_SETTINGS_TotalCount и SAV_MAPPINGS_Size
   //масивите се инициализират когато се ползват при SAV_Settings_Create
   //----------------------------------------------------------------
    
   SAV_MAPPINGS_Size = 1;
   SAV_SETTINGS_TotalCount = 0;    
}

//functions
//-------------------------------------------------------------------------------------
void SAV_Settings_SetTrace( bool value )
{
   SAV_SETTINGS_Trace = value;
}

int SAV_Settings_GetTotalCount()
{
   return (SAV_SETTINGS_TotalCount);
}
//-------------------------------------------------------------------------------------
int SAV_Settings_Create( string values )
{
   if( SAV_SETTINGS_Trace )
      Print( "[SAV_Settings_Create] enter ...");
   int index;
   index = SAV_SETTINGS_TotalCount;
   SAV_SETTINGS_TotalCount++;
   
   if( values == "" ) return (index);
   
   if( SAV_SETTINGS_TotalCount >= SAV_SETTINGS_MAXSIZE )
   {
      Print("[SAV_Settings_Create] Error!!!!! Bufer size=",
                        SAV_SETTINGS_MAXSIZE, 
                        ";TotalCount=", SAV_SETTINGS_TotalCount);
   }
   
   if( SAV_SETTINGS_Trace )
      Print( "[SAV_Settings_Create] index=", index);
      
   string arrayvalues[];
   //parse all values
   
   SAV_Settings_SplitValues(values, arrayvalues);

   if( SAV_SETTINGS_Trace )
      Print( "[SAV_Settings_Create] Split size=", ArraySize(arrayvalues));
         
   //parse all single value
   string name="",value="";
   
   //reset all arrays to default values
   //in optimization values are rpeserved for the next optimization
   //tere can be unpredicted results !!!!! so everything should be 0
   for(int ii=0;
               ii < SAV_MAPPINGS_Size; 
               //ii < SAV_SETTINGS_PARAMSMAXSIZE; 
               ii++)
   {
      SAV_Settings_SetValueI(index, ii, "");
   }
   
   for( int i = 0; i < ArraySize(arrayvalues); i++ )
   {
      SAV_Settings_AddRawValue(index, arrayvalues[i]);
   }
   
   if( SAV_SETTINGS_Trace )
      Print( "[SAV_Settings_Create] exit ...");
      
   return (index);
}
//-------------------------------------------------------------------------------------
void SAV_Settings_AddRawValue( int settIndex, string data )
{
   string name="", value="";
   SAV_Settings_ParseNameValue( data, name, value );
   SAV_Settings_SetValueByName(settIndex, name, value );   
}
//-------------------------------------------------------------------------------------
void SAV_Settings_SetValueByName( int settIndex, string name, string value )
{
   int valueIndex;
   
   valueIndex = SAV_Settings_GetNameIndex(name);  
   
   //new value still not exist
   if( valueIndex > 0 )
   {  
      SAV_SETTINGS_STORAGE_NAMES[settIndex,valueIndex] = name;
      SAV_Settings_SetValueI(settIndex,valueIndex,value);
      //SAV_SETTINGS_STORAGE_VALUES[settIndex,valueIndex] = value; 
   }

   if( SAV_SETTINGS_Trace == true)
      Print("[SAV_Settings_SetValueByName] name=",name,";value=",value,";valueIndex=",valueIndex);
      
}
//-------------------------------------------------------------------------------------
void SAV_Settings_SetIntValueI( int settIndex, int index, int value )
{
   //SAV_Settings_SetValueI( settIndex, name, value );
   SAV_SETTINGS_STORAGE_VALUESINT[settIndex,index] = value;
}
//-------------------------------------------------------------------------------------
void SAV_Settings_SetValueI( int settIndex, int index, string value )
{
   if( SAV_SETTINGS_Trace )
      Print("[SAV_Settings_SetValueI] settIndex=",settIndex,";index=",index,
         ";value=",value,";name=",SAV_SETTINGS_NAME_MAPPINGS[index] );
   SAV_SETTINGS_STORAGE_VALUES[settIndex,index] = value;
   SAV_SETTINGS_STORAGE_VALUESINT[settIndex,index] = StrToInteger(value);
   SAV_SETTINGS_STORAGE_VALUESDBL[settIndex,index] = StrToDouble(value);
   SAV_SETTINGS_STORAGE_VALUESBOOL[settIndex,index] = SAN_AUtl_StrToBool(value);
}

//-------------------------------------------------------------------------------------
int SAV_Settings_GetNameIndex( string name )
{
   int index = 0;
   int size = SAV_MAPPINGS_Size;
     
   for( int i=0; i < size; i++ )
   {
      if( SAN_AUtl_StrCompare(name, SAV_SETTINGS_NAME_MAPPINGS[i]) == true )
      {
         index = i;
         break;
      }
   }
   
   if( index == 0 )
   {
      Print("[SAV_Settings_GetNameIndex] !!! Fatal Error !!!! Not found name: ", name );
   }
    
   return (index);
}
//-------------------------------------------------------------------------------------
string SAV_Settings_GetValueI( int settIndex, int index )
{
   string value="";
   value = SAV_SETTINGS_STORAGE_VALUES[settIndex,index];  
   return (value);
}
//-------------------------------------------------------------------------------------
int SAV_Settings_GetIntValueI( int settIndex, int index)
{
   int value;
   value = SAV_SETTINGS_STORAGE_VALUESINT[settIndex,index];
   //value = StrToInteger( SAV_Settings_GetValueI( settIndex, index ) );
   return (value);
}
//-------------------------------------------------------------------------------------
bool SAV_Settings_GetBoolValueI( int settIndex, int index )
{
   bool value;
   value = false;
   value = SAV_SETTINGS_STORAGE_VALUESBOOL[settIndex,index];
   //string strValue = SAV_Settings_GetValueI( settIndex, index );
   //if( strValue == "true" )
   //{
   //   value = true;
   //}
   return (value);
}
//-------------------------------------------------------------------------------------
void SAV_Settings_SetDoubleValueI( int settIndex, int index, double value )
{
   SAV_SETTINGS_STORAGE_VALUESDBL[settIndex,index] = value;
   //SAV_Settings_SetValueI( settIndex, index, value );
}
//-------------------------------------------------------------------------------------
void SAV_Settings_SetBoolValueI( int settIndex, int index, bool value )
{
   string strValue = "false";
   if( value == true )
   {
      strValue = "true";
   }  
   SAV_SETTINGS_STORAGE_VALUESBOOL[settIndex,index] = value;
   SAV_Settings_SetValueI( settIndex, index, strValue );
}
//-------------------------------------------------------------------------------------
string SAV_Settings_TrimValue( string value )
{
   return (StringTrimRight(StringTrimLeft(value)));
}
//-------------------------------------------------------------------------------------
void SAV_Settings_GetNameValue( string input, string& values[2] )
{
   string name,value;
   SAV_Settings_ParseNameValue( input, name, value );
   values[0] = name;
   values[1] = value;
}
//----------------------------------------------------------------------------------
string SAV_Settings_GetNamedValue( string input, string name )
{
   string result;
   string values[];
   string tmp_name, value, tmpInput;
   SAV_Settings_SplitValues( input, values );
   
   for( int i = 0; i < ArraySize(values); i++ )
   {
      tmpInput = values[i];
      SAV_Settings_ParseNameValue(tmpInput, tmp_name, value);
      if( tmp_name == name )
      {
         result = value;
         break;
      }       
   }
   
   return (result);
}

//-------------------------------------------------------------------------------------
void SAV_Settings_ParseNameValue( string input, string& name, string& value )
{
   name="";
   value="";
   int val_start = StringFind(input,"=");
   int val_end = StringFind(input,";");
   if( val_end == -1 )
   {
      val_end = StringLen(input);
   }
   
   if( val_start > 0 && val_end > val_start )
   {
      name = StringSubstr(input,0,val_start);
      name = SAV_Settings_TrimValue(name);
      value = SAV_Settings_TrimValue(StringSubstr(input,val_start+1,val_end-val_start-1));
      
      if( StringGetChar(value,0) == '"' )
      {
         if( StringLen(value) == 2 )
         {
            value = "";
         }
         else
         {
           val_end = StringFind(input,"\"",val_start+2); 
           value = SAV_Settings_TrimValue(StringSubstr(input,val_start+2,val_end-val_start-2));
         }   
      }
   }
}
//-------------------------------------------------------------------------------------
int String_GetCount(string value, string search )
{
   int count = 0;
   int index=0;
   
   while(true)
   {
      index = StringFind(value, search, index);

      if( index < 0 ) break;
      
      index++;
      count++;
   }
   
   return (count);
}
//-------------------------------------------------------------------------------------
int  SAV_Settings_SplitValues( string values, string& result_values[] )
{
   static string tmp_values[SAV_SETTINGS_PARAMSMAXSIZE];
   string current;
   int  values_count, start,last,len,countQuotes=0,quoteIndex;

   values_count=0;
   start=0;
   last =0;

   while( last != -1 )
   {   
      last = StringFind(values, ";", start);    
      len = last-start;
           
      if( len > 0 )
      {
         countQuotes = 0;
         quoteIndex = 0;         
         
         while( true )
         {
            current = StringSubstr( values, start, len+1 );
            current = StringTrimLeft(current);
                        
            countQuotes = String_GetCount(current, "\"");
            
            if( countQuotes == 0 || countQuotes > 1 )
            {         
               tmp_values[values_count] = current;
               values_count++;
               break;
            }
            
            last = StringFind(values, ";", start+len+1);    
            len = last-start;
         }         
      }
      
      start = last+1;
   }
   
   //copy the result array
   ArrayResize(result_values,values_count);
   ArrayCopy(result_values, tmp_values,0,0,values_count);

   return (values_count);
}

//-------------------------------------------------------------------------------------

double SAV_Settings_GetDoubleValueI( int settIndex, int index )
{
   double value;
   value = SAV_SETTINGS_STORAGE_VALUESDBL[settIndex,index];
   //string strValue = SAV_Settings_GetValueI( settIndex, index );
//-------------------------------------------------------------------------------------
   return ( value );
}

int SAV_Settings_GetMappingIndex( string name )
{
   int Index;
   SAV_SETTINGS_NAME_MAPPINGS[SAV_MAPPINGS_Size] = name;
   Index = SAV_MAPPINGS_Size;
   if( SAV_SETTINGS_Trace )
      Print("[SAV_Settings_SetMapping] name=",name,";index=", SAV_MAPPINGS_Size ); 
   
   if( SAV_MAPPINGS_Size > SAV_SETTINGS_PARAMSMAXSIZE )
      Print("[SAV_Settings_GetMappingIndex] !!! Fatal Error Too many Mappings!!!! SAV_MAPPINGS_Size=",SAV_MAPPINGS_Size,";maxSize=",SAV_SETTINGS_PARAMSMAXSIZE);
      
   SAV_MAPPINGS_Size++;
   
   return (Index);
}