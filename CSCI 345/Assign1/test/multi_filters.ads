private with Ada.Containers.Doubly_Linked_Lists;

with AUnit.Test_Filters;
with AUnit.Tests;

--  An instance of AUnit.Test_Filters.Filter.
--
--  A Multi-Filter allows multiple test names to be provided. If any of
--  the provided names matches the test, the test will be run.  Name 
--  matching is done in the same manner as AUnit.Test_Filters.Name_Filter.

package Multi_Filters is

	type Multi_Filter is limited new AUnit.Test_Filters.Test_Filter with private;
	type Multi_Filter_Access is access all Multi_Filter'Class;
	
	function Is_Active (Filter : Multi_Filter;
				        T      : AUnit.Tests.Test'Class) return Boolean;
				        
	procedure Clear_Names (Filter : in out Multi_Filter);
	--  Clear the list of names that is currently maintained by the filter.
	--  This will release all memory associated with the filter.
	
	procedure Add_Name (Filter : in out Multi_Filter; Name : in String);
	--  Add the name Name to the filter.

	procedure Add_Command_Line (Filter : in out Multi_Filter;
	                            Offset : in Positive);
	--  Add the remaining arguments from the command line to the filter.
	--  The parameter Offset determines the arguments from which to
	--  start adding names.
	
private

	type Name_Access is access String;
	package Name_Lists is new Ada.Containers.Doubly_Linked_Lists (Name_Access);

	type Multi_Filter is limited new AUnit.Test_Filters.Test_Filter with record
		Names : Name_Lists.List := Name_Lists.Empty_List;
	end record;
	
end Multi_Filters;

	