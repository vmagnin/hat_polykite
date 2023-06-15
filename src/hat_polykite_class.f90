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

module hat_polykite_class
    use, intrinsic :: iso_c_binding, only: dp=>c_double, c_ptr
    use hexagon_class, only: Hexagon

    implicit none

    type :: Hat_polykite
        complex(dp), private :: vertex(13)
    contains
        procedure :: set
        procedure :: draw
        procedure :: print
    end type Hat_polykite

contains

    subroutine set(self, start, hx_side)
        class(Hat_polykite), intent(inout) :: self
        ! Top left vertex of the hat (our starting point):
        complex(dp), intent(in) :: start
        ! Side length of the hexagons used to define the polykite:
        real(dp), intent(in)    :: hx_side
        ! Three adjacent hexagons are needed:
        type(Hexagon) :: hx1, hx2, hx3

        ! Left hexagon (the hat starts at its top apothem):
        call hx1%set(start + cmplx(-hx_side / 2 , 0._dp, dp), hx_side)
        ! Bottom right hexagon:
        call hx2%set(hx1%vertex(5), hx_side)
        ! Upper right hexagon:
        call hx3%set(hx2%vertex(1) + cmplx(0._dp, -hx_side * sqrt(3._dp), dp), hx_side)

        ! The 13 vertices of the hat polykite:
        self%vertex(1)  = hx1%apothem(1)
        self%vertex(2)  = hx1%center
        self%vertex(3)  = hx1%apothem(3)
        self%vertex(4)  = hx1%vertex(3)
        self%vertex(5)  = hx1%vertex(4)
        self%vertex(6)  = hx1%apothem(5)
        self%vertex(7)  = hx2%center
        self%vertex(8)  = hx2%apothem(6)
        self%vertex(9)  = hx2%vertex(6)
        self%vertex(10) = hx2%apothem(1)
        self%vertex(11) = hx3%center
        self%vertex(12) = hx3%apothem(2)
        self%vertex(13) = hx3%vertex(2)
    end subroutine set

    subroutine draw(self, cr)
        use cairo
        class(Hat_polykite), intent(in) :: self
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
        class(Hat_polykite), intent(in) :: self
        integer :: i

        print *, "Polygon with ", size(self%vertex), " vertices:"
        print *, self%vertex
    end subroutine

end module hat_polykite_class
