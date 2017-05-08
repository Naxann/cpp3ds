# - Find libfmt
#
#  FMT_INCLUDE_DIR - where to find libfmt headers.
#  FMT_LIBRARY     - List of libraries when using libfmt.
#  FMT_FOUND       - True if libfmt found.

if(FMT_INCLUDE_DIR)
    # Already in cache, be silent
    set(FMT_FIND_QUIETLY TRUE)
endif(FMT_INCLUDE_DIR)

find_path(FMT_INCLUDE_DIR fmt/format.h)
find_library(FMT_LIBRARY NAMES fmt)

# Handle the QUIETLY and REQUIRED arguments and set FMT_FOUND to TRUE if
# all listed variables are TRUE.
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(FMT DEFAULT_MSG
        FMT_INCLUDE_DIR FMT_LIBRARY)

mark_as_advanced(FMT_INCLUDE_DIR FMT_LIBRARY)
