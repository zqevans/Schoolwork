with Ada.Text_IO;
with AUnit.Assertions;
with Tracking_Pools.Allocation_Message;

package body Ropes.Tests.Memory_Check is

    use AUnit;
    
    package body Memory_Case is

        overriding
        procedure Run_Test (T : in out Memory_Case) is
        begin
            TCase(T).Run_Test;
            Ada.Text_IO.Put_Line (Tracking_Pools.Allocation_Message (Rope_Pool));
        end Run_Test;

    end Memory_Case;
    
    procedure Check_Fixture (T : in out Fixture) is 
    begin
        Rope_Pool.Clear_Counts;
        Test (T);
        if Rope_Pool.Is_Balanced then
            return;
        end if;
        declare
            Message : constant String :=  "Memory Leak: " &
                        Tracking_Pools.Allocation_Message (Rope_Pool);
        begin
            Rope_Pool.Clear_Counts;
            Assertions.Assert (False, Message);
        end;
    end Check_Fixture;

end Ropes.Tests.Memory_Check;
