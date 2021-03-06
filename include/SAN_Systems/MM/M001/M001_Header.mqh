extern string M001_1_Descr = "Параметри: Фиксирано пропорционален метод с преминаване към Фиксирано Фракционен чрез риска";
extern double M001_FP_BeginBalance = 2000;
// AvailableBalance - Наличен първоначален баланс по сметката коийто имем и може да е различен от BeginBalance който задаваме за да пресметнем таблиците
// Примерно задаваме BeginBalance = 2000, но в сметката разполагаме с AvailableBalance=5000 долара и реално започваме от 6-то ниво на ММ а не от 1-во.
extern string M001_FP_AvailBal_1_Descr = "Начален калитал наличен в сметката ако е различен от BeginBalance който дефинира ММ";
extern string M001_FP_AvailBal_2_Descr = "ако е 0 това означава, че наличния капитал по сметката е равен на BeginBalance";
extern double M001_FP_AvailableBalance = 0;
extern double M001_FP_MaxDD = 500;
extern double M001_FP_Delta = 250; 
extern string M001_2_Descr = "PersentDD ниво на риска при което става превключване --- ";
extern double M001_FF_PersentDD = 10;





