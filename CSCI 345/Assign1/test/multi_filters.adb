with Ada.Command_Line;

with AUnit.Simple_Test_Cases;

package body Multi_Filters is

	function Starts_With (Str : String; Prefix : String) return Boolean is
	begin
	  	if Str'Length < Prefix'Length then
		 	return False;
	  	end if;
	
	  	return Str (Str'First .. Str'First + Prefix'Length - 1) = Prefix;
	end Starts_With;

	function Get_Test_Name (T : AUnit.Tests.Test'Class) return String is
		use AUnit;
		use AUnit.Simple_Test_Cases;
	begin
	    if T not in Test_Case'Class
	    then
	    	--  Not a Test_Case, no way to get the name
	    	return "";
	    end if;
	    
	    -- We now know that T is a Test_Case
		if Test_Case'Class (T).Name = null
		then
			--  There is no name
			return "";
		end if;

		if Test_Case'Class (T).Routine_Name  = null then
			return Test_Case'Class (T).Name.all;
		else
			return Test_Case'Class (T).Name.all & " : " &
				   Test_Case'Class (T).Routine_Name.all;
		end if;
	end Get_Test_Name;

	pragma Inline (Starts_With, Get_Test_Name);
	
	function Is_Active (Filter : Multi_Filter;
				        T      : AUnit.Tests.Test'Class) return Boolean is
		use Name_Lists;
	begin
		if Filter.Names.Is_Empty then
			return True;
		end if;

		declare
			Cursor : Name_Lists.Cursor;
			Test_Name : constant String := Get_Test_Name (T);
		begin
			if Test_Name'Length = 0 then
				--  There is no name, so there is no match
				return False;
			end if;
			Cursor := Filter.Names.First;
			while Cursor /= No_Element loop
				if Starts_With (Test_Name, Element (Cursor).all) then
					return True;
				end if;
				Cursor := Next (Cursor);
			end loop;
		end;
		
		--  None of the filter terms matched the test name
		return False;
	end Is_Active;
				        
	procedure Clear_Names (Filter : in out Multi_Filter) is
	--  Clear the list of names that is currently maintained by the filter.
	--  This will release all memory associated with the filter.
	begin
		Filter.Names.Clear;
	end Clear_Names;
	
	procedure Add_Name (Filter : in out Multi_Filter; Name : in String) is
	--  Add the name Name to the filter.
	begin
		if Name'Length > 0 then
			Filter.Names.Append (new String'(Name));
		end if;
	end Add_Name;

	procedure Add_Command_Line (Filter : in out Multi_Filter;
	                            Offset : in Positive) is
	--  Add the remaining arguments from the command line to the filter.
	--  The parameter Offset determines the arguments from which to
	--  start adding names.
	begin
		for I in Offset .. Ada.Command_Line.Argument_Count loop
			Filter.Add_Name (Ada.Command_Line.Argument (I));
		end loop;
	end Add_Command_Line;
	
end Multi_Filters;
