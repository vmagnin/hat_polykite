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
! Last modifications: 2024-03-12
!------------------------------------------------------------------------------

module tile_class
    use, intrinsic :: iso_c_binding, only: dp=>c_double, c_ptr
    use hexagon_class, only: Hexagon

    implicit none

    private
    public :: Hat_polykite, Tile1_1

    type, abstract :: Polygon
        complex(dp), allocatable :: vertex(:)
    contains
        procedure :: draw => polygon_draw
        procedure :: print => polygon_print
    end type Polygon

    type, extends(Polygon) :: Hat_polykite
    contains
        procedure :: set => Hat_polykite_set
        final :: Hat_polykite_clear
    end type

    type, extends(Polygon) :: Tile1_1
    contains
        procedure :: set => Tile1_1_set
        final :: Tile1_1_clear
    end type

contains

    subroutine Hat_polykite_set(self, start, hx_side)
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
        allocate(self%vertex(13))
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
    end subroutine Hat_polykite_set


    subroutine Hat_polykite_clear(self)

        type(Hat_polykite) :: self

        if(allocated(self%vertex)) deallocate(self%vertex)
    end subroutine


    subroutine Tile1_1_set(self, start, side_length)
        class(Tile1_1), intent(inout) :: self
        ! Top left vertex of the hat (our starting point):
        complex(dp), intent(in) :: start
        ! All the edges will have the same length:
        real(dp), intent(in) :: side_length
        ! The y axis going downward in Cairo, the +rotation must be inverted:
        ! 60° rotation:
        complex(dp), parameter :: ROTATE60  = cmplx(0.5_dp, -sqrt(3._dp) / 2, dp)
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
        allocate(self%vertex(14))
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
    end subroutine Tile1_1_set


    subroutine Tile1_1_clear(self)
        type(Tile1_1) :: self

        if(allocated(self%vertex)) deallocate(self%vertex)
    end subroutine


    subroutine polygon_draw(self, cr)
        use cairo
        class(Polygon), intent(in) :: self
        ! Cairo context :
        type(c_ptr), intent(in) :: cr
        integer :: i
        real(dp), parameter :: pi = acos(-1._dp)
        real(dp)    :: radius
        complex(dp) :: barycenter

        ! Draw the polygone in blue:
        call cairo_set_source_rgb(cr, 0._dp, 0._dp, 1._dp)

        call cairo_move_to(cr, self%vertex(1)%re, self%vertex(1)%im)
        do i = 2, size(self%vertex)
            call cairo_line_to(cr, self%vertex(i)%re, self%vertex(i)%im)
        end do
        call cairo_close_path(cr)
        call cairo_stroke(cr)

        ! Add a red circle in the middle to mark the front face:
        barycenter = sum(self%vertex(:)) / size(self%vertex(:))
        radius = abs(self%vertex(2) - self%vertex(1)) / 5._dp
        call cairo_set_source_rgb(cr, 1._dp, 0._dp, 0._dp)
        call cairo_arc(cr, barycenter%re, barycenter%im, radius, 0._dp, 2*pi)
        call cairo_stroke(cr)
    end subroutine


    ! Useful for testing and debugging:
    subroutine polygon_print(self)
        class(Polygon), intent(in) :: self

        print *, "Polygon with ", size(self%vertex), " vertices:"
        print *, self%vertex
    end subroutine

end module tile_class
