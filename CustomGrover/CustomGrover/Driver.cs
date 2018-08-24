using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using System;
using System.Linq;

namespace Quantum.CustomGrover
{
    class Driver
    {
        static void Main(string[] args)
        {
            using (var sim = new QuantumSimulator())
            {
                var nSuccesses = 0;
                var nRepeats = 100;
                foreach (var rep in Enumerable.Range(0, nRepeats))
                {
                    // Parameter setup
                    var n = 10;
                    var N = Math.Pow(2, n);
                    var nIterations = (int)Math.Ceiling(Math.Sqrt(N)); // O(sqrt(N)) iterations
                    var needle = 2000; // Element to be found

                    // Runs main algorithm and collects results
                    var res = ApplySearch.Run(sim, n, nIterations, needle).Result;
                    var (measured, foundElement) = res;
                    var success = (measured[measured.Length - 1] == Result.One);

                    // Displays results
                    showMeasured(measured.ToArray());
                    if (success)
                    {
                        Console.WriteLine($", success on iteration {rep}, Found:{foundElement}");
                        nSuccesses++;
                    }
                    else
                    {
                        Console.WriteLine(", failed");
                    }
                }

                // Displays success rate
                var successRate = Math.Round((double)nSuccesses / ((double)nRepeats), 6);
                Console.WriteLine();
                Console.WriteLine($"Success rate: {successRate}");
                Console.WriteLine("Press any key to exit\n\n");
                Console.ReadKey();
            }
        }

        // Helper function to show measured register as string
        public static void showMeasured(Result[] measured)
        {
            string s = "";
            for (var i = measured.Length - 2; i >= 0; i--)
            {
                var item = measured[i];
                
                if (item == Result.Zero)
                {
                    s += "0";
                }
                else if (item == Result.One)
                {
                    s += "1";
                }                
            }
            Console.Write($"Measured: {s}");
        }
        
    }
}