using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Diagnostics;
using System.Threading;

namespace SVM_Job_Start
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

      
        private void timer1_Tick(object sender, EventArgs e)
        {
            timer1.Enabled =false;

                string[] files = Directory.GetFiles(@"S:\Research\SVM_Results\Start_Job");
                for (int i = 0; i < files.Length; i++)
                {
                    string file = Path.GetFileName(files[i]);
                    try
                    {

                        try
                        {
                            File.Copy(files[i], @"c:\data\" + file);
                        }
                        catch { }

                        Process ScriptRunner = new Process();
                        ScriptRunner.StartInfo.WindowStyle = ProcessWindowStyle.Normal;
                        ScriptRunner.StartInfo.WorkingDirectory = "C:\\Development\\SVM_Signal Classification\\svmsignalanalysis";
                        ScriptRunner.StartInfo.FileName = @"matlab.exe";
                        ScriptRunner.StartInfo.Arguments = "-logfile -nosplash -nodesktop -r \"killFlowThrough=true;killFile='" +  files[i]  + "';batchExcel='" + @"c:\data\" + file
                            + "';doAnalysis=true;run('C:\\Development\\SVM_Signal Classification\\svmsignalanalysis\\Master.m');exit;\"";
                        ScriptRunner.Start();

                        ScriptRunner.WaitForExit();
                        while (File.Exists(files[i]))
                        {
                            Application.DoEvents();
                            Thread.Sleep(1000);
                        }
                    }
                    catch { }
                }
            timer1.Enabled=true;
        }
    }
}
