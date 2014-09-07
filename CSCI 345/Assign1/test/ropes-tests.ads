with AUnit.Test_Suites;

private with Ada.Unchecked_Deallocation;
private with Tracking_Pools;

package Ropes.Tests is

	Ext_Prefix : constant String := "Null_Rope:";
	Int_Prefix : constant String := "Null_Rope_Int:";
	
	function External_Suite return AUnit.Test_Suites.Access_Test_Suite;

	function Internal_Suite return AUnit.Test_Suites.Access_Test_Suite;
	
private
    --  This private section is for use by the various subpackages of
    --  Ropes.Tests only.

    --  Make a string of the given length for tests.    
	function Make_Test_String (Length : Positive) return String;

    --  Many of the tests required access to Ropes. We maintain a separate
    --  storage pool for allocations and deallocations by the test software.
    --  This keeps these allocations from potentially polluting Rope_Pool.
    Rope_Test_Pool : Tracking_Pools.Tracking_Pool;
    type Test_Rope_Access is access all Rope;
    for Test_Rope_Access'Storage_Pool use Rope_Test_Pool;
    procedure Free is new Ada.Unchecked_Deallocation (Rope, Test_Rope_Access);
    
    --  We also maintain a separate string type for strings allocated for
    --  testing purposes.
    type Test_String_Access is access String;
    for Test_String_Access'Storage_Pool use Rope_Test_Pool;
    procedure Free is new Ada.Unchecked_Deallocation (String, Test_String_Access);
    
end Ropes.Tests;
