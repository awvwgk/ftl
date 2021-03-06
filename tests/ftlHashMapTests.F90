! Copyright (c) 2016, 2017  Robert Rüger
!
! This file is part of of the Fortran Template Library.
!
! The Fortran Template Library is free software: you can redistribute it and/or
! modify it under the terms of the GNU Lesser General Public License as
! published by the Free Software Foundation, either version 3 of the License, or
! (at your option) any later version.
!
! The Fortran Template Library is distributed in the hope that it will be
! useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
! General Public License for more details.
!
! You should have received a copy of the GNU Lesser General Public License along
! with the Fortran Template Library.  If not, see <http://www.gnu.org/licenses/>.


#include "ftlTestTools.inc"

module ftlHashMapTestsModule

   use ftlKindsModule
   use ftlTestToolsModule
   use ftlHashMapStrIntModule
   use ftlStringModule
   use ftlHashMapStringIntModule

   implicit none
   private
   public :: ftlHashMapTests

contains


   subroutine ftlHashMapTests

      write (*,'(A)') 'Running ftlHashMap tests ...'

      ! Tests of the ftlHashMap container itself:

      call testNewDefault
      call testNewCopyOther
      call testAssignment
      call testClear
      call testSetAndGet
      call testRehash
      call testIterators
      call testFind
      call testEraseKey
      call testEraseIterators

      call testStringSpecialization

      call testArrayFinalization

   end subroutine


   subroutine testNewDefault
      type(ftlHashMapStrInt) :: um

      call um%New(100)

      ASSERT(um%Empty())
      ASSERT(um%Size() == 0)
      ASSERT(size(um) == 0)
      ASSERT(um%BucketCount() == 100)

   end subroutine


   subroutine testNewCopyOther
      type(ftlHashMapStrInt) :: um, copy

      call um%New(10)
      call um%Set('foo ', 42)
      call um%Set('bar ',  1)
      call um%Set('test',  2)
      call um%Set('blub',  3)
      call um%Set('jipi',  4)
      call um%Set('fort',  5)
      call um%Set('ran ',  6)
      call um%Set('is m',  7)
      call um%Set('y fa',  8)
      call um%Set('vour',  9)
      call um%Set('ite ', 10)
      call um%Set('lang', 11)
      call um%Set('not ', 12)
      call um%Set('rly!', 13)

      call copy%New(um)
      call um%Delete()

      ASSERT(copy%Size() == 14)
      ASSERT(size(copy) == 14)
      ASSERT(copy%Get('foo ') ==  42)
      ASSERT(copy%Get('bar ') ==  1)
      ASSERT(copy%Get('test') ==  2)
      ASSERT(copy%Get('blub') ==  3)
      ASSERT(copy%Get('jipi') ==  4)
      ASSERT(copy%Get('fort') ==  5)
      ASSERT(copy%Get('ran ') ==  6)
      ASSERT(copy%Get('not ') == 12)
      ASSERT(copy%Get('vour') ==  9)
      ASSERT(copy%Get('is m') ==  7)
      ASSERT(copy%Get('ite ') == 10)
      ASSERT(copy%Get('y fa') ==  8)
      ASSERT(copy%Get('lang') == 11)
      ASSERT(copy%Get('rly!') == 13)

      call copy%New(um)

      ASSERT(copy%Size() == 0)
      ASSERT(copy%Empty())

   end subroutine


   subroutine testAssignment
      type(ftlHashMapStrInt) :: um, copy

      call um%New(10)
      call um%Set('foo ', 42)
      call um%Set('bar ',  1)
      call um%Set('test',  2)
      call um%Set('blub',  3)
      call um%Set('jipi',  4)
      call um%Set('fort',  5)
      call um%Set('ran ',  6)
      call um%Set('is m',  7)
      call um%Set('y fa',  8)
      call um%Set('vour',  9)
      call um%Set('ite ', 10)
      call um%Set('lang', 11)
      call um%Set('not ', 12)
      call um%Set('rly!', 13)

      copy = um
      call um%Delete()

      ASSERT(copy%Size() == 14)
      ASSERT(size(copy) == 14)
      ASSERT(copy%Get('foo ') ==  42)
      ASSERT(copy%Get('bar ') ==  1)
      ASSERT(copy%Get('test') ==  2)
      ASSERT(copy%Get('blub') ==  3)
      ASSERT(copy%Get('jipi') ==  4)
      ASSERT(copy%Get('fort') ==  5)
      ASSERT(copy%Get('ran ') ==  6)
      ASSERT(copy%Get('not ') == 12)
      ASSERT(copy%Get('vour') ==  9)
      ASSERT(copy%Get('is m') ==  7)
      ASSERT(copy%Get('ite ') == 10)
      ASSERT(copy%Get('y fa') ==  8)
      ASSERT(copy%Get('lang') == 11)
      ASSERT(copy%Get('rly!') == 13)

      copy = um

      ASSERT(copy%Size() == 0)
      ASSERT(copy%Empty())

   end subroutine


   subroutine testClear
      type(ftlHashMapStrInt) :: um
      integer :: b

      call um%New(10)
      call um%Set('foo ', 42)
      call um%Set('bar ',  1)
      call um%Set('test',  2)
      call um%Set('blub',  3)
      call um%Set('jipi',  4)
      call um%Set('fort',  5)
      call um%Set('ran ',  6)
      call um%Set('is m',  7)
      call um%Set('y fa',  8)
      call um%Set('vour',  9)
      call um%Set('ite ', 10)
      call um%Set('lang', 11)
      call um%Set('not ', 12)
      call um%Set('rly!', 13)

      call um%Clear()

      ASSERT(um%Size() == 0)
      do b = 1, um%BucketCount()
         ASSERT(um%BucketSize(b) == 0)
      enddo

   end subroutine


   subroutine testSetAndGet
      type(ftlHashMapStrInt) :: um
      integer :: i
      integer, pointer :: ptr

      call um%New(10)

      call um%Set('foo ', 42)

      ASSERT(um%Size() == 1)
      ASSERT(size(um) == 1)

      ! add > 10 elements to have overfull buckets
      call um%Set('bar ',  1)
      call um%Set('test',  2)
      call um%Set('blub',  3)
      call um%Set('jipi',  4)
      call um%Set('fort',  5)
      call um%Set('ran ',  6)
      call um%Set('is m',  7)
      call um%Set('y fa',  8)
      call um%Set('vour',  9)
      call um%Set('ite ', 10)
      call um%Set('lang', 11)
      call um%Set('not ', 12)
      call um%Set('rly!', 13)

      ASSERT(um%Size() == 14)
      ASSERT(size(um) == 14)

      ! retrieve all entries again

      ptr => um%Get('foo ')

      ASSERT(associated(ptr))
      ASSERT(ptr == 42)

      ASSERT(um%Get('bar ') ==  1)
      ASSERT(um%Get('test') ==  2)
      ASSERT(um%Get('blub') ==  3)
      ASSERT(um%Get('jipi') ==  4)
      ASSERT(um%Get('fort') ==  5)
      ASSERT(um%Get('ran ') ==  6)
      ASSERT(um%Get('not ') == 12)
      ASSERT(um%Get('vour') ==  9)
      ASSERT(um%Get('is m') ==  7)
      ASSERT(um%Get('ite ') == 10)
      ASSERT(um%Get('y fa') ==  8)
      ASSERT(um%Get('lang') == 11)
      ASSERT(um%Get('rly!') == 13)

      ! try writing to pointers we got from Get()

      ptr = 82
      ASSERT(um%Get('foo ') == 82)

      ! try getting into a value type directly

      i = um%Get('blub')
      ASSERT(i == 3)
      i = 1337
      ASSERT(um%Get('blub') == 3)

      ! try setting the value for a key that already exists

      call um%Set('bar ',  -1)
      call um%Set('test',  -2)
      call um%Set('blub',  -3)
      call um%Set('jipi',  -4)
      call um%Set('fort',  -5)
      call um%Set('ran ',  -6)
      call um%Set('not ', -12)
      call um%Set('vour',  -9)
      call um%Set('is m',  -7)
      call um%Set('y fa',  -8)
      call um%Set('ite ', -10)
      call um%Set('lang', -11)
      call um%Set('rly!', -13)

      ASSERT(um%Get('bar ') ==  -1)
      ASSERT(um%Get('test') ==  -2)
      ASSERT(um%Get('blub') ==  -3)
      ASSERT(um%Get('jipi') ==  -4)
      ASSERT(um%Get('fort') ==  -5)
      ASSERT(um%Get('ran ') ==  -6)
      ASSERT(um%Get('not ') == -12)
      ASSERT(um%Get('vour') ==  -9)
      ASSERT(um%Get('is m') ==  -7)
      ASSERT(um%Get('y fa') ==  -8)
      ASSERT(um%Get('ite ') == -10)
      ASSERT(um%Get('lang') == -11)
      ASSERT(um%Get('rly!') == -13)

   end subroutine


   subroutine testRehash
      type(ftlHashMapStrInt) :: um

      call um%New(10)
      call um%SetMaxLoadFactor(1.0_FTL_KREAL)

      ASSERT(um%BucketCount() == 10)

      call um%Set('foo ',  0)
      call um%Set('bar ',  1)
      call um%Set('test',  2)
      call um%Set('blub',  3)
      call um%Set('jipi',  4)
      call um%Set('fort',  5)
      call um%Set('ran ',  6)
      call um%Set('is m',  7)
      call um%Set('y fa',  8)
      call um%Set('vour',  9)
      call um%Set('ite ', 10)
      call um%Set('lang', 11)
      call um%Set('not ', 12)
      call um%Set('rly!', 13)

      ASSERT(size(um) == 14)
      ASSERT(um%LoadFactor() < 1.0)
      ASSERT(um%BucketCount() > 10)

      call um%Rehash(5)

      ASSERT(size(um) == 14)
      ASSERT(um%BucketCount() == 5)

   end subroutine


   subroutine testIterators
      type(ftlHashMapStrInt) :: um
      type(ftlHashMapStrIntIterator) :: it
      integer :: i

      call um%New(10)

      call um%Set('test',  0)
      call um%Set('blub',  1)
      call um%Set('jipi',  2)
      call um%Set('fort',  3)
      call um%Set('ran ',  4)
      call um%Set('is m',  5)
      call um%Set('y fa',  6)
      call um%Set('vour',  7)
      call um%Set('ite ',  8)
      call um%Set('lang',  9)
      call um%Set('not ', 10)
      call um%Set('rly!', 11)

      call um%Rehash(10) ! make sure we have overfull buckets

      ASSERT(size(um) == 12)
      ASSERT(um%LoadFactor() > 1.0)
      ASSERT(um%BucketCount() == 10)

      it = um%Begin()
      do i = 1, 12
         ASSERT(it /= um%End())
         ASSERT(um%Has(it%key()))
         ASSERT(associated(um%Get(it%key())))
         ASSERT(um%Get(it%key()) == it%value)
         call it%Inc()
      enddo

      ASSERT(it == um%End())

   end subroutine


   subroutine testFind
      type(ftlHashMapStrInt) :: um

      call um%New(10)

      call um%Set('test',  0)
      call um%Set('blub',  1)
      call um%Set('jipi',  2)
      call um%Set('fort',  3)
      call um%Set('ran ',  4)
      call um%Set('is m',  5)
      call um%Set('y fa',  6)
      call um%Set('vour',  7)
      call um%Set('ite ',  8)
      call um%Set('lang',  9)
      call um%Set('not ', 10)
      call um%Set('rly!', 11)

      call um%Rehash(10) ! make sure we have overfull buckets

      ASSERT(um%Find('test') /= um%End())
      ASSERT(um%Find('blub') /= um%End())
      ASSERT(um%Find('jipi') /= um%End())
      ASSERT(um%Find('fort') /= um%End())
      ASSERT(um%Find('ran ') /= um%End())
      ASSERT(um%Find('is m') /= um%End())
      ASSERT(um%Find('y fa') /= um%End())
      ASSERT(um%Find('vour') /= um%End())
      ASSERT(um%Find('ite ') /= um%End())
      ASSERT(um%Find('lang') /= um%End())
      ASSERT(um%Find('not ') /= um%End())
      ASSERT(um%Find('rly!') /= um%End())

      ASSERT(um%Find('----') == um%End())

   end subroutine


   subroutine testEraseKey
      type(ftlHashMapStrInt) :: um

      call um%New(10)

      ASSERT(um%Empty())
      ASSERT(size(um) == 0)

      call um%Set('bar ',  1)
      call um%Set('test',  2)
      call um%Set('blub',  3)
      call um%Set('jipi',  4)
      call um%Set('fort',  5)
      call um%Set('ran ',  6)
      call um%Set('is m',  7)
      call um%Set('y fa',  8)
      call um%Set('vour',  9)
      call um%Set('ite ', 10)
      call um%Set('lang', 11)
      call um%Set('not ', 12)
      call um%Set('rly!', 13)

      ASSERT(size(um) == 13)

      call um%Erase('bar ')
      ASSERT(.not.um%Has('bar '))
      ASSERT(size(um) == 12)

      ! test double erase

      call um%Erase('bar ')
      ASSERT(.not.um%Has('bar '))
      ASSERT(size(um) == 12)

      ! erase all the rest

      call um%Erase('test')
      call um%Erase('blub')
      call um%Erase('jipi')
      call um%Erase('fort')
      call um%Erase('ran ')
      call um%Erase('is m')
      call um%Erase('y fa')
      call um%Erase('vour')
      call um%Erase('ite ')
      call um%Erase('lang')
      call um%Erase('not ')
      call um%Erase('rly!')

      ASSERT(.not.um%Has('test'))
      ASSERT(.not.um%Has('blub'))
      ASSERT(.not.um%Has('jipi'))
      ASSERT(.not.um%Has('fort'))
      ASSERT(.not.um%Has('ran '))
      ASSERT(.not.um%Has('is m'))
      ASSERT(.not.um%Has('y fa'))
      ASSERT(.not.um%Has('vour'))
      ASSERT(.not.um%Has('ite '))
      ASSERT(.not.um%Has('lang'))
      ASSERT(.not.um%Has('not '))
      ASSERT(.not.um%Has('rly!'))

      ASSERT(um%Empty())
      ASSERT(size(um) == 0)

   end subroutine


   subroutine testEraseIterators
      type(ftlHashMapStrInt) :: um
      type(ftlHashMapStrIntIterator) :: it

      call um%New(10)

      call um%Set('test',  0)
      call um%Set('blub',  1)
      call um%Set('jipi',  2)
      call um%Set('fort',  3)
      call um%Set('ran ',  4)
      call um%Set('is m',  5)
      call um%Set('y fa',  6)
      call um%Set('vour',  7)
      call um%Set('ite ',  8)
      call um%Set('lang',  9)
      call um%Set('not ', 10)
      call um%Set('rly!', 11)

      call um%Rehash(10) ! make sure we have overfull buckets

      ASSERT(size(um) == 12)

      ASSERT(um%Has('test'))
      call um%Erase('test')
      ASSERT(.not.um%Has('test'))

      ASSERT(size(um) == 11)

      ASSERT(um%Has('fort'))
      it = um%Find('fort')
      call um%Erase(it)
      ASSERT(.not.um%Has('fort'))

      ASSERT(size(um) == 10)

      it = um%Begin()
      call it%Inc()
      call it%Inc()
      call um%Erase(it, um%End())

      ASSERT(size(um) == 2)

   end subroutine


   subroutine testStringSpecialization
      type(ftlHashMapStringInt) :: um

      call um%New(10)

      call um%Set('this', 1)
      call um%Set('is', 12)
      call um%Set('a', 21)
      call um%Set('test', 114)
      call um%Set('with', 1)
      call um%Set('variable', 145)
      call um%Set('length', 7)
      call um%Set('keys!', 9)

      ASSERT(um%Has('this'))
      ASSERT(um%Has('is'))
      ASSERT(um%Has('a'))
      ASSERT(um%Has('test'))
      ASSERT(um%Has('with'))
      ASSERT(um%Has('variable'))
      ASSERT(um%Has('length'))
      ASSERT(um%Has('keys!'))
      ASSERT(.not.um%Has('not there'))

      ASSERT(um%Get('this') == 1)
      ASSERT(um%Get('is') == 12)
      ASSERT(um%Get('a') == 21)
      ASSERT(um%Get('test') == 114)
      ASSERT(um%Get('with') == 1)
      ASSERT(um%Get('variable') == 145)
      ASSERT(um%Get('length') == 7)
      ASSERT(um%Get('keys!') == 9)

      ASSERT(um%Find('with') /= um%End())
      call um%Erase('with')
      ASSERT(um%Find('with') == um%End())

   end subroutine


   subroutine testArrayFinalization
      type(ftlHashMapStringInt) :: um(2)

      call um(1)%New(10)
      call um(1)%Set('this', 1)
      call um(1)%Set('is', 12)
      call um(1)%Set('a', 21)
      call um(1)%Set('test', 114)
      ASSERT('this' .in. um(1))

      call um(2)%New(10)
      call um(2)%Set('bla blub', 1)
      call um(2)%Set('here', 8)
      call um(2)%Set('another', 26)
      call um(2)%Set('test', 107)
      ASSERT('here' .in. um(2))

      ! This subroutine should not leak. Check with 'make memtest'

   end subroutine

end module
