-----------------------------------------------------------------------
--  Tracking_Pools package spec
--
--  Author: Chris Reedy (Chris.Reedy@wwu.edu)
-----------------------------------------------------------------------

with System.Storage_Elements;
with System.Storage_Pools;

--  A tracking pool is a storage pool that tracks allocations and the
--  number of bytes allocated. The actual allocation is preformed by
--  the underlying system allocator.

package Tracking_Pools is

    subtype Storage_Count is System.Storage_Elements.Storage_Count;
    use type System.Storage_Elements.Storage_Count;

    subtype Allocation_Count is Long_Integer range 0 .. Long_Integer'Last;

    type Tracking_Pool is new System.Storage_Pools.Root_Storage_Pool
    with record
        Allocations   : Allocation_Count := 0;
        Deallocations : Allocation_Count := 0;
        Allocated     : Storage_Count := 0;
        Deallocated   : Storage_Count := 0;
    end record;

    --  see System.Storage_Pools
       overriding
       procedure Allocate (Pool                     : in out Tracking_Pool;
                        Storage_Address          : out System.Address;
                         Size_In_Storage_Elements : Storage_Count;
                          Alignment                : Storage_Count);

    overriding
    procedure Deallocate (Pool                     : in out Tracking_Pool;
                           Storage_Address          : System.Address;
                          Size_In_Storage_Elements : Storage_Count;
                          Alignment                : Storage_Count);

    overriding
    function Storage_Size (Pool : Tracking_Pool) return Storage_Count;

    --  Clear_Counts clears the counts in the tracking pool.
    procedure Clear_Counts (Pool : in out Tracking_Pool);

    --  Is_Balanced returns True if the allocation and allocated bytes
    --  are equal to the deallocations and deallocated bytes.
    function Is_Balanced (Pool : Tracking_Pool) return Boolean;

end Tracking_Pools;