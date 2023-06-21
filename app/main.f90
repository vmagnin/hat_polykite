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
! Last modifications: 2023-06-21
!------------------------------------------------------------------------------

program main
    use, intrinsic :: iso_c_binding, only: dp=>c_double
    ! Use the cairo-fortran bindings:
    use cairo
    use cairo_enums
    ! Our objects:
    use tile_class

    implicit none
    ! Cairo surface and Cairo context:
    type(c_ptr) :: surface, cr
    character(*), parameter :: FILENAME_HAT = "hat_polykite.svg"
    character(*), parameter :: FILENAME_TILE1_1 = "tile1_1.svg"
    ! Size of the surface in mm (A4 paper):
    real(dp), parameter :: IMAGE_WIDTH  = 210._dp
    real(dp), parameter :: IMAGE_HEIGHT = 297._dp
    ! Hexagon side length in mm:
    real(dp), parameter :: HX_SIDE = 20._dp
    integer  :: i, j
    real(dp) :: x, y

    ! ***********************
    ! The hat polykite
    ! ***********************
    ! The object will be rendered in a SVG file:
    surface = cairo_svg_surface_create(FILENAME_HAT//c_null_char, &
                                      & IMAGE_WIDTH, IMAGE_HEIGHT)
    call cairo_svg_surface_set_document_unit(surface, CAIRO_SVG_UNIT_MM)
    cr = cairo_create(surface)

    ! Initialize parameters:
    call cairo_set_antialias(cr, CAIRO_ANTIALIAS_BEST)
    call cairo_set_line_width(cr, 1._dp)
    ! Draw in blue:
    call cairo_set_source_rgb(cr, 0._dp, 0._dp, 1._dp)

    ! Create and draw several columns of hat polykites:
    x = 20._dp  ! mm left margin
    do j = 1, 3
        y = 20._dp  ! mm top margin
        do i = 1, 7
            block
                type(Hat_polykite) :: hat
                call hat%set(start=cmplx(x+10._dp, y, dp), hx_side=HX_SIDE)
                call hat%draw(cr)
            end block
            y = y + sqrt(3._dp) * HX_SIDE
        end do
        x = x + 3 * HX_SIDE
    end do

    ! Finalyze:
    call cairo_destroy(cr)
    call cairo_surface_destroy(surface)
    print *, "-----------------------------"
    print *, "Output file: ", FILENAME_HAT

    ! ***********************
    ! The Tile(1,1)
    ! ***********************
    ! The object will be rendered in a SVG file:
    surface = cairo_svg_surface_create(FILENAME_TILE1_1//c_null_char, &
                                      & IMAGE_WIDTH, IMAGE_HEIGHT)
    call cairo_svg_surface_set_document_unit(surface, CAIRO_SVG_UNIT_MM)
    cr = cairo_create(surface)

    ! Initialize parameters:
    call cairo_set_antialias(cr, CAIRO_ANTIALIAS_BEST)
    call cairo_set_line_width(cr, 1._dp)
    ! Draw in blue:
    call cairo_set_source_rgb(cr, 0._dp, 0._dp, 1._dp)

    ! Create and draw several columns of Tile(1,1):
     x = 20._dp  ! mm left margin
     do j = 1, 3
         y = 20._dp  ! mm top margin
         do i = 1, 7
            block
                type(Tile1_1) :: tile11
                call tile11%set(start=cmplx(x+10._dp, y, dp), side_length=20._dp)
                call tile11%draw(cr)
            end block
            y = y + 4 * 20._dp
         end do
         x = x + 5 * 20._dp
     end do

    ! Finalyze:
    call cairo_destroy(cr)
    call cairo_surface_destroy(surface)
    print *, "-----------------------------"
    print *, "Output file: ", FILENAME_TILE1_1
    print *, "-----------------------------"
end program main
