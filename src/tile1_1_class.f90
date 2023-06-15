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
! Contributed by Vincent Magnin, 2023-06-12
! Last modifications: 2023-06-12
!------------------------------------------------------------------------------

module tile1_1_class
    use, intrinsic :: iso_c_binding, only: dp=>c_double, c_ptr

    implicit none

    type :: Tile1_1
        complex(dp), private :: vertex(14)
    contains
        procedure :: set
        procedure :: draw
        procedure :: print
    end type Tile1_1

contains

    subroutine set(self, start, side_length)
        class(Tile1_1), intent(inout) :: self
        ! Top left vertex of the hat (our starting point):
        complex(dp), intent(in) :: start
        ! All the edges will have the same length:
        real(dp), intent(in) :: side_length
        ! The y axis going downward in Cairo, the +rotation must be inverted:
        ! 60° rotation:
        complex(dp), parameter :: ROTATE60  = cmplx(0.5_dp, -sqrt(3._dp) / 2, dp)
        ! 90° rotation:
        complex(dp), parameter :: ROTATE90  = cmplx(0._dp, -1._dp, dp)
        ! 120° rotation:
        complex(dp), parameter :: ROTATE120 = cmplx(-0.5_dp, -sqrt(3._dp) / 2, dp)
        ! Translations:
        complex(dp) :: VERTICAL
        complex(dp) :: HORIZONTAL
        VERTICAL   = cmplx(0._dp, side_length, dp)
        HORIZONTAL = cmplx(side_length, 0._dp, dp)

        ! The 14 vertices of the tile(1,1): we follow the same path as for the hat.
        ! The rotation angles are relative to the horizontal.
        ! Multiplications are for counter clockwise rotations,
        ! divisions are for clockwise rotations.
        self%vertex(1)  = start
        self%vertex(2)  = self%vertex(1)  + VERTICAL
        self%vertex(3)  = self%vertex(2)  + VERTICAL / ROTATE60
        self%vertex(4)  = self%vertex(3)  + HORIZONTAL / ROTATE60
        self%vertex(5)  = self%vertex(4)  + HORIZONTAL
        self%vertex(6)  = self%vertex(5)  + HORIZONTAL
        self%vertex(7)  = self%vertex(6)  + HORIZONTAL * ROTATE60
        self%vertex(8)  = self%vertex(7)  + VERTICAL * ROTATE60
        self%vertex(9)  = self%vertex(8)  - VERTICAL / ROTATE60
        self%vertex(10) = self%vertex(9)  + HORIZONTAL * ROTATE120
        self%vertex(11) = self%vertex(10) - HORIZONTAL
        self%vertex(12) = self%vertex(11) - VERTICAL
        self%vertex(13) = self%vertex(12) - VERTICAL * ROTATE60
        self%vertex(14) = self%vertex(13) - HORIZONTAL * ROTATE60
    end subroutine set

    subroutine draw(self, cr)
        use cairo
        class(Tile1_1), intent(in) :: self
        ! Cairo context :
        type(c_ptr), intent(in) :: cr
        integer :: i

        call cairo_move_to(cr, self%vertex(1)%re, self%vertex(1)%im)
        do i = 2, size(self%vertex)
            call cairo_line_to(cr, self%vertex(i)%re, self%vertex(i)%im)
        end do
        call cairo_close_path(cr)
        call cairo_stroke(cr)
    end subroutine draw

    ! Useful for testing and debugging:
    subroutine print(self)
        class(Tile1_1), intent(in) :: self
        integer :: i

        print *, "Polygon with ", size(self%vertex), " vertices:"
        print *, self%vertex
    end subroutine

end module tile1_1_class
