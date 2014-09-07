-----------------------------------------------------------------------
--  Ropes.Concat_Impl package spec
--
--  Author: Chris Reedy (Chris.Reedy@wwu.edu)
-----------------------------------------------------------------------

--  A Concat_Impl is a String_Impl that represents the concatenation of
--  two strings. Concat_Impl have references to Rope_Impls which
--  represent the left and right Ropes that were concatenated.
--
--  The left and right pointers in Concat_Impl are both non-null. The
--  procedure Make_Concat_Impl is used to guarantee that this
--  constraint is maintained.

private package Ropes.Concat_Impl is

    type Concat_Impl is new Ropes.Rope_Impl with record
        L, R : Rope_Impl_Access;
    end record;

    --  See Ropes.ads for description of overriding operations.
    overriding
    procedure Dispose (R : access Concat_Impl);

    overriding
    function Element (Source : Concat_Impl; Index : Positive) return Character;

    overriding
    procedure To_String (Source : access constant Concat_Impl;
                         Target : in out String; Start : in Positive);

    overriding
    function Slice (Source : access Concat_Impl;
                    Low : Positive; High : Natural)
      return Rope_Impl_Access;

    --  Impl_Text_Contents returns a string with the short descriptions of
    --  the left and right children.
    overriding
    function Impl_Text_Contents (R : access constant Concat_Impl) return String;

    package Make is

        --  Make_Concat_Impl returns an access to a Rope_Impl representing the
        --  concatentation. If exactly one of Left or Right is null, the non-null
        --  one is returned. If both are null, null is returned.
        --
        --  The Ref_Counts of both Left and Right must be incremented prior to
        --  calling Make_Concat_Impl. Make_Concat_Impl uses that reference when
        --  creating the Concat_Impl.
        function Make_Concat_Impl (Left, Right : Rope_Impl_Access) return Rope_Impl_Access;

    end Make;

    function Make_Concat_Impl (Left, Right : Rope_Impl_Access) return Rope_Impl_Access
        renames Make.Make_Concat_Impl;

end Ropes.Concat_Impl;
