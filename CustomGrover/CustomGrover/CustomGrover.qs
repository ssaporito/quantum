namespace Quantum.CustomGrover
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

	// Oracle which determines whether 'mainRegister' corresponds to the int value in 'markedElement' 
	// Simulates a simple database 
    operation DatabaseOracleFromInt(markedElement : Int, flag: Qubit, mainRegister: Qubit[]) : ()
    {
        body {
			// Creates unitary operation which sets flag to 1 if mainRegister_{2}=markedElement_{10}
			(ControlledOnInt(markedElement, ApplyToEachCA(X, _)))(mainRegister, [flag]);

        }	
        adjoint auto
        controlled auto
        adjoint controlled auto
    }
	
	// Oracle implementing a circuit for Grover's Algorithm
    operation GroverOracleImpl(markedElement : Int,flagIndex: Int,register: Qubit[]) : ()
    {
        body {                        
			let mainRegister=Exclude([flagIndex],register);			
			let flag=register[flagIndex];			
			
			// Superposes every qubit in main register
			for (i in 0..Length(mainRegister)-1){
				H(mainRegister[i]);
			}

			// Executes main oracle
            DatabaseOracleFromInt(markedElement, flag, mainRegister);

        }

        adjoint auto
        controlled auto
        adjoint controlled auto
    }

	// Returns an Oracle based on its implementation function
    function GroverOracle(markedElement : Int) : StateOracle
    {
        return StateOracle(GroverOracleImpl(markedElement,_,_));
    }


	// Applies amplitude amplification on 'register' with 'nIterations' iterations to amplify the indices corresponding to 'markedElement'
	operation Search (register : Qubit[], nIterations : Int, markedElement : Int, flagIndex: Int) : ()
	{
		body
		{			
			// Amplifies amplitude of every x for which f(x)=1, i.e., x_{2}=flagIndex_{10}
			(AmpAmpByOracle(nIterations, GroverOracle(markedElement), flagIndex))(register);
		}
	}

	// Treats input, calls main operation and returns the output
	operation ApplySearch (n : Int, nIterations : Int, markedElement : Int) : (Result[],Int)
    {
        body
        {
		   mutable result=new Result[n+1];
		   mutable foundElement=0;		   
           using (register = Qubit[n+1]) 
		   {				
				Search(register,nIterations,markedElement,n);

				
				for (i in 0..n){
					set result[i]=M(register[i]);
				}								
                ResetAll(register);				
				set foundElement=PositiveIntFromResultArr(result[0..n-1]);				
		   }		
		   
		   return (result,foundElement);
        }
    }
}
