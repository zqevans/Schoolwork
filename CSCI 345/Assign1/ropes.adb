-----------------------------------------------------------------------
--  Ropes package body
--
--  Author: Chris Reedy (Chris.Reedy@wwu.edu)
-----------------------------------------------------------------------

with Ada.Strings.Fixed;
with Ada.Text_IO;
with Ada.Tags;
with System.Storage_Elements;

with Ropes.String_Impl; use Ropes.String_Impl;
with Ropes.Concat_Impl; use Ropes.Concat_Impl;

package body Ropes is

    --  Note that the Rope_Impl_Access in a Rope can be null. For this
    --  reason, all routines that manipulate Ropes (as opposed to
    --  Rope_Impls) must check for a null pointer and do the right thing,
    --  which is whatever is correct for a null string.

    function Length (Source : in Rope) return Natural is
    begin
        if Source.B = null then
            return 0;
        else
            return Length (Source.B.all);
        end if;
    end Length;

    function Element (Source : Rope; Index : Positive) return Character is
    begin
        if Index > Source.Length then
            raise Constraint_Error with "Rope Index out of range";
        end if;
        --  If Source.B is null, Index > Source.Length should have been true
        pragma Assert (Source.B /= null);
        return Element (Source.B.all, Index);
    end Element;

    function To_Rope (Source : in String) return Rope is
        Result : constant Rope_Impl_Access := Make_String_Impl (Source);
    begin
        --  Result will be null if Source has length zero.
        return Rope'(Ada.Finalization.Controlled with B => Result);
    end To_Rope;

    function To_String (Source : in Rope) return String is
    begin
         if Source.B = null then
            return "";
        end if;
        declare
            Result : String (1 .. Length (Source.B.all));
        begin
            To_String (Source.B, Result, 1);
            return Result;
        end;
    end To_String;

    function Copy (Source : Rope) return Rope is
    begin
        --  Increment Reference Count and return a copy
        if Source.B /= null then
            Inc_Ref_Count (Source.B);
        end if;
        return Rope'(Ada.Finalization.Controlled with B => Source.B);
    end Copy;

    function "&" (Left, Right : Rope) return Rope is
    begin
        Inc_Ref_Count (Left.B);
        Inc_Ref_Count (Right.B);
        return Rope'(Ada.Finalization.Controlled with
                        B => Make_Concat_Impl (Left.B, Right.B));
    end "&";

    function "&" (Left : Rope; Right : String) return Rope is
    begin
        return Left & To_Rope (Right);
    end "&";

    function "&" (Left : String; Right : Rope) return Rope is
    begin
        return To_Rope (Left) & Right;
    end "&";

    function Slice (Source : Rope; Low : Positive; High : Natural)
        return Rope is
        Source_Length : constant Natural := Length (Source);
        Real_High : constant Natural := Natural'Min (High, Source_Length);
        Result : Rope_Impl_Access;
    begin
        if Low > Source_Length + 1 then
            raise Constraint_Error with "Rope Index out of range";
        end if;
        if Real_High < Low then
            return Null_Rope;
        end if;
        Result := Source.B.Slice (Low, Real_High);
        return Rope'(Ada.Finalization.Controlled with B => Result);
    end Slice;

    procedure Adjust (R : in out Rope) is
    begin
        if Memory_Verbose then
            Ada.Text_IO.Put_Line ("Adjust " & Rope_Text_Image (R));
        end if;
        Inc_Ref_Count (R.B);
    end Adjust;

    procedure Finalize (R : in out Rope) is
    begin
        if Memory_Verbose then
            Ada.Text_IO.Put_Line ("Finalize " & Rope_Text_Image (R));
        end if;
        Dec_Ref_Count (R.B);
        if R.B /= null and then R.B.Ref_Count = 0 then
            Free (R.B);
        end if;
    end Finalize;

    function Length (Source : in Rope_Impl) return Natural is
    begin
        return Source.Length;
    end Length;

    procedure Set_Memory_Verbose (Verbose : Boolean) is
    begin
        Memory_Verbose := Verbose;
    end Set_Memory_Verbose;

    procedure Inc_Ref_Count (R : access Rope_Impl'Class) is
    begin
        if R /= null then
            R.Ref_Count := R.Ref_Count + 1;
            if Memory_Verbose then
                declare
                    Ref_Count_Str : constant String := Integer'Image (R.Ref_Count);
                begin
                    Ada.Text_IO.Put_Line ("Inc_Ref_Count " & Impl_Text_Image (R) & " to" & Ref_Count_Str);
                end;
            end if;
        end if;
    end Inc_Ref_Count;

    procedure Dec_Ref_Count (R : access Rope_Impl'Class) is
    begin
        if R /= null then
            R.Ref_Count := R.Ref_Count - 1;
            if Memory_Verbose then
                declare
                    Ref_Count_Str : constant String := Integer'Image (R.Ref_Count);
                begin
                    Ada.Text_IO.Put_Line ("Dec_Ref_Count " & Impl_Text_Image (R) & " to" & Ref_Count_Str);
                end;
            end if;
            if R.Ref_Count = 0 then
                Dispose(R);
            end if;
        end if;
    end Dec_Ref_Count;

    function Address_String (Addr : System.Address) return String is
        use System.Storage_Elements;
        Address_Str : constant String := Integer_Address'Image (To_Integer (Addr));
    begin
        return Address_Str (2 .. Address_Str'Length);
    end Address_String;

    function Rope_Text_Image (R : in Rope'Class) return String is
    begin
        if R.B = null then
            return "[Rope@" & Address_String (R'Address) & " null]";
        else
            return "[Rope@" & Address_String (R'Address) & " " & Impl_Text_Image(R.B, False) & "]";
        end if;
    end Rope_Text_Image;

    function Impl_Text_Image (R : access constant Rope_Impl'Class; Full : Boolean := True) return String is
        use Ada.Strings; use Ada.Strings.Fixed;
        Full_Name : constant String := Ada.Tags.External_Tag (R'Tag);
        I : constant Natural := Index (Full_Name, ".", Backward);
        Short_Name : constant String := Full_Name (I + 1 .. Full_Name'Length);
        Address_Str : constant String := Address_String (R.all'Address);
    begin
        if Full then
            return "[" & Short_Name & "@" & Address_Str & Impl_Text_Contents (R) & "]";
        else
            return "[" & Short_Name & "@" & Address_Str & "]";
        end if;
    end Impl_Text_Image;

    function Impl_Text_Contents (R : access constant Rope_Impl) return String is
        pragma Warnings (Off, R);
    begin
        return "";
    end Impl_Text_Contents;

end Ropes;
