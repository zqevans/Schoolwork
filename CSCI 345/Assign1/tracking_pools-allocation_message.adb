-----------------------------------------------------------------------
--  Tracking_Pools.Allocation_Message function
--
--  Author: Chris Reedy (Chris.Reedy@wwu.edu)
-----------------------------------------------------------------------

with Ada.Strings.Fixed;

--  This function returns a string of the form:
--      "Allocated: ## bytes (## allocs) Freed: ## bytes (## frees)"
--  where the numbers indicated by ## are filled in with the corresponding
--  values from the tracking pool.

function Tracking_Pools.Allocation_Message (Pool : Tracking_Pool) return String is

    use Ada.Strings;
    use Ada.Strings.Fixed;

    P1 : constant String := "Allocated: ";
    P2 : constant String := " bytes (";
    P3 : constant String := " allocs), Freed: ";
    P5 : constant String := " frees)";
    Message : String (1 .. 256); -- Should be plenty of room
    Cur : Integer := 1;

    procedure Add_String (S : in String) is
    begin
        Message (Cur .. Cur + S'Length - 1) := S;
        Cur := Cur + S'Length;
    end Add_String;

    procedure Add_Alloc_Count (C : in Allocation_Count) is
    begin
        Add_String (Trim (Allocation_Count'Image (C), Left));
    end Add_Alloc_Count;

    procedure Add_Storage_Count (C : in Storage_Count) is
    begin
        Add_String (Trim (Storage_Count'Image (C), Left));
    end Add_Storage_Count;

begin
    Add_String (P1);
    Add_Storage_Count (Pool.Allocated);
    Add_String (P2);
    Add_Alloc_Count (Pool.Allocations);
    Add_String (P3);
    Add_Storage_Count (Pool.Deallocated);
    Add_String (P2);
    Add_Alloc_Count (Pool.Deallocations);
    Add_String (P5);
    return Message (1 .. Cur - 1);

end Tracking_Pools.Allocation_Message;
