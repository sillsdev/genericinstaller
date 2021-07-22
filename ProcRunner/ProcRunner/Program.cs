using System;
using System.Diagnostics;
using System.IO;
using Microsoft.Win32;

namespace ProcRunner
{
	static class Program
	{
		public static string updatePath;
		public static string callingApplication;

		public const string ParatextKey = "PT9";
		public const string PublishingAssistantKey = "PA6";

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main(string[] args)
		{
			if (args.Length > 0)
				updatePath = args[0];
			else
				Environment.Exit(0);

			if (args.Length > 1)
				callingApplication = args[1];
			else
				callingApplication = ParatextKey;

			string argsParam = "/p";

			if (updatePath.EndsWith(".exe"))
			{
				argsParam = "/e";
			}

			if (updatePath.EndsWith(".msi"))
			{
				argsParam = "/i";
			}

			if (updatePath.StartsWith("repair_", StringComparison.OrdinalIgnoreCase))
			{
				updatePath = "{" + updatePath.Substring(7) + "}";
				argsParam = "/f";
			}

			RunUpdate(updatePath, argsParam);

			if (callingApplication.Equals(ParatextKey))
				RunParatext();

			if (callingApplication.Equals(PublishingAssistantKey))
				RunPA6();

			Environment.Exit(0);
		}

		private static void RunUpdate(string localFile, string args)
		{
			if (args.Equals("/e"))
			{
				Process eproc = new Process();
				ProcessStartInfo einfo = eproc.StartInfo;
				einfo.FileName = localFile;
				einfo.WorkingDirectory = GetAppFolder();
				einfo.UseShellExecute = true;

				eproc.Start();
				eproc.WaitForExit();
				return;
			}

			string options = "";
			string verb = null;
			bool waitForExit = true;
			if (args.Equals("/i"))
			{
				options = " AUTOUPDATE=\"True\"";
			}
			else if (args.Equals("/p"))
			{
				string logfile = Path.Combine(Environment.GetFolderPath(
					Environment.SpecialFolder.LocalApplicationData), "Temp", "PtPatch.log");
				options = " /qb AUTOUPDATE=\"True\" /l*vx " + "\"" + logfile + "\"";
			}
			else if (args.Equals("/f"))
			{
				string logfile = Path.Combine(Environment.GetFolderPath(
					Environment.SpecialFolder.LocalApplicationData), "Temp", "PtRepair.log");
				options = " /qb AUTOUPDATE=\"True\" /l*vx " + "\"" + logfile + "\"";
				verb = "runas";
				// when doing repair, ProcRunner needs to exit immediately so user doesn't get a prompt to close ProcRunner
				// or to restart their computer when repair is complete.
				waitForExit = false;
			}

			Process proc = new Process();
			ProcessStartInfo info = proc.StartInfo;
			info.FileName = "msiexec.exe";
			info.WorkingDirectory = GetAppFolder();
			info.UseShellExecute = true;
			info.Arguments = args + " " + "\"" + localFile + "\"" + options;
			if (verb != null)
				info.Verb = verb;

			proc.Start();
			if (waitForExit)
				proc.WaitForExit();
		}

		public static string GetAppFolder()
		{
			if (callingApplication.Equals(ParatextKey))
				return GetPT9Folder();
			if (callingApplication.Equals(PublishingAssistantKey))
				return GetPA6Folder();
			return null;
		}

		public static string GetPT9Folder()
		{
			string path = null;
			/*** Don't look for folder in registry, just return null to look in current folder
			RegistryKey key = Registry.LocalMachine.OpenSubKey("SOFTWARE\\Paratext\\8\\");
			if (key != null)
			{
				path = (string)key.GetValue("Program_Files_Directory_Ptw9");
				return path;
			}
			key = Registry.LocalMachine.OpenSubKey("SOFTWARE\\Wow6432Node\\Paratext\\8\\");
			if (key != null)
			{
				path = (string)key.GetValue("Program_Files_Directory_Ptw9");
			}
			***/
			return path;
		}

		public static string GetPA6Folder()
		{
			string path = null;
			RegistryKey key = Registry.LocalMachine.OpenSubKey("SOFTWARE\\PublishingAssistant\\6\\");
			if (key != null)
			{
				path = (string)key.GetValue("Program_Files_Directory_PA6");
				return path;
			}
			key = Registry.LocalMachine.OpenSubKey("SOFTWARE\\Wow6432Node\\PublishingAssistant\\6\\");
			if (key != null)
			{
				path = (string)key.GetValue("Program_Files_Directory_PA6");
			}
			return path;
		}

		public static void RunParatext()
		{
			Process proc = new Process();
			ProcessStartInfo info = proc.StartInfo;
			info.FileName = "Paratext.exe";
			info.WorkingDirectory = GetPT9Folder();
			info.UseShellExecute = true;

			proc.Start();
		}

		public static void RunPA6()
		{
			Process proc = new Process();
			ProcessStartInfo info = proc.StartInfo;
			info.FileName = "PublishingAssistant.exe";
			info.WorkingDirectory = GetPA6Folder();
			info.UseShellExecute = true;

			proc.Start();
		}
	}
}
