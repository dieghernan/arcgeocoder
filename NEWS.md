# arcgeocoder 0.4.1

- Reviewed and aligned documentation terminology across **roxygen2**, README and
  vignettes with AI assistance.
- Refactored internal geocoding helpers for simpler maintenance, including
  shared query, progress, validation and API-call utilities. The refactor was
  developed with AI assistance and does not change the public API.

# arcgeocoder 0.4.0

- Migrated the documentation to Quarto (#24).

# arcgeocoder 0.3.0

- The minimum required **R** version is now `4.1.0`.

# arcgeocoder 0.2.1

- Updated the documentation.

# arcgeocoder 0.2.0

- Added **ggplot2** and **sf** to Suggests.
- Fixed typos in the documentation.
- `arc_geo_categories()` is now vectorized over the `category` argument.
- `custom_query` now accepts vectors in each named element.

# arcgeocoder 0.1.0

- First **CRAN** release.
- Added articles to the **pkgdown** site and included icons for examples.
- Changed project status to active.
- Added the `arc_spatial_references` data object.

# arcgeocoder 0.0.1

- Initial release.
