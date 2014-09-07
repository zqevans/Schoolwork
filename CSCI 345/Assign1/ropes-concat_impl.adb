-----------------------------------------------------------------------
--  Ropes.Concat_Impl package body
--
--  Author: Chris Reedy (Chris.Reedy@wwu.edu)
-----------------------------------------------------------------------

package body Ropes.Concat_Impl is

    overriding
    procedure Dispose (R : access Concat_Impl) is
    begin
        pragma Assert (R.L /= null and R.R /= null);
        Dec_Ref_Count (R.L);
        if R.L.Ref_Count = 0 then
            Free (R.L);
        end if;
        Dec_Ref_Count (R.R);
        if R.R.Ref_Count = 0 then
            Free (R.R);
        end if;
    end Dispose;

    overriding
    function Element (Source : Concat_Impl; Index : Positive) return Character is
        Left_Length : constant Natural := Length (Source.L.all);
    begin
        pragma Assert (Index <= Source.Length);
        if Index <= Left_Length then
            return Element (Source.L.all, Index);
        else
            return Element (Source.R.all, Index - Left_Length);
        end if;
    end Element;

    overriding
    procedure To_String (Source : access constant Concat_Impl;
                         Target : in out String; Start : in Positive) is
    begin
        To_String (Source.L, Target, Start);
        To_String (Source.R, Target, Start + Length (Source.L.all));
    end To_String;

    overriding
    function Slice (Source : access Concat_Impl;
                    Low : Positive; High : Natural)
      return Rope_Impl_Access is
        New_L, New_R : Rope_Impl_Access := null;
        Left_Length : constant Natural := Length (Source.L.all);
    begin
        pragma Assert (Low <= High and High <= Length (Source.all));
        if Low = 1 and High = Source.Length then
            Inc_Ref_Count (Source);
            return Rope_Impl_Access (Source);
        end if;
        if Low <= Left_Length then
            New_L := Source.L.Slice (Low, Natural'Min (High, Left_Length));
        end if;
        if High > Left_Length then
            New_R := Source.R.Slice (Integer'Max (1, Low - Left_Length),
                                     High - Left_Length);
        end if;
        return Make_Concat_Impl (New_L, New_R);
    end Slice;

    overriding
    function Impl_Text_Contents (R : access constant Concat_Impl) return String is
    begin
        return " " & Impl_Text_Image (R.L, False) & " " & Impl_Text_Image (R.R, False);
    end Impl_Text_Contents;

    package body Make is

        function Make_Concat_Impl (Left, Right : Rope_Impl_Access)
          return Rope_Impl_Access is
        begin
            if Left = null then
                return Right;
            elsif Right = null then
                return Left;
            else
                declare
                    New_Impl : constant Rope_Impl_Access :=
                      new Concat_Impl'(Ref_Count => 0,
                                       Length => Length (Left.all) + Length (Right.all),
                                       L => Left, R => Right);
                begin
                    Inc_Ref_Count (New_Impl);
                    return New_Impl;
                end;
            end if;
        end Make_Concat_Impl;
    end Make;

end Ropes.Concat_Impl;
