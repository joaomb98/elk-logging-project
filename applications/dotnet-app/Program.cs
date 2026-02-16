using System;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;
using System.Threading;

namespace LoggingApp
{
    class Program
    {
        private static string logstashHost = Environment.GetEnvironmentVariable("LOGSTASH_HOST") ?? "logstash";
        private static int logstashPort = int.Parse(Environment.GetEnvironmentVariable("LOGSTASH_PORT") ?? "5000");
        private static string appName = Environment.GetEnvironmentVariable("APP_NAME") ?? "dotnet-app";
        private static string environment = Environment.GetEnvironmentVariable("ENVIRONMENT") ?? "development";
        private static string hostname = Environment.MachineName;

        static void Main(string[] args)
        {
            Console.WriteLine($".NET application started - connecting to Logstash at {logstashHost}:{logstashPort}");
            
            int counter = 0;
            Random random = new Random();

            while (true)
            {
                counter++;
                
                string level = counter % 5 switch
                {
                    0 => "DEBUG",
                    1 => "INFO",
                    2 => "WARNING",
                    3 => "ERROR",
                    4 => "CRITICAL",
                    _ => "INFO"
                };

                string message = level switch
                {
                    "DEBUG" => $"Debug message #{counter}: Application state check",
                    "INFO" => $"Info message #{counter}: Processing request",
                    "WARNING" => $"Warning message #{counter}: Resource usage at 75%",
                    "ERROR" => $"Error message #{counter}: Failed to connect to database",
                    "CRITICAL" => $"Critical message #{counter}: System failure detected!",
                    _ => $"Log message #{counter}"
                };

                SendLog(level, message);
                
                int sleepTime = random.Next(2000, 5000);
                Thread.Sleep(sleepTime);
            }
        }

        static void SendLog(string level, string message)
        {
            try
            {
                var logData = new
                {
                    timestamp = DateTime.UtcNow.ToString("o"),
                    level = level,
                    message = message,
                    app_name = appName,
                    environment = environment,
                    hostname = hostname,
                    logger = "dotnet-logger"
                };

                string jsonLog = JsonSerializer.Serialize(logData);
                
                // Write to console
                Console.WriteLine(jsonLog);

                // Send to Logstash via TCP
                using (TcpClient client = new TcpClient())
                {
                    client.Connect(logstashHost, logstashPort);
                    using (NetworkStream stream = client.GetStream())
                    {
                        byte[] data = Encoding.UTF8.GetBytes(jsonLog + "\n");
                        stream.Write(data, 0, data.Length);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error sending log: {ex.Message}");
            }
        }
    }
}
