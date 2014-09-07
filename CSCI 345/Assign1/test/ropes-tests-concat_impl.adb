with AUnit.Test_Fixtures;
with AUnit.Test_Caller;
with AUnit.Assertions; use AUnit.Assertions;

with Ropes.Tests.Memory_Check;
-- with Ropes.Concat_Impl;

package body Ropes.Tests.Concat_Impl is

	use AUnit;

	package Concat_Fixture is
	
	    Concat_Len : constant Positive := 20;
	    Concat_Mid : constant Positive := Concat_Len / 2;
	
		type Fixture is new Test_Fixtures.Test_Fixture with record
		    Test_Str_All : Test_String_Access;
		    Test_Str1 : Test_String_Access;
		    Test_Str2 : Test_String_Access;
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
		
        procedure Test_Element_MidLeft (T : in out Fixture);

        procedure Test_Element_EndLeft (T : in out Fixture);

        procedure Test_Element_BeginRight (T : in out Fixture);
		
        procedure Test_Element_MidRight (T : in out Fixture);

        procedure Test_Element_End (T : in out Fixture);

        procedure Test_Element_Error (T : in out Fixture);
        
        procedure Test_Slice_Left_Begin (T : in out Fixture);

        procedure Test_Slice_Left_Mid (T : in out Fixture);
        
        procedure Test_Slice_Left_End (T : in out Fixture);
        
        procedure Test_Slice_Left_All (T : in out Fixture);
        
        procedure Test_Slice_Right_Begin (T : in out Fixture);
        
        procedure Test_Slice_Right_Mid (T : in out Fixture);
        
        procedure Test_Slice_Right_End (T : in out Fixture);
        
        procedure Test_Slice_Right_All (T : in out Fixture);
        
        procedure Test_Slice_Left_Mid_Right_Begin (T : in out Fixture);
        
        procedure Test_Slice_Left_End_Right_Mid (T : in out Fixture);
        
        procedure Test_Slice_Left_Mid_Right_Mid (T : in out Fixture);
        
        procedure Test_Slice_All (T : in out Fixture);
        
        procedure Test_Slice_Error (T : in out Fixture);
        
		package Caller is new Test_Caller (Fixture);
		
		procedure Add_Tests (Suite : Test_Suites.Access_Test_Suite);

		procedure Add_Internal_Tests (Suite : Test_Suites.Access_Test_Suite);

	end Concat_Fixture;
	
	package body Concat_Fixture is	
		
		overriding
		procedure Set_Up (T : in out Fixture) is
		    Base_String : constant String := Make_Test_String (Concat_Len);
		begin
		    T.Test_Str_All := new String'(Base_String);
			T.Test_Str1 := new String'(Base_String (1 .. Concat_Mid));
			T.Test_Str2 := new String'(Base_String (Concat_Mid + 1 .. Concat_Len));
		end Set_Up;
	
		overriding
		procedure Tear_Down (T : in out Fixture) is
		begin
		    Free (T.Test_Str_All);
			Free (T.Test_Str1);
			Free (T.Test_Str2);
            pragma Assert (Rope_Test_Pool.Is_Balanced, "Unbalanced Rope_Test_Pool");
		end Tear_Down;
		
		function Make_Test_Concat (T : in Fixture) return Rope is
		begin
		    return To_Rope (T.Test_Str1.all) & To_Rope (T.Test_Str2.all);
		end Make_Test_Concat;
		
		procedure Test_Length (T : in out Fixture) is
			Message : constant String := "Length Concat " & " rope has wrong length";
			Test_Rope : constant Rope := Make_Test_Concat (T); 
		begin
			Assert (Test_Rope.Length = Concat_Len, Message);
		end Test_Length;
	
		procedure Test_To_String (T : in out Fixture) is
			Message : constant String := "To_String Concat " & " rope has wrong contents";
			Test_Rope : constant Rope := Make_Test_Concat (T); 
		begin
			Assert (Test_Rope.To_String = T.Test_Str_All.all, Message);
		end Test_To_String;
		
		procedure Element_Test (T : in Fixture; Prefix : in String; Index : Positive) is
		    Test_Rope : constant Rope := Make_Test_Concat (T);
		begin
		    Assert (Test_Rope.Element (Index) = T.Test_Str_All (Index), Prefix & "is wrong");
		end Element_Test;
		
        procedure Test_Element_Begin (T : in out Fixture) is
        begin
            Element_Test (T, "Element(Begin) Concat ", 1);
        end Test_Element_Begin;
		
        procedure Test_Element_MidLeft (T : in out Fixture) is
        begin
            Element_Test (T, "Element(MidLeft) Concat ", Concat_Mid / 2);
        end Test_Element_MidLeft;

        procedure Test_Element_EndLeft (T : in out Fixture) is
        begin
            Element_Test (T, "Element(EndLeft) Concat ", Concat_Mid);
        end Test_Element_EndLeft;

        procedure Test_Element_BeginRight (T : in out Fixture) is
        begin
            Element_Test (T, "Element(Beginright) Concat ", Concat_Mid + 1);
        end Test_Element_BeginRight;
		
        procedure Test_Element_MidRight (T : in out Fixture) is
        begin
            Element_Test (T, "Element(Midright) Concat ", (Concat_Mid + 1 + Concat_Len) / 2);
        end Test_Element_MidRight;

        procedure Test_Element_End (T : in out Fixture) is
        begin
            Element_Test (T, "Element(Concat_Len) Concat ", Concat_Len);
        end Test_Element_End;

        procedure Test_Element_Error (T : in out Fixture) is
            Message : constant String := "Element(end + 1) Concat " & " did not raise Constraint_Error";
            Test_Rope : constant Rope := Make_Test_Concat (T);
            Index : constant Positive := Concat_Len + 1;
            C : Character;
            pragma Warnings(Off, C);
        begin
            C := Test_Rope.Element (Index);
            Assert (False, Message);
        exception
            when Constraint_Error => null;
        end Test_Element_Error;
        
        procedure Slice_Test (T : in Fixture; Prefix : in String; Low, High : Positive) is
            Test_Rope : constant Rope := Make_Test_Concat (T);
            Sliced : constant Rope := Test_Rope.Slice (Low, High);
        begin            
            pragma Assert (Low < High and High <= Concat_Len);
            Assert (Sliced.To_String = T.Test_Str_All (Low .. High), Prefix & "has wrong contents");
            Assert (Sliced.Length = High - Low + 1, Prefix & "has wrong length");
        end Slice_Test;
        
        procedure Test_Slice_Left_Begin (T : in out Fixture) is
        begin
            Slice_Test (T, "Slice (1 .. LMid) Concat ", 1,  (1 + Concat_Mid) / 2);
        end Test_Slice_Left_Begin;
        
        procedure Test_Slice_Left_Mid (T : in out Fixture) is
            Mid : constant Positive := (1 + Concat_Mid) / 2;
        begin
            Slice_Test (T, "Slice (1 .. LMid) Concat ", Mid - 1, Mid + 1);
        end Test_Slice_Left_Mid;
        
        procedure Test_Slice_Left_End (T : in out Fixture) is
        begin
            Slice_Test (T, "Slice (LMid .. LEnd) Concat ", (1 + Concat_Mid) / 2, Concat_Mid);
        end Test_Slice_Left_End;
        
        procedure Test_Slice_Left_All (T : in out Fixture) is
        begin
            Slice_Test (T, "Slice (LeftAll) Concat ", 1,  Concat_Mid);
        end Test_Slice_Left_All;
        
        procedure Test_Slice_Right_Begin (T : in out Fixture) is
        begin
            Slice_Test (T, "Slice (RBegin .. RMid) Concat ", Concat_Mid + 1, (Concat_Mid + 1 + Concat_Len) / 2);
        end Test_Slice_Right_Begin;
        
        procedure Test_Slice_Right_Mid (T : in out Fixture) is
            Mid : constant Positive := (Concat_Mid + 1 + Concat_Len) / 2;
        begin
            Slice_Test (T, "Slice (RMid) Concat ", Mid - 1, Mid + 1);
        end Test_Slice_Right_Mid;
        
        procedure Test_Slice_Right_End (T : in out Fixture) is
        begin
            Slice_Test (T, "Slice (RMid .. End) Concat ", (Concat_Mid + 1 + Concat_Len) / 2,  Concat_Len);
        end Test_Slice_Right_End;
        
        procedure Test_Slice_Right_All (T : in out Fixture) is
        begin
            Slice_Test (T, "Slice (RightAll) Concat ", Concat_Mid + 1,  Concat_Len);
        end Test_Slice_Right_All;
        
        procedure Test_Slice_Left_Mid_Right_Begin (T : in out Fixture) is
        begin
            Slice_Test (T, "Slice (LMid .. RBegin) Concat ", (1 + Concat_Mid) / 2, Concat_Mid + 1);
        end Test_Slice_Left_Mid_Right_Begin;
        
        procedure Test_Slice_Left_End_Right_Mid (T : in out Fixture) is
        begin
            Slice_Test (T, "Slice (LEnd .. RMid) Concat ", Concat_Mid, (Concat_Mid + 1 + Concat_Len) / 2);
        end Test_Slice_Left_End_Right_Mid;
        
        procedure Test_Slice_Left_Mid_Right_Mid (T : in out Fixture) is
        begin
            Slice_Test (T, "Slice (LMid .. RMid) Concat ", (1 + Concat_Mid) / 2, (Concat_Mid + 1 + Concat_Len) / 2);
        end Test_Slice_Left_Mid_Right_Mid;
        
        procedure Test_Slice_All (T : in out Fixture) is
        begin
            Slice_Test (T, "Slice All Concat ", 1, Concat_Len);
        end Test_Slice_All;

        procedure Test_Slice_Error (T : in out Fixture) is
            Message : constant String := "Slice(end + 1, 1) Concat " & " did not raise Constraint_Error";
            Test_Rope : constant Rope := Make_Test_Concat (T);
            Result : Rope;
            pragma Warnings(Off, Rope);
        begin
            Result := Test_Rope.Slice (Concat_Len + 2, 1);
            Assert (False, Message);
        exception
            when Constraint_Error => null;
        end Test_Slice_Error;
        
		use Memory_Check;
		
        procedure M_Test_Length is
            new Check_Fixture (Fixture, Test_Length);
        procedure M_Test_To_String is
            new Check_Fixture (Fixture, Test_Length);
        procedure M_Test_Element_Begin is
            new Check_Fixture (Fixture, Test_Element_Begin);
        procedure M_Test_Element_MidLeft is
            new Check_Fixture (Fixture, Test_Element_MidLeft);
        procedure M_Test_Element_EndLeft is
            new Check_Fixture (Fixture, Test_Element_EndLeft);
        procedure M_Test_Element_BeginRight is
            new Check_Fixture (Fixture, Test_Element_BeginRight);
        procedure M_Test_Element_MidRight is
            new Check_Fixture (Fixture, Test_Element_MidRight);
        procedure M_Test_Element_End is
            new Check_Fixture (Fixture, Test_Element_End);
        procedure M_Test_Element_Error is
            new Check_Fixture (Fixture, Test_Element_Error);
        procedure M_Test_Slice_Left_Begin is
            new Check_Fixture (Fixture, Test_Slice_Left_Begin);
        procedure M_Test_Slice_Left_Mid  is
            new Check_Fixture (Fixture, Test_Slice_Left_Mid);
        procedure M_Test_Slice_Left_End is
            new Check_Fixture (Fixture, Test_Slice_Left_End);
        procedure M_Test_Slice_Left_All is
            new Check_Fixture (Fixture, Test_Slice_Left_All);
        procedure M_Test_Slice_Right_Begin is
            new Check_Fixture (Fixture, Test_Slice_Right_Begin);
        procedure M_Test_Slice_Right_Mid is
            new Check_Fixture (Fixture, Test_Slice_Right_Mid);
        procedure M_Test_Slice_Right_End is
            new Check_Fixture (Fixture, Test_Slice_Right_End);
        procedure M_Test_Slice_Right_All is
            new Check_Fixture (Fixture, Test_Slice_Right_All);
        procedure M_Test_Slice_Left_Mid_Right_Begin is
            new Check_Fixture (Fixture, Test_Slice_Left_Mid_Right_Begin);
        procedure M_Test_Slice_Left_End_Right_Mid is
            new Check_Fixture (Fixture, Test_Slice_Left_End_Right_Mid);
        procedure M_Test_Slice_Left_Mid_Right_Mid is
            new Check_Fixture (Fixture, Test_Slice_Left_Mid_Right_Mid);
        procedure M_Test_Slice_All is
            new Check_Fixture (Fixture, Test_Slice_All);
        procedure M_Test_Slice_Error is
            new Check_Fixture (Fixture, Test_Slice_Error);
	
		procedure Add_Tests (Suite : Test_Suites.Access_Test_Suite) is
			use Caller;
		begin
			Suite.Add_Test (Create (Ext_Prefix & "Test_Length Concat ",
									M_Test_Length'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_To_String Concat ",
									M_Test_To_String'Access));
                                    
			Suite.Add_Test (Create (Ext_Prefix & "Test_Element_Begin Concat ",
									M_Test_Element_Begin'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_Element_MidLeft Concat ",
									M_Test_Element_MidLeft'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_Element_EndLeft Concat ",
									M_Test_Element_EndLeft'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_Element_BeginRight Concat ",
									M_Test_Element_BeginRight'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_Element_MidRight Concat ",
									M_Test_Element_MidRight'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_Element_End Concat ",
									M_Test_Element_End'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_Element_Error Concat ",
									M_Test_Element_Error'Access));
                                    
			Suite.Add_Test (Create (Ext_Prefix & "Test_Slice_Left_Begin Concat ",
									M_Test_Slice_Left_Begin'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_Slice_Left_Mid Concat ",
									M_Test_Slice_Left_Mid'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_Slice_Left_End Concat ",
									M_Test_Slice_Left_End'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_Slice_Left_All Concat ",
									M_Test_Slice_Left_All'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_Slice_Right_Begin Concat ",
									M_Test_Slice_Right_Begin'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_Slice_Right_Mid Concat ",
									M_Test_Slice_Right_Mid'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_Slice_Right_End Concat ",
									M_Test_Slice_Right_End'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_Slice_Right_All Concat ",
									M_Test_Slice_Right_All'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_Slice_Left_Mid_Right_Begin Concat ",
									M_Test_Slice_Left_Mid_Right_Begin'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_Slice_Left_End_Right_Mid Concat ",
									M_Test_Slice_Left_End_Right_Mid'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_Slice_Left_Mid_Right_Mid Concat ",
									M_Test_Slice_Left_Mid_Right_Mid'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_Slice_All Concat ",
									M_Test_Slice_All'Access));
			Suite.Add_Test (Create (Ext_Prefix & "Test_Slice_Error Concat ",
									M_Test_Slice_Error'Access));
		end Add_Tests;
		
		procedure Add_Internal_Tests (Suite : Test_Suites.Access_Test_Suite) is
			use Caller;
		begin
			null;
		end Add_Internal_Tests;
		
	end Concat_Fixture;

	function External_Suite return AUnit.Test_Suites.Access_Test_Suite is
	    Result : constant Test_Suites.Access_Test_Suite := new Test_Suites.Test_Suite;
	begin
		Concat_Fixture.Add_Tests (Result);
		return Result;
	end External_Suite;

	function Internal_Suite return AUnit.Test_Suites.Access_Test_Suite is
	    Result : constant Test_Suites.Access_Test_Suite := new Test_Suites.Test_Suite;
	begin
		Concat_Fixture.Add_Internal_Tests (Result);
		return Result;
	end Internal_Suite;

end Ropes.Tests.Concat_Impl;
