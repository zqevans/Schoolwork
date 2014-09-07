--  Test_Ropes
--
--  Author: Chris Reedy (Chris.Reedy@wwu.edu)

with Ada.Command_Line;

with AUnit.Run;
with AUnit.Reporter.Text;
with AUnit.Test_Filters;
with AUnit.Options;

with Multi_Filters;

with Ropes;
with Basic_Tests;

--  Procedure Test_Ropes
--
--  This procedure is the main for driving the test packages for the ropes
--  package. This procedure is invoked as follows:
--
--      test_ropes [-m] test_name ...
--
--      -m is an optional flag that, if present, will enable tracing of all
--          Adjust and Finalize calls on the Rope type and all Inc_Ref_Count
--          and Dec_Ref_Count calls. Be careful with this since it can 
--          produce a great deal of output.
--
--      zero or more test_names. Each test name is interpreted as the prefix
--          for one or more tests. Any tests whose names start with any of
--          the specified prefixes will be run.

procedure Test_Ropes is

	Run_Filter : constant Multi_Filters.Multi_Filter_Access :=
		new Multi_Filters.Multi_Filter;
	
	Options : AUnit.Options.AUnit_Options;
	
	procedure Run is new AUnit.Run.Test_Runner (Basic_Tests.Suite);

    Reporter : AUnit.Reporter.Text.Text_Reporter;
    
    First_Test : Positive := 1;
     
begin

	Options.Global_Timer := True;
	Options.Test_Case_Timer := False;
	Options.Filter := AUnit.Test_Filters.Test_Filter_Access (Run_Filter);

    if Ada.Command_Line.Argument_Count >= First_Test then
        if Ada.Command_Line.Argument (First_Test) = "-m" then
            Ropes.Set_Memory_Verbose (True);
            First_Test := First_Test + 1;
        end if;
    end if;
    
	Run_Filter.Add_Command_Line (First_Test);

    Run (Reporter, Options);
    
    Run_Filter.Clear_Names;
    
end Test_Ropes;
