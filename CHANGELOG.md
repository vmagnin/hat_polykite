# Changelog
All notable changes to the gtk-fortran project are documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).


## [hat_polykite 2.2] 2024-04-15

### Added
- Four photos in `pictures/`: `a_circle_of_tile1_1.jpg`, `another_circle_of_tile1_1.jpg`, `hat_and_hexagonal_holes.jpg`, `The ein Stein stand - 2024-04-12.jpg`


## [hat_polykite 2.1] 2024-03-12

### Added
* `pictures/one_tile1_1.svg`: it appears in the `README.md` file.
* A red circle at the barycenter of each polygon to mark the front face.

### Changed
* Copied the resulting `.svg` files in the `pictures/` directory.
* Replaced `src/hat_polykite_class.f90` and `src/tile1_1_class.f90` by the abstract class `src/tile_class.f90`, extended in two classes `Hat_polykite` and `Tile1_1`.


## [hat_polykite 2.0] 2023-06-15

### Added
* `tile1_1_class.f90` module (class): draws a Tile(1,1) chiral aperiodic monotile in a `tile1_1.svg` file.


## [hat_polykite 1.0] 2023-06-02

Initial commit.
