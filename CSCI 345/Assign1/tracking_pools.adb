-----------------------------------------------------------------------
--  Tracking_Pools package body
--
--  Author: Chris Reedy (Chris.Reedy@wwu.edu)
-----------------------------------------------------------------------

with System.Pool_Global;

package body Tracking_Pools is

    Global_Pool : System.Pool_Global.Unbounded_No_Reclaim_Pool
        renames System.Pool_Global.Global_Pool_Object;

       overriding
       procedure Allocate (Pool                     : in out Tracking_Pool;
                        Storage_Address          : out System.Address;
                         Size_In_Storage_Elements : Storage_Count;
                          Alignment                : Storage_Count) is
    begin
        Pool.Allocations := Pool.Allocations + 1;
        Pool.Allocated := Pool.Allocated + Size_In_Storage_Elements;
        Global_Pool.Allocate (Storage_Address, Size_In_Storage_Elements, Alignment);
    end Allocate;

    overriding
    procedure Deallocate (Pool                     : in out Tracking_Pool;
                           Storage_Address          : System.Address;
                          Size_In_Storage_Elements : Storage_Count;
                          Alignment                : Storage_Count) is
    begin
        Pool.Deallocations := Pool.Deallocations + 1;
        Pool.Deallocated := Pool.Deallocated + Size_In_Storage_Elements;
        Global_Pool.Deallocate (Storage_Address, Size_In_Storage_Elements, Alignment);
    end Deallocate;

    overriding
    function Storage_Size (Pool : Tracking_Pool) return Storage_Count is
        pragma Warnings (Off, Pool);
    begin
        return Global_Pool.Storage_Size;
    end Storage_Size;

    procedure Clear_Counts (Pool : in out Tracking_Pool) is
    begin
        Pool.Allocations := 0;
        Pool.Deallocations := 0;
        Pool.Allocated := 0;
        Pool.Deallocated := 0;
    end Clear_Counts;

    function Is_Balanced (Pool : Tracking_Pool) return Boolean is
    begin
        return Pool.Allocations = Pool.Deallocations and Pool.Allocated = Pool.Deallocated;
    end Is_Balanced;

end Tracking_Pools;