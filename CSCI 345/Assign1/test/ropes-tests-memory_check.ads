with AUnit.Simple_Test_Cases;
with AUnit.Test_Fixtures;

package Ropes.Tests.Memory_Check is

    generic
        type TCase is new AUnit.Simple_Test_Cases.Test_Case with private;
    package Memory_Case is
    
        type Memory_Case is new TCase with null record;
        
        overriding
        procedure Run_Test (T : in out Memory_Case);
        
    end Memory_Case;
    
    generic
        type Fixture is new AUnit.Test_Fixtures.Test_Fixture with private;
        with procedure Test (T : in out Fixture);
    procedure Check_Fixture (T : in out Fixture);

end Ropes.Tests.Memory_Check;
