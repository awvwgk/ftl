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

module ftlDynArrayTestsModule

   use ftlTestToolsModule
   use ftlDynArrayIntModule
   use ftlDynArrayLeakyModule
   use ftlDynArrayMovableLeakyModule
   use LeakyModule

   implicit none
   private
   public :: ftlDynArrayTests

contains


   subroutine ftlDynArrayTests

      write (*,'(A)') 'Running ftlDynArray tests ...'

      ! Tests of the ftlDynArray container itself:

      call testNewDefault
      call testNewCopyOther
      call testNewFill
      call testNewFromArray

      call testAssignment

      call testDelete

      call testBegin
      call testEnd

      call testSizeAndCapacity
      call testResize
      call testEmpty
      call testReserve
      call testShrinkToFit

      call testPushBack
      call testPopBack

      ! TODO: test insertion methods that take an iterator as position
      call testInsertSingle
      call testInsertFill
      call testInsertArray
      call testInsertIteratorPair

      call testEraseSingle
      call testEraseRange

      call testClear

      call testSwap
      call testMove

      ! Tests of its iterators:

      call testNewItDefault
      call testNewItCopyOther

      call testInc
      call testDec

      call testAdvanceReverseDiff
      call testLogicalOperations

      ! Tests with a type that needs to be cleaned up through a finalizer

      call testLeakyResize
      call testLeakyReserveAndShrinkToFit

      call testLeakyPushBack
      call testLeakyPopBack

      call testLeakyEraseSingle
      call testLeakyEraseRange

      call testLeakySwap
      call testLeakyMove

      ! Tests with a movable type that needs to be cleaned up through a finalizer

      call testMovableLeakyResize
      call testMovableLeakyReserveAndShrinkToFit

      call testMovableLeakyPushBack
      call testMovableLeakyPopBack

      call testMovableLeakyEraseSingle
      call testMovableLeakyEraseRange

      call testMovableLeakySwap
      call testMovableLeakyMove

   end subroutine


   subroutine testNewDefault
      type(ftlDynArrayInt) :: v

      call v%New()

      ASSERT(v%Empty())
      ASSERT(v%Size() == 0)
      ASSERT(Size(v) == 0)
      ASSERT(size(v%data) == 0)
      ASSERT(v%Begin() == v%End())
      ASSERT(.not.(v%Begin() /= v%End()))

   end subroutine


   subroutine testNewCopyOther
      type(ftlDynArrayInt) :: v,o,uninit

      call o%New([5,13,41,97,17,10,88])
      call v%New(o)

      ASSERT(.not.v%Empty())
      ASSERT(v%Size() == 7)
      ASSERT(Size(v) == 7)
      ASSERT(size(v%data) == 7)
      ASSERT(all(v%data == [5,13,41,97,17,10,88]))
      ASSERT(v%front == 5)
      ASSERT(v%back == 88)
      ASSERT(v%End() - v%Begin() == 7)
      ASSERT(.not.associated(o%data,v%data))
      ASSERT(.not.associated(o%front,v%front))
      ASSERT(.not.associated(o%back,v%back))

      call v%New(uninit)

      ASSERT(v%Empty())
      ASSERT(v%Size() == 0)
      ASSERT(Size(v) == 0)
      ASSERT(size(v%data) == 0)
      ASSERT(.not.associated(v%front))
      ASSERT(.not.associated(v%back))
      ASSERT(v%End() == v%Begin())
      ASSERT(v%Capacity() == 0)

   end subroutine


   subroutine testNewFill
      type(ftlDynArrayInt) :: u,v

      call u%New(33)

      ASSERT(u%Size() == 33)
      ASSERT(Size(u) == 33)
      ASSERT(size(u%data) == 33)

      call v%New(5,41)

      ASSERT(.not.v%Empty())
      ASSERT(v%Size() == 5)
      ASSERT(Size(v) == 5)
      ASSERT(size(v%data) == 5)
      ASSERT(all(v%data == [41,41,41,41,41]))
      ASSERT(v%front == 41)
      ASSERT(v%back == 41)
      ASSERT(v%End() - v%Begin() == 5)

   end subroutine


   subroutine testNewFromArray
      type(ftlDynArrayInt) :: v

      call v%New([5,13,41,97,17,10,88])

      ASSERT(.not.v%Empty())
      ASSERT(v%Size() == 7)
      ASSERT(Size(v) == 7)
      ASSERT(size(v%data) == 7)
      ASSERT(all(v%data == [5,13,41,97,17,10,88]))
      ASSERT(v%front == 5)
      ASSERT(v%back == 88)
      ASSERT(v%End() - v%Begin() == 7)

   end subroutine


   subroutine testAssignment
      type(ftlDynArrayInt) :: v1, v2, v3, uninit
      integer, allocatable :: a(:)

      v1 = [5,13,41,97,17,10,88]

      ASSERT(.not.v1%Empty())
      ASSERT(v1%Size() == 7)
      ASSERT(Size(v1) == 7)
      ASSERT(size(v1%data) == 7)
      ASSERT(all(v1%data == [5,13,41,97,17,10,88]))
      ASSERT(v1%front == 5)
      ASSERT(v1%back == 88)
      ASSERT(v1%End() - v1%Begin() == 7)

      v2 = v1

      ASSERT(.not.v2%Empty())
      ASSERT(v2%Size() == 7)
      ASSERT(Size(v2) == 7)
      ASSERT(size(v2%data) == 7)
      ASSERT(all(v2%data == [5,13,41,97,17,10,88]))
      ASSERT(v2%front == 5)
      ASSERT(v2%back == 88)
      ASSERT(v2%End() - v2%Begin() == 7)

      v1 = [1,2]

      ASSERT(.not.v1%Empty())
      ASSERT(v1%Size() == 2)
      ASSERT(Size(v1) == 2)
      ASSERT(size(v1%data) == 2)
      ASSERT(all(v1%data == [1,2]))
      ASSERT(v1%front == 1)
      ASSERT(v1%back == 2)
      ASSERT(v1%End() - v1%Begin() == 2)
      ASSERT(v1%Capacity() == 7) ! no reallocation on smaller assignment

      allocate(a(0))

      v1 = a

      ASSERT(v1%Empty())
      ASSERT(v1%Size() == 0)
      ASSERT(Size(v1) == 0)
      ASSERT(size(v1%data) == 0)
      ASSERT(v1%End() == v1%Begin())
      ASSERT(v1%Capacity() == 7) ! no reallocation on smaller assignment

      v3 = a ! assignment of 0 sized array to something that wasn't constructed before ...
             ! ... don't ask ... yes, that happens ...

      ASSERT(v3%Empty())
      ASSERT(v3%Size() == 0)
      ASSERT(Size(v3) == 0)
      ASSERT(size(v3%data) == 0)
      ASSERT(v3%End() == v3%Begin())

      v2 = uninit ! assigning an uninitialized dynArray is equivalent to deleting ...

      ASSERT(.not.associated(v2%data))
      ASSERT(.not.associated(v2%front))
      ASSERT(.not.associated(v2%back))

   end subroutine


   subroutine testDelete
      type(ftlDynArrayInt) :: v

      call v%New([5,13,41,97,17,10,88])
      call v%Delete()

      ASSERT(.not.associated(v%data))
      ASSERT(.not.associated(v%front))
      ASSERT(.not.associated(v%back))

   end subroutine


   subroutine testBegin
      type(ftlDynArrayInt) :: v
      type(ftlDynArrayIntIterator) :: it

      call v%New([4,6,38,216,48468,3,2,67,9])
      it = v%Begin()

      ASSERT(associated(it%value,v%data(1)))
      ASSERT(associated(it%value,v%front))
      ASSERT(it%value == 4)
      ASSERT(it%value == v%front)

   end subroutine


   subroutine testEnd
      type(ftlDynArrayInt) :: v
      type(ftlDynArrayIntIterator) :: it

      call v%New([4,6,38,216,48468,3,2,67,27])
      it = v%End()
      call it%Dec()

      ASSERT(associated(it%value,v%data(9)))
      ASSERT(associated(it%value,v%back))
      ASSERT(it%value == 27)
      ASSERT(it%value == v%back)

   end subroutine


   subroutine testSizeAndCapacity
      type(ftlDynArrayInt) :: v
      integer            :: i

      call v%New()

      ASSERT(v%Size() == 0)
      ASSERT(v%Capacity() >= 0)

      do i = 1, 32
         call v%PushBack(i)
         ASSERT(v%Size() == i)
         ASSERT(v%Capacity() >= i)
      enddo

   end subroutine


   subroutine testResize
      type(ftlDynArrayInt) :: v

      call v%New([246,57,2,6,7,38,245,2,6274,446])
      call v%Resize(20,1)

      ASSERT(v%Size() == 20)
      ASSERT(Size(v) == 20)
      ASSERT(size(v%data) == 20)
      ASSERT(all(v%data(1:10) == [246,57,2,6,7,38,245,2,6274,446]))
      ASSERT(all(v%data(11:20) == [1,1,1,1,1,1,1,1,1,1]))
      ASSERT(v%front == 246)
      ASSERT(associated(v%front,v%data(1)))
      ASSERT(v%back == 1)
      ASSERT(associated(v%back,v%data(20)))

   end subroutine


   subroutine testEmpty
      type(ftlDynArrayInt) :: v

      call v%New()
      ASSERT(v%Empty())
      call v%Insert(1,[7,8,9])
      ASSERT(.not.v%Empty())
      call v%Clear()
      ASSERT(v%Empty())

   end subroutine


   subroutine testReserve
      type(ftlDynArrayInt) :: v

      call v%New([4,5,6,7])
      call v%Reserve(50)

      ASSERT(v%Capacity() >= 50)
      ASSERT(v%front == 4)
      ASSERT(v%back == 7)

      call v%Reserve(30)

      ASSERT(v%Capacity() >= 50)
      ASSERT(v%front == 4)
      ASSERT(v%back == 7)

   end subroutine


   subroutine testShrinkToFit
      type(ftlDynArrayInt) :: v

      call v%New([4,5,6,7])
      call v%Reserve(50)

      ASSERT(v%Capacity() >= 50)
      ASSERT(v%front == 4)
      ASSERT(v%back == 7)

      call v%PushBack(9)
      call v%ShrinkToFit()

      ASSERT(v%Capacity() == 5)
      ASSERT(v%front == 4)
      ASSERT(v%back == 9)

   end subroutine


   subroutine testPushBack
      type(ftlDynArrayInt) :: v
      integer            :: i

      call v%New()
      do i = 1, 32
         call v%PushBack(i)
         ASSERT(v%back == i)
      enddo

   end subroutine


   subroutine testPopBack
      type(ftlDynArrayInt) :: v

      call v%New([4,62,78,836,3])
      ASSERT(v%PopBack() == 3)
      ASSERT(v%PopBack() == 836)
      ASSERT(v%PopBack() == 78)
      ASSERT(v%PopBack() == 62)
      ASSERT(v%PopBack() == 4)
      ASSERT(v%Empty())

   end subroutine


   subroutine testInsertSingle
      type(ftlDynArrayInt) :: v

      call v%New([4,6,8,3,737])

      call v%Insert(2,1)
      ASSERT(v%Size() == 6)
      ASSERT(all(v%data == [4,1,6,8,3,737]))

      call v%Insert(1,320)
      ASSERT(v%Size() == 7)
      ASSERT(v%front == 320)
      ASSERT(all(v%data == [320,4,1,6,8,3,737]))

      call v%Insert(8,29)
      ASSERT(v%Size() == 8)
      ASSERT(v%back == 29)
      ASSERT(all(v%data == [320,4,1,6,8,3,737,29]))

   end subroutine


   subroutine testInsertFill
      type(ftlDynArrayInt) :: v

      call v%New([4,6,8,3,737])

      call v%Insert(2,3,1)
      ASSERT(v%Size() == 8)
      ASSERT(all(v%data == [4,1,1,1,6,8,3,737]))

      call v%Insert(1,2,320)
      ASSERT(v%Size() == 10)
      ASSERT(v%front == 320)
      ASSERT(all(v%data == [320,320,4,1,1,1,6,8,3,737]))

      call v%Insert(11,5,29)
      ASSERT(v%Size() == 15)
      ASSERT(v%back == 29)
      ASSERT(all(v%data == [320,320,4,1,1,1,6,8,3,737,29,29,29,29,29]))

   end subroutine


   subroutine testInsertArray
      type(ftlDynArrayInt) :: v

      call v%New([4,6,8,3,737])

      call v%Insert(2,[8,9,1])
      ASSERT(v%Size() == 8)
      ASSERT(all(v%data == [4,8,9,1,6,8,3,737]))

      call v%Insert(1,[320,321])
      ASSERT(v%Size() == 10)
      ASSERT(v%front == 320)
      ASSERT(all(v%data == [320,321,4,8,9,1,6,8,3,737]))

      call v%Insert(11,[29,30,31,32,33])
      ASSERT(v%Size() == 15)
      ASSERT(v%back == 33)
      ASSERT(all(v%data == [320,321,4,8,9,1,6,8,3,737,29,30,31,32,33]))

   end subroutine


   subroutine testInsertIteratorPair
      type(ftlDynArrayInt) :: v, o

      call o%New([2,3,4])
      call v%New([1,5])
      call v%Insert(2, o%Begin(), o%End())

      ASSERT(v%Size() == 5)
      ASSERT(all(v%data == [1,2,3,4,5]))

   end subroutine


   subroutine testEraseSingle
      type(ftlDynArrayInt) :: v

      call v%New([3,6,12,-4,733])

      call v%Erase(2)
      ASSERT(v%Size() == 4)
      ASSERT(all(v%data == [3,12,-4,733]))

      call v%Erase(1)
      ASSERT(v%Size() == 3)
      ASSERT(v%front == 12)
      ASSERT(all(v%data == [12,-4,733]))

      call v%Erase(3)
      ASSERT(v%Size() == 2)
      ASSERT(v%back == -4)
      ASSERT(all(v%data == [12,-4]))

   end subroutine


   subroutine testEraseRange
      type(ftlDynArrayInt) :: v

      call v%New([1,-5,2,5126,-356,33,823,3,1,2])

      call v%Erase(2,5)
      ASSERT(v%Size() == 7)
      ASSERT(all(v%data == [1,-356,33,823,3,1,2]))

      call v%Erase(1,3)
      ASSERT(v%Size() == 5)
      ASSERT(v%front == 33)
      ASSERT(all(v%data == [33,823,3,1,2]))

      call v%Erase(4,6)
      ASSERT(v%Size() == 3)
      ASSERT(v%back == 3)
      ASSERT(all(v%data == [33,823,3]))

   end subroutine


   subroutine testClear
      type(ftlDynArrayInt) :: v

      call v%New([1,-5,2,5126,-356,33,823,3,1,2])
      call v%Clear()

      ASSERT(v%Empty())
      ASSERT(v%Size() == 0)

   end subroutine


   subroutine testSwap
      type(ftlDynArrayInt) :: v, u, uninit

      v = [42,34,67,8,3,5]
      u = [3,4,41,2]

      call ftlSwap(v,u)

      ASSERT(all(v%data == [3,4,41,2]))
      ASSERT(size(v) == 4)
      ASSERT(v%front == 3)
      ASSERT(v%back == 2)
      ASSERT(all(u%data == [42,34,67,8,3,5]))
      ASSERT(size(u) == 6)
      ASSERT(u%front == 42)
      ASSERT(u%back == 5)

      call ftlSwap(v, uninit)

      ASSERT(v%Empty())
      ASSERT(all(uninit%data == [3,4,41,2]))
      ASSERT(size(uninit) == 4)
      ASSERT(uninit%front == 3)
      ASSERT(uninit%back == 2)

   end subroutine


   subroutine testMove
      type(ftlDynArrayInt) :: v, u, uninit
      integer, allocatable :: raw(:)

      v = [42,34,67,8,3,5]
      u = [3,4,41,2]

      call ftlMove(v, u)

      ASSERT(size(v) == 0)
      ASSERT(.not.associated(v%data))
      ASSERT(all(u%data == [42,34,67,8,3,5]))
      ASSERT(size(u) == 6)
      ASSERT(u%front == 42)
      ASSERT(u%back == 5)

      call ftlMove(uninit, u)

      ASSERT(size(u) == 0)
      ASSERT(.not.associated(u%data))

      raw = [1,2,3,4,5]
      call ftlMove(raw, v)

      ASSERT(.not.allocated(raw))
      ASSERT(all(v%data == [1,2,3,4,5]))
      ASSERT(size(v) == 5)
      ASSERT(v%front == 1)
      ASSERT(v%back == 5)

   end subroutine


   subroutine testNewItDefault
      type(ftlDynArrayIntIterator) :: it

      call it%New()
      ASSERT(.not.associated(it%value))

   end subroutine


   subroutine testNewItCopyOther
      type(ftlDynArrayInt) :: v
      type(ftlDynArrayIntIterator) :: it1, it2

      call v%New([353,6,5,2,2274,33])
      it1 = v%Begin()
      call it2%New(it1)

      ASSERT(associated(it1%value,it2%value))
      ASSERT(it2%value == 353)

   end subroutine


   subroutine testInc
      type(ftlDynArrayInt) :: v
      type(ftlDynArrayIntIterator) :: it

      call v%New([353,6,5,2,2274,33])
      it = v%Begin()

      ASSERT(associated(it%value,v%data(1)))
      ASSERT(it%value == 353)

      call it%Inc()

      ASSERT(associated(it%value,v%data(2)))
      ASSERT(it%value == 6)

   end subroutine


   subroutine testDec
      type(ftlDynArrayInt) :: v
      type(ftlDynArrayIntIterator) :: it

      call v%New([353,6,5,2,2274,33])
      it = v%End()
      call it%Dec()

      ASSERT(associated(it%value,v%data(6)))
      ASSERT(it%value == 33)

      call it%Dec()

      ASSERT(associated(it%value,v%data(5)))
      ASSERT(it%value == 2274)

   end subroutine


   subroutine testAdvanceReverseDiff
      type(ftlDynArrayInt) :: v
      type(ftlDynArrayIntIterator) :: it1, it2

      call v%New([353,6,5,2,2274,33])
      it1 = v%Begin()
      it2 = it1 + 4

      ASSERT(it2 - it1 == 4)
      ASSERT(associated(it2%value,v%data(5)))
      ASSERT(it2%value == 2274)

      it2 = it2 - 2
      ASSERT(it2 - it1 == 2)
      ASSERT(associated(it2%value,v%data(3)))
      ASSERT(it2%value == 5)

   end subroutine


   subroutine testLogicalOperations
      type(ftlDynArrayInt) :: v
      type(ftlDynArrayIntIterator) :: it1, it2

      call v%New([4,7,3,6,8])
      it1 = v%Begin() + 2
      ASSERT(it1%value == 3)
      it2 = v%Begin()

      ASSERT(it2%value == 4)
      ASSERT(.not.(it2 == it1))
      ASSERT(     (it2 /= it1))
      ASSERT(     (it2 <  it1))
      ASSERT(     (it2 <= it1))
      ASSERT(.not.(it2 >  it1))
      ASSERT(.not.(it2 >= it1))

      call it2%Inc()

      ASSERT(it2%value == 7)
      ASSERT(.not.(it2 == it1))
      ASSERT(     (it2 /= it1))
      ASSERT(     (it2 <  it1))
      ASSERT(     (it2 <= it1))
      ASSERT(.not.(it2 >  it1))
      ASSERT(.not.(it2 >= it1))

      call it2%Inc()

      ASSERT(it2%value == 3)
      ASSERT(     (it2 == it1))
      ASSERT(.not.(it2 /= it1))
      ASSERT(.not.(it2 <  it1))
      ASSERT(     (it2 <= it1))
      ASSERT(.not.(it2 >  it1))
      ASSERT(     (it2 >= it1))

      call it2%Inc()

      ASSERT(it2%value == 6)
      ASSERT(.not.(it2 == it1))
      ASSERT(     (it2 /= it1))
      ASSERT(.not.(it2 <  it1))
      ASSERT(.not.(it2 <= it1))
      ASSERT(     (it2 >  it1))
      ASSERT(     (it2 >= it1))

      call it2%Inc()

      ASSERT(it2%value == 8)
      ASSERT(.not.(it2 == it1))
      ASSERT(     (it2 /= it1))
      ASSERT(.not.(it2 <  it1))
      ASSERT(.not.(it2 <= it1))
      ASSERT(     (it2 >  it1))
      ASSERT(     (it2 >= it1))

      call it2%Inc()

      ASSERT(it2 == v%End())

   end subroutine


   ! Tests with a type that needs to be cleaned up through a finalizer


   subroutine testLeakyResize
      type(ftlDynArrayLeaky) :: v

      call v%New(1)
      call v%data(1)%New('first', 1000)
      call v%Resize(2)

      ASSERT(v%data(1)%name == 'first')
      ASSERT(size(v%data(1)%dontLeakMe) == 1000)

   end subroutine


   subroutine testLeakyReserveAndShrinkToFit
      type(ftlDynArrayLeaky) :: v

      call v%New(3)
      call v%data(1)%New('first', 1000)
      call v%data(2)%New('second', 2000)
      call v%Reserve(6)
      call v%data(3)%New('third', 3000)

      ASSERT(v%Capacity() == 6)

      call v%ShrinkToFit()

      ASSERT(v%Capacity() == 3)
      ASSERT(v%front%name == 'first')
      ASSERT(v%back%name  == 'third')
      ASSERT(size(v) == 3)

   end subroutine


   subroutine testLeakyPushBack
      type(ftlDynArrayLeaky) :: v
      type(LeakyType) :: l
      integer :: i

      call v%New()
      do i = 1, 32
         call l%New('bla', i)
         call v%PushBack(l)
         ASSERT(size(v%back%dontLeakMe) == i)
      enddo

   end subroutine


   subroutine testLeakyPopBack
      type(ftlDynArrayLeaky) :: v
      type(LeakyType) :: l

      call v%New(3)
      call v%data(1)%New('first', 1000)
      call v%data(2)%New('second', 2000)
      call v%data(3)%New('third', 3000)

      ASSERT(v%Size() == 3)
      ASSERT(v%back%name == 'third')

      l = v%PopBack()

      ASSERT(l%name == 'third')
      ASSERT(v%Size() == 2)
      ASSERT(v%back%name == 'second')

      l = v%PopBack()

      ASSERT(l%name == 'second')
      ASSERT(v%Size() == 1)
      ASSERT(v%back%name == 'first')

      l = v%PopBack()

      ASSERT(l%name == 'first')
      ASSERT(v%Size() == 0)

      ! This subroutine leaks with gfortran in the moments. I think the reason is that gfortran does not yet implement
      ! finalization of temporaries, see: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=37336#c27
      ! TODO: Workaround?

   end subroutine


   subroutine testLeakyEraseSingle
      type(ftlDynArrayLeaky) :: v

      call v%New(3)
      call v%data(1)%New('first', 1000)
      call v%data(2)%New('second', 2000)
      call v%data(3)%New('third', 3000)

      ASSERT(v%Size() == 3)

      call v%Erase(2)

      ASSERT(v%Size() == 2)
      ASSERT(v%back%name == 'third')

   end subroutine


   subroutine testLeakyEraseRange
      type(ftlDynArrayLeaky) :: v

      call v%New(10)
      call v%data( 1)%New('first'  ,  1000)
      call v%data( 2)%New('second' ,  2000)
      call v%data( 3)%New('third'  ,  3000)
      call v%data( 4)%New('fourth' ,  4000)
      call v%data( 5)%New('fifth'  ,  5000)
      call v%data( 6)%New('sixth'  ,  6000)
      call v%data( 7)%New('seventh',  7000)
      call v%data( 8)%New('eighth' ,  8000)
      call v%data( 9)%New('nineth' ,  9000)
      call v%data(10)%New('tenth'  , 10000)

      call v%Erase(2,5)
      ASSERT(v%Size() == 7)
      ASSERT(v%data(1)%name == 'first')
      ASSERT(size(v%data(1)%dontLeakMe) == 1000)
      ASSERT(v%data(2)%name == 'fifth')
      ASSERT(size(v%data(2)%dontLeakMe) == 5000)
      ASSERT(v%back%name == 'tenth')
      ASSERT(size(v%back%dontLeakMe) == 10000)

      call v%Erase(1,3)
      ASSERT(v%Size() == 5)
      ASSERT(v%front%name == 'sixth')
      ASSERT(size(v%front%dontLeakMe) == 6000)
      ASSERT(v%data(2)%name == 'seventh')
      ASSERT(size(v%data(2)%dontLeakMe) == 7000)
      ASSERT(v%back%name == 'tenth')
      ASSERT(size(v%back%dontLeakMe) == 10000)

      call v%Erase(4,6)
      ASSERT(v%Size() == 3)
      ASSERT(v%data(1)%name == 'sixth')
      ASSERT(v%data(2)%name == 'seventh')
      ASSERT(v%data(3)%name == 'eighth')

   end subroutine


   subroutine testLeakySwap
      type(ftlDynArrayLeaky) :: v, u, uninit

      call v%New(3)
      call v%data( 1)%New('A_first' , 1000)
      call v%data( 2)%New('A_second', 2000)
      call v%data( 3)%New('A_third' , 3000)

      call u%New(2)
      call u%data( 1)%New('B_first' , 10000)
      call u%data( 2)%New('B_second', 20000)

      call ftlSwap(v,u)

      ASSERT(v%data(1)%name == 'B_first')
      ASSERT(size(v) == 2)
      ASSERT(v%front%name == 'B_first')
      ASSERT(v%back%name == 'B_second')
      ASSERT(u%data(2)%name == 'A_second')
      ASSERT(size(u) == 3)
      ASSERT(u%front%name == 'A_first')
      ASSERT(u%back%name == 'A_third')

      call ftlSwap(v, uninit)

      ASSERT(v%Empty())
      ASSERT(uninit%data(1)%name == 'B_first')
      ASSERT(size(uninit) == 2)
      ASSERT(uninit%front%name == 'B_first')
      ASSERT(uninit%back%name == 'B_second')

   end subroutine


   subroutine testLeakyMove
      type(ftlDynArrayLeaky) :: v, u, uninit

      call v%New(3)
      call v%data( 1)%New('A_first' , 1000)
      call v%data( 2)%New('A_second', 2000)
      call v%data( 3)%New('A_third' , 3000)

      call u%New(2)
      call u%data( 1)%New('B_first' , 10000)
      call u%data( 2)%New('B_second', 20000)

      call ftlMove(v, u)

      ASSERT(size(v) == 0)
      ASSERT(.not.associated(v%data))
      ASSERT(u%data(2)%name == 'A_second')
      ASSERT(size(u) == 3)
      ASSERT(u%front%name == 'A_first')
      ASSERT(u%back%name == 'A_third')

      call ftlMove(uninit, u)

      ASSERT(size(u) == 0)
      ASSERT(.not.associated(u%data))

   end subroutine


   ! Tests with a movable type that needs to be cleaned up through a finalizer


   subroutine testMovableLeakyResize
      type(ftlDynArrayMovableLeaky) :: v

      call v%New(1)
      call v%data(1)%New('first', 1000)
      call v%Resize(2)

      ASSERT(v%data(1)%name == 'first')
      ASSERT(size(v%data(1)%dontLeakMe) == 1000)

   end subroutine


   subroutine testMovableLeakyReserveAndShrinkToFit
      type(ftlDynArrayMovableLeaky) :: v

      call v%New(3)
      call v%data(1)%New('first', 1000)
      call v%data(2)%New('second', 2000)
      call v%Reserve(6)
      call v%data(3)%New('third', 3000)

      ASSERT(v%Capacity() == 6)

      call v%ShrinkToFit()

      ASSERT(v%Capacity() == 3)
      ASSERT(v%front%name == 'first')
      ASSERT(v%back%name  == 'third')
      ASSERT(size(v) == 3)

   end subroutine


   subroutine testMovableLeakyPushBack
      type(ftlDynArrayMovableLeaky) :: v
      type(LeakyType) :: l
      integer :: i

      call v%New()
      do i = 1, 32
         call l%New('bla', i)
         call v%PushBack(l)
         ASSERT(size(v%back%dontLeakMe) == i)
      enddo

   end subroutine


   subroutine testMovableLeakyPopBack
      type(ftlDynArrayMovableLeaky) :: v
      type(LeakyType) :: l

      call v%New(3)
      call v%data(1)%New('first', 1000)
      call v%data(2)%New('second', 2000)
      call v%data(3)%New('third', 3000)

      ASSERT(v%Size() == 3)
      ASSERT(v%back%name == 'third')

      l = v%PopBack()

      ASSERT(l%name == 'third')
      ASSERT(v%Size() == 2)
      ASSERT(v%back%name == 'second')

      l = v%PopBack()

      ASSERT(l%name == 'second')
      ASSERT(v%Size() == 1)
      ASSERT(v%back%name == 'first')

      l = v%PopBack()

      ASSERT(l%name == 'first')
      ASSERT(v%Size() == 0)

      ! This subroutine leaks with gfortran in the moments. I think the reason is that gfortran does not yet implement
      ! finalization of temporaries, see: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=37336#c27
      ! TODO: Workaround?

   end subroutine


   subroutine testMovableLeakyEraseSingle
      type(ftlDynArrayMovableLeaky) :: v

      call v%New(3)
      call v%data(1)%New('first', 1000)
      call v%data(2)%New('second', 2000)
      call v%data(3)%New('third', 3000)

      ASSERT(v%Size() == 3)

      call v%Erase(2)

      ASSERT(v%Size() == 2)
      ASSERT(v%back%name == 'third')

   end subroutine


   subroutine testMovableLeakyEraseRange
      type(ftlDynArrayMovableLeaky) :: v

      call v%New(10)
      call v%data( 1)%New('first'  ,  1000)
      call v%data( 2)%New('second' ,  2000)
      call v%data( 3)%New('third'  ,  3000)
      call v%data( 4)%New('fourth' ,  4000)
      call v%data( 5)%New('fifth'  ,  5000)
      call v%data( 6)%New('sixth'  ,  6000)
      call v%data( 7)%New('seventh',  7000)
      call v%data( 8)%New('eighth' ,  8000)
      call v%data( 9)%New('nineth' ,  9000)
      call v%data(10)%New('tenth'  , 10000)

      call v%Erase(2,5)
      ASSERT(v%Size() == 7)
      ASSERT(v%data(1)%name == 'first')
      ASSERT(size(v%data(1)%dontLeakMe) == 1000)
      ASSERT(v%data(2)%name == 'fifth')
      ASSERT(size(v%data(2)%dontLeakMe) == 5000)
      ASSERT(v%back%name == 'tenth')
      ASSERT(size(v%back%dontLeakMe) == 10000)

      call v%Erase(1,3)
      ASSERT(v%Size() == 5)
      ASSERT(v%front%name == 'sixth')
      ASSERT(size(v%front%dontLeakMe) == 6000)
      ASSERT(v%data(2)%name == 'seventh')
      ASSERT(size(v%data(2)%dontLeakMe) == 7000)
      ASSERT(v%back%name == 'tenth')
      ASSERT(size(v%back%dontLeakMe) == 10000)

      call v%Erase(4,6)
      ASSERT(v%Size() == 3)
      ASSERT(v%data(1)%name == 'sixth')
      ASSERT(v%data(2)%name == 'seventh')
      ASSERT(v%data(3)%name == 'eighth')

   end subroutine


   subroutine testMovableLeakySwap
      type(ftlDynArrayMovableLeaky) :: v, u, uninit

      call v%New(3)
      call v%data( 1)%New('A_first' , 1000)
      call v%data( 2)%New('A_second', 2000)
      call v%data( 3)%New('A_third' , 3000)

      call u%New(2)
      call u%data( 1)%New('B_first' , 10000)
      call u%data( 2)%New('B_second', 20000)

      call ftlSwap(v,u)

      ASSERT(v%data(1)%name == 'B_first')
      ASSERT(size(v) == 2)
      ASSERT(v%front%name == 'B_first')
      ASSERT(v%back%name == 'B_second')
      ASSERT(u%data(2)%name == 'A_second')
      ASSERT(size(u) == 3)
      ASSERT(u%front%name == 'A_first')
      ASSERT(u%back%name == 'A_third')

      call ftlSwap(v, uninit)

      ASSERT(v%Empty())
      ASSERT(uninit%data(1)%name == 'B_first')
      ASSERT(size(uninit) == 2)
      ASSERT(uninit%front%name == 'B_first')
      ASSERT(uninit%back%name == 'B_second')

   end subroutine


   subroutine testMovableLeakyMove
      type(ftlDynArrayMovableLeaky) :: v, u, uninit

      call v%New(3)
      call v%data( 1)%New('A_first' , 1000)
      call v%data( 2)%New('A_second', 2000)
      call v%data( 3)%New('A_third' , 3000)

      call u%New(2)
      call u%data( 1)%New('B_first' , 10000)
      call u%data( 2)%New('B_second', 20000)

      call ftlMove(v, u)

      ASSERT(size(v) == 0)
      ASSERT(.not.associated(v%data))
      ASSERT(u%data(2)%name == 'A_second')
      ASSERT(size(u) == 3)
      ASSERT(u%front%name == 'A_first')
      ASSERT(u%back%name == 'A_third')

      call ftlMove(uninit, u)

      ASSERT(size(u) == 0)
      ASSERT(.not.associated(u%data))

   end subroutine


end module
