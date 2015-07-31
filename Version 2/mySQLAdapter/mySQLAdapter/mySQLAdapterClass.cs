using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.Odbc;

namespace mySQLAdapter
{
    public class mySQLAdapterClass
    {
        public static  double[,] GetData_mySQL(string MyConString, string sql, int identityColumn, string[] analyteName, int[] analyteIndex)
        {
            //string MyConString = "DSN=recognition;" +
            //          "UID=root;" +
            //          "PASSWORD=Shawntel75;";

            OdbcConnection conn = new OdbcConnection(MyConString);
            conn.Open();

            identityColumn=identityColumn-1;

            //  string sql = "SELECT * FROM Peaks ;";
            Dictionary<string, int> analyteMappings = new Dictionary<string, int>();
            for (int i = 0; i < analyteName.Length; i++)
                analyteMappings.Add(analyteName[i].ToLower(), analyteIndex[i]);

            OdbcCommand comm = new OdbcCommand(sql, conn);
            OdbcDataReader dr = comm.ExecuteReader();
            double[,] table = new double[dr.RecordsAffected, dr.FieldCount];
            object[] fields = new object[dr.FieldCount];
            int cc = 0;
            System.Diagnostics.Stopwatch sw = new System.Diagnostics.Stopwatch();
            sw.Start();
            while (dr.Read())
            {
                dr.GetValues(fields);
                for (int i = 0; i < fields.Length; i++)
                {
                    if (i == identityColumn)
                    {

                        try
                        {
                            table[cc, i] = (double)analyteMappings[((string)fields[i]).ToLower()];
                        }
                        catch (Exception ex)
                        {
                            table[cc, i] = -1;
                            //throw new Exception(((string)fields[i]).ToLower() + " not found");
                        }
                            
                        
                    }
                    else
                    {
                        var t = fields[i].GetType();
                        if (t == typeof(double))
                            table[cc, i] = (double)fields[i];
                        else if (t == typeof(int))
                            table[cc, i] = (double)(int)fields[i];
                        else if (t == typeof(Int64))
                            table[cc, i] = (double)(Int64)fields[i];
                        else if (t == typeof(float))
                            table[cc, i] = (double)(float)fields[i];
                    }

                }
                //for (int i = 1; i < 5; i++)
                //    table[cc, i] = (double)(int)fields[i];
                //for (int i = 5; i < 7; i++)
                //    table[cc, i] = (double)(Int64)fields[i];
                //for (int i = 7; i < fields.Length; i++)
                //    table[cc, i] = (double)fields[i];
                cc = cc + 1;
                // Application.DoEvents();
            }
            System.Diagnostics.Debug.Print(sw.ElapsedMilliseconds.ToString());
            conn.Close();
            dr.Close();
            comm.Dispose();
            conn.Dispose();
            return table;
        }

        private static string[,] strings;

        public static string[,] GetStringData()
        {
          
            return strings;
        }

        public static string[,] ClearStringData()
        {
            return strings;
        }

        public static double[,] GetData_mySQL(string MyConString, string sql)
        {
            OdbcConnection conn = new OdbcConnection(MyConString);
            conn.Open();
        
            OdbcCommand comm = new OdbcCommand(sql, conn);
            OdbcDataReader dr = comm.ExecuteReader();
            double[,] table = new double[dr.RecordsAffected, dr.FieldCount];
            strings =new string[dr.RecordsAffected, dr.FieldCount];
            object[] fields = new object[dr.FieldCount];
            int cc = 0;
            System.Diagnostics.Stopwatch sw = new System.Diagnostics.Stopwatch();
            sw.Start();
            while (dr.Read())
            {
                dr.GetValues(fields);
                for (int i = 0; i < fields.Length; i++)
                {
                        var t = fields[i].GetType();
                        if (t == typeof(double))
                            table[cc, i] = (double)fields[i];
                        else if (t == typeof(int))
                            table[cc, i] = (double)(int)fields[i];
                        else if (t == typeof(Int64))
                            table[cc, i] = (double)(Int64)fields[i];
                        else if (t == typeof(float))
                            table[cc, i] = (double)(float)fields[i];
                        else
                            strings[cc, i] = fields[i].ToString();
                }
                cc = cc + 1;
            }
            System.Diagnostics.Debug.Print(sw.ElapsedMilliseconds.ToString());
            conn.Close();
            dr.Close();
            comm.Dispose();
            conn.Dispose();
            return table;
        }

        public static object[,] GetAllData_mySQL(string MyConString, string sql)
        {
            OdbcConnection conn = new OdbcConnection(MyConString);
            conn.Open();

            OdbcCommand comm = new OdbcCommand(sql, conn);
            OdbcDataReader dr = comm.ExecuteReader();
            object[,] table = new object[dr.RecordsAffected+1, dr.FieldCount];
           
            object[] fields = new object[dr.FieldCount];
            int cc = 1;
            System.Diagnostics.Stopwatch sw = new System.Diagnostics.Stopwatch();
            sw.Start();
            while (dr.Read())
            {
                dr.GetValues(fields);
                for (int i = 0; i < fields.Length; i++)
                {
                    table[0, i] = dr.GetName(i);
                    var t = fields[i].GetType();
                    if (t == typeof(double))
                        table[cc, i] = (double)fields[i];
                    else if (t == typeof(int))
                        table[cc, i] = (double)(int)fields[i];
                    else if (t == typeof(Int64))
                        table[cc, i] = (double)(Int64)fields[i];
                    else if (t == typeof(float))
                        table[cc, i] = (double)(float)fields[i];
                    else
                        table[cc, i] = fields[i].ToString();
                }
                cc = cc + 1;
            }
            System.Diagnostics.Debug.Print(sw.ElapsedMilliseconds.ToString());
            conn.Close();
            dr.Close();
            comm.Dispose();
            conn.Dispose();
            return table;
        }


        public static void SaveResultsTable(string MyConString, string sql, string Filename)
        {
            OdbcConnection conn = new OdbcConnection(MyConString);
            conn.Open();
            OdbcCommand comm = new OdbcCommand(sql, conn);
            OdbcDataReader dr = comm.ExecuteReader();
           
            using (System.IO.StreamWriter file = new System.IO.StreamWriter(Filename, false ))
            {
                System.Diagnostics.Stopwatch sw = new System.Diagnostics.Stopwatch();
                object[] fields = new object[dr.FieldCount];
                sw.Start();
                while (dr.Read())
                {
                    dr.GetValues(fields);
                    for (int i = 0; i < fields.Length; i++)
                    {
                        file.Write(fields.ToString() + ",");
                    }
                    file.WriteLine("0");
                }
            }
            conn.Close();
            dr.Close();
            comm.Dispose();
            conn.Dispose();
        }
    }
}
