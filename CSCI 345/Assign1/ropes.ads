-----------------------------------------------------------------------
--  Ropes package spec
--
--  Author: Chris Reedy (Chris.Reedy@wwu.edu)
-----------------------------------------------------------------------

private with Ada.Unchecked_Deallocation;
private with Ada.Finalization;
private with Tracking_Pools;

--  package Ropes
--
--  The Ropes package provides an alternative implementation of the concept
--  of a string. (A Rope is a heavy-weight string.) The original concept is
--  discussed in the article: "Ropes: an Alternative to Strings", Boehm,
--  Atkinson, and Plass, Software Practice and Experience, December 1995,
--  pages 1315-1330.

package Ropes is

    --  Ropes are a data structure that provides behavior equivalent to that
    --  of a string. Ropes are immutable. All operations that return Ropes
    --  create a new Rope and leave the original Rope unchanged.
    --
    --  An uninitialized Rope is initialized to the empty Rope.
    type Rope is private;

    --  Length returns the length of Source, which is the same as the length
    --  of the string represented by the rope.
    function Length (Source : Rope) return Natural;

    --  Element returns the character at position Index in Source. The
    --  first character of a Rope has Index one (1). The last character has
    --  Index Length (Source). If Index > Length (Source) a Constraint_Error
    --  will be raised.
    function Element (Source : Rope; Index : Positive) return Character;

    --  To_Rope returns a Rope containing the contents of the ordinary
    --  string Source. To_Rope makes a copy of Source so it cannot be
    --  modified by later changes to the string.
    function To_Rope (Source : String) return Rope;

    --  To_String returns an ordinary String that contains the contents
    --  of the Rope Source. The returned String will have indices in the
    --  range 1 .. Length (Source).
    function To_String (Source : Rope) return String;

    --  Copy makes a copy of the given Rope.
    function Copy (Source : Rope) return Rope;

    --  & is an overloaded form of the Ada String concatenation operator. Three
    --  versions are provided. For concatenating two Ropes or a Rope and a
    --  String.
    function "&" (Left, Right : Rope) return Rope;
    function "&" (Left : Rope; Right : String) return Rope;
    function "&" (Left : String; Right : Rope) return Rope;

    --  Slice return a new Rope which is corresponds to the characters with
    --  indices Low .. High (inclusive) of the original Rope. The indices of
    --  the Rope that is returned will be 1 .. High - Low + 1. If
    --  Low > Length (Source) + 1, a Constraint_Error will be raised. If Low
    --  is in the valid range and High < Low, a Null_Rope will be returned.
    function Slice (Source : Rope; Low : Positive; High : Natural) return Rope;

    --  A Rope representing a null string.
    Null_Rope : constant Rope;

    --  For testing purposes. Set_Memory_Verbose (True) will cause a trace of
    --  memory relevant actions to be produced. This is available for internal
    --  debugging of the Rope operations.
    procedure Set_Memory_Verbose (Verbose : Boolean);

private

    --  Rope_Pool is provided as a way to track allocation and deallocation of
    --  Ropes. This provides a way to detect memory leaks.
    Rope_Pool : Tracking_Pools.Tracking_Pool;

    --  Ropes are implemented as pointers to Rope_Impls. There can be multiple
    --  kinds of Rope_Impls.
    type Rope_Impl is abstract tagged;

    type Rope_Impl_Access is access all Rope_Impl'Class;
    for Rope_Impl_Access'Storage_Pool use Rope_Pool;

    type Rope is new Ada.Finalization.Controlled with record
        B : Rope_Impl_Access;
    end record;

    --  Adjust and Finalize for Ropes. These procedures are required to handle
    --  memory management for Rope_Impls.
    overriding procedure Adjust (R : in out Rope);
    overriding procedure Finalize (R : in out Rope);

    Null_Rope : constant Rope := (Ada.Finalization.Controlled with B => null);

    --  All Rope_Impls contain a reference count and a length. Length is the
    --  total length of the string represented by this Rope_Impl.
    --
    --  Ref_Count contains a count of all references (via Rope_Impl_Access types)
    --  to this Rope_Impl. When this reference count goes to zero, the Rope_Impl
    --  will be freed. When an additional reference to a Rope_Impl is created, the
    --  Ref_Count is incremented.
    type Rope_Impl is abstract tagged record
        Ref_Count : Natural := 0;
        Length    : Natural := 0;
    end record;

    --  Dispose is called when the Ref_Count of a Rope_Impl goes to zero. Dispose
    --  is responsible for decrementing the Ref_Counts of any child Rope_Impls and
    --  Freeing any other structures that might be owned by this Rope_Impl.
    procedure Dispose (R : access Rope_Impl) is abstract;

    --  Length returns the Length of the Rope_Impl.
    function Length (Source : Rope_Impl) return Natural;

    --  Element returns the character at the given Index in this Rope_Impl.
    --  The Element function is allowed to assume that
    --  1 <= Index <= Length (Source).
    function Element (Source : Rope_Impl; Index : Positive) return Character
        is abstract;

    --  To_String copies the characters associated with this Rope_Impl into
    --  the String Target, beginning at Index Start. To_String is allowed to
    --  assume that Target is large enough to hold all of the string
    --  represented by Source.
    procedure To_String (Source : access constant Rope_Impl;
                         Target : in out String;
                         Start  : in Positive) is abstract;

    --  Slice returns a new Rope_Impl which represents the given Slice of
    --  Source. As part of memory management for Rope_Impls, the returned
    --  Rope_Impl will have its Ref_Count incremented to reflect that it has
    --  created a new reference to the slice. The caller of Slice is
    --  responsible for either using that reference by placing the slice in
    --  in a Rope or as the child of another Rope_Impl, or decrementing the
    --  Ref_Count if the Slice is to be discarded.
    function Slice (Source : access Rope_Impl;
                    Low : Positive; High : Natural)
      return Rope_Impl_Access is abstract;

    --  Impl_Text_Contents provides a String descriptive of the contents of
    --  R. This is called by Impl_Text_Image to create a string describing
    --  the Rope_Impl. The default implementation of this function returns
    --  the null string ("").
    function Impl_Text_Contents (R : access constant Rope_Impl) return String;

    --  Setting this flag to True will cause output describing memory relevant
    --  actions to be produced.
    Memory_Verbose : Boolean := False;

    --  Increment and decrement the Ref_Count of the R. Use these procedures
    --  when this is required, do not increment and decrement Ref_Counts
    --  directly.
    --
    --  Dec_Ref_Count will automatically call Dispose if the Ref_Count is
    --  decremented to zero. The caller of Dec_Ref_Count must still check to
    --  see if the count was decremented to zero and Free the Rope_Impl if
    --  it was.
    procedure Inc_Ref_Count (R : access Rope_Impl'Class);
    procedure Dec_Ref_Count (R : access Rope_Impl'Class);

    --  Utility functions which produce a string describing a Rope or
    --  Rope_Impl.
    --
    --  Rope_Text_Image returns a string of the form "[Rope@<<address>>].
    --  Impl_Test_Image returns a string of the form
    --  "[<<class>>@<<address>><<contents>>]" where <<class>> is the actual
    --  class of the Rope_Impl, <<address>> is the memory address of the Rope
    --  or Rope_Impl, and <<contents>> is the result of calling
    --  Impl_Text_Contents of the Rope_Impl. If Full is False, the contetns
    --  portion of the Rope_Impl is suppressed.
    function Rope_Text_Image (R : in Rope'Class) return String;
    function Impl_Text_Image (R : access constant Rope_Impl'Class; Full : Boolean := True) return String;

    --  Free the memory used by a Rope_Impl.
    procedure Free is
        new Ada.Unchecked_Deallocation (Rope_Impl'Class, Rope_Impl_Access);

    --  A String_Access type used whenever a String is referenced by a
    --  Rope_Impl.
    type String_Access is access String;
    for String_Access'Storage_Pool use Rope_Pool;

    --  Free the memory referenced by a String_Access.
    procedure Free is
        new Ada.Unchecked_Deallocation (String, String_Access);

end Ropes;
