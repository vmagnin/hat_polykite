! This file is part of the hat polykite project.
! Copyright (C) 2023 Vincent MAGNIN
!
! This is free software; you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation; either version 3, or (at your option)
! any later version.
!
! This software is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License along with
! this program; see the files LICENSE and LICENSE_EXCEPTION respectively.
! If not, see <http://www.gnu.org/licenses/>.
!------------------------------------------------------------------------------
! Contributed by Vincent Magnin, 2023-06-01
! Last modifications: 2023-06-02
!------------------------------------------------------------------------------

module hexagon_class
    use, intrinsic :: iso_c_binding, only: dp=>c_double

    implicit none

    type :: Hexagon
        complex(dp) :: vertex(6)
        complex(dp) :: apothem(6)
        complex(dp) :: center
    contains
        procedure :: set
        procedure :: print
    end type Hexagon

contains

    ! Computes the coordinates of the vertices and apothems of an hexagon
    ! whose bottom side is parallel to the x axis. The starting point is
    ! the top left vertex. We work in the complex plane.
    ! Properties of an hexagon: https://en.wikipedia.org/wiki/Hexagon
    subroutine set(self, start, side)
        class(Hexagon), intent(inout) :: self
        complex(dp), intent(in) :: start
        real(dp), intent(in)    :: side
        ! The y axis going downward in Cairo, the 60° rotation must be inverted:
        complex(dp), parameter :: ROTATE = cmplx(0.5_dp, -sqrt(3._dp) / 2, dp)
        integer :: i

        self%vertex(1)  = start
        ! The first apothem is at its right:
        self%apothem(1) = start + cmplx(side / 2, 0._dp, dp)
        ! The center is below the first apothem:
        self%center     = self%apothem(1) + cmplx(0._dp, + side * sqrt(3._dp) / 2, dp)

        ! The other vertices and apothems are computed by successive
        ! 60° rotations around the center of the hexagon:
        do i = 2, 6
            self%vertex(i)  = self%center + (self%vertex(i-1) - self%center) * ROTATE
            self%apothem(i) = self%center + (self%apothem(i-1)- self%center) * ROTATE
        end do
    end subroutine set

    ! Useful for testing and debugging:
    subroutine print(self)
        class(Hexagon), intent(in) :: self

        print *, "Hexagon vertices:"
        print *, self%vertex
        print *, "Apothems:"
        print *, self%apothem
        print *, "Center:"
        print *, self%center
        print *, "------------------------------------------------------------"
    end subroutine

end module hexagon_class
