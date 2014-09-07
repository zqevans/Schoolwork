with AUnit.Test_Suites;

package Ropes.Tests.String_Impl is

	Ext_Prefix : constant String := "String_Rope : ";
	Int_Prefix : constant String := "String_Rope_Int : ";
	
	function External_Suite return AUnit.Test_Suites.Access_Test_Suite;
	function Internal_Suite return AUnit.Test_Suites.Access_Test_Suite;
			
end Ropes.Tests.String_Impl;
