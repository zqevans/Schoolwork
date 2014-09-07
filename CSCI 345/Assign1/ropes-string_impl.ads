-----------------------------------------------------------------------
--  Ropes.String_Impl package spec
--
--  Author: Chris Reedy (Chris.Reedy@wwu.edu)
-----------------------------------------------------------------------

--  A String_Impl is a Rope_Impl that contains a simple string.
--  String_Impls are managed by a pointer to the underlying string. (As
--  opposed to embedding the string in the String_Impl object.

private package Ropes.String_Impl is

    --  Future: Max_Small_String is the maximum size for a small string.
    --  A small string is embedded in the String_Impl rather than being
    --  pointed to by the impl. This constant is exposed to allow test
    --  programs to know the size.
    Max_Small_String : constant Natural := 8;

    type String_Impl is new Ropes.Rope_Impl with record
        S : String_Access;
    end record;

    --  See Ropes.ads for these procedures
    overriding
    procedure Dispose (R : access String_Impl);

    overriding
    function Element (Source : String_Impl; Index : Positive) return Character;

    overriding
    procedure To_String (Source : access constant String_Impl;
                         Target : in out String; Start : in Positive);

    overriding
    function Slice (Source : access String_Impl;
                    Low : Positive; High : Natural)
      return Rope_Impl_Access;

    --  Impl_Text_Contents returns a string which is a copy of the underlying
    --  string.
    overriding
    function Impl_Text_Contents (R : access constant String_Impl) return String;

    package Make is

        --  Make_String_Impl makes a copy of Source and returns a String_Impl
        --  which contains or references the copy. Make_String_Impl returns a
        --  null pointer if Source has zero length.
        function Make_String_Impl (Source : in String) return Rope_Impl_Access;

    end Make;

    --  Expose Make_String_Impl as part of the parent package.
    function Make_String_Impl (Source : in String) return Rope_Impl_Access
        renames Make.Make_String_Impl;

end Ropes.String_Impl;
