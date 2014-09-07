with AUnit.Test_Caller;
with AUnit.Test_Fixtures;
with AUnit.Simple_Test_Cases; use AUnit.Simple_Test_Cases;
with AUnit.Assertions; use AUnit.Assertions;

with Ropes.Tests.Memory_Check;

package body Ropes.Tests is

	use AUnit;
	
	function Make_Test_String (Length : Positive) return String is
		Base_String : constant String := "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		Result : String (1 .. Length);
		L : Natural := 0;
	begin
		while L < Length loop
			if Length <= Base_String'Length + L then
				Result (L + 1 .. Length) := Base_String (1 .. Length - L);
				L := Length;
			else
				Result (L + 1 .. L + Base_String'Length) := Base_String;
				L := L + Base_String'Length;
			end if;
		end loop;
		return Result;
	end Make_Test_String;
	
	package Null_Rope_Tests is

		---------------------------------------------------------------
		--  External Tests (Black Box)
		---------------------------------------------------------------
	
		--  Fixture for External Tests using Null_Rope
		type Null_Rope_Test is new Test_Fixtures.Test_Fixture with record
			Test_Null_Rope : Test_Rope_Access;
		end record;
	
		overriding
		procedure Set_Up (T : in out Null_Rope_Test);
	
		overriding
		procedure Tear_Down (T : in out Null_Rope_Test);
	
		procedure Test_Length (T : in out Null_Rope_Test);
		procedure Test_To_String (T : in out Null_Rope_Test);
		
		---------------------------------------------------------------
		--  Internal Tests (White Box)
		---------------------------------------------------------------
	
        procedure Test_To_Rope (T : in out Null_Rope_Test);

		--  Test that an uninitialized Rope is properly initialized
		--  to the null Rope;
		type Uninitialized_Is_Null is new Simple_Test_Cases.Test_Case
			with null record;
		
		overriding
		procedure Run_Test (T : in out Uninitialized_Is_Null);
		
		overriding
		function Name (T : Uninitialized_Is_Null) return Test_String;
		
	end Null_Rope_Tests;
	
	package body Null_Rope_Tests is

		overriding
		procedure Set_Up (T : in out Null_Rope_Test) is
		begin
			T.Test_Null_Rope := new Rope'(Null_Rope);
		end Set_Up;
		
		overriding
		procedure Tear_Down (T : in out Null_Rope_Test) is
		begin
			Free (T.Test_Null_Rope);
		end Tear_Down;
		
		procedure Test_Length (T : in out Null_Rope_Test) is
		begin
			Assert (T.Test_Null_Rope.Length = 0,
					"Null Rope has non-zero length");
		end Test_Length;
		
		procedure Test_To_String (T : in out Null_Rope_Test) is
		begin
			Assert (T.Test_Null_Rope.To_String'Length = 0,
					"Null Rope has non-empty To_String");
		end Test_To_String;
        
        procedure Test_To_Rope (T : in out Null_Rope_Test) is
		    pragma Warnings (Off, T);
            Empty_Rope : constant Rope := To_Rope ("");
        begin
            Assert (Empty_Rope.B = null, "Allocated Impl for Empty Rope");
        end Test_To_Rope;
		
		overriding
		procedure Run_Test (T : in out Uninitialized_Is_Null) is
		    pragma Warnings (Off, T);
			Un_Initial : Rope;
		begin
			Assert (Un_Initial.B = null, "Uninitialized Rope is not null");
		end Run_Test;
		
		overriding
		function Name (T : Uninitialized_Is_Null) return Test_String is
		    pragma Warnings (Off, T);
		begin
			return Format (Int_Prefix & "Uninitialized_Is_Null");
		end Name;	
		
	end Null_Rope_Tests;
	
	-------------------------------------------------------------------
	--  Build External and Internal Test Suites
	-------------------------------------------------------------------

	use Null_Rope_Tests;
	use Memory_Check;
	
	package Null_Test_Caller
		is new Test_Caller (Null_Rope_Test);
	use Null_Test_Caller; 
		
	procedure M_Test_Length is
	    new Check_Fixture (Null_Rope_Test, Test_Length);
	procedure M_Test_To_String is
	    new Check_Fixture (Null_Rope_Test, Test_To_String);
    procedure M_Test_To_Rope is
        new Check_Fixture (Null_Rope_Test, Test_To_Rope);
	package M_Uninitialized_Is_Null is
	    new Memory_Case (Uninitialized_Is_Null);
		
	function External_Suite return AUnit.Test_Suites.Access_Test_Suite is
	    Result : constant Test_Suites.Access_Test_Suite := new Test_Suites.Test_Suite;
	begin
		Result.Add_Test (Create (Ext_Prefix & "Test_Length",
								 M_Test_Length'Access));
		Result.Add_Test (Create (Ext_Prefix & "Test_To_String",
								 M_Test_To_String'Access));
	    return Result;
	end External_Suite;

	function Internal_Suite return AUnit.Test_Suites.Access_Test_Suite is
	    Result : constant Test_Suites.Access_Test_Suite := new Test_Suites.Test_Suite;
	    Test : constant Simple_Test_Cases.Test_Case_Access :=
	            new M_Uninitialized_Is_Null.Memory_Case;
	begin
        Result.Add_Test (Create (Int_Prefix & "Test_To_Rope",
                                 M_Test_To_Rope'Access));
		Result.Add_Test (Test);
	    return Result;
	end Internal_Suite;
	
end Ropes.Tests;
