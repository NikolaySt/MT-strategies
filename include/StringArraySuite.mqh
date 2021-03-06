//+------------------------------------------------------------------+
//|                                             StringArraySuite.mqh |
//|                                         Copyright © 2006, sx ted |
//|                                                       2006.07.14 |
//| Purpose.: Functions for handling two dimensional string arrays.  |
//|           Usefull for prototyping.                               |
//| ThankYou: Compliments to the programmers and the MetaQuotes team |
//|           for MT4, amazing.                                      |
//| Notes...: See StringArraySuiteSample.mq4 for usage.              |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, sx ted"
#define ERROR -1
//+------------------------------------------------------------------+
//| Function..: StringArrayAdd                                       |
//| Parameters: A      - Name of the string array.                   |
//|             iCount - Number of new rows to be added, defaults to |
//|                      one row if the parameter is omitted.        |
//|             sValue - Value to be set for the cells of the new    |
//|                      row(s), defaults to a string of zero        |
//|                      length (the string "").                     |
//| Purpose...: Append one or more new row(s) to a two dimensional   |
//|             string array, and set the new cells with <sValue>.   |
//| Returns...: Position number of the first row added, or -1 if an  |
//|             error occured and the array is not resized.          |
//| Sample....: string A[2][2]={ "EURUSD","500","GBPUSD","400" };    |
//|             string sKey=Symbol();                                |
//|             int iRows=ArrayRange(A, 0);                          |
//|             int iRow =StringArrayFind(A, sKey, 0) // soft seek   |
//|             if(iRows == 0 || A[iRow][0] < sKey)                  |
//|               iRow=StringArrayAdd(A, 1, sKey);                   |
//|             else if(A[iRow][0] != sKey)                          |
//|               iRow=StringArrayInsert(A, iRow, 1, sKey);          |
//|             if(iRow == -1) return (-1);                          |
//|             A[iRow][1]=DoubleToStr(iVolume(NULL,PERIOD_MN1,0),0);|
//+------------------------------------------------------------------+
int StringArrayAdd(string& A[][], int iCount=1, string sValue="") 
  {
    int iRows = ArrayRange(A, 0);
//----
    if(ArrayResize(A, iRows+iCount) > 0) 
      {
        StringArrayIni(A, sValue, iRows, iCount);
        return(iRows);
      }
    else Print("StringArrayAdd()", Error());
      return(ERROR);
  }
//+------------------------------------------------------------------+
//| Function..: StringArrayDelete                                    |
//| Parameters: A      - Name of the string array.                   |
//|             iRow   - Index position in dimension 1 where the row |
//|                      is to be deleted from the array.            |
//|             iCount - Number of rows to be deleted starting at    |
//|                      position <iRow>, the default is to delete   |
//|                      one row (if the parameter is omitted).      |
//| Purpose...: Delete one or more row(s) in a two dimensional array.|
//| Returns...: Count of cells remaining in the array after deleting |
//|             otherwise returns -1 if an error occured and the     |
//|             array is not resized.                                |
//| Sample....: int iRow=StringArrayFind(A,"2000",1); // exact match |
//|             if(iRow >= 0) StringArrayDelete(A, iRow);            |
//+------------------------------------------------------------------+
int StringArrayDelete(string& A[][], int iRow, int iCount = 1) 
  {
    int iRows = ArrayRange(A, 0); 
    int iRowsToCopy = MathMin(iRows - iCount - iRow, iCount); 
    int iCols, iCol, iDestination, iSource, i;
//----
    if(!(iRows > 0 && iRows > iRow && iRows >= iRow + iCount - 1)) 
        return(ERROR);
    iCols = ArraySize(A) / iRows;
    string sCopy[]; // backup
//----
    for(iSource = iRows - iRowsToCopy, i = 0; iSource < iRows; iSource++, i++) 
      {
        if(ArrayResize(sCopy, (i + 1)*iCols) > 0) 
          {
            for(iCol = 0; iCol < iCols; iCol++) 
              {
                iDestination = i*iCols + iCol;
                sCopy[iDestination] = A[iSource][iCol];
              }
          }
        else 
          { 
            Print("StringArrayDelete()1", Error()); 
            return(ERROR); 
          }
      }
//----
    if(ArrayResize(A, iRows - iCount) >= 0) 
      {
        iRows -= iCount;
        //----
        for(iDestination = iRow; iDestination < iRows-iRowsToCopy; iDestination++) 
          {
            iSource = iDestination + iCount;
            for(iCol = 0; iCol < iCols; iCol++) 
              {
                A[iDestination][iCol] = A[iSource][iCol];
              }
          }
        //----
        for(iDestination = iRows - iRowsToCopy, i = 0; iDestination < iRows; iDestination++, i++) 
          {
            for(iCol = 0; iCol < iCols; iCol++) 
              {
                iSource=i*iCols + iCol;
                A[iDestination][iCol] = sCopy[iSource];
              }
          }
        return (iRows*iCols);
      }
    Print("StringArrayDelete()2", Error());
    return(ERROR);
  }
//+------------------------------------------------------------------+
//| Function..: StringArrayFind                                      |
//| Parameters: A      - The string array in which to search for.    |
//|             sFind  - The string to find.                         |
//|             bExact - Pass value 1 for exact search match,        |
//|                      pass value 0 for soft seek.                 |
//|                      Defaults to TRUE (1) if no value is passed. |
//|             iStart - Starting index to search for. Default value |
//|                      is 0 for search to start on first row.      |
//|             iCount - Count of elements to search for.            |
//|                      By default searches the whole array.        |
//|             iDir   - Search direction. It can be either of the   |
//|                      following values:                           |
//|                      MODE_ASCEND  (1) search array sorted A to Z,|
//|                      MODE_DESCEND (2) search array sorted Z to A.|
//|                      The default is to search for a value in an  |
//|                      array whose first dimension is sorted in    |
//|                      ascending mode.                             |
//| Purpose...: Find a value in a sorted two dimension string array. |
//| Returns...: If bExact is passed as 0 (false) returns the index   |
//|             of the first occurrence of a value in the first      |
//|             dimension of array if possible, or the nearest one   |
//|             if the occurrence is not found.                      |
//|             If bExact is passed as 1 (true) StringArrayFind will |
//|             return -1 if the value is not found, otherwise the   |
//|             index position.                                      |
//| Notes.....: Ensure that if numbers are to be searched for in the |
//|             first dimension that they are all of the same length |
//|             by pre-pending with "*" or other character with lower|
//|             ASCII code value, same applies to the search string. |
//| Sample....: string A[2][2]={ "EURUSD","500","GBPUSD","400" };    |
//|             string sKey=Symbol();                                |
//|             int iRows=ArrayRange(A, 0);                          |
//|             int iRow =StringArrayFind(A, sKey, 0) // soft seek   |
//|             if(iRows == 0 || A[iRow][0] < sKey)                  |
//|               iRow=StringArrayAdd(A, 1, sKey);                   |
//|             else if(A[iRow][0] != sKey)                          |
//|               iRow=StringArrayInsert(A, iRow, 1, sKey);          |
//|             if(iRow == -1) return (-1);                          |
//|             A[iRow][1]=DoubleToStr(iVolume(NULL,PERIOD_MN1,0),0);|
//+------------------------------------------------------------------+
int StringArrayFind(string A[][], string sFind, bool bExact = TRUE, int iStart = 0, 
                    int iCount = WHOLE_ARRAY, int iDir = MODE_ASCEND) 
  {
    int iMiddle;
//----
    if(iCount == WHOLE_ARRAY) 
        iCount = ArrayRange(A, 0)-1; 
    else 
        iCount = (iStart + iCount) -1 ;
//----
    if(iDir == MODE_ASCEND) 
      {
        while(iCount - iStart > 1) 
          {
            iMiddle = (iStart+iCount) / 2;
            //----
            if(A[iMiddle][0] == sFind) 
                return(iMiddle);
            //----
            if(sFind > A[iMiddle][0]) 
                iStart = iMiddle; 
            else 
                iCount=iMiddle;
          }
      }
    else 
      {
        while(iCount - iStart > 1) 
          {
            iMiddle = (iStart + iCount) / 2;
            //----
            if(A[iMiddle][0] == sFind) 
                return(iMiddle);
            //----
            if(sFind < A[iMiddle][0]) 
                iStart=iMiddle; 
            else 
                iCount=iMiddle;
          }
      }
//----
    if(A[iStart][0] == sFind || (!bExact && sFind < A[iStart][0])) 
        return(iStart); 
    else 
        if(A[iCount][0] == sFind || !bExact) 
            return(iCount);
    return(-1);
  }
//+------------------------------------------------------------------+
//| Function..: StringArrayIni                                       |
//| Parameters: A      - Name of the string array.                   |
//|             sValue - New value to be set, defaults to a string   |
//|                      of zero length (the string "").             |
//|             iStart - Index position in dimension 1 start row for |
//|                      which the cells are  to be initialized, the |
//|                      default value is row zero if the parameter  |
//|                      is omitted.                                 |
//|             iCount - Count of rows to be initialized, defaults   |
//|                      to the whole array if the parameter is not  |
//|                      passed.                                     |
//| Purpose...: Set all cells of one or more row(s) of a two         |
//|             dimensional string array to the same value.          |
//| Returns...: Number of cells initialized.                         |
//| Sample....: StringArrayIni(A, "0");                              |
//+------------------------------------------------------------------+
int StringArrayIni(string& A[][], string sValue = "", int iStart = 0, int iCount = WHOLE_ARRAY) 
  {
    int iCells = 0;
//----
    if(iCount == WHOLE_ARRAY) 
        iCount=ArrayRange(A, 0); 
    else 
        iCount = (iStart + iCount) - 1;
//----
    for(int iRow = iStart; iRow <= iCount; iRow++) 
      {
        iCells += StringArrayIniRow(A, sValue, iRow);
      }
    return(iCells);
  }
//+------------------------------------------------------------------+
//| Function..: StringArrayIniRow                                    |
//| Parameters: A      - Name of the string array.                   |
//|             sValue - New value to be set.                        |
//|             iRow   - Index position in dimension 1 where the row |
//|                      whose cells are to be initialized.          |
//| Purpose...: Initialize the cells of a row with new value.        |
//| Returns...: Number of cells initialized.                         |
//| Sample....: StringArrayIniRow(A, "0", iRow);                     |
//+------------------------------------------------------------------+
int StringArrayIniRow(string& A[][], string sValue, int iRow) 
  {
    int iCols = ArrayRange(A, 0);
    if(iCols > 0) 
      {
        iCols = ArraySize(A) / iCols;
        for(int iCol = 0; iCol < iCols; iCol++) 
          {
            A[iRow][iCol] = sValue;
          }
      }
    return (iCols);
  }
//+------------------------------------------------------------------+
//| Function..: StringArrayInsert                                    |
//| Parameters: A      - Name of the string array.                   |
//|             iRow   - Index position in dimension 1 where the new |
//|                      row is to be inserted in the array.         |
//|             iCount - Number of new rows to be inserted starting  |
//|                      at position <iRow>, the default is to insert|
//|                      one row (if the parameter is omitted).      |
//|             sValue - Value to be set for the cells of the new    |
//|                      row(s), defaults to a string of zero length |
//|                      (the string "").                            |
//| Purpose...: Insert one or more new row(s) in a two dimensional   |
//|             array, and initialize the new cells with a value.    |
//| Returns...: Position number of the first row inserted, or        |
//|             -1 if an attempt is made to insert after last row or |
//|             if an error occured and the array is not resized.    |
//| Sample....: string A[2][2]={ "EURUSD","500","GBPUSD","400" };    |
//|             string sKey=Symbol();                                |
//|             int iRows=ArrayRange(A, 0);                          |
//|             int iRow =StringArrayFind(A, sKey, 0) // soft seek   |
//|             if(iRows == 0 || A[iRow][0] < sKey)                  |
//|               iRow=StringArrayAdd(A, 1, sKey);                   |
//|             else if(A[iRow][0] != sKey)                          |
//|               iRow=StringArrayInsert(A, iRow, 1, sKey);          |
//|             if(iRow == -1) return (-1);                          |
//|             A[iRow][1]=DoubleToStr(iVolume(NULL,PERIOD_MN1,0),0);|
//+------------------------------------------------------------------+
int StringArrayInsert(string& A[][], int iRow, int iCount = 1, string sValue = "") 
  {
    int iRows = ArrayRange(A, 0), iCells, iCols, iDestination;
//----
    if(iRows == 0) 
        return(StringArrayAdd(A, iCount, sValue));
//----
    if(iRows <= iRow) 
        return(ERROR);
    iCells = ArrayResize(A, iRows + iCount);
//----
    if(iCells > 0) 
      {
        iCols = iCells / (iRows + iCount);
        for(int iSource = iRows; iSource >= iRow; iSource--) 
          {
            iDestination = iSource + iCount;
            for(int iCol = 0; iCol < iCols; iCol++) 
              {
                A[iDestination][iCol] = A[iSource][iCol];
              }
          }
        StringArrayIni(A, sValue, iRow, iCount);
        return(iRow);
      }
    else
        Print("StringArrayInsert()", Error());
    return(ERROR);
  }
//+------------------------------------------------------------------+
//| Function..: StringArrayLoad                                      |
//| Based on..: BenchStringArraySort.mq4 by http://www.MetaQuotes.net|
//|             and modified to handle two dimensional arrays.       |
//| Parameters: sFile    - File name, file may be with any extension,|
//|             A        - Array where data will be stored,          |
//|             iColumns - Number of columns in the second dimension.|
//| Purpose...: Read all text elements from a CSV file into a two    |
//|             dimensional array.                                   |
//| Returns...: iLinesRead - Returns actual read lines count (size   |
//|             of the first dimension of the array).                |
//|             Returns -1 if an error occured.                      |
//| Notes.....: The array is resized dynamically. Cells with NULL    |
//|             values are rejected and reported in Experts log.     |
//| Sample....: string A[2][2]={"GBPUSD","500","EURUSD","600"};      |
//|             StringArraySort(A);                                  |
//|             StringArrayWrite(A);                                 |
//|                                                                  |
//|             string B[][2];                                       |
//|             int iRows=StringArrayLoad("My.CSV", B, 2); //import A|
//|             int iRow =StringArrayAdd(B, 1, Symbol());            |
//|             B[iRow][1]=DoubleToStr(iVolume(NULL,PERIOD_MN1,0),0);|
//|             StringArrayWrite(B, "B.CSV");                        |
//+------------------------------------------------------------------+
int StringArrayLoad(string sFile, string& A[][], int iColumns) 
  {
    int handle = FileOpen(sFile, FILE_CSV|FILE_READ, ";"), i, iStart, iPos;
//----
    if(handle < 1) 
      {
        Alert("File:", sFile, Error());
        return(ERROR);
      }
    string sLine;
    int iRows = ArrayRange(A,0), iLinesRead = 0;
//----
    while(FileIsEnding(handle) == false) 
      {
        sLine = FileReadString(handle);
        iStart = StringLen(sLine);
        //----
        if(iStart < 1) 
            continue; // empty strings dropped
        //----
        if(iLinesRead >= iRows) 
          {
            if(ArrayResize(A,iRows+1) == 0 ) 
              {
                Alert("StringArrayLoad()", Error());
                return(ERROR);
              }
            iRows += 1;
          }
        //----
        if(StringFind(sLine, ",,", 0) >= 0 || StringSubstr(sLine, iStart - 1, 1) == ",") 
          {
            Alert("File:", sFile, " Line:", iLinesRead, " NULL value");
            break;
          }
        sLine = sLine + ",";
        iStart = 0;
        //----
        for(i = 0; i < iColumns; i++) 
          {
            iPos = StringFind(sLine, ",", iStart);
            A[iLinesRead][i] = StringSubstr(sLine, iStart, iPos - iStart);
            iStart = iPos + 1;
          }
        iLinesRead++;
      }
    FileClose(handle);
    return (iLinesRead);
  }
//+------------------------------------------------------------------+
//| Function..: StringArraySort                                      |
//| Based on..: BenchStringArraySort.mq4 by http://www.MetaQuotes.net|
//|             and modified to handle two dimensional arrays and    |
//|             descend mode.                                        |
//| Parameters: A      - Name of the string array.                   |
//|             iStart - Start row, the default value is row zero if |
//|                      the parameter is omitted.                   |
//|             iCount - Count of rows to be sorted, defaults to the |
//|                      whole array if the parameter is not passed  |
//|                      or passed as 0 (zero).                      |
//|             iDir   - Array sorting direction. It can be either   |
//|                      of the following values:                    |
//|                      MODE_ASCEND  (1) - sort ascending  A to Z,  |
//|                      MODE_DESCEND (2) - sort descending Z to A.  |
//| Purpose...: Sort the two dimensional array by the first column.  |
//| Returns...: The sorted string array passed by reference.         |
//| Sample....: string A[2][2]={"GBPUSD","500","EURUSD","600"};      |
//|             StringArraySort(A);                                  |
//|             StringArrayWrite(A);                                 |
//+------------------------------------------------------------------+
void StringArraySort(string& A[][], int iStart = 0, int iCount = WHOLE_ARRAY, 
                     int iDir = MODE_ASCEND) 
  {
    int iRows = ArrayRange(A, 0);
//----
    if(iCount == WHOLE_ARRAY) 
        iCount = iRows; 
    else 
        iCount = (iStart + iCount) - 1;
//----
    if(iRows == 0 || iCount-iStart <=  0) 
        return (0);
    int iCols = ArraySize(A) / iRows;
    string pivot[];
//----
    if(ArrayResize(pivot, iCols) == 0) 
      {
        Print("StringArraySort()", Error());
        return (ERROR);
      }
//----
    if(iDir == MODE_ASCEND) 
        StringArraySortAZ(A, iStart, iCount, iCols, pivot);
    else                    
        StringArraySortZA(A, iStart, iCount, iCols, pivot);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StringArraySortAZ(string& A[][], int low, int high, int iCols, string& pivot[]) 
  {
    int scan_forward, scan_back;
    int middle, i;
//----
    if(high - low <= 0) 
        return(0);
//----
    if(high - low == 1) 
      {
        if(A[high][0] < A[low][0]) 
            StringArraySwapRows(A, low, high, iCols);
        return (0);
      }
    middle = (low + high) / 2;
//----
    for(i = 0; i < iCols; i++) 
        pivot[i] = A[middle][i];
    StringArraySwapRows(A, middle, low, iCols);
    scan_forward = low + 1;
    scan_back = high;
//----
    while(scan_forward < scan_back) 
      {
        while(scan_forward <= scan_back && A[scan_forward][0] <= pivot[0]) 
            scan_forward++;
        //----
        while(A[scan_back][0] > pivot[0]) 
            scan_back--;
        //----
        if(scan_forward < scan_back) 
            StringArraySwapRows(A, scan_forward, scan_back, iCols);
      }
//----
    for(i = 0; i < iCols; i++) 
      {
        A[low][i] = A[scan_back][i];
        A[scan_back][i] = pivot[i];
      }
//----
    if(low < scan_back - 1)  
        StringArraySortAZ(A, low, scan_back-1, iCols, pivot);
//----
    if(scan_back + 1 < high) 
        StringArraySortAZ(A, scan_back + 1, high, iCols, pivot);
    return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StringArraySortZA(string& A[][], int low, int high, int iCols, string& pivot[]) 
  {
    int scan_forward, scan_back;
    int middle, i;
//----
    if(high - low <= 0) 
        return(0);
//----
    if(high - low == 1) 
      {
        if(A[high][0] > A[low][0]) 
            StringArraySwapRows(A, low, high, iCols);
        return (0);
      }
    middle = (low + high) / 2;
//----
    for(i = 0; i < iCols; i++) 
        pivot[i] = A[middle][i];
    StringArraySwapRows(A, middle, low, iCols);
    scan_forward = low + 1;
    scan_back = high;
//----
    while(scan_forward < scan_back) 
      {
        while(scan_forward <= scan_back && A[scan_forward][0] >= pivot[0]) 
            scan_forward++;
        //----
        while(A[scan_back][0] < pivot[0]) 
            scan_back--;
        //----
        if(scan_forward < scan_back) 
            StringArraySwapRows(A, scan_forward, scan_back, iCols);
      }
//----
    for(i = 0; i < iCols; i++) 
      {
        A[low][i] = A[scan_back][i];
        A[scan_back][i] = pivot[i];
      }
//----
    if(low < scan_back - 1)  
        StringArraySortZA(A, low, scan_back-1, iCols, pivot);
//----
    if(scan_back + 1 < high) 
        StringArraySortZA(A, scan_back+1, high, iCols, pivot);
    return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StringArraySwapRows(string& A[][], int iRow1, int iRow2, int iCols) 
  {
    string sTmp = "";
    for(int i = 0; i < iCols; i++) 
      {
        sTmp = A[iRow1][i];
        A[iRow1][i] = A[iRow2][i];
        A[iRow2][i] = sTmp;
      }
  } 
//+------------------------------------------------------------------+
//| Function..: StringArrayWrite                                     |
//| Parameters: A      - Name of the string array.                   |
//|             sFile  - Output file name, defaults to "My.CSV".     |
//|             bAdd   - If set to 1 (true) appends the data to the  |
//|                      existing file <sFile>, otherwise if set to  |
//|                      the default 0 (false) the previous contents |
//|                      are over written with the new data.         |
//|             iStart - First row to be written to the file, the    |
//|                      default is row 0.                           |
//|             iCount - Number of rows to be written to the file,   |
//|                      the  default is all rows.                   |
//| Purpose...: Write a two dimensional array to a CSV file for      |
//|             viewing with a text editor or further manipulations  |
//|             using a spreadsheet. Usefull for debugging.          |
//| Returns...: Number of rows written, or a negative value if an    |
//|             error occurs.                                        |
//| Sample....: string sProfit[2][2]={"Jan","-150","Feb","200"};     |
//|             StringArrayWrite(sProfit);                           |
//+------------------------------------------------------------------+
int StringArrayWrite(string A[][], string sFile = "My.CSV", bool bAdd = false, 
                     int iStart = 0, int iCount = WHOLE_ARRAY) 
  {
    int iRows = ArrayRange(A, 0), iCols, handle, iRowsWritten, iRow, iCol;
//----
    if(iRows == 0) 
        return (0);
    iCols = ArraySize(A) / iRows;
//----
    if(iCount == WHOLE_ARRAY) 
        iCount = iRows; 
    else 
        iCount = iStart + iCount - 1;
//----
    if(!bAdd) 
        handle = FileOpen(sFile, FILE_CSV|FILE_WRITE, ',');
    else 
        handle = FileOpen(sFile, FILE_CSV|FILE_READ|FILE_WRITE, ',');
//----
    if(handle < 1) 
      {
        Alert("File:", sFile, Error());
        return (ERROR);
      }
//----
    if(bAdd) 
        FileSeek(handle, 0, SEEK_END);
    string sColSeperator = ",";
//----
    for(iRow = iStart; iRow < iCount; iRow++) 
      {
        for(iCol = 0; iCol < iCols-1; iCol++) 
          {
            FileWrite(handle, A[iRow][iCol] + sColSeperator);
            FileSeek(handle, -2, SEEK_END);
          } 
        FileWrite(handle, A[iRow][iCol]);
        iRowsWritten++;
      }
    FileClose(handle);
    return(iRowsWritten);
}
//+------------------------------------------------------------------+
//| Function..: Error                                                |
//| Parameters: None.                                                |
//| Purpose...: Get the last occured error number and description.   |
//| Returns...: Error message.                                       |
//| Sample....: string A[][2];                                       |
//|             if(ArrayRange(A,100)<0) Alert("ArrayRange",Error()); |
//+------------------------------------------------------------------+
#include <stdlib.mqh>
string Error() 
  {
    int i = GetLastError();
    return(StringConcatenate(" Error:", i, " ", ErrorDescription(i)));
  }
//+------------------------------------------------------------------+