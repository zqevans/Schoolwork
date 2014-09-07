with AUnit.Test_Fixtures;
with AUnit.Test_Caller;
with AUnit.Assertions; use AUnit.Assertions;

with Ropes.Tests.Memory_Check;
with Ropes.String_Impl;

package body Ropes.Tests.String_Impl is

	use AUnit;

	generic
		Length : Positive;
		Name : String;
	package Length_Fixtures is
	
		type Fixture is new Test_Fixtures.Test_Fixture
		with record
			Test_String : Test_String_Access;
			Test_Rope : Test_Rope_Access;
		end record;

		overriding
		procedure Set_Up (T : in out Fixture);	
	
		overriding
		procedure Tear_Down (T : in out Fixture);

		---------------------------------------------------------------
		--
		--  External Tests (Black Box)
		--
		---------------------------------------------------------------

		procedure Test_Length (T : in out Fixture);
		
		procedure Test_To_String (T : in out Fixture);
        
        procedure Test_Element_Begin (T : in out Fixture);
		
        procedure Test_Element_Middle (T : in out Fixture);

        procedure Test_Element_End (T : in out Fixture);

        procedure Test_Element_Error (T : in out Fixture);

		package Caller is new Test_Caller (Fixture);
		
		procedure Add_Tests (Suite : Test_Suites.Access_Test_Suite);

		procedure Add_Internal_Tests (Suite : Test_Suites.Access_Test_Suite);

	end Length_Fixtures;
	
	package body Length_Fixtures is	
		
		overriding
		procedure Set_Up (T : in out Fixture) is
		begin
			T.Test_String := new String' (Make_Test_String (Length));
		end Set_Up;
	
		overriding
		procedure Tear_Down (T : in out Fixture) is
		begin
			Free (T.Test_String);
            pragma Assert (Rope_Test_Pool.Is_Balanced, "Unbalanced Rope_Test_Pool");
		end Tear_Down;
		
		procedure Test_Length (T : in out Fixture) is
			Message : constant String := "Length " & Name & " rope has wrong length";
			Test_Rope : constant Rope := To_Rope (T.Test_String.all); 
		begin
			Assert (Test_Rope.Length = Length, Message);
		end Test_Length;
	
		procedure Test_To_String (T : in out Fixture) is
			Message : constant String := "Length " & Name & " rope has wrong contents";
			Test_Rope : constant Rope := To_Rope (T.Test_String.all);
		begin
			Assert (Test_Rope.To_String = T.Test_String.all, Message);
		end Test_To_String;
		
        procedure Test_Element_Begin (T : in out Fixture) is
            Message : constant String := "Element(1) " & Name & " is wrong";
            Test_Rope : constant Rope := To_Rope (T.Test_String.all);
        begin
            Assert (Test_Rope.Element (1) = T.Test_String(1), Message);
        end Test_Element_Begin;
		
        procedure Test_Element_Middle (T : in out Fixture) is
            Message : constant String := "Element(middle) " & Name & " is wrong";
            Test_Rope : constant Rope := To_Rope (T.Test_String.all);
            Index : constant Positive := (T.Test_String'Length + 1) / 2;
        begin
            Assert (Test_Rope.Element (Index) = T.Test_String(Index), Message);
        end Test_Element_Middle;

        procedure Test_Element_End (T : in out Fixture) is
            Message : constant String := "Element(end) " & Name & " is wrong";
            Test_Rope : constant Rope := To_Rope (T.Test_String.all);
            Index : constant Positive := T.Test_String'Length;
        begin
            Assert (Test_Rope.Element (Index) = T.Test_String(Index), Message);
        end Test_Element_End;

        procedure Test_Element_Error (T : in out Fixture) is
            Message : constant String := "Element(end + 1) " & Name & " did not raise Constraint_Error";
            Test_Rope : constant Rope := To_Rope (T.Test_String.all);
            Index : constant Positive := T.Test_String'Length + 1;
            C : Character;
            pragma Warnings(Off, C);
        begin
            C := Test_Rope.Element (Index);
            Assert (False, Message);
        exception
            when Constraint_Error => null;
        end Test_Element_Error;

        procedure Test_Slice_Null_10 (T : in out Fixture) is
            Prefix : constant String := "Test_Slice_Null (1, 0) " & Name;
            Test_Rope : constant Rope := To_Rope (T.Test_String.all);
            Low : constant Positive := 1;
            High : constant Natural := 0;
        begin
            Assert (Test_Rope.Slice (Low, High).Length = 0, Prefix & " does not have zero length");
            Assert (Test_Rope.Slice (Low, High).To_String = "", Prefix & " is not null string");
            Assert (Test_Rope.Length = Length, Prefix & " Test_Rope changed");
        end Test_Slice_Null_10;

        procedure Test_Slice_Null_end (T : in out Fixture) is
            Prefix : constant String := "Test_Slice_Null (Length + 1, Length) " & Name;
            Test_Rope : constant Rope := To_Rope (T.Test_String.all);
            Low : constant Positive := T.Test_String'Length + 1;
            High : constant Natural := T.Test_String'Length;
        begin
            Assert (Test_Rope.Slice (Low, High).Length = 0, Prefix & " does not have zero length");
            Assert (Test_Rope.Slice (Low, High).To_String = "", Prefix & " is not null string");
            Assert (Test_Rope.Length = Length, Prefix & " Test_Rope changed");
        end Test_Slice_Null_End;
        
        procedure Test_Slice_All (T : in out Fixture) is
            Prefix : constant String := "Test_Slice_All " & Name;
            Test_Rope : constant Rope := To_Rope (T.Test_String.all);
            Low : constant Positive := 1;
            High : constant Natural := T.Test_String'Length;
        begin
            Assert (Test_Rope.Slice (Low, High).Length = High - Low + 1, Prefix & " incorrect length");
            Assert (Test_Rope.Slice (Low, High).To_String = T.Test_String (Low .. High),
                    Prefix & " incorrect value");
            Assert (Test_Rope.Length = Length, Prefix & " Test_Rope changed");
        end Test_Slice_All;
        
        procedure Test_Slice_All_Internal (T : in out Fixture) is
            Prefix : constant String := "Test_Slice_All " & Name;
            Test_Rope : constant Rope := To_Rope (T.Test_String.all);
            Sliced : Rope;
            Low : constant Positive := 1;
            High : constant Natural := T.Test_String'Length;
        begin
            Sliced := Test_Rope.Slice (Low, High);
            Assert (Test_Rope.B = Sliced.B, Prefix & " did not reuse rope");
        end Test_Slice_All_Internal;
                    
        procedure Test_Slice_Begin (T : in out Fixture) is
            Prefix : constant String := "Test_Slice_Begin " & Name;
            Test_Rope : constant Rope := To_Rope (T.Test_String.all);
            Low : constant Positive := 1;
            High : constant Natural := (T.Test_String'Length + 1) / 2;
        begin
            Assert (Test_Rope.Slice (Low, High).Length = High - Low + 1, Prefix & " incorrect length");
            Assert (Test_Rope.Slice (Low, High).To_String = T.Test_String (Low .. High),
                    Prefix & " incorrect value");
            Assert (Test_Rope.Length = Length, Prefix & " Test_Rope changed");
        end Test_Slice_Begin;
        
        procedure Test_Slice_End (T : in out Fixture) is
            Prefix : constant String := "Test_Slice_End " & Name;
            Test_Rope : constant Rope := To_Rope (T.Test_String.all);
            Low : constant Positive := (T.Test_String'Length + 2) / 2;
            High : constant Natural := T.Test_String'Length;
        begin
            Assert (Test_Rope.Slice (Low, High).Length = High - Low + 1, Prefix & " incorrect length");
            Assert (Test_Rope.Slice (Low, High).To_String = T.Test_String (Low .. High),
                    Prefix & " incorrect value");
            Assert (Test_Rope.Length = Length, Prefix & " Test_Rope changed");
        end Test_Slice_End;
        
        procedure Test_Slice_Middle (T : in out Fixture) is
            Prefix : constant String := "Test_Slice_Middle (1, Length) " & Name;
            Test_Rope : constant Rope := To_Rope (T.Test_String.all);
            Low : constant Positive := 1 + T.Test_String'Length / 3;
            High : constant Natural := T.Test_String'Length - T.Test_String'Length / 3;
        begin
            Assert (Test_Rope.Slice (Low, High).Length = High - Low + 1, Prefix & " incorrect length");
            Assert (Test_Rope.Slice (Low, High).To_String = T.Test_String (Low .. High),
                    Prefix & " incorrect value");
            Assert (Test_Rope.Length = Length, Prefix & " Test_Rope changed");
        end Test_Slice_Middle;
        
		use Memory_Check;
		
        procedure M_Test_Length is
            new Check_Fixture (Fixture, Test_Length);
        procedure M_Test_To_String is
            new Check_Fixture (Fixture, Test_Length);
        procedure M_Test_Element_Begin is
            new Check_Fixture (Fixture, Test_Element_Begin);
        procedure M_Test_Element_Middle is
            new Check_Fixture (Fixture, Test_Element_Middle);
        procedure M_Test_Element_End is
            new Check_Fixture (Fixture, Test_Element_End);
        procedure M_Test_Element_Error is
            new Check_Fixture (Fixture, Test_Element_Error);
        procedure M_Test_Slice_Null_10 is
            new Check_Fixture (Fixture, Test_Slice_Null_10);
        procedure M_Test_Slice_Null_End is
            new Check_Fixture (Fixture, Test_Slice_Null_End);
        procedure M_Test_Slice_All is
            new Check_Fixture (Fixture, Test_Slice_All);
        procedure M_Test_Slice_All_Internal is
            new Check_Fixture (Fixture, Test_Slice_All_Internal);
        procedure M_Test_Slice_Begin is
            new Check_Fixture (Fixture, Test_Slice_Begin);
        procedure M_Test_Slice_Middle is
            new Check_Fixture (Fixture, Test_Slice_Middle);
        procedure M_Test_Slice_End is
            new Check_Fixture (Fixture, Test_Slice_End);
	
		procedure Add_Tests (Suite : Test_Suites.Access_Test_Suite) is
			use Caller;
		begin
			Suite.Add_Test (Create (Ext_Prefix & "Test_Length " & Name,
									M_Test_Length'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_To_String " & Name,
									M_Test_To_String'Access));
                                    
			Suite.Add_Test (Create (Ext_Prefix & "Test_Element_Begin " & Name,
									M_Test_Element_Begin'Access));
            if Length >= 3 then
                Suite.Add_Test (Create (Ext_Prefix & "Test_Element_Middle " & Name,
                                        M_Test_Element_Middle'Access));
            end if;
            if Length >= 2 then
                Suite.Add_Test (Create (Ext_Prefix & "Test_Element_End " & Name,
                                        M_Test_Element_End'Access));
            end if;
			Suite.Add_Test (Create (Ext_Prefix & "Test_Element_Error " & Name,
									M_Test_Element_Error'Access));
                                    
			Suite.Add_Test (Create (Ext_Prefix & "Test_Slice_Null_10 " & Name,
									M_Test_Slice_Null_10'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_Slice_Null_End " & Name,
									M_Test_Slice_Null_End'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_Slice_All " & Name,
									M_Test_Slice_All'Access));
			if Length >= 2 then
    			Suite.Add_Test (Create (Ext_Prefix & "Test_Slice_Begin " & Name,
	    								M_Test_Slice_Begin'Access));
		    	Suite.Add_Test (Create (Ext_Prefix & "Test_Slice_End " & Name,
			    						M_Test_Slice_End'Access));
			end if;
			if Length >= 3 then
    			Suite.Add_Test (Create (Ext_Prefix & "Test_Slice_Middle " & Name,
	    								M_Test_Slice_Middle'Access));
	    	end if;
		end Add_Tests;
		
		procedure Add_Internal_Tests (Suite : Test_Suites.Access_Test_Suite) is
			use Caller;
		begin
			Suite.Add_Test (Create (Int_Prefix & "Test_Slice_All_Internal " & Name,
									M_Test_Slice_All_Internal'Access));
		end Add_Internal_Tests;
		
	end Length_Fixtures;

	Small_Min : constant Positive := 1;
	Small_Max : constant Positive := Ropes.String_Impl.Max_Small_String;
	Large_Min : constant Positive := Small_Max + 1;
	Large_Max : constant Positive := 100;
	
	package Length_Small_Min_Fixture is
		new Length_Fixtures (Small_Min, "Small_Min");
	package Length_Small_Max_Fixture is
		new Length_Fixtures (Small_Max, "Small_Max");
	package Length_Large_Min_Fixture is
		new Length_Fixtures (Large_Min, "Large_Min");
	package Length_Large_Max_Fixture is
		new Length_Fixtures (Large_Max, "Large_Max");

	function External_Suite return AUnit.Test_Suites.Access_Test_Suite is
	    Result : constant Test_Suites.Access_Test_Suite := new Test_Suites.Test_Suite;
	begin
		Length_Small_Min_Fixture.Add_Tests (Result);
		Length_Small_Max_Fixture.Add_Tests (Result);
		Length_Large_Min_Fixture.Add_Tests (Result);
		Length_Large_Max_Fixture.Add_Tests (Result);
		return Result;
	end External_Suite;

	function Internal_Suite return AUnit.Test_Suites.Access_Test_Suite is
	    Result : constant Test_Suites.Access_Test_Suite := new Test_Suites.Test_Suite;
	begin
		Length_Small_Min_Fixture.Add_Internal_Tests (Result);
		Length_Small_Max_Fixture.Add_Internal_Tests (Result);
		Length_Large_Min_Fixture.Add_Internal_Tests (Result);
		Length_Large_Max_Fixture.Add_Internal_Tests (Result);
		return Result;
	end Internal_Suite;

end Ropes.Tests.String_Impl;
