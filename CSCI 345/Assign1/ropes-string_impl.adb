-----------------------------------------------------------------------
--  Ropes.String_Impl package bpdy
--
--  Author: Chris Reedy (Chris.Reedy@wwu.edu)
-----------------------------------------------------------------------

package body Ropes.String_Impl is

    overriding
    procedure Dispose (R : access String_Impl) is
    begin
        Free (R.S);
    end Dispose;

    overriding
    function Element (Source : String_Impl; Index : Positive)
      return Character is
    begin
        pragma Assert (Index <= Source.S'Length);
        return Source.S (Index);
    end Element;

    overriding
    procedure To_String (Source : access constant String_Impl;
                         Target : in out String; Start : in Positive) is
    begin
        Target (Start .. Start + Source.Length - 1) := Source.S.all;
    end To_String;

    overriding
    function Slice (Source : access String_Impl;
                    Low : Positive; High : Natural)
      return Rope_Impl_Access is
    begin
        pragma Assert (Low <= High and High <= Source.Length);
        if Low = 1 and High = Source.Length then
            Inc_Ref_Count (Source);
            return Rope_Impl_Access (Source);
        end if;
        return Make_String_Impl (Source.S (Low .. High));
    end Slice;

    overriding
    function Impl_Text_Contents (R : access constant String_Impl)
      return String is
    begin
        return " " & R.S.all;
    end Impl_Text_Contents;

    package body Make is

        function Make_String_Impl (Source : in String)
          return Rope_Impl_Access is
        begin
            if Source'Length = 0 then
                return null;
            end if;
            --  Need to shift the index of Source to be 1 based
            declare
                Str : constant String_Access :=
                  new String (1 .. Source'Length);
                New_Impl : constant Rope_Impl_Access :=
                  new String_Impl'(Ref_Count => 0,
                                   Length => Source'Length, S => Str);
            begin
                Str.all := Source;
                Inc_Ref_Count (New_Impl);
                return New_Impl;
            end;
        end Make_String_Impl;
    end Make;

end Ropes.String_Impl;
