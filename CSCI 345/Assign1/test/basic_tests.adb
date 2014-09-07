with AUnit.Test_Suites; use AUnit.Test_Suites;
with Ropes.Tests;
with Ropes.Tests.String_Impl;
with Ropes.Tests.Concat_Impl;

package body Basic_Tests is
     
	function Suite return Aunit.Test_Suites.Access_Test_Suite is
	    Result : constant Access_Test_Suite := new Test_Suite;
	begin
		Result.Add_Test (Ropes.Tests.External_Suite);
		Result.Add_Test (Ropes.Tests.Internal_Suite);
		Result.Add_Test (Ropes.Tests.String_Impl.External_Suite);
		Result.Add_Test (Ropes.Tests.String_Impl.Internal_Suite);
		Result.Add_Test (Ropes.Tests.Concat_Impl.External_Suite);
		Result.Add_Test (Ropes.Tests.Concat_Impl.Internal_Suite);
	    return Result;
	end Suite;
 
end Basic_Tests;
